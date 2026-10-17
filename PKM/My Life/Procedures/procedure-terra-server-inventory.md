---
up: [[PKM/INDEX]]
title: "Servidor Terra - Inventário de Infraestrutura"
created: 2026-09-17
type: procedure
---

# Servidor Terra - Inventário de Infraestrutura e Serviços Docker

Registo oficial e persistente no myPKA dos serviços, portas, credenciais e métodos de gestão do servidor **Terra**.

## 1. Localização e Orquestração
- **Servidor:** Terra
- **Ficheiro Docker Compose:** `/home/openclaw/workspace/docker-compose_infra.yml`
- **Rede Interna:** `aether_net` (bridge)

## 2. Inventário de Serviços e Credenciais
As credenciais padrão para os serviços que exigem autenticação são `admin / admin`.

| Serviço | Container | Portas | Credenciais / Configuração |
|---|---|---|---|
| **PostgreSQL** | `aether_db` | `5432:5432` | User: `admin`<br>Pass: `admin`<br>DB: `keycloak_db` |
| **Keycloak** | `aether_keycloak` | `8080:8080`<br>`8443:8443` | Admin: `admin`<br>Pass: `admin`<br>Ligado ao PostgreSQL |
| **RabbitMQ** | `aether_rabbitmq` | `5672:5672`<br>`15672:15672` (Painel) | User: `admin`<br>Pass: `admin` |
| **Redis** | `aether_redis` | `6379:6379` | Sem autenticação |
| **Adminer** | `aether_adminer` | `8081:8080` | Interface web para o PostgreSQL |

## 3. Comandos Úteis
Para subir ou reiniciar os serviços no Terra:
\`\`\`bash
cd /home/openclaw/workspace
docker compose -f docker-compose_infra.yml up -d
\`\`\
