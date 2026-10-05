---
name: revisao-codigo
description: Autorrevisão rigorosa do diff contra a spec, corretude, segurança, complexidade e testes, antes de entregar. Use ao finalizar uma tarefa ou ao revisar um PR/diff.
---

# 👀 Code Review

<execution_steps>
1. Obtenha o diff (`git diff` / `git diff --staged` / branch vs. base) e a spec (se houver).
2. **Escopo:** todo arquivo alterado está em `<files_in_scope>`? Há mudanças não relacionadas (ruído, formatação em massa)?
3. **Spec:** cada requisito/AC está implementado e coberto por teste? Algo além do pedido foi adicionado?
4. **Corretude:** lógica, bordas, nulos, concorrência, tratamento de erros, recursos não liberados, off-by-one.
5. **Segurança:** entrada não validada, injeção, segredos, autorização, logs com dados sensíveis (aprofunde com `security-audit` se relevante).
6. **Manutenibilidade:** nomes, tamanho de funções, duplicação, consistência com as convenções do projeto, comentários úteis, código morto.
7. **Testes:** qualidade, determinismo, cobertura das bordas; testes realmente falhariam se o código quebrasse?
8. **Performance/compat.:** N+1, loops caros, breaking changes, migrations reversíveis.
9. Saída: lista priorizada `[BLOQUEANTE] / [IMPORTANTE] / [SUGESTÃO]` com `arquivo:linha` e correção proposta. Corrija os bloqueantes antes de entregar.
</execution_steps>

<anti_patterns>
- NUNCA aprovar o próprio código sem rodar `verify.sh`.
- NUNCA apontar preferências pessoais de estilo como bloqueantes.
</anti_patterns>
