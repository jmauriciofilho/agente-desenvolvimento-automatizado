#!/usr/bin/env bash
# Executa lint, typecheck, test e build conforme <commands> em .agent/project_instructions.md
# Uso: .agent/scripts/verify.sh [etapa ...]   (ex.: verify.sh lint test)
#      .agent/scripts/verify.sh --state       (imprime o hash do código alterado; usado pelos hooks)
# A execução completa (sem argumentos) também confere o escopo (check-scope.sh) e, se tudo passar,
# grava o carimbo em .git/ada-verify-stamp para o hook Stop saber que o estado atual foi verificado.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

# Hash do estado do código fora de .agent/ (vazio se não há mudanças ou não é repositório git)
code_state() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local data
  data="$({
    git diff HEAD -- . ':(exclude).agent' 2>/dev/null || git diff -- . ':(exclude).agent'
    git ls-files --others --exclude-standard -- . ':(exclude).agent' | while IFS= read -r f; do
      # symlink (ex.: .claude/skills -> ../.agent/skills): usa o alvo, não o conteúdo
      if [[ -L "$f" ]]; then echo "$f -> $(readlink "$f")"; else echo "$f $(git hash-object -- "$f")"; fi
    done
  })"
  if [[ -n "$data" ]]; then printf '%s' "$data" | git hash-object --stdin; fi
}

if [[ "${1:-}" == "--state" ]]; then code_state; exit 0; fi
FILE=".agent/project_instructions.md"

if [[ ! -f "$FILE" ]]; then
  echo "❌ $FILE não encontrado. Rode a skill auto-context."; exit 2
fi
if grep -q 'ADA:UNCONFIGURED' "$FILE"; then
  echo "❌ $FILE ainda não configurado (marcador ADA:UNCONFIGURED). Rode a skill auto-context."; exit 2
fi

get_cmd() {
  sed -n '/<commands>/,/<\/commands>/p' "$FILE" \
    | grep -E "^[[:space:]]*-[[:space:]]*$1:" | head -n1 \
    | sed -E 's/^[^:]*:[[:space:]]*//; s/^`//; s/`[[:space:]]*$//; s/[[:space:]]+$//'
}

FULL=0
if [[ $# -gt 0 ]]; then STEPS=("$@"); else STEPS=(lint typecheck test build); FULL=1; fi

PASSED=(); FAILED=(); SKIPPED=()
if [[ "$FULL" == "1" && -x .agent/scripts/check-scope.sh ]]; then
  if ! .agent/scripts/check-scope.sh; then FAILED+=("scope"); fi
  echo
fi
for step in "${STEPS[@]}"; do
  cmd="$(get_cmd "$step")"
  shopt -s nocasematch
  if [[ -z "$cmd" || "$cmd" == \[* || "$cmd" == "N/A" ]]; then
    shopt -u nocasematch
    SKIPPED+=("$step"); echo "⏭️  $step: não configurado"; continue
  fi
  shopt -u nocasematch
  echo "▶️  $step: $cmd"
  if bash -c "$cmd"; then PASSED+=("$step"); echo "✅ $step OK"
  else FAILED+=("$step"); echo "❌ $step FALHOU"; fi
  echo
done

echo "================ RESUMO ================"
echo "OK:        ${PASSED[*]:-nenhuma}"
echo "Falhas:    ${FAILED[*]:-nenhuma}"
echo "Ignoradas: ${SKIPPED[*]:-nenhuma}"

if [[ ${#FAILED[@]} -gt 0 ]]; then exit 1; fi
if [[ "$FULL" == "1" ]] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  code_state > "$(git rev-parse --git-path ada-verify-stamp)"
fi
if [[ ${#PASSED[@]} -eq 0 ]]; then echo "⚠️  Nada foi executado: configure <commands>."; exit 3; fi
exit 0
