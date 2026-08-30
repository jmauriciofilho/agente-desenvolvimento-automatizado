# Framework Agêntico de Desenvolvimento Automatizado (Google Antigravity)

Este projeto implementa uma estrutura de desenvolvimento agêntico avançado baseada nas diretrizes do framework **"Criando Meu Agente Pessoal"**, adaptada especificamente para o ecossistema **Google Antigravity** (CLI e IDE).

O framework opera sob o paradigma de **Spec Driven Development (SDD)**, garantindo que o agente execute tarefas com validação rigorosa de escopo, descoberta automática de contexto e habilidades modulares (Skills).

---

## 🎯 Estrutura Gerada pelo `setup_agent_ada.sh`

O script [`setup_agent_ada.sh`](file:///home/mauricio/workspace/agente-desenvolvimento-automatizado/setup_agent_ada.sh) atua como instalador (*bootstrap*) para configurar a estrutura em qualquer repositório:

```text
├── AGENTS.md                          # Diretrizes e regras globais do agente no Antigravity
├── .agent/
│   ├── project_instructions.md        # Contexto, tech stack e restrições arquiteturais do projeto
│   ├── specs/
│   │   └── template_spec.md           # Template padrão para especificações de tarefas (SDD)
│   └── skills/                        # Habilidades sob demanda (Progressive Disclosure)
│       ├── auto-context/SKILL.md      # Descoberta da arquitetura e criação de project_instructions
│       ├── refatoracao/SKILL.md       # Otimização e limpeza sem quebra de contratos
│       ├── scaffolding/SKILL.md       # Geração de esqueletos e contratos de novas features
│       └── testes-automatizados/SKILL.md # Criação de testes unitários e de integração (AAA)
```

---

## 🚀 Como Usar

### 1. Inicializar a Estrutura no Projeto
Copie o script [`setup_agent_ada.sh`](file:///home/mauricio/workspace/agente-desenvolvimento-automatizado/setup_agent_ada.sh) para a raiz do seu repositório e execute:

```bash
chmod +x setup_agent_ada.sh
./setup_agent_ada.sh
```

### 2. Mapear o Projeto Existente
Em projetos já existentes, execute o comando:
```text
/auto-context
```
O agente fará uma análise profunda do repositório (podendo usar subagentes de pesquisa) e preencherá automaticamente o arquivo `.agent/project_instructions.md`.

### 3. Desenvolver Novas Funcionalidades (Ciclo SDD)
Ao solicitar uma nova funcionalidade ou tarefa:
1. **Verificação & Descoberta:** O agente verificará a existência de uma especificação em `.agent/specs/`. Caso não exista, ele fará perguntas de alinhamento e gerará uma nova spec baseada no [`template_spec.md`](file:///home/mauricio/workspace/agente-desenvolvimento-automatizado/.agent/specs/template_spec.md).
2. **Planejamento:** O plano de execução técnico será aprovado antes da codificação.
3. **Execução:** O código será implementado cumprindo estritamente o plano passo a passo.
4. **Validação:** O agente validará o código contra os critérios de aceite e testes automatizados.

### 4. Habilidades Modulares (Skills)
O Antigravity carrega as skills automaticamente conforme o contexto ou através de comandos na interface:
- `/auto-context`: Mapeamento e descoberta da arquitetura.
- `/refatoracao`: Limpeza e redução de complexidade de código.
- `/scaffolding`: Criação de estrutura base e esqueletos de novas features.
- `/testes-automatizados`: Criação e ampliação de testes com mocks e padrão AAA.
