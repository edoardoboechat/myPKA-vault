---
name: Docker & Workspaces (Local, Metris, Terra)
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_topics:
  - infrastructure-servers
  - ci-cd
tags:
  - docker
  - workspaces
  - environments
  - metris
  - terra
---

# Docker & Workspaces (Local, Metris, Terra)

## O que são

O ecossistema de desenvolvimento e execução do coingame está distribuído por diferentes ambientes e workspaces, integrando virtualização local e infraestrutura baseada em Docker.

## Workspaces e Servidores

O ecossistema divide-se em **ambientes locais** e **servidores remotos**:

### Ambientes Locais (nesta máquina)

| Ambiente | Caminho | Propósito |
|---|---|---|
| **projects** | `/home/master/hermes-stack/projects/` | Código fonte de projectos (ex: coingame) |
| **playwright** | `/home/master/hermes-stack/playwrite/` | Scripts de teste E2E e prints de validação |
| **library** | `/home/master/hermes-stack/library/` | Ficheiros de instrução e referência |

### Servidores Remotos

| Servidor | IP(s) | Propósito |
|---|---|---|
| **Terra** | `192.168.10.138` (LAN) / `100.122.21.51` (Tailscale) | Stateful: Keycloak, Postgres, RabbitMQ |
| **Metris** | _(por confirmar)_ | Stateless: monitorização, métricas, suporte |

### Ambientes de Execução

| Perfil | Alvo | Propósito |
|---|---|---|
| `local` (Spring) | `100.122.21.51:8443` via Tailscale | Desenvolvimento local contra infra real |
| `dev` (por definir) | Metris ou Terra de staging | Testes de integração |

## Docker no Ecossistema

1. **Serviços de Infra (Terra):** Keycloak, Postgres e RabbitMQ correm tipicamente em contentores Docker ou serviços dedicados na infraestrutura do servidor Terra.
2. **Build e Testes:** O build integrado (`mvn clean package -DskipTests`) compila backend e frontend num único artefacto (`backend-0.0.1-SNAPSHOT.jar`).
3. **Isolamento de Perfis:** O perfil Spring Boot `local` (`application-local.yaml`) aponta para as instâncias de infra (ex: `192.168.10.138` / Tailscale `100.122.21.51`) com porta SSL `8443` e keystore PKCS12 (`classpath:aetherquest-local.p12`).

## Regras de Execução

- **Nunca rodar da pasta errada:** Usar sempre os caminhos absolutos ou relativos corretos para o workspace do coingame ou playwright.
- **Processos em background:** Para servidores (como o backend Spring Boot), usar `terminal(background=true, notify_on_complete=true)` ou gerir via `process`.

## Cross-links

- [[infrastructure-servers]] — Servidores metris e terra
- [[ci-cd]] — Pipeline local e de build
- [[coingame]] — Project hub
