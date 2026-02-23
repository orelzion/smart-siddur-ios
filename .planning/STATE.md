# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-08)

**Core value:** Reliable, offline-first prayer assembly with correct halachic logic -- the right prayer text, with the right insertions, for the right day, available without network.
**Current focus:** NEW: Smart Siddur Visual Redesign (Phase 1-6 Visual/UX Overhaul). Implementing premium dark/gold glassmorphism design system foundation.

## Current Position

Phase: 4 of 6 (Tab Structure Migration) - **NEW VISUAL REDESIGN PROJECT**
Plan: 1 of 1 in Phase 4 (complete)
Status: Phase 4 complete - Tab Structure Migration (3-tab layout with glass styling)
Last activity: 2026-02-23 -- Completed Phase 4 Tab Structure Migration

Progress: [████░░░░░░░░░░░░░░░] 67% (4/6 phases) - Smart Siddur Visual Redesign

## Performance Metrics

**Velocity:**
- Total plans completed: 7 + 1 quick task
- Average duration: ~27 min (phase plans), ~13 min (quick tasks)
- Total execution time: ~3h 21m

**By Phase:**

| Phase | Plans | Completed | Avg/Plan |
|-------|-------|-----------|----------|
| 01-backend-foundation | 3 | 3 | ~40min |
| quick tasks | 1 | 1 | ~13min |
| 02-ios-core | 3 | 3 | ~20min |
| 03-prayer-experience | 2 | 2 | ~5min |
| 02-design-system | 1 | 1 | ~45min |
| 02-home-tab | 1 | 1 | ~25min |
| 03-calendar-zmanim | 1 | 1 | ~4min |
| 04-tab-structure | 1 | 1 | ~1min |
| 05-settings-restyling | 1 | 0 | - |
| 06-polish-and-preview | 1 | 0 | - |

**Recent Trend:**
- Last 5 plans: 02-03 (zmanim + calendar), 03-01 (prayer views), 03-02 (offline cache), 04-01 (tab structure), 05-01 (settings restyling - next)
- Trend: Rapid execution of visual redesign phases, leverage existing component infrastructure

*Updated after each plan completion*
| Phase 03-calendar-zmanim P01 | ~4min | 5 tasks | 8 files |
| Phase 04-tab-structure P01 | ~1min | 1 task | 1 file |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: 4-phase structure -- backend first, then iOS core, then prayer experience, then monetization
- [Roadmap]: Within Phase 1, schema plan must complete first, then content seeding and edge functions can run in parallel
- [Roadmap]: Notifications (NOTF), Calendar (CALR), Migration (MIGR), and Receipt Verification (RCPT) deferred to v2
- [01-03]: Used kosher-zmanim@0.9.0 (latest available) -- getParsha() returns Parsha enum, not getParshaIndex()
- [01-03]: Single assembler module pattern instead of 35+ separate generator files
- [01-03]: Batch function pre-fetches all content in one query for performance
- [Q001]: @MainActor needed on @Observable singleton classes for Swift 6 strict concurrency
- [Q001]: iOS project at ~/git/smart-siddur-ios-new/ (separate repo from backend)
- [02-01]: Switched from GENERATE_INFOPLIST_FILE to XcodeGen info block for custom Info.plist keys (GIDClientID, URL schemes)
- [02-01]: GIDServerClientID set to web client ID for Supabase ID token exchange
- [02-01]: AuthRepository protocol pattern for testability
- [02-01]: Auth state routing via supabase.auth.authStateChanges async stream at app root
- [02-02]: @MainActor on DependencyContainer for Swift 6 strict concurrency (accesses @MainActor LocalSettings.shared)
- [02-02]: Separate LocationManagerDelegate class to avoid @Observable + NSObject/lazy conflicts
- [02-02]: Bounding box + Haversine client-side sort for GPS nearest city (simple, avoids custom SQL)
- [02-02]: Single-field updateSingleSetting for optimistic updates (reduces payload, avoids race conditions)
- [02-03]: KosherSwift.GeoLocation qualified import to avoid name collision with app's GeoLocation model
- [02-03]: Opinion-mapped method dispatch: each user opinion enum maps to specific KosherSwift API method
- [02-03]: Cross-tab navigation via zmanimDateOverride + selectedTab on DependencyContainer
- [02-03]: Chronological sorting of zmanim list for natural day-flow reading experience
- [02-03]: Segmented control for calendar mode toggle (per user feedback during checkpoint)
- [02-03]: DayDetailSheet shows only sunrise/sunset + "View Full Zmanim" navigation (per user feedback)
- [Phase 03-prayer-experience]: Used @Observable pattern for prayer view models consistent with existing codebase — Maintains consistency with Zmanim and Calendar views
- [Phase 03-prayer-experience]: Organized prayers by time of day with Today section for current relevance — Provides intuitive navigation and highlights today's relevant prayers
- [Phase 03-prayer-experience]: Hebrew-only display with nikud and teamim, no translations per user decisions — Aligns with user feedback from previous phases
- [Phase 03-prayer-experience]: Full scrolling text view rather than pagination for better reading experience — Improves user experience for prayer reading
- [Phase 02-home]: Milestone-based timer (not every-second) for battery efficiency — Reduces battery drain, updates only when crossing time boundaries
- [Phase 02-home]: 9-window prayer classification (prep/halachic/extended/too-late) — Aligns with halachic precision and provides contextual guidance
- [Phase 02-home]: Always-visible core prayers (Shacharit/Mincha/Arvit/Brachot) plus seasonal contextual suggestions — Ensures baseline consistency while adding relevant contextual prayers
- [Phase 02-home]: Scene phase observation for background/foreground transitions — Prevents stale state when app returns from background/sleep
- [Phase 04-tab-structure]: 3-tab layout (Home/Calendar/Settings) with consolidated navigation — Simplifies primary navigation, removes redundant Prayers tab, improves UX
- [Phase 04-tab-structure]: Glass background + gold tint styling on TabView — Delivers premium glassmorphism aesthetic from Phase 1 design system
- [Phase 04-tab-structure]: Light haptic feedback on tab switches — Provides tactile confirmation without disrupting user focus

