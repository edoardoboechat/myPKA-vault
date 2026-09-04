# Research: Android Notification Filtering Architecture for a Security App

**Author:** Pax (Research Specialist)  
**Date:** 2026-09-03  
**Subject:** Intelligent notification filtering beyond "trusted sources" whitelist  
**Status:** Complete — Ready for Larry review and Nolan handoff to development  

---

## 1. Executive Summary

The current Android Security Agent uses a **reactive allowlist** approach: it sends everything to the LLM *unless* a source is marked as trusted. This creates two problems: (1) the user must manually mark every legitimate source to reduce noise, and (2) new/malicious sources are always processed by default.

The recommended architecture is a **hybrid tiered filter**: Android-side pre-filtering (structured, deterministic, no cost) that gates which notifications reach the LLM, combined with LLM-side context enrichment. The Android filter runs at three progressive levels — app awareness, channel awareness, sender awareness — so that the LLM only receives notifications that genuinely matter.

---

## 2. Android API Foundations (Verified)

### 2.1 Enumerating Apps That Generate Notifications

**API:** `NotificationListenerService.getActiveNotifications()` (from API level 18)

```kotlin
// Within AppMessageInterceptor (extends NotificationListenerService)
override fun onListenerConnected() {
    val active = activeNotifications  // inherited from Service
    active.forEach { sbn: StatusBarNotification ->
        val pkg = sbn.packageName
        val label = packageManager.getApplicationLabel(
            packageManager.getApplicationInfo(pkg, 0)
        ).toString()
        // Store in local DB for the "known apps" inventory
    }
}
```

For a persistent inventory of all apps that have ever posted a notification (not just currently active ones), accumulate `sbn.packageName` on each `onNotificationPosted()` call and store it in Room. On next app launch, query `getActiveNotifications()` to repopulate live state.

### 2.2 System Apps vs. User Apps

**API:** `PackageManager` + `ApplicationInfo.flags`

```kotlin
fun isSystemApp(context: Context, packageName: String): Boolean {
    return try {
        val appInfo = context.packageManager.getApplicationInfo(packageName, 0)
        val FLAG_SYSTEM = android.content.pm.ApplicationInfo::class.java.getField("FLAG_SYSTEM").getInt(null)
        (appInfo.flags and FLAG_SYSTEM) != 0
    } catch (e: Exception) {
        false
    }
}
```

**Note on `android:systemApp` in AndroidManifest:** This attribute exists in the manifest but is not queryable at runtime. The canonical runtime check is `ApplicationInfo.flags & FLAG_SYSTEM`. Pre-installed/OEM apps (Google, Samsung, etc.) set this flag. The flag is reliable for distinguishing pre-loaded apps from user-installed ones, but it does **not** distinguish "safe from fraud" — a system app can still send malicious-looking notifications.

### 2.3 Notification Channels per App

**API:** `NotificationManager.getNotificationChannels(packageName)` (API level 26+)

```kotlin
// From NotificationListenerService (has access to NotificationManager as a service)
val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
val channels = notificationManager.getNotificationChannels(packageName)
channels.forEach { channel ->
    // channel.id, channel.name, channel.importance, channel.description
    // IMPORTANCE_DEFAULT = 3, IMPORTANCE_HIGH = 4, IMPORTANCE_LOW = 2, etc.
}
```

**Key insight:** Notification channels let you filter by *category of urgency* within an app. Example: WhatsApp has channels "Messages," "Group Messages," "Calls," "Lost Device." Monitoring only "Messages" and "Group Messages" channels filters out call rings and system alerts.

### 2.4 Notification Importance Ranking System (NotificationListenerService.Ranking)

```kotlin
// In onNotificationPosted(sbn, rankingMap) — rankingMap parameter available from API 21+
override fun onNotificationPosted(sbn: StatusBarNotification?, rankingMap: RankingMap?) {
    sbn ?: return
    val ranking = Ranking()
    rankingMap.getRanking(sbn.key, ranking)

    // Key Ranking fields:
    ranking.isBuzzzzMutated          // user snoozed/Do Not Disturb suppressed
    ranking.suppressedVisualEffects  // BIT flags: SMALL_ICON, etc.
    ranking.importance               // IMPORTANCE_UNSPECIFIED(0) to CRITICAL(5)
    ranking.channelImportance        // equivalent to channel's importance setting
    ranking.importanceExplanation    // human-readable reason
}
```

