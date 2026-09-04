---
name: Android Security Agent - Integration Architecture
description: Architecture, data flow, payload specs, and design decisions for Hermes REST API integration with Android Security Agent
key_element: [security]
status: active
tags:
  - android
  - security
  - rest-api
  - architecture
  - hermes-agent
references:
  - GL-001-file-naming-conventions
  - GL-002-frontmatter-conventions
linked_session_logs:
  - 2026-08-30-17-00_hermes_android-security-agent-full-implementation
---

# Android Security Agent — Integration Architecture

Este documento detalha a arquitetura de integração entre a aplicação Android [[android-security-agent]] e o Hermes Agent através da REST API OpenAI-compatible. Para visão completa do sistema, ver [[system-architecture]].

## Visão Geral do Fluxo

```
[Android App] ──(HTTP POST /v1/chat.completions + Bearer Token)──> [Hermes Agent API (Port 8642)]
                                                                               │
                                                                    (Routing via model param)
                                                                               ▼
                                                                  [Android Security Agent Skill]
                                                                               │
                                                                   (Structured JSON Response)
                                                                               ▼
[Room DB / HistoryDatabase] <──(ActionExecutor parses & logs)── [Android App Receives Verdict]
```

1. **Interceção:** `SmsInterceptor` ou `AppMessageInterceptor` captura SMS/notificação, ou `ShareReceiverActivity` recebe imagem compartilhada.
2. **Requisição HTTP:** O OkHttp Client envia um POST para o endpoint configurado (ver [[rest-api-credentials]]) com o Bearer token.
3. **Encaminhamento no Hermes:** O parâmetro `model: "android-security-agent"` direciona o request para o subagente/skill correspondente no Hermes.
4. **Processamento:** O Hermes processa o prompt (texto ou multimodal com imagem em Base64) e retorna um JSON estruturado.
5. **Execução e Registo:** O `ActionExecutor` processa a resposta e grava o evento no Room DB ([[data-layer]]).

---

## Payloads da API

### 1. Mensagem de Texto (SMS / Notificação)
O request enviado à API **NÃO** inclui system prompt na app; todas as instruções e diretrizes de análise residem no servidor Hermes.

**Request JSON:**
```json
{
  "model": "android-security-agent",
  "messages": [
    {
      "role": "user",
      "content": "[SMS from +351****5678] URGENT: Your account has been locked. Click here to verify."
    }
  ],
  "stream": false
}
```

### 2. Mensagem Multimodal (Screenshots / Imagens via Share)
Imagens compartilhadas são comprimidas, convertidas para Base64 e enviadas no array `content` do formato OpenAI.

**Request JSON:**
```json
{
  "model": "android-security-agent",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Analyze this screenshot for phishing or security risks."
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQ..."
          }
        }
      ]
    }
  ],
  "stream": false
}
```

### 3. Resposta Esperada do Hermes
O assistente retorna um JSON estruturado encapsulado no campo `content` da mensagem de resposta (`choices[0].message.content`):

```json
{
  "action": "BLOCK",
  "title": "Phishing Attempt Detected",
  "message": "Suspicious link prompting credential harvesting.",
  "risk_level": "HIGH"
}
```

---

## Decisões de Design (Design Decisions)

1. **Zero System Prompt na App:** A aplicação cliente não define personas ou system prompts. Toda a lógica de análise de segurança reside no ecossistema Hermes Agent (`android-security-agent` skill), garantindo que atualizações de regras de segurança não exijam APK update.
2. **Roteamento via Atributo `model`:** O agente correto é selecionado dinamicamente pelo servidor Hermes com base no campo `model: "android-security-agent"` no payload.
3. **Suporte Multimodal Nativo:** Utilização do formato padrão OpenAI para `image_url` com Data URLs em Base64, permitindo análise direta de screenshots compartilhadas pelo utilizador.
4. **SSOT de Credenciais e Dados:** Credenciais e parâmetros de rede isolados em [[rest-api-credentials]], enquanto a estrutura de persistência local e DTOs estão em [[data-layer]].

---

## Cross-links

- [[android-security-agent]] — Project note
- [[rest-api-credentials]] — Credenciais e parâmetros de conexão
- [[data-layer]] — Modelos de dados Retrofit e Room DB
- [[system-architecture]] — Arquitetura completa do sistema
- [[security]] — Key Element anchor
- [[2026-08-30-17-00_hermes_android-security-agent-full-implementation]] — Session log
