---
name: refatoracao
description: Orienta a refatoração e otimização de código sem alterar o comportamento funcional externo. Ative ao solicitar limpeza de código, simplificação ou melhoria de legibilidade.
---

# 🧹 Refatoração de Código e Otimização

Esta skill é ativada quando a tarefa (spec) exige limpeza de código, redução de complexidade, ou quando o usuário solicita explicitamente uma "refatoração" ou "melhoria" em arquivos existentes.

<execution_steps>
1. **Mapeamento de Contrato:** Identifique e preserve assinaturas de funções, tipos de entrada e saída.
2. **Auditoria de Código:** Busque duplicações (quebras do DRY), funções longas e acoplamento desnecessário.
3. **Desacoplamento e Extração:** Separe responsabilidades em funções menores e módulos utilitários.
4. **Modernização Semântica:** Adote padrões idiomáticos da linguagem mantendo a legibilidade.
5. **Auto-Revisão e Validação:** Garanta que a funcionalidade e os testes existentes continuam passando sem alterações comportamentais.
</execution_steps>

<anti_patterns>
- NUNCA adicione features novas ou altere contratos públicos durante uma refatoração.
- NUNCA quebre testes unitários existentes sem justificativa arquitetural documentada.
</anti_patterns>
