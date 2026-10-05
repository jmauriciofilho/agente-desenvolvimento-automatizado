---
name: refatoracao
description: Refatora e otimiza código sem alterar comportamento externo, em passos pequenos e verificáveis. Use para limpeza, simplificação, redução de duplicação ou melhoria de legibilidade.
---

# 🧹 Refatoração

<execution_steps>
1. **Rede de segurança:** rode `verify.sh`. Se a área não tem testes, escreva testes de caracterização (registram o comportamento atual) ANTES de mexer.
2. **Contrato:** liste assinaturas públicas, tipos e efeitos colaterais que devem ser preservados.
3. **Auditoria:** duplicação (DRY), funções longas, aninhamento profundo, acoplamento, nomes ruins, código morto.
4. **Passos pequenos:** uma transformação por vez (extrair função, renomear, mover, simplificar condicional). Rode testes após cada passo.
5. **Modernização idiomática** apenas onde melhora a legibilidade, seguindo o estilo do projeto.
6. **Validação final:** `verify.sh` verde, sem mudança comportamental, diff revisado com `revisao-codigo`.
</execution_steps>

<anti_patterns>
- NUNCA adicionar features ou alterar contratos públicos durante refatoração.
- NUNCA alterar testes existentes para acomodar a refatoração (exceto renomeações mecânicas justificadas).
- NUNCA refatorar arquivos fora de `<files_in_scope>`.
</anti_patterns>
