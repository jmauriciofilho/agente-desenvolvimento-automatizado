# 🤖 Instruções e Contexto do Projeto

> **[META INSTRUÇÃO PARA O AGENTE IA]**
> Este arquivo contém a verdade absoluta sobre o projeto, incluindo stack, padrões arquiteturais e regras estritas. Você DEVE ler e respeitar estas restrições e diretrizes antes de iniciar qualquer plano de execução, alteração de código ou especificação (spec).

<project_context>

- **Nome do Projeto:** [Nome do seu projeto aqui]
- **Propósito:** [Explique em 1 ou 2 frases o que a aplicação faz e o problema que resolve]
- **Público Alvo:** [Ex: Usuários finais, administradores, desenvolvedores]
</project_context>

<tech_stack>

- **Linguagem Principal:** [Ex: TypeScript v5.0, Python 3.11]
- **Framework Core:** [Ex: React 18, Next.js 14 (App Router), Flutter 3.x]
- **Ferramentas Auxiliares:**
  - Estilização: [Ex: TailwindCSS, Styled Components]
  - Banco de Dados / ORM: [Ex: PostgreSQL, Prisma, Supabase]
  - Testes: [Ex: Jest, Vitest, Cypress]
</tech_stack>

<architecture>

- **Padrão Principal:** [Ex: Feature Sliced Design, Clean Architecture, MVC]
- **Mapa de Diretórios (Resumo):**
  - `/src/components`: Componentes UI reutilizáveis.
  - `/src/features`: Lógica isolada por domínio de negócio.
  - `/src/lib`: Configurações de bibliotecas externas de terceiros.
  - `/src/utils`: Funções puras e utilitários globais.
</architecture>

<coding_guidelines>

- **Nomenclatura:**
  - Arquivos e Componentes React: `PascalCase.tsx`
  - Funções e Variáveis: `camelCase`
  - Banco de dados e Rotas de API: `snake_case`
- **Tratamento de Erros:** Sempre envolva chamadas assíncronas em blocos `try/catch` e retorne mensagens de erro padronizadas.
- **Geração de Código:**
  - Escreva código completo, não use placeholders como `// implemente o resto aqui`.
  - Documente funções complexas ou regras de negócio usando JSDoc (ou equivalente).
  - Evite abstrações prematuras; mantenha o código simples e legível.
</coding_guidelines>

<agent_constraints>

- **PROIBIDO:** Remover ou alterar configurações de ambiente (arquivos `.env`, `.gitignore`) a menos que explicitamente solicitado pelo usuário.
- **PROIBIDO:** Modificar código de bibliotecas em `node_modules` (ou equivalente).
- **OBRIGATÓRIO:** Antes de criar novas dependências, verifique se a funcionalidade não pode ser construída com a stack atual.
- **OBRIGATÓRIO:** Siga estritamente o documento `spec.md` (quando fornecido) para escopo de tarefas.
</agent_constraints>

<available_skills>

- O agente possui habilidades modulares na pasta `/.agent/skills/`.
- Consulte o diretório de skills se precisar de contexto adicional sobre tarefas específicas (ex: configuração de testes, refatoração estrutural).
</available_skills>
