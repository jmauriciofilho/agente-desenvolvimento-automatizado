# ADA v2 — Framework Agêntico de Desenvolvimento Automatizado

Estrutura de desenvolvimento agêntico baseada em **Spec Driven Development (SDD)**, com fonte única de verdade em `.agent/` e adaptadores finos para **Antigravity**, **Claude Code**, **Codex** e **OpenCode**.

O script [`install.sh`](install.sh) instala tudo em qualquer repositório, de forma **idempotente**: rodar de novo nunca apaga o que você customizou.

---

## Estrutura do repositório do framework

O instalador é pequeno porque o **conteúdo vive em arquivos reais** (`template/`), não em heredocs. Para evoluir uma skill, edite o `.md` correspondente; não há script gigante para mexer.

```text
agente-desenvolvimento-automatizado/
├── install.sh          # instalador (~140 linhas): copia template/ para o projeto
├── build_single.sh     # opcional: gera instalador de arquivo único em dist/
├── README.md
└── template/
    ├── AGENTS.md
    ├── CLAUDE.md
    ├── agent/          # vira .agent/ no projeto (skills, templates, scripts, memory)
    └── commands/       # slash-commands (Claude Code e OpenCode)
```

| Quero... | Faça |
|---|---|
| Instalar em um projeto | `/caminho/agente-desenvolvimento-automatizado/install.sh` (na raiz do projeto) |
| Instalar direto de um repositório git | `bash install.sh --from=https://github.com/jmauriciofilho/agente-desenvolvimento-automatizado` |
| Distribuir um único arquivo | `bash build_single.sh` → `dist/setup_agent_ada_v2.sh` (template compactado embutido) |
| Editar/criar uma skill | Edite `template/agent/skills/<nome>/SKILL.md` e reinstale com `--force` nos projetos |

---

## Sumário

