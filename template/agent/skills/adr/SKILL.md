---
name: adr
description: Registra decisões arquiteturais relevantes (ADR) em .agent/decisions/ com contexto, opções e consequências. Use ao escolher stack, padrão, biblioteca ou abordagem com impacto duradouro.
---

# 🏛️ Architecture Decision Records

<execution_steps>
1. Verifique se a decisão merece ADR: afeta estrutura, dependências, dados, segurança ou é difícil de reverter. Decisões triviais não precisam.
2. Numere sequencialmente olhando `.agent/decisions/` (`ADR-0001-titulo-em-kebab.md`).
3. Preencha `.agent/templates/adr.template.md`: contexto, opções (com prós/contras), decisão, consequências e como reverter.
4. Se substituir uma decisão anterior, atualize o `Status` do ADR antigo para `Substituída por ADR-XXXX`.
5. Referencie o ADR na spec relacionada e, se a decisão mudar convenções, atualize `project_instructions.md` (skill `context-sync`).
</execution_steps>

<anti_patterns>
- NUNCA apagar ADRs antigos; marque-os como substituídos.
- NUNCA registrar ADR sem alternativas consideradas.
</anti_patterns>
