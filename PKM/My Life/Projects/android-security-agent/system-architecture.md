---
name: Android Security Agent - System Architecture
description: Complete system architecture documentation for the Android Security Agent ecosystem including Android app, Hermes Agent, REST API, profiles, and services
key_element: [security]
status: active
tags:
  - android
  - security
  - architecture
  - hermes-agent
  - rest-api
  - system-design
references:
  - GL-001-file-naming-conventions
  - GL-002-frontmatter-conventions
---

# Android Security Agent - System Architecture

Documento de arquitetura completa do ecossistema [[android-security-agent]]. Cobre todos os componentes: app Android, Hermes Agent, REST API, profiles, skills, services e validações.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Android Device                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  android-security-agent App                          │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │  │
│  │  │SmsInterceptor│  │AppMessage    │  │Share       │  │  │
│  │  │              │  │Interceptor   │  │Receiver    │  │  │
│  │  └──────┬───────┘  └──────┬───────┘  └─────┬──────┘  │  │
│  │         │                 │                 │         │  │
│  │         └─────────────────┼─────────────────┘         │  │
│  │                           ▼                           │  │
│  │                  ┌─────────────────┐                  │  │
│  │                  │ ActionExecutor  │                  │  │
│  │                  └────────┬────────┘                  │  │
│  │                           │                           │  │
│  │         ┌─────────────────┼─────────────────┐         │  │
│  │         ▼                 ▼                 ▼         │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │  │
│  │  │HermesAgentApi│  │RetrofitClient│  │Room DB     │  │  │
│  │  │              │  │              │  │EventLog    │  │  │
│  │  └──────┬───────┘  └──────┬───────┘  └────────────┘  │  │
│  │         │                 │                           │  │
│  │         └─────────────────┘                           │  │
│  └─────────────────────────┬───────────────────────────────┘  │
└────────────────────────────┼──────────────────────────────────┘
                             │ HTTPS (Tailscale)
                             │ Authorization: Bearer hermes-dev-key-2026
                             ▼
┌─────────────────────────────────────────────────────────────┐
│              Hermes Server (Linux)                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  hermes-gateway.service (systemd)                     │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Hermes REST API (Port 8642, 0.0.0.0)          │  │  │
│  │  │  POST /v1/chat/completions                      │  │  │
│  │  │  POST /v1/responses                             │  │  │
│  │  │  GET  /v1/models                                │  │  │
│  │  └────────────────────┬────────────────────────────┘  │  │
│  │                       │                                │  │
│  │                       ▼                                │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Hermes Profile: android-security-agent        │  │  │
│  │  │  ~/.hermes/profiles/android-security-agent/    │  │  │
│  │  │  ┌───────────────────────────────────────────┐  │  │  │
│  │  │  │  Skills:                                  │  │  │  │
│  │  │  │  - development/android-security-agent      │  │  │  │
│  │  │  │  SOUL.md: Agent instructions              │  │  │  │
│  │  │  │  .env: Isolated environment               │  │  │  │
│  │  │  └─────────────────┬─────────────────────────┘  │  │  │
│  │  └────────────────────┼────────────────────────────┘  │  │
│  └───────────────────────┼────────────────────────────────┘  │
│                          │                                   │
│                          ▼                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  LiteLLM Proxy (Port 4000, PID 363417)              │  │
│  │  Provider: openai-api                                │  │
│  │  Model: fallback-pipeline                            │  │
│  └───────────────────────┬───────────────────────────────┘  │
└──────────────────────────┼──────────────────────────────────┘
                           │
                           ▼
              ┌──────────────────────┐
              │   AI Model Provider  │
              │   (OpenAI API)       │
              └──────────────────────┘
