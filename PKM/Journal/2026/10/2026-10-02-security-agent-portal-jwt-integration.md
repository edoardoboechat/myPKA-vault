---
full_name: "Edoardo Boechat Abreu"
role: "Lead Developer & Project Owner"
relation: "collaborator"
city: "Braga"
tags: ["development", "security", "keycloak", "spring-boot", "react"]
---

# Journal Entry — 2026-10-02

## Summary
Sessão focada na implementação e validação rigorosa da arquitetura de segurança baseada em **OAuth2 Resource Server (JWT)** no **Security Agent Portal**. 

## Highlights
- **Resolução do erro de regeneração do PAT**: O back-end passou a extrair a identidade do utilizador diretamente do token JWT enviado pelo cabeçalho `Authorization: Bearer`, eliminando falhas de rede ou de parâmetros em falta no corpo.
- **Restauração e isolamento dos fluxos de e-mail**: Os fluxos de *Resend Verification* e *Forgot Password* foram totalmente separados e integrados nas exceções de segurança públicas do Spring Security.
- **Preparação para futuras features**: Garantimos que o login agora emite e devolve o `accessToken` real do Keycloak ao front-end, estabelecendo a base definitiva para todos os fluxos autenticados e autorizados daqui para frente.
- **Deploy e Validação**: Compilação via Maven (`mvn clean package -DskipTests`), subida bem-sucedida do `.jar` na porta 8080, e sincronização completa com o repositório no GitHub (`feature-integration`).

## Links
- Project: [[security-agent-portal]]
- Key Technologies: [[keycloak]], [[spring-boot]], [[react]]
