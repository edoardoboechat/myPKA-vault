# Auditoria de Conhecimento — Vigil (myPKA)
**Data:** 2026-09-13
**Projeto:** Security Agent Portal / Metris Server Infrastructure
**Assunto:** Isolamento de Certificados SSL (Certbot) por Domínio de Topo e Roteamento NGINX

## Lições Aprendidas e Consolidação
1. **Isolamento de Certificados por Domínio:** Quando um servidor aloja múltiplos domínios de topo distintos (ex: `moneyback.com.br` vs `metris.com.br`), utilizar uma única instância do Certbot com a mesma zona DNS para todos pode causar conflitos ou falhas de wildcard. A solução robusta validada foi criar um serviço dedicado no compose (`certbot_metris`) focado na zona específica do novo domínio (`metris.com.br`), mantendo o ecossistema original 100% isolado e intacto.
2. **Segurança de Borda no NGINX:** A adição de novos blocos `server` para portas `80` e `443` deve ser feita apontando o `proxy_pass` exclusivamente para nomes de serviços internos na rede Docker compartilhada (`aether_net`), evitando a exposição desnecessária de portas para o host (`ports: [...]`).
3. **Disciplina de Git no Metris:** Respeitar a regra de que o utilizador `root` (via `sudo`) utiliza Deploy Keys de leitura, enquanto o utilizador padrão possui a chave SSH pessoal com permissões de escrita, exigindo que o `git push` seja sempre executado sem `sudo`.
