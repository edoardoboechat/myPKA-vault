---
id: ssh-access-remote-servers
title: SSH Access — Remote Servers Terra & Metris
default_owner: vigil
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_topics:
  - infrastructure-servers
tags:
  - ssh
  - terra
  - metris
  - remote-access
  - infra
version: "1.0"
changelog:
  - "2026-08-29 v1.0 — created by Vigil (Work Guardian)"
---

# SSH Access — Remote Servers Terra & Metris

**Owner:** vigil (Work Guardian)
**Triggered by:** need to access Terra or Metris for development, inspection, or deployment
**Output:** active SSH session to the target server
**References:** [[infrastructure-servers]], [[SOP-ssh-access-remote-servers]]

> Reusable by any agent. SOPs are skills — invoke this when you need shell access to either server.

---

## Quando usar

Activar este SOP quando:

- Precisas de_inspeccionar logs ou estado de containers Docker num dos servidores.
- Precisas de fazer deploy manual ou verificar o pipeline CI/CD em Metris.
- Precisas de validar alterações de infraestrutura em Terra.
- Precisas de configurar ou reinciar serviços Docker via `docker compose`.
- Precisas de verificar conectividade de rede entre serviços.
- Estás a preparar ambiente local contra serviços reais (Terra).
- Estás a fazer debugging de produção/staging (Metris).

---

## Pré-requisitos

Antes de iniciar, verifica:

1. **Chave SSH para Terra existe:**
   ```bash
   ls -la ~/.ssh/id_ed25519
   ```
   Se não existir, cria com: `ssh-keygen -t ed25519 -C "openclaw@terra" -f ~/.ssh/id_ed25519`

2. **Chave SSH para Metris existe:**
   ```bash
   ls -la ~/.ssh/metris_key
   ```
   Se não existir, cria com: `ssh-keygen -t ed25519 -C "openclaw@metris" -f ~/.ssh/metris_key`

3. **Configuração SSH em `~/.ssh/config`** — verifica com:
   ```bash
   cat ~/.ssh/config
   ```
   Deve conter entradas para `terra` e `metris`. Se não existirem, adiciona (ver secção Procedimento).

4. **Conectividade de rede:**
   - Para Terra: `ping -c 1 100.122.21.51` (Tailscale) ou `ping -c 1 192.168.10.138` (LAN)
   - Para Metris: `ping -c 1 metris.com.br`

5. **Agente SSH activo** (evita pedir password em cada comando):
   ```bash
   ssh-add ~/.ssh/id_ed25519
   ssh-add ~/.ssh/metris_key
   ```

---

## Procedimento

### Passo 0 — Configurar ~/.ssh/config (primeira vez)

Adiciona ao ficheiro `~/.ssh/config`:

```
# Terra — infraestrutura de rede e serviços de identidade
Host terra
    HostName 100.122.21.51
    User openclaw
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking accept-new
    ServerAliveInterval 60

# Metris — produção / staging
Host metris
    HostName metris.com.br
    User openclaw
    IdentityFile ~/.ssh/metris_key
    StrictHostKeyChecking accept-new
    ServerAliveInterval 60
```

### Passo 1 — Listar servidores disponíveis

```bash
cat ~/.ssh/config
```

Confirma que `terra` e `metris` aparecem com os aliases correctos.

### Passo 2 — Validar conectividade antes de conectar

```bash
# Testar Terra (Tailscale)
ping -c 1 100.122.21.51

# Testar Metris
ping -c 1 metris.com.br
```

Se o ping falhar, verifica: VPN ligada? Tailscale activo? DNS a resolver `metris.com.br`?

### Passo 3 — Conectar a Terra

```bash
ssh terra
```

- **Hostname real:** `100.122.21.51`
- **User:** `openclaw`
- **Chave:** `~/.ssh/id_ed25519`
- **Papel:** Desenvolvimento local + infra de identidade (Keycloak, Postgres, RabbitMQ, Redis)
- **Workspace:** `~/workspace/`

Uma vez conectado, verifica os serviços:

```bash
docker ps
sudo systemctl list-units --type=service --state=running | head -20
```

