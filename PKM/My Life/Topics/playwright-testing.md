---
name: Playwright Testing & Visual Validation
status: active
created: 2026-08-29
linked_projects:
  - coingame
linked_topics:
  - sdlc
  - ci-cd
tags:
  - playwright
  - testing
  - visual-validation
  - e2e
---

# Playwright Testing & Visual Validation

## O que é

Framework de automação E2E usado no coingame para testes e **validação visual obrigatória** sempre que o trabalho envolver ajustes no frontend.

## Localização dos scripts e screenshots

| Recurso | Caminho | Notas |
|---|---|---|
| **Scripts Playwright** | `~/hermes-stack/playwrite/coingame/` | Todos os scripts `.py` do projecto |
| **Screenshots / Prints** | `~/hermes-stack/playwrite/coingame/prints/` | **SEMPRE** gravar aqui, nunca em `/home/master/` |

### Convenção de prints (regra estrita)

Todos os testes Playwright **devem** gravar screenshots em `~/hermes-stack/playwrite/coingame/prints/`.

**Nunca** gravar screenshots em `/home/master/`, `/tmp/`, ou outras pastas. Esta regra garante:
- Isolamento por projecto (coingame, futuras apps, etc.)
- Reproducibilidade (qualquer operador sabe onde estão os artefactos)
- Limpeza do home directory
- Co-localização com os scripts que os geraram

**Padrão de path nos scripts:**

```python
import os
PRINTS_DIR = os.path.expanduser("~/hermes-stack/playwrite/coingame/prints")
SCREENSHOT_PATH = os.path.join(PRINTS_DIR, "proof_landing.png")
page.screenshot(path=SCREENSHOT_PATH)
```

## Scripts principais

| Script | Propósito | O que valida |
|---|---|---|
| `validate_pilot01.py` | Cross-screen validation | Login pilot01, captura home, ledger, profile |
| `capture_landing.py` | Landing screen capture | Hero panel, botões, layout sem cortes |
| `inspect_layout.py` | Layout dimensions | Altura do TopBar, colisão de elementos |
| `inspect_dom.py` | DOM tree inspection | Tamanho de H1, wrappers, flexbox |
| `capture_all_proofs.py` | Comprehensive audit | Captura 7 ecrãs (landing, home, ledger, inspection, tasks, admin-game, admin-users) |

## Regras de Validação Visual

1. **Obrigatório no Frontend:** Qualquer alteração no frontend (React PWA) **exige** captura de ecrã e validação visual antes do commit/PR.
2. **Vision Analyze:** Usar a ferramenta `vision_analyze` para inspecionar os screenshots gerados.
3. **Critérios de sucesso:**
   - TopBar com exactamente 1 linha (sem wrap, ~54px)
   - Toast notifications no `bottom-right` (`bottom: 24px; right: 24px`), nunca no topo cobrindo informações
   - Inputs com paleta escura (`var(--surface-card)`), nunca fundos brancos
   - Sem corte de texto ("encontr", títulos longos)

## Cross-links

- [[coingame]] — Project hub
- [[sdlc]] — SDLC (Fase 4: Validação)
- [[ci-cd]] — Pipeline local
