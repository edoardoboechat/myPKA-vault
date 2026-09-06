# Session Log — 2026-09-06

**Project:** Android Security Agent
**Session:** UI fix — Toolbar title visibility, dark mode item colors
**User:** Edoardo Boechat Abreu

## What was done

### Toolbar title visibility fix (critical bug)
All screens were showing "Android Security Agent" in the Toolbar instead of the correct section title. Root cause: using `android:title` instead of `app:title` — `android:titleTextColor` does not apply when `app:title` is used. Fix: add `xmlns:app` namespace + use `app:title` + `app:titleTextColor`.

Affected screens:
- `activity_history.xml` — "Histórico de Eventos" ✅
- `activity_monitored_apps.xml` — "Apps Monitorizadas" ✅
- `activity_trusted_sources.xml` — "Fontes Confiáveis" ✅
- `activity_debug_log.xml` — "Debug Logs" ✅

### Dark mode item colors
`item_event_log.xml` updated: timestamp `#B0B0B5`, source/preview `#FFFFFF`, action `#FF5555`, reason `#B0B0B5`, divider `#2A2A2E`.

### Dark mode consistency
Background: `#0E0E10`, Surface: `#1A1A1D`, Text: `#FFFFFF`/`#B0B0B5`, Buttons: `#3A3A3D`.

## Commits
- `cc06c5f` — fix: add app:titleTextColor to Toolbar for history screen visibility
- `0278111` — fix: use app:title and app:titleTextColor for visible Toolbar titles on monitored apps, trusted sources and debug logs

## Key lesson learned
When using `androidx.appcompat.widget.Toolbar` with `app:title`, the title text color MUST be set with `app:titleTextColor` — `android:titleTextColor` is ignored.
