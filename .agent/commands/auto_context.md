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