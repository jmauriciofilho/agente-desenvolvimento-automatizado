#!/usr/bin/env bash
# Hook Stop (Claude Code): impede encerrar o turno com mudanças fora do escopo ou não verificadas.
# A verificação vale se o último `verify.sh` completo passou com o código no estado atual.
# Bloqueia uma vez por turno (respeita stop_hook_active para não entrar em loop).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT"

input="$(cat)"
if printf '%s' "$input" | grep -qE '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then exit 0; fi
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
FILE=".agent/project_instructions.md"
if [[ ! -f "$FILE" ]] || grep -q 'ADA:UNCONFIGURED' "$FILE"; then exit 0; fi

if ! scope="$(.agent/scripts/check-scope.sh 2>&1)"; then
  echo "ADA: $scope" >&2
  echo "Reverta essas mudanças ou peça autorização e atualize <files_in_scope>." >&2
  exit 2
fi

state="$(.agent/scripts/verify.sh --state)"
[[ -z "$state" ]] && exit 0   # nada alterado fora de .agent/
stamp="$(git rev-parse --git-path ada-verify-stamp)"
if [[ -f "$stamp" && "$(cat "$stamp")" == "$state" ]]; then exit 0; fi

echo "ADA: há mudanças de código não verificadas. Rode .agent/scripts/verify.sh (sem argumentos) e corrija as falhas antes de encerrar." >&2
exit 2
