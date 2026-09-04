---
agent_id: hermes
session_id: 2026-08-29-server-discovery
timestamp: 2026-08-29T18:30:00Z
type: close-session
linked_sops: [SOP-ssh-access-remote-servers]
linked_workstreams: []
linked_guidelines: [GL-001-file-naming-conventions, GL-005-llm-agnostic-portable-core]
linked_tasks: []
linked_journal_entries: []
---

# Server Discovery & SSH Knowledge Indexing

## Context

Edoardo asked Hermes to SSH into metris and terra servers and list their contents. This revealed that SSH access knowledge was not indexed in myPKA — it only lived in `~/.ssh/config`.

## What we did

### Server access
- Discovered SSH config at `~/.ssh/config`
- Accessed **Terra**: `ssh terra` → `100.122.21.51`, user `openclaw`, key `id_ed25519`
- Accessed **Metris**: `ssh metris` → `metris.com.br`, user `openclaw`, key `metris_key`

### Terra inventory
- Workspace: `docker-compose_infra.yml`, `.env`, `infra/`
- Docker: keycloak:22.0.1, adminer, postgres:15, rabbitmq, redis (all up 5+ days)

### Metris inventory
- Workspace: symlink to `/root/workspace`, coingame git repo
- Docker: coingame:latest (ghcr.io), nginx:alpine, keycloak, postgres, redis, rabbitmq (prod backend up 30h)
- Public URL: `https://metris.com.br` via nginx on ports 80/443

### Vigil SSOT enforcement
- Delegated to Vigil: store SSH access knowledge in myPKA
- Created `SOP-ssh-access-remote-servers.md` (6.4KB) with full procedure
- Updated `infrastructure-servers.md` with concrete server inventory
- Updated `MEMORY.md` with SSH access instructions
- Wrote session logs for discovery and Vigil work

## Realignments

- Metris = production server (not just monitoring) — corrected earlier assumption
- Terra = development infrastructure server
- SSH access knowledge now formally indexed (not just in ~/.ssh/config)

## SSOT check

- No duplicates introduced
- SSH knowledge: vault (SOP + topic) + MEMORY.md
- Server inventory: vault (infrastructure-servers.md + coingame.md)

## Cross-links

- [[infrastructure-servers]] — full server inventory
- [[docker-and-workspaces]] — Terra + Metris distinction
- [[coingame]] — production info
- [[SOP-ssh-access-remote-servers]] — formal SSH procedure
