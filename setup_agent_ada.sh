#!/bin/bash

echo "🚀 Iniciando a instalação da estrutura agentica (Criando Meu Agente Pessoal)..."

# 1. Criando a árvore de diretórios
mkdir -p .agent/skills
mkdir -p .agent/specs
mkdir -p .agent/commands
mkdir -p .opencode/commands

# 2. Criando o Command (auto_context.md)
cat << 'EOF' > .opencode/commands/auto_context.md
---
name: auto-context
description: Executa uma tarefa de descoberta da arquitetura do projeto atual e preenche o templeta de instruções project_intructions.md
---

Atue como um Engenheiro de Software Sênior. Analise todo o código-fonte, os arquivos de configuração (como package.json, requirements.txt, tsconfig, etc.) e a estrutura de diretórios deste projeto atual.

Sua tarefa é fazer o "discovery" (descoberta) da arquitetura atual e preencher o template de instruções do agente. 

Busque ativamente identificar:
1. O propósito principal e o domínio do projeto.
2. A stack tecnológica completa e as versões das ferramentas.
3. O padrão arquitetural adotado e o mapa de pastas principal.
4. As convenções de nomenclatura e de tratamento de erros utilizadas no código.

Após concluir a análise, preencha o template abaixo de forma precisa com as informações reais que você encontrou. 

**INSTRUÇÃO DE SALVAMENTO (MUITO IMPORTANTE):**
1. Verifique se existe uma pasta chamada `.agent` na raiz do projeto. Se não existir, crie-a.
2. Salve o template preenchido OBRIGATORIAMENTE dentro desta pasta, com o nome exato de `project_instructions.md` (caminho: `/.agent/project_instructions.md`).
3. Não use texto genérico, preencha os colchetes com os dados extraídos do nosso código.

# 🤖 Instruções e Contexto do Projeto

> **[META INSTRUÇÃO PARA O AGENTE IA]**
> Este arquivo contém a verdade absoluta sobre o projeto, incluindo stack, padrões arquiteturais e regras estritas. Você DEVE ler e respeitar estas restrições e diretrizes antes de iniciar qualquer plano de execução, alteração de código ou especificação (spec).

<project_context>
  - **Nome do Projeto:** [Preencha com o nome real descoberto do repositório/configuração]
  - **Propósito:** [Resuma em 1-2 frases o objetivo da aplicação com base na sua análise do código]
  - **Público Alvo:** [Infira o público-alvo com base no contexto, ex: Admin, Usuários Finais]
</project_context>

<tech_stack>
  - **Linguagem Principal:** [Preencha com a linguagem predominante e sua versão (ex: TypeScript, Python)]
  - **Framework Core:** [Preencha com o framework core identificado (ex: React, Next.js, Django)]
  - **Ferramentas Auxiliares:** 
    - Estilização: [Identifique a biblioteca de CSS ou UI utilizada]
    - Banco de Dados / ORM: [Identifique o ORM ou banco mapeado]
    - Testes: [Identifique o framework de testes configurado]
</tech_stack>

<architecture>
  - **Padrão Principal:** [Identifique o padrão de design adotado no código (ex: MVC, Clean Architecture, Feature-Sliced)]
  - **Mapa de Diretórios (Resumo):**
    [Mapeie os 4 a 5 diretórios principais do projeto e explique o propósito real de cada um com base no que você encontrou]
</architecture>

<coding_guidelines>
  - **Nomenclatura:** [Descreva o padrão exato encontrado para arquivos, classes, variáveis (ex: PascalCase, camelCase)]
  - **Tratamento de Erros:** [Descreva como o projeto atual lida com falhas/exceções]
  - **Geração de Código:** 
    - Escreva código completo, não use placeholders como `// implemente o resto aqui`.
    - Siga os padrões de tipagem e comentários já existentes no repositório.
</coding_guidelines>

<agent_constraints>
  - **PROIBIDO:** Remover ou alterar configurações de ambiente (`.env`, `.gitignore`) a menos que explicitamente solicitado.
  - **PROIBIDO:** Modificar código de bibliotecas externas.
  - **OBRIGATÓRIO:** Antes de sugerir novas dependências, verifique se não é possível usar a stack atual.
  - **OBRIGATÓRIO:** Siga estritamente o documento `spec.md` (quando fornecido).
</agent_constraints>

<available_skills>
  - O agente possui habilidades modulares na pasta `/.agent/skills/`.
  - Consulte o diretório de skills se precisar de contexto adicional sobre tarefas.
</available_skills>
EOF

