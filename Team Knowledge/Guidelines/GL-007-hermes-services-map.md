1|---
2|created: 2026-09-02
3|linked_topics: [hermes-agent, infrastructure, services, whatsapp-bridge, litellm, android-security-agent, trusted-sources]
4|---
5|
6|# GL-007 - Hermes Agent Services Map

**Guideline registado por:** Hermes Agent (subagente)
**Data:** 2026-09-02
**Mantido por:** Edoardo / Hermes Agent

> **Actualizar sempre que a infraestrutura mudar.** Este é o SSOT para o estado actual dos serviços.

---

## Estado Actual (2026-09-02)

### Resumo dos Serviços

| Serviço | Tipo | PID | Porta | Uptime | Auto-arranque |
|---------|------|-----|-------|--------|---------------|
| hermes-dashboard | PM2 | 688894 | 9119 | 24h | ✅ via PM2 |
| litellm-proxy | PM2 | 703050 | 4000 | 10h | ✅ via PM2 |
| hermes-gateway | Python (manual) | 647557 | 8642 | — | ❌ Manual |
| WhatsApp Bridge | Node.js (subprocess) | 647571 | 3000 | — | ✅ (via Gateway) |

---

## Arquitectura em ASCII

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         HERMES AGENT - ARQUITECTURA                         │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌──────────────┐      ┌──────────────┐
  │    PM2       │      │    PM2       │
  │ hermes-      │      │   litellm-  │
  │  dashboard   │      │    proxy     │
  │  ──────────  │      │  ──────────  │
  │  PID:688894  │      │  PID:703050  │
  │  Porta:9119  │      │  Porta:4000  │
  └──────────────┘      └──────┬───────┘
                               │
                               │ LLM
                               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FLUXO DE MENSAGEM                                 │
└─────────────────────────────────────────────────────────────────────────────┘

  WhatsApp
     │
     │ (WhatsApp Web Protocol - Baileys)
     ▼
  ┌─────────────────────────────────────┐
  │       WhatsApp Bridge (Node.js)     │
  │  PID: 647571 | Porta: 3000 (local)  │
  │  Mode: self-chat                    │
  │  Session: ~/.hermes/platforms/       │
  │           whatsapp/session          │
  │  Log: bridge.log                    │
  └─────────────────┬───────────────────┘
                    │ HTTP
                    ▼
  ┌─────────────────────────────────────┐
  │     Hermes Gateway (Python)         │
  │  PID: 647557 | Porta: 8642          │
  │  Pai: 647557 (self)                 │
  │  ─────────────────────────────      │
  │  child_process spawned:             │
  │    → WhatsApp Bridge (PID 647571)   │
  └─────────────────┬───────────────────┘
                    │ REST → LiteLLM
                    ▼
  ┌─────────────────────────────────────┐
  │       LiteLLM Proxy                 │
  │  PID: 703050 | Porta: 4000          │
  │  ─────────────────────────────      │
  │  Routing: → LLM Provider            │
  └─────────────────┬───────────────────┘
                    │ LLM Inference
                    ▼
            ┌───────────────┐
            │   LLM Model   │
            └───────┬───────┘
                    │
                    │ Resposta
                    ▼
  ┌─────────────────────────────────────┐
  │       LiteLLM Proxy                 │
  │  (Response streaming)               │
  └─────────────────┬───────────────────┘
                    │
  ┌─────────────────┴───────────────────┐
  │                                     │
  ▼                                     ▼
 Hermes Gateway                    WhatsApp Bridge
    │                                     │
    └─────────── Response ───────────────┘
                    │
                    ▼
               WhatsApp
              (User final)

┌─────────────────────────────────────────────────────────────────────────────┐
│                          CLIENTES EXTERNOS                                  │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────┐
  │   Android Security Agent App        │
  │  Endpoint: http://100.122.21.51:8642 │
  │  Auth: Bearer hermes-dev-key-2026    │
  │  Header: ag-sec-app                  │
  │  Modelo: android-security-agent      │
  └─────────────────────────────────────┘
                    │
                    ▼ (v1/chat/completions)
  ┌─────────────────────────────────────┐
  │     Hermes Gateway                  │
  │  Porta: 8642                        │
  └─────────────────────────────────────┘