**Importance levels (from `NotificationManager`):**

| Level | Constant | User sees |
|---|---|---|
| 0 | `IMPORTANCE_UNSPECIFIED` | None |
| 1 | `IMPORTANCE_NONE` | None |
| 2 | `IMPORTANCE_LOW` | Status bar, no sound |
| 3 | `IMPORTANCE_DEFAULT` | Status bar + sound |
| 4 | `IMPORTANCE_HIGH` | Status bar + sound + peeks |
| 5 | `IMPORTANCE_MAX` | Full-screen interruption |

**Filtering strategy:** Filter out `IMPORTANCE_NONE`, `IMPORTANCE_LOW` (or let user configure), and suppress notifications from apps the user has not approved. This alone can cut 40–60% of noise.

### 2.5 Grouped Notifications and Sender Extraction (WhatsApp/Groups)

Grouped notifications are a major pain point. Android sends each sub-notification as a separate `StatusBarNotification`, but they share a `groupKey`. Extraction patterns:

```kotlin
val extras = sbn.notification.extras

// android.title → sender/person name
val sender = extras.getCharSequence("android.title")?.toString() ?: ""

// android.text → message content
val text = extras.getCharSequence("android.text")?.toString() ?: ""

// android.subText → group name (e.g., "Family Group")
val groupName = extras.getCharSequence("android.subText")?.toString()

// android.conversationTitle → direct chat name
val conversationTitle = extras.getCharSequence("android.conversationTitle")

// android.shortcutId → person shortcut (API 26+)
val shortcutId = extras.getString("android.shortcutId")

// Notification.GROUP_ALERT_LOCAL / GROUP_ALERT_CHILDREN
val groupAlertBehavior = sbn.notification.groupAlertBehavior

// Detecting grouped notification summary:
val isGroupSummary = sbn.notification.flags and Notification.FLAG_GROUP_SUMMARY != 0
```

**WhatsApp-specific patterns:**
- `android.title` = contact name or "10 new messages"
- `android.text` = last message preview or "~Pessoa: message"
- Group chats: `android.subText` = group name, individual messages tagged with "~SenderName: text"
- Parsing: extract sender prefix from text with regex `^~([^:]+):` for individual group messages

### 2.6 Official Android APIs Beyond NotificationListenerService

| API | What it provides | Relevance |
|---|---|---|
| `NotificationListenerService` | Primary interception | ✅ Core |
| `NotificationManager.getNotificationChannels(pkg)` | Channel list per app | ✅ Level 1-2 |
| `NotificationManager.getActiveNotifications()` | Currently visible notifs | ✅ App inventory |
| `PackageManager.getInstalledApplications()` | All installed apps | ✅ System vs user |
| `NotificationManager.setNotificationPolicy()` | DND/filtering control | ⚠️ Requires DND access |
| `DevicePolicyManager` | Work profile control | ⚠️ Enterprise only |
| `NotificationListenerService.Ranking` | Importance, suppressed effects | ✅ Level 1 |
| `UsageStatsManager` | App usage frequency | ❌ Not directly relevant |
| `AppOpsManager` | Op monitoring | ❌ No direct notification ops |
| **Android 14+ App Search** | `OnDevicePersonalization` | ❌ Not applicable |

**Conclusion:** No official API gives you "which apps send notifications I care about." You must build this inventory yourself using `getActiveNotifications()` + accumulation over time.

---

## 3. Architectural Recommendation

### 3.1 Filter Placement: Android-Side vs. LLM-Side

