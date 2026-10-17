# Registo Global de Infraestrutura — Instâncias Keycloak

Este documento serve como referência central e permanente para os agentes e projetos em toda a infraestrutura sobre os ambientes de **Keycloak** disponíveis.

## 1. Ambiente de Desenvolvimento (Servidor Terra)
* **Servidor:** Terra (acessível via Tailscale)
* **Localização da Stack:** `/home/openclaw/workspace/docker-compose_infra.yml`
* **Serviços associados:** PostgreSQL, Keycloak, RabbitMQ, Redis, Adminer.
* **Portas de Acesso:** 
  * HTTP: `8080`
  * HTTPS: `8443`
* **Credenciais de Acesso (Admin):**
  * Utilizador: `admin`
  * Palavra-passe: `admin`

## 2. Ambiente de Produção (Servidor Metris)
* **Servidor:** Metris (acessível via Tailscale / Nginx Proxy)
* **Localização da Stack:** `/home/openclaw/workspace/coingame/docker-compose.yml`
* **Domínio de Acesso (Host):** `keycloak.moneyback.com.br`
* **Realm Principal:** `aether-quest`
* **Credenciais de Acesso (Admin):**
  * Utilizador: `admin`
  * Palavra-passe: `changeit`
* **Base de Dados associada:** PostgreSQL interno (`aether_db`) com credenciais `admin` / `changeit`.

---
*Registo auditado pelo Vigil e gerido pelo Larry para persistência transversal no myPKA Vault.*
