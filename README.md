# Framework Agentico Pessoal

Este projeto implementa uma estrutura de desenvolvimento agentico baseada nas diretrizes estabelecidas no documento "Criando Meu Agente Pessoal ". O foco principal é utilizar o paradigma de Spec Driven Development (SDD) para integrar de forma eficiente IAs (como Opencode, Claude Code e Codex) ao seu fluxo de trabalho diário.

## 🎯 Objetivo do Script `setup_agent.sh`

O script `setup_agent.sh` atua como um instalador rápido (bootstrap) do framework. O seu objetivo é **automatizar a criação da arquitetura padronizada** em qualquer repositório de código, eliminando a necessidade de criar os arquivos de contexto e habilidades manualmente.

Ao rodar o script, ele gera a seguinte árvore na raiz do seu projeto:

- **`/.agent/project_instructions.md`**: O "cérebro" do projeto. Contém as restrições, stack tecnológica e regras arquiteturais.
- **`/.agent/skills/`**: Um diretório com habilidades modulares (`refatoracao.md`, `scaffolding.md`, `testes_automatizados.md`) que ensinam o agente a realizar tarefas complexas com segurança.
- **`/.agent/specs/`**: Um diretório contendo o template padrão para as especificações (`spec.md`) das tarefas a serem desenvolvidas.

## 🚀 Como Usar

Siga o passo a passo abaixo no seu terminal (Linux, macOS ou WSL) para inicializar o framework no seu projeto:

1. **Adicione o Script:** Copie e salve o script bash como `setup_agent.sh` no diretório raiz do repositório onde deseja trabalhar.
2. **Conceda Permissão de Execução:**
   No seu terminal, rode o comando:

    ```bash
    chmod +x setup_agent.sh
    ```

3. Execute a Instalação:

    ```Bash
    ./setup_agent.sh
    ```

4. Preencha o Cérebro: Abra o arquivo gerado em /.agent/project_instructions.md e preencha as marcações em branco ([ ]) com as informações específicas e reais da sua aplicação.

5. Configure a Plataforma IA (Crucial): Adicione o "System Prompt" (gerado durante a estruturação do framework) nas configurações globais da ferramenta que for usar (ex: aba de customização do Opencode, ou arquivo .cursorrules).

6. Com isso feito, basta criar um novo spec.md na pasta de especificações e instruir a sua IA a seguir o plano!
