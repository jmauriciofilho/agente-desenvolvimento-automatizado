---
name: testes-automatizados
description: Orienta a criação e expansão de testes automatizados (unitários, integração) seguindo o padrão AAA e isolamento rigoroso de dependências.
---

# 🧪 Criação de Testes Automatizados

Esta skill é ativada quando a tarefa incluir requisitos de testes (unitários, integração), para aumentar a cobertura de código de um arquivo existente, ou quando o usuário solicitar testes.

<execution_steps>
1. **Identificação da Stack:** Identifique o framework de testes configurado no projeto (ex: Jest, Vitest, Pytest).
2. **Isolamento de Dependências:** Crie mocks/stubs rigorosos para chamadas de rede, I/O e banco de dados em testes unitários.
3. **Padrão AAA:** Estruture os casos de teste em Arrange (Preparação), Act (Execução) e Assert (Verificação).
4. **Cobertura Abrangente:** Cubra o caminho feliz (happy path), casos limites (edge cases) e tratamento de erros esperados.
5. **Execução:** Valide os testes via terminal para garantir que estão passando.
</execution_steps>

<anti_patterns>
- NUNCA realize chamadas externas reais ou mutações em banco de dados de produção em testes unitários.
- NUNCA crie testes dependentes de ordem de execução.
</anti_patterns>