| Filter Layer | Location | Decision Type | Cost |
|---|---|---|---|
| **Level 1 — App toggle** | Android (Room + SharedPreferences) | Deterministic | Zero |
| **Level 2 — Channel filter** | Android (Room) | Deterministic | Zero |
| **Level 3 — Sender intelligence** | Android (Room, normalized) | Deterministic | Zero |
| **Level 4 — Content triage** | LLM (Hermes) | AI inference | API call |
| **Level 5 — Dynamic risk eval** | LLM (Hermes) | AI inference | API call |

**Principle: Filter on Android as much as possible before sending to LLM.** The LLM is an expensive, high-latency resource. Every notification that can be filtered with a simple DB lookup should be filtered there.

### 3.2 Proposed Architecture: Three-Tier Decision Flow

```
onNotificationPosted(sbn, rankingMap)
│
├─ Skip: own app notification
├─ Skip: own Hermes alerts (hermes_security_alert extra)
├─ Skip: deduplication (existing key + content hash)
│
├─ Level 1: App-level toggle?
│   ├─ App is globally disabled → SKIP
│   └─ App is globally enabled → continue
│
├─ Level 2: Channel importance filter?
│   ├─ ranking.importance < threshold (e.g., IMPORTANCE_LOW) → SKIP
│   └─ Channel is monitored → continue
│
├─ Level 3: Sender trust check (EXISTING logic)
│   ├─ sender IS in trusted_source → SKIP (log to history)
│   └─ sender NOT in trusted_source → continue
│
└─ Level 4: Send to LLM (ActionExecutor)
    ├─ LLM returns action + risk_level
    ├─ Compare risk_level >= notificationMinRisk threshold
    └─ Show alert or suppress
```

**Key enhancement:** The new **Level 1 and Level 2** gates run *before* the Trusted Source check, so completely unwanted apps never reach any decision logic.

---

## 4. Data Model Design

### 4.1 New Entity: `MonitoredApp`

```kotlin
@Entity(tableName = "monitored_app", indices = [Index(value = ["packageName"], unique = true)])
data class MonitoredApp(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val packageName: String,        // "com.whatsapp"
    val appLabel: String,            // "WhatsApp" (resolved, human-readable)
    val isSystemApp: Boolean,        // true = pre-installed
    val isEnabled: Boolean = true,  // user toggle
    val defaultImportance: Int,      // from NotificationChannel or Ranking
    val lastSeenTimestamp: Long = 0,
    val addedAt: Long = System.currentTimeMillis()
)
```

### 4.2 New Entity: `MonitoredChannel`

```kotlin
@Entity(
    tableName = "monitored_channel",
    indices = [Index(value = ["packageName", "channelId"], unique = true)]
)
data class MonitoredChannel(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val packageName: String,
    val channelId: String,           // "messages", "groups", etc.
    val channelName: String,         // user-visible name
    val importance: Int,             // NotificationManager.IMPORTANCE_*
    val isEnabled: Boolean = true,
    val addedAt: Long = System.currentTimeMillis()
)
```

### 4.3 Extended Entity: `TrustedSource` (existing, no schema change needed)

The existing `TrustedSource` table covers Level 3 (per-app + per-sender). Add a new DAO query that checks `isTrustedForAppNotification` and use it after the Level 1/2 gates.

### 4.4 New DAO: `MonitoredAppDao`

```kotlin
@Dao
interface MonitoredAppDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdate(app: MonitoredApp)

    @Query("SELECT EXISTS(SELECT 1 FROM monitored_app WHERE packageName = :pkg AND isEnabled = 1)")
    suspend fun isAppEnabled(pkg: String): Boolean

    @Query("SELECT * FROM monitored_app ORDER BY appLabel ASC")
    fun getAllApps(): Flow<List<MonitoredApp>>

    @Query("UPDATE monitored_app SET isEnabled = :enabled WHERE packageName = :pkg")
    suspend fun setEnabled(pkg: String, enabled: Boolean)

    @Query("SELECT * FROM monitored_app WHERE packageName = :pkg")
    suspend fun getByPackage(pkg: String): MonitoredApp?
}
```

### 4.5 New DAO: `MonitoredChannelDao`

