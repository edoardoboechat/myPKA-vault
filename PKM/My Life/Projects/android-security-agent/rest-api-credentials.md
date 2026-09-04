---
name: Android Security Agent - REST API Credentials & Config
description: Credentials and connection parameters for Hermes REST API integration with the Android Security Agent app
key_element: [security]
status: active
linked_topics:
  - android-security-agent
tags:
  - rest-api
  - credentials
  - hermes-agent
references:
  - GL-001-file-naming-conventions
  - GL-002-frontmatter-conventions
linked_session_logs:
  - 2026-08-30-17-00_hermes_android-security-agent-full-implementation
---

# Hermes REST API Configuration ([[android-security-agent]])

Este ficheiro é a **Single Source of Truth (SSOT)** para as credenciais e parâmetros de conexão da API REST do Hermes Agent com o [[android-security-agent]].

## Configurações do Servidor (.env)
Variáveis configuradas no servidor Hermes (`/home/master/.hermes/.env`):

- `API_SERVER_ENABLED=true`
- `API_SERVER_PORT=8642`
- `API_SERVER_HOST=0.0.0.0`
- `API_SERVER_KEY=hermes-dev-key-2026`

## Parâmetros de Conexão na App
- **Endpoint Base:** `http://100.122.21.51:8642/v1` (ou IP Tailscale configurável na UI)
- **Autenticação:** Header HTTP `Authorization: Bearer hermes-dev-key-2026` injetado automaticamente via OkHttp Interceptor.
- **Identificador do Agente:** `model: "android-security-agent"` (direciona o request internamente no Hermes para o skill correto).

## Notas de Segurança
- Em produção, o Bearer token deve ser gerado com entropia alta e rotacionado.
- Comunicação restrita à rede segura Tailscale ou HTTPS com certificado válido.

## Referências Cruzadas
- [[integration-architecture]] — Arquitetura de fluxo e payloads
- [[data-layer]] — Modelos de dados Retrofit e Room DB
