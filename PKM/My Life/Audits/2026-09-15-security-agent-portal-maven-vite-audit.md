# Vigil Audit & Knowledge Consolidation: Spring Boot All-in-One Maven + Vite CI/CD

**Date:** 2026-09-15
**Target:** security-agent-portal
**Scope:** Architecture, Maven Lifecycle Automation, and Production Parity

## Core Learnings & Methodological Rules Added
1. **Spring Boot Static Assets Packaging:**
   - Never copy frontend build assets (`dist/`) into `src/main/resources/static` during build phases as source modifications are skipped/ignored during repackaging.
   - Always target `${project.build.directory}/classes/static` using `maven-resources-plugin` so that assets are directly embedded into `BOOT-INF/classes/static/` within the final executable `.jar`.
2. **Self-Contained Maven Build Lifecycle:**
   - Use `exec-maven-plugin` mapped strictly to lifecycle phases (`initialize` for `npm install`, `generate-resources` for `npm run build`) to guarantee that both local machine builds and GitHub Actions runners produce identical, fully standalone artifacts without requiring manual external shell wrappers in CI scripts.
3. **Strict Validation Protocol:**
   - Never declare success based solely on CI pipeline green states. Always verify internal container binaries (`jar tf app.jar | grep index.html`) and local runtime health (`curl -I http://localhost:8080/` -> HTTP 200) before pulling images to production servers (Metris).
