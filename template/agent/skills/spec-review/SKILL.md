---
name: spec-review
description: Revisa uma spec antes da aprovação, checando contradições, critérios testáveis, escopo e rastreabilidade. Use ao concluir o rascunho de uma spec ou quando o usuário pedir revisão de spec.
---

# 🔎 Revisão de Especificação

<execution_steps>
Verifique cada item e liste os achados como `[BLOQUEANTE]`, `[ATENÇÃO]` ou `[SUGESTÃO]`:
1. **Completude:** todos os blocos do template estão presentes e sem placeholders `[...]`.
2. **Testabilidade:** cada AC é verificável objetivamente (entrada → saída/efeito mensurável).
3. **Rastreabilidade:** todo R tem ≥ 1 AC; todo AC tem ≥ 1 teste no `<test_plan>`; nenhum AC órfão.
4. **Escopo:** `<files_in_scope>` existem (ou serão criados de forma coerente com a arquitetura); `<out_of_scope>` está explícito.
5. **Consistência:** sem requisitos contraditórios; alinhada a `<architecture>` e `<agent_constraints>`.
6. **Riscos:** segurança, migração de dados, compatibilidade reversa e performance foram considerados.
7. **Plano:** passos pequenos, ordenados, cada um verificável; inclui verify, code-review e memória.
8. Resultado: `APROVADA PARA REVISÃO DO USUÁRIO` (sem bloqueantes) ou `REPROVADA` + lista de correções.
</execution_steps>

<anti_patterns>
- NUNCA aprovar spec com AC subjetivo ou sem teste correspondente.
</anti_patterns>
