#!/usr/bin/env bash
# =============================================================================
# setup_agent_ada_v2.sh
# Framework Agêntico SDD - compatível com Antigravity, Claude Code, Codex e OpenCode
#
# ADA v2 — instalador. Copia o conteúdo de template/ para o repositório atual.
# Idempotente: NÃO sobrescreve arquivos existentes (use --force para sobrescrever, gerando backup .bak).
# Fonte única de verdade: .agent/  (as demais ferramentas apontam para ela)
# =============================================================================
set -euo pipefail

ADA_VERSION="2.0.0"
SELF="${BASH_SOURCE[0]}"
SELF_DIR="$(cd "$(dirname "$SELF")" && pwd)"

# Convenções por ferramenta (ajuste aqui se mudarem). Antigravity usa .agent/skills nativamente.
CLAUDE_SKILLS_DIR=".claude/skills"
CODEX_SKILLS_DIR=".agents/skills"
OPENCODE_SKILLS_DIR=".opencode/skills"
CLAUDE_COMMANDS_DIR=".claude/commands"
OPENCODE_COMMANDS_DIR=".opencode/command"

FORCE=0; NO_LINKS=0; NO_COMMANDS=0; SRC=""
TOOLS="antigravity,claude,codex,opencode"
CREATED=0; SKIPPED=0; TMP=""

usage() {
  cat <<'USO'
Uso: install.sh [opções]
  --force            Sobrescreve existentes (cria backup .bak)
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

# install_file <origem> <destino>
install_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    if [[ "$FORCE" != "1" ]]; then echo "⏭️  mantido: $dst"; SKIPPED=$((SKIPPED + 1)); return 0; fi
    cp "$dst" "$dst.bak"; cp -p "$src" "$dst"
    echo "♻️  sobrescrito (backup: $dst.bak): $dst"
  else
    cp -p "$src" "$dst"; echo "✅ criado: $dst"
  fi
  CREATED=$((CREATED + 1))
}

link_skills() {
  local link="$1" target="../.agent/skills"
  if [[ -L "$link" ]]; then echo "⏭️  link existe: $link"; return 0; fi
  if [[ -d "$link" && -f "$link/.ada-copy" ]]; then
    rm -rf "$link"; cp -R .agent/skills "$link"; : > "$link/.ada-copy"
    echo "♻️  cópia atualizada: $link"; return 0
  fi
  if [[ -e "$link" ]]; then echo "⚠️  $link existe e não é do ADA; mantido (mescle manualmente)."; return 0; fi
  mkdir -p "$(dirname "$link")"
  if ln -s "$target" "$link" 2>/dev/null; then echo "🔗 link: $link -> $target"
  else cp -R .agent/skills "$link"; : > "$link/.ada-copy"; echo "📋 cópia (sem symlink): $link"; fi
}

echo "🚀 Instalando ADA v$ADA_VERSION (ferramentas: $TOOLS)"
resolve_src

# 1. Copia o template (agent/ -> .agent/; commands/ é tratado à parte)
while IFS= read -r -d '' f; do
  rel="${f#"$SRC"/}"
  case "$rel" in
    commands/*) continue ;;
    agent/*) dst=".$rel" ;;
    *) dst="$rel" ;;
  esac
  install_file "$f" "$dst"
done < <(find "$SRC" -type f -print0 | sort -z)

# 2. Arquivos derivados (evita duplicar conteúdo no template)
mkdir -p .agent/specs/active .agent/specs/done .agent/decisions .agent/memory
for d in .agent/specs/active .agent/specs/done .agent/decisions; do
  if [[ ! -e "$d/.gitkeep" ]]; then : > "$d/.gitkeep"; fi
done
install_file "$SRC/agent/templates/project_instructions.template.md" .agent/project_instructions.md
install_file "$SRC/agent/templates/spec.template.md" .agent/specs/template_spec.md
echo "$ADA_VERSION" > .agent/.ada-version
chmod +x .agent/scripts/verify.sh 2>/dev/null || true

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
        if [[ -f "$dst" ]] && cmp -s "$f" "$dst"; then rm "$dst"; echo "🧹 removido duplicado (já é skill): $dst"; fi
      else
        install_file "$f" "$CLAUDE_COMMANDS_DIR/$n"
      fi
    fi
    if has_tool opencode; then install_file "$f" "$OPENCODE_COMMANDS_DIR/$n"; fi
  done
fi

echo
echo "🎉 ADA v$ADA_VERSION instalado. Criados/atualizados: $CREATED | Mantidos: $SKIPPED"
echo "Próximos passos:"
echo "  1. Projeto existente: peça '/auto-context' ao agente."
echo "  2. Projeto novo: descreva a ideia; o agente fará o discovery."
echo "  3. Valide: .agent/scripts/verify.sh"
echo "Reexecutar é seguro (use --force para sobrescrever, com backup .bak)."
exit 0