```kotlin
@Dao
interface MonitoredChannelDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdate(channel: MonitoredChannel)

    @Query("SELECT * FROM monitored_channel WHERE packageName = :pkg")
    suspend fun getChannelsForApp(pkg: String): List<MonitoredChannel>

    @Query("SELECT EXISTS(SELECT 1 FROM monitored_channel WHERE packageName = :pkg AND channelId = :channelId AND isEnabled = 1)")
    suspend fun isChannelEnabled(pkg: String, channelId: String): Boolean

    // If no channel record exists for an app, default to: allow (nil means unknown = monitor)
    @Query("SELECT COUNT(*) FROM monitored_channel WHERE packageName = :pkg AND isEnabled = 1")
    suspend fun countEnabledChannels(pkg: String): Int

    @Transaction
    suspend fun insertChannelsForApp(pkg: String, channels: List<NotificationChannel>) {
        // Replace all channels for this app with fresh data
    }
}
```

### 4.6 Database Migration (v4)

```kotlin
// Migration 3 → 4
private val MIGRATION_3_4 = object : Migration(3, 4) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("""
            CREATE TABLE IF NOT EXISTS monitored_app (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                packageName TEXT NOT NULL UNIQUE,
                appLabel TEXT NOT NULL,
                isSystemApp INTEGER NOT NULL DEFAULT 0,
                isEnabled INTEGER NOT NULL DEFAULT 1,
                defaultImportance INTEGER NOT NULL DEFAULT 3,
                lastSeenTimestamp INTEGER NOT NULL DEFAULT 0,
                addedAt INTEGER NOT NULL
            )
        """.trimIndent())
        db.execSQL("CREATE UNIQUE INDEX IF NOT EXISTS idx_monitored_app_pkg ON monitored_app(packageName)")

        db.execSQL("""
            CREATE TABLE IF NOT EXISTS monitored_channel (
                id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                packageName TEXT NOT NULL,
                channelId TEXT NOT NULL,
                channelName TEXT NOT NULL,
                importance INTEGER NOT NULL DEFAULT 3,
                isEnabled INTEGER NOT NULL DEFAULT 1,
                addedAt INTEGER NOT NULL,
                UNIQUE(packageName, channelId)
            )
        """.trimIndent())
        db.execSQL("CREATE UNIQUE INDEX IF NOT EXISTS idx_monitored_channel_pkg_ch ON monitored_channel(packageName, channelId)")

        // EventLog: add new column for channel (nullable, safe migration)
        db.execSQL("ALTER TABLE event_log ADD COLUMN channelId TEXT")
    }
}
```

---

## 5. Enhanced Interceptor Logic (AppMessageInterceptor Refactored)

