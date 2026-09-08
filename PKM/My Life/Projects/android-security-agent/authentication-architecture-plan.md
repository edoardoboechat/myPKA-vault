---
created: 2026-09-07
type: architectural-plan
project: android-security-agent
linked_topics: [[android-security-agent]], [[infrastructure-servers]], [[security-authentication]]
---

# Plano Arquitetural: Autenticação de API, Portal Web e Gestão de Tokens (Android Security Agent)

Este documento regista o plano conceptual e a arquitetura desenhada para introduzir autenticação baseada em tokens (Bearer Token) nas requisições da aplicação **Android Security Agent**, protegendo o acesso ao backend do Hermes Agent através de um Proxy inteligente e um Portal de Gestão de Utilizadores.

---

## 1. Visão Geral do Problema e Objetivo
Atualmente, a API do Hermes Agent está exposta no servidor **Metris** (via Nginx) sem uma camada de autenticação na ponta. 
O objetivo é implementar:
1. Um **Portal Web** para registo de utilizadores e geração de tokens de API.
2. Um **Mecanismo de Validação no Proxy (Nginx)** para rejeitar com `401 Unauthorized` qualquer pedido que não traga um token válido e ativo.
3. Utilização da infraestrutura existente no servidor **Terra** (Keycloak, PostgreSQL, Redis, RabbitMQ) para gestão de identidade e cache de tokens.

---

## 2. Topologia de Servidores e Componentes

### **Servidor Metris (Edge / Porta de Entrada)**
- **Nginx (Docker Compose):** Modificado para incluir validação de tokens (`auth_request` ou consulta rápida) antes de reencaminhar o tráfego.
- **Portal Web (Novo Container):** Servido com domínio próprio (ex: `https://metris.com.br` ou `https://portal.metris.com.br`), gerindo o registo e a emissão de tokens.
- **Certbot:** Emissão e renovação automática de certificados SSL para o novo domínio, integrando com a rotina já existente.

### **Servidor Terra (Core de Identidade e Dados — Interno via Tailscale)**
- **Keycloak:** Identity Provider (IdP) responsável pelo registo e autenticação de utilizadores.
- **PostgreSQL:** Base de dados relacional para persistência do Keycloak e dados do portal.
- **Redis:** Cache de alta performance para validação rápida de tokens (evitando latência e sobrecarga no banco a cada notificação enviada pela app).
- **RabbitMQ:** Disponível para eventos assíncronos e auditoria.

### **Servidor UbuntuOllama (Backend Privado)**
- **Hermes Agent (PM2) + Ollama:** Continua protegido na rede interna, recebendo apenas pedidos cujos tokens já foram validados pelo Nginx no Metris.

---

## 3. Fluxo de Funcionamento (End-to-End)

### **Fase A: Registo e Geração de Token**
1. O utilizador acede ao Portal Web alojado no Metris (`https://metris.com.br`).
2. Efetua o registo/login autenticado pelo **Keycloak** (no Terra).
3. No painel, gera o seu **Token de API**.
4. O portal regista o token no PostgreSQL e guarda uma referência ativa no **Redis**.
5. O utilizador insere o token nas definições da app **Android Security Agent**.

### **Fase B: Validação do Pedido no Proxy**
1. A app envia um pedido de notificação/SMS com o header:
   ```http
   Authorization: Bearer <token>
   ```
2. O pedido atinge o **Nginx no Metris**.
3. O Nginx valida o token (consultando o **Redis** no Terra via Tailscale).
   - **Token Válido:** O Nginx faz o *proxy pass* para o Hermes Agent no `ubuntuollama`.
   - **Token Inválido/Ausente:** O Nginx bloqueia imediatamente e responde com **`401 Unauthorized`**.

---

## 4. Diretrizes de Segurança e Implementação Futura
- **Garantia de Zero Downtime:** Configuração do novo domínio/portal em blocos de servidor (Server Blocks) separados no Nginx, sem tocar nas rotas atuais da API (`api.moneyback.com.br`) até que a migração esteja validada.
- **Backups Obrigatórios:** Obrigatório efetuar backup de todas as configurações do Nginx e volumes Docker no Metris antes de qualquer alteração estrutural.
- **Performance:** Validação de tokens estritamente via Redis para garantir latência mínima nas notificações do telemóvel.
