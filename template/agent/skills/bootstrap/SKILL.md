---
name: bootstrap
description: Executa o marco 0 de um projeto novo (git, esqueleto do framework, .gitignore, lint, typecheck, testes e build funcionando, <commands> reais). Use logo após o Modo Arquiteto (spec-writer Modo B), antes da primeira feature.
---

# 🌱 Bootstrap (Marco 0 de projeto novo)

Pré-requisito: Modo Arquiteto concluído (stack aprovada, ADR de stack registrado, `project_instructions.md` sem `ADA:UNCONFIGURED` e com `<commands>` em `N/A`).
Nenhuma spec de feature começa antes de o marco 0 estar `Completed`.

<execution_steps>
1. **Spec do marco 0:** crie `.agent/specs/active/00-bootstrap_spec.md` a partir de `.agent/templates/spec.template.md`. Conteúdo mínimo:
   - `<requirements>`: repositório git; esqueleto do framework; `.gitignore` (e `.env.example` se a stack usar variáveis de ambiente); lint, typecheck, testes e build configurados; um teste de fumaça; `<commands>` reais.
   - `<files_in_scope>`: o que o gerador e você vão criar, por diretório ou glob (ex.: `src/`, `public/`, `tests/`, `*.json`, `*.config.*`), mais `.gitignore`, `.env.example` e `README.md`. Listar `.gitignore` e `.env.example` aqui é o pedido explícito que as regras exigem para alterá-los.
   - `<out_of_scope>`: toda regra de negócio e tela do MVP.
   - `<context>`: dependências iniciais citadas no ADR de stack (pré-aprovadas, passo 4).
   - `<test_plan>`: o teste de fumaça (ex.: `tests/smoke.test.ts`: o módulo principal carrega) e `verify.sh` verde.
   Aplique `spec-review` e peça aprovação explícita, como em qualquer spec.
2. **Git:** se a pasta não for repositório (`git rev-parse --is-inside-work-tree` falha), rode `git init`. Sem git, `check-scope.sh` e os hooks não funcionam.
   - Antes de `In Progress`, os arquivos do ADA (`AGENTS.md`, `CLAUDE.md`, `.agent/`, `.claude/`, `.agents/`, `.opencode/`) precisam estar commitados: o `check-scope.sh` compara com `HEAD` e acusaria todos como fora do escopo. Peça autorização para o commit `chore: instala ADA` (skill `git-workflow`); sem ela, não avance.
3. **Esqueleto:** defina `Status: In Progress`. Rode o gerador oficial da stack na raiz (ex.: `npm create vite@latest . -- --template react-ts`, `uv init`, `cargo init`), de forma não interativa quando possível.
   - Se o gerador recusar pasta não vazia, gere numa pasta temporária e mova o conteúdo para a raiz sem sobrescrever `AGENTS.md`, `CLAUDE.md`, `.agent/`, `.claude/`, `.agents/` e `.opencode/`.
   - Logo depois rode `.agent/scripts/check-scope.sh`. Arquivos gerados fora de `<files_in_scope>` vêm do gerador aprovado: adicione-os ao escopo e registre em `<change_log>` como "arquivos do gerador", sem nova aprovação. Arquivos que você mesmo criaria fora do escopo seguem a regra normal (pedir autorização).
4. **Dependências:** as citadas no ADR de stack aprovado contam como aprovadas; instale-as com o gerenciador do projeto, sem nova `dependency-eval`. Qualquer outra passa pela skill.
5. **Ferramentas:** configure lint, formatação (se o ADR prever), typecheck e testes com a configuração mínima recomendada pela stack. Escreva o teste de fumaça: primeiro falhando, depois passando.
6. **Contexto real:** preencha `<commands>` em `.agent/project_instructions.md` com os comandos que funcionam (`install`, `lint`, `typecheck`, `test`, `build`, `dev`); o que não existir fica `N/A`. Troque a estrutura "(planejado)" de `<architecture>` pela árvore real (skill `context-sync`).
7. **Validação:** `.agent/scripts/verify.sh` sem argumentos deve sair com `0` (não `3`: ao menos `test` precisa rodar). Se houver `dev`, suba a aplicação uma vez para confirmar.
8. **Fechamento:** `revisao-codigo`, `memoria`, `Status: Completed`, spec para `done/`. Sugira o commit `chore: bootstrap do projeto` e indique a próxima spec do MVP.
</execution_steps>

<anti_patterns>
- NUNCA implementar regra de negócio do MVP no bootstrap.
- NUNCA deixar em `<commands>` um comando que não roda: ou funciona, ou fica `N/A`.
- NUNCA criar `.env` com valores reais; use `.env.example` com placeholders.
- NUNCA pular o `git init`: sem git não há controle de escopo nem verificação obrigatória.
</anti_patterns>
