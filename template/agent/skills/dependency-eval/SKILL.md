---
name: dependency-eval
description: Avalia se uma nova dependência é realmente necessária, comparando com a stack atual e alternativas, e pede aprovação. Use antes de adicionar, trocar ou remover qualquer biblioteca.
---

# 📦 Avaliação de Dependências

<execution_steps>
1. **Necessidade:** a stack atual, a biblioteca padrão ou dependências já instaladas resolvem? Se sim, use-as e encerre.
2. **Alternativas:** compare 2–3 opções (incluindo "implementar internamente" se for pequeno) por: manutenção ativa (últimos releases/commits), popularidade, licença compatível, tamanho/impacto no bundle, dependências transitivas, tipagem/qualidade de docs, histórico de vulnerabilidades, compatibilidade com as versões do projeto.
3. Use pesquisa na web/registry quando disponível para dados atuais; não confie em memória para versões e status de manutenção.
4. Apresente uma tabela comparativa curta, recomendação e o custo de remover depois.
5. **Aguarde aprovação explícita** antes de instalar. Depois, instale com o gerenciador do projeto (respeitando o lockfile), fixe a versão conforme a política do projeto e registre a decisão (skill `adr` se relevante).
6. Rode `verify.sh` e, se houver, o auditor de vulnerabilidades.
</execution_steps>

<anti_patterns>
- NUNCA instalar dependência "para testar" sem aprovação.
- NUNCA adicionar biblioteca grande para uma função trivial.
</anti_patterns>
