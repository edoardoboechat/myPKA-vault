---
created: 2026-09-02
linked_topics: [hermes-agent, troubleshooting, diagnostics, logs, infrastructure]
---

# GL-008 - Hermes Agent Troubleshooting

**Guideline registado por:** Hermes Agent (subagente)
**Data:** 2026-09-02
**Mantido por:** Edoardo / Hermes Agent

> **Guia de diagnóstico read-only.** Todos os comandos são de verificação — não alteram estado.

---

## Visão Rápida: Onde Procurar Primeiro

| Sintoma | Verificar Primeiro | Comando |
|---------|-------------------|---------|
| API não responde (8642) | Hermes Gateway vivo? | `ss -tlnp \| grep 8642` |
| WhatsApp não envia/recebe | Bridge vivo? | `ps aux \| grep bridge.js` |
| LLM não responde | LiteLLM vivo? | `pm2 logs litellm-proxy` |
| Dashboard não abre | hermes-dashboard vivo? | `pm2 logs hermes-dashboard` |
| Tudo caiu após reboot | Persistência? | Ver secção "Alerta de Persistência" em [[GL-007-hermes-services-map]] |

---

## 1. Hermes Gateway (Porta 8642)

### Verificar se está a correr
```bash
ss -tlnp | grep 8642
# Saída esperada: LISTEN 0 512 *:8642 *:* users:(("python",pid=647557,fd=5))
```

### Verificar processo
```bash
ps aux | grep "hermes_cli.main gateway run"
# Deve mostrar: python -m hermes_cli.main gateway run
```

### Verificar configuração
```bash
cat ~/.hermes/config.yaml
# Verificar: platforms.whatsapp.enabled: true
# Verificar: platforms.whatsapp.allowed_users
```

### Verificar se systemd service está activo (NÃO está actualmente)
```bash
systemctl status hermes-gateway.service
# Esperado: inactive (dead) — ESTE É O PROBLEMA CONHECIDO
```

### Verificar logs (se houver)
O Hermes Gateway não tem ficheiro de log dedicado — logs vão para stdout/stderr do terminal onde foi lançado.
```bash
# Se foi lançado via systemd:
journalctl -u hermes-gateway.service -f
```

---

## 2. WhatsApp Bridge (Porta 3000)

### Verificar se está a correr
```bash
ps aux | grep bridge.js
# Deve mostrar: node .../bridge.js --mode self-chat
# PPID deve ser o PID do Hermes Gateway
```

### Verificar porta
```bash
ss -tlnp | grep 3000
# Saída esperada: LISTEN 0 128 127.0.0.1:3000 *:* users:(("node",pid=647571,fd=...))
```

### Ver logs
```bash
# Tempo real
tail -f /home/master/.hermes/platforms/whatsapp/bridge.log

# Últimas 100 linhas
tail -100 /home/master/.hermes/platforms/whatsapp/bridge.log

# Procurar erros
grep -i error /home/master/.hermes/platforms/whatsapp/bridge.log
grep -i "connection\|connect\|disconnect" /home/master/.hermes/platforms/whatsapp/bridge.log
```

### Verificar sessão WhatsApp
```bash
ls -la /home/master/.hermes/platforms/whatsapp/session/
# Deve conter ficheiros de sessão do Baileys (auth_info, etc.)
```

### Verificar modo
```bash
ps aux | grep bridge.js
# Verificar flag: --mode self-chat
```

---

## 3. LiteLLM Proxy (Porta 4000)

### Verificar via PM2
```bash
pm2 list
# Procurar: litellm-proxy | online | 703050
```

### Ver logs
```bash
pm2 logs litellm-proxy --lines 100
pm2 logs litellm-proxy -f  # seguir tempo real
```

### Verificar saúde
```bash
curl -s http://localhost:4000/health
curl -s http://localhost:4000/v1/models
```

### Ver configuração
```bash
cat /home/master/hermes-stack/litellm_config.yaml
```

---

## 4. Hermes Dashboard (Porta 9119)

### Verificar via PM2
```bash
pm2 list
# Procurar: hermes-dashboard | online | 688894
```

### Ver logs
```bash
pm2 logs hermes-dashboard --lines 100
pm2 logs hermes-dashboard -f
```

### Verificar acesso
```bash
curl -s http://localhost:9119
curl -s http://100.122.21.51:9119
```

---

## 5. Android Security Agent (Cliente Externo)

### Verificar conectividade ao Gateway
```bash
# Do dispositivo/emulador Android:
curl -X POST http://100.122.21.51:8642/v1/chat/completions \
  -H "Authorization: Bearer hermes-dev-key-2026" \
  -H "Content-Type: application/json" \
  -d '{"model": "android-security-agent", "messages": [{"role": "user", "content": "test"}], "source": "ag-sec-app"}'
```