```

---

## Detalhes por Serviço

### 1. PM2 Services

#### hermes-dashboard
- **PID:** 688894
- **Porta:** 9119
- **Uptime:** 24 horas
- **Script:** `start-dashboard.sh`
- **Verificação:** `pm2 list` → `pm2 logs hermes-dashboard`

#### litellm-proxy
- **PID:** 703050
- **Porta:** 4000
- **Uptime:** 10 horas
- **Script:** `start_proxy.sh`
- **Verificação:** `pm2 list` → `pm2 logs litellm-proxy`

### 2. Hermes Gateway (Python)

- **PID:** 647557
- **Porta:** 8642
- **Comando:** `python -m hermes_cli.main gateway run`
- **PPID:** 1 (init) — iniciado manualmente
- **Verificação:** `ss -tlnp | grep 8642`
- **Configuração:** `~/.hermes/config.yaml`

**⚠️ ALERTA CRÍTICO:**
O serviço `hermes-gateway.service` existe em `/etc/systemd/system/` mas está **inactive (dead)** apesar de enabled. Isto significa que **a API REST vai abaixo se o servidor reiniciar**.

### 3. WhatsApp Bridge (Node.js subprocess)

- **PID:** 647571
- **Porta:** 3000 (localhost only)
- **PPID:** 647557 (filho directo do Hermes Gateway)
- **Caminho:** `/home/master/hermes-stack/.venv/lib/python3.12/site-packages/scripts/whatsapp-bridge/bridge.js`
- **Tecnologia:** `@whiskeysockets/baileys` (WhatsApp Web protocol)
- **Session:** `/home/master/.hermes/platforms/whatsapp/session`
- **Modo:** `--mode self-chat`
- **Log:** `/home/master/.hermes/platforms/whatsapp/bridge.log`

**Auto-arranque:** ✅ SIM — o Bridge arranca automaticamente quando o Hermes Gateway inicia.

---

## Configuração (`~/.hermes/config.yaml`)

```yaml
platforms:
  whatsapp:
    enabled: true
    allowed_users:
      - '351939791481'
```

---

## Fluxo Completo de Mensagem

```
WhatsApp User
     │
     ▼
┌─────────────┐    porta 3000    ┌─────────────────┐    porta 8642    ┌──────────────┐
│ WhatsApp    │ ────────────────►│ Hermes Gateway  │ ─────────────────►│ LiteLLM      │
│ Bridge      │                  │ (Python)        │                   │ Proxy        │
└─────────────┘                  └─────────────────┘                   └──────┬───────┘
                                                                              │
                                                                              ▼
                                                                     ┌──────────────┐
                                                                     │ LLM Provider │
                                                                     └──────────────┘
```

---

## ⚠️ Alerta de Persistência

| Serviço | Persiste após reinício? | Motivo |
|---------|------------------------|--------|
| hermes-dashboard | ✅ SIM | PM2 restart policy |
| litellm-proxy | ✅ SIM | PM2 restart policy |
| hermes-gateway | ❌ NÃO | Service inactive em systemd |
| WhatsApp Bridge | ❌ NÃO | Depende do Hermes Gateway |

**Acção necessária (Edoardo):** Investigar porque o `hermes-gateway.service` está enabled mas inactive. Sem isto, a API REST não sobrevive a reinícios.

---

## Comandos Úteis

### Ver estado dos serviços
```bash
pm2 list
```

### Ver logs de serviços PM2
```bash
pm2 logs hermes-dashboard
pm2 logs litellm-proxy
```

### Verificar se Hermes Gateway está a correr
```bash
ss -tlnp | grep 8642
```

### Ver logs do WhatsApp Bridge
```bash
tail -f /home/master/.hermes/platforms/whatsapp/bridge.log
```

### Ver processos relacionados
```bash
ps aux | grep hermes
ps aux | grep litellm
```

---

## Funcionalidade: Fontes Confiáveis

> **Atualização:** 2026-09-02 — Integração da feature de Fontes Confiáveis do android-security-agent.

### 1. Lógica de Confiança Granular

O android-security-agent implementou um sistema de confiança **por origem específica**, não apenas por aplicação. A confiança é avaliada com base em dois critérios combinados:

- **appPackage**: Identificador único da aplicação Android emissora
- **sender**: Identificador único do remetente (pode ser um userId, número de telefone, ou outro identificador específico)

**Nível de confiança por origem:**
- **Trusted**: Origem explicitamente marcada como confiável pelo utilizador na TrustedSourcesActivity
- **Untrusted**: Origem explicitamente bloqueada ou não explicitamente confiada
- **Default**: Origens não listadas assumem o nível de confiança padrão configurado na aplicação

**Fluxo de decisão:**
```
Receção de mensagem → AppMessageInterceptor → Verificação de confiança →
  ├─ Se trusted → Permitir processamento
  ├─ Se untrusted → Bloquear e registar evento
  └─ Se default → Aplicar política padrão (configurada no app)
