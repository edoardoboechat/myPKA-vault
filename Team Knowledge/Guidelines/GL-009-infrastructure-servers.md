---
id: GL-009
title: Infrastructure Servers — Terra & Metris
status: active
created: 2026-09-04
updated: 2026-09-04
linked_projects: []
linked_topics:
  - infrastructure-servers
  - ci-cd
  - docker-and-workspaces
  - credentials-and-security
tags:
  - infra
  - servers
  - ssh
  - terra
  - metris
  - remote-access
version: "1.0"
---

# GL-009 — Infrastructure Servers (Terra & Metris)

**Global guideline.** This knowledge is not bound to any single project. It applies to every agent in the myPKA team that needs to access remote infrastructure.

---

## 1. Server Overview

The infrastructure is split across two remote servers with distinct roles:

| Aspect | Terra | Metris |
|---|---|---|
| **Purpose** | Development + identity infrastructure | Production / Staging |
| **Network** | Tailscale (100.122.21.51) + LAN (192.168.10.138) | Internet (metris.com.br) |
| **Backend** | No | Yes (Docker, ghcr.io) |
| **Frontend** | No | Yes (Nginx 80/443) |
| **CI/CD** | Manual (docker-compose) | Automatic (GitHub Container Registry) |
| **Workspace** | `~/workspace/` (regular dir) | `~/workspace` (symlink → `/root/workspace`) |

---

## 2. Access Configuration

### SSH Configuration (`~/.ssh/config`)

```bash
# Terra — infraestrutura de rede e serviços de identidade
Host terra
    HostName 100.122.21.51
    User openclaw
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking accept-new
    ServerAliveInterval 60

# Metris — produção / staging
Host metris
    HostName metris.com.br
    User openclaw
    IdentityFile ~/.ssh/metris_key
    StrictHostKeyChecking accept-new
    ServerAliveInterval 60
```

### Prerequisites

1. **SSH Keys exist:**
   ```bash
   ls -la ~/.ssh/id_ed25519     # Terra
   ls -la ~/.ssh/metris_key     # Metris
   ```
   If missing, create:
   ```bash
   ssh-keygen -t ed25519 -C "openclaw@terra" -f ~/.ssh/id_ed25519
   ssh-keygen -t ed25519 -C "openclaw@metris" -f ~/.ssh/metris_key
   ```

2. **SSH Agent active:**
   ```bash
   ssh-add ~/.ssh/id_ed25519
   ssh-add ~/.ssh/metris_key
   ```

3. **Connectivity check:**
   ```bash
   ping -c 1 100.122.21.51        # Terra (Tailscale)
   ping -c 1 metris.com.br        # Metris
   ```

---

## 3. Server Details

### Terra

| Field | Value |
|---|---|
| **SSH alias** | `ssh terra` |
| **Hostname** | `100.122.21.51` (Tailscale) / `192.168.10.138` (LAN) |
| **User** | `openclaw` |
| **SSH Key** | `~/.ssh/id_ed25519` |
| **Role** | Development + identity infrastructure |
| **Workspace** | `~/workspace/` |
| **Backend port** | 8443 (SSL) |
| **Spring profile** | `local` → `100.122.21.51:8443` |

**Active Docker containers:**
- `aether_keycloak` (8080, 8443) — `quay.io/keycloak/keycloak:22.0.1`
- `aether_adminer` (8081) — `adminer:latest`
- `aether_db` (5432) — `postgres:15-alpine`
- `aether_rabbitmq` (5672, 15672) — `rabbitmq:3-management`
- `aether_redis` (6379) — `redis:alpine`

**Keycloak realm:** `aether-quest`
**Users:** `admin`, `pilot01`, `hunterX` (password `Hitachi$20261`)
**Shared credentials:** `changeit` (Postgres, RabbitMQ, Keycloak Admin)

**System services:** Docker, Tailscale, SSH, cron, systemd-networkd, rsyslog, ModemManager, unattended-upgrades, udisks2

### Metris

| Field | Value |
|---|---|
| **SSH alias** | `ssh metris` |
| **Hostname** | `metris.com.br` |
| **User** | `openclaw` |
| **SSH Key** | `~/.ssh/metris_key` (dedicated — never use `id_ed25519`) |
| **Role** | Production / Staging |
| **Workspace** | `~/workspace` → symlink to `/root/workspace` |

**Workspace structure (verified 2026-09-04):**

