---
agent_id: hermes
session_id: 2026-08-29-metris-discovery
timestamp: 2026-08-29T18:05:00Z
type: realignment
linked_sops: []
linked_workstreams: []
linked_guidelines: [GL-001-file-naming-conventions, GL-005-llm-agnostic-portable-core]
linked_tasks: []
linked_journal_entries: []
---

# Metris & Terra Server Discovery

## Context

Edoardo asked to ssh into both metris and terra servers, run `ls -la`, and list results. This triggered a realignment of the `infrastructure-servers.md` topic with actual server state.

## What we did

### Discovery
- Discovered SSH config at `~/.ssh/config`:
  - `Host metris` → `metris.com.br` user `openclaw` key `~/.ssh/metris_key`
  - `Host terra` → user `openclaw` key `~/.ssh/id_ed25519`
- Successfully accessed both servers

### Terra (`100.122.21.51`)
- **Workspace:** `~/workspace/` (regular dir)
  - `docker-compose_infra.yml`
  - `.env`
  - `infra/`
- **Docker containers (5):** keycloak:22.0.1, adminer, postgres:15, rabbitmq, redis
- **All services up 5 days**

### Metris (`metris.com.br`)
- **Workspace:** `~/workspace` (symlink → `/root/workspace`)
  - `.git/`, `.gitignore`
  - `coingame/` (git cloned)
- **Docker containers (8):** coingame:latest (ghcr.io), adminer, nginx, postgres, redis, keycloak, redis_commander, rabbitmq
- **Production backend running 30 hours**
- **Uses snap.docker (Ubuntu)**

### Updates to vault
- `infrastructure-servers.md` rewritten with:
  - Full inventory of both servers
  - Container list with images, ports, state
  - System services
  - SSH access rules
  - Terra vs Metris comparison table
- `coingame.md` updated with production info (Metris URL, Docker registry)

## Realignments

- **Metris is the production server** (not just monitoring) — corrected from earlier assumption
- **Terra is the development infrastructure** (not a copy of prod)
- **Both servers have Keycloak** but Terra's is for dev (`aether-quest` realm), Metris's is for prod
- **Metris runs nginx as reverse proxy** (ports 80/443) — public-facing
- **Backend coingame in prod** is `ghcr.io/edoardoboechat/coingame:latest` — confirming CI/CD pipeline exists
- **Workspace dirs**:
  - Terra: regular `~/workspace/`
  - Metris: `~/workspace` is symlink to `/root/workspace`

## SSOT check

- All previous "Metris = suporte/monitorização (por confirmar)" replaced with concrete data
- No duplicates introduced
- New info correctly linked in coingame.md

## Cross-links

- [[infrastructure-servers]] — rewritten with full inventory
- [[coingame]] — added production section
- [[docker-and-workspaces]] — linked (Terra + Metris)
