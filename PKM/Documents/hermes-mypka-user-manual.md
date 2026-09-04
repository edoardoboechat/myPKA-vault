# Manual do Utilizador — Hermes + myPKA

> Este manual explica como comunicar com o assistente de forma que ele use a arquitetura certa — vault, memória, skills, ou código — sem duplicar conhecimento nem violar o SSOT.

---

## Os 4 Domínios — O Essencial

O teu sistema tem **4 locais** onde o conhecimento vive. Cada um tem uma função:

| Domínio | Onde | O que vai lá |
|---|---|---|
| **PKM / Vault** | `/hermes-stack/myPKA-vault/` | O teu conhecimento pessoal: pessoas, projetos de vida, hábitos, journal, notas duráveis |
| **Memória** | `~/.hermes/memory/` | Facts sobre ti e o teu ambiente: preferências, credenciais, convenções, estado de projetos |
| **Skills** | `~/.hermes/skills/` | Procedimentos reutilizáveis: fluxos validados, comandos complexos, padrões testados |
| **Código** | `/hermes-stack/projects/` | Código real: coingame, infra, automações |

**Regra de ouro:** cada fact vive em **exatamente um** destes 4 sitios. Nunca duplicar.

---

## Como Falar — Semântica Básica

### triggering the right pattern

| O que dizes | O que acontece |
|---|---|
| `pesquisa X`, `faz research sobre Y` | Pax pattern: browser + search_files + síntese |
| `captura isto`, `anota isto`, `guarda isto` | Penn pattern: escreve no vault (Journal, CRM, PKM) |
| `automatiza X`, `faz um script para Y` | Mack pattern: terminal + process |
| `valida X`, `verifica conformidade` | Silas pattern: read_file + audit de frontmatter/schema |
| `cria isto como procedimento`, `regista como SOP` | Cria skill ou写入 SOP no vault |
| `wrap up`, `close session`, `we're done` | Larry pattern: escreve session-log no vault |
| `lembra-te disto`, `nota para a próxima sessão` | Memory update |
| `builda o coingame`, `mvn clean install` | Código: terminal no projeto |
| `delegação`, `usa subagente` | Orkiestração: delegate_task |

### o que NÃO dizer (e porquê)

| Evitar | Motivo |
|---|---|
| `guarda no vault E na memória` | Violação SSOT — cada fact num sitio só |
| `reescreve o vault` | O vault é o PKM do utilizador — nunca modificar sem pedido explícito |
| `usa tools nativas do Claude Code` | GL-005: nenhum harness name no vault |
| `ignora o que está na memory` | Memory é source of truth para facts sobre ti e ambiente |

---

## O Fluxo Day-to-Day

### Começo de sessão

1. O assistente verifica tasks em aberto (`todo` tool + vault `Team Knowledge/tasks/`)
2. Lê a memória (`memory`) para facts sobre ti e estado dos projetos
3. Carrega skills relevantes para o contexto atual
4. Se o vault myPKA está ativo, aplica o modelo mental Larry

### Durante o trabalho

- **Pessoa/organização nova:** diz "anota o contacto do dr-schmidt" → Penn pattern → `PKM/CRM/People/dr-schmidt.md` com frontmatter GL-002
- **Projeto de vida:** diz "quero追踪 isto como projeto de vida" → Goal + Project no vault
- **Nota durável:** diz "esta lição aplica-se a futuras sessões" → journal entry no vault
- **Procedimento novo:** diz "regista este fluxo como skill" → skill em `~/.hermes/skills/`
- **Fact sobre o teu ambiente:** diz "o backend do coingame corre em 100.122.21.51" → memory update

### Fecho de sessão

Diz `wrap up` ou `close session` → o assistente:
1. Escreve session-log no vault
2. Verifica duplicações SSOT
3. Atualiza memória com facts novos
4. Resume o que ficou pendente

---

## O PKM / Vault — O Que Vai Lá

### Pasta `PKM/Journal/`

Entrada diária de reflexões. Cada ficheiro: `YYYY-MM-DD-<tema>.md`.

**Quando usar:**
- Pensamentos que queres capturar para futuro
- Notas sobre reuniões ou decisões
- Screenshots ou imagens relacionadas com topics

**Como acionar:** "anota isto", "escreve no journal"

**Formato:** wikilinks para entidades existentes (`[[dr-schmidt]]`, `[[ai-tooling]]`).

### Pasta `PKM/CRM/People/` e `PKM/CRM/Organizations/`

Uma nota por pessoa ou organização. Frontmatter obrigatório (GL-002).

**Quando usar:** quando conheces uma pessoa nova ou interages com uma organização.

**Como acionar:** "cria uma nota para o João", "anota a clínica do dr-schmidt"

### Pasta `PKM/My Life/`

5 sub-pastas para organizar áreas da tua vida:

- **Key Elements** — paredes mestras (saúde, trabalho, dinheiro, relações). Estáveis.
- **Goals** — alvos mensuráveis ancorados a um Key Element. Têm data.
- **Projects** — esforços delimitados com fim. Levam um Goal.
- **Habits** — ritmos recorrentes. Mantêm um Key Element.
- **Topics** — áreas de interesse que ainda estás a explorar.

**Quando usar:**
- "quero perder 20kg" → Goal + Habit ou Project
- "estou a explorar French" → Topic (promove para Key Element quando cristalizar)
- "saúde" → Key Element (já existe, usa-o como âncora)

### Pasta `Team Knowledge/session-logs/`

