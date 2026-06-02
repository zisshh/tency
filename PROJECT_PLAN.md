# tency — Project Plan v0.1

> A private, colorful, minimalist habit tracker for iOS — heatmap-first, widget-driven, themeable.
> Built for **rits** to use on **iPhone 17 Pro**. Personal use, no App Store distribution.

---

## 1. Identity

| Field | Value |
|---|---|
| **App name** | tency *(short for "consistency")* |
| **Bundle ID** | `com.divs.tency` |
| **Target user** | Just you (single-user, personal install) |
| **Platform** | iOS only (iPhone — no iPad / Mac for v1) |
| **Tagline** | *"Show up. Color the grid."* |

---

## 2. Goals & Non-Goals

**Goals**
- Reduce ADHD/procrastination by making "did I do it today?" instantly visible on the Home Screen
- A heatmap that's so satisfying to fill in that checking the app feels like a reward
- Multi-habit, multi-category, fully colorful, theme-able
- Minimal friction: 1-tap check-in from a widget

**Non-goals (for v1)**
- ❌ Multi-device sync (no iCloud — skipped per your call)
- ❌ Shortcuts/Siri (skipped)
- ❌ Negative habits (skipped)
- ❌ Social / sharing / accountability
- ❌ App Store distribution
- ❌ TestFlight (requires paid dev account)

---

## 3. Constraints (the real-world tradeoffs)

