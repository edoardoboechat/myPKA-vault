---
agent_id: hermes
session_id: 2026-08-29-workspace-migration
timestamp: 2026-08-29T17:50:00Z
type: close-session
linked_sops: [SOP-write-session-log]
linked_workstreams: []
linked_guidelines: [GL-001-file-naming-conventions, GL-005-llm-agnostic-portable-core]
linked_tasks: []
linked_journal_entries: []
---

# Workspace Migration & SSOT Cleanup

## Context

Edoardo identified two issues that required SSOT correction: (1) 55 Playwright screenshots in `/home/master/` instead of the project print folder, and (2) the entire `playwrite` folder was in the wrong location (`/home/master/workspace/playwrite/` instead of `/home/master/hermes-stack/playwrite/`). Edoardo clarified that the workspace is `/home/master/hermes-stack/` and `playwrite` should sit alongside `projects` and `library`.

## What we did

### Screenshot fix
- Moved 55 PNG files from `/home/master/` to `/home/master/hermes-stack/playwrite/coingame/prints/`
- Updated `playwright-testing.md` with strict rule: never in `/home/master/`
- Updated `validate_pilot01.py` as model script with `PRINTS_DIR` pattern
- Session log written: `2026-08-29-17-35_playwright-screenshot-fix.md`

### Workspace path migration
- Created `/home/master/hermes-stack/playwrite/` directory
- Moved entire `playwrite/` folder to new location
- Confirmed `/home/master/workspace/` is now empty (removed)
- Updated 7 vault files with new path (`sed` replacement of `~/workspace/playwrite` → `~/hermes-stack/playwrite`)
- Updated 4 skills with new path (via `sed`)
- Updated `validate_pilot01.py` script

### SSOT consistency fix
- Detected and corrected: `docker-and-workspaces.md` was conflating servers and workspaces in one table
- Rewrote `docker-and-workspaces.md` with 3 clear sections: Ambientes Locais, Servidores Remotos, Ambientes de Execução
- Fixed typo "Statef ul" → "Stateful"
- Updated `infrastructure-servers.md` with clear LAN vs Tailscale IP distinction for Terra
- Memory updated: Playwright path corrected from `~/workspace/playwrite/` to `~/hermes-stack/playwrite/`

### SSOT sweep results
- 0 remaining references to `/home/master/workspace`
- 0 remaining references to `~/workspace/playwrite` in vault or skills
- 0 remaining inconsistencies between MEMORY.md, vault topics, and skills

## Decisions

- **Workspace = `/home/master/hermes-stack/`** — definitive. `playwrite` sits alongside `projects/` and `library/`
- **Workspace vs Server distinction:** Local environments (projects, playwright, library) vs remote servers (Terra, Metris). Different concept — never conflate.
- **Terra has two IPs:** `192.168.10.138` (LAN) and `100.122.21.51` (Tailscale). Same server. Use Tailscale from outside LAN.
- **Metris still needs mapping:** IP, hostname, and exact role not yet confirmed. Flagged for first-time interaction.

## SSOT check

- No duplicates introduced
- All paths consistent: MEMORY.md = vault = skills = scripts
- GL-001 naming maintained
- GL-005 compliance maintained (no harness names)

## Open threads

- Confirm Metris: IP, hostname, services, role
- First interaction with Metris should update `infrastructure-servers.md`

## Cross-links

- [[playwright-testing]] — updated with new path and print convention
- [[docker-and-workspaces]] — rewritten with clear sections
- [[infrastructure-servers]] — updated with LAN vs Tailscale distinction
- [[coingame]] — lesson added for screenshots rule
