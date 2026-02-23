# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-08)

**Core value:** Reliable, offline-first prayer assembly with correct halachic logic -- the right prayer text, with the right insertions, for the right day, available without network.
**Current focus:** NEW: Smart Siddur Visual Redesign (Phase 1-6 Visual/UX Overhaul). Implementing premium dark/gold glassmorphism design system foundation.

## Current Position

Phase: 2 of 6 (Home Tab Implementation) - **NEW VISUAL REDESIGN PROJECT**
Plan: 1 of 1 in Phase 2 (02-01 complete)
Status: Phase 2 complete - Home Tab Implementation (Smart Prayer Countdown + Glass UI)
Last activity: 2026-02-23 -- Completed Phase 2 Home Tab Implementation

Progress: [██░░░░░░░░░░░░░░░░░] 33% (2/6 phases) - Smart Siddur Visual Redesign

## Performance Metrics

**Velocity:**
- Total plans completed: 6 + 1 quick task
- Average duration: ~35 min (phase plans), ~13 min (quick tasks)
- Total execution time: ~3h 10m

**By Phase:**

| Phase | Plans | Completed | Avg/Plan |
|-------|-------|-----------|----------|
| 01-backend-foundation | 3 | 3 | ~40min |
| quick tasks | 1 | 1 | ~13min |
| 02-ios-core | 3 | 3 | ~20min |
| 03-prayer-experience | 2 | 2 | ~5min |
| 04-monetization | 1 | 0 | - |

**Recent Trend:**
- Last 5 plans: 02-01 (iOS auth), 02-02 (settings + location), 02-03 (zmanim + calendar), 03-01 (prayer views), 03-02 (offline cache)
- Trend: Phase 3 plans completed quickly as they enhanced existing Phase 3-01 infrastructure

*Updated after each plan completion*
| Phase 03-prayer-experience P01 | 5min | 5 tasks | 9 files |
| Phase 03-prayer-experience P02 | ~3min | 2 tasks | 4 files |

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

### Pending Todos

None.

### Blockers/Concerns

None. Phase 2 (Home Tab Implementation) is complete. All plans executed:
- 02-01: Data models + NextPrayerService + view extensions
- 02-02: HomeViewModel + NewHomeView UI

Ready for Phase 3 (Prayer Detail & Navigation).

## Session Continuity

Last session: 2026-02-23 16:10 UTC
Stopped at: Completed Phase 2 - Home Tab Implementation
Resume file: None

**Phase 2 Execution Completed**: Home Tab Implementation

Phase 2 complete. Home Tab Implementation delivered:
- **Data Models** (NextPrayerState.swift): 4 models for prayer state management
  - NextPrayerState, PrayerMilestone, SuggestedItem, SpecialZman
- **NextPrayerService**: Smart prayer countdown with milestone-based timer
  - 9-window prayer classification (prep/halachic/extended/too-late)
  - Milestone boundary detection (not every-second updates)
  - Scene phase observation for background/foreground transitions
- **Service Extensions**:
  - PrayerVisibilityService.suggestedItems() - Contextual seasonal prayers
  - JewishCalendarService.seasonalBadge() - Holiday badges
- **HomeViewModel**: Complete orchestration of services
  - Greeting management, date display, prayer grid filtering
  - Lifecycle management (start/stop)
- **NewHomeView**: Premium dark/gold UI
  - Greeting header, HeroCard countdown, Suggested For You grid
  - All Prayers 2-column grid with current prayer highlighting
  - RTL layout support, spring animations
- All components: light/dark theme support, glass morphism aesthetic, haptic feedback
- Project source code compiles successfully (signing only requires dev team)

Ready for Phase 3 (Prayer Detail & Navigation).

Home Tab Implementation: Milestone-based smart countdown, glass cards, contextual suggestions, RTL support.
