#!/usr/bin/env bash
# Registra em template/known_hashes.txt o hash de cada arquivo do template (atual ou de commits passados).
# O `install.sh --upgrade` usa essa lista para saber se um arquivo instalado ainda é original
# (pode ser atualizado) ou foi customizado pelo usuário (gera .ada-new).
# Uso: tools/record_hashes.sh            # template atual (rodado pelo build_single.sh)
#      tools/record_hashes.sh <commit>... # versões antigas, a partir do git
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="template/known_hashes.txt"
sha() { if command -v sha256sum >/dev/null; then sha256sum | cut -d' ' -f1; else shasum -a 256 | cut -d' ' -f1; fi; }

lines="$({
  [[ -f "$OUT" ]] && grep -v '^#' "$OUT" || true
  if [[ $# -eq 0 ]]; then
    find template -type f ! -name 'known_hashes.txt*' | sort | while IFS= read -r f; do
      echo "$(sha < "$f") ${f#template/}"
    done
  else
    for c in "$@"; do
      git ls-tree -r --name-only "$c" -- template | grep -v 'known_hashes.txt$' | while IFS= read -r f; do
        echo "$(git show "$c:$f" | sha) ${f#template/}"
      done
    done
  fi
} | sort -u -k2,2 -k1,1)"
{ echo "# Gerado por tools/record_hashes.sh. Não edite à mão."; echo "$lines"; } > "$OUT"
echo "✅ $OUT: $(grep -vc '^#' "$OUT") hashes"
