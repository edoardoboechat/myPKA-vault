# Infra Critical - Guidelines de Segurança

**Guideline registado por:** Vigil (Hermes Agent)
**Data:** 2026-09-01
**Responsável:** Edoardo

## Regra Principal
**NUNCA mexer em configurações de infra crítica sem pedido explícito do Edoardo.**

## Ficheiros e Componentes Proibidos
- litellm_config.yaml
- Configurações do Hermes (env, profiles)
- systemd
- pm2 (processos específicos):
  - litellm-proxy
  - hermes-dashboard
  - openclaw-gateway
  - hermes-gateway
- WhatsApp bridge
- API server
- nginx
- /etc/* (todos os ficheiros nesta diretoria)
- Pipeline de fallback

## Procedimentos Obrigatórios
- **Alertar sempre antes de alterar** qualquer configuração mencionada acima
- **Nunca** incluir placeholders do tipo 'gsk_...' nos ficheiros de configuração
- **Nunca** escrever placeholders genéricos — sempre preencher com valores reais e específicos

## Responsabilidade
- **Edoardo** é o único autorizado a solicitar alterações nestas configurações críticas
- Qualquer tentativa de modificação não autorizada deve ser imediatamente reportada

---
*Nota: Este guideline foi criado automaticamente pelo Vigil (Hermes Agent) a pedido do Edoardo para garantir a integridade da infraestrutura crítica.*