---
agent_id: hermes
session_id: 2026-08-29-playwright-screenshot-fix
timestamp: 2026-08-29T17:35:00Z
type: realignment
linked_sops: []
linked_workstreams: []
linked_guidelines: [GL-001-file-naming-conventions]
linked_tasks: []
linked_journal_entries: []
---

# Playwright Screenshots — SSOT Violation Fixed

## Context

Edoardo spotted 55 screenshots scattered in `/home/master/` (wrong location) and identified that they should be inside `~/hermes-stack/playwrite/coingame/prints/` following the project isolation principle.

## What we did

- Identified 55 PNG files in `/home/master/` that were Playwright screenshots
- Created `~/hermes-stack/playwrite/coingame/prints/` directory
- Moved all 55 screenshots to the correct location
- Updated `PKM/My Life/Topics/playwright-testing.md` with the new convention (strict rule: never in `/home/master/`)
- Updated `validate_pilot01.py` as a model script with the correct pattern (`PRINTS_DIR`, `os.path.join`)
- Updated `PKM/My Life/Projects/coingame.md` with a new lesson: "Screenshots Playwright: always in `~/hermes-stack/playwrite/coingame/prints/`"

## Realignment

- **Rule established:** All Playwright screenshots must go to `~/hermes-stack/playwrite/coingame/prints/`. Never in `/home/master/`, `/tmp/`, or other folders.
- **Pattern for scripts:** Use `PRINTS_DIR = os.path.expanduser("~/hermes-stack/playwrite/coingame/prints")` and `os.path.join(PRINTS_DIR, "filename.png")`

## Cross-links

- [[playwright-testing]] — updated with new convention
- [[coingame]] — lesson added
