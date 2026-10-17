---
created: 2026-10-03
linked_topics:
  - ci-cd
  - infrastructure-servers
  - production-deployment
---

# Produção no Servidor Metris — Arquitetura e Configuração Padrão

## O que é
Documento de referência canônico do myPKA para o provisionamento e preparação de aplicações e microsserviços para o ambiente de produção no servidor **Metris** (`metris.com.br`).

## Servidor de Produção: Metris
- **Endereço / Host:** `metris.com.br` (acesso via SSH com utilizador `openclaw` e chave dedicada `~/.ssh/metris_key`).
- **Workspace:** `/root/workspace` (ou link simbólico `~/workspace`).
- **Orquestração:** Docker & Docker Compose (`coingame_aether_net`).

## Stack de Serviços Padrão (Aether Net)

| Serviço / Container | Imagem / Tecnologia | Porta Interna | Porta Exposta / Domínio | Propósito |
|---|---|---|---|---|
| `aether_nginx` | `nginx:alpine` | 80 / 443 | `80`, `443` (Metris & Moneyback) | Borda, proxy reverso, terminação SSL e isolamento de certificados. |
| `aether_postgres` | `postgres:15-alpine` | 5432 | Rede interna (`5432`) | Base de dados transacional central (`aether_db`). |
| `aether_keycloak` | `quay.io/keycloak/keycloak:22.0.1` | 8080 / 8443 | `keycloak.moneyback.com.br` | Gestão de identidade e autenticação OIDC (Realm de prod). |
| `aether_redis` | `redis:alpine` | 6379 | Rede interna | Cache e gestão de sessões. |
| `aether_rabbitmq` | `rabbitmq:3-management` | 5672 / 15672 | `rabbitmq.moneyback.com.br` | Mensageria assíncrona. |
| `aether_adminer` | `adminer:latest` | 8080 | `adminer.moneyback.com.br` | Gestão web de base de dados. |
| `aether_redis_commander` | `rediscommander/redis-commander:latest` | 8081 | `redis.moneyback.com.br` | Gestão visual do Redis. |

---

## Padrões Obrigatórios para Novos Projetos em Produção (Metris)

1. **Rede Docker Compartilhada:**
   - Todos os serviços de produção devem integrar-se obrigatoriamente à rede Docker externa/partilhada: `coingame_aether_net`. Isso permite resolução de nomes interna (ex: `postgres`, `keycloak`, `redis`).

2. **Configuração de Base de Dados e Credenciais (Padrão Aether):**
   - **Database Name:** `aether_db` (ou base dedicada na mesma instância PostgreSQL).
   - **User:** `admin`
   - **Password:** `changeit` (ou credenciais seguras injetadas via variáveis de ambiente de produção).
   - **JDBC URL Pattern:** `jdbc:postgresql://postgres:5432/<db_name>`

3. **Integração com Keycloak (OIDC):**
   - **Issuer URI:** `https://keycloak.moneyback.com.br/realms/<realm_name>`
   - **Base URL Interna:** `http://keycloak:8080`
   - **Configuração de Proxy Reverso (Nginx):**
     O Nginx do Metris deve encaminhar os headers de proxy corretamente (`X-Forwarded-For`, `X-Forwarded-Proto https`, `X-Forwarded-Host`) para garantir que o Keycloak e as aplicações reconheçam o canal HTTPS de borda.

4. **Exposição NGINX e Certificados SSL:**
   - Os novos domínios ou subdomínios devem ser adicionados ao `nginx.conf` da stack no Metris, apontando para o container correspondente na rede `coingame_aether_net`.
   - Utilização de certificados Let's Encrypt gerados pelos containers Certbot dedicados no Metris.

5. **Regras de Git e Deploy:**
   - **Nunca utilizar `sudo` para `git push`** no Metris (o utilizador `openclaw` usa a chave pessoal com permissão de escrita, enquanto o `sudo`/`root` usa uma *Deploy Key* restrita a leitura).
