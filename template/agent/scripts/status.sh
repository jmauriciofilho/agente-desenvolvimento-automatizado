#!/usr/bin/env bash
# Mostra as specs/mini-specs em .agent/specs/active/: status, progresso do plano, próximo passo e último registro.
# Uso: .agent/scripts/status.sh            # relatório completo
#      .agent/scripts/status.sh --brief    # só imprime se houver spec ativa (usado no início da sessão)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
BRIEF=0; [[ "${1:-}" == "--brief" ]] && BRIEF=1

FILES=()
for f in .agent/specs/active/*.md; do [[ -f "$f" ]] && FILES+=("$f"); done
if [[ ${#FILES[@]} -eq 0 ]]; then
  [[ "$BRIEF" == "1" ]] || echo "Nenhuma spec ativa em .agent/specs/active/."
  exit 0
fi

echo "📋 ADA — specs ativas"
IN_PROGRESS=0
for f in "${FILES[@]}"; do
  status="$(grep -oE 'Status:\*\*[[:space:]]*[A-Za-z ]+' "$f" | head -n1 | sed -E 's/.*\*\*[[:space:]]*//; s/[[:space:]]+$//')"
  [[ "$status" == "In Progress" ]] && IN_PROGRESS=$((IN_PROGRESS + 1))
  total="$(grep -cE '^[[:space:]]*- \[[ xX]\] [0-9]+\.' "$f")"
  done_="$(grep -cE '^[[:space:]]*- \[[xX]\] [0-9]+\.' "$f")"
  next="$(grep -m1 -E '^[[:space:]]*- \[ \] [0-9]+\.' "$f" | sed -E 's/^[[:space:]]*- \[ \] //')"
  last="$(sed -n '/<progress_log>/,/<\/progress_log>/p' "$f" | grep -E '^[[:space:]]*- \[[0-9]' | tail -n1 | sed -E 's/^[[:space:]]*- //')"
  echo "- $f — ${status:-sem status} — plano: $done_/$total"
  if [[ -n "$next" ]]; then echo "    próximo: $next"; fi
  if [[ -n "$last" ]]; then echo "    último registro: $last"; fi
done
if [[ "$IN_PROGRESS" -gt 1 ]]; then
  echo "⚠️  $IN_PROGRESS specs em In Progress: só uma pode estar em execução. Pergunte ao usuário qual continuar e volte as outras para Planned."
elif [[ "$IN_PROGRESS" -eq 1 ]]; then
  echo "➡️  Há execução interrompida: antes de uma tarefa nova, pergunte ao usuário se deve retomá-la."
fi
exit 0
