---
name: Credentials & Security
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_topics:
  - infrastructure-servers
  - docker-and-workspaces
tags:
  - credentials
  - security
  - keycloak
  - secrets
---

# Credentials & Security

## Regra de Ouro

**Nunca expor credenciais em output, commits, ou respostas.** Usar sempre `***` ou `[REDACTED]` para mascarar.

## Credenciais de Infra

| Serviço | Credencial | Notas |
|---|---|---|
| Keycloak Admin | `admin` / `Hitachi$20261` | Realm: `aether-quest` |
| Postgres | `postgres` / `changeit` | Servidor Terra |
| RabbitMQ | `guest` / `changeit` | Servidor Terra |
| Keycloak Users | `admin`, `pilot01`, `hunterX` / `Hitachi$20261` | Realm: `aether-quest` |

## Credenciais da App Coingame

| Utilizador | Senha | Papel |
|---|---|---|
| `admin` | `Hitachi$20261` | Administrador |
| `pilot01` | `Hitachi$20261` | Jogador padrão |
| `hunterX` | `Hitachi$20261` | Jogador |

## SSL / Keystore

- **Keystore:** `classpath:aetherquest-local.p12`
- **Alias:** `aetherquest-local`
- **Senha:** `changeit`
- **Formato:** PKCS12

## Regras de Segurança

1. **Nunca commitar credenciais** — usar `.env` locais e `.gitignore`
2. **Seguir o padrão fail-closed** — nega por defeito, permite só o necessário
3. **Masking:** Output de terminal/ferramentas nunca expõe passwords reais
4. **GitHub tokens:** `gh` CLI usa autenticação do host — nunca guardar tokens em ficheiros

## myPKA Cockpit (TLS + PIN)

O serviço Node.js do Cockpit usa:
- **TLS:** Obrigatório para exposição LAN
- **PIN Gate:** scrypt hash com prefixo `$`
- **Porta:** 8443 ou similar

Ver: [[node-lan-service-setup]]

## Cross-links

- [[infrastructure-servers]] — Servidores metris e terra
- [[docker-and-workspaces]] — Docker e workspaces
- [[coingame]] — Project hub
