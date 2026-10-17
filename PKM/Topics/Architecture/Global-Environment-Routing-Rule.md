# Regra Global de Ambientes: Local (Terra) vs Produção (Metris)

Esta regra é **transversal e obrigatória** para todos os projetos do ecossistema myPKA / Hermes que envolvam serviços de backend (Spring Boot ou similares) com dependências de infraestrutura (Keycloak, PostgreSQL, Redis, etc.).

## Princípio Fundamental
Qualquer aplicação gerida pela equipa deve comportar-se de forma distinta consoante o seu contexto de execução:

1. **Contexto de Desenvolvimento (Local / Profile `local`):**
   * **Onde corre:** Na máquina de desenvolvimento (ex: UbuntuOllama) ou em testes locais via `mvn` / `java -jar`.
   * **Profile Spring:** Deve utilizar obrigatoriamente o profile `local`.
   * **Serviços Alvo:** Devem apontar para a infraestrutura partilhada de desenvolvimento localizada no **servidor Terra** (via rede Tailscale).

2. **Contexto de Produção (Metris / Sem profile `local`):**
   * **Onde corre:** No servidor de produção (**Metris**), alojado em containers Docker geridos na rede interna (`aether_net`).
   * **Profile Spring:** **Nunca** deve utilizar o profile `local`.
   * **Serviços Alvo:** Devem apontar para a infraestrutura local do **servidor Metris** (ex: Keycloak local em `aether_keycloak`, BD local, etc.).

---
*Registo oficial criado por Larry / Vigil para aplicação em todos os repositórios e instâncias do myPKA Vault.*