cat << 'EOF' > .agent/commands/auto_context.md
---
name: auto_context
description: Realiza discovery do projeto atual e preenche o /.agent/project_instructions.md
aliases:
  - auto-context
  - /auto-context
---

Atue como um Engenheiro de Software Sênior. Analise todo o código-fonte, os arquivos de configuração (como package.json, requirements.txt, tsconfig, etc.) e a estrutura de diretórios deste projeto atual.

Sua tarefa é fazer o "discovery" (descoberta) da arquitetura atual e preencher o template de instruções do agente. 

Busque ativamente identificar:
1. O propósito principal e o domínio do projeto.
2. A stack tecnológica completa e as versões das ferramentas.
3. O padrão arquitetural adotado e o mapa de pastas principal.
4. As convenções de nomenclatura e de tratamento de erros utilizadas no código.

Após concluir a análise, preencha o template abaixo de forma precisa com as informações reais que você encontrou. 

**INSTRUÇÃO DE SALVAMENTO (MUITO IMPORTANTE):**
1. Verifique se existe uma pasta chamada `.agent` na raiz do projeto. Se não existir, crie-a.
2. Salve o template preenchido OBRIGATORIAMENTE dentro desta pasta, com o nome exato de `project_instructions.md` (caminho: `/.agent/project_instructions.md`).
3. Não use texto genérico, preencha os colchetes com os dados extraídos do nosso código.

# 🤖 Instruções e Contexto do Projeto

> **[META INSTRUÇÃO PARA O AGENTE IA]**
> Este arquivo contém a verdade absoluta sobre o projeto, incluindo stack, padrões arquiteturais e regras estritas. Você DEVE ler e respeitar estas restrições e diretrizes antes de iniciar qualquer plano de execução, alteração de código ou especificação (spec).

<project_context>
  - **Nome do Projeto:** [Preencha com o nome real descoberto do repositório/configuração]
  - **Propósito:** [Resuma em 1-2 frases o objetivo da aplicação com base na sua análise do código]
  - **Público Alvo:** [Infira o público-alvo com base no contexto, ex: Admin, Usuários Finais]
</project_context>

<tech_stack>
  - **Linguagem Principal:** [Preencha com a linguagem predominante e sua versão (ex: TypeScript, Python)]
  - **Framework Core:** [Preencha com o framework core identificado (ex: React, Next.js, Django)]
  - **Ferramentas Auxiliares:** 
    - Estilização: [Identifique a biblioteca de CSS ou UI utilizada]
    - Banco de Dados / ORM: [Identifique o ORM ou banco mapeado]
    - Testes: [Identifique o framework de testes configurado]
</tech_stack>

<architecture>
  - **Padrão Principal:** [Identifique o padrão de design adotado no código (ex: MVC, Clean Architecture, Feature-Sliced)]
  - **Mapa de Diretórios (Resumo):**
    [Mapeie os 4 a 5 diretórios principais do projeto e explique o propósito real de cada um com base no que você encontrou]
</architecture>

<coding_guidelines>
  - **Nomenclatura:** [Descreva o padrão exato encontrado para arquivos, classes, variáveis (ex: PascalCase, camelCase)]
  - **Tratamento de Erros:** [Descreva como o projeto atual lida com falhas/exceções]
  - **Geração de Código:** 
    - Escreva código completo, não use placeholders como `// implemente o resto aqui`.
    - Siga os padrões de tipagem e comentários já existentes no repositório.
</coding_guidelines>

<agent_constraints>
  - **PROIBIDO:** Remover ou alterar configurações de ambiente (`.env`, `.gitignore`) a menos que explicitamente solicitado.
  - **PROIBIDO:** Modificar código de bibliotecas externas.
  - **OBRIGATÓRIO:** Antes de sugerir novas dependências, verifique se não é possível usar a stack atual.
  - **OBRIGATÓRIO:** Siga estritamente o documento `spec.md` (quando fornecido).
</agent_constraints>

<available_skills>
  - O agente possui habilidades modulares na pasta `/.agent/skills/`.
  - Consulte o diretório de skills se precisar de contexto adicional sobre tarefas.
</available_skills>
EOF
echo "✅ auto_context.md criado!"

# 3. Criando as Skills
# 3.1 - refatoracao.md
cat << 'EOF' > .agent/skills/refatoracao.md
<skill_name> Refatoração de Código e Otimização </skill_name>
<trigger_conditions> Acione para limpeza de código ou redução de complexidade. </trigger_conditions>
<execution_steps>
  - 1. Mapeamento de Contrato: Preserve inputs/outputs.
  - 2. Auditoria: Busque quebras do DRY e funções longas.
  - 3. Desacoplamento: Extraia lógicas complexas.
  - 4. Modernização Semântica.
  - 5. Auto-Revisão rigorosa do comportamento.
