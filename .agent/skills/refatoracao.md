<skill_name> Refatoração de Código e Otimização </skill_name>

<trigger_conditions>
  Acione esta skill sempre que a tarefa (spec) exigir limpeza de código, redução de complexidade, ou quando o usuário solicitar explicitamente uma "refatoração" ou "melhoria" em um arquivo existente.
</trigger_conditions>

<execution_steps>
  - 1. **Mapeamento de Contrato:** Analise o arquivo atual e identifique rigidamente as entradas, saídas e efeitos colaterais. A assinatura pública da função, classe ou componente DEVE ser preservada.
  - 2. **Auditoria de Código:** Busque por violações do princípio DRY (Don't Repeat Yourself), funções com mais de 30 linhas, variáveis genéricas (ex: `data`, `val`) e lógicas condicionais profundamente aninhadas.
  - 3. **Desacoplamento:** Extraia lógicas complexas para funções auxiliares menores e com responsabilidade única. Se aplicável, mova funções puras para fora do componente ou para o diretório de utilitários indicado nas instruções do projeto.
  - 4. **Modernização Semântica:** Atualize sintaxes legadas para os padrões modernos da linguagem (definida no `project_instructions.md`), garantindo o uso correto de tipagem estrita caso aplicável.
  - 5. **Auto-Revisão:** Verifique passo a passo se o comportamento original do sistema (a regra de negócio) permanece 100% inalterado após as suas mudanças.
</execution_steps>

<anti_patterns>
  - NUNCA adicione ou remova funcionalidades (features) durante um processo de refatoração. O escopo deve ser estritamente técnico.
  - NÃO altere a interface pública (tipagens exportadas, props esperadas) a menos que explicitamente solicitado.
  - EVITE abstrações complexas e prematuras; o objetivo primário é legibilidade e manutenibilidade para desenvolvedores humanos.
</anti_patterns>