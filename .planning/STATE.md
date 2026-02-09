# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-08)

**Core value:** Reliable, offline-first prayer assembly with correct halachic logic -- the right prayer text, with the right insertions, for the right day, available without network.
**Current focus:** Phase 2 complete. Ready for Phase 3 - Prayer Experience.

## Current Position

Phase: 3 of 4 (Prayer Experience)
Plan: 2 of 2 in Phase 3 (03-02 complete)
Status: Phase 3 complete - Offline prayer cache with pre-fetch implemented
Last activity: 2026-02-09 -- Completed 03-02-PLAN.md (Offline cache and pre-fetch)

Progress: [████████░░] 89% (8/9 plans) + 1 quick task

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

### Pending Todos

None.

### Blockers/Concerns

None. Phase 3 (Prayer Experience) is complete. All plans executed:
- 03-01: Prayer views (menu, text display, navigation)
- 03-02: Offline cache and pre-fetch

Ready for Phase 4 (Monetization).

## Session Continuity

Last session: 2026-02-09 21:38 UTC
Stopped at: Completed 03-02-PLAN.md (Offline cache and pre-fetch)
Resume file: None

Phase 3 complete. All Prayer Experience features working:
- Prayer menu organized by time of day with today's relevant prayers highlighted
- Full prayer text view with scrolling display and table of contents
- Offline prayer cache with SwiftData persistence
- 14-day pre-fetch for upcoming prayers
- Automatic cache invalidation when settings change (nusach, location, tfilaMode)
- Background refresh on app launch
- Cache cleanup and size management (50MB limit)
- SwiftData model with proper indexes and migration handling

Phase 3 complete. Ready for Phase 4 (Monetization).

DependencyContainer now holds: authRepository, settingsRepository, locationRepository, localSettings, zmanimService, jewishCalendarService, prayerService, prayerCacheService, selectedLocationName, zmanimDateOverride, selectedTab.