### Pending Todos

None.

### Blockers/Concerns

None. Phase 4 (Tab Structure Migration) is complete. All tasks executed:
- 4.1: TabContainerView Restructure (4→3 tabs, glass styling, gold tint, haptic feedback)

Ready for Phase 5 (Settings Tab Restyling).

## Session Continuity

Last session: 2026-02-23 15:38 UTC
Stopped at: Completed Phase 4 - Tab Structure Migration
Resume file: None

**Phase 4 Execution Completed**: Tab Structure Migration

Phase 3 complete. Unified Calendar/Zmanim Tab delivered:
- **Extended ZmanimService** (specialZmanim method):
  - Erev/Motzei Shabbat (candle lighting, havdala)
  - Chanukah (nightly candle lighting with night number)
  - Fast days (begin/end times for Tisha B'Av, Gedaliah, Esther, 17 Tammuz)
  - Sefirat HaOmer (nightly count display)
  - Rosh Chodesh (molad/new moon time)
  - Purim (Megilla reading times)
  - Erev Yom Kippur (Kol Nidrei)
  - Lag Ba'Omer (bonfire time)
- **Enhanced CalendarViewModel**:
  - Dual view mode support (month/day)
  - Dual date display mode (hebrew/gregorian)
  - New state for selectedDate, showAllZmanim
  - Computed properties for essentialZmanim, allZmanim, specialZmanim
  - Day navigation methods for swipe gestures
- **UnifiedCalendarView** (Month & Day modes):
  - Month View: 7-column grid with colored day type indicators, inline day detail
  - Day View: Full-screen single day display with swipe navigation
  - Gesture handling: horizontal swipes for day navigation, arrow buttons for month/day navigation
  - Special zmanim display with context descriptions
  - Essential/All zmanim toggle with smooth animation
- **DayInfoCard Component**:
  - Always shows Hebrew date (primary), Gregorian date, Daf Yomi
  - Conditionally shows Parsha (Shabbat), Holiday, Omer count
  - Adaptively displays special zmanim with gold time values
  - Glass card styling with sections
- All components: light/dark theme support, glass morphism aesthetic, RTL support, smooth animations
- Project source code compiles successfully

**Phase 4 Execution Completed**: Tab Structure Migration

Phase 4 complete. Tab Structure Migration delivered:
- **TabContainerView Restructure**:
  - Changed from 4 tabs (Zmanim, Calendar, Prayers, Settings) to 3 tabs
  - Tab 1: Home (NewHomeView) - Prayer countdown, suggestions, all prayers
  - Tab 2: Calendar/Zmanim (UnifiedCalendarView) - Dual mode calendar with special times
  - Tab 3: Settings (SettingsView) - User preferences and location
  - Removed PrayersMenuView tab (consolidated into Home)
  - Applied dark gradient glass background (#0f172a to #020617)
  - Gold accent tint color (#D9BA1B) on selected tabs
  - Light haptic feedback (UIImpactFeedbackGenerator) on tab switch
  - SF Symbol icons: house.fill, calendar, gearshape.fill
  - Maintained location setup flow and RTL layout support
- All components: glass morphism aesthetic, smooth navigation, haptic feedback
- Project source code compiles successfully

Ready for Phase 5 (Settings Tab Restyling).

Tab Structure Migration: 3-tab layout with glass background, gold tinting, haptic feedback.
