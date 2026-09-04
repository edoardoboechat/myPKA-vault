---
name: CI/CD — Continuous Integration / Continuous Deployment
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_session_logs:
  - 2026-08-29-11-37_hermes_mypka-integration
  - 2026-08-29-12-05_hermes_mypka-integration
linked_topics:
  - sdlc
  - ddd-software-design
tags:
  - ci-cd
  - pipeline
  - deploy
  - build
---

# CI/CD — Continuous Integration / Continuous Deployment

## O que é

Pipeline de automação que pega no código, compila, testa, e entrega. No coingame, a pipeline local (desenvolvimento) e produção são distintas.

## Pipeline local (validação)

A validação local segue o SDLC phase 4. Cada peça de trabalho é validada antes do merge.

### Build
```bash
# Backend
mvn -f backend-spring/pom.xml clean package -DskipTests

# Frontend
cd frontend-react-pwa && npm run build
```

### Test
```bash
# Playwright (UI smoke tests)
python3 ~/hermes-stack/playwrite/coingame/<script>.py
```

### Visual validation
- Captura de screenshots via Playwright
- Vision-analyze para confirmar layout e paleta
- Comparação com baseline se aplicável

## Pipeline de produção (a definir)

Estado actual: **não existe pipeline automatizada** — deploys são manuais.

### O que precisa existir
- Build automático em push a `develop` e `master`
- Run de testes unitários + integração
- Containerização: Dockerfile para backend
- Orquestração: docker-compose ou k8s
- Secrets management: Keycloak, Postgres, RabbitMQ
- Deploy em dev/prod com roll-back capability

### Variáveis de ambiente
- `KEYCLOAK_URL`
- `POSTGRES_URL` + `POSTGRES_PASSWORD` (`changeit`)
- `RABBITMQ_URL` + `RABBITMQ_PASSWORD` (`changeit`)
- `SPRING_PROFILES_ACTIVE=prod`

## Build artefactos

| Artefacto | Onde | Quando |
|---|---|---|
| `backend-0.0.1-SNAPSHOT.jar` | `backend-spring/target/` | Cada `mvn package` |
| APK | `frontend-react-pwa/build/` | Cada `npm run build` + Android packaging |
| `coingame-backend-latest.jar` | `/home/master/` | Cópia manual para deploy |

## Estratégia de branching

| Branch | Função | Protegida |
|---|---|---|
| `master` | Produção | Sim |
| `develop` | Integração | Sim |
| `feat/*` | Features em desenvolvimento | Não |
| `fix/*` | Bug fixes | Não |
| `chore/*` | Manutenção | Não |

## Anti-patterns

- Skip de validação (push sem build)
- Deploy em sexta-feira
- Build sem tests
- Não ter rollback strategy
- Secrets no repositório

## Open threads

- Definir Dockerfile do backend
- Definir estratégia de deploy (manual vs automatizado)
- Configurar Keycloak para produção
- Build do APK para Android

## Cross-links

- [[sdlc]] — processo de desenvolvimento
- [[coingame]] — Project hub
- [[SOP-coingame-development-process]] — SOP formal
