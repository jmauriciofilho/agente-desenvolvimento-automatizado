#!/usr/bin/env bash
# Gera um instalador de ARQUIVO ÚNICO (install.sh + template compactado embutido).
# Útil para distribuir por e-mail/curl sem clonar o repositório do framework.
# Uso: ./build_single.sh [saida]   (padrão: dist/setup_agent_ada_v2.sh)
set -euo pipefail
cd "$(dirname "$0")"

OUT="${1:-dist/setup_agent_ada_v2.sh}"
mkdir -p "$(dirname "$OUT")"

{
  cat install.sh
  echo "__ADA_PAYLOAD__"
  tar czf - -C template . | base64
} > "$OUT"

chmod +x "$OUT"
echo "✅ Gerado: $OUT ($(wc -l < "$OUT") linhas, $(wc -c < "$OUT") bytes)"