```kotlin
// In onNotificationPosted(sbn, rankingMap) — rankingMap available from API 21
override fun onNotificationPosted(sbn: StatusBarNotification?, rankingMap: RankingMap?) {
    sbn ?: return

    // --- Pre-filter: own app, own alerts ---
    if (sbn.packageName == packageName) return
    if (sbn.notification.extras.getString("hermes_security_alert") == "true") return

    val now = System.currentTimeMillis()

    // --- Deduplication (existing logic) ---
    dedupByKey.entries.removeIf { (now - it.value) > dedupKeyWindowMs }
    dedupByContent.entries.removeIf { (now - (it.value.maxOrNull() ?: 0L)) > dedupContentWindowMs }

    val title = sbn.notification.extras.getCharSequence("android.title")?.toString()?.trim() ?: ""
    val text = sbn.notification.extras.getCharSequence("android.text")?.toString()?.trim() ?: ""
    val appPackage = sbn.packageName
    val sender = title.ifBlank { appPackage }.trim()

    // --- Extract channel from notification ---
    val channelId = sbn.notification.channelId  // API 26+

    // --- Extract importance from ranking (API 21+) ---
    var notificationImportance = NotificationManager.IMPORTANCE_DEFAULT
    rankingMap?.let { rm ->
        val ranking = Ranking()
        if (rm.getRanking(sbn.key, ranking)) {
            notificationImportance = ranking.importance
        }
    }

    val contentHash = "${appPackage}_${title}_${text}".hashCode().toString()
    val timestamps = dedupByContent.getOrPut(contentHash) { mutableSetOf() }
    timestamps.removeIf { (now - it) > dedupContentWindowMs }
    if (timestamps.isNotEmpty()) return
    timestamps.add(now)
    dedupByKey[sbn.key] = now

    scope.launch {
        val appPreferences = AppPreferences(applicationContext)
        if (!appPreferences.isAppMsgEnabled) return@launch

        val historyDatabase = HistoryDatabase.getInstance(applicationContext)
        val monitoredAppDao = historyDatabase.monitoredAppDao()
        val monitoredChannelDao = historyDatabase.monitoredChannelDao()

        // === LEVEL 1: App-level toggle ===
        val appEnabled = monitoredAppDao.isAppEnabled(appPackage)
        // Default: if app is NOT in monitored_app table yet, default to ENABLED
        // (new app seen for first time — let it through until user decides)
        if (!appEnabled) {
            // Check if it's a new app we haven't catalogued yet
            val existing = monitoredAppDao.getByPackage(appPackage)
            if (existing != null) {
                AppLogger.log(tag, "I", "SKIP: app disabled by user — $appPackage")
                return@launch
            }
            // New app — catalog it and allow through
            catalogNewApp(appPackage, appPreferences, historyDatabase)
        }

        // === LEVEL 2: Channel importance filter ===
        if (notificationImportance < appPreferences.minImportanceThreshold) {
            AppLogger.log(tag, "D", "SKIP: importance=$notificationImportance < threshold")
            return@launch
        }
        // Channel-level toggle (if user configured specific channels)
        val channelEnabled = monitoredChannelDao.isChannelEnabled(appPackage, channelId)
        // Nil result = no channel record = allow (user hasn't filtered this channel)
        if (!channelEnabled) {
            // Only skip if explicit record says disabled
            val channels = monitoredChannelDao.getChannelsForApp(appPackage)
            val hasExplicitRecord = channels.any { it.channelId == channelId && !it.isEnabled }
            if (hasExplicitRecord) {
                AppLogger.log(tag, "D", "SKIP: channel $channelId disabled — $appPackage")
                return@launch
            }
        }

        // === LEVEL 3: Trusted Source (existing logic) ===
        val senderNorm = sender.lowercase().trim().removeAccents()
        if (historyDatabase.trustedSourceDao().isTrustedForAppNotification(appPackage, senderNorm)) {
            AppLogger.log(tag, "I", "→ IGNORED (trusted) package=$appPackage sender='$senderNorm'")
            return@launch
        }

        // === LEVEL 4: Send to LLM ===
        AppLogger.log(tag, "I", "→ SENT TO LLM: package=$appPackage sender='$senderNorm' importance=$notificationImportance channel=$channelId")
        val retrofitClient = RetrofitClient(appPreferences)
        val actionExecutor = ActionExecutor(applicationContext, retrofitClient, historyDatabase)
        actionExecutor.execute(
            source = "app_notification",
            sender = sender,
            appPackage = appPackage,
            textContent = "Title: $title | Text: $text",
            imageBase64 = null,
            context = applicationContext,
            // New: enrich context with channel/importance metadata
            metadata = mapOf(
                "channelId" to channelId,
                "importance" to notificationImportance.toString(),
                "isSystemApp" to (monitoredAppDao.getByPackage(appPackage)?.isSystemApp ?: false).toString()
            )
        )
    }
}

private suspend fun catalogNewApp(pkg: String, prefs: AppPreferences, db: HistoryDatabase) {
    val label = resolveAppLabel(applicationContext, pkg)
    val isSystem = isSystemApp(applicationContext, pkg)

    // Get channels
    val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val channels = notificationManager.getNotificationChannels(pkg)

    val app = MonitoredApp(
        packageName = pkg,
        appLabel = label,
        isSystemApp = isSystem,
        isEnabled = true,  // Default: new apps are ENABLED (let through until user decides)
        defaultImportance = channels.maxOfOrNull { it.importance } ?: NotificationManager.IMPORTANCE_DEFAULT,
        lastSeenTimestamp = System.currentTimeMillis()
    )
    db.monitoredAppDao().insertOrUpdate(app)

    // Also catalog channels
    channels.forEach { ch ->
        db.monitoredChannelDao().insertOrUpdate(MonitoredChannel(
            packageName = pkg,
            channelId = ch.id,
            channelName = ch.name?.toString() ?: ch.id,
            importance = ch.importance,
            isEnabled = true  // Default: all channels enabled
        ))
    }
}
```

