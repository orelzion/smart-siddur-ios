# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-08)

**Core value:** Reliable, offline-first prayer assembly with correct halachic logic -- the right prayer text, with the right insertions, for the right day, available without network.
**Current focus:** Phase 2 complete. Ready for Phase 3 - Prayer + Monetization.

## Current Position

Phase: 2 of 3 (iOS Core) -- COMPLETE
Plan: 3 of 3 in Phase 2 (02-03 complete)
Status: Phase 2 complete, ready for Phase 3
Last activity: 2026-02-09 -- Completed 02-03-PLAN.md (Zmanim + Calendar)

Progress: [######░░░░] 66% (6/9 plans) + 1 quick task

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
| 03-prayer-monetization | 3 | 0 | - |

**Recent Trend:**
- Last 5 plans: quick/001 (iOS project init), 02-01 (iOS auth), 02-02 (settings + location), 02-03 (zmanim + calendar)
- Trend: iOS plans running faster than backend; 02-03 took ~38min due to KosherSwift integration + checkpoint UX fixes

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: 3-phase structure -- backend first, then iOS core, then prayer+monetization
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

### Pending Todos

None.

### Blockers/Concerns

None. Phase 2 (iOS Core) is complete. All three plans executed:
- 02-01: Auth (Apple + Google + Anonymous)
- 02-02: Settings + Location
- 02-03: Zmanim + Calendar

Ready for Phase 3 (Prayer Assembly + Monetization).

## Session Continuity

Last session: 2026-02-09 15:22 UTC
Stopped at: Completed 02-03-PLAN.md (Zmanim + Calendar)
Resume file: None

Phase 2 complete. All iOS core features working:
- Auth flow with Apple, Google, and Anonymous sign-in
- Full settings system (16 local + 17 synced) with optimistic updates
- Location picker with 141K city search and GPS detection
- Zmanim display with KosherSwift, 8 essential + 8 comprehensive times, opinion-aware
- Full calendar with Hebrew/Gregorian toggle, day markers, day detail sheets
- DependencyContainer holds all repositories and services needed for Phase 3

DependencyContainer now holds: authRepository, settingsRepository, locationRepository, localSettings, zmanimService, jewishCalendarService, selectedLocationName, zmanimDateOverride, selectedTab.
