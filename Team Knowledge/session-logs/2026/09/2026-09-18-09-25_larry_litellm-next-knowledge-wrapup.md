# Session Log: Knowledge Restructuring - LiteLLM Next Migration

**Date:** 2026-09-18
**Agent:** Larry (Orchestrator) & Team
**Topic:** Knowledge base and guidelines update reflecting the deprecation of `litellm-proxy` in favor of `litellm-next` and `litellm_config_next.yaml`.

## What We Did
1. **Repository Hygiene (hermes-stack):** Committed and pushed new test proxy configs (`litellm_config_next.yaml`, `start_proxy_next.sh`), test artifacts, and Playwright screenshots to `origin/master`.
2. **Knowledge Base Alignment (myPKA & Hermes Guidelines):**
   - Updated `Team Knowledge/guidelines/infra-critical.md`
   - Updated `Team Knowledge/Guidelines/GL-007-hermes-services-map.md`
   - Updated `Team Knowledge/Guidelines/GL-008-hermes-troubleshooting.md`
   - Replaced all operational references from `litellm-proxy` to `litellm-next` and `litellm_config.yaml` to `litellm_config_next.yaml` across all SOPs and service maps.
