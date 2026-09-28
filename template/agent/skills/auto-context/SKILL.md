---
name: auto-context
description: Faz o discovery da arquitetura do projeto existente e gera/atualiza .agent/project_instructions.md a partir do template. Use quando o arquivo não existir, estiver com marcador ADA:UNCONFIGURED, ou via /auto-context.
---

# 🧭 Auto-Context (Discovery de Projeto Existente)

Atue como Engenheiro de Software Sênior. Em repositórios grandes ou monorepos, delegue a exploração a um subagente de pesquisa se sua ferramenta suportar; caso contrário, explore por partes e resuma.

<execution_steps>
1. Leia `.agent/templates/project_instructions.template.md` (estrutura obrigatória).
2. Explore: README, manifests (package.json, pyproject.toml, requirements.txt, Cargo.toml, go.mod, pom.xml, composer.json...), lockfiles, configs (tsconfig, eslint, prettier, ruff, jest/vitest/pytest), CI (`.github/workflows`, etc.), Dockerfile, `Makefile`, scripts, estrutura de diretórios e amostras representativas de código.
3. Identifique com evidência: propósito/domínio; linguagem e versões; framework; gerenciador de pacotes; estilização; banco/ORM; framework de testes; padrão arquitetural; mapa de diretórios (4–6); convenções de nomenclatura e de erros; regras de git (histórico de commits, branches).
4. Extraia os **comandos reais** de `install`, `lint`, `typecheck`, `test`, `build`, `dev` (de scripts do manifest, Makefile ou CI). Se não existir, escreva `N/A`. Nunca invente comandos.
5. Em monorepos, documente cada pacote/app relevante e os comandos por workspace.
6. Preencha TODOS os campos com dados reais. Onde não houver evidência, escreva `N/A` ou faça uma pergunta ao usuário — nunca chute.
7. Remova a linha `<!-- ADA:UNCONFIGURED ... -->` e salve em `.agent/project_instructions.md` (crie `.agent/` se necessário). Se o arquivo já tinha conteúdo válido, mostre o diff e peça confirmação antes de sobrescrever.
8. Rode `.agent/scripts/verify.sh` para confirmar que os comandos funcionam; corrija os que falharem.
9. Resuma em ≤ 10 linhas o que foi descoberto e o que ficou como `N/A`.
</execution_steps>

<anti_patterns>
- NUNCA deixar placeholders `[...]` no arquivo final.
- NUNCA copiar exemplos genéricos do template como se fossem dados do projeto.
</anti_patterns>
