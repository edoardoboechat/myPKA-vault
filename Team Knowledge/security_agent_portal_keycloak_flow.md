# Guia de Operação E2E: Keycloak Integration & Registo no Security Agent Portal

## 1. Contexto e Problema de Negócio
Durante a integração do Security Agent Portal com o Keycloak (servidor Terra), identificou-se que a criação de novos utilizadores gerava o envio de e-mails de confirmação, mas os utilizadores ficavam bloqueados em páginas finais genéricas do Keycloak ou sofriam de falhas de redirecionamento (`Invalid redirect uri` ou `Invalid username or password`).

## 2. Solução e Arquitetura Implementada
- **Callback Endpoint (`AuthController.java`):** Criado para intercetar o redirecionamento pós-confirmação, marcar `emailVerified = true`, gerar um PAT seguro e reencaminhar o utilizador com segurança para o ecossistema frontend (`/welcome`).
- **Parâmetros no `AuthService.java`:** Chamada explícita e rigorosa de `executeActionsEmail` passando `clientId`, `redirectUri` exata (`/api/auth/callback`), `lifespan` e as ações pretendidas.
- **Configuração de Clientes (Keycloak):** Atualização do `portal-realm.json` e dos clientes em produção/desenvolvimento para aceitar explicitamente o callback da API via Tailscale e redes locais (`http://100.122.21.51:8080/*`).

## 3. Elementos Conectados e Rastreio myPKA
- **Projeto Relacionado:** `security-agent-portal` (`~/hermes-stack/projects/security-agent-portal/`).
- **Infraestrutura:** Servidor Terra (Keycloak a rodar em Docker Compose, porta 8080).
- **Validação de Logs:** Os rastreios de auditoria e validações cURL de teste (`teste1` a `teste7`) demonstram o alinhamento completo do contrato OIDC com o motor do Keycloak.
