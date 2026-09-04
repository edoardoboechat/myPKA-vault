---
name: Android Security Agent - Data Layer
description: Database schema and API models for the Android Security Agent project
key_element: [security]
status: active
tags:
  - android
  - security
  - data-layer
  - room
  - retrofit
  - rest-api
references:
  - GL-001-file-naming-conventions
  - GL-002-frontmatter-conventions
linked_session_logs:
  - 2026-08-30-17-00_hermes_android-security-agent-full-implementation
---

# Android Security Agent — Data Layer

## AppPreferences (SharedPreferences)

| Campo | Tipo | Default | Descrição |
|-------|------|---------|-----------|
| `hermes_endpoint` | String | `http://100.122.21.51:8642/v1` | URL base da API do Hermes Agent (OpenAI-compatible) |
| `is_sms_enabled` | Boolean | `true` | Ativa/desativa monitoramento de SMS |
| `is_app_msg_enabled` | Boolean | `true` | Ativa/desativa monitoramento de mensagens de app |

**Ficheiro:** `app/src/main/java/com/agent/security/data/preferences/AppPreferences.kt`

---

## HistoryDatabase (Room)

### Entity: EventLog

| Campo | Tipo | Nullable | Descrição |
|-------|------|---------|-----------|
| `id` | Long | Não (autoGenerate) | Chave primária |
| `timestamp` | Long | Não | Data/hora do evento (epoch ms) |
| `source` | String | Não | Origem: `sms`, `app`, `imagem` |
| `preview` | String | Não | Preview do texto analisado |
| `action` | String | Não | Ação tomada pelo Hermes (e.g. `BLOCK`, `ALLOW`, `WARN`) |
| `reason` | String | Não | Motivo/justificação da ação |

**Ficheiro:** `app/src/main/java/com/agent/security/data/local/entity/EventLog.kt`

### DAO: EventLogDao

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `insert(eventLog)` | `Long` | Insere novo evento |
| `getAllEvents()` | `Flow<List<EventLog>>` | Todos os eventos ordenados por timestamp DESC |
| `getEventsBySource(source)` | `Flow<List<EventLog>>` | Eventos filtrados por source |
| `deleteById(id)` | — | Remove evento por ID |
| `deleteAll()` | — | Remove todos os eventos |

**Ficheiro:** `app/src/main/java/com/agent/security/data/local/dao/EventLogDao.kt`

### Database

- **Nome:** `history_database`
- **Versão:** 1
- **Export Schema:** false

**Ficheiro:** `app/src/main/java/com/agent/security/data/local/HistoryDatabase.kt`

---

## Hermes Agent REST API Integration (OpenAI-Compatible)

A integração completa com a API REST do Hermes Agent encontra-se documentada em [[integration-architecture]] e as credenciais em [[rest-api-credentials]].

### Modelos de Dados Retrofit (OpenAI Chat Completions)

- `ChatRequest.kt`: `model`, `messages` (`List<ChatMessage>`), `stream`
- `ChatMessage.kt`: `role` (`user`, `assistant`), `content` (`Any` - suporta String ou `List<ContentPart>`)
- `ChatResponse.kt`: `choices` (`List<ChatChoice>`)
- `ChatChoice.kt`: `message` (`ChatMessage`), `finish_reason`

**Ficheiros relacionados:**
- `app/src/main/java/com/agent/security/data/remote/HermesAgentApi.kt`
- `app/src/main/java/com/agent/security/data/remote/model/ChatRequest.kt`
- `app/src/main/java/com/agent/security/data/remote/model/ChatResponse.kt`
- `app/src/main/java/com/agent/security/data/remote/RetrofitClient.kt`

---

## Android Permissions

| Permissão | Manifest | Descrição |
|-----------|---------|-----------|
| `INTERNET` | `android.permission.INTERNET` | Comunicação com API Hermes |
| `RECEIVE_SMS` | `android.permission.RECEIVE_SMS` | Interceptar SMS recebidos |
| `READ_SMS` | `android.permission.READ_SMS` | Ler conteúdo do SMS |
| `POST_NOTIFICATIONS` | `android.permission.POST_NOTIFICATIONS` | Notificações de alerta |
| `RECEIVE_BOOT_COMPLETED` | `android.permission.RECEIVE_BOOT_COMPLETED` | Reiniciar interceptores após boot |

**BroadcastReceivers registados:**
- `SmsInterceptor` (`android.provider.Telephony.SMS_RECEIVED`, exported = `true`)
- `AppMessageInterceptor` (`com.agent.security.APP_MESSAGE`, exported = `false`)

---

## Interface de Gestão (Cockpit)

A `MainActivity` gere o estado da app e exibe o histórico persistido no Room DB.

- **Configurações:** `EditText` para URL base do Hermes e switches para ativar/desativar SMS e Notificações (armazenados em `AppPreferences`).
- **Histórico:** `RecyclerView` alimentada por `EventLogDao.getAllEvents()` via Kotlin `Flow`.
- **Ações:** Botão para limpar histórico com confirmação (`AlertDialog`).

**Ficheiros da UI:**
- `app/src/main/res/layout/activity_main.xml`
- `app/src/main/res/layout/item_event_log.xml`
- `app/src/main/java/com/agent/security/presentation/EventLogAdapter.kt`
- `app/src/main/java/com/agent/security/MainActivity.kt`

---

## Cross-links

- [[android-security-agent]] — Project note
- [[integration-architecture]] — Arquitetura de integração REST e fluxos
- [[rest-api-credentials]] — Credenciais e parâmetros de conexão
- [[security]] — Key Element anchor
