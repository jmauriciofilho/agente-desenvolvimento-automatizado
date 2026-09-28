---
name: migracao-upgrade
description: Atualiza versões de linguagem, frameworks e bibliotecas em passos pequenos e verificáveis, com plano de rollback. Use em upgrades de major/minor, migração de framework ou remoção de APIs depreciadas.
---

# ⬆️ Migração e Upgrade

<execution_steps>
1. **Linha de base:** `verify.sh` verde e árvore git limpa (ou commit/branch dedicada). Registre versões atuais.
2. **Pesquisa:** consulte changelog/guia de migração oficial da versão alvo (use busca na web/docs quando disponível). Liste breaking changes, depreciações e requisitos (runtime, peer deps).
3. **Spec:** para upgrades major ou que toquem muitos arquivos, gere spec (`spec-writer`) com plano em etapas e critérios (`verify.sh` verde, sem novos warnings de depreciação críticos).
4. **Etapas:** uma dependência (ou grupo coeso) por vez; upgrade incremental por majors (não pule versões quando o guia recomendar). Após cada etapa: instalar, corrigir breaking changes, `verify.sh`, commit atômico.
5. **Codemods oficiais** têm preferência sobre edições manuais em massa, quando existirem.
6. **Rollback:** descreva como reverter (revert do commit, lockfile anterior, migrations reversíveis).
7. Atualize `project_instructions.md` (`context-sync`) e registre `adr` se a mudança for estrutural.
</execution_steps>

<anti_patterns>
- NUNCA atualizar tudo de uma vez.
- NUNCA ignorar warnings de depreciação ou apagar lockfile para "resolver".
</anti_patterns>
