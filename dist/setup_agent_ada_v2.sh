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

ADA_VERSION="2.2.0"
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
  echo "  2. Projeto novo: descreva a ideia; o agente fará o discovery."
  echo "  3. Valide: .agent/scripts/verify.sh"
fi
echo "Reexecutar é seguro. Para atualizar o framework depois: --upgrade."
exit 0
__ADA_PAYLOAD__
H4sIAAAAAAAAA+xcTW8cR3rWeX5Fhd4Dh54PciiSC0pQQFO0VxuZJkhpN8CuwanpLg5L7O4aV3WP
KC0XyGmvWQR7yyEwcljYiE/KAoGv80/8B5KfkOd9q7qnZ0iKVixSu8gUIA2nu7q+3q/n/ejpdO/d
eltF21pdpc+1rY21+mfZ7q1t9Da3emu99Y3evdXe6ubW5j2xcftLu3evcLm0Qtyz0cv26tpaVLx6
nZ6NT14oLc9fRcnPR3KgqN9N9/9GW6cbJbKI1W2ywTvQf219i+jfW1u/v6D/XbSK/k7luc6GrvPC
mez9zkEE3rye/pD6XkX/zS30693f3Ny6J1bf7zKubv/P6f+7hhBLI2VT7Zw2mVvaFnQJF2WSmJf4
+hv+igufSHe63JFDleVdF1k9yl13rKw+edVxp9srzaXW23pGpyo6a7vIjNSP6Q6q5IULPbnjl62w
LndWX9VerPPlTrejsnFtyNrVzsoV14c618PMWDU3eKyyV1eMnplYHacmLhLluitXDDhWWWzslbc6
uDe+7iF/wy8B//+euiydGnNWI8SRYtIcgU/z2tp+Fz5rD/ymulS/zV3yVyOFHkuRSVOZxdVawu3y
Mnr8dulnu093nj/eOz44/OKXe7vPjh8/OfztUvc6Aol2e2C1Olmqjfj76u8vG/Ur5TEfWPXMmOS5
U1dvKJU5+MXScuisLj4vklzzX7+2OlcX+yZXA2yaLtW28kEOgufsDgtp47bCenAk73IUR7kZ/fVQ
1W/Gqq8KbVW7ku4ftSHi38bvGx9aoy3auzTYf88k7vYQ4LvgP2//exurawv8dxetRn+rcpNK20nj
9zzHDfhvdeP+/Xn8x/Rf4L/bb+12uxErr/4BMrbF58blVgrphBupyAmZ6zG+KOHZQ0ihzlVUTP48
+XcjdJYra0060rFs0FCNQyAl0b8OK/Q74kiJU1PAsvD4ov8kEwfWDC1ATr8lEhxrW/K42sqWMGLy
PUx/ajD9UGNlRtD4D0fhkePEDB/1sToj+sB0ItYnJ/0HIjLZCZ4Xjm5EkzexHhoxkLnCnVQYJ0bS
OXz0f3P+JT2N/nB+CiViI0Z28uacZuQ+YgRkh72o+spTqR2to0ixRIDnYYEO4qtCJqIUIvGzncPP
nn++t//s6K/aItbkn+jx/oX/3s3y39tcJ/nf2NzYuL8JwV/trW9t9hbyfxftkvzvWi2Jsb14Lsca
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
