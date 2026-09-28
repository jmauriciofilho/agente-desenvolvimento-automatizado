---
name: triagem
description: Classifica a tarefa (trivial, pequena, feature ou bug) e escolhe o fluxo SDD proporcional. Use no início de qualquer tarefa nova, antes de planejar ou codar.
---

# 🚦 Triagem de Tarefas

<execution_steps>
1. Entenda o pedido em 1 frase. Se estiver ambíguo demais para classificar, faça no máximo 2 perguntas.
2. Classifique:
   - **trivial**: ≤ 1 arquivo, ≤ ~20 linhas, sem mudar contrato público, comportamento relevante ou dependências (typo, texto, ajuste de estilo, renomear local).
   - **bug**: comportamento atual diverge do esperado → skill `bugfix`.
   - **pequena**: 2–5 arquivos, comportamento localizado, sem novo contrato público nem migração.
   - **feature**: novo módulo/tela/endpoint, contrato público novo ou alterado, migração de dados, segurança/auth, nova dependência, ou > 5 arquivos.
3. Declare em uma linha: `Triagem: <classe> — <motivo>`.
4. Siga o fluxo:
   - trivial → executar, rodar `.agent/scripts/verify.sh`, entregar.
   - pequena → preencher `.agent/templates/mini_spec.template.md` (salvar em `.agent/specs/active/`), pedir "ok" rápido, executar.
   - feature → skill `spec-writer` → `spec-review` → aprovação explícita → ciclo SDD completo.
   - bug → skill `bugfix`.
5. Durante a execução, se o escopo crescer, PARE, reclassifique e informe.
</execution_steps>

<anti_patterns>
- NUNCA exigir spec completa para tarefas triviais (burocracia).
- NUNCA tratar mudança em auth, pagamentos, dados ou contrato público como trivial.
- Em dúvida entre duas classes, escolha a maior.
</anti_patterns>
