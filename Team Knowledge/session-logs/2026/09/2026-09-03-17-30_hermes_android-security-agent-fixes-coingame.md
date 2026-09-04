---
agent_id: hermes
type: close-session
session_id: 20260823_131830_14d08e77
timestamp: 2026-09-03T17:30:00+01:00
linked_sops: []
linked_tasks: []
linked_workstreams: []
linked_guidelines: []
linked_journal_entries: [PKM/Journal/2026/09/2026-09-03-android-security-agent-and-coingame.md]
created: 2026-09-03
---

# Session Log — 2026-09-03: Android Security Agent Fixes & Coingame Admin Cockpit

## Context
- **User:** Edoardo Boechat Abreu
- **Topics:** Android Security Agent trusted sources bugfix (case + Unicode accents), SOUL.md content confusion fix, wrap-up git check rule added, Coingame bearer token auth commit & push.

## What We Did
1. **Android Security Agent Bugfix:**
   - Identified and fixed trusted source filtering failure caused by SQLite `LOWER()` not supporting Unicode accents (e.g. "Condomínio" vs "Condominio").
   - Added `removeAccents()` extension using `Normalizer.Form.NFD` in `EventLogAdapter`, `AppMessageInterceptor`, and `SmsInterceptor`.
   - Added `COLLATE NOCASE` to SQLite DAO queries (`TrustedSourceDao`).
   - Committed (`104683b`) and pushed to GitHub (`edoardoboechat/android-security-agent`).

2. **SOUL.md & Routing Security:**
   - Fixed issue where the mention of `ag-sec-app` inside message content/images triggered Guardian Mode.
   - Updated `SOUL.md` and `android-security-agent` skill to strictly require `source: "ag-sec-app"` in the REST payload body.

3. **Wrap-up Protocol Enhancement:**
   - Added Step 0 (git uncommitted work check) to `vigil-work-guardian` and `mypka-hermes-integration` skills.
   - Now Hermes automatically checks for uncommitted changes across project repos and asks the user before closing.

4. **Coingame Commit & Push:**
   - Committed (`da607ab`) and pushed changes for Coingame admin cockpit bearer token auth (DB migration V2, backend service/controller updates, React frontend admin screen).

## Decisions
- Trusted sources must be normalized to ASCII lowercase on insertion and check.
- Guardian Mode routing is strictly payload-based (`source` field), never content-based.
- Wrap-up protocol now enforces git status checks.
- **Decision added (17:55):** Trusted source match is now **substring** (`LIKE %sender%`) instead of equality. This handles WhatsApp's grouped notifications like `"Edo (10 msgs): ~Pessoa"` matching against trusted `"Edo"`.

## Open Threads
- None. All tasks completed and pushed.
- User needs to install the new APK (`app-debug.apk`) on their Android device.
