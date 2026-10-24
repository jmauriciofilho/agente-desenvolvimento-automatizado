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

ADA_VERSION="2.1.0"
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
    claude/*) has_tool claude || continue; dst=".$rel" ;;
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
find .agent/scripts -name '*.sh' -exec chmod +x {} + 2>/dev/null || true

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

if has_tool claude && [[ -f .claude/settings.json ]] && ! grep -q 'guard-edit.sh' .claude/settings.json; then
  echo "⚠️  .claude/settings.json já existia: mescle os hooks e permissões de template/claude/settings.json do ADA para ativar a proteção de escopo."
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
q221+dv/A9fvs/4AkAEA
