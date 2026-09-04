---
agent_id: hermes
session_id: 2026-08-29-ssh-access-guard
timestamp: 2026-08-29T12:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks: []
linked_journal_entries: []
---

# Session Log — SSH Access Persistence in myPKA

## Context
O Hermes descobriu as instruções de acesso SSH em `~/.ssh/config` para os servidores **Terra** e **Metris**. O Vigil exigiu a preservação desse conhecimento no myPKA (SSOT) e no `MEMORY.md` do Hermes para assegurar reuso futuro sem depender apenas da máquina local.

## What we did
1. Lemos o ficheiro `~/.ssh/config` para obter os detalhes exactos das conexões.
2. Localizámos e actualizamos o ficheiro `PKM/My Life/Topics/infrastructure-servers.md` no myPKA com uma secção clara de **Acesso SSH** em tabela.
3. Actualizámos o `MEMORY.md` do Hermes com os detalhes de acesso SSH para os servidores.
4. Gerámos este session-log seguindo rigorosamente os padrões do myPKA.

## Decisions & Details
- **Terra:** alias `ssh terra`, hostname `100.122.21.51`, user `openclaw`, chave `~/.ssh/id_ed25519`.
- **Metris:** alias `ssh metris`, hostname `metris.com.br`, user `openclaw`, chave `~/.ssh/metris_key`.

## Next steps
- Manter o SSOT íntegro em alterações futuras de infraestrutura.
