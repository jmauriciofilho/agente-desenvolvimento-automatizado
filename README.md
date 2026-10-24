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
├── tools/record_hashes.sh  # registra hashes do template em template/known_hashes.txt (usado pelo --upgrade)
├── README.md
└── template/
    ├── AGENTS.md
    ├── CLAUDE.md
    ├── agent/          # vira .agent/ no projeto (skills, templates, scripts, memory)
    ├── claude/         # vira .claude/ (settings.json com hooks); só com --tools incluindo claude
    └── commands/       # slash-commands (Claude Code e OpenCode)
```

| Quero... | Faça |
|---|---|
| Instalar em um projeto | `/caminho/agente-desenvolvimento-automatizado/install.sh` (na raiz do projeto) |
| Instalar direto de um repositório git | `bash install.sh --from=https://github.com/jmauriciofilho/agente-desenvolvimento-automatizado` |
| Distribuir um único arquivo | `bash build_single.sh` → `dist/setup_agent_ada_v2.sh` (template compactado embutido) |
| Editar/criar uma skill | Edite `template/agent/skills/<nome>/SKILL.md`, rode `bash build_single.sh` e use `--upgrade` nos projetos |
| Atualizar um projeto que já usa o ADA | `/caminho/install.sh --upgrade` (veja antes com `--dry-run`) |

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
#     propõe arquiteturas, quebra o MVP em specs e executa o
#     marco 0 (bootstrap: git, esqueleto, lint e testes) antes da 1ª feature.

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
│   │   ├── roadmap.md               # Projeto novo: marcos do MVP (criado no Modo Arquiteto)
│   │   └── template_spec.md         # Cópia do template (compatibilidade com a v1)
│   ├── scripts/
│   │   ├── verify.sh                # escopo + lint + typecheck + test + build, via <commands>
│   │   ├── check-scope.sh           # diff dentro de <files_in_scope> da spec In Progress?
│   │   ├── status.sh                # specs ativas, progresso, próximo passo e próximo marco
│   │   └── hooks/                   # hooks do Claude Code (guard-edit, require-verify)
│   └── skills/<17 skills>/SKILL.md
├── .claude/{skills → link, commands/, settings.json}   # settings.json: hooks + permissões
├── .agents/skills → link            # Codex
└── .opencode/{skills → link, command/}
```

---

## O fluxo v2

Toda conversa começa com a **inicialização**, depois a **triagem** define o peso do processo, e só então roda o ciclo SDD.

### 0. Inicialização
1. Ler `.agent/project_instructions.md`. Se não existir ou ainda tiver o marcador `ADA:UNCONFIGURED`, o agente trata como inexistente e aciona `auto-context` (projeto existente) ou `spec-writer` em Modo Arquiteto seguido de `bootstrap` (projeto novo; veja abaixo).
2. Ler `.agent/memory/learnings.md` para não repetir erros já registrados.

### Projeto novo: Modo Arquiteto e marco 0

| Etapa | Skill | Resultado |
|---|---|---|
| Discovery e stack | `spec-writer` (Modo B) | Até 7 perguntas com sugestão; 2 propostas numa tabela fixa de critérios; sua escolha; ADR de stack com as dependências iniciais (pré-aprovadas) |
| Contexto planejado | `spec-writer` (Modo B) | `project_instructions.md` revisado e aprovado, com `<commands>` em `N/A` e estrutura "(planejado)"; `.agent/specs/roadmap.md` com os marcos do MVP |
| Marco 0 | `bootstrap` | Spec `00-bootstrap` aprovada; `git init` e commit dos arquivos do ADA (com sua autorização); esqueleto do gerador; `.gitignore`; lint, typecheck, testes e teste de fumaça; `<commands>` reais; `verify.sh` saindo com `0` |
| Primeira feature | ciclo SDD | Só começa com o marco 0 `Completed`; a spec de cada marco é escrita quando chega a vez dele, e o `status.sh` mostra o próximo |

Sem git, `check-scope.sh` e os hooks não fazem nada; por isso o instalador avisa quando a pasta não é repositório, e o bootstrap começa pelo `git init`.

O agente considera o projeto novo quando a pasta só tem arquivos do ADA (e, no máximo, `README`, `LICENSE` ou documentos). Em dúvida, ele pergunta.

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
| **EXECUTAR** | Spec vira `In Progress`; testes primeiro (falhando), depois a lógica; código completo, só em `<files_in_scope>`; marca `[x]` a cada passo |
| **VALIDAR** | `verify.sh` + `revisao-codigo` do diff + conferência dos ACs |
| **FECHAR** | Skill `memoria`; spec vira `Completed` e vai para `done/` |

**Retomada:** cada passo concluído (ou interrompido) é registrado em `<progress_log>`. Numa conversa nova, o agente roda `status.sh`, vê a spec `In Progress` e oferece retomá-la a partir do próximo passo. Só uma spec fica `In Progress` por vez.

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
| `bootstrap` | Marco 0: git, esqueleto, ferramentas e `<commands>` reais | Projeto novo, após o Modo Arquiteto |
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
| `/retomar` | Mostra as specs ativas (`status.sh`) e retoma a que está `In Progress` |

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

Sem argumentos, o `verify.sh` também roda o `check-scope.sh` (etapa `scope`) e, se tudo passar, grava um carimbo em `.git/ada-verify-stamp` com o hash do código atual. É esse carimbo que o hook `Stop` do Claude Code confere.

| Código de saída | Significado |
|---|---|
| `0` | Tudo que foi executado passou |
| `1` | Alguma etapa falhou |
| `2` | Contexto ausente ou ainda `ADA:UNCONFIGURED` |
| `3` | Nada executado (nenhum comando configurado) |

Etapas com valor `N/A` ou placeholder `[...]` são ignoradas, não falham.

### check-scope.sh

Compara o diff (`git diff HEAD` + arquivos novos) com os caminhos de `<files_in_scope>` e `<test_plan>` das specs com `Status: In Progress` (na mini-spec, a linha `**Arquivos:**`). Aceita diretório (`src/lib/`) e glob (`src/*.ts`). Arquivos em `.agent/` sempre podem ser alterados. Sem spec em andamento, não bloqueia nada.

### Hooks do Claude Code (`.claude/settings.json`)

| Hook | Quando | O que faz |
|---|---|---|
| `PreToolUse` → `guard-edit.sh` | Antes de `Edit`/`Write` | Bloqueia arquivo fora do escopo da spec em andamento e diz ao agente como pedir autorização |
| `SessionStart` → `status.sh --brief` | Ao abrir/retomar a sessão | Coloca no contexto as specs ativas e o próximo passo, para o agente oferecer a retomada |
| `Stop` → `require-verify.sh` | Ao encerrar o turno | Bloqueia se houver mudança fora do escopo ou código alterado sem `verify.sh` completo verde (uma vez por turno, sem loop) |

> ⚠️ **Só o Claude Code tem esses hooks.** Em Antigravity, Codex e OpenCode, o `AGENTS.md` manda o próprio agente rodar `check-scope.sh` após editar e `verify.sh` antes de encerrar, mas nada o obriga. Confira você mesmo com `.agent/scripts/verify.sh` antes de commitar.

Também traz permissões: `verify.sh` e `check-scope.sh` liberados, edição de `.env*`/`.gitignore` pede confirmação, edição em `node_modules`/`vendor`/`venv` é negada. Se o projeto já tinha `.claude/settings.json`, o instalador mantém o seu e avisa para mesclar.

---

## Opções do script

| Opção | Efeito |
|---|---|
| *(nenhuma)* | Cria o que falta; **mantém** o que já existe |
| `--upgrade` | Atualiza arquivos do framework que você **não** customizou; nos customizados, grava a nova versão em `arquivo.ada-new` |
| `--force` | Sobrescreve arquivos do framework, com backup `arquivo.bak.<data>` |
| `--dry-run` | Mostra o que seria feito, sem alterar nada |
| `--tools=a,b` | Limita a `antigravity,claude,codex,opencode` (padrão: todas) |
| `--no-links` | Não cria symlinks/cópias de skills |
| `--no-commands` | Não cria slash-commands |
| `-h`, `--help` | Ajuda |

### Atualização segura (`--upgrade`)

| Tipo de arquivo | Exemplos | O que o `--upgrade` faz |
|---|---|---|
| Do usuário | `project_instructions.md`, `memory/learnings.md`, specs, decisions | Nunca toca (nem com `--force`) |
| Do framework, original | skills, templates, scripts, comandos, `.claude/settings.json` | Atualiza |
| Do framework, customizado | uma skill que você editou | Mantém o seu e grava a nova versão em `.ada-new` para você mesclar |
| `AGENTS.md` com marcadores | `<!-- ADA:BEGIN -->` … `<!-- ADA:END -->` | Substitui só o bloco; suas regras em **Regras do projeto** ficam |
| Obsoleto | arquivo de versão antiga que saiu do ADA | Só avisa; nunca apaga |

"Original" é decidido por hash: o instalador grava `.agent/.ada-manifest` com o hash de cada arquivo instalado e também conhece os hashes de todas as versões publicadas (`template/known_hashes.txt`). Por isso projetos instalados antes do manifesto (v2.0, v2.1) também são atualizados com segurança.

---

## Guia de migração v1 → v2

### O que mudou

| Tema | v1 | v2 |
|---|---|---|
| Regras | `AGENTS.md` longo, com o discovery embutido | `AGENTS.md` curto + índice; procedimentos viraram skills |
| Re-execução do script | Sobrescreve tudo | Idempotente; `--upgrade` atualiza preservando customizações |
| Contexto | Exemplo com dados falsos (`/src/components`...) tratado como verdade | Só placeholders + marcador `ADA:UNCONFIGURED` |
| Validação | "Se houver linters, execute" (sem saber quais) | Bloco `<commands>` + `verify.sh` |
| Processo | Sempre spec completa | Triagem: trivial / pequena / feature / bug |
| Spec | 4 blocos | + `files_in_scope`, `out_of_scope`, `risks`, `test_plan`, `definition_of_done` |
| Template | Duplicado na skill e no arquivo | Fonte única em `.agent/templates/` |
| Specs | Soltas em `.agent/specs/` | `specs/active/` e `specs/done/` |
| Memória | Nenhuma | `.agent/memory/learnings.md` |
| Skills | 4 | 17 |
| Ferramentas | Antigravity | + Claude Code, Codex, OpenCode |
| Links de código | `file:///` | `caminho/relativo:Lx-Ly` (`file://` ainda aceito no Antigravity) |

### Passo a passo

**1. Backup e branch**
```bash
git checkout -b chore/ada-v2
git status   # árvore limpa
```

**2. Rode o instalador em modo de atualização**
```bash
./install.sh --upgrade --dry-run   # veja o que vai mudar
./install.sh --upgrade
```
O instalador reconhece os arquivos da v1 que você não editou (o `AGENTS.md` e as 4 skills antigas) e os atualiza. O `project_instructions.md` e a memória nunca são sobrescritos.

**3. Mescle o que você customizou**
Se você editou o `AGENTS.md` ou alguma skill, o seu arquivo foi mantido e a versão nova está em `<arquivo>.ada-new`. Para o `AGENTS.md`: use o `.ada-new` como base e copie suas regras próprias para a seção **Regras do projeto** (fora do bloco `ADA:BEGIN/END`); a partir daí as próximas atualizações preservam essas regras sozinhas.
```bash
find . -name '*.ada-new' -not -path './node_modules/*'   # lista o que mesclar
```
Arquivos marcados como `🗑️ obsoleto` (ex.: `.agent/skills/refatoracao.md` da v1) podem ser removidos.

**4. Atualize o `project_instructions.md` (sem perder o conteúdo)**
O seu arquivo da v1 não tem o marcador, então é tratado como **configurado**, mas falta o que a v2 usa. Peça ao agente:
```text
/context-sync
```
ou adicione manualmente estes blocos, copiando a estrutura de `.agent/templates/project_instructions.template.md`:
- `<commands>` (**obrigatório** para o `verify.sh` funcionar)
- `<git_conventions>`, `<security>`, `<definition_of_done>`

Se o seu arquivo ainda tiver os dados de exemplo da v1 (`/src/components`, `PascalCase.tsx`), apague-os e rode `/auto-context` para regenerar com dados reais.

**5. Reorganize as specs**
```bash
mkdir -p .agent/specs/active .agent/specs/done
# Specs em andamento ou rascunho:
git mv .agent/specs/minha_feature_spec.md .agent/specs/active/
# Specs já concluídas:
git mv .agent/specs/outra_spec.md .agent/specs/done/
```
Mantenha `.agent/specs/template_spec.md`; ele é só compatibilidade.

Specs antigas continuam válidas, mas sem `files_in_scope` o agente não sabe o limite do escopo. Peça `spec-review` nas que ainda estão ativas.

**6. Valide**
```bash
.agent/scripts/verify.sh
```
- Saída `3` → `<commands>` ainda não configurado (passo 4).
- Algum comando falhando → corrija o comando no `<commands>` ou o projeto.

**7. Commit**
```bash
git add -A
git commit -m "chore: migra framework ADA para v2"
```

### Checklist de migração

- [ ] Branch criada, árvore limpa
- [ ] `install.sh --upgrade` executado
- [ ] `.ada-new` mesclados e apagados; regras próprias em **Regras do projeto** do `AGENTS.md`
- [ ] `project_instructions.md` com `<commands>`, `<git_conventions>`, `<security>`, `<definition_of_done>`
- [ ] Dados de exemplo da v1 removidos
- [ ] Specs movidas para `active/` e `done/`
- [ ] `verify.sh` retorna `0`
- [ ] Links de skills funcionando (`ls -la .claude .agents .opencode`)

---

## Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| `verify.sh` sai com `2` | Marcador `ADA:UNCONFIGURED` presente | Projeto existente: `/auto-context`. Projeto novo: descreva a ideia (Modo Arquiteto) |
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
