---
created: 2026-09-06
type: journal
linked_topics: [[android-security-agent]], [[UI-UX]], [[Android-Icon]]
---

# Journal — 2026-09-06 (Manhã)

Sessão intensiva de aperfeiçoamento da aplicação **Android Security Agent**:
1. **Ícone da App (Launcher):** Criámos ícones PNG rasterizados em 5 densidades (mdpi até xxxhdpi) com o motivo de escudo + cadeado, garantindo compatibilidade total com instaladores e visualizadores sem crashar.
2. **Debug Logs:** Corrigimos o texto de estado vazio que estava hardcoded no Kotlin para "Sem logs para apresentar".
3. **Tela Inicial:** Adicionada a logo vetorial no ecrã de boas-vindas.
4. **Spinner de Riscos:** Resolvido o problema de visibilidade (texto preto sobre fundo escuro) com um layout customizado `spinner_item.xml` em branco, e actualizados os textos de rotulagem (LOW="todas", HIGH="críticas +").
5. **Toolbars:** Corrigida a visibilidade e o nome dos títulos em todas as activites usando `app:title` e `app:titleTextColor`.
