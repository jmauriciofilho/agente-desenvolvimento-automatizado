<skill_name> Geração de Estrutura (Scaffolding) </skill_name>

<trigger_conditions>
  Acione esta skill ao iniciar uma nova especificação (spec) que envolva a criação de uma funcionalidade completa (nova tela, novo módulo, CRUD), ou quando instruído a criar a "estrutura base" de algo.
</trigger_conditions>

<execution_steps>
  - 1. **Análise Arquitetural:** Consulte a seção `<architecture>` no arquivo `project_instructions.md` para determinar os diretórios corretos onde os novos arquivos devem residir.
  - 2. **Mapeamento da Árvore:** Crie um plano mental ou escreva no `spec.md` a árvore de arquivos que será gerada (ex: componentes, serviços, tipos e rotas).
  - 3. **Geração de Esqueletos:** Crie os arquivos necessários apenas com as exportações básicas, interfaces/tipagens essenciais e componentes vazios. Não implemente regras de negócio complexas nesta etapa.
  - 4. **Integração (Wiring):** Conecte os novos arquivos à aplicação. Exporte-os em arquivos de barril (`index.ts` / `__init__.py`) se for o padrão do projeto, e registre as novas rotas ou provedores nos arquivos de configuração principais.
</execution_steps>

<anti_patterns>
  - NUNCA crie lógica de negócio densa ou chamadas de API reais durante a fase de scaffolding. Mantenha os arquivos o mais limpos possível.
  - NÃO invente novas pastas raiz que não estejam mapeadas na arquitetura padrão do projeto.
  - EVITE criar arquivos "órfãos" que não são importados ou utilizados por nenhuma outra parte da aplicação.
</anti_patterns>