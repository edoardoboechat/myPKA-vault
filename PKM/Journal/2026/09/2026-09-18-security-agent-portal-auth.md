# Diário de Bordo do Penn — 2026-09-18

## Resumo da Sessão: Security Agent Portal
- **Atividade Principal:** Implementação e integração de 3 novas páginas (Login, Recuperação de Senha e Registo de Utilizador) no **Security Agent Portal**.
- **Detalhes Técnicos:**
  - Modularização em React (`frontend/src/views/`).
  - Suporte completo a internacionalização (i18n: PT e EN).
  - Design com foco em "Mobile-first" utilizando ícones padrão.
  - Fluxo integrado com o ícone de utilizador na barra de navegação da página inicial.
- **Ciclo CI/CD & Deploy:**
  - Build automatizado via Maven (`mvn clean install`).
  - PR criado, aprovado e fundido na branch `main`.
  - Imagem publicada no GitHub Container Registry (`ghcr.io`) e aplicada no servidor Metris através do ecossistema de Docker Compose.
- **Lições Aprendidas:**
  - Evitar `docker run` direto em serviços integrados no Metris para não quebrar a rede interna (`aether_net`) e o Nginx (`502 Bad Gateway`); manter sempre o uso via Docker Compose.
