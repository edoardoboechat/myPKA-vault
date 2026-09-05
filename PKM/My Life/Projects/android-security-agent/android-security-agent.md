---
name: Android Security Agent
status: active
target_date: null
key_element: [security]
linked_goals: []
linked_topics:
  - android-security
  - mobile-vulnerability-assessment
  - apk-analysis
  - owasp-mstg
linked_sops:
  - SOP-android-security-agent-setup
linked_session_logs:
  - 2026-08-30-17-00_hermes_android-security-agent-full-implementation
  - 2026-09-05-14-40_hermes_android-security-agent-url-persist-fix
linked_people: []
linked_deliverables:
  - integration-architecture
  - url: https://github.com/edoardoboechat/android-security-agent/commit/9853695
    description: "fix: persist endpoint URL onPause (auto-save on app exit)"
  - data-layer
  - rest-api-credentials
  - system-architecture
linked_journal_entries: []
tags:
  - security
  - android
  - mobile
  - agent
  - rest-api
  - hermes-agent
---

# Android Security Agent

## What it is

AI-powered agent for automated Android application security analysis, vulnerability scanning, and APK deep inspection. Supports OWASP MSTG compliance checks, malware detection patterns, and security hardening recommendations. Integrates with Hermes Agent via OpenAI-compatible REST API for real-time threat detection (SMS, notifications, multimodal image analysis).

## Current State

- **Status:** Production-ready core, Hermes integration validated
- **Build:** BUILD SUCCESSFUL
- **Git:** Commit 83aa459 pushed to origin/main
- **Hermes REST API:** Operational on port 8642
- **Profile:** android-security-agent configured and isolated

## Architecture Overview

```
[Android App] → [Hermes REST API :8642] → [LiteLLM Proxy :4000] → [AI Model]
                         ↓
                  [android-security-agent skill]
                         ↓
                  [Structured JSON Response]
                         ↓
                  [Room DB EventLog]
```

Detailed architecture: [[system-architecture]]
Integration flows: [[integration-architecture]]
Credentials: [[rest-api-credentials]]
Data models: [[data-layer]]

## Components

### 1. Android Application
- **Package:** com.agent.security
- **Min SDK:** 24, Target SDK: 34
- **Architecture:** MVVM with Room DB and Retrofit
- **Build Status:** BUILD SUCCESSFUL

**Key Files:**
- `app/src/main/java/com/agent/security/data/remote/HermesAgentApi.kt`
- `app/src/main/java/com/agent/security/data/remote/RetrofitClient.kt`
- `app/src/main/java/com/agent/security/data/remote/model/ChatRequest.kt`
- `app/src/main/java/com/agent/security/data/remote/model/ChatResponse.kt`
- `app/src/main/java/com/agent/security/data/remote/model/ChatMessage.kt`
- `app/src/main/java/com/agent/security/data/remote/model/ContentPart.kt`
- `app/src/main/java/com/agent/security/data/remote/model/ImageUrl.kt`
- `app/src/main/java/com/agent/security/data/preferences/AppPreferences.kt`
- `app/src/main/java/com/agent/security/data/local/HistoryDatabase.kt`
- `app/src/main/java/com/agent/security/data/local/entity/EventLog.kt`
- `app/src/main/java/com/agent/security/data/local/dao/EventLogDao.kt`
- `app/src/main/java/com/agent/security/data/action/ActionExecutor.kt`
- `app/src/main/java/com/agent/security/receiver/SmsInterceptor.kt`
- `app/src/main/java/com/agent/security/receiver/AppMessageInterceptor.kt`
- `app/src/main/java/com/agent/security/MainActivity.kt`

### 2. Hermes REST API
- **Port:** 8642
- **Binding:** 0.0.0.0 (all interfaces)
- **Format:** OpenAI Chat Completions
- **Auth:** Bearer token (hermes-dev-key-2026)

**Endpoints:**
- POST /v1/chat/completions
- POST /v1/responses
- GET /v1/models

**Configuration:** /home/master/.hermes/.env
- API_SERVER_ENABLED=true
- API_SERVER_PORT=8642
- API_SERVER_HOST=0.0.0.0
- API_SERVER_KEY=hermes-dev-key-2026

### 3. Hermes Profile: android-security-agent
- **Location:** ~/.hermes/profiles/android-security-agent/
- **Config:** base_url=http://127.0.0.1:4000/v1, provider=openai-api, model=fallback-pipeline
- **Skills:** development/android-security-agent (copied from main skills)
- **SOUL.md:** Custom agent instructions

### 4. systemd Service
- **Service:** hermes-gateway.service
- **Location:** /etc/systemd/system/hermes-gateway.service
- **Status:** Enabled, auto-restart on failure
- **Config:** EnvironmentFile=/home/master/.hermes/.env, Restart=always, RestartSec=5

