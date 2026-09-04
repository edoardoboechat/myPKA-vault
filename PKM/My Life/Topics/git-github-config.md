---
name: Git & GitHub Configuration
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_topics:
  - sdlc
  - ci-cd
tags:
  - git
  - github
  - cli
  - gh
---

# Git & GitHub Configuration

## GitHub CLI (gh)

O binário `gh` é **exclusivo do ambiente de execução atual**. Nunca deve ser executado ou buscado em servidores remotos — é uma tool do host, não do runtime do assistente.

Comandos principais:
```bash
gh pr create --base master --head <branch>   # Criar PR
gh pr merge <n> --squash --delete-branch --auto   # Merge squash
gh pr list   # Listar PRs
gh repo view  # Ver repositório actual
```

## Git Flow — Regras Estritas

| Regra | Razão |
|---|---|
| Nunca trabalhar em `master` | Branch de estabilidade, protegida |
| Nunca `git push` sem aprovação explícita | Controlo do utilizador |
| Sempre criar PR antes de merge | Traceabilidade |
| Sempre recriar `develop` após merge | Branch sempre sincronizada com master |
| Commits atómicos e descritivos | Facilita revert e code review |
| Sem texto fictício de progresso (WIP) | Traceabilidade |

## Ramificação

| Branch | Função | Protegida |
|---|---|---|
| `master` | Produção | Sim |
| `develop` | Integração contínua | Sim |
| `feat/<slug>` | Features | Não |
| `fix/<slug>` | Bug fixes | Não |
| `chore/<slug>` | Manutenção | Não |

## Fluxo Completo

```bash
# 1. Criar branch a partir de develop
git checkout develop && git pull
git checkout -b feat/<slug>

# 2. Desenvolvimento + commit (com aprovação)
git add -A && git commit -m "feat: <description>"

# 3. Push (com aprovação)
git push origin feat/<slug>

# 4. Criar PR (com aprovação)
gh pr create --base master --head feat/<slug>

# 5. Merge (com aprovação)
gh pr merge <n> --squash --delete-branch --auto

# 6. Recriar develop
git checkout master && git pull
git checkout -b develop
git push origin develop
git branch --set-upstream-to=origin/develop develop
```

## Anti-patterns

- Trabalhar em `master` directamente
- Push automático sem aprovação
- Commits "WIP" com push
- Merge sem PR
- Não recriar `develop` após merge

## Cross-links

- [[sdlc]] — SDLC completo
- [[ci-cd]] — Pipeline de build
- [[coingame]] — Project hub
