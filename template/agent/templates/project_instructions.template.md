<!-- ADA:UNCONFIGURED  (a skill auto-context remove esta linha ao preencher) -->
# 🤖 Instruções e Contexto do Projeto

> **[META INSTRUÇÃO PARA O AGENTE IA]**
> Este arquivo é a fonte de verdade sobre o projeto. Leia e respeite antes de qualquer plano, código ou spec.
> Valores entre colchetes são placeholders: substitua por dados REAIS. Se não souber, escreva `N/A` (nunca invente).

<project_context>
  - **Nome do Projeto:** [nome]
  - **Propósito:** [1-2 frases]
  - **Público Alvo:** [ex.: usuários finais, admins, devs]
</project_context>

<tech_stack>
  - **Linguagem Principal:** [linguagem + versão]
  - **Framework Core:** [framework + versão]
  - **Gerenciador de pacotes:** [npm | pnpm | yarn | pip | poetry | uv | cargo | go mod | ...]
  - **Ferramentas Auxiliares:**
    - Estilização: [ou N/A]
    - Banco de Dados / ORM: [ou N/A]
    - Testes: [framework]
</tech_stack>

<commands>
  <!-- Formato: "- nome: comando". Lido por .agent/scripts/verify.sh. Use N/A se não existir. -->
  - install: [comando]
  - lint: [comando]
  - typecheck: [comando]
  - test: [comando]
  - build: [comando]
  - dev: [comando]
</commands>

<architecture>
  - **Padrão Principal:** [ex.: MVC, Clean Architecture, Feature-Sliced, Modular]
  - **Mapa de Diretórios (Resumo):**
    [4-6 diretórios principais e o propósito real de cada um]
  - **Pontos de entrada:** [ex.: src/main.ts, app/page.tsx]
</architecture>

<coding_guidelines>
  - **Nomenclatura:** [arquivos, classes, variáveis, rotas, banco]
  - **Tratamento de Erros:** [como o projeto lida com falhas]
  - **Tipagem/Comentários:** [padrões existentes]
  - **Geração de Código:** código completo, sem placeholders; siga os padrões já existentes.
</coding_guidelines>

<git_conventions>
  - **Branches:** [ex.: feat/<slug>, fix/<slug>, chore/<slug>]
  - **Commits:** Conventional Commits (feat, fix, refactor, test, docs, chore). Mensagens em [pt-BR | en].
  - **PRs:** [regras, template, revisores]
</git_conventions>

<security>
  - Nunca commitar segredos, tokens ou `.env`.
  - Validar/sanitizar toda entrada externa. Usar consultas parametrizadas.
  - Áreas sensíveis do projeto: [ex.: auth, pagamentos, dados pessoais]
</security>

<definition_of_done>
  - Lint, typecheck e testes passando (`.agent/scripts/verify.sh`).
  - Todos os `<acceptance_criteria>` da spec atendidos e passos marcados `[x]`.
  - Sem arquivos alterados fora de `<files_in_scope>`.
  - Documentação/README atualizados se o comportamento público mudou.
  - `.agent/memory/learnings.md` atualizado quando houver aprendizado relevante.
</definition_of_done>

<agent_constraints>
  - **PROIBIDO:** alterar `.env`, `.gitignore` ou configs de ambiente sem pedido explícito.
  - **PROIBIDO:** modificar código de dependências instaladas (`node_modules`, `venv`, `vendor`, etc.).
  - **PROIBIDO:** commitar segredos ou executar comandos destrutivos (drop, `rm -rf`, force push) sem confirmação.
  - **OBRIGATÓRIO:** passar por `dependency-eval` antes de adicionar dependências.
  - **OBRIGATÓRIO:** seguir a spec aprovada; escopo fechado em `<files_in_scope>`.
  - [Restrições específicas do projeto]
</agent_constraints>

<available_skills>
  - Skills em `.agent/skills/`. Consulte o índice no `AGENTS.md`.
</available_skills>