```

## Components Detail

### 1. Android Application

**Package:** com.agent.security  
**Min SDK:** 24  
**Target SDK:** 34  
**Language:** Kotlin  
**Build Status:** BUILD SUCCESSFUL  
**Git:** Commit 83aa459

#### Core Modules

**BroadcastReceivers:**
- SmsInterceptor (SMS_RECEIVED action, exported=true)
- AppMessageInterceptor (APP_MESSAGE action, exported=false)

**Data Layer:**
- Remote: Retrofit + OkHttp + HermesAgentApi
- Local: Room Database (HistoryDatabase v1)
- Preferences: SharedPreferences (AppPreferences)
- Action: ActionExecutor (orchestrates flow)

**Models (OpenAI Chat Completions):**
- ChatRequest: model, messages, stream
- ChatResponse: choices, usage
- ChatMessage: role, content (String or List<ContentPart>)
- ContentPart: type (text | image_url), text/image_url
- ImageUrl: url (Data URL with base64)
- ChatChoice: message, finish_reason
- Usage: prompt_tokens, completion_tokens, total_tokens

**UI:**
- MainActivity: Configuration + History display
- EventLogAdapter: RecyclerView adapter
- ShareReceiverActivity: Image share handling

#### Data Flow

1. **SMS/Notification Capture:**
   - BroadcastReceiver fires
   - ActionExecutor.extractData() parses intent
   - ActionExecutor.execute() calls HermesAgentApi
   - Response parsed as JSON (action, title, message, risk_level)
   - EventLog inserted in Room DB

2. **Image Share:**
   - ShareReceiverActivity receives image
   - Image compressed and converted to base64
   - Multimodal request sent (text + image_url)
   - Response parsed and logged

#### Key Files

```
app/src/main/java/com/agent/security/
├── MainActivity.kt
├── data/
│   ├── remote/
│   │   ├── HermesAgentApi.kt
│   │   ├── RetrofitClient.kt
│   │   └── model/
│   │       ├── ChatRequest.kt
│   │       ├── ChatResponse.kt
│   │       ├── ChatMessage.kt
│   │       ├── ContentPart.kt
│   │       ├── ImageUrl.kt
│   │       ├── Usage.kt
│   │       └── ChatChoice.kt
│   ├── local/
│   │   ├── HistoryDatabase.kt
│   │   ├── dao/EventLogDao.kt
│   │   └── entity/EventLog.kt
│   ├── preferences/AppPreferences.kt
│   └── action/ActionExecutor.kt
└── receiver/
    ├── SmsInterceptor.kt
    └── AppMessageInterceptor.kt
```

### 2. Hermes REST API

**Port:** 8642  
**Binding:** 0.0.0.0 (all interfaces)  
**Format:** OpenAI Chat Completions  
**Auth:** Bearer token  
**Configuration:** /home/master/.hermes/.env

#### Environment Variables

```bash
API_SERVER_ENABLED=true
API_SERVER_PORT=8642
API_SERVER_HOST=0.0.0.0
API_SERVER_KEY=hermes-dev-key-2026
```

#### Endpoints

**POST /v1/chat/completions**
- Main endpoint for chat completions
- Accepts OpenAI-compatible request format
- Routes to appropriate agent based on model field

**POST /v1/responses**
- Alternative endpoint for responses

**GET /v1/models**
- List available models

#### Request Flow

1. Android app sends POST to /v1/chat/completions
2. Hermes validates Bearer token
3. Hermes reads model field ("android-security-agent")
4. Hermes routes to android-security-agent profile
5. Profile loads skill and SOUL.md
6. Skill processes request
7. Response returned in OpenAI format

#### Security

- Bearer token required for all requests
- Token validated on every request
- In production: use high-entropy token, rotate regularly
- Network: Tailscale or HTTPS with valid certificate

### 3. Hermes Profile: android-security-agent

**Location:** ~/.hermes/profiles/android-security-agent/

**Structure:**
```
android-security-agent/
├── config.yaml
├── SOUL.md
├── .env
└── skills/
    └── development/
        └── android-security-agent/
            └── SKILL.md
```

#### config.yaml

```yaml
base_url: http://127.0.0.1:4000/v1
provider: openai-api
model: fallback-pipeline
```

#### SOUL.md

Custom agent instructions defining:
- Agent identity and purpose
- Input contract specification
- Output contract (JSON format)
- Decision heuristics
- OWASP knowledge base
- Behavior rules

#### Profile Isolation

- Separate .env file
- Dedicated skills directory
- Independent configuration
- Same LiteLLM Proxy as main agent (shared infrastructure)

### 4. android-security-agent Skill

**Locations:**
- ~/.hermes/skills/development/android-security-agent/SKILL.md
- ~/.hermes/profiles/android-security-agent/skills/development/android-security-agent/SKILL.md

**Content:**
- Agent role and capabilities
- Input contract (SMS text, app notifications, images)
- Output contract (JSON: action, title, message, risk_level)
- Decision heuristics (phishing, malware, social engineering)
- OWASP MSTG knowledge base
- Behavior rules and edge cases

**Triggers:**
- model: android-security-agent
- sms suspicious
- phishing detection
- security analysis
- threat assessment

### 5. systemd Service

**Service:** hermes-gateway.service  
**Location:** /etc/systemd/system/hermes-gateway.service  
**Status:** Enabled, running

**Configuration:**
```ini
[Unit]
Description=Hermes Agent Gateway
After=network.target

