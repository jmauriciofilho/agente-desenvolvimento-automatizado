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

ADA_VERSION="2.4.1"
SELF="${BASH_SOURCE[0]}"
SELF_DIR="$(cd "$(dirname "$SELF")" && pwd)"

# Convenções por ferramenta (ajuste aqui se mudarem). Antigravity usa .agent/skills nativamente.
CLAUDE_SKILLS_DIR=".claude/skills"
CODEX_SKILLS_DIR=".agents/skills"
OPENCODE_SKILLS_DIR=".opencode/skills"
CLAUDE_COMMANDS_DIR=".claude/commands"
OPENCODE_COMMANDS_DIR=".opencode/command"

# Windows (Git Bash/MSYS/Cygwin): por padrão `ln -s` copia em silêncio. Com nativestrict ele cria symlink
# de verdade (Modo de Desenvolvedor ou admin) ou falha, e aí caímos na cópia marcada com .ada-copy.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*) export MSYS="${MSYS:+$MSYS }winsymlinks:nativestrict" ;;
  CYGWIN*) export CYGWIN="${CYGWIN:+$CYGWIN }winsymlinks:nativestrict" ;;
esac

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

# Pasta de skills sem .ada-copy que é cópia do ADA? (versões antigas no Git Bash copiavam sem marcar)
# Só é se todo arquivo dela for igual ao atual ou a uma versão publicada do template.
is_unmarked_ada_copy() {
  local link="$1" f rel h n=0
  [[ -d "$link" && ! -f "$link/.ada-copy" ]] || return 1
  while IFS= read -r -d '' f; do
    rel="${f#"$link"/}"; n=$((n + 1))
    if cmp -s "$f" ".agent/skills/$rel"; then continue; fi
    h="$(sha < "$f")"
    [[ -f "$SRC/known_hashes.txt" ]] && grep -qxF "$h agent/skills/$rel" "$SRC/known_hashes.txt" || return 1
  done < <(find "$link" -type f -print0)
  [[ "$n" -gt 0 ]]
}

copy_skills() {
  rm -rf "$1"; mkdir -p "$(dirname "$1")"; cp -R .agent/skills "$1"; : > "$1/.ada-copy"
}

link_skills() {
  local link="$1" target="../.agent/skills"
  if [[ -L "$link" ]]; then return 0; fi
  if [[ "$DRY" == "1" ]]; then echo "🔗 (dry-run) link/cópia: $link"; return 0; fi
  if is_unmarked_ada_copy "$link"; then : > "$link/.ada-copy"; echo "🏷️  cópia antiga do ADA reconhecida: $link"; fi
  if [[ -d "$link" && -f "$link/.ada-copy" ]]; then
    copy_skills "$link"
    echo "♻️  cópia atualizada: $link"; return 0
  fi
  if [[ -e "$link" ]]; then echo "⚠️  $link existe e não é do ADA; mantido (mescle manualmente)."; return 0; fi
  mkdir -p "$(dirname "$link")"
  # Confere com -L: no Windows o `ln -s` pode "dar certo" criando uma cópia comum
  if ln -s "$target" "$link" 2>/dev/null && [[ -L "$link" ]]; then echo "🔗 link: $link -> $target"
  else copy_skills "$link"; echo "📋 cópia (sem symlink; rode o instalador de novo após editar skills): $link"; fi
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
    CLAUDE.md) has_tool claude || continue; dst="$rel" ;;
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
sT22x/d9/H9jf8zBAOABAA==
