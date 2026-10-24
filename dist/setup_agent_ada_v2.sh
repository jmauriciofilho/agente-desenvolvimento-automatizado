#!/usr/bin/env bash
# =============================================================================
# install.sh — ADA v2: Framework Agêntico SDD (Antigravity, Claude Code, Codex e OpenCode)
#
# Copia o conteúdo de template/ para o repositório atual. Fonte única de verdade: .agent/
#   (padrão)    cria só o que falta; nunca sobrescreve
#   --upgrade   atualiza arquivos do framework que você NÃO customizou; customizados recebem <arquivo>.ada-new
#   --force     sobrescreve arquivos do framework (backup .bak.<data>)
# Arquivos do usuário (project_instructions.md, memory/learnings.md, specs, decisions) nunca são sobrescritos.
# No AGENTS.md, só o trecho entre <!-- ADA:BEGIN --> e <!-- ADA:END --> é atualizado.
# =============================================================================
set -euo pipefail

ADA_VERSION="2.3.0"
SELF="${BASH_SOURCE[0]}"
SELF_DIR="$(cd "$(dirname "$SELF")" && pwd)"

# Convenções por ferramenta (ajuste aqui se mudarem). Antigravity usa .agent/skills nativamente.
CLAUDE_SKILLS_DIR=".claude/skills"
CODEX_SKILLS_DIR=".agents/skills"
OPENCODE_SKILLS_DIR=".opencode/skills"
CLAUDE_COMMANDS_DIR=".claude/commands"
OPENCODE_COMMANDS_DIR=".opencode/command"

FORCE=0; UPGRADE=0; DRY=0; NO_LINKS=0; NO_COMMANDS=0; SRC=""
TOOLS="antigravity,claude,codex,opencode"
CREATED=0; UPDATED=0; SKIPPED=0; CONFLICTS=0; TMP=""
MANIFEST=".agent/.ada-manifest"; MANIFEST_NEW=""
STAMP="$(date +%Y%m%d-%H%M%S)"
# Arquivos do usuário: criados uma vez a partir do template e nunca mais tocados
USER_FILES=".agent/project_instructions.md .agent/memory/learnings.md"

usage() {
  cat <<'USO'
Uso: install.sh [opções]
  --upgrade          Atualiza o framework preservando customizações (gera .ada-new nos conflitos)
  --force            Sobrescreve arquivos do framework (backup .bak.<data>); não toca arquivos do usuário
  --dry-run          Mostra o que seria feito, sem alterar nada
  --tools=a,b        antigravity,claude,codex,opencode (padrão: todas)
  --from=DIR|URL     Origem do template (pasta local ou URL git). Padrão: ./template
  --no-links         Não cria links/cópias de skills para outras ferramentas
  --no-commands      Não instala slash-commands
  -h, --help         Ajuda
USO
}

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --upgrade) UPGRADE=1 ;;
    --dry-run) DRY=1 ;;
    --no-links) NO_LINKS=1 ;;
    --no-commands) NO_COMMANDS=1 ;;
    --tools=*) TOOLS="${arg#--tools=}" ;;
    --from=*) SRC="${arg#--from=}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção desconhecida: $arg"; usage; exit 1 ;;
  esac
done

has_tool() { [[ ",$TOOLS," == *",$1,"* ]]; }
cleanup() { if [[ -n "$TMP" ]]; then rm -rf "$TMP"; fi; }
trap cleanup EXIT

