# 📋 Especificação: [Nome da Feature]

> **[META INSTRUÇÃO PARA O AGENTE IA]**
> Escopo estrito da execução. Leia `.agent/project_instructions.md` antes de começar.
> Marque `[x]` em cada passo do `<execution_plan>` ao concluir. Não toque arquivos fora de `<files_in_scope>`.

<specification_meta>
- **Status:** [Draft | Planned | In Progress | Completed]
- **Data de Criação:** [AAAA-MM-DD]
- **Slug:** [nome-da-feature]
- **Tamanho (triagem):** feature
</specification_meta>

<context>
  - **O que estamos construindo:** [descrição objetiva]
  - **Motivação:** [problema e valor gerado]
</context>

<requirements>
  - [ ] R1: [requisito verificável]
  - [ ] R2: [requisito verificável]
  - [ ] R3: [requisito verificável]
</requirements>

<acceptance_criteria>
  <!-- Cada critério deve ser testável e referenciar o requisito: ACn (Rn) -->
  - AC1 (R1): [dado/quando/então, mensurável]
  - AC2 (R2): [dado/quando/então, mensurável]
  - AC-G1: lint e typecheck sem erros.
  - AC-G2: tipagem estrita nas funções e interfaces públicas.
  - AC-G3: nenhuma dependência nova sem aprovação.
</acceptance_criteria>

<files_in_scope>
  - `caminho/arquivo1` — [criar | editar]: [motivo]
  - `caminho/arquivo2` — [criar | editar]: [motivo]
</files_in_scope>

<out_of_scope>
  - [o que explicitamente NÃO será feito nesta spec]
</out_of_scope>

<risks>
  - [Risco] → [Mitigação]
</risks>

<test_plan>
  <!-- Rastreabilidade: R → AC → teste -->
  - R1 → AC1 → `caminho/do/teste`: [cenário feliz]
  - R1 → AC1 → `caminho/do/teste`: [cenário de erro / limite]
</test_plan>

<execution_plan>
- [ ] 1. Mapear arquivos e criar contratos (interfaces/tipos).
- [ ] 2. Implementar a lógica central.
- [ ] 3. Implementar testes conforme `<test_plan>`.
- [ ] 4. Rodar `.agent/scripts/verify.sh` e corrigir.
- [ ] 5. `code-review` do diff contra esta spec.
- [ ] 6. Registrar aprendizados (`memoria`) e mover spec para `done/`.
</execution_plan>

<definition_of_done>
  - Todos os ACs atendidos e verificados; `verify.sh` verde.
  - Diff restrito a `<files_in_scope>`.
  - Documentação atualizada se necessário; `learnings.md` atualizado.
</definition_of_done>