```
~/workspace (symlink) → /root/workspace
├── .git/                    # Git repository
├── .gitignore
└── coingame/                # Coingame project root
    ├── .env                 # Environment variables (credentials)
    ├── .env.example         # Template
    ├── .github/             # GitHub workflows
    ├── .gitignore
    ├── .idea/               # IntelliJ IDE files
    ├── README.md
    ├── backend-spring/      # Spring Boot backend
    ├── copilot/             # Copilot integration
    ├── docker-compose-dev.yaml
    ├── docker-compose.yml   # Production Docker compose
    ├── docs/                # Documentation
    ├── frontend-react-pwa/  # React PWA frontend
    └── infra/               # Infrastructure configs
```

**Active Docker containers:**
- `aether_backend` — `ghcr.io/edoardoboechat/coingame:latest`
- `aether_adminer` (8080) — `adminer:latest`
- `aether_nginx` (80, 443) — `nginx:alpine`
- `aether_postgres` (5432) — `postgres:15-alpine`
- `aether_redis` (6379) — `redis:alpine`
- `aether_keycloak` (8080, 8443) — `quay.io/keycloak/keycloak:22.0.1`
- `aether_redis_commander` (8081) — `rediscommander/redis-commander:latest`
- `aether_rabbitmq` (5671-5672, 15672) — `rabbitmq:3-management`

**System services:** snap.docker.dockerd, snapd, chrony, SSH, cron, fwupd, systemd-networkd, rsyslog, ModemManager

**CI/CD:** GitHub Container Registry → automatic deploy

---

## 4. Workspace File Structure

### Terra (`~/workspace/`)
```
~/workspace/
├── docker-compose_infra.yml    # Docker compose for infra
├── .env                        # Environment variables (credentials)
├── infra/                      # Infrastructure subdirectories (5)
└── coingame/                   # (if present) coingame code
```

### Metris (`~/workspace` → `/root/workspace`)
```
~/workspace/  (symlink → /root/workspace)
├── .git/                       # Git repository
├── .gitignore
├── coingame/                   # Coingame code (cloned from repo)
│   ├── .env
│   ├── .env.example
│   ├── .github/
│   ├── .gitignore
│   ├── .idea/
│   ├── README.md
│   ├── backend-spring/
│   ├── copilot/
│   ├── docker-compose-dev.yaml
│   ├── docker-compose.yml
│   ├── docs/
│   ├── frontend-react-pwa/
│   └── infra/
└── (other project files)
```

**Verification command:**
```bash
ssh metris "ls -la ~/workspace"
ssh metris "ls -la /root/workspace"
ssh metris "ls -la /root/workspace/coingame"
```

---

## 5. Common Commands (Inside SSH Session)

```bash
# List Docker containers
docker ps
docker ps -a

# View logs
docker logs <container_name> --tail 50 -f

# Services status
sudo systemctl list-units --type=service --state=running

# Disk usage
df -h

# Memory and CPU
free -h && top -bn1 | head -10

# Restart Terra infra
cd ~/workspace && docker compose -f docker-compose_infra.yml down && docker compose -f docker-compose_infra.yml up -d

# View backend logs (Metris)
docker logs aether_backend --tail 100 -f
```

---

## 6. Security Rules

1. **Credentials never in commits** — `.env` local only, never in repo
2. **Sudo requires password** — both servers require `sudo` with password; don't automate without confirming safety
3. **Don't mix environments** — Terra = dev/infra, Metris = production/staging. No heavy tests in Metris
4. **Verify before acting** — always run `docker ps` + `docker logs` before restart or modification
5. **Metris uses dedicated key** — use `~/.ssh/metris_key`, never `id_ed25519`
6. **SSH keys never versioned** — private keys stay in `~/.ssh/` local only
7. **Keep sessions short** — use `tmux` or `screen` if persistence is needed

---

## 7. Related References

- [[SOP-ssh-access-remote-servers]] — Step-by-step SSH access procedure
- [[infrastructure-servers]] — Detailed server state (Topic)
- [[docker-and-workspaces]] — Docker and workspace patterns
- [[ci-cd]] — CI/CD pipeline (relevant for Metris)
- [[credentials-and-security]] — Credential management
- [[GL-007-hermes-services-map]] — Hermes services map
- [[GL-008-hermes-troubleshooting]] — Hermes troubleshooting guide

---

*Created: 2026-09-04 by Hermes Agent (as Larry)*
*This is a global guideline — not bound to any project. All agents should reference this when accessing Terra or Metris.*