# --- Localiza o template: --from, ./template ou payload embutido (build_single.sh) ---
resolve_src() {
  local mark="__ADA_PAYLOAD"; mark+="__"
  if [[ -n "$SRC" ]]; then
    if [[ "$SRC" =~ ^(https?://|git@) ]]; then
      TMP="$(mktemp -d)"; git clone --depth 1 -q "$SRC" "$TMP/repo"; SRC="$TMP/repo"
    fi
    if [[ -d "$SRC/template" ]]; then SRC="$SRC/template"; fi
  elif [[ -d "$SELF_DIR/template" ]]; then
    SRC="$SELF_DIR/template"
  elif grep -q "^${mark}\$" "$SELF"; then
    TMP="$(mktemp -d)"
    sed "1,/^${mark}\$/d" "$SELF" | base64 -d | tar xz -C "$TMP"
    SRC="$TMP"
  fi
  if [[ ! -d "$SRC" ]]; then echo "❌ Template não encontrado. Use --from=DIR|URL."; exit 1; fi
}

sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum | cut -d' ' -f1; else shasum -a 256 | cut -d' ' -f1; fi; }
is_user_file() { [[ " $USER_FILES " == *" $1 "* ]]; }
run() { if [[ "$DRY" == "1" ]]; then return 0; fi; "$@"; }

# Arquivo instalado ainda é original? (hash igual ao do manifesto ou a alguma versão publicada do template)
is_pristine() {
  local dst="$1" rel="$2" h
  h="$(sha < "$dst")"
  if [[ -f "$MANIFEST" ]] && grep -qxF "$h $dst" "$MANIFEST"; then return 0; fi
  [[ -f "$SRC/known_hashes.txt" ]] && grep -qxF "$h $rel" "$SRC/known_hashes.txt"
}

# AGENTS.md com marcadores: substitui só o bloco ADA:BEGIN..ADA:END, preservando o resto
merge_managed_block() {
  local src="$1" dst="$2" out
  out="$(awk -v SRC="$src" '
    BEGIN { while ((getline l < SRC) > 0) { if (l ~ /ADA:BEGIN/) inb=1; if (inb) blk = blk l "\n"; if (l ~ /ADA:END/) inb=0 } }
    /ADA:BEGIN/ { printf "%s", blk; skip=1; next }
    /ADA:END/   { skip=0; next }
    !skip       { print }
  ' "$dst")"
  if [[ "$out" == "$(cat "$dst")" ]]; then echo "⏭️  atual: $dst"; SKIPPED=$((SKIPPED + 1)); return 0; fi
  if [[ "$DRY" != "1" ]]; then printf '%s\n' "$out" > "$dst"; fi
  echo "♻️  bloco ADA atualizado (suas regras preservadas): $dst"; UPDATED=$((UPDATED + 1))
}

# install_file <origem> <destino>
install_file() {
  local src="$1" dst="$2" rel="${1#"$SRC"/}"
  MANIFEST_NEW+="$(sha < "$src") $dst"$'\n'
  if [[ ! -e "$dst" ]]; then
    run mkdir -p "$(dirname "$dst")"; run cp -p "$src" "$dst"
    echo "✅ criado: $dst"; CREATED=$((CREATED + 1)); return 0
  fi
  if is_user_file "$dst" || cmp -s "$src" "$dst"; then SKIPPED=$((SKIPPED + 1)); return 0; fi
  if [[ "$FORCE" == "1" ]]; then
    run cp "$dst" "$dst.bak.$STAMP"; run cp -p "$src" "$dst"
    echo "♻️  sobrescrito (backup: $dst.bak.$STAMP): $dst"; UPDATED=$((UPDATED + 1)); return 0
  fi
  if [[ "$UPGRADE" != "1" ]]; then echo "⏭️  mantido: $dst"; SKIPPED=$((SKIPPED + 1)); return 0; fi
  if [[ "$rel" == "AGENTS.md" ]] && grep -q 'ADA:BEGIN' "$dst" && grep -q 'ADA:END' "$dst"; then
    merge_managed_block "$src" "$dst"; return 0
  fi
  if is_pristine "$dst" "$rel"; then
    run cp -p "$src" "$dst"; echo "⬆️  atualizado: $dst"; UPDATED=$((UPDATED + 1))
  else
    run cp -p "$src" "$dst.ada-new"
    echo "⚠️  customizado, mantido: $dst  →  nova versão em $dst.ada-new (compare e mescle)"
    CONFLICTS=$((CONFLICTS + 1))
  fi
}

link_skills() {
  local link="$1" target="../.agent/skills"
  if [[ -L "$link" ]]; then return 0; fi
  if [[ "$DRY" == "1" ]]; then echo "🔗 (dry-run) link/cópia: $link"; return 0; fi
  if [[ -d "$link" && -f "$link/.ada-copy" ]]; then
    rm -rf "$link"; cp -R .agent/skills "$link"; : > "$link/.ada-copy"
    echo "♻️  cópia atualizada: $link"; return 0
  fi
  if [[ -e "$link" ]]; then echo "⚠️  $link existe e não é do ADA; mantido (mescle manualmente)."; return 0; fi
  mkdir -p "$(dirname "$link")"
  if ln -s "$target" "$link" 2>/dev/null; then echo "🔗 link: $link -> $target"
  else cp -R .agent/skills "$link"; : > "$link/.ada-copy"; echo "📋 cópia (sem symlink): $link"; fi
}

PREV="$(cat .agent/.ada-version 2>/dev/null || true)"
EXISTED=0; [[ -d .agent ]] && EXISTED=1
MODE="instalação"; [[ "$UPGRADE" == "1" ]] && MODE="atualização"; [[ "$FORCE" == "1" ]] && MODE="sobrescrita (--force)"
echo "🚀 ADA v$ADA_VERSION — $MODE${PREV:+ (instalado: v$PREV)} — ferramentas: $TOOLS"
[[ "$DRY" == "1" ]] && echo "🔍 --dry-run: nada será alterado"
resolve_src

# 1. Copia o template (agent/ -> .agent/; commands/ é tratado à parte)
while IFS= read -r -d '' f; do
  rel="${f#"$SRC"/}"
  case "$rel" in
    commands/*|known_hashes.txt*) continue ;;
    agent/*) dst=".$rel" ;;
    claude/*) has_tool claude || continue; dst=".$rel" ;;
    *) dst="$rel" ;;
  esac
  install_file "$f" "$dst"
done < <(find "$SRC" -type f -print0 | sort -z)

# 2. Arquivos derivados (evita duplicar conteúdo no template)
for d in .agent/specs/active .agent/specs/done .agent/decisions; do
  run mkdir -p "$d"
  if [[ ! -e "$d/.gitkeep" ]]; then run touch "$d/.gitkeep"; fi
done
install_file "$SRC/agent/templates/project_instructions.template.md" .agent/project_instructions.md
install_file "$SRC/agent/templates/spec.template.md" .agent/specs/template_spec.md
run find .agent/scripts -name '*.sh' -exec chmod +x {} + 2>/dev/null || true

# 3. Adaptadores por ferramenta
if [[ "$NO_LINKS" != "1" ]]; then
  if has_tool claude;   then link_skills "$CLAUDE_SKILLS_DIR"; fi
  if has_tool codex;    then link_skills "$CODEX_SKILLS_DIR"; fi
  if has_tool opencode; then link_skills "$OPENCODE_SKILLS_DIR"; fi
fi

# 4. Slash-commands (Claude Code e OpenCode)
# No Claude Code, cada skill em .claude/skills/<nome> já vira o comando /<nome>;
# instalar também .claude/commands/<nome>.md duplicaria a entrada no menu.
claude_has_skill() {
  [[ "$NO_LINKS" != "1" && -f "$SRC/agent/skills/$1/SKILL.md" ]]
}
if [[ "$NO_COMMANDS" != "1" && -d "$SRC/commands" ]]; then
  for f in "$SRC"/commands/*.md; do
    n="$(basename "$f")"
    if has_tool claude; then
      if claude_has_skill "${n%.md}"; then
        dst="$CLAUDE_COMMANDS_DIR/$n"
        # Remove a cópia duplicada deixada por versões anteriores (só se for idêntica ao template)
        if [[ "$DRY" != "1" && -f "$dst" ]] && cmp -s "$f" "$dst"; then rm "$dst"; echo "🧹 removido duplicado (já é skill): $dst"; fi
      else
        install_file "$f" "$CLAUDE_COMMANDS_DIR/$n"
      fi
    fi
    if has_tool opencode; then install_file "$f" "$OPENCODE_COMMANDS_DIR/$n"; fi
  done
fi

if has_tool claude && [[ -f .claude/settings.json ]] && ! grep -q 'guard-edit.sh' .claude/settings.json; then
  echo "⚠️  .claude/settings.json já existia: mescle os hooks e permissões de template/claude/settings.json do ADA para ativar a proteção de escopo."
fi

# 5. Arquivos de versões antigas que não existem mais no template (só avisa; nunca apaga)
if [[ -f "$SRC/known_hashes.txt" ]]; then
  while read -r _ rel; do
    case "$rel" in agent/*) dst=".$rel" ;; claude/*|commands/*) continue ;; *) dst="$rel" ;; esac
    if [[ -e "$dst" && ! -e "$SRC/$rel" ]]; then
      if is_pristine "$dst" "$rel"; then echo "🗑️  obsoleto (não existe mais no ADA, pode remover): $dst"
      else echo "🗑️  obsoleto e customizado (revise antes de remover): $dst"; fi
    fi
  done < <(grep -v '^#' "$SRC/known_hashes.txt" | sort -u -k2,2)
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "⚠️  Esta pasta não é um repositório git: o controle de escopo (check-scope.sh) e os hooks só funcionam com git."
  echo "   Rode 'git init' (num projeto novo, a skill bootstrap faz isso no marco 0)."
fi

if [[ "$DRY" != "1" ]]; then
  echo "$ADA_VERSION" > .agent/.ada-version
  { echo "# ADA v$ADA_VERSION — hash do template instalado (usado pelo --upgrade). Não edite."; printf '%s' "$MANIFEST_NEW" | sort -u -k2,2; } > "$MANIFEST"
fi

echo
echo "🎉 ADA v$ADA_VERSION — criados: $CREATED | atualizados: $UPDATED | mantidos: $SKIPPED | conflitos: $CONFLICTS"
if [[ "$CONFLICTS" -gt 0 ]]; then
  echo "⚠️  Mescle os arquivos *.ada-new nos originais e apague os .ada-new (ou peça ao agente: \"mescle os .ada-new do ADA\")."
fi
if [[ "$UPGRADE" != "1" && "$FORCE" != "1" && -n "$PREV" && "$PREV" != "$ADA_VERSION" ]]; then
  echo "ℹ️  Projeto estava na v$PREV: rode com --upgrade para atualizar os arquivos existentes."
fi
echo "Próximos passos:"
if [[ "$EXISTED" == "1" ]]; then
  echo "  1. Mescle os .ada-new (se houver) e revise com: git diff"
  echo "  2. Peça '/context-sync' ao agente para alinhar o project_instructions.md à nova versão."
  echo "  3. Valide: .agent/scripts/verify.sh"
else
  echo "  1. Projeto existente: peça '/auto-context' ao agente."
  echo "  2. Projeto novo: descreva a ideia; o agente fará o discovery e o bootstrap (marco 0)."
  echo "  3. Valide: .agent/scripts/verify.sh"
fi
echo "Reexecutar é seguro. Para atualizar o framework depois: --upgrade."
exit 0
__ADA_PAYLOAD__
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
Ov5/p+P89AC4AQA=
