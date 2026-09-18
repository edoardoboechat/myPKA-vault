# Session Log: 2026-09-14 - Security Agent Portal Architecture Fix & Automation

## Goal
Fix the build pipeline and architecture of the **Security Agent Portal** by strictly separating Frontend (React) and Backend (Spring Boot), automating the entire process via Maven (`pom.xml`), adding the user profile icon, ensuring the dark theme is preserved, and verifying functionality via Playwright.

## Actions Executed
1. **Separation of Concerns Restored:** Abandoned manual edits in `backend/src/main/resources/static/` and restored the rule that all UI work must happen in React (`frontend/src/App.jsx`).
2. **Maven Build Automation (`pom.xml`):** Added the `exec-maven-plugin` to run `npm run build` during the `generate-resources` phase, and the `maven-resources-plugin` to automatically copy the compiled Vite bundle (`frontend/dist`) into `backend/src/main/resources/static`.
3. **Build & Test Cycle:** Verified that a single `mvn clean install` handles the entire process cleanly (`BUILD SUCCESS`).
4. **Git Commit & Push:** Committed the automated POM configuration (`06ac379`, `9564f12`) and successfully pushed to `origin/develop`.
5. **Runtime Verification:** Started the application locally via Java (`--spring.profiles.active=local`), verified HTTP 200 response on port 8080, and performed headless Playwright checks.

## Key Learnings / Architectural Guardrails
- **No Manual Static Copies:** The backend `static/` folder is exclusively an output target of the Maven build process.
- **Unified Build:** `mvn clean install` builds the React frontend, copies the assets, packages the Spring Boot application, and installs the resulting JAR in one go.
- **Strict Validation:** Always verify real HTTP status codes and visual renders (via Playwright) before declaring a release ready.
