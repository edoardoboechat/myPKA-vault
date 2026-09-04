---
name: DDD — Domain-Driven Design
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_session_logs:
  - 2026-08-29-11-37_hermes_mypka-integration
  - 2026-08-29-12-05_hermes_mypka-integration
linked_topics:
  - clean-code-solid
  - sdlc
tags:
  - ddd
  - architecture
  - domain
  - software-design
---

# DDD — Domain-Driven Design

## O que é

Metodologia de design de software que coloca o modelo de domínio no centro. No coingame, o domínio é o jogo AR: jogadores, sessões, scans, moedas, inventário, recompensas.

## Conceitos aplicados ao coingame

### Entidades

- **Player** — jogador com sessão activa
- **GameSession** — sessão de jogo com tempo válido e timeout de inactividade
- **Coin** — moeda escondida no mundo real
- **Scan** — scan de realidade aumentada feito pelo jogador
- **Inventory** — inventário do jogador com moedas encontradas

### Agregados

- **GameSession** — agrega Player + estado de jogo + tempo
- **Coin** — entidade isolada com localização

### Value Objects

- **Location** — coordenadas GPS + raio de detecção
- **SessionToken** — token de autenticação JWT

### Regras de domínio

- Sessão só é válida dentro do período `sessionStart` + `sessionDuration`
- Sessão expira após `inactivityTimeout` sem interacção
- Moedas só são encontradas dentro do raio de detecção
- Cada scan tem cooldown de 30 segundos

## Estrutura do código

```
backend-spring/
├── src/main/java/.../domain/
│   ├── model/          # Entidades e value objects
│   ├── service/        # Lógica de domínio
│   ├── repository/     # Persistência
│   └── event/         # Eventos de domínio
├── src/main/java/.../application/
│   └── usecase/       # Casos de uso
└── src/main/java/.../infrastructure/
    └── persistence/    # JPA repositories
```

## Porque DDD no coingame

- **Complexidade de domínio real:** scans ao vivo, geolocalização, tempo de jogo
- **Regras de negócio centralizadas:** não espalhadas pelos controllers
- **Evoluável:** novas features (power-ups, missões) encaixam no modelo
- **Testável:** lógica de domínio pura, sem dependências de framework

## Anti-patterns

- Anemic domain model (objetos só com getters/setters)
- Logic in controllers
- JPA entities que são também domain objects
- Violação de agregados (referências directas entre agregados)

## Cross-links

- [[clean-code-solid]] — práticas de código limpo
- [[sdlc]] — processo de desenvolvimento
- [[coingame]] — Project hub
