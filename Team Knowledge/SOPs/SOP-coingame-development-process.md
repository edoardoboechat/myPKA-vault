---
id: SOP-coingame-development-process
title: Coingame Development Process
default_owner: hermes
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_topics:
  - sdlc
  - ci-cd
  - ddd-software-design
  - clean-code-solid
references:
  - GL-001-file-naming-conventions
  - GL-002-frontmatter-conventions
  - GL-004-task-resource-linking
  - GL-006-command-boundaries-git-and-gh
---

# SOP-coingame-development-process

> **Default owner:** Hermes (the user can override at any time).
> **Reusable by any agent** that works on the coingame project.

## Triggered by

- User starts work on coingame
- User says "vou mexer no coingame", "let's work on coingame"
- Any task touching `/hermes-stack/projects/coingame/`

## Purpose

Standardize the coingame development process so that every work session follows the same gates, validation, and documentation rituals. This SOP codifies what has been practice since v1 of the project.

## Steps

### 1. Context loading (Pre-work)

Before any change:

1. Read `PKM/My Life/Projects/coingame.md` — project hub
2. Read `PKM/My Life/Topics/sdlc.md` — process overview
3. Read `PKM/My Life/Topics/ddd-software-design.md` — architecture
4. Read `PKM/My Life/Topics/clean-code-solid.md` — code quality rules
5. Load skill `coingame-git-governance` — git flow strict
6. Load skill `coingame-validation-workflow` — validation steps
7. Check git state: `git status`, `git log -3 --oneline`
8. Check if backend is running: `ps aux | grep -i coingame`

### 2. Branching

- **Always** create a new branch from `develop`, never from `master`
- Naming:
  - `feat/<slug>` — new features
  - `fix/<slug>` — bug fixes
  - `chore/<slug>` — maintenance tasks
- Slug follows GL-001: kebab-case, ASCII, 2–5 words

```bash
git checkout develop && git pull
git checkout -b feat/<slug>
```

### 3. Development

- Follow DDD: domain logic in domain layer, not in controllers
- Follow Clean Code: small functions, expressive names, no magic numbers
- Frontend: CSS Modules, dark theme via CSS vars
- Toast position: bottom-right (`bottom: 24px; right: 24px`)
- Inputs: always `var(--surface-card)` for dark theme
- Paleta: dark navy + teal/cyan, no white backgrounds

### 4. Validation (the gate)

Before any commit:

```bash
# Backend
mvn -f backend-spring/pom.xml clean package -DskipTests

# Frontend
cd frontend-react-pwa && npm run build
```

If UI changed, run Playwright validation:

```bash
python3 ~/hermes-stack/playwrite/coingame/<script>.py
```

Capture screenshots, vision-analyze if layout changed.

### 5. Commit (user approval required)

**Never commit without explicit user approval.**

```bash
git add -A
git commit -m "<type>: <description>

<body with rationale>"
```

Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`.

### 6. Push & PR

**Never push without explicit user approval.**

```bash
# git — Local version control (commits/push)
git push origin feat/<slug>

# gh — GitHub platform management (PRs, issues, Actions)
gh pr create --base master --head feat/<slug> --title "..." --body "..."
```

Wait for user review of the PR. Note: `gh` has no `push` subcommand; use `git push`. See [[GL-006-command-boundaries-git-and-gh]].

### 7. Merge (user approval required)

```bash
gh pr merge <n> --squash --delete-branch --auto
```

After merge:

```bash
git checkout master && git pull
git checkout -b develop
git push origin develop
git branch --set-upstream-to=origin/develop develop
```

### 8. Documentation update

- Update `coingame.md` if state changed (new commit, new branch, new lesson)
- Write session log via Vigil pattern
- Update memory if state changed

### 9. Close (wrap up)

User says "wrap up" or "close session":

- Vigil checks SSOT
- Vigil checks for unfinished tasks
- Hermes writes session log
- Memory updated
- Report to user

## Cross-links

- [[coingame]] — Project hub
- [[sdlc]] — process overview
- [[ci-cd]] — pipeline
- [[ddd-software-design]] — architecture
- [[clean-code-solid]] — code quality
- [[GL-001-file-naming-conventions]] — naming rules
- [[GL-002-frontmatter-conventions]] — frontmatter
- [[GL-004-task-resource-linking]] — task cross-references

## Anti-patterns

- Committing without user approval
- Pushing without user approval
- Trying to run `gh push` (which does not exist; use `git push`)
- Working on `master` directly
- Skipping validation
- Forgetting to update documentation
- Duplicating knowledge (instead of linking via `[[wikilinks]]`)
