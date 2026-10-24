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

ADA_VERSION="2.4.0"
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
# Copia do template garantindo leitura para todos (o template pode vir com 600, ex.: payload gerado em outra máquina)
put() { run cp "$1" "$2"; run chmod u+rw,go+r "$2"; }

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
    run mkdir -p "$(dirname "$dst")"; put "$src" "$dst"
    echo "✅ criado: $dst"; CREATED=$((CREATED + 1)); return 0
  fi
  if is_user_file "$dst" || cmp -s "$src" "$dst"; then SKIPPED=$((SKIPPED + 1)); return 0; fi
  if [[ "$FORCE" == "1" ]]; then
    run cp -p "$dst" "$dst.bak.$STAMP"; put "$src" "$dst"
    echo "♻️  sobrescrito (backup: $dst.bak.$STAMP): $dst"; UPDATED=$((UPDATED + 1)); return 0
  fi
  if [[ "$UPGRADE" != "1" ]]; then echo "⏭️  mantido: $dst"; SKIPPED=$((SKIPPED + 1)); return 0; fi
  if [[ "$rel" == "AGENTS.md" ]] && grep -q 'ADA:BEGIN' "$dst" && grep -q 'ADA:END' "$dst"; then
    merge_managed_block "$src" "$dst"; return 0
  fi
  if is_pristine "$dst" "$rel"; then
    put "$src" "$dst"; echo "⬆️  atualizado: $dst"; UPDATED=$((UPDATED + 1))
  else
    put "$src" "$dst.ada-new"
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
/w/SZQg+AOABAA==
