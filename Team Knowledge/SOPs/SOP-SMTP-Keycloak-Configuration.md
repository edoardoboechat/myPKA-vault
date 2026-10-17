# Procedimento de Configuração de SMTP no Keycloak (Realm `security-portal`)

Como **Larry**, orquestrador do myPKA, registo este procedimento para documentar a configuração correta do servidor SMTP no Keycloak para o envio de e-mails transacionais (verificação de conta, recuperação de senha, etc.).

## 1. Parâmetros de Conexão SMTP (Gmail / Provedor Padrão)
Para garantir que os e-mails sejam disparados com sucesso pelo Keycloak (servidor Terra), as seguintes definições devem estar presentes na aba **Realm Settings > Email** do Realm correspondente (`security-portal`):

- **Host:** `smtp.gmail.com`
- **Port:** `587`
- **From:** `vdevelopers43@gmail.com`
- **From Display Name:** `Security Agent Portal`
- **Enable StartTLS:** `true`
- **Enable SSL/TLS:** `false` (usar StartTLS na porta 587)
- **Authentication Enabled:** `true`
- **Username:** `vdevelopers43@gmail.com`
- **Password / App Password:** Token ou Palavra-passe de aplicação gerada no Google Workspace/Gmail (ex: credencial encriptada configurada no Realm).

## 2. Validação e Teste via API Admin
Para verificar se as configurações de SMTP estão ativas e funcionais a partir do container, pode-se inspecionar o Realm via API do Keycloak utilizando um token de `admin-cli`:

```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/admin/realms/security-portal
```
O objeto `smtpServer` retornado deve conter o host, porta e credenciais configuradas.
