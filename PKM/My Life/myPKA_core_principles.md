---
name: myPKA Core Principles and SSOT Architecture
description: "Consolidated knowledge from ICOR 32-lesson course. SSOT Golden Rule, GL-001/GL-002, team architecture, PKM routing, and all foundational principles."
key_element: myPKA
tags: [myPKA, ICOR, SSOT, GL-001, GL-002, principios, arquitectura, larry, pax, penn, nolan, mack, silas]
source: /home/master/hermes-stack/ICOR/myPKA_System/ (32 PDFs - ICOR_Licao_01 to ICOR_Licao_32)
status: active
created: 2026-09-01
---

# myPKA Core Principles — Consolidated Knowledge

## 1. SSOT Golden Rule (Regra de Ouro)

**Core Principle:** Every fact lives in exactly one file. Anywhere else that needs it uses a [[wikilink]]. No copy-paste. No duplication.

### Applications:
- **Naming rules** → GL-001 is the canonical source; all SOPs and contracts wikilink to it
- **Frontmatter schemas** → GL-002 defines schemas; no file invents ad-hoc fields
- **Team memory** → Session-logs feed static surfaces (SOPs/Workstreams/Guidelines)
- **CRM records** → One Person file, one Organization file, wikilinks from journal entries
- **Images** → Live once in PKM/Images/, embedded everywhere via ![[Images/...]]
- **Contracts** → Specialists link to SOPs, never restate them

### Why It Matters:
- When rules change, update once → all references inherit automatically
- Prevents "where is the real answer?" confusion
- Enables compound growth without coherence decay
- The team scales without rotting

---

## 2. GL-001 — File Naming Conventions

**Source of Truth:** `Team Knowledge/Guidelines/GL-001-file-naming-conventions.md`

### 9 Rules:

1. **kebab-case for slugs**
   - All lowercase, words separated by single hyphens
   - No underscores, no spaces, no camelCase
   - Examples: `morning-build-session`, `dr-schmidt`

2. **ISO date prefix on date-driven files**
   - Pattern: `YYYY-MM-DD-<slug>.<ext>`
   - Applies to: Journal, Images, session-logs, Deliverables

3. **Slug rules**
   - Derive from main subject in 2-5 words
   - People: `firstname-lastname` or `title-lastname`
   - Organizations: include context to disambiguate

4. **Folder naming for specialist contracts**
   - Pattern: `Team/<Name> - <Role>/AGENTS.md`
   - Literal space-hyphen-space (NOT kebab-case)

5. **INDEX.md is always UPPERCASE**
   - Sorts before lowercase (ASCII order) → floats to top

6. **SOP/WS/GL numbering**
   - Format: `SOP-NNN-<slug>.md`
   - NNN zero-padded to 3 digits, no gaps

7. **Image filename pattern**
   - `YYYY-MM-DD-<slug>.<ext>` under `PKM/Images/YYYY/MM/`

8. **Collision handling**
   - Append short qualifier: `dr-schmidt-lawyer.md`
   - Link via full path: `[[CRM/People/dr-schmidt-lawyer]]`

9. **Forbidden characters**
   - No em-dashes, slashes, colons, semicolons, `?`, `*`, emoji

### Wikilink Conventions:
- `[[filename]]` when unique in myPKA
- `[[path/filename]]` when collision risk or deeply nested
- `![[Images/YYYY/MM/YYYY-MM-DD-<slug>.<ext>]]` for images

---

## 3. GL-002 — Frontmatter Conventions

**Source of Truth:** `Team Knowledge/Guidelines/GL-002-frontmatter-conventions.md`

### Key Principles:
- **Markdown is canonical** — all other shapes are derived
- **Frontmatter is the contract** — YAML for facts, prose for stories
- **Schema discipline beats cleanup**
- **Imports are schema decisions** disguised as content moves
- **Migrations are documentation**

