---
agent_id: larry
type: update-progress
date: 2026-09-30
topic: security-agent-portal-progress
---

# Atualização de Progresso: Security Agent Portal (Roadmap de Pendências)

## Estado Atual do Roadmap
- **Item 1 (Validação de E-mail & Registo):** Concluído na sessão anterior (redirecionamento OIDC, callback, geração de PAT e ecrã de boas-vindas).
- **Item 2 (Recuperação de Credenciais):** **Concluído nesta sessão** (endpoints no backend `forgot-password`, integração completa com o Keycloak via `UPDATE_PASSWORD`, e atualização interativa da `RecoveryView.jsx`).
- **Correção Crítica de Login & OIDC:** Resolvido o erro de `unauthorized_client` no Keycloak através da integração correta do `client_secret` (`portal-secret-key-change-me`) nas chamadas OIDC de validação de password do `AuthService`.
- **Item 3 (Gestão de Perfil do Utilizador):** Pendente (próxima e última tarefa do roadmap atual).

## Observações Técnicas Importantes
- **Localização do JSON do Realm:** O ficheiro de configuração do Keycloak para o portal reside em `/home/master/hermes-stack/projects/security-agent-portal/infra/keycloak`.
- **Pendente de i18n (Internacionalização):** A mensagem de erro em caso de credenciais inválidas ou falha de autenticação (`"Credenciais inválidas ou utilizador não encontrado."`) ainda precisa de ser totalmente traduzida/ajustada para suportar o dicionário i18n de inglês (`en`) no Front-End.
- **Git Push:** Alterações commitadas e enviadas com sucesso para a branch `feature-integration` (Commit `7d4ecab`).