[Service]
Type=simple
EnvironmentFile=/home/master/.hermes/.env
ExecStart=/usr/bin/hermes gateway
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**Management:**
```bash
systemctl enable hermes-gateway.service
systemctl start hermes-gateway.service
systemctl status hermes-gateway.service
```

### 6. LiteLLM Proxy

**Port:** 4000  
**PID:** 363417  
**Status:** Online  
**Provider:** openai-api  
**Model:** fallback-pipeline

**Role:**
- Centralized LLM proxy
- Shared by main Hermes agent and android-security-agent profile
- Handles model routing and fallback
- Manages API keys and rate limits

## Design Decisions

### 1. Zero System Prompt in App

**Decision:** Android app does NOT include system prompt in requests.

**Rationale:**
- All security logic resides in Hermes skill
- Security rule updates don't require APK update
- Centralized security governance
- Easier to maintain and audit

**Implementation:**
- ActionExecutor sends only user message
- System prompt loaded from skill in Hermes

### 2. Routing via model Attribute

**Decision:** Use `model: "android-security-agent"` field for routing.

**Rationale:**
- OpenAI-compatible standard
- No special routing logic needed
- Single endpoint serves multiple agents
- Extensible to other agents

### 3. Multimodal Native Support

**Decision:** Use OpenAI image_url format with base64 Data URLs.

**Rationale:**
- Standard OpenAI format
- No need for image upload endpoints
- Works with existing infrastructure
- Direct image analysis in single request

### 4. Profile Isolation

**Decision:** Create separate Hermes profile for android-security-agent.

**Rationale:**
- Isolated environment
- Dedicated skills and configuration
- Independent testing
- Clear separation of concerns

### 5. SSOT for Credentials

**Decision:** All credentials in single rest-api-credentials.md file.

**Rationale:**
- Single source of truth
- Easy to update and rotate
- Clear audit trail
- Prevents credential sprawl

### 6. systemd Service Management

**Decision:** Use systemd for Hermes gateway service.

**Rationale:**
- Auto-start on boot
- Automatic restart on failure
- Standard Linux service management
- Centralized logging

## Validations

### Integration Tests

**Text Request:**
```bash
curl -X POST http://100.122.21.51:8642/v1/chat/completions \
  -H "Authorization: Bearer hermes-dev-key-2026" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "android-security-agent",
    "messages": [{"role": "user", "content": "Suspicious SMS test"}],
    "stream": false
  }'
```
**Result:** Returns security JSON with action, title, message, risk_level

**Image Request:**
```bash
# Multipart with base64 image
```
**Result:** Multimodal analysis works correctly

### Service Health

- **LiteLLM Proxy:** PID 363417, online, responsive
- **Port 8642:** LISTEN on 0.0.0.0
- **systemd Service:** Active and enabled
- **Android Build:** BUILD SUCCESSFUL
- **Git:** Commit 83aa459 pushed to origin/main

## Not Touched

The following components were explicitly NOT modified in this session:

- **WhatsApp bridge** (Node.js on port 3000)
- **Main Hermes agent** (default profile)
- **LiteLLM Proxy configuration** (shared infrastructure, already running)
- **Android app base code** (only refactored to OpenAI format)

## Future Work

- End-to-end testing with physical device
- Production Bearer token generation and rotation
- APK release and deployment procedure
- Monitoring and alerting setup
- Performance optimization for image processing
- Additional security heuristics in skill

## Cross-links

- [[android-security-agent]] — Project note
- [[integration-architecture]] — Integration flows and payloads
- [[rest-api-credentials]] — Credentials and configuration
- [[data-layer]] — Data models and Room DB
- [[security]] — Key Element anchor
- [[android-security]] — Related topic
- [[owasp-mstg]] — Security standard reference
- Session log: [[2026-08-30-17-00_hermes_android-security-agent-full-implementation]]
