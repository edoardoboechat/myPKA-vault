---
created: 2026-09-08
type: guideline
title: Regra Global de Execução e Comandos Imperativos
---

# Regra Global de Execução e Comandos Imperativos (Governança)

Esta diretiva aplica-se a todos os agentes e sessões do ecosistema myPKA e Hermes Agent.

## Princípio Fundamental: Exceção para Pedidos Explícitos / Imperativos

1. **Quando o utilizador der uma instrução direta e imperativa de ação** (ex: *"Faz o push"*, *"Faz o build"*, *"Apaga isto"*, *"Executa o comando X"*):
   - **Ação imediata:** O agente deve executar o pedido **sem pedir novas autorizações redundantes**. A própria frase imperativa já constitui a autorização explícita e direta para a execução técnica.

2. **Quando o utilizador explicar um tema, fizer uma pergunta genérica, levantar uma dúvida ou pedir uma análise/planeamento:**
   - **Ação imediata:** O agente deve explicar o que entendeu e apresentar o plano, **aguardando obrigatoriamente** a confirmação do utilizador antes de tocar em código ou efetuar alterações destrutivas/externas.
