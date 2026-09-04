---
agent_id: hermes
session_id: 2026-08-29-hermes-mypka-integration
timestamp: 2026-08-29T11:37:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: [GL-005-llm-agnostic-portable-core]
linked_tasks: []
linked_journal_entries: []
---

# myPKA + Hermes Agent Integration

## Context

Edoardo asked for a thorough integration of the myPKA vault with Hermes Agent. The vault at `/home/master/hermes-stack/myPKA-vault/` was read in full across 8 stages: foundation docs, team contracts, Team Knowledge (SOPs, Workstreams, Guidelines, Templates, session-logs, tasks), PKM structure, and PKM content examples.

## What we did

- Read all foundation docs: AGENTS.md, ADAPTER-PROMPT.md, CLAUDE.md, CHANGELOG.md (v5.5.1), README.md, CONTRIBUTING.md, DERIVATIVES.md, WAY-FORWARD.md
- Read all 6 specialist AGENTS.md contracts: Larry, Pax, Penn, Mack, Silas, Nolan
- Read all Team Knowledge: SOPs (10 files), Workstreams (4 files), Guidelines (4 files: GL-001/002/004/005), Templates (8 entity templates), session-logs (_template, README), tasks (INDEX, _template, EXAMPLE)
- Read all PKM structure: PKM/INDEX, My Life (5 subsections), CRM, Journal, Documents, Images, Weekly Reports
- Synthesized complete mapping table: 22 myPKA concepts → Hermes tools/patterns
- Rebuilt skill `mypka-hermes-integration` (was a stub, now comprehensive with vault paths, role mappings, GL-001/002 rules, SSOT, session-close protocol, task system)
- Validated 3 scenarios: session-log template (READ OK), GL-002 (READ OK), all 8 entity templates (READ OK)
- Coingame: merged PR #18, copied JAR to `/home/master/coingame-backend-latest.jar`, closed backend
- Coingame: fixed LandingScreen layout bug (hero title inside TopBar causing 318px height → removed it, hero uses gap:24px)

## Decisions

- **Identity layering:** Hermes Agent remains primary identity. Larry mental model applies as orchestrator overlay in vault context only. Never say "I'm Larry" to the user.
- **SSOT enforcement:** Coingame knowledge → Hermes memory. Personal knowledge → vault. Procedures → Hermes skills. Project code → /home/master/hermes-stack/projects/
- **Task system:** Use Hermes `todo` tool for tracking; mirror to vault tasks/ via write_file when crossing contexts.
- **Session-log:** Write to vault on "wrap up"/"close session" triggers. Template from session-logs/_template.md.
- **Portability:** GL-005 compliance — no harness names in vault files.

## Insights

- myPKA and Hermes are highly compatible architecturally: SSOT, skills/SOPs, delegation patterns, markdown, frontmatter — all map 1:1 between the two systems.
- The myPKA vault at this installation is complete (v5.5.1, 2026-08-08) with a full 6-agent team, 10 SOPs, 4 Workstreams, 4 Guidelines, 8 entity templates, and a PKM with seeded examples.
- The adapter was built for Claude Code/Codex/Gemini/Cursor — Hermes is effectively the 5th host. The integration layer (skill `mypka-hermes-integration`) bridges the two without modifying any vault file.
- The coingame LandingScreen bug was a perfect real-world test case: hero title was rendered inside TopBar.jsx (line 67, `!hasSession` condition), causing 318px topbar height. Removed the h1 — title belongs only in LandingScreen.jsx.
- `mypka-hermes-integration` skill loaded automatically on vault detection or myPKA keywords. Trigger words: myPKA, Larry, Pax, Penn, session-log, close session, PKM, CRM, SOP, frontmatter, wikilinks, etc.

## Realignments

- None this session.

## Open threads

- myPKA Cockpit (Node.js server at Expansions/mypka-cockpit/) not yet started — requires TLS + PIN setup per myPKA Cockpit skill.
- Coingame task system not yet mirrored from Hermes `todo` to vault tasks/
- Session-log write cycle tested end-to-end (this log is the first integration log)

## Next steps

- Start myPKA Cockpit when user requests
- Mirror coingame tasks to vault tasks/ on next coingame session
- Consider creating Hermes skills for coingame-specific SOPs (coingame-local-run, coingame-validation-workflow already exist)

## Cross-links

- (first integration session — no prior logs to link)