Log de cada sessão de trabalho. Escrito pelo assistente no fecho.

**Formato:** template do `_template.md`. Campos obrigatórios em frontmatter.

**Como acionar:** diz "wrap up" ou "close session"

---

## A Memória — O Que Vai Lá

Facts sobre ti e o teu ambiente que o assistente precisa em **todas** as sessões:

- Preferências (conciso, respostas curtas, mobile-first)
- Identidade (Edoardo — nome real do utilizador)
- Credenciais (Keycloak, Postgres, RabbitMQ — todas `changeit`)
- URLs e portas (coingame: `100.122.21.51:8443`)
- Convenções (git flow, paleta escura, toast no bottom)
- Estados de projeto (branch atual, commits pendentes, processos ativos)

**Como atualizar:** o assistente faz isto automaticamente, mas podes dizer "lembra-te que..."

**O que NÃO vai na memória:**
- Notas sobre pessoas ou organizações → vault
- Procedimentos → skills
- Código → projects/

---

## Skills — O Que Vai Lá

Procedimentos validados e reutilizáveis que exigem múltiplos passos ou comandos.

**Características de uma boa skill:**
- Trigger claro (quando activar)
- Passos numerados
- Comandos exatos
- Como verificar que funcionou
- Armadilhas conhecidas

**Quando criar:**
- Fluindo de 5+ tool calls num padrão repetível
- Depois de descobrir um workaround para um erro
- Quando um procedimento novo se estabilizar

**Como acionar:** o assistente carrega skills automaticamente por contexto. Também podes dizer "usa a skill coingame-local-run"

---

## Coingame — Contexto Específico

### O que vai onde

| Facto | Onde |
|---|---|
| Build/test/validation commands | Skill `coingame-validation-workflow` |
| Credenciais (admin, pilot01) | Memory |
| Dev URL, porta, profile | Memory |
| UI patterns, paleta CSS | Skill `coingame-ledger-ux-patterns` |
| Código fonte | `/hermes-stack/projects/coingame/` |
| APK / JAR | `/home/master/` |
| Screenshots de validação | `/home/master/` |

### Fluxo típico

1. **Começar trabalho:** diz "vou mexer no coingame" → assistente carrega skills e memory
2. **Fazer mudanças:** código no repo, builds via `mvn clean package -DskipTests`
3. **Validar:** Playwright scripts em `~/hermes-stack/playwrite/coingame/`
4. **Commits:** o assistente pede aprovação antes de cada operação git
5. **Fecho:** session-log no vault + memory update se estado mudou

---

## Armadilhas a Evitar

1. **Não dizer "guarda em todo o lado"** — o assistente pode duplicar. Se ele perguntar "onde guardo?", aponta o sitio certo.

2. **Não pedir para reescrever o vault** — o vault é o teu PKM. O assistente nunca modifica sem pedir.

3. **Não misturar projectos pessoais com projectos de código** — coingame vai para `/projects/`, vida pessoal vai para `/vault/PKM/`.

4. **Não usar nomes de harnesses no vault** — "Claude Code", "Codex", "Cursor" não devem aparecer em ficheiros do vault. O assistente sabe isto, mas não forçar.

5. **Não pular o wrap up** — dizer "wrap up" no final garante que o session-log capta o que foi feito. Sem ele, perde-se continuidade.

6. **Não criar tasks sem contexto** — se criares uma task, diz qual o SOP relevante, qual o session log de origem, e qual o deliverable esperado.

---

## Referências Rápidas

### Pasta do vault
```
/home/master/hermes-stack/myPKA-vault/
├── PKM/
│   ├── Journal/YYYY/MM/         # diário
│   ├── CRM/People/              # pessoas
│   ├── CRM/Organizations/       # organizações
│   └── My Life/
│       ├── Key Elements/        # paredes mestras
│       ├── Goals/               # alvos
│       ├── Projects/            # esforços delimitados
│       ├── Habits/             # ritmos
│       └── Topics/             # interesses
├── Team Knowledge/
│   ├── SOPs/                   # procedimentos
│   ├── Workstreams/            # orquestrações multi-agente
│   ├── Guidelines/            # GL-001 a GL-005
│   ├── session-logs/YYYY/MM/  # logs de sessão
│   └── tasks/                 # sistema de tasks
└── Deliverables/              # artefactos de trabalho
```

### Pasta de projects
```
/home/master/hermes-stack/projects/
├── coingame/                  # backend Spring + frontend React
├── playwright/               # scripts de validação
└── [outros projectos]
```

### Pasta de skills
```
~/.hermes/skills/
├── system/mypka-hermes-integration/
├── devops/coingame-local-run/
├── devops/coingame-validation-workflow/
├── devops/coingame-frontend-ui/
├── git/prevent-master-work/
└── [outras skills]
```

---

## Quando Tiveres Dúvidas

> **"Onde devo guardar isto?"**

- É um fact sobre ti/ambiente? → **memória**
- É uma pessoa, organização, projeto de vida? → **vault PKM**
- É um procedimento reutilizável? → **skill**
- É código real? → **projects/**

> **"Não sei que semantic usar."**

Diz simplesmente o que precisas em linguagem natural. O assistente detecta o contexto e activa o padrão certo. A semântica ajuda, mas a intenção é sempre o que comanda.

---

*Manual criado em 2026-08-29 como resultado da integração myPKA + Hermes Agent.*
*Guardado em: `/home/master/hermes-stack/myPKA-vault/PKM/Documents/hermes-mypka-user-manual.md`*