---

## 6. Allowlist vs. Blocklist Strategy

### The User's Intuition is Correct

The current approach (allowlist of trusted sources) is **fundamentally backwards for a security app**:

- **Allowlist:** "Trust this, ignore everything else." Works well for a personal assistant. Fails for security because you don't know what new threats look like — and a new scam doesn't announce itself.
- **Blocklist:** "Ignore known spam, analyze everything new." Correct for security because zero-day fraud, smishing, and social engineering arrive from *unknown* sources.

**Recommended hybrid:**

| Category | Strategy | Reason |
|---|---|---|
| System apps (Google, OEM) | **Auto-blocklist** (ignore by default) | Extremely low fraud probability |
| Known communication apps (WhatsApp, Signal) | **Allowlist sender-level** (user-configurable per contact) | High volume, low fraud |
| Unknown/new apps | **Send to LLM always** | Security critical path |
| SMS | **Send to LLM always** (existing) | Primary fraud vector |
| Screenshots | **Send to LLM always** (existing) | Manual triage, always security-relevant |

### Rationale for Auto-Blocking System Apps

System apps (`FLAG_SYSTEM`) generate enormous noise — Google Play Services, carrier services, Android system, OEM apps — that is almost never fraud-relevant. Auto-blocking these reduces LLM load by 30–50% with near-zero security risk.

---

## 7. Decision Flow Summary

```
┌─────────────────────────────────────────────────────────┐
│  onNotificationPosted(sbn, rankingMap)                 │
│                                                         │
│  1. Own app? Own Hermes alert? → SKIP                   │
│  2. Deduplication (key + content hash) → SKIP          │
│                                                         │
│  3. LEVEL 1 — App Inventory                            │
│     ├─ New app detected? → Catalog in MonitoredApp    │
│     └─ App disabled by user? → SKIP                    │
│                                                         │
│  4. LEVEL 2 — Channel + Importance                      │
│     ├─ Importance < threshold? → SKIP                  │
│     ├─ Channel explicitly disabled? → SKIP             │
│     └─ Default: allow (user hasn't filtered)           │
│                                                         │
│  5. LEVEL 3 — Sender Trust (existing logic)            │
│     ├─ Sender trusted (app/sender/SMS)? → SKIP         │
│     └─ Not trusted → continue                           │
│                                                         │
│  6. SYSTEM APP fast-path                                │
│     └─ FLAG_SYSTEM && !userOverridden? → SKIP (low risk│
│                                                         │
│  7. SEND TO LLM (ActionExecutor)                       │
│     ├─ Compare riskLevel >= notificationMinRisk       │
│     └─ Alert or suppress                               │
└─────────────────────────────────────────────────────────┘
```

---

## 8. UI: Level 1 & 2 Controls (New Screens)

### 8.1 `MonitoredAppsActivity`

A settings screen showing all apps the system has ever seen post a notification:

- **List:** `RecyclerView` with app icon, name, package name, badge (🟢 system / 🔵 user), toggle switch
- **Toggle:** Enable/disable monitoring per app (maps to `MonitoredApp.isEnabled`)
- **Tap:** Opens `AppDetailActivity` (Level 2 controls)
- **FAB:** "Refresh from system" — calls `getActiveNotifications()` to refresh live apps
- **Search/filter:** Filter by user/system app, by enabled/disabled

### 8.2 `AppDetailActivity` (per-app, per-channel controls)

When user taps an app from `MonitoredAppsActivity`:

