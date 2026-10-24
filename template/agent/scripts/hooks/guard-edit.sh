#!/usr/bin/env bash
# Hook PreToolUse (Claude Code): bloqueia edição fora do escopo da spec em andamento.
# Recebe o JSON da ferramenta no stdin. Saída 2 bloqueia a edição e devolve a mensagem ao agente.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

input="$(cat)"
file="$(printf '%s' "$input" | grep -oE '"(file_path|notebook_path)"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed -E 's/.*:[[:space:]]*"([^"]*)"$/\1/')"
[[ -z "$file" ]] && exit 0

if ! msg="$("$ROOT/.agent/scripts/check-scope.sh" --file "$file" 2>&1)"; then
  echo "ADA: $msg" >&2
  exit 2
fi
exit 0