### 5. LiteLLM Proxy
- **Port:** 4000
- **PID:** 363417
- **Status:** Online
- **Provider:** openai-api
- **Model:** fallback-pipeline

## Implementation Details

### Android App Changes
1. Refactored to OpenAI Chat Completions format
2. Created 7 new data model classes (ChatRequest, ChatResponse, ChatMessage, ContentPart, ImageUrl, Usage, ChatChoice)
3. Updated HermesAgentApi with /v1/chat/completions endpoint
4. Updated RetrofitClient with Tailscale base URL
5. Updated AppPreferences with endpoint default
6. Rewrote ActionExecutor to send user message only (no system prompt)
7. Fixed SmsInterceptor and AppMessageInterceptor BroadcastReceivers

### Hermes Configuration
1. Created isolated profile at ~/.hermes/profiles/android-security-agent/
2. Copied android-security-agent skill to profile skills
3. Created SOUL.md with agent instructions
4. Configured systemd service for auto-start
5. Validated REST API on port 8642

### Integration Validations
- Text request: model: android-security-agent returns security JSON
- Image request: multimodal works with base64 image_url
- LiteLLM Proxy: running and responsive
- Port 8642: LISTEN on 0.0.0.0

## Scope

- **APK Analysis:** Decompilation, manifest inspection, permission analysis
- **Vulnerability Scanning:** Static analysis for common Android security flaws
- **Malware Detection:** Pattern matching for known Android malware signatures
- **Security Reports:** Generated findings with remediation guidance
- **REST API Integration:** OpenAI-compatible Hermes Agent integration for real-time threat detection (SMS, notifications, multimodal image analysis)

## Dependencies

| Library | Version | Purpose |
|---------|---------|---------|
| Room Database | 2.6.1 | Local SQLite database |
| Retrofit | 2.9.0 | HTTP client |
| Gson | 2.10.1 | JSON serialization |
| Coroutines | 1.7.3 | Async operations |
| OkHttp | 4.12.0 | HTTP interceptors |
| AndroidX Core | 1.12.0 | Android utilities |

## Status update

- [x] Project environment created (isolated)
- [x] PKM vault section established
- [x] Hermes skill scaffolded
- [x] Android project base initialized (minSdk 24, targetSdk 34)
- [x] Gradle build configured with dependencies
- [x] Hermes Agent REST API integration completed & tested
- [x] Multimodal image support implemented via ShareReceiver
- [x] Local Room DB history logging operational
- [x] Refactored to OpenAI Chat Completions format
- [x] Hermes Profile android-security-agent created
- [x] systemd service configured and enabled
- [x] Full integration validated (text + image)
- [x] PKM documentation complete

## Base Structure

```
android-security-agent/
├── app/
│   ├── build.gradle.kts
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/agent/security/
│       │   ├── MainActivity.kt
│       │   ├── data/
│       │   │   ├── remote/
│       │   │   │   ├── HermesAgentApi.kt
│       │   │   │   ├── RetrofitClient.kt
│       │   │   │   └── model/
│       │   │   │       ├── ChatRequest.kt
│       │   │   │       ├── ChatResponse.kt
│       │   │   │       ├── ChatMessage.kt
│       │   │   │       ├── ContentPart.kt
│       │   │   │       ├── ImageUrl.kt
│       │   │   │       ├── Usage.kt
│       │   │   │       └── ChatChoice.kt
│       │   │   ├── local/
│       │   │   │   ├── HistoryDatabase.kt
│       │   │   │   ├── dao/EventLogDao.kt
│       │   │   │   └── entity/EventLog.kt
│       │   │   ├── preferences/AppPreferences.kt
│       │   │   └── action/ActionExecutor.kt
│       │   └── receiver/
│       │       ├── SmsInterceptor.kt
│       │       └── AppMessageInterceptor.kt
│       └── res/
├── build.gradle.kts
├── settings.gradle.kts
├── gradle/
└── local.properties (sdk.dir)
```

## GitHub Repository

- **Repo:** `edoardoboechat/android-security-agent` (private)
- **Branch:** main
- **Latest Commit:** 9853695

## Cross-links

- [[security]] — Key Element anchor
- [[android-security]] — Related topic
- [[mobile-vulnerability-assessment]] — Related topic
- [[owasp-mstg]] — Security standard reference
- [[SOP-android-security-agent-setup]] — Setup procedure
- [[integration-architecture]] — REST API integration architecture & workflows
- [[data-layer]] — Data layer specs, Room DB & Retrofit models
- [[rest-api-credentials]] — API credentials & connection config
- [[system-architecture]] — Complete system architecture
- [[GL-009-infrastructure-servers]] — Server infrastructure (Metris/Terra)
- Session log: [[2026-09-05-21-00_android-security-agent-ui-refresh]]
- Session log: [[2026-09-05-14-40_hermes_android-security-agent-url-persist-fix]]
- Session log: [[2026-08-30-17-00_hermes_android-security-agent-full-implementation]]
