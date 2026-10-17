---
created: 2026-10-03
linked_topics:
  - security-agent-portal
  - production-metris-infrastructure
  - keycloak
---

# Security Agent Portal — Arquitetura de Produção e Integração com Keycloak (Metris)

## O que é
Documento de registo e conhecimento consolidado do myPKA sobre o funcionamento, arquitetura e requisitos de integração do **Security Agent Portal** com a infraestrutura de produção no servidor **Metris** (`metris.com.br`).

## Arquitetura de Autenticação e Integração (Direct Access Grants / Admin API)
Ao contrário de um fluxo OIDC tradicional com redirecionamento no browser (Authorization Code Flow), o Security Agent Portal implementa um fluxo onde **o Backend do Portal atua como intermediário direto via API REST** com o Keycloak:

1. **Registo de Utilizadores (`registerUser`):**
   - O Backend utiliza o Keycloak Admin Client (`keycloak.realm(targetRealm).users().create(...)`) para criar o utilizador diretamente no realm configurado (`security-portal`).
   - Dispara e-mails de verificação e atribui roles padrão (`ROLE_USER`).

2. **Login de Utilizadores (`loginUser`):**
   - O utilizador submete as credenciais no frontend. O Backend recebe e faz um pedido HTTP POST *server-to-server* para o endpoint OIDC do Keycloak (`/realms/{realm}/protocol/openid-connect/token` com `grant_type=password`).
   - O Keycloak valida e retorna o `access_token` JWT ao Backend, que sincroniza o utilizador localmente na base de dados do portal (`portal_db`).

## Comunicação Interna em Produção (Rede Docker `aether_net`)
Como o Backend do Portal (`security_agent_portal`) e o Keycloak (`aether_keycloak`) rodam como containers na mesma rede interna Docker (`aether_net`) no servidor Metris:
- As chamadas de API do portal para o Keycloak **não** precisam de transitar pela internet pública ou pelo NGINX externo (`keycloak.moneyback.com.br`).
- Devem utilizar a resolução de nomes interna da rede Docker:
  - Endpoint Keycloak interno: `http://keycloak:8080/realms/security-portal` (ou `http://aether_keycloak:8080`).
  - Base de dados interna: `jdbc:postgresql://aether_postgres:5432/portal_db`.

## Configuração de Variáveis e Perfis (`application.yaml`)
- **Ambiente Local (Desenvolvimento):** Utiliza `application-local.yaml`, apontando para o servidor Terra via Tailscale.
- **Ambiente de Produção (Metris):** Utiliza `application.yaml`, configurado para a stack conteinerizada local com nomes de serviços internos e o URL público do portal (`https://metris.com.br`).