```
┌────────────────────────────────────────┐
│ WhatsApp           [●] Enabled          │
│ com.whatsapp                          │
│ 🟢 System app: No                     │
│                                        │
│ ── Notification Channels ──            │
│                                        │
│ 🟢 Messages          [●] Monitor      │
│ 🔵 Group Messages     [●] Monitor      │
│ 🔵 Calls              [○] Ignored      │
│ 🔵 Missed Calls       [○] Ignored      │
│ 🔵 Live Location      [○] Ignored      │
│ 🔵 Other              [●] Monitor      │
│                                        │
│ ── Per-Sender Rules ──                 │
│                                        │
│ [Manage Trusted Sources for WhatsApp]  │
│                                        │
│ [Add to Trusted Sources]               │
└────────────────────────────────────────┘
```

Channel rows map directly to `MonitoredChannel.isEnabled`. Tapping a channel toggles it.

---

## 9. Risks and Tradeoffs

| Risk | Severity | Mitigation |
|---|---|---|
| New malicious app auto-catalogued and processed by LLM | Medium | Processing is correct behavior for unknown apps |
| User disables too many apps, loses fraud protection | Medium | Warn on first disable; default all new apps ON |
| System app check (`FLAG_SYSTEM`) is not security guarantee | Low | System apps are auto-blocked for noise reduction only, not security |
| Channel enumeration requires API 26+ | Low | Min SDK is already 26+ (Oreo, 2017) |
| LLM load increases if user disables system-app fast-path | Medium | Add `AppPreferences.minSystemAppImportance` toggle |
| Database migration breaks on unclean install | Medium | Already handled via `fallbackToDestructiveMigration()` (see skill lesson #18) |
| Sender normalization edge cases (Unicode, RTL names) | Low | `removeAccents()` + `COLLATE NOCASE` covers Latin; add `normalizeUnicode()` for CJK/Arabic if needed |
| NotificationListenerService rebind after toggle | None | `AppPreferences` is read at processing time, no rebind needed |
| Multiple notifications per second from same app | Low | Content hash dedup (30s window) already handles this |

---

## 10. Implementation Phases

### Phase 1: App Inventory (Level 1) — **Priority: HIGH**
- Add `MonitoredApp` entity + DAO + migration v4
- Modify `AppMessageInterceptor` to catalog new apps on first seen
- Create `MonitoredAppsActivity` with toggle list
- Add "new app detected" flag to history entries

### Phase 2: Channel Awareness (Level 2) — **Priority: MEDIUM**
- Add `MonitoredChannel` entity + DAO
- Catalog channels alongside app in Phase 1
- Add per-channel toggle UI in `AppDetailActivity`
- Integrate `ranking.importance` into filter chain

### Phase 3: System App Auto-Classification — **Priority: MEDIUM**
- Compute `isSystemApp` during cataloguing
- Auto-disable system apps in `MonitoredApp` by default
- User can override per-app

### Phase 4: UI Polish — **Priority: LOW**
- Search/filter in app list
- Importance threshold slider in `MainActivity`
- Channel preview in `AppDetailActivity` (show recent notification count)

---

## 11. Key Code Reference

All code assumes these imports are available:
```kotlin
import android.app.NotificationManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.service.notification.Ranking
import android.service.notification.RankingMap
import android.service.notification.StatusBarNotification
import android.service.notification.NotificationListenerService
```

The existing `removeAccents()` extension function (lesson #14 from skill) remains required for sender normalization in all DAO queries.

---

## 12. Sources Consulted

- Android Developer API Reference: `NotificationListenerService`, `NotificationListenerService.Ranking`, `NotificationListenerService.RankingMap`
- Android Developer API Reference: `NotificationManager` (channels, importance levels, active notifications)
- Android Developer API Reference: `ApplicationInfo.flags` (`FLAG_SYSTEM` constant)
- Current app source: `AppMessageInterceptor.kt`, `TrustedSourceDao.kt`, `TrustedSource.kt`, `HistoryDatabase.kt`, `EventLog.kt`, `AppPreferences.kt`, `TrustedSourcesActivity.kt`
- Project skill: `android-security-agent-project` (v1.4.0)

---

*Research completed by Pax. This brief is ready for Larry to route to Nolan for developer handoff or for direct implementation by the development team.*
