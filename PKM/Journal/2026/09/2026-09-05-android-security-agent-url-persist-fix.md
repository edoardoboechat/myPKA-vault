---
created: 2026-09-05
tags:
  - android-security-agent
  - bugfix
  - persistence
  - nginx
linked_tasks: []
linked_deliverables:
  - url: https://github.com/edoardoboechat/android-security-agent/commit/9853695
    description: "fix: persist endpoint URL onPause (auto-save on app exit)"
linked_projects:
  - android-security-agent
linked_topics:
  - android-security
---

# 2026-09-05 — Android Security Agent: URL Persistence Fix & Public API Access

## What happened today

### Bug: App settings not persisting
The Android app was resetting the Hermes endpoint URL every time the user reopened it. Investigation revealed the root cause: the endpoint was only being saved when the text field lost focus (`setOnFocusChangeListener`), which didn't trigger when the app was closed directly.

### Fix: Added onPause() to MainActivity
Implemented `onPause()` lifecycle hook in `MainActivity.kt` to persist the endpoint URL immediately when the user leaves the activity or closes the app. The fix ensures settings survive app restarts.

### New: Public API access via domain
Configured `api.moneyback.com.br` as a public-facing endpoint for the Android Security Agent. The Nginx reverse proxy on Metris now routes HTTPS requests from `api.moneyback.com.br` to the Hermes Gateway at `100.122.21.51:8642`. This eliminates the need for the app to connect over Tailscale/VPN — it now works from anywhere with a public internet connection.

**Technical note:** The wildcard SSL certificate (`*.moneyback.com.br`) covers `api.moneyback.com.br` without additional configuration. No new Docker containers or docker-compose changes were needed.

## Outcomes
- Android app settings now persist correctly on app exit ✅
- Public API access working: `https://api.moneyback.com.br/v1/chat/completions` returns valid JSON from Android Security Agent ✅
- All existing Nginx mappings (moneyback.com.br, keycloak, adminer, redis, rabbitmq, hermes) remain functional ✅

## Key lesson
Android lifecycle methods (`onPause`, `onStop`, `onDestroy`) are the correct hooks for persistence operations — not just focus change listeners.
