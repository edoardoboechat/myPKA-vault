---
name: Infrastructure Servers — Metris & Terra
status: active
created: 2026-08-29
updated: 2026-08-29
linked_projects:
  - coingame
linked_topics:
  - ci-cd
  - docker-and-workspaces
tags:
  - infra
  - metris
  - terra
  - servers
  - network
---

# Infrastructure Servers — Metris & Terra

## O que são

O ecossistema de desenvolvimento e produção do coingame distribui-se por **dois servidores remotos**: **Terra** e **Metris**. Cada um tem um papel distinto e hospeda diferentes serviços via Docker.

## Servidor Terra

**Hostname:** `terra` (alias SSH)
**Real hostname:** `100.122.21.51` (Tailscale) / `192.168.10.138` (LAN)
**User:** `openclaw` (chave SSH: `~/.ssh/id_ed25519`)

**Papel:** Servidor de **infraestrutura de rede e serviços de identidade**. Hospeda Keycloak, base de dados e mensageria. Também serve de ambiente de desenvolvimento local contra serviços reais.

**Workspace remoto:** `~/workspace/`
- `docker-compose_infra.yml` — composição Docker da infra
- `.env` — variáveis de ambiente (credenciais)
- `infra/` — directório de infraestrutura (5 subdiretórios)

**Serviços Docker activos:**

| Container | Imagem | Portas expostas | Estado |
|---|---|---|---|
| `aether_keycloak` | `quay.io/keycloak/keycloak:22.0.1` | 8080, 8443 | Up 5 days |
| `aether_adminer` | `adminer:latest` | 8081 | Up 5 days |
| `aether_db` | `postgres:15-alpine` | 5432 | Up 5 days (healthy) |
| `aether_rabbitmq` | `rabbitmq:3-management` | 5672, 15672 | Up 5 days (healthy) |
| `aether_redis` | `redis:alpine` | 6379 | Up 5 days |

**System services activos:** Docker, Tailscale, SSH, cron, systemd-networkd, rsyslog, ModemManager, unattended-upgrades, udisks2.

**Realm Keycloak:** `aether-quest`
**Utilizadores:** `admin`, `pilot01`, `hunterX` (senha `Hitachi$20261`)
**Credenciais infra:** `changeit` (Postgres, RabbitMQ, Keycloak Admin)
**Porta backend:** 8443 (SSL)
**Profile Spring:** `local` (aponta para `100.122.21.51:8443`)

---

## Servidor Metris

**Hostname:** `metris` (alias SSH)
**Real hostname:** `metris.com.br`
**User:** `openclaw` (chave SSH: `~/.ssh/metris_key`)

**Papel:** Servidor de **produção / staging** com pipeline CI/CD activo. Hospeda o backend do coingame em produção (imagem Docker do GitHub Container Registry), reverse proxy Nginx, e ambiente completo com Keycloak próprio.

**Workspace remoto:** `~/workspace` (symlink → `/root/workspace`)
- `.git/` — repositório git do workspace
- `.gitignore`
- `coingame/` — código do coingame (clonado do repositório)

**Serviços Docker activos:**

| Container | Imagem | Portas expostas | Estado |
|---|---|---|---|
| `aether_backend` | `ghcr.io/edoardoboechat/coingame:latest` | (interno) | Up 30 hours |
| `aether_adminer` | `adminer:latest` | 8080 | Up 30 hours |
| `aether_nginx` | `nginx:alpine` | 80, 443 | Up 6 days |
| `aether_postgres` | `postgres:15-alpine` | 5432 (interno) | Up 6 days (healthy) |
| `aether_redis` | `redis:alpine` | 6379 (interno) | Up 6 days |
| `aether_keycloak` | `quay.io/keycloak/keycloak:22.0.1` | 8080, 8443 (interno) | Up 5 weeks |
| `aether_redis_commander` | `rediscommander/redis-commander:latest` | 8081 | Up 5 weeks (healthy) |
| `aether_rabbitmq` | `rabbitmq:3-management` | 5671-5672, 15672 (interno) | Up 5 weeks (healthy) |

**System services activos:** snap.docker.dockerd, snapd, chrony, SSH, cron, fwupd, systemd-networkd, rsyslog, ModemManager.

**Diferença em relação ao Terra:**

| Aspecto | Terra | Metris |
|---|---|---|
| Estado | Desenvolvimento local contra infra | Produção / Staging |
| Backend coingame | Não | Sim (via Docker, ghcr.io) |
| Frontend público | Não | Sim (via Nginx 80/443) |
| Pipeline CI/CD | Manual (docker-compose) | Automático (GitHub Container Registry) |
| Rede Tailscale | Sim | Não (acesso via metris.com.br) |
| Workspace | `~/workspace` (regular dir) | `~/workspace` (symlink para `/root/workspace`) |

---

## Regras de Acesso

### Acesso SSH

| Servidor | Alias SSH | Hostname | User | Chave SSH |
|---|---|---|---|---|
| **Terra** | `ssh terra` | `100.122.21.51` | `openclaw` | `~/.ssh/id_ed25519` |
| **Metris** | `ssh metris` | `metris.com.br` | `openclaw` | `~/.ssh/metris_key` |

### Terra
1. **SSH:** `ssh terra` (usa `~/.ssh/id_ed25519`)
2. **Tailscale:** `100.122.21.51` (acesso remoto seguro)
3. **LAN:** `192.168.10.138` (acesso local)

### Metris
1. **SSH:** `ssh metris` (usa `~/.ssh/metris_key`)
2. **Hostname:** `metris.com.br`
3. **Requer chave dedicada** (não usar `id_ed25519`)

### Regras Comuns
1. **Credenciais nunca em commits:** Usar `changeit` e `.env` locais; nunca no repositório.
2. **Sudo via password:** Ambos os servidores requerem `sudo` com password (não automatizar sem cuidado).
3. **Não misturar:** Terra = stateful dev, Metris = production. Não correr testes pesados em Metris.

## Cross-links

- [[docker-and-workspaces]] — Docker, local, metris, terra
- [[coingame]] — Project hub
- [[ci-cd]] — Pipeline e deploy
- [[credentials-and-security]] — Credenciais e segurança
- [[SOP-ssh-access-remote-servers]] — SOP de acesso SSH estruturado (passo-a-passo para Terra e Metris)