```

### 2. Fluxo no AppMessageInterceptor

O `AppMessageInterceptor` é o ponto central de verificação de confiança antes de qualquer mensagem ser encaminhada para o LLM:

1. **Interceção da mensagem**: Todas as mensagens recebidas são interceptadas pelo interceptor
2. **Extração de origem**: Identifica `appPackage` e `sender` da mensagem
3. **Verificação na base de dados**: Consulta a tabela `trusted_source` para determinar o nível de confiança
4. **Decisão de fluxo**:
   - Se origem estiver na tabela como `trusted=true`: mensagem prossegue para processamento normal
   - Se origem estiver na tabela como `trusted=false`: mensagem é rejeitada e evento registado
   - Se origem não existir na tabela: aplica política padrão (configurada no app)
5. **Encaminhamento**: Mensagens aprovadas são encaminhadas para o Hermes Gateway via REST API

**Localização do interceptor:**
- Classe: `com.nousresearch.androidsecurityagent.interceptor.AppMessageInterceptor`
- Método principal: `interceptMessage()`
- Trigger: Antes de qualquer processamento de mensagem

### 3. Tabela trusted_source na Base de Dados Local

Foi adicionada uma nova tabela `trusted_source` à base de dados local (Room) para armazenar as origens confiáveis:

```sql
CREATE TABLE trusted_source (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    app_package TEXT NOT NULL,      -- Pacote da aplicação Android (ex: "com.whatsapp")
    sender TEXT NOT NULL,           -- Identificador do remetente (ex: "351939791481")
    trusted BOOLEAN NOT NULL DEFAULT 1,  -- 1=true (confiável), 0=false (não confiável)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(app_package, sender)     -- Restrição de unicidade por combinação app+remetente
);
```

**Migração de base de dados:**
- Versão: 1 → 2
- Comando: `ALTER TABLE trusted_source ADD COLUMN ...`
- Localização: `com.nousresearch.androidsecurityagent.data.AppDatabase.MIGRATION_1_2`

**Entidades relacionadas:**
- `TrustedSource`: Entidade Room que mapeia a tabela
- `TrustedSourceDao`: Interface DAO com métodos para CRUD de origens confiáveis
- `TrustedSourceRepository`: Camada de repositório para acesso à base de dados

### 4. TrustedSourcesActivity

Nova atividade para gestão de fontes confiáveis:

**Funcionalidades:**
- **Listagem**: Exibe todas as origens confiáveis/bloqueadas com respetivo estado
- **Adição**: Permite adicionar novas origens confiáveis manualmente
- **Remoção**: Permite remover origens da lista de confiança
- **Edição**: Permite alterar o estado de confiança de uma origem
- **Pesquisa**: Filtra por appPackage ou sender
- **Ordenação**: Por appPackage, sender, ou data de criação

**Layout:**
- Arquivo: `res/layout/activity_trusted_sources.xml`
- Componentes principais:
  - `RecyclerView` para listagem de origens
  - `SearchView` para pesquisa
  - `FloatingActionButton` para adicionar nova origem
  - `CardView` para cada item de origem com:
    - Nome da aplicação (resolvido via `resolveAppLabel()`)
    - Identificador do remetente
    - Botão de toggle para alterar estado de confiança
    - Opção de remoção

**Integração com EventLogAdapter:**
- Long-press em mensagens no EventLogAdapter agora oferece opção "Marcar como confiável"
- Ao selecionar esta opção, a origem da mensagem é automaticamente adicionada à tabela `trusted_source` com `trusted=true`
- Permite ao utilizador promover rapidamente uma origem a confiável diretamente do histórico de eventos

**Navegação:**
- Acesso via menu de configurações do android-security-agent
- Intento: `Intent(this, TrustedSourcesActivity::class.java)`

---

## Ficheiros Relacionados

- [[GL-008-hermes-troubleshooting]] — Como diagnosticar problemas
- [[infra-critical]] — Regras de segurança para infra
- [[GL-006-command-boundaries-git-and-gh]] — Limites de comandos

---

*Actualizado: 2026-09-02*
*Próxima revisão: Após qualquer mudança na infraestrutura*
