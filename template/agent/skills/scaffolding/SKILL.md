---
name: scaffolding
description: Cria a estrutura base (esqueletos, contratos, tipagens e wiring) de novas features ou módulos antes da lógica densa. Use ao iniciar uma spec que crie tela, módulo, endpoint ou CRUD.
---

# 🏗️ Scaffolding

<execution_steps>
1. Leia `.agent/project_instructions.md` (arquitetura e nomenclatura) e a spec (`<files_in_scope>`).
2. Localize uma feature existente similar e use-a como modelo de estrutura e estilo.
3. Liste a árvore de arquivos a criar e confirme que coincide com `<files_in_scope>`.
4. Crie esqueletos: assinaturas, interfaces/tipos, DTOs/schemas, stubs mínimos válidos que compilam (sem lógica densa).
5. Faça o wiring: exports, rotas, registro de módulos, injeção de dependência, migrations vazias, se aplicável.
6. Crie arquivos de teste vazios/esqueleto alinhados ao `<test_plan>`.
7. Rode `verify.sh` (o esqueleto deve compilar e passar lint).
</execution_steps>

<anti_patterns>
- NUNCA implementar lógica de negócio densa nesta fase.
- NUNCA criar arquivos fora de `<files_in_scope>` sem autorização.
</anti_patterns>
