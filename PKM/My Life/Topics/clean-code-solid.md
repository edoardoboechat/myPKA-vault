---
name: Clean Code & SOLID
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_session_logs:
  - 2026-08-29-11-37_hermes_mypka-integration
  - 2026-08-29-12-05_hermes_mypka-integration
linked_topics:
  - ddd-software-design
tags:
  - clean-code
  - solid
  - best-practices
  - code-quality
---

# Clean Code & SOLID

## O que é

Conjunto de princípios e práticas para escrever código que é legível, manutenível, e testável. Aplicado consistentemente no coingame.

## Clean Code — princípios

### Nomenclatura
- Nomes expressivos: `findUserById` em vez de `getUser`
- Variáveis booleanas com `is/has/can` prefix
- Constantes em UPPER_SNAKE_CASE
- Packages em kebab-case

### Funções
- Pequenas (< 20 linhas ideal)
- Uma responsabilidade
- Poucos parâmetros (< 3)
- Sem side effects escondidos

### Comentários
- "Why", não "what"
- Apenas onde não é óbvio
- Não duplicar o que o código diz

### Formatação
- 2 spaces indentation
- Linhas < 120 chars
- Imports agrupados (java.*, javax.*, project.*)

## SOLID — 5 princípios

### S — Single Responsibility
Cada classe tem uma única razão para mudar. Services só fazem uma coisa.

```java
// Bom
class CoinDetectionService { detect(), classify() }

// Mau
class CoinService { detect(), persist(), notify(), validate() }
```

### O — Open/Closed
Aberto para extensão, fechado para modificação. Usar interfaces e abstract classes.

### L — Liskov Substitution
Subtipos substituíveis por tipos base sem quebrar comportamento.

### I — Interface Segregation
Interfaces pequenas e coesas, não uma interface "faz tudo".

### D — Dependency Inversion
Depender de abstrações, não de implementações concretas.

## Aplicado no coingame

### Backend
- **Services** — uma classe por agregado
- **Controllers** — só delegam para services
- **Repositories** — JPA repositories separados por agregado
- **DTOs** — separados de domain entities
- **Exceptions** — excepções específicas, não genéricas

### Frontend
- **Componentes** — um componente por responsabilidade
- **CSS Modules** — estilos coesos por componente
- **Hooks** — lógica reutilizável em hooks
- **State** — mínimo, idealmente local

## Code review checklist

- [ ] Nomes expressivos?
- [ ] Funções pequenas?
- [ ] Sem comentários redundantes?
- [ ] Single Responsibility?
- [ ] Sem dependências desnecessárias?
- [ ] Testes para lógica complexa?
- [ ] Sem magic numbers?

## Anti-patterns

- God classes
- Deeply nested conditionals (> 3 levels)
- Boolean parameters (prefer strategy pattern)
- Speculative generality (código "para o futuro")
- Magic strings/numbers

## Cross-links

- [[ddd-software-design]] — design de domínio
- [[sdlc]] — processo de desenvolvimento
- [[coingame]] — Project hub
