---
agent_id: hermes
type: close-session
session_id: 20260905_144000
timestamp: 2026-09-05T14:40:00+01:00
linked_sops: []
linked_tasks: []
linked_workstreams: []
linked_guidelines: []
linked_deliverables:
  - url: https://github.com/edoardoboechat/android-security-agent/commit/9853695
    description: "fix: persist endpoint URL onPause (auto-save on app exit)"
created: 2026-09-05
---

# Session Log — 2026-09-05: Android Security Agent — URL Persist Fix & Nginx Proxy

## Summary
Fixed persistent URL save issue and configured public domain access via Nginx reverse proxy on Metris.

## Decisions
- Android Security Agent endpoint URL must persist on app pause/exit (not just on field focus lost).
- Public API access via `api.moneyback.com.br` — Nginx proxy on Metris (no Docker compose changes needed).
- Backup rule: .bak only for config files OUTSIDE projects (git handles project files).

## Actions Taken

### 1. Android Security Agent — onPause Fix
- **File:** `MainActivity.kt`
- **Change:** Added `onPause()` override to save `hermesEndpoint` to SharedPreferences immediately on app exit
- **Commit:** `9853695` — "fix: persist endpoint URL onPause (auto-save on app exit)"
- **Pushed:** ✅ `main` branch

### 2. Nginx Proxy — api.moneyback.com.br (Metris)
- **File:** `~/workspace/coingame/infra/nginx.conf` (Metris)
- **Backup:** `nginx.conf.bak` created
- **Added:** New `server` block for `api.moneyback.com.br` → `http://100.122.21.51:8642`
- **Validation:** `nginx -t` passed
- **Container restart:** `sudo docker compose restart nginx`
- **Tested:** `https://api.moneyback.com.br/v1/chat/completions` → HTTP 200 ✅

### 3. Existing Mappings Validated (all pass)
| URL | Before | After |
|---|---|---|
| moneyback.com.br | 200 | ✅ 200 |
| keycloak.moneyback.com.br | 200 | ✅ 200 |
| adminer.moneyback.com.br | 200 | ✅ 200 |
| redis.moneyback.com.br | 200 | ✅ 200 |
| rabbitmq.moneyback.com.br | 200 | ✅ 200 |
| mars.moneyback.com.br | 502 | ⚠️ 502 (pre-existing) |
| hermes.moneyback.com.br | 302 | ✅ 302 |
| api.moneyback.com.br (new) | — | ✅ 200 |

### 4. Memory Updated
- Rule added: "Backups (.bak) only for config files OUTSIDE projects — git handles project files"

## New Endpoint for Android App
**URL:** `https://api.moneyback.com.br/v1/`

## Risks
- `mars.moneyback.com.br` already returning 502 (pre-existing, not caused by changes)
- No other risks identified

## Related Files
- `~/hermes-stack/projects/android-security-agent/app/src/main/java/com/agent/security/MainActivity.kt` — onPause fix
- `~/hermes-stack/myPKA-vault/Team Knowledge/Guidelines/GL-009-infrastructure-servers.md` — Metris workspace structure
- Metris: `~/workspace/coingame/infra/nginx.conf` — new `api.moneyback.com.br` block
- Metris: `~/workspace/coingame/infra/nginx.conf.bak` — backup before changes
