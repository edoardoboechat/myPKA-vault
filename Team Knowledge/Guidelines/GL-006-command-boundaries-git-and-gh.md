---
id: GL-006-command-boundaries-git-and-gh
title: Command Boundaries — git vs. gh
default_owner: hermes
status: active
created: 2026-08-29
linked_topics:
  - git-github-config
references:
  - coingame-git-governance
---

# GL-006 - Command Boundaries: git vs. gh

> **This Guideline is a general rule every agent reads on every relevant action.** Every session touching version control reads this file. SOPs and Workstreams `[[wikilink]]` here rather than restating the rule.

## The rule

**`git`** and **`gh`** are not interchangeable. Each tool owns a distinct domain:

| Tool | Domain | Examples |
|---|---|---|
| `git` | Local version control — commits, branches, pushes, pulls, merges | `git add`, `git commit`, `git push`, `git pull`, `git merge`, `git checkout`, `git branch` |
| `gh` | GitHub platform management — PRs, issues, Actions, releases, repo metadata | `gh pr create`, `gh pr merge`, `gh issue create`, `gh run list`, `gh release create` |

## `gh push` does not exist

**`gh push` is not a valid command.** The GitHub CLI (`gh`) has no `push` subcommand.

If you type `gh push`, you will get an error such as:

```
unknown command "push" for "gh"
```

This is a **common mistake** when switching between `git` and `gh`. The correct tool for sending commits to a remote is `git push`.

### Why the confusion happens

- `git` and `gh` share some subcommand names: `git clone`, `gh repo clone`; `git status`, `gh status`.
- Both use `--base`, `--head`, `--branch` flags in overlapping ways.
- But `push` belongs exclusively to `git`. `gh` manages what happens *on GitHub* after the push — it never initiates the push itself.

### How to avoid the mistake

When you reach for a remote operation, ask:

> *"Am I pushing commits to the remote, or am I managing a GitHub artifact (PR, issue, Actions run)?"*

- Push commits → **`git push origin <branch>`**
- Create a PR, merge a PR, check CI status → **`gh`**
- Open an issue, comment on a PR, trigger a release → **`gh`**

## Practical implications for the coingame workflow

In the coingame project, the typical sequence uses both tools correctly:

```bash
# git — local version control
git add -A
git commit -m "feat: ..."
git push origin feat/my-branch

# gh — GitHub platform management
gh pr create --base master --head feat/my-branch --title "..." --body "..."
gh pr merge <pr-number> --squash --delete-branch --auto
gh run list --limit 3          # check Actions status
gh issue create --title "..."  # open a GitHub issue
```

Notice that `push` never appears after `gh`.

## Anti-patterns

```bash
# ❌ Wrong — gh has no push subcommand
gh push origin feat/my-branch

# ✅ Correct — git push sends commits
git push origin feat/my-branch
```

```bash
# ❌ Wrong — git cannot create or merge PRs
git pr create
git merge --squash

# ✅ Correct — gh manages PR lifecycle
gh pr create ...
gh pr merge ...
```

## Cross-references

- [[GL-001-file-naming-conventions]] — branch naming (`feat/<slug>`, `fix/<slug>`)
- [[SOP-coingame-development-process]] — full coingame workflow (steps 6–7 show the correct `git`/`gh` sequence)
- [[coingame-git-governance]] — detailed governance rules (commit authorization, no auto-merge, pitfall tracking)
- [[git-pitfalls]] — real-world errors including `gh push` mistakes

## Updates to this Guideline

If the rule changes, update this file. Do not duplicate it into SOPs or Workstreams. They `[[wikilink]]` here and inherit the change automatically.

### Version history

- **v1** (2026-08-29) — Initial version. Establishes the `git` vs. `gh` domain split, documents that `gh push` does not exist (common mistake), and shows the correct sequence used in the coingame workflow.