### Critical Rules:
1. NEVER overwrite myPKA files without explicit user approval
2. NEVER import without the WS-002 plan/approve gate
3. NEVER rename a field without explicit user approval
4. NEVER auto-fix user notes — audit, report, recommend
5. ALWAYS run frontmatter audit before SQLite conversion
6. ALWAYS write the import or migration report
7. NEVER mix structured data into body or narrative into frontmatter
8. NEVER invent ad-hoc YAML keys — edit GL-002 first
9. NEVER touch markdown myPKA during conversion (read-only)
10. NEVER establish API/OAuth/MCP connections solo — that's Mack's domain

### YAML Schemas (8 Entity Types):
| Entity | Required Fields |
|--------|----------------|
| Person | name, role, organization, how_we_met |
| Organization | name, sector, location |
| Goal | goal, what_shipped_means, why_exists, supporting_work |
| Habit | why_i_do_it, cadence, definition_of_done |
| Topic | what_it_covers, why_matters, current_pulse |
| Key Element | what_this_is, what_this_is_not |
| Project | finish_line, current_status, linked_goal |
| Document | document_type, location_physical, location_digital |

---

## 4. Team Architecture — The 6 Specialists

### Larry (Orchestrator, Librarian, Session-Log Author)
**Three duties, one role:**
1. **Orchestrator** — 6-step delegation protocol (Understand, Clarify, Match, Brief, Execute, Synthesize)
2. **Librarian** — SSOT enforcement at session close (fixes broken links, orphans, SSOT violations)
3. **Session-Log Author** — writes structured logs at session close

**Iron Rule:** Larry NEVER executes domain work. He delegates.

**Hire-Don't-Decline Rule:** When no specialist fits, route to Nolan to start a hire. Never refuse.

### Nolan (HR)
**Operating Principle:** "Open SOP-001 and follow it."

- Owns the hiring procedure (SOP-001)
- One clarifying question: "What specifically should this specialist own that no current specialist does?"
- Maintains agent-index (master routing table, O(1) lookup)
- Bootstrap exception named explicitly (Nolan was the only hire that skipped Pax)

### Pax (Senior Research Specialist)
**Operating Principle:** Never trust a single source. Triangulate. Present findings with explicit confidence levels.

**Four-Step Research Protocol:**
1. **Frame** — Restate question, break into 2-5 sub-questions, set scope
2. **Discover** — Source collection (prefer primary over secondary)
3. **Triangulate** — Cross-reference, mark confidence (High/Medium/Low)
4. **Synthesize** — Executive summary, key findings, evidence, methodology, limitations, recommendations

**Two Modes:**
- General research: answers questions with confidence tags
- Hire research: produces role spec (400-800 words) for new specialists

**Scope:** Pax flags PKM entities for Penn; does NOT write PKM directly.

### Penn (Journal Writer)
**Operating Principle:** Capture specialist — transforms any input into structured PKM.

**Three Input Types:**
1. **Text** → Journal entry at `PKM/Journal/YYYY/MM/YYYY-MM-DD-<slug>.md`
2. **Image** → Save to `PKM/Images/YYYY/MM/`, embed via ![[Images/...]]
3. **Audio** → Transcribe, then process as text

**PKM Routing Map (8 Entity Types):**
| Entity | Destination |
|--------|-------------|
| Person | PKM/CRM/People/ |
| Organization | PKM/CRM/Organizations/ |
| Topic | PKM/My Life/Topics/ |
| Habit | PKM/My Life/Habits/ |
| Project | PKM/My Life/Projects/ |
| Goal | PKM/My Life/Goals/ |
| Key Element | PKM/My Life/Key Elements/ |
| Document | PKM/Documents/ |

**Key Rules:**
- Auto-create YYYY/MM/ folders when missing
- Journal is APPEND-ONLY (never edit past entries)
- Image lives once in PKM/Images/, embedded everywhere
- Default to creating stubs (cost nothing, gain future cross-links)

### Mack (Automation Specialist)
**Operating Principle:** "Mack establishes the wire. Silas shapes what comes through it."

**Four Domains (all transport, none data shape):**
1. API connections — auth, rate limits, pagination
2. MCP server orchestration — Tana, Mem, Figma, Supabase
3. OAuth and credential flows — token rotation, refresh, scope
4. Webhooks and scheduled jobs — trigger contracts, raw payloads