### Verificar headers obrigatórios
| Header | Valor |
|--------|-------|
| Authorization | `Bearer hermes-dev-key-2026` |
| X-Source / Source | `ag-sec-app` |
| Content-Type | `application/json` |

### Campo `model` vs Modelo LLM
- **Campo `model` no request:** `android-security-agent` (nome do sub-agente, NÃO modelo LLM)
- O routing interno decide qual LLM usar

---

## 6. Diagnóstico de Falhas Comuns

### Gateway não arranca
```bash
# 1. Verificar se porta 8642 já está em uso
ss -tlnp | grep 8642

# 2. Verificar venv activado
which python
python -c "import hermes_cli; print('OK')"

# 3. Tentar arrancar manualmente
cd /home/master/hermes-stack
source .venv/bin/activate
python -m hermes_cli.main gateway run
```

### WhatsApp Bridge não conecta
```bash
# 1. Verificar se Gateway está a correr
ss -tlnp | grep 8642

# 2. Verificar logs do bridge
tail -50 /home/master/.hermes/platforms/whatsapp/bridge.log

# 3. Verificar sessão (pode ter expirado)
ls -la /home/master/.hermes/platforms/whatsapp/session/

# 4. Reiniciar bridge (via Gateway)
# Matar bridge e deixar Gateway re-arrancar:
kill <PID_BRIDGE>
# Gateway deve re-spawn automaticamente
```

### LiteLLM não responde
```bash
# 1. Verificar PM2
pm2 list

# 2. Reiniciar se necessário
pm2 restart litellm-proxy

# 3. Verificar config
cat /home/master/hermes-stack/litellm_config.yaml

# 4. Verificar conectividade a provedores LLM
# Logs mostram tentativas de conexão
pm2 logs litellm-proxy | grep -i "error\|timeout\|connection"
```

---

## 7. Verificação de Saúde Completa (One-liner)

```bash
echo "=== HERMES HEALTH CHECK $(date) ===" && \
echo -n "Gateway (8642): " && ss -tlnp | grep -q ":8642 " && echo "✅ UP" || echo "❌ DOWN" && \
echo -n "WhatsApp Bridge (3000): " && ss -tlnp | grep -q ":3000 " && echo "✅ UP" || echo "❌ DOWN" && \
echo -n "LiteLLM (4000): " && ss -tlnp | grep -q ":4000 " && echo "✅ UP" || echo "❌ DOWN" && \
echo -n "Dashboard (9119): " && ss -tlnp | grep -q ":9119 " && echo "✅ UP" || echo "❌ DOWN" && \
echo "=== PM2 STATUS ===" && pm2 list
```

---

## 8. Locais de Logs - Resumo

| Componente | Local do Log | Tipo |
|------------|--------------|------|
| Hermes Gateway | stdout/stderr (terminal) / journalctl | Runtime |
| WhatsApp Bridge | `/home/master/.hermes/platforms/whatsapp/bridge.log` | Ficheiro dedicado |
| LiteLLM Proxy | `pm2 logs litellm-proxy` | PM2 |
| Hermes Dashboard | `pm2 logs hermes-dashboard` | PM2 |
| systemd (gateway) | `journalctl -u hermes-gateway.service` | Systemd |

---

## 9. Ficheiros de Configuração Importantes

| Ficheiro | Descrição |
|----------|-----------|
| `~/.hermes/config.yaml` | Config principal Hermes (WhatsApp, platforms) |
| `/home/master/hermes-stack/litellm_config.yaml` | Config LiteLLM (modelos, routing, API keys) |
| `/etc/systemd/system/hermes-gateway.service` | Service file (enabled mas inactive) |
| `start-dashboard.sh` | Script PM2 para dashboard |
| `start_proxy.sh` | Script PM2 para LiteLLM |

---

## 10. Referência Rápida de Portas

| Porta | Serviço | Protocolo | Bind |
|-------|---------|-----------|------|
| 3000 | WhatsApp Bridge | HTTP | 127.0.0.1 (localhost) |
| 4000 | LiteLLM Proxy | HTTP | 0.0.0.0 |
| 8642 | Hermes Gateway | HTTP | 0.0.0.0 |
| 9119 | Hermes Dashboard | HTTP | 0.0.0.0 |

---

## 11. Próximos Passos (Para Edoardo)

1. **Investigar systemd:** `systemctl status hermes-gateway.service` → ver logs com `journalctl -u hermes-gateway.service -n 50`
2. **Corrigir persistência:** Activar e testar `hermes-gateway.service` para sobreviver a reboot
3. **Documentar aqui:** Após fix, actualizar [[GL-007-hermes-services-map]] com novo estado

---

*Actualizado: 2026-09-02*
*Próxima revisão: Após qualquer incidente ou mudança na infraestrutura*