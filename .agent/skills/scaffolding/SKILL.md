---
name: scaffolding
description: Guia a criação da estrutura base (esqueletos, contratos, tipagens e wiring) de novas features ou módulos antes da implementação da lógica densa.
---

# 🏗️ Geração de Estrutura (Scaffolding)

Esta skill é ativada ao iniciar uma nova especificação (spec) que envolva a criação de uma funcionalidade completa (nova tela, novo módulo, CRUD), ou quando instruído a criar a "estrutura base" de algo.

<execution_steps>
1. **Análise Arquitetural:** Consulte `.agent/project_instructions.md` para respeitar os padrões de pasta e convenções do projeto.
2. **Mapeamento da Árvore de Arquivos:** Defina todos os arquivos e pastas que serão criados.
3. **Geração de Esqueletos:** Crie os arquivos com assinaturas, contratos de interfaces/tipos e stubs mínimos válidos.
4. **Integração (Wiring):** Registre as exportações, rotas, schemas ou injeções de dependência necessárias.
</execution_steps>

<anti_patterns>
- NUNCA crie lógica de negócio densa nesta fase; concentre-se estritamente na estrutura e contratos.
</anti_patterns>
