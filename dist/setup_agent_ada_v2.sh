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
__ADA_PAYLOAD__
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
