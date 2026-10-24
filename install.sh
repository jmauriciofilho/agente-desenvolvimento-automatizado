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
