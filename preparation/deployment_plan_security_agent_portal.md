---
created: 2026-10-03
modified: 2026-10-03
linked_topics:
  - security-agent-portal
  - production-metris-infrastructure
  - keycloak
---

# Plano de Execução: Deploy do Security Agent Portal em Metris

## Visão Geral
Este documento descreve o plano de execução para preparar e lançar o utilitário **Security Agent Portal** no ambiente de produção **Metris (Metris)**. O foco é garantir uma transição suave, mantendo a estabilidade dos serviços existentes enquanto se integra as funcionalidades do portal com o Keycloak e estado sólido em termos de segurança.

## Premissas Críticas
1. **Não Alterar NGINX:** O NGINX em Metris já está configurado para direcionar `metris.com.br` ao container do portal. Não se deve alterar este ficheiro a menos que seja estritamente necessário, sob consentimento explícito.
2. **Segregação de Ambientes:** As configurações de desenvolvimento (`application-local.yaml`) devem permanecer intactas. Apenas o perfil de produção (`application.yaml`) será ajustado para refletir a infraestrutura localizada em Metris (redes Docker, volumes e DNS locais).
3. **Integração Direta (Backend to Keycloak):** O portal utiliza comunicações *server-to-server* via API do Keycloak para operações de gestão de utilizadores e autenticação direta.

## Etapas do Plano de Execução

### Fase 1: Auditoria e Sincronização do Realm (Keycloak)
* **Objetivo:** Garantir que o realm `security-portal` e os clientes associados no ambiente Metris possuam as mesmas definições de permissões, rotas e capacidades que funcionam no servidor Terra.
* **Ação:** 
  1. Comparar o realm ativo em Terra (servidor de desenvolvimento) com o ficheiro `portal-realm.json`.
  2. Verificar configurações específicas: **SMTP (para notificações e validação)**, **Client Scopes**, e **Web Origins**. 
  3. Sincronizar estas definições para a instância de produção em Metris através da API do Keycloak.

### Fase 2: Configuração do Ambiente de Produção (Código)
* **Objetivo:** Preparar o código fonte do portal para operar na rede interna de produção.
* **Ação:** Atualizar o ficheiro `backend/src/main/resources/application.yaml` com os seguintes parâmetros:
    * **Datasource:** Conexão ao serviço interno `aether_postgres` no banco `portal_db`.
    * **Keycloak Client/Realm:** Configuração de endpoint para acesso via rede interna (`http://keycloak:8080`).
    * **Base URL do Sistema:** Definir como `https://metris.com.br`.

### Fase 3: Preparação e Governança (Git & CI/CD)
* **Objetivo:** Garantir que a transição para produção passe pelo pipeline de QA oficial.
* **Ação:**
  1. Submeter Pull Requests (PRs) sequenciais: `develop` -> `master`.
  2. Validar a geração automática da imagem no GHCR via GitHub Actions após aprovação do código.
  3. Cada passo de commit ou push em produção exige **autorização prévia** por parte do utilizador humano, nunca sendo automatizado pelo agente sem sinalização.

### Fase 4: Deploy Físico (Metris)
* **Objetivo:** Atualizar o serviço no servidor de produção.
* **Ação:**
  1. Aceder ao servidor via SSH seguro no Metris.
  2. Executar `docker pull` da imagem mais recente do repositório oficial.
  3. Reiniciar o contentor `security_agent_portal`.
  4. Validar a disponibilidade e o funcionamento dos fluxos de login, registro e recuperação através do browser em `metris.com.br`.

## Resumo de Segurança (Vigil Audit)
- Não utilizar `sudo` no Metris para tarefas que possam ser feitas pelo utilizador `openclaw`.
- Confirmar sempre a conectividade com o serviço `aether_keycloak` antes de iniciar qualquer transação de usuário real durante a janela de deploy.

---
# Rascunho do Plano - (Aguardando Aprovação)
- [ ] Fase 1: Auditoria no Terra e Sincronização em Metris.
- [ ] Fase 2: Ajustes de configuração no `application.yaml`.
- [ ] Fase 3: Processo de homologação via GitHub Actions.
- [ ] Fase 4: Pull final e Restart do serviço em Metris.
