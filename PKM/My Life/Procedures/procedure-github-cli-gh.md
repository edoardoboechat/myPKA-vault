# Procedimento: Gestão e Validação do GitHub com GitHub CLI (gh)

## Propósito
Padronizar a utilização da ferramenta de linha de comandos `gh` para interagir com o GitHub, consultar o estado de workflows de CI/CD (GitHub Actions) e inspecionar pacotes publicados (GHCR) sem necessidade de recorrer ao browser.

## Comandos Principais
1. **Listar Workflows:**
   ```bash
   gh workflow list --repo <org>/<repo>
   ```
2. **Listar Execuções de Actions (Runs):**
   ```bash
   gh run list --repo <org>/<repo> --limit <num>
   ```
3. **Verificar Versões e Metadados de Pacotes/Imagens no GHCR:**
   ```bash
   gh api /user/packages/container/<package_name>/versions
   ```

## Diretrizes de Uso (Vigil Audit)
- Sempre que houver dúvidas sobre o sucesso de um build ou publicação de imagem Docker, utilize os comandos `gh run list` e `gh api` para validação programática rigorosa antes de reportar ao utilizador.
