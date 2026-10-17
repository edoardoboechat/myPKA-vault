---
name: tsk-2026-10-10-001-credit-system-and-portal-routing.md
title: "Implementação de Conta Corrente, Controle de Crédito e Futuro Roteamento no Portal"
status: pending
priority: 1
created_date: 2026-10-10
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks: []
linked_journal_entries: []
---

# Objectivo e Contexto Global
Implementar esquema de controle de crédito por usuário no `security-agent-portal`:
1. **Conta Corrente Individual**: Cada usuário possui conta corrente com créditos e débitos. O saldo nunca pode ser negativo.
2. **Página de Conta Corrente**: Filtros por período e tipo (crédito/débito), últimos 20 registros com paginação por scroll ao atingir o fim, ordenação da data mais recente para mais antiga.
3. **Listagem de Usuários**: Coluna de saldo atualizada com valores reais calculados (possível consolidação junto aos dados do usuário).
4. **Arquitetura Futura (Roteamento e Validação no Portal)**:
   - A app Android Security Agent enviará requisições de análise diretamente para o portal (substituindo o NGINX atual em Metris).
   - O portal validará:
     - O **PAT** (Personal Access Token) enviado pela app em relação ao usuário.
     - O **Saldo de Crédito** na conta corrente. Se positivo, debita o valor e roteia o pedido para o modelo.
5. **Restrições**: Validação com Playwright apenas se explicitamente solicitada pelo utilizador.
