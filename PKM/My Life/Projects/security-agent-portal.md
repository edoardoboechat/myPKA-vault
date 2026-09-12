---
created: 2026-09-12
type: project-note
project: security-agent-portal
linked_topics: [[security-agent-portal]], [[android-security-agent]], [[infrastructure-servers]]
---

# Security Agent Portal — Project Note & Architecture

Este documento regista a arquitetura, as decisões de design, a stack técnica e o fluxo operacional do **Security Agent Portal**, criado para servir como suporte e API Gateway de validação para a aplicação **Android Security Agent**.

## 1. Visão Geral e Objetivos

O portal é o ponto central para:
- Apresentar a solução e os pilares de proteção da aplicação móvel.
- Gestão de autenticação de utilizadores baseada no **Keycloak** (existente no servidor Metris).
- Emissão, regeneração e gestão de **Personal Access Tokens (PAT)** que a app utiliza nos cabeçalhos dos pedidos (`pat-token`).
- Sistema de conta corrente de créditos (saldo de pedidos) para controlo e tarifação das chamadas de IA.
- Atuar como **API Proxy** que interceta os pedidos da app móvel, valida o PAT, o campo `source: "ag-sec-app"`, desconta o saldo de créditos no PostgreSQL e encaminha o tráfego legítimo para a Gateway de IA (`ubuntuollama:8643`).

## 2. Stack Tecnológica e Padrões de Código

- **Arquitetura Unificada ("All-in-One"):** Inspirada no modelo do projeto *coingame*. O Spring Boot empacota e serve a API e o Frontend estático num único ficheiro `.jar`, escutando na porta padrão.
- **Princípios Aplicados:** 
  - **DDD (Domain-Driven Design):** Isolamento de domínios (`domain`), casos de uso (`usecase`) e camadas de infraestrutura (`infrastructure`).
  - **SOLID:** Inversão de dependências e responsabilidade única em todos os componentes.
- **Stack:**
  - **Backend:** Spring Boot 3.x (Java 17+), Spring Web, Spring Data JPA / JDBC.
  - **Frontend:** Single-Page Application (HTML5 / Tailwind CSS moderno / JavaScript integrado no static do Spring).
  - **Base de Dados & Cache:** PostgreSQL (persistência de utilizadores, tokens e créditos) e Redis (cache e rate-limiting).

## 3. Diretrizes Operacionais e Regras de Execução

1. **Validação Rigorosa de Build e Deploy:**
   - Nenhum recurso é considerado concluído sem passar por uma build limpa de ponta a ponta (`mvn clean package -DskipTests`).
   - O servidor deve ser iniciado e testado localmente via ferramentas de diagnóstico (como `curl` ou testes visuais) antes de ser reportado como pronto.
2. **Ambiente de Destino (Metris):**
   - Integrado no ecossistema de servidores do Metris (`metris.com.br` para o frontend web e `api.metris.com.br` para os endpoints de API Gateway/Proxy).