| Constraint | What it forces |
|---|---|
| **Free Apple ID signing** | App signature expires every **7 days** → you'll need to plug into Mac and re-deploy weekly via Xcode. Acceptable for personal use. |
| **No paid Apple Dev** | No CloudKit/iCloud sync. App Groups still work locally. Push notifications limited (local notifications are fine — that's all we need). |
| **Xcode 16.4 SDK = iOS 18.5 max** | Your iPhone 17 Pro runs iOS 26. **Deploying to your real device may need either (a) updating Xcode to latest, or (b) adding device support files manually.** We'll dev/test on the iOS 18 simulator and resolve this when v1 is ready. ⚠️ **Flagging early so we're not surprised.** |
| **No remote backup** | If you delete the app, data is gone. We'll add a **local JSON export** to Files app as a safety net. |

---

## 4. Feature Scope (your priorities, locked in)

| # | Feature | Priority | Notes |
|---|---|---|---|
| 1 | Heatmap calendar grid | **MUST** | The headline. Year-view + scrollable. |
| 2 | Home Screen widgets (S/M/L) | **MUST** | Per-habit. Interactive (tap-to-checkin). |
| 3 | Track amounts (minutes, count, custom unit) | **MUST** | Heatmap intensity reflects amount. |
| 4 | Streaks + consistency % | **MUST** | Current streak, best streak, % over window. |
| 5 | Local reminders/notifications | **MUST** | Per-habit time, days-of-week. |
| 6 | Multiple habits + categories | **MUST** | Categories for grouping. |
| 7 | Dark mode | **MUST** | Both light & dark fully themed. |
| 8 | Per-habit colors | **MUST** | Pick from active theme's palette. |
| 9 | **Themes (Gruvbox + more)** | **MUST** | See §6. |
| 10 | Lock Screen widgets | NICE | After v1. |
| 11 | Control Center widgets | NICE | iOS 18+ feature. After v1. |
| 12 | Notes/journal per check-in | NICE | After v1. |
| 13 | Charts / analytics view | NICE | After v1. Apple Swift Charts is free. |
| 14 | iCloud sync | **SKIP** | Needs paid dev account. |
| 15 | Shortcuts / Siri | **SKIP** | Skipped per your call. |
| 16 | Negative habits | **SKIP** | Skipped per your call. |

---

## 5. Tech Stack & Architecture

| Layer | Choice | Why |
|---|---|---|
| Language | **Swift 6.1** | Latest, strict concurrency. |
| UI | **SwiftUI** (iOS 17+ APIs) | Less boilerplate, widgets share views. |
| Persistence | **SwiftData** | Apple's modern Core Data wrapper; macros = clean models. |
| Widgets | **WidgetKit + AppIntents** | Required for interactive widgets. |
| Notifications | **UNUserNotificationCenter** | Local, free, no dev account needed. |
| Animations | **SwiftUI + Core Animation** | Ripple tap effect, transitions. |
| Charts (later) | **Swift Charts** | Apple's native chart framework. |
| Project gen | **XcodeGen** | YAML-defined project — no `.xcodeproj` merge hell. |
| Build pretty-print | **xcbeautify** | Readable `xcodebuild` output. |
| Formatting | **swift-format** | Apple-official formatter. |
| Linting | **SwiftLint** | Catches bad patterns. |
| Min iOS target | **iOS 17.0** | SwiftData + interactive widgets need this. |

**Module structure:**
```
tency/
├── project.yml                    # XcodeGen spec
├── Tency/                         # Main iOS app target
│   ├── App/                       # @main, navigation root
│   ├── Models/                    # SwiftData @Model types
│   ├── Features/
│   │   ├── HabitList/             # Home screen list
│   │   ├── Heatmap/               # The grid view + cells
│   │   ├── HabitDetail/           # Per-habit stats + history
│   │   ├── AddHabit/              # Create/edit flow
│   │   ├── Categories/            # Category manager
│   │   ├── Settings/              # Theme picker, prefs, export
│   │   └── Themes/                # Theme catalog + engine
│   ├── Core/                      # Streak/consistency calc, date utils
│   ├── Services/                  # Notifications, persistence shim
│   └── Resources/                 # Assets, fonts, app icon
├── TencyWidget/                   # Widget extension target
│   ├── TencyWidget.swift          # WidgetBundle
│   ├── HeatmapWidget.swift        # The main widget
│   └── CheckinIntent.swift        # AppIntent for tap-to-checkin
├── TencyShared/                   # Swift Package — shared between app + widget
│   ├── Models/                    # SwiftData schema (shared)
│   ├── Themes/                    # All theme definitions
│   └── Heatmap/                   # Heatmap rendering logic
└── Tests/
    └── TencyTests/
```

**App ↔ Widget data sharing:** App Group `group.com.divs.tency` with shared SwiftData store URL.

---

## 6. Color System & Themes

The defining visual element. Each theme provides:
- `background`, `surface`, `surfaceElevated` (neutrals)
- `textPrimary`, `textSecondary`
- A **palette of 8–12 accent colors** the user picks from for each habit
- Each accent color generates a **5-step heatmap intensity scale** (empty → low → med → high → very-high)
- Light and dark variants

**Themes shipping in v1:**

| Theme | Vibe | Inspired by |
|---|---|---|
| **Gruvbox Dark** | Warm retro earthy | the Vim/terminal classic |
| **Gruvbox Light** | Cream paper + warm pops | " |
| **Catppuccin Mocha** | Pastel dark | very popular dev theme |
| **Catppuccin Latte** | Light pastel | " |
| **Nord** | Cool arctic blue/teal | another dev classic |
| **Tokyo Night** | Deep neon-noir | " |
| **Rosé Pine** | Muted vintage | " |
| **System** | Follows iOS accent colors | Apple-native fallback |

Each accent in a theme = a habit color choice. So in Gruvbox you'd pick from `red / orange / yellow / green / aqua / blue / purple / gray` — and each has a known light/dark hex.

**Heatmap intensity formula (per cell):**
```
ratio = min(amount / target, 1.0)
step  = floor(ratio * 4)     // 0..4
color = lerp(theme.surface, habit.color, [0.15, 0.35, 0.6, 0.85, 1.0][step])
```

You can swap themes anytime — habit colors remap by semantic name (`red → red`).

---

## 7. UI Screens

Tab bar (**2 tabs**): **Habits · Settings**

```
┌─────────────────────────────────────────┐
│ HabitsView (default tab — "home")        │
│  • Sticky header: today's date + small  │
│    "X of Y habits done today" pill       │
│  • Categories as horizontal chips        │
│    (tap to filter)                       │
│  • Quick-check row: today's habits as    │
│    chips → tap to +1 / mark done         │
│  • Below: each habit as a card with      │
│    full-width year heatmap, scrollable   │
│  • Bottom-right: floating + button to    │
│    add a habit                           │
├─────────────────────────────────────────┤
│ HabitDetailView (push from Habits)       │
│  • Big heatmap (multi-year scrollable)  │
│  • Current streak / best / consistency  │
│  • Days-of-week breakdown                │
│  • Edit / Archive / Delete               │
├─────────────────────────────────────────┤
│ AddHabitFlow (sheet)                     │
│  • Name + icon (auto-suggested SF        │
│    Symbol by name) + color               │
│  • Type: count / amount                  │
│  • Target per day + unit                 │
│  • Category                              │
│  • Reminder time (optional)              │
├─────────────────────────────────────────┤
│ SettingsView                             │
│  • Theme picker (live preview)           │
│  • Week starts on (Sun/Mon)              │
│  • Manage categories                     │
│  • Export data (JSON to Files)           │
│  • About                                  │
└─────────────────────────────────────────┘
```

**Note:** No separate "Today" tab — `HabitsView` itself is today-aware. Today's checked/unchecked status lives at the top of the screen as a quick-action row, so you can do a 1-tap daily sweep without navigating anywhere.

---

## 8. Data Model

```swift
@Model class Habit {
  var id: UUID
  var name: String
  var icon: String        // SF Symbol name
  var colorKey: String    // semantic key, resolved via theme (e.g. "red", "blue")
  var kind: HabitKind     // .binary | .amount
  var targetPerDay: Double
  var unit: String?       // "min", "ml", "page", etc. nil if binary
  var category: Category?
  var reminderTime: Date? // time-of-day only
  var reminderDays: Int   // bitmask 0..127 for Mon-Sun
  var createdAt: Date
  var archivedAt: Date?
  @Relationship(deleteRule: .cascade) var checkins: [CheckIn]
}

@Model class CheckIn {
  var id: UUID
  var habit: Habit
  var date: Date          // start-of-day in user's calendar
  var amount: Double      // 1.0 for binary, actual value for amount
  var note: String?       // for later
  var createdAt: Date
}

@Model class Category {
  var id: UUID
  var name: String
  var colorKey: String
  var icon: String
  var sortOrder: Int
}

// Theme + preferences live in UserDefaults (not SwiftData)
// because they don't need history.
```

---

## 9. Build Pipeline

- **Generate project:** `xcodegen generate`
- **Build (sim):** `xcodebuild -scheme Tency -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build | xcbeautify`
- **Run on sim:** `open -a Simulator && xcrun simctl install booted ...`
- **Run on device:** Open in Xcode, plug iPhone in, hit ▶ (re-do every 7 days)
- **Lint:** `swiftlint --strict`
- **Format:** `swift-format format --in-place --recursive Tency/`

I'll add `Makefile` shortcuts so you don't need to remember any of this:
```
make gen      # regenerate Xcode project
make build    # build for simulator
make run      # build + run on booted simulator
make lint     # swiftlint
make fmt      # swift-format
make clean    # nuke DerivedData
```

---

## 10. Build Phases (Checkpoints)

You picked **(b) checkpoint mode** — I'll pause after each phase for your review.

| Phase | Deliverable | What you'll see |
|---|---|---|
| **0** | **Project bootstrap** | `xcodegen generate` produces a clean project. App launches in simulator, shows empty state with the active theme. **No data yet.** |
| **1** | **Data model + Add Habit + Habit list** | Tap +, create a habit, see it in a list. SwiftData persists across launches. |
| **2** | **Heatmap rendering** | Year-view heatmap for each habit. Tap a cell = check in. Heatmap fills with color. |
| **3** | **Streaks, consistency, categories** | Stats card on detail view. Category chips filter the list. |
| **4** | **Themes engine** | Theme picker in settings. Gruvbox, Catppuccin, Nord, Tokyo Night, Rosé Pine + light/dark all switchable. |
| **5** | **Home Screen widget** | Add widget → pick habit → see heatmap → tap to check in (no app launch). |
| **6** | **Reminders/notifications** | Per-habit time, days-of-week. Notification fires, tap → opens habit. |
| **7** | **Polish** | Ripple tap animation, haptics, app icon, launch screen, JSON export. |

After phase 7 we'd have a v1 you can use daily. Phases 8+ (lock screen widget, journal, analytics) are future work.

---

## 11. Risks & Open Questions

| Risk / Question | Mitigation |
|---|---|
| **Xcode 16.4 ↔ iOS 26 device deploy** | Develop on simulator. Defer device deploy until v1-ish. If it fails, we either update Xcode (~12GB download) or copy device support files. |
| **Free Apple ID 7-day re-sign** | Accepted tradeoff. Maybe a future "renew reminder" notification. |
| **App Group + free signing** | Should work — App Groups are not paid-feature gated. Will verify at Phase 5. |
| **SwiftData stability** | Use small, well-tested patterns. Avoid complex predicates until 2.x. |
| **interactive widgets + free signing** | Should work (AppIntents don't require paid). Verify Phase 5. |
| **Heatmap performance for multi-year data** | Render visible cells only (LazyVGrid / Canvas). Bench at Phase 2. |

**Decisions locked in (your answers):**
1. ✅ Bundle ID = `com.divs.tency`
2. ✅ Tabs = **Habits · Settings** (no Today tab; Habits view is today-aware at the top)
3. ✅ Week starts **Monday**
4. ✅ Widget tap = **+1** (every tap adds 1 to today's amount; for binary habits this just marks done)
5. ✅ Icons = **SF Symbols** picked by me to fit each habit's name (you'll provide custom designs later)
6. ✅ Ship **completely empty** — no sample habits

---

## 12. What I need from you to start

1. ✅ **Plan approved** (you signed off)
2. ✅ **All 6 assumptions answered** — see §11
3. ⏳ **Xcode update in progress** on your machine — I am holding off
4. ⏳ **`/ctx-upgrade` pending** — pi restart so newly-installed skills load and web-fetcher is fixed

**Status:** Standing by. The moment you say "Xcode is done, go," I'll start **Phase 0 (Project bootstrap)**.

---

## Appendix A — Skills now active for this project

After installation, the following skills are available to draw from:
- `swiftui-pro` (twostraws — Paul Hudson)
- `swiftui-expert-skill` (avdlee — Antoine van der Lee)
- `widgetkit` (dpearson2699)
- `swiftui-animation` (dpearson2699)
- `ios-hig-design` (wondelai — Apple HIG)
- `sleek-design-mobile-apps` (sleekdotdesign — 169K installs)

## Appendix B — Tooling now installed

| Tool | Version | Purpose |
|---|---|---|
| XcodeGen | 2.45.4 | Generate `.xcodeproj` from YAML |
| swift-format | 602.0.0 | Apple's formatter |
| xcbeautify | 3.2.1 | Readable xcodebuild output |
| SwiftLint | 0.63.2 | Style/lint enforcement |
| Xcode | 16.4 | Already installed |
| Swift | 6.1.2 | Already installed |
