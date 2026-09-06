---
created: 2026-09-06
type: journal
linked_topics: [[android-security-agent]], [[UI-UX]], [[Android-Toolbar]], [[Dark-Mode]]
---

# Journal — 2026-09-06

Hoje resolvemos um bug crítico de visibilidade na aplicação Android Security Agent: a Toolbar de várias telas (Histórico, Apps Monitorizadas, Fontes Confiáveis, Debug Logs) mostrava sempre "Android Security Agent" em vez do título da secção, com texto invisível (preto sobre fundo cinza).

**Causa raiz:** usávamos `android:title` em vez de `app:title`. Em `androidx.appcompat.widget.Toolbar`, a propriedade `android:title` é ignorada — o título correto é `app:title`, e a cor deve ser `app:titleTextColor` (não `android:titleTextColor`).

**Mudanças:**
- Adicionámos `xmlns:app="http://schemas.android.com/apk/res-auto"` em todas as Toolbars das 4 telas afectadas.
- Usámos `app:title` com a string apropriada (`@string/history_title`, `@string/view_monitored_apps`, etc.).
- Usámos `app:titleTextColor="#FFFFFFFF"` (branco) para visibilidade.

**Lição importante:** Quando se trabalha com `androidx.appcompat.widget.Toolbar`, o namespace `app:` é essencial. Atributos `android:titleTextColor` são ignorados se `app:title` for usado.
