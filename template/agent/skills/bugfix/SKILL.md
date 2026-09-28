---
name: bugfix
description: Corrige bugs com método - reproduzir, escrever teste que falha, achar a causa raiz, corrigir com mudança mínima e provar a regressão. Use para relatos de bug, erros, regressões ou testes quebrando.
---

# 🐛 Correção de Bugs

<execution_steps>
1. **Entender:** comportamento esperado vs. observado, passos, ambiente, logs/stack trace. Pergunte só o que faltar.
2. **Reproduzir:** rode o cenário. Se não reproduzir, colete mais dados antes de mudar código.
3. **Teste de regressão primeiro:** escreva um teste que FALHA pelo motivo certo (skill `testes-automatizados`).
4. **Causa raiz:** rastreie até a origem (não trate só o sintoma). Formule hipóteses, valide com evidência (logs, debugger, bisect via `git bisect` se útil).
5. **Correção mínima:** menor mudança que resolve a causa, sem refatorações oportunistas. Verifique se o mesmo padrão existe em outros locais e liste-os (corrija só se autorizado).
6. **Provar:** o teste novo passa; `verify.sh` completo verde.
7. **Registrar:** aprendizado na skill `memoria` (causa raiz + como evitar).
8. Reporte: causa raiz, correção, teste adicionado, riscos residuais.
</execution_steps>

<anti_patterns>
- NUNCA "corrigir" sem reproduzir.
- NUNCA silenciar erro (catch vazio) ou desativar teste para passar.
- NUNCA misturar refatoração ou feature no mesmo fix.
</anti_patterns>
