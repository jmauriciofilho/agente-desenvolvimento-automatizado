---
description: Mostra as specs ativas e retoma a execução interrompida
---

Rode `.agent/scripts/status.sh`. Se houver spec `In Progress`, leia-a inteira, o último registro de `<progress_log>` e o `git diff`; confira se o código bate com os passos `[x]` e continue do próximo passo pendente. Se houver mais de uma, pergunte qual retomar. $ARGUMENTS