**Critical Rules:**
- NEVER hardcode credentials (use .env or OS keychain)
- NEVER write to PKM/ directly
- ALWAYS verify webhook signatures
- ALWAYS implement retry with exponential backoff
- NEVER touch the database layer solo (Silas's domain)

**Handoff with Silas:**
- Mack fetches bytes → Silas shapes into well-structured notes
- File-based imports (zip): Mack not invoked, Silas runs end-to-end
- API imports: Mack establishes connection → Silas takes over
- MCP imports: Mack ensures server running → Silas queries through it

### Silas (Database Architect)
**Operating Principle:** "Schema is destiny."

**Three Responsibilities:**
1. **WS-002** — External knowledge import (mapping to myPKA structure)
2. **SOP-002** — Markdown-to-SQLite migration
3. **GL-002** — Frontmatter compliance auditing

**Critical Rules:**
- Markdown is canonical (SQLite is derived layer)
- NEVER overwrite myPKA without explicit approval
- NEVER import without plan/approve gate
- Reports drift, does NOT silently rewrite
- Local SQLite only (never cloud Postgres for myPKA storage)

---

## 5. Operations Library — Three Forms of Team Memory

### SOPs (Skills)
- **What:** Atomic step-by-step procedures
- **Default owner:** specialist who runs it most often
- **Any agent can invoke** — like Claude skills
- **Filename:** `SOP-NNN-<title>.md`

### Workstreams (Multi-Agent Compositions)
- **What:** Choreography that strings skills together
- **Emergent:** written when a pattern repeats across 3+ sessions
- **Wikilinks to SOPs and Guidelines** — never duplicates
- **Filename:** `WS-NNN-<title>.md`

### Guidelines (General Rules)
- **What:** Static rules every agent reads on every relevant action
- **Read, not run** — constraints on action, not checklists
- **Wikilinked by SOPs and Workstreams** — never restated
- **Filename:** `GL-NNN-<title>.md`

### Decision Rule:
> Is it a skill, a composition, or a general rule?
> - Skill (one specialist) → SOP
> - Composition (multi-specialist) → Workstream
> - General rule (read by all) → Guideline

### The Fourth Surface: Session-Logs
- **What:** Temporal memory — what the team DID and decided
- **Append-only**
- **Drives revisions** to the static three
- **Promotion path:** Pattern in 3 logs → candidate for SOP/WS/Guideline

---

## 6. PKM Architecture — My Life Five Concepts

### Five Routing Destinations (answers different "whats"):

1. **Key Elements** (stable dimensions)
   - Health, Family, Career, Wealth, Creative work
   - 4-7 files, no horizon, tended forever
   - Holds Goals (the test: does it hold Goals?)
   - NOT a tracker, streak, or number to optimize

2. **Goals** (outcomes with horizon)
   - Result + date + observable test ("definition of shipped")
   - Sits inside Key Element, driven by Habits, delivered by Projects
   - WITHOUT horizon = a wish
   - Needs leading indicator (self-correct 2 months early)

3. **Projects** (time-bound efforts with finish line)
   - Vehicle that delivers a Goal
   - Has scope and deliverables
   - Cross off when finished

4. **Habits** (ongoing rhythms with cadence)
   - NOT a Goal (no finish line), NOT a streak (no number to optimize)
   - 5 fields: why, cadence, definition of done, yardstick, linked work
   - Maintained, not finished

5. **Topics** (interest areas — signal layer)
   - Fluid, lightweight, deletable
   - NOT a Key Element (does NOT hold Goals)
   - "Current pulse" energy — alive, not curated
   - Graduate to Goals or settle into Key Elements

### Supporting Structure:
- **Documents** (universal, not under My Life)
  - Passports, contracts, certificates
  - Lives at PKM/Documents/, NOT under Key Element
  - SSOT split: metadata in markdown, assets in PKM/Images/

- **CRM** (People + Organizations)
  - Two subfolders (lifecycle differs)
  - People can leave Orgs; Orgs outlive People
  - Four files from one input (journal + person + org + image) = SSOT in motion

---

## 7. Routing and Delegation

### Entry Point: Larry Always
Every user input lands with Larry first. Never address specialists directly.

### Routing Cheatsheet:
| User says | Route to |
|----------|----------|
| "capture this", screenshot, voice note | Penn |
| "research", "find sources", "compare X vs Y" | Pax |
| "hire", "I need someone for", "audit team" | Nolan |
| "import my [tool] export" | Silas (via WS-002) |
| "set up MCP", "connect to API", "OAuth" | Mack |
| "convert to SQLite", "audit frontmatter" | Silas |
| "build/design X" (no specialist) | Nolan → start hire |

### Agent-Index (master routing table):
- Located at `Team/agent-index.md`
- O(1) lookup regardless of team size
- Single source of truth for "who is on the team right now"
- Bootstrap rule: if table drops below 3 rows → Bootstrap Mode

---

## 8. Session Management

### Close-Session Ritual (7 Steps):
1. Sweep open items → task store
2. Write session log → `Team Knowledge/session-logs/YYYY/MM/`
3. Librarian pass → fix SSOT violations, broken links, orphans
4. Optional insight graduation → propose SOP/WS/GL
5. Deliverables hygiene → triage
6. BKM updates → write new files
7. Commit and push → git

**Trigger:** "close this session", "wrap up", "log this session"
**Six surfaces fed at once:** Tasks, session-logs, journal, deliverables, BKM, git

### Librarian Pass (Larry's Duty):
- **SSOT violations** → pick canonical home, replace with wikilink
- **Broken wikilinks** → fix path, create stub, or flag
- **Orphaned files** → add to appropriate INDEX.md
- **Missing INDEX entries** → add new files
- **Fixes structural drift silently**; flags content drift to user

---

## 9. Task Management (v1.10+)

### Task as Resumption Point:
- Location = status (folder is state)
- Status folders: `tasks/open/`, `tasks/in-progress/`, `tasks/done/YYYY/MM/`, `tasks/cancelled/YYYY/MM/`

### Six Required Cross-References:
1. `linked_sops` — existing procedures
2. `linked_workstreams` — active arcs
3. `linked_guidelines` — standards
4. `linked_my_life` — Topics/Habits/Goals/Projects/Key Elements
5. `linked_session_logs` — birth sessions
6. `linked_journal_entries` — prior learning

### Lifecycle:
1. **Created** → `tasks/open/` (full frontmatter)
2. **Claimed** → git mv to `in-progress/`, set assignee
3. **Worked** → edits append to Updates section
4. **Closed** → fill Outcome, git mv to `done/` or `cancelled/`

### Blocked Pattern:
- Blocked tasks stay in `in-progress/` (NOT a separate folder)
- `blocked_reason` and `blocked_by` in frontmatter
- Prevents hiding from assignee's normal queue

---

## 10. Per-Agent Journals

### Purpose:
- Resumption surface for **learning** (not work)
- Catches durable but agent-scoped insights
- Lives inside each specialist's folder

### Template Sections:
1. **Context** — 2 sentences max
2. **What I learned** — direct, opinionated, no hedging
3. **When this applies** — concrete trigger conditions
4. **When this does NOT apply** — REQUIRED (self-bounds the entry)
5. **Evidence** — wikilinks to session-logs, tasks, commits

### Trigger Test:
> "Will I want this insight 3 months from now, halfway through a different task, and have it change what I do?"

### Wiring:
- Tasks, session logs, journal entries → closed three-way reference web
- Linked symmetrically before session log is committed

---

## 11. Key Architectural Decisions

### Why Three Duties in One (Larry)?
- Share session (input), myPKA-wide vision, audience at close
- Three separate specialists → routing duplicated, context split
- Three duties = smallest unit of librarianship for multi-specialist coherence

### Why Two Modes in One Specialist (Pax)?
- General research + hire research = same underlying skill
- Only the output template differs
- Splitting would duplicate methodology (SSOT violation) and force routing inference

### Why Mack-Silas Split?
- Transport (Mack) vs data shape (Silas)
- Prevents OAuth concerns from leaking into other contracts
- "Mack establishes the wire. Silas shapes what comes through it."

### Why Four My Life Concepts (not one)?
- Different answers to different "what" questions:
  - Key Elements: "what part of my life?" (dimension)
  - Goals: "what am I aspiring to?" (horizon)
  - Projects: "what am I in motion on?" (finish line)
  - Habits: "what am I repeating?" (cadence)
  - Topics: "what am I attending to?" (signal)
- Collapsing loses routing precision

### Why No Tasks Folder?
- Tasks live INSIDE Projects or in session logs
- My Life = stable concepts, not day-to-day to-do lists
- Task file = resumption point, not task list

### Why Date-Nesting for Journal/Images?
- Volume: 365+ entries/year, 1000+ images/year
- YYYY/MM keeps directories under ~30 files
- Concept folders stay FLAT (low volume, easy to scan)

### Why Documents at PKM Level?
- Universal reference (passports cut across all Key Elements)
- Would force arbitrary choice if nested under one Key Element
- Future specialists know where to look

---

## 12. Compliance Checklist (GL-001/GL-002/SSOT)

### GL-001 Compliance:
- [ ] All file names use kebab-case
- [ ] Date-driven files use YYYY-MM-DD prefix
- [ ] Specialist folders use `Name - Role` format
- [ ] INDEX.md files are UPPERCASE
- [ ] SOP/WS/GL files use 3-digit numbering
- [ ] Forbidden characters avoided
- [ ] Wikilinks use correct syntax

### GL-002 Compliance:
- [ ] Entity files have required frontmatter fields
- [ ] No ad-hoc YAML keys invented
- [ ] Structured data in frontmatter, prose in body
- [ ] Frontmatter audit runs before SQLite conversion
- [ ] Imports follow plan/approve gate

### SSOT Compliance:
- [ ] Every fact in one location
- [ ] Other locations use wikilinks
- [ ] No copy-paste of rules across files
- [ ] Session-logs feed static surfaces
- [ ] Image lives once, embedded everywhere
- [ ] Changes propagate via wikilinks (not duplication)

---

## 13. Bootstrap and Migration

### Scaffold Version:
- `.scaffold-version` at root → current version (e.g., v2.1.2)
- `CHANGELOG-MIGRATION.md` → machine-readable upgrade recipe

### Migration Principles:
- Purely additive (no existing files moved/renamed/modified)
- Each step idempotent and numbered
- Markdown SSOT survives all migrations
- Upgrade runnable by any LLM that reads CHANGELOG

### Bootstrap Exception:
- Named explicitly in Nolan's contract
- Nolan was only hire that skipped Pax research
- Prevents exception from becoming loophole

---

## 14. Closing Principles

### The Compounding Is Structural:
- Every Penn capture → future cross-link target
- Every session-log → pattern detection for SOP/WS/GL
- Every task → context one wikilink away
- Every agent journal entry → insight available to future sessions

### Why This Matters:
> "A wiki that is denser, not just larger."
> "The team gets better over time, not just larger."

### The Architecture IS the Consistency:
- Rules inherited via wikilinks
- Structure prevents drift
- Growth without coherence decay
- The team scales because the rules are embedded in architecture, not willpower

---

## Sources
- ICOR/myPKA_System/ICOR_Licao_01_Bilingue.pdf through ICOR_Licao_32_Bilingue.pdf
- myPKA-vault/Team Knowledge/Guidelines/GL-001-file-naming-conventions.md
- myPKA-vault/Team Knowledge/Guidelines/GL-002-frontmatter-conventions.md
- myPKA-vault/Team/Larry - Orchestrator/AGENTS.md
- myPKA-vault/Team/Penn - Journal Writer/AGENTS.md
- myPKA-vault/Team/Pax - Researcher/AGENTS.md
- myPKA-vault/Team/Nolan - HR/AGENTS.md
- myPKA-vault/Team/Mack - Automation Specialist/AGENTS.md
- myPKA-vault/Team/Silas - Database Architect/AGENTS.md
