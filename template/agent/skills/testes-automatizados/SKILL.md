---
name: testes-automatizados
description: Cria e amplia testes automatizados (unitários e de integração) no padrão AAA, com isolamento de dependências e rastreabilidade com os critérios da spec. Use ao criar testes, aumentar cobertura ou cumprir o test_plan.
---

# 🧪 Testes Automatizados

<execution_steps>
1. Identifique framework, convenções de nome/localização e utilitários de teste já usados (em `<tech_stack>` e nos testes existentes). Reutilize helpers/fixtures.
2. Parta do `<test_plan>` da spec: cada AC deve ter ao menos um teste; nomeie os testes de forma que indiquem o AC (ex.: `AC1: retorna 400 para e-mail inválido`).
3. Estruture em AAA (Arrange, Act, Assert). Um comportamento por teste.
4. Cubra: caminho feliz, bordas (vazio, limites, nulos), erros esperados e permissões/segurança quando aplicável.
5. Isole rede, I/O, relógio, aleatoriedade e banco com mocks/stubs/fakes; use bancos em memória ou containers de teste para integração.
6. Teste comportamento observável, não detalhes de implementação.
7. Execute a suíte (`verify.sh test`), confirme que passa e que os testes novos FALHAM quando o código é quebrado de propósito (sanidade).
</execution_steps>

<anti_patterns>
- NUNCA chamar serviços externos reais nem mutar banco de produção.
- NUNCA criar testes dependentes de ordem, de horário ou flaky.
- NUNCA "consertar" um teste falhando alterando a asserção sem entender a causa.
</anti_patterns>
