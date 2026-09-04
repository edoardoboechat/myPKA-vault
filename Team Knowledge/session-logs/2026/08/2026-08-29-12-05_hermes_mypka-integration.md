---
agent_id: hermes
session_id: 2026-08-29-hermes-mypka-integration
timestamp: 2026-08-29T12:05:00Z
type: close-session
linked_sops: [SOP-001-how-to-add-a-new-specialist, SOP-write-session-log]
linked_workstreams: []
linked_guidelines: [GL-005-llm-agnostic-portable-core, GL-001-file-naming-conventions, GL-002-frontmatter-conventions]
linked_tasks: []
linked_journal_entries: []
---

# User Manual + Vigil Onboarding + Shard Delegation Pattern

## Context

Edoardo asked for a user-facing manual, then asked to create a new agent (Vigil — Work Guardian), then pushed back on a flawed delegation approach ("passing the myPKA to all sub-agents is wrong") which led to the Shard Pattern. This is the second close-session log for the mypka-integration session_id, covering the work after the first log.

## What we did

- **User manual** — wrote `PKM/Documents/hermes-mypka-user-manual.md` (10094 bytes). Explains the 4 domains, semantics, day-to-day flow, PKM structure, memory rules, skill criteria, and coingame-specific guidance.
- **Vigil — Work Guardian** — new specialist hired following SOP-001:
  - Research brief: `Deliverables/2026-08-29-work-vigil-hire-research.md`
  - Contract: `Team/Vigil - Work Guardian/AGENTS.md`
  - Claude shim: `.claude/agents/vigil.md`
  - Hermes skill: `system/vigil-work-guardian`
  - Routing table updated: `Team/agent-index.md`
  - Three phases: pre-work gate, SSOT watch, post-work cleanup
- **Shard Pattern** — corrected the flawed approach of passing the full vault to all sub-agents. Created 7 nano-shards (21-39 lines each) in `system/mypka-hermes-integration/shims/`:
  - `larry.md`, `pax.md`, `penn.md`, `mack.md`, `silas.md`, `nolan.md`, `vigil.md`
  - Each shard is a pointer to the full AGENTS.md contract, not a copy
  - Updated main `SKILL.md` with "Sub-agent Delegation — Shard Pattern" section including 3 example delegations (Pax research, Penn capture, Mack automation)
- **Memory consolidation** — replaced 89% memory entry with shorter version: "myPKA vault: /home/master/hermes-stack/myPKA-vault/. 7 agents: Larry, Pax, Penn, Mack, Silas, Nolan + Vigil (Work Guardian, hired 2026-08-29). Skills: mypka-hermes-integration + vigil-work-guardian. SSOT: each fact one place (vault/memory/skills/code). Session-log triggers: wrap up, close session, we're done."

## Decisions

- **Identity layering confirmed:** Hermes Agent primary. myPKA mental models (Larry, Pax, Vigil) are role overlays, never identity substitutes.
- **Shard Pattern adopted:** sub-agents get only their nano-shard + task-specific context, never the full vault. Preserves tokens, preserves SSOT, matches what Claude Code does with `.claude/agents/<slug>.md`.
- **Vigil is auto-active in background:** no user invocation needed; loads on session start and on triggers (let's start, wrap up, where does this go).
- **GL-005 compliance preserved:** no harness names in vault; skill text uses "the host", "the agent runtime", "your assistant" patterns.

## Insights

- The user caught a real architectural error (passing the full vault to sub-agents) that I had proposed. This is exactly the kind of course-correction the myPKA framework is designed to surface.
- The Shard Pattern is a Hermes-specific adaptation: the myPKA contract is in the vault, but the binding to the Hermes runtime happens through nano-shards in the skill directory. This keeps the vault portable (GL-005) while making the runtime binding lightweight.
- A 21-39 line shard is enough to give a sub-agent its identity, its tools, and a pointer to its full contract. Anything more is duplication.

## Realignments

- **User correction:** "Não parece ser o correcto, passar o myPKA para todas as sessões de sub agentes?" — User pushed back on the original delegation pattern (passing the full vault). Result: Shard Pattern implemented. This is a durable principle: the orchestrator keeps the vault; workers get only their shard.

## Open threads

- myPKA Cockpit (Node.js server at Expansions/mypka-cockpit/) not yet started
- Coingame task system not yet mirrored from Hermes `todo` to vault `tasks/`
- No first end-to-end test of the Shard Pattern with a real `delegate_task` call yet
- Skill `hermes-mypka-manual` not yet created (the manual exists as a PKM document, but no Hermes skill points to it for auto-loading on demand)

## Next steps

- When the user first requests a real delegation (research, capture, automation), use the Shard Pattern for real
- Consider creating a skill that auto-loads the user manual on demand
- Start myPKA Cockpit when user requests

## Cross-links

- [[2026-08-29-11-37_hermes_mypka-integration]] — first log for this session
- [[Vigil - Work Guardian/AGENTS]] — new specialist
- [[SOP-001-how-to-add-a-new-specialist]] — followed for Vigil's hiring
