#!/bin/bash

echo "🚀 Iniciando a instalação da estrutura agentica (Criando Meu Agente Pessoal)..."

# 1. Criando a árvore de diretórios
mkdir -p .agent/skills
mkdir -p .agent/specs

# 2. Criando o Cérebro (project_instructions.md)
cat << 'EOF' > .agent/project_instructions.md
# 🤖 Instruções e Contexto do Projeto

> **[META INSTRUÇÃO PARA O AGENTE IA]**
> Este arquivo contém a verdade absoluta sobre o projeto. Você DEVE ler e respeitar estas restrições e diretrizes antes de iniciar qualquer plano de execução.

<project_context>
  - **Nome do Projeto:** [Preencha aqui]
  - **Propósito:** [Preencha aqui]
  - **Público Alvo:** [Preencha aqui]
</project_context>

<tech_stack>
  - **Linguagem Principal:** [Ex: TypeScript v5.0]
  - **Framework Core:** [Ex: React 18]
  - **Ferramentas Auxiliares:** [Ex: Tailwind, Jest]
</tech_stack>

<architecture>
  - **Padrão Principal:** [Ex: Clean Architecture]
  - **Mapa de Diretórios (Resumo):** [Defina os diretórios principais]
</architecture>

<coding_guidelines>
  - **Nomenclatura:** [Ex: PascalCase para componentes, camelCase para variáveis]
  - **Geração de Código:** Não use placeholders. Escreva código funcional e completo.
</coding_guidelines>

<agent_constraints>
  - **PROIBIDO:** Modificar `.env` ou `node_modules`.
  - **OBRIGATÓRIO:** Siga estritamente o `spec.md` da tarefa atual.
</agent_constraints>

<available_skills>
  - Consulte o diretório `/.agent/skills/` se precisar de contexto adicional para tarefas específicas (refatoração, scaffolding, testes).
</available_skills>
EOF
echo "✅ project_instructions.md criado!"

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
# 📋 Especificação da Tarefa: [Nome da Feature]

<specification_meta>
  - **Status:** Draft
</specification_meta>

<requirements>
  - [ ] Requisito 1
</requirements>

<acceptance_criteria>
  - [ ] Critério 1
</acceptance_criteria>

<execution_plan>
  <!-- A IA preencherá as tarefas técnicas aqui -->
</execution_plan>
EOF
echo "✅ template de spec.md criado!"

# 5. Criando o arquivo de Regras do Agente para o Projeto
cat << 'EOF' > AGENTS.md
Você é um Agente de Desenvolvimento de Software avançado, estruturado com base nas diretrizes do framework "Criando Meu Agente Pessoal ". Você opera estritamente sob o paradigma de Spec Driven Development (SDD). Sua função não é apenas gerar código, mas gerenciar o ciclo de vida da tarefa de forma autônoma e validada.

<core_directives>
  <directive>
    **1. INICIALIZAÇÃO OBRIGATÓRIA:**
    Sempre que um novo projeto for carregado ou uma nova conversa for iniciada, a sua PRIMEIRA AÇÃO deve ser ler o arquivo `/.agent/project_instructions.md`. Você está proibido de gerar qualquer código sem antes absorver a `<tech_stack>`, a `<architecture>` e as `<agent_constraints>` contidas nele.
  </directive>
  
  <directive>
    **2. O CICLO DE EXECUÇÃO (SDD):**
    Sempre que eu apontar uma nova tarefa ou fornecer um arquivo `spec.md`, você é OBRIGADO a seguir, de forma invisível no seu raciocínio, este loop:
    - **ANALISAR:** Leia o `spec.md` para entender os `<requirements>` e `<acceptance_criteria>`.
    - **PLANEJAR:** Se o `<execution_plan>` no `spec.md` estiver vazio, gere os passos técnicos lá antes de codificar. Se eu pedir para você planejar, pare aqui e aguarde minha aprovação.
    - **EXECUTAR:** Escreva o código estritamente necessário para cumprir o plano. Ao terminar um passo, considere-o marcado com `[x]` no seu contexto.
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
  </directive>
</core_directives>
EOF
echo "✅ AGENTS.md criado!"

echo "🎉 Estrutura agentica finalizada com sucesso!"