</execution_steps>
<anti_patterns> NUNCA adicione features novas durante uma refatoração. </anti_patterns>
EOF
echo "✅ skill: refatoracao.md criada!"

# 3.2 - scaffolding.md
cat << 'EOF' > .agent/skills/scaffolding.md
<skill_name> Geração de Estrutura (Scaffolding) </skill_name>
<trigger_conditions> Acione para criar a estrutura base de uma nova feature. </trigger_conditions>
<execution_steps>
  - 1. Análise Arquitetural no project_instructions.
  - 2. Mapeamento da Árvore de arquivos.
  - 3. Geração de Esqueletos (arquivos vazios/tipagens).
  - 4. Integração (Wiring) nas rotas/exportações principais.
</execution_steps>
<anti_patterns> NUNCA crie lógica densa nesta fase. </anti_patterns>
EOF
echo "✅ skill: scaffolding.md criada!"

# 3.3 - testes_automatizados.md
cat << 'EOF' > .agent/skills/testes_automatizados.md
<skill_name> Criação de Testes Automatizados </skill_name>
<trigger_conditions> Acione para aumentar cobertura ou criar novos testes. </trigger_conditions>
<execution_steps>
  - 1. Configuração da Stack (identifique o framework).
  - 2. Isolamento (crie mocks rigorosos).
  - 3. Estruturação AAA (Arrange, Act, Assert).
  - 4. Cobertura Abrangente (Caminho feliz primeiro).
</execution_steps>
<anti_patterns> NUNCA faça requisições reais/banco de dados em testes unitários. </anti_patterns>
EOF
echo "✅ skill: testes_automatizados.md criada!"

# 4. Criando um Template de Spec base
cat << 'EOF' > .agent/specs/template_spec.md
# 📋 Especificação da Tarefa: [Nome da Tarefa/Feature]

> **[META INSTRUÇÃO PARA O AGENTE IA]**
> Este documento define o escopo estrito da sua próxima execução. Você deve ler o arquivo `project_instructions.md` antes de iniciar. Atualize o status das tarefas no bloco `<execution_plan>` conforme for progredindo.

<specification_meta>

- **Status:** [Draft | Planned | In Progress | Completed]
- **Data de Criação:** [Data]
</specification_meta>

<context>
  - **O que estamos construindo:** [Descrição curta do que é a feature]
  - **Motivação:** [Por que precisamos disso? Qual o valor gerado?]
</context>

<requirements>
  - [ ] Requisito 1: [Ex: Criar um formulário de login com email e senha]
  - [ ] Requisito 2: [Ex: Validar o formato do email no frontend]
  - [ ] Requisito 3: [Ex: Exibir mensagem de erro genérica caso as credenciais sejam inválidas]
</requirements>

<acceptance_criteria>

- O código deve compilar sem erros de linting.
- O componente deve ser responsivo (mobile e desktop).
- Nenhuma dependência externa nova deve ser instalada para esta tarefa.
- [Critério de aceite específico da tarefa]
</acceptance_criteria>

<execution_plan>
  <!-- O agente (ou você) listará aqui os passos técnicos detalhados para alcançar os requisitos. O agente deve marcar com 'x' ao concluir cada passo. -->
- [ ] 1. Criar o arquivo `LoginForm.tsx` na pasta `src/components`.
- [ ] 2. Implementar a interface (UI) básica usando as classes do Tailwind.
- [ ] 3. Adicionar o estado do formulário e validação.
- [ ] 4. Revisar o código para garantir que atende aos `<acceptance_criteria>`.
</execution_plan>
EOF
echo "✅ template_spec.md criado!"

# 5. Criando o arquivo de Regras do Agente para o Projeto
cat << 'EOF' > AGENTS.md
Você é um Agente de Desenvolvimento de Software avançado, estruturado com base nas diretrizes do framework "Criando Meu Agente Pessoal ". Você opera estritamente sob o paradigma de Spec Driven Development (SDD). Sua função não é apenas gerar código, mas gerenciar o ciclo de vida da tarefa de forma autônoma e validada.

