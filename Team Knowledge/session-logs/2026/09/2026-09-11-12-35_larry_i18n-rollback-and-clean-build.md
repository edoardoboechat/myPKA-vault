---
agent_id: larry
session_id: 2026-09-11-larry-i18n-rollback-and-clean-build
timestamp: 2026-09-11T12:35:34Z
type: end-of-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
linked_tasks: []
linked_journal_entries: []
---

# Reversão de i18n instável, restauro do branch develop e build limpa do APK

## Contexto
Esta sessão começou com tentativas de ajustar a alternância dinâmica de idiomas (i18n) na aplicação Android Security Agent. As soluções anteriores causaram regressões de estado e problemas de ciclo de vida. O utilizador ordenou o descarte completo de todas as alterações não commitadas e o restauro do branch `develop` original e estável.

## O que foi feito
- Executado o reset limpo com `git checkout .` e `git clean -fd` no repositório `android-security-agent`, descartando todas as alterações não commitadas e restaurando a versão estável do commit `9b41d93`.
- Executada a compilação limpa do projeto com `./gradlew assembleDebug` (Exit 0, `BUILD SUCCESSFUL`).
- Gerado e verificado o APK estável em `app/build/outputs/apk/debug/app-debug.apk`.
- Executado o protocolo de limpeza de contexto (*New Session* / `SOP-003`) a pedido do utilizador.
- Concluído o Wrap Up protocolar com verificação de estado Git em todos os repositórios, confirmando que tudo se encontra limpo e seguro sem alterações pendentes.

## Decisões
- **Abortar tentativas avulsas de i18n em runtime:** A manipulação manual de Locale sem suporte nativo da Application causava loops e perda de estado. O branch `develop` foi mantido na sua versão base estável.

## O que não foi tocado
- Nenhuma alteração foi commitada ou enviada para repositórios remotos.
- O myPKA vault e os demais repositórios de infraestrutura permaneceram intactos.

## O que está pendente para o futuro
- Se houver interesse em voltar a implementar i18n futuramente, deverá ser seguido estritamente o padrão canónico do Android (`AppCompatDelegate.setApplicationLocales`) com arquitetura a nível de Application, em vez de patches isolados em Activities.

Journal: [[2026-09-11-i18n-rollback-and-clean-build]]
