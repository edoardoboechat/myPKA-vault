---
name: Coin Game
status: active
target_date: null
key_element: engineering
linked_goals: []
linked_topics:
  - spring-boot
  - react-pwa
  - ddd
  - ar-game
  - clean-code
  - solid
  - sdlc
  - ci-cd
  - playwright-testing
  - infrastructure-servers
  - docker-and-workspaces
  - git-github-config
  - credentials-and-security
linked_sops:
  - SOP-coingame-development-process
linked_session_logs:
  - 2026-08-29-11-37_hermes_mypka-integration
  - 2026-08-29-12-05_hermes_mypka-integration
linked_people:
  - hunterX
linked_deliverables:
  - coingame-backend-latest.jar
linked_journal_entries: []
tags:
  - software
  - game
  - spring-boot
  - react
  - ddd
  - clean-code
  - solid
  - sdlc
  - ci-cd
---

# Coin Game

## O que é

Coin Game é um jogo de realidade aumentada onde o jogador usa a câmara do telemóvel para encontrar moedas escondidas em scans ao vivo. Backend em Spring Boot, frontend React PWA, autenticação Keycloak.

## Stack

- **Backend:** Spring Boot (Java 17+)
- **Frontend:** React PWA
- **Infra:** Keycloak, Postgres, RabbitMQ
- **Dev URL:** `https://100.122.21.51:8443` (profile `local`)
- **Credenciais:** admin / [REDACTED], pilot01 / [REDACTED]

## Estado atual

- **Branch:** `develop` (tracking `origin/develop`)
- **Último commit:** `89ff69e` (2026-08-29)
- **JAR:** `/home/master/coingame-backend-latest.jar` (61MB)
- **Build:** `mvn -f backend-spring/pom.xml clean package -DskipTests`
- **Playwright:** `~/hermes-stack/playwrite/coingame/`

## Metodologia e Processo

O coingame segue rigorosamente a metodologia myPKA integrada com o Hermes Agent:
- **SDLC:** [[sdlc]] — ciclo de vida em 6 fases (Decisão, Preparação, Desenvolvimento, Validação, Revisão, Fecho)
- **CI/CD:** [[ci-cd]] — pipeline local de build, teste e validação visual
- **Arquitectura:** [[ddd-software-design]] — Domain-Driven Design (Players, GameSessions, Coins, Scans)
- **Qualidade:** [[clean-code-solid]] — Clean Code e princípios SOLID
- **Processo formal:** [[SOP-coingame-development-process]] — SOP canónico de desenvolvimento
- **Git Flow:** Skill `coingame-git-governance` (nunca em `master`, commits atómicos, PR squash, recriar `develop`)

## Conhecimento acumulado

### Skills de desenvolvimento
- [[coingame-validation-workflow]] — fluxo de validação local
- [[coingame-local-run]] — como subir o projeto localmente
- [[coingame-ledger-ux-patterns]] — paleta escura, toast bottom-right, inputs dark theme
- [[coingame-frontend-ui]] — mapeamento de componentes React
- [[coingame-time-control-architecture]] — regras de tempo de jogo
- [[coingame-git-governance]] — regras git estritas

### Session logs
- [[2026-08-29-11-37_hermes_mypka-integration]] — integração myPKA + Hermes
- [[2026-08-29-12-05_hermes_mypka-integration]] — manual + Vigil + Shard Pattern

### Screenshots validados
- `/home/master/proof_landing.png`
- `/home/master/proof_home.png`
- `/home/master/proof_ledger.png`
- `/home/master/proof_profile.png`
- `/home/master/proof_tasks.png`
- `/home/master/proof_admin-game.png`
- `/home/master/proof_admin-users.png`

### Lições aprendidas
- **LandingScreen bug:** H1 dentro de TopBar.jsx (linha 67, `!hasSession`) fazia o header ter 318px de altura, empurrando tudo para baixo. Removido o H1 — o título fica apenas no LandingScreen.jsx.
- **Toast position:** Deve ficar no `bottom: 24px; right: 24px` — nunca no topo para não cobrir KPIs.
- **Inputs dark theme:** Sempre `var(--surface-card)` (`rgba(23, 31, 51, 0.82)`).
- **Git flow:** Nunca work directly on master. Commits em `develop`, PR para `master` via `gh pr create`, merge com `gh pr merge`, recreate `develop` de `origin/master`.
- **Paleta:** Dark navy + teal/cyan. Nunca backgrounds brancos.
- **Screenshots Playwright:** Sempre em `~/hermes-stack/playwrite/coingame/prints/` — nunca em `/home/master/`. Convenção documentada em `playwright-testing.md`.

### Autenticação
- **Keycloak realm:** `aether-quest`
- **Usuários:** admin, pilot01, hunterX
- **Senhas:** todas `Hitachi$20261`

### Infra local
- **Tailscale IP:** `100.122.21.51` (Terra)
- **Backend profile:** `local` (porta 8443 SSL, aponta para `192.168.10.138`)

### Produção (Metris)
- **URL produção:** `https://metris.com.br` (via Nginx + SSL)
- **Backend produção:** `ghcr.io/edoardoboechat/coingame:latest` (Docker container)
- **Docker registry:** GitHub Container Registry (ghcr.io)

## Cross-links

- [[sdlc]] — SDLC do projeto
- [[ci-cd]] — CI/CD e pipelines
- [[ddd-software-design]] — DDD
- [[clean-code-solid]] — Clean Code & SOLID
- [[playwright-testing]] — Playwright e validação visual
- [[infrastructure-servers]] — Servidores metris e terra
- [[docker-and-workspaces]] — Docker, local, metris, terra
- [[git-github-config]] — Git flow e GitHub CLI
- [[credentials-and-security]] — Credenciais e segurança
- [[SOP-coingame-development-process]] — SOP formal
- [[coingame-validation-workflow]] — validação
- [[coingame-local-run]] — execução local
- [[coingame-ledger-ux-patterns]] — UX/UI
- [[coingame-git-governance]] — git
- [[coingame-time-control-architecture]] — tempo