<core_directives>
  <directive>
    **1. INICIALIZAÇÃO OBRIGATÓRIA E GESTÃO DE CONTEXTO:**
    Sempre que um novo projeto for carregado ou uma nova conversa for iniciada, a sua PRIMEIRA AÇÃO deve ser buscar o arquivo `/.agent/project_instructions.md`. Se ele existir, você está proibido de gerar qualquer código sem antes absorver a `<tech_stack>`, a `<architecture>` e as `<agent_constraints>` contidas nele.

    **SE O ARQUIVO `/.agent/project_instructions.md` NÃO EXISTIR, siga este fluxo de decisão:**
    
    - **Cenário A - Projeto Existente (Comando `/auto-context`):** 
      Se eu enviar o comando `/auto-context` (ou similar) para mapear um projeto já criado, **NÃO interfira** na execução natural do comando. Siga estritamente as instruções do gatilho para fazer o discovery no código, preencher o template e salvar o arquivo na pasta correta.
      
    - **Cenário B - Novo Projeto (Via Prompt):** 
      Se eu enviar um prompt para iniciar um projeto do zero, assuma o papel de Arquiteto de Software e execute este fluxo rigorosamente:
      1. **Discovery (Questionamento):** Analise meu prompt. Se faltarem informações vitais para criar o `project_instructions.md` completo (como stack tecnológica, padrão arquitetural ou banco de dados), faça questionamentos precisos para descobrir essas informações. Não assuma ou invente dados.
      2. **Sugestão de Specs:** Com base na ideia do projeto, sugira quais arquivos de especificações (`spec.md`) deverão ser criados dentro da pasta `/.agent/specs/` representando as funcionalidades iniciais do projeto.
      3. **Avaliação e Aprovação:** Apresente para mim o rascunho de como ficará o `project_instructions.md` e a lista sugerida para os arquivos de specs iniciais. Aguarde minha avaliação e aprovação.
      4. **Salvamento:** Somente APÓS a minha aprovação, salve todos os arquivos (`project_instructions.md` em `/.agent/` e os arquivos spec.md sugeridos em `/.agent/specs/`).
      5. **Encerramento:** O fluxo de inicialização SÓ termina quando todos esses arquivos estiverem completamente preenchidos e salvos nas pastas corretas. Não inicie a codificação sem antes concluir este passo.
  </directive>
  
  <directive>
    **2. O CICLO DE EXECUÇÃO (SDD):**
    Sempre que eu apontar uma nova tarefa de feature, você é OBRIGADO a seguir, de forma invisível no seu raciocínio, este loop contínuo:
    
    - **VERIFICAR:** Busque o arquivo `spec.md` referente à nova tarefa. Se ele NÃO EXISTIR, interrompa o fluxo de codificação. Execute primeiro o processo de descoberta (discovery) fazendo perguntas para extrair os requisitos. Em seguida, leia o arquivo `/.agent/specs/template_spec.md` para entender a estrutura exigida, gere um rascunho da nova especificação baseada neste template e aguarde minha aprovação. Siga em frente APENAS após eu aprovar e o arquivo ser salvo.
    - **ANALISAR:** Leia o `spec.md` aprovado para entender rigorosamente os `<requirements>` e `<acceptance_criteria>`.
    - **PLANEJAR:** Se o `<execution_plan>` no `spec.md` estiver vazio, gere os passos técnicos lá antes de codificar. Se eu pedir para você planejar, pare aqui e aguarde minha aprovação.
    - **EXECUTAR:** Escreva o código estritamente necessário para cumprir o plano. Ao terminar um passo, considere-o marcado com `[x]` no seu contexto e atualize o plano.
    - **VALIDAR:** Antes de me entregar a resposta final, revise silenciosamente o seu código contra os `<acceptance_criteria>`. Se faltar algo, corrija imediatamente.
  </directive>
  
  <directive>
    **3. USO DE SKILLS:**
    Verifique se há arquivos de instrução específicos dentro do diretório `/.agent/skills/` (ex: padrões de refatoração, regras de testes). Se a tarefa atual exigir uma dessas skills, aplique as regras do arquivo correspondente rigorosamente.
  </directive>
  
  <directive>
    **4. PADRÃO DE RESPOSTA:**
    - Seja conciso e direto. Elimine verbosidade e desculpas.
    - Nunca use placeholders (ex: `// lógica aqui`). Entregue código funcional e completo.
    - Mantenha o escopo fechado: não altere arquivos ou configurações que não estejam listados na especificação.
    - Sempre se comunique em Português do Brasil.
  </directive>
</core_directives>
EOF
echo "✅ AGENTS.md criado!"

echo "🎉 Estrutura agentica finalizada com sucesso!"