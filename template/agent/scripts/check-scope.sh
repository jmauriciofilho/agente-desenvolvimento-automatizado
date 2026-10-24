#!/usr/bin/env bash
# Confere se as mudanças estão dentro do escopo das specs em andamento (Status: In Progress).
# Escopo = caminhos em `<files_in_scope>` e `<test_plan>` (spec) ou na linha **Arquivos:** (mini-spec).
# Caminhos aceitam diretório (terminado em /) e glob (src/foo/*). Arquivos em .agent/ são sempre permitidos.
# Uso: .agent/scripts/check-scope.sh             # confere o diff atual (git)
#      .agent/scripts/check-scope.sh --file PATH # confere um arquivo (usado pelo hook do Claude Code)
# Saída: 0 dentro do escopo ou sem spec em andamento | 1 fora do escopo | 2 erro de uso
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

active_specs() {
  local f
  for f in .agent/specs/active/*.md; do
    [[ -f "$f" ]] || continue
    if grep -qE 'Status:\*\*[[:space:]]*In Progress' "$f"; then echo "$f"; fi
  done
}

# Extrai os caminhos entre crases das seções de escopo de uma spec/mini-spec
scope_of() {
  {
    sed -n '/<files_in_scope>/,/<\/files_in_scope>/p; /<test_plan>/,/<\/test_plan>/p' "$1"
    grep -E '^[[:space:]]*-[[:space:]]*\*\*Arquivos:\*\*' "$1"
  } | grep -v '^[[:space:]]*<!--' | grep -oE '`[^`]+`' | tr -d '`' | sed 's#^\./##'
}

in_scope() {
  local file="$1" pat
  [[ "$file" == .agent/* ]] && return 0
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    if [[ "$pat" == */ ]]; then [[ "$file" == "$pat"* ]] && return 0
    else
      # shellcheck disable=SC2053  # glob intencional
      [[ "$file" == $pat ]] && return 0
    fi
  done <<< "$SCOPE"
  return 1
}

mapfile -t SPECS < <(active_specs)
if [[ ${#SPECS[@]} -eq 0 ]]; then
  [[ "${1:-}" == "--file" ]] || echo "⏭️  scope: nenhuma spec em andamento (In Progress)"
  exit 0
fi
SCOPE="$(for s in "${SPECS[@]}"; do scope_of "$s"; done | sort -u)"

if [[ "${1:-}" == "--file" ]]; then
  [[ -n "${2:-}" ]] || { echo "Uso: check-scope.sh --file PATH" >&2; exit 2; }
  f="${2#"$ROOT"/}"; f="${f#./}"
  if in_scope "$f"; then exit 0; fi
  echo "❌ '$f' está fora do escopo de: ${SPECS[*]}" >&2
  echo "   Peça autorização ao usuário, registre em <change_log> e adicione o arquivo a <files_in_scope>." >&2
  exit 1
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "❌ scope: não é um repositório git" >&2; exit 2; }
OUT=()
while IFS= read -r f; do
  [[ -n "$f" ]] && ! in_scope "$f" && OUT+=("$f")
done < <({ git diff --name-only HEAD 2>/dev/null || git diff --name-only; git ls-files --others --exclude-standard; } | sort -u)

if [[ ${#OUT[@]} -gt 0 ]]; then
  echo "❌ scope: arquivos fora do escopo de ${SPECS[*]}:"
  printf '   - %s\n' "${OUT[@]}"
  exit 1
fi
echo "✅ scope: todas as mudanças dentro do escopo"
exit 0
