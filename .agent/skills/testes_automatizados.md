<skill_name> Criação de Testes Automatizados </skill_name>

<trigger_conditions>
  Acione esta skill quando a tarefa (spec) incluir requisitos de testes (unitários, integração), para aumentar a cobertura de código de um arquivo existente, ou quando o usuário solicitar explicitamente a criação de testes.
</trigger_conditions>

<execution_steps>
  - 1. **Configuração da Stack:** Consulte o `project_instructions.md` para identificar o framework de testes e a biblioteca de asserções corretas (ex: Jest, Vitest, Testing Library).
  - 2. **Isolamento (Mocks):** Identifique todas as dependências externas da unidade (chamadas de API, banco de dados, navegação) e crie *mocks* estritos no topo do arquivo para garantir o isolamento do teste.
  - 3. **Estruturação AAA:** Organize cada caso de teste seguindo o padrão Arrange (Preparar o estado/mocks), Act (Executar a função/renderizar o componente) e Assert (Verificar o resultado).
  - 4. **Cobertura Abrangente:** Escreva sempre o cenário principal (caminho feliz) primeiro. Em seguida, adicione testes para falhas esperadas, exceções e entradas inválidas (edge cases).
  - 5. **Nomenclatura Clara:** Descreva o comportamento exato no nome do teste, facilitando a leitura de relatórios de erro (ex: `deve renderizar mensagem de erro quando as credenciais forem inválidas`).
</execution_steps>

<anti_patterns>
  - NUNCA execute testes unitários que façam requisições HTTP reais ou alterem bancos de dados.
  - NÃO teste detalhes de implementação internos (como o nome de uma variável local), teste o contrato (inputs e outputs/renderização).
  - EVITE criar testes "vazios" ou com asserções tautológicas que sempre passam (ex: `expect(true).toBe(true)`).
</anti_patterns>
