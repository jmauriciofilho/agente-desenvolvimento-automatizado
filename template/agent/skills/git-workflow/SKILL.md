---
name: git-workflow
description: Padroniza branches, commits (Conventional Commits) e descrição de PR gerada a partir da spec. Use ao versionar mudanças, criar branch, commitar ou preparar um pull request.
---

# 🌿 Git Workflow

<execution_steps>
1. Leia `<git_conventions>` em `.agent/project_instructions.md` e respeite-as (elas prevalecem sobre este padrão).
2. **Branch:** `feat/<slug>`, `fix/<slug>`, `chore/<slug>`, `refactor/<slug>` a partir da branch base atualizada. Nunca commite direto em `main`/`master` sem autorização.
3. **Commits:** Conventional Commits — `tipo(escopo): resumo no imperativo (≤ 72 chars)` + corpo explicando o "porquê" quando necessário. Commits pequenos e atômicos (um propósito cada). Nunca inclua segredos.
4. Antes de commitar: `git status`, `git diff --staged` e `verify.sh` verdes.
5. **PR:** título no padrão de commit; descrição com: Contexto/Motivação, O que mudou, Como testar, Requisitos/ACs atendidos (da spec), Riscos e rollback, Screenshots (se UI).
6. **Só faça `git commit`/`push` se o usuário pedir ou autorizar.** Nunca `push --force`, `reset --hard` ou reescrita de histórico compartilhado sem confirmação explícita.
</execution_steps>

<anti_patterns>
- NUNCA usar `git add .` às cegas: revise os arquivos adicionados.
- NUNCA misturar refatoração, feature e formatação no mesmo commit.
</anti_patterns>