### Passo 4 — Conectar a Metris

```bash
ssh metris
```

- **Hostname real:** `metris.com.br`
- **User:** `openclaw`
- **Chave:** `~/.ssh/metris_key`
- **Papel:** Produção / Staging — backend coingame, Nginx, CI/CD pipeline
- **Workspace:** `~/workspace` (symlink → `/root/workspace`)

Uma vez conectado, verifica:

```bash
docker ps
sudo systemctl list-units --type=service --state=running | head -20
```

### Passo 5 — Sair da sessão

```bash
exit
```

---

## Comandos úteis

Executar **dentro da sessão SSH** em qualquer servidor:

```bash
# Listar todos os containers Docker activos
docker ps

# Listar todos os containers (incluindo parados)
docker ps -a

# Ver logs de um container específico
docker logs <container_name> --tail 50 -f

# Ver estado dos serviços systemd
sudo systemctl list-units --type=service --state=running

# Ver espaço em disco
df -h

# Ver memória e CPU
free -h && top -bn1 | head -10

# Listar conteúdo do workspace
ls -la ~/workspace/

# Ver versão do Docker e Docker Compose
docker --version && docker compose version

# Reiniciar stack de infra (Terra)
cd ~/workspace && docker compose -f docker-compose_infra.yml down && docker compose -f docker-compose_infra.yml up -d

# Ver logs do backend em produção (Metris)
docker logs aether_backend --tail 100 -f
```

---

## Boas práticas

1. **Não misturar ambientes.** Terra = dev/infra; Metris = produção/staging. Nunca correr testes pesados em Metris.

2. **Sudo requer password.** Ambos os servidores pedem password para `sudo`. Nunca automatizar sem confirmar que a operação é segura.

3. **Credenciais nunca em commits.** Variáveis de ambiente e credenciais vivem em `.env` local, nunca no repositório.

4. **Verificar antes de actuar.** Sempre correr `docker ps` e `docker logs` antes de reiniciar ou modificar containers.

5. **Tailscale para Terra.** Prefere o hostname Tailscale (`100.122.21.51`) em vez do IP LAN quando estiver fora de casa.

6. **Metris usa chave dedicada.** Não uses `id_ed25519` para Metris — usa `metris_key`. Configura correctamente em `~/.ssh/config` para evitar tentativas falhadas.

7. **Manter sessões curtas.** Não deixes sessões SSH abertas sem actividade prolongada. Usa `tmux` ou `screen` se precisares de persistência.

8. **Confirmar antes de restart.** Antes de `docker compose down/up`, confirma que não há deploys activos em curso.

### 🔒 Aviso de Segurança: Versionamento de Chaves SSH

**SSH keys nunca devem ser versionadas no repositório de código.**

- **Risco:** Chaves privadas em repositórios são alvos de ataques automatizados (credential stuffing, exploits em CI/CD).
- **SSOT:** Este SOP e o ficheiro `infrastructure-servers.md` são o SSOT autorizado para acesso SSH. Qualquer chave privada deve permanecer apenas em `~/.ssh/` local.
- **Guard Policy:** O sistema de segurança (Vigil) remove automaticamente informações de acesso SSH de locais não autorizados. Este SOP e o Topic `infrastructure-servers.md` estão explicitamente permitidos no vault.
- **Verificação:** Consulte [[2026-08-29-12-00_hermes_ssh-access-guard]] para detalhes da política de segurança e o rationale da remoção automática.

---

## Cross-links

- [[infrastructure-servers]] — Topic hub com detalhes de cada servidor, containers activos, e credenciais
- [[docker-and-workspaces]] — Docker, workspaces remotos
- [[coingame]] — Project hub
- [[ci-cd]] — Pipeline CI/CD (relevante para Metris)
- [[credentials-and-security]] — Gestão de credenciais e segurança
- [[SOP-ssh-access-remote-servers]] — Este SOP (auto-referência)
- [[2026-08-29-12-00_hermes_ssh-access-guard]] — Session log do guard que removeu acesso SSH não autorizado
