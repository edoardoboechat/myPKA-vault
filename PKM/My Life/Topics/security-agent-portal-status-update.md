---
created: 2026-10-03
modified: 2026-10-03
linked_topics:
  - security-agent-portal
  - production-metris-infrastructure
  - keycloak
---

# Ponto de Situação: Deploy do Security Agent Portal em Metris

## Resumo da Execução
O plano de preparação e sincronização encontra-se numa fase avançada de estabilização, com todos os pré-requisitos de infraestrutura e parâmetros validados tanto em desenvolvimento local quanto na infraestrutura de produção (Metris).

---

## 📊 O que já foi feito (Concluído)

1. **Auditoria e SSOT (Terra e Metris):**
   - Mapeada a infraestrutura completa de produção em Metris (Docker stack, rede interna `aether_net`, NGINX e proxies).
   - Documentado o plano de execução canónico no vault do myPKA (`preparation/deployment_plan_security_agent_portal.md`).

2. **Correção Crítica de Infraestrutura (Metris):**
   - Resolvido o erro `502 Bad Gateway` e o crash-loop do Keycloak em Metris através do ajuste de permissões e montagem correta do realm.

3. **Sincronização Completa do Keycloak (Metris vs Terra):**
   - Criado e configurado o realm `security-portal` no Keycloak de Metris.
   - Sincronizadas as propriedades de **SMTP** para suporte a e-mails (recuperação de senha/registo).
   - Criados os clientes necessários (`portal-client`) com as URLs de redirecionamento corretas para produção (`https://metris.com.br/*`).
   - Criadas as roles essenciais do portal (`ROLE_USER` e `ROLE_ADMIN`).

4. **Parametrização Segura do Código (Sem tocar no código core da lógica de negócio):**
   - Ajustado o `KeycloakConfig.java` para ler as credenciais do admin do master (`admin_username` / `admin_password`) via propriedades do Spring (`@Value`).
   - Atualizados os ficheiros `application-local.yaml` (Terra/Local) e `application.yaml` (Produção/Metris) para separarem as credenciais (`admin/admin` vs `admin/changeit`).

5. **Validação de Desenvolvimento Local:**
   - Feita a limpeza, build Maven completa (backend + frontend Vite) e execução local estrita na porta **8080** com o perfil `local`. O ambiente local foi validado e está 100% íntegro.

---

## 🚧 O que falta fazer (Próximos Passos)

1. **Configuração Final do Container do Portal em Metris:**
   - Garantir que a stack do portal em Metris consome o novo `application.yaml` e as variáveis de ambiente corretas.
2. **Deploy do Portal em Metris:**
   - Subir o container do portal (`security_agent_portal`) na rede interna `aether_net` de Metris, apontando para o Keycloak interno (`http://keycloak:8080`).
3. **Validação por Endpoints (Curl / Teste E2E):**
   - Executar os testes estritos de fluxo (Registo, Login via `grant_type=password`, etc.) contra o ambiente de produção em Metris, **um a um, sob comando direto e aprovação explícita**.
