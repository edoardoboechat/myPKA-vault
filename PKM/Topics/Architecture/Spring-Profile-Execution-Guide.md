# Regras de Execução e Perfis (Profiles) no Spring Boot

Esta diretriz complementa a [[Global-Environment-Routing-Rule]] e define o comando exato de execução e empacotamento para os contextos de Desenvolvimento Local e Produção.

## 1. Contexto de Desenvolvimento Local (Servidor Terra)
Quando estiver a testar, validar ou executar o projeto (ex: Security Agent Portal) na sua máquina de desenvolvimento ou ambiente local, deve utilizar explicitamente o profile **`local`**.

* **Comando de Execução:**
  ```bash
  java -Dspring.profiles.active=local -jar target/backend-1.0-SNAPSHOT.jar
  ```
* **O que acontece:** O Spring Boot lê o ficheiro `application-local.yaml` e redireciona automaticamente todas as dependências de infraestrutura (como o Keycloak) para o **IP da Tailscale do servidor Terra** (`100.99.110.11`).

## 2. Contexto de Produção (Servidor Metris)
Em produção, a aplicação corre empacotada dentro da imagem Docker gerada pela GitHub Action e gerida pelo Docker Compose no servidor Metris.

* **Comando de Execução (Automático via container):**
  A imagem JAR arranca **sem** nenhum profile ativo.
* **O que acontece:** O Spring Boot utiliza o ficheiro padrão `application.yaml`, apontando diretamente para os serviços locais de produção no servidor Metris (`keycloak.moneyback.com.br` / rede `aether_net`).

---
*Registo oficial mantido por Larry / Vigil para padronização de build e run em todos os repositórios do myPKA.*
