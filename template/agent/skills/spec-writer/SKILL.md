---
name: spec-writer
description: Conduz o discovery e redige a especificação (spec) de uma feature ou de um projeto novo, salvando em .agent/specs/active/ somente após aprovação. Use quando não existir spec para uma tarefa do tamanho "feature" ou ao iniciar um projeto do zero.
---

# 📝 Redação de Especificações

## Modo A — Feature em projeto existente
<execution_steps>
1. Leia `.agent/project_instructions.md`, `.agent/memory/learnings.md` e explore o código relacionado (arquivos, testes, contratos existentes) ANTES de perguntar.
2. Faça o discovery: no máximo 5–7 perguntas, agrupadas em uma única mensagem, cada uma com uma sugestão de resposta padrão. Cubra: objetivo/valor, comportamento esperado, casos de borda e erros, fora de escopo, restrições (performance, segurança, compatibilidade), como validar.
3. Leia `.agent/templates/spec.template.md` e gere o rascunho em `.agent/specs/active/<slug>_spec.md` com `Status: Draft`.
4. Garanta: requisitos numerados (R1..), critérios testáveis vinculados (AC1 (R1)..), `<files_in_scope>` reais (verificados no repositório), `<out_of_scope>`, `<risks>` e `<test_plan>` com rastreabilidade R → AC → teste.
5. Aplique a skill `spec-review` no rascunho e corrija os achados.
6. Apresente o resumo da spec e peça aprovação EXPLÍCITA. Não codifique antes disso.
7. Após aprovação: `Status: Planned`, preencha `<execution_plan>` se vazio.
</execution_steps>

## Modo B — Projeto novo (Arquiteto)
<execution_steps>
1. Discovery: problema, usuários, escopo do MVP, restrições (prazo, custo, equipe, hospedagem), preferências de stack.
2. Proponha 2 arquiteturas/stacks com prós, contras e recomendação justificada.
3. Após escolha, gere `.agent/project_instructions.md` a partir de `.agent/templates/project_instructions.template.md` (remova o marcador `ADA:UNCONFIGURED`) — apenas após aprovação.
4. Quebre o MVP em specs por marco (uma spec por entrega), listando a ordem sugerida.
5. Registre as decisões de arquitetura com a skill `adr`.
</execution_steps>

<anti_patterns>
- NUNCA salvar spec como aprovada sem "ok" explícito do usuário.
- NUNCA inventar arquivos em `<files_in_scope>`: confirme no repositório.
- NUNCA escrever critérios vagos ("deve ser rápido", "funcionar bem").
</anti_patterns>
