---
created: 2026-09-07
type: architecture-note
project: android-security-agent
linked_topics: [[android-security-agent]], [[infrastructure-servers]], [[hermes-infrastructure-map]]
---

# Topologia de Rede e Infraestrutura — Android Security Agent

Este documento regista a arquitetura de rede e os componentes físicos/lógicos envolvidos no fluxo de dados da aplicação **Android Security Agent**, desde o telemóvel do utilizador até ao modelo LLM no servidor de backend.

## Fluxo de Tráfego de Ponta a Ponta

1. **Origem (Dispositivo Android / Telemóvel):**
   - A aplicação faz um pedido HTTP/HTTPS para o endpoint público oficial: `https://api.moneyback.com.br`.
   - *Nota:* O acesso direto via Tailscale a partir do telemóvel foi descontinuado; todo o tráfego externo passa agora obrigatoriamente por HTTPS através do domínio.

2. **Porta de Entrada (Servidor Metris):**
   - O pedido HTTPS aterra no servidor **Metris**.
   - No Metris, corre um **Nginx** dentro de um container Docker (gerido por um ficheiro `docker-compose` no workspace do servidor).
   - O Nginx atua como **Reverse Proxy**: faz a terminação SSL/TLS (convertendo HTTPS para HTTP) e prepara o reencaminhamento.

3. **Ponte de Rede (Tailscale Interno):**
   - Para saltar do servidor Metris para o servidor de backend, o Nginx do Metris reencaminha a requisição através da rede **Tailscale** (túnel privado dedicado à comunicação entre os servidores da infraestrutura).

4. **Processamento e Inferência (Servidor UbuntuOllama):**
   - O pedido chega ao servidor **`ubuntuollama`**.
   - **Hermes Agent:** Corre como um serviço gerido pelo **PM2**. Recebe a API request, valida o campo restrito `source: "ag-sec-app"`, aplica a persona de segurança e encaminha para o motor de IA.
   - **Ollama:** Corre nativamente como um serviço do sistema no mesmo servidor `ubuntuollama`, executando a inferência do modelo.

## Componentes e Responsabilidades

| Componente | Localização / Servidor | Tecnologia | Função Principal |
| :--- | :--- | :--- | :--- |
| **App Client** | Telemóvel Android | Kotlin / Retrofit | Interceta SMS/Notificações e envia payload formatado via HTTPS. |
| **Reverse Proxy** | Servidor Metris | Nginx (Docker Compose) | Terminação SSL/TLS e encaminhamento de portas. |
| **Túnel de Rede** | Entre Metris e UbuntuOllama | Tailscale | Conectividade segura e privada entre servidores. |
| **Gateway / Agente** | Servidor `ubuntuollama` | Hermes Agent (PM2) | Roteamento de pedidos, validação de `source` e orquestração. |
| **Motor de LLM** | Servidor `ubuntuollama` | Ollama (Serviço do Sistema) | Execução local dos modelos de linguagem. |
