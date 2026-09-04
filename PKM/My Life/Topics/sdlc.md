---
name: SDLC — Software Development Life Cycle
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_session_logs:
  - 2026-08-29-11-37_hermes_mypka-integration
  - 2026-08-29-12-05_hermes_mypka-integration
linked_topics:
  - ci-cd
  - ddd-software-design
  - clean-code-solid
tags:
  - sdlc
  - git
  - process
  - workflow
---

# SDLC — Software Development Life Cycle

## O que é

O SDLC do coingame define o ciclo completo de vida de uma funcionalidade ou correcção: desde a decisão de trabalho até ao merge em produção. É um ciclo iterativo, com gates de validação em cada transição.

## As 6 fases

### 1. Decisão — o que fazer

- Identificar a necessidade (bug, feature, refactor)
- Classificar: bug urgente → hotfix, feature → topic branch, chore → quando natural
- Definir done criteria (o que "pronto" significa)

### 2. Preparação — o contexto

- Ler session logs relevantes para contexto
- Verificar estado actual do repositório (branch, commits pendentes)
- Carregar skill correspondente (validation-workflow, local-run, etc.)
- Criar task no vault se o trabalho займе mais de um turn

### 3. Desenvolvimento — a execução

- Criar branch a partir de `develop` (nunca de `master`)
- Naming: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`
- Commits atómicos, com mensagem descritiva
- Pedir aprovação ao utilizador antes de cada commit

### 4. Validação — o gate

Antes de qualquer merge, validar:
- Build: `mvn -f backend-spring/pom.xml clean package -DskipTests`
- Frontend: `cd frontend-react-pwa && npm run build`
- Smoke test: Playwright scripts em `~/hermes-stack/playwrite/coingame/`
- Screenshots capturados se UI mudou
- Não fazer push sem validação aprovada

### 5. Revisão — o merge

- Criar PR via `gh pr create --base master --head <branch>`
- Revisão pelo utilizador
- Merge via `gh pr merge <n> --squash --delete-branch --auto`
-Após merge, recriar `develop` de `origin/master`:
  ```
  git checkout master && git pull && git checkout -b develop && git push origin develop
  git branch --set-upstream-to=origin/develop develop
  ```

### 6. Fecho — a continuidade

- Actualizar coingame.md com nova lição se aplicável
- Session log com o que foi feito
- Memory update se estado mudou (novo commit, branch, processo)

## Git Flow — regras estritas

| Regra | Razão |
|---|---|
| Nunca trabalhar directamente em `master` | Branch de estabilidade |
| Nunca fazer `git push` sem aprovação | Controlo do utilizador |
| Sempre criar PR antes de merge | Traceabilidade |
| Sempre recriar `develop` após merge | Branch sempre sincronizada |
| Commits atómicos | Facilita revert e code review |

## Anti-patterns

- Commitar "WIP" e fazer push
- Fazer merge sem validação
- Trabalhar em `master`
- Fazer push sem o utilizador saber
- Criar branch de `master` em vez de `develop`

## Cross-links

- [[ci-cd]] — pipeline de integração e deploy
- [[ddd-software-design]] — arquitectura e modelo de domínio
- [[clean-code-solid]] — práticas de código limpo
- [[coingame]] — Project hub
- [[SOP-coingame-development-process]] — SOP formal do processo
