---
name: context-sync
description: Detecta divergências entre o código real e o project_instructions.md e propõe atualização. Use após mudanças estruturais (nova stack, pastas, scripts), quando o contexto parecer desatualizado ou via /context-sync.
---

# 🔄 Context Sync

<execution_steps>
1. Leia `.agent/project_instructions.md`.
2. Verifique contra a realidade: versões e dependências nos manifests, scripts/comandos (`<commands>` funcionam? rode `verify.sh`), estrutura de diretórios, ferramentas de teste/lint, convenções observáveis em arquivos recentes (`git log`, `git diff` desde a última atualização).
3. Liste as divergências: `campo | valor documentado | valor real | evidência`.
4. Proponha as edições em formato de diff. Aplique somente após confirmação do usuário, preservando conteúdo manual (regras específicas em `<agent_constraints>`).
5. Atualize `.agent/memory/learnings.md` se a divergência revelou uma armadilha recorrente.
</execution_steps>

<anti_patterns>
- NUNCA sobrescrever o arquivo inteiro: aplique edições cirúrgicas.
- NUNCA remover restrições do usuário em `<agent_constraints>`.
</anti_patterns>
