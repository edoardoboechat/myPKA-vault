# Diretriz Crítica de Segurança: Proibição de Comandos Destrutivos Sem Confirmação Prévia

## Contexto
Qualquer operação que envolva remoção de ficheiros ou diretórios (`rm`, `rmdir`, etc.) no sistema do utilizador (`/home/master/` ou qualquer outro local) acarreta risco severo de perda de dados e configurações críticas.

## Regra Inquebrável (Zero-Destructive Actions Without Verification)
1. **Nunca executar `rm` (ou qualquer comando destrutivo) de forma cega ou baseada em suposições.**
2. **Sempre listar (`ls` ou comandos de inspeção equivalentes)** e apresentar o resultado ao utilizador antes de realizar qualquer exclusão.
3. **Exigir autorização explícita** do utilizador antes de apagar qualquer diretório ou ficheiro fora do diretório de build temporário de um projeto isolado.
4. O uso de curingas (`*`) ou caminhos que possam abranger múltiplos diretórios em operações de exclusão é estritamente proibido sem validação prévia detalhada.
