#!/usr/bin/env bash
# Executa lint, typecheck, test e build conforme <commands> em .agent/project_instructions.md
# Uso: .agent/scripts/verify.sh [etapa ...]   (ex.: verify.sh lint test)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
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

if [[ $# -gt 0 ]]; then STEPS=("$@"); else STEPS=(lint typecheck test build); fi

PASSED=(); FAILED=(); SKIPPED=()
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
if [[ ${#PASSED[@]} -eq 0 ]]; then echo "⚠️  Nada foi executado: configure <commands>."; exit 3; fi
exit 0
