---
name: memoria
description: Registra aprendizados da tarefa em .agent/memory/learnings.md e fecha o ciclo (spec concluída). Use ao final de toda tarefa não trivial ou quando o usuário corrigir o agente.
---

# 🧠 Memória e Fechamento

<execution_steps>
1. Ao terminar (ou quando o usuário corrigir você), pergunte-se: o que quebrou, o que surpreendeu, que convenção/preferência foi descoberta, que comando é essencial, que armadilha evitar?
2. Escreva 0–3 entradas curtas em `.agent/memory/learnings.md` no formato: `- [AAAA-MM-DD] [categoria] Aprendizado. → Regra para o futuro.` Só registre o que for útil em sessões futuras.
3. Evite duplicatas: leia o arquivo antes; atualize a entrada existente. Se passar de ~150 linhas, consolide entradas antigas.
4. Nunca registre segredos, dados pessoais ou detalhes efêmeros.
5. Fechamento da spec: marque todos os passos `[x]`, `Status: Completed`, mova para `.agent/specs/done/`.
6. Se o aprendizado indicar que o contexto do projeto mudou, sugira `context-sync`.
</execution_steps>

<anti_patterns>
- NUNCA registrar opinião sem evidência.
- NUNCA transformar `learnings.md` em diário de tudo o que foi feito.
</anti_patterns>