0. [Estrutura do repositório do framework](#estrutura-do-repositório-do-framework)
1. [Início rápido](#início-rápido)
2. [Tabela de compatibilidade](#tabela-de-compatibilidade)
3. [Estrutura gerada](#estrutura-gerada)
4. [O fluxo v2](#o-fluxo-v2)
5. [Skills](#skills)
6. [Slash-commands](#slash-commands)
7. [verify.sh](#verifysh)
8. [Opções do script](#opções-do-script)
9. [Guia de migração v1 → v2](#guia-de-migração-v1--v2)
10. [Solução de problemas](#solução-de-problemas)

---

## Início rápido

```bash
# 1. Na raiz do repositório
chmod +x install.sh
./install.sh

# 2a. Projeto existente: peça ao agente
/auto-context            # ou: "aplique a skill auto-context"

# 2b. Projeto novo: descreva a ideia; o agente faz o discovery,
#     propõe arquiteturas e quebra o MVP em specs.

# 3. Confirme que os comandos do projeto funcionam
.agent/scripts/verify.sh

# 4. Versione
git add AGENTS.md CLAUDE.md .agent .claude .agents .opencode
```

---

## Tabela de compatibilidade

| Ferramenta | Arquivo de regras | Skills lidas de | Como o ADA conecta | Slash-commands |
|---|---|---|---|---|
| **Antigravity** | `AGENTS.md` | `.agent/skills/` | Nativo (nenhum link necessário) | Skills por nome |
| **Claude Code** | `CLAUDE.md` (contém `@AGENTS.md`) | `.claude/skills/` | Symlink → `.agent/skills` | `.claude/commands/*.md` |
| **Codex** | `AGENTS.md` | `.agents/skills/` | Symlink → `.agent/skills` | Skills por nome |
| **OpenCode** | `AGENTS.md` | `.opencode/skills/` | Symlink → `.agent/skills` | `.opencode/command/*.md` |

> ⚠️ **Convenções sujeitas a mudança.** Os caminhos acima refletem as convenções conhecidas quando o script foi escrito e podem mudar entre versões das ferramentas. Confirme na documentação da sua versão. Se algum divergir, edite as variáveis no topo do script (`CLAUDE_SKILLS_DIR`, `CODEX_SKILLS_DIR`, `OPENCODE_SKILLS_DIR`, `CLAUDE_COMMANDS_DIR`, `OPENCODE_COMMANDS_DIR`).

**Ferramenta sem suporte nativo a skills?** Funciona igual. O `AGENTS.md` traz um índice de skills com o gatilho de cada uma e instrui o agente a ler `.agent/skills/<nome>/SKILL.md` quando o gatilho ocorrer.

**Windows sem permissão de symlink?** O script cai automaticamente para cópia dos arquivos (marcada com `.ada-copy`). Rode o script novamente após editar skills para atualizar as cópias.

---

## Estrutura gerada

```text
├── AGENTS.md                        # Regras curtas + índice de skills (fonte única de regras)
├── CLAUDE.md                        # "@AGENTS.md" (Claude Code)
├── .agent/
│   ├── project_instructions.md      # Contexto do projeto (marcador ADA:UNCONFIGURED até o auto-context)
│   ├── memory/learnings.md          # Aprendizados entre sessões
│   ├── decisions/                   # ADRs
│   ├── templates/                   # Fonte única: spec, mini-spec, ADR, project_instructions
│   ├── specs/
│   │   ├── active/                  # Specs em andamento
│   │   ├── done/                    # Specs concluídas
│   │   └── template_spec.md         # Cópia do template (compatibilidade com a v1)
│   ├── scripts/verify.sh            # lint + typecheck + test + build, via <commands>
│   └── skills/<16 skills>/SKILL.md
├── .claude/{skills → link, commands/}
├── .agents/skills → link            # Codex
└── .opencode/{skills → link, command/}
```

---

## O fluxo v2

Toda conversa começa com a **inicialização**, depois a **triagem** define o peso do processo, e só então roda o ciclo SDD.

### 0. Inicialização
1. Ler `.agent/project_instructions.md`. Se não existir ou ainda tiver o marcador `ADA:UNCONFIGURED`, o agente trata como inexistente e aciona `auto-context` (projeto existente) ou `spec-writer` em Modo Arquiteto (projeto novo).
2. Ler `.agent/memory/learnings.md` para não repetir erros já registrados.

### 1. Triagem (proporcional ao tamanho)

| Classe | Critério | Fluxo |
|---|---|---|
| **trivial** | ≤ 1 arquivo, ≤ ~20 linhas, sem mudar contrato ou dependências | Executa direto + `verify.sh` |
| **pequena** | 2–5 arquivos, comportamento localizado | Mini-spec com "ok" rápido |
| **feature** | Novo módulo/contrato, auth/dados, nova dependência ou > 5 arquivos | Spec completa + revisão + aprovação explícita |
| **bug** | Comportamento diverge do esperado | Skill `bugfix` |

Em dúvida, sobe um nível. Se o escopo crescer no meio da execução, o agente **para e reclassifica**.

### 2. Ciclo SDD

| Etapa | O que acontece |
|---|---|
| **VERIFICAR** | Procura a spec em `.agent/specs/active/`. Sem spec (e tarefa que exige): para de codar e roda `spec-writer` |
| **ANALISAR** | Lê `<requirements>`, `<acceptance_criteria>`, `<files_in_scope>`, `<out_of_scope>` |
| **PLANEJAR** | Gera `<execution_plan>` se estiver vazio |
| **EXECUTAR** | Código completo, só em `<files_in_scope>`; marca `[x]` a cada passo |
| **VALIDAR** | `verify.sh` + `revisao-codigo` do diff + conferência dos ACs |
| **FECHAR** | Skill `memoria`; spec vira `Completed` e vai para `done/` |

### Spec v2
Além dos blocos da v1, a spec agora tem `<files_in_scope>`, `<out_of_scope>`, `<risks>`, `<test_plan>` (rastreabilidade **R → AC → teste**) e `<definition_of_done>`.

---

## Skills

| Skill | Função | Gatilho |
|---|---|---|
| `triagem` | Classifica a tarefa e escolhe o fluxo | Início de toda tarefa |
| `auto-context` | Descobre a arquitetura e gera `project_instructions.md` (inclui `<commands>` reais) | Sem contexto válido; `/auto-context` |
| `spec-writer` | Discovery → spec (Modo A: feature; Modo B: projeto novo) | Feature sem spec; projeto novo |
| `spec-review` | Checa testabilidade, rastreabilidade, escopo e contradições | Antes de pedir aprovação |
| `scaffolding` | Esqueletos, contratos e wiring | Nova feature/módulo |
| `testes-automatizados` | Testes AAA vinculados aos ACs | Criar/ampliar testes |
| `bugfix` | Reproduzir → teste que falha → causa raiz → correção mínima | Bug, regressão, teste quebrando |
| `refatoracao` | Limpeza em passos pequenos, com testes de caracterização | Simplificação sem mudar comportamento |
| `revisao-codigo` | Autorrevisão do diff (spec, corretude, segurança, testes) | Antes de entregar; revisão de PR |
| `security-audit` | Segredos, entrada, authn/authz, dependências, OWASP | Auth, dados de usuário, APIs públicas |
| `dependency-eval` | Justifica e compara antes de adicionar uma biblioteca | Antes de qualquer dependência nova |
| `git-workflow` | Branch, Conventional Commits, descrição de PR | Versionamento (só commita se autorizado) |
| `adr` | Registra decisões arquiteturais | Escolhas de impacto duradouro |
| `context-sync` | Detecta drift entre código e `project_instructions.md` | Após mudanças estruturais |
| `migracao-upgrade` | Upgrades em etapas, com rollback | Atualização de versões/frameworks |
| `memoria` | Grava aprendizados e fecha a spec | Fim de toda tarefa não trivial |

---

## Slash-commands

Atalhos opcionais gerados para **Claude Code** e **OpenCode**. Nas demais ferramentas, invoque a skill pelo nome.

| Comando | Faz |
|---|---|
| `/auto-context` | Mapeia o projeto e gera `project_instructions.md` |
| `/spec <tarefa>` | Triagem + `spec-writer` + `spec-review` |
| `/bugfix <descrição>` | Método completo de correção de bug |
| `/review [foco]` | `revisao-codigo` do diff atual |
| `/verify [etapas]` | Roda `verify.sh` e trata falhas |
| `/context-sync` | Sincroniza o contexto com o código real |

---

## verify.sh

Lê o bloco `<commands>` de `.agent/project_instructions.md`:

```text
<commands>
  - install: npm ci
  - lint: npm run lint
  - typecheck: npm run typecheck
  - test: npm test
  - build: npm run build
</commands>
```

```bash
.agent/scripts/verify.sh              # lint, typecheck, test, build
.agent/scripts/verify.sh lint test    # apenas as etapas indicadas
```

| Código de saída | Significado |
|---|---|
| `0` | Tudo que foi executado passou |
| `1` | Alguma etapa falhou |
| `2` | Contexto ausente ou ainda `ADA:UNCONFIGURED` |
| `3` | Nada executado (nenhum comando configurado) |

Etapas com valor `N/A` ou placeholder `[...]` são ignoradas, não falham.

---

## Opções do script

| Opção | Efeito |
|---|---|
| *(nenhuma)* | Cria o que falta; **mantém** o que já existe |
| `--force` | Sobrescreve existentes, gerando backup `arquivo.bak` |
| `--tools=a,b` | Limita a `antigravity,claude,codex,opencode` (padrão: todas) |
| `--no-links` | Não cria symlinks/cópias de skills |
| `--no-commands` | Não cria slash-commands |
| `-h`, `--help` | Ajuda |

---

## Guia de migração v1 → v2

### O que mudou

| Tema | v1 | v2 |
|---|---|---|
| Regras | `AGENTS.md` longo, com o discovery embutido | `AGENTS.md` curto + índice; procedimentos viraram skills |
| Re-execução do script | Sobrescreve tudo | Idempotente; `--force` faz backup |
| Contexto | Exemplo com dados falsos (`/src/components`...) tratado como verdade | Só placeholders + marcador `ADA:UNCONFIGURED` |
| Validação | "Se houver linters, execute" (sem saber quais) | Bloco `<commands>` + `verify.sh` |
| Processo | Sempre spec completa | Triagem: trivial / pequena / feature / bug |
| Spec | 4 blocos | + `files_in_scope`, `out_of_scope`, `risks`, `test_plan`, `definition_of_done` |
| Template | Duplicado na skill e no arquivo | Fonte única em `.agent/templates/` |
| Specs | Soltas em `.agent/specs/` | `specs/active/` e `specs/done/` |
| Memória | Nenhuma | `.agent/memory/learnings.md` |
| Skills | 4 | 16 |
| Ferramentas | Antigravity | + Claude Code, Codex, OpenCode |
| Links de código | `file:///` | `caminho/relativo:Lx-Ly` (`file://` ainda aceito no Antigravity) |

### Passo a passo

**1. Backup e branch**
```bash
git checkout -b chore/ada-v2
git status   # árvore limpa
```

**2. Rode o instalador (modo seguro)**
```bash
./install.sh
```
Sem `--force`, seus arquivos existentes são **mantidos**. O script só adiciona o que falta (skills novas, templates, `verify.sh`, `memory/`, links, `CLAUDE.md`).

**3. Atualize o `AGENTS.md`**
O seu foi mantido e ainda é o da v1. Duas opções:
```bash
# A) Substituir pelo novo (seu antigo vira AGENTS.md.bak)
./install.sh --force --tools=antigravity --no-links --no-commands
```
Depois copie de `AGENTS.md.bak` para o novo `AGENTS.md` qualquer regra própria que você tenha adicionado.

> ⚠️ `--force` sobrescreve **todos** os arquivos do script, inclusive `.agent/project_instructions.md` (que voltaria ao estado `UNCONFIGURED`; o seu fica em `.bak`). Se preferir não arriscar, use a opção B.

```bash
# B) Manual: copie o AGENTS.md de um repositório de teste onde você rodou o script
mkdir /tmp/ada-ref && (cd /tmp/ada-ref && /caminho/install.sh --no-links --no-commands)
cp /tmp/ada-ref/AGENTS.md ./AGENTS.md
```

**4. Atualize o `project_instructions.md` (sem perder o conteúdo)**
O seu arquivo da v1 não tem o marcador, então é tratado como **configurado**, mas falta o que a v2 usa. Peça ao agente:
```text
/context-sync
```
ou adicione manualmente estes blocos, copiando a estrutura de `.agent/templates/project_instructions.template.md`:
- `<commands>` (**obrigatório** para o `verify.sh` funcionar)
- `<git_conventions>`, `<security>`, `<definition_of_done>`

Se o seu arquivo ainda tiver os dados de exemplo da v1 (`/src/components`, `PascalCase.tsx`), apague-os e rode `/auto-context` para regenerar com dados reais.

**5. Atualize as skills antigas**
As 4 skills da v1 (`auto-context`, `refatoracao`, `scaffolding`, `testes-automatizados`) foram **mantidas** e não recebem as melhorias. Para atualizá-las sem tocar no resto:
```bash
for s in auto-context refatoracao scaffolding testes-automatizados; do
  mv .agent/skills/$s/SKILL.md .agent/skills/$s/SKILL.md.v1
done
./install.sh          # recria apenas as que estão faltando
```
Se você customizou alguma, compare com o `.v1` e reaplique. Depois apague os `.v1`.

**6. Reorganize as specs**
```bash
mkdir -p .agent/specs/active .agent/specs/done
# Specs em andamento ou rascunho:
git mv .agent/specs/minha_feature_spec.md .agent/specs/active/
# Specs já concluídas:
git mv .agent/specs/outra_spec.md .agent/specs/done/
```
Mantenha `.agent/specs/template_spec.md`; ele é só compatibilidade.

Specs antigas continuam válidas, mas sem `files_in_scope` o agente não sabe o limite do escopo. Peça `spec-review` nas que ainda estão ativas.

**7. Valide**
```bash
.agent/scripts/verify.sh
```
- Saída `3` → `<commands>` ainda não configurado (passo 4).
- Algum comando falhando → corrija o comando no `<commands>` ou o projeto.

**8. Commit**
```bash
git add -A
git commit -m "chore: migra framework ADA para v2"
```

### Checklist de migração

- [ ] Branch criada, árvore limpa
- [ ] `install.sh` executado
- [ ] `AGENTS.md` atualizado (regras próprias preservadas)
- [ ] `project_instructions.md` com `<commands>`, `<git_conventions>`, `<security>`, `<definition_of_done>`
- [ ] Dados de exemplo da v1 removidos
- [ ] Skills antigas atualizadas
- [ ] Specs movidas para `active/` e `done/`
- [ ] `verify.sh` retorna `0`
- [ ] Links de skills funcionando (`ls -la .claude .agents .opencode`)

---

## Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| `verify.sh` sai com `2` | Marcador `ADA:UNCONFIGURED` presente | Rode `/auto-context` |
| `verify.sh` sai com `3` | `<commands>` vazio, `N/A` ou placeholders | Preencha os comandos reais |
| Ferramenta não enxerga as skills | Caminho de skills diferente na sua versão | Ajuste as variáveis no topo do script e rode com `--force` só nos links, ou crie o link manualmente: `ln -s ../.agent/skills <pasta>/skills` |
| `⚠️ ... já existe e não é um link do ADA` | Você já tinha uma pasta de skills própria na ferramenta | Mescle manualmente; o script não a toca |
| Skills desatualizadas no Windows | Cópia em vez de symlink | Rode o script novamente |
| Agente ignora o `AGENTS.md` | Ferramenta lê outro arquivo | No Claude Code, confirme que `CLAUDE.md` contém `@AGENTS.md` |
| Agente exige spec para tarefa mínima | Triagem não aplicada | Lembre: "aplique a skill `triagem`"; confira o `AGENTS.md` v2 |

---

## Princípios do framework

1. **Fonte única:** tudo vive em `.agent/`; as ferramentas apontam para lá.
2. **Processo proporcional:** burocracia só onde o risco justifica.
3. **Escopo fechado:** o que não está em `<files_in_scope>` não é tocado.
4. **Evidência antes de afirmação:** `verify.sh` e testes decidem, não a opinião do agente.
5. **Memória:** o agente aprende com os erros do projeto entre sessões.
