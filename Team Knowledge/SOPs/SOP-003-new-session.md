---
created: 2026-09-08
type: sop
title: SOP-003 — New Session (Limpeza de Contexto LLM)
---

# SOP-003: New Session (Protocolo de Limpeza de Contexto)

## Objetivo
Definir o procedimento padrão quando o utilizador emite o comando **"new session"**, **"iniciar nova sessão"** ou **"limpar contexto"**.

## Distinção Importante
- **Wrap Up:** Fecho técnico completo (commits, push, logs de sessão, auditoria do Silas e Vigil).
- **New Session:** Esvaziamento rápido da janela de conversação (contexto do LLM) para iniciar um novo tópico sem carregar o histórico da conversa anterior.

## Passos de Execução Automática para "New Session"
1. **Confirmação de Integridade (Silas & Vigil):**
   - O agente valida rapidamente se existe algum estado crítico não salvo (se houver dúvidas, avisa o utilizador).
2. **Garantia de Preservação:**
   - Recordar explicitamente ao utilizador que **nenhum ficheiro local, repositório Git ou dados do myPKA vault são apagados**. Apenas a memória de curto prazo da conversa do LLM é limpa.
3. **Reset Limpo:**
   - O agente apresenta uma mensagem curta de confirmação a indicar que o contexto foi limpo e está pronto para receber a próxima instrução do utilizador.
