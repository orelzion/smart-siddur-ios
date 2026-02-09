# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-02-08)

**Core value:** Reliable, offline-first prayer assembly with correct halachic logic -- the right prayer text, with the right insertions, for the right day, available without network.
**Current focus:** Phase 2 - iOS Core (02-01 complete, 02-02 next)

## Current Position

Phase: 2 of 3 (iOS Core)
Plan: 1 of 3 in Phase 2 (02-01 complete)
Status: In progress -- 02-01 complete, ready for 02-02
Last activity: 2026-02-09 -- Completed 02-01-PLAN.md (iOS project setup + auth flow)

Progress: [####░░░░░░] 44% (4/9 plans) + 1 quick task

## Performance Metrics

**Velocity:**
- Total plans completed: 4 + 1 quick task
- Average duration: ~40 min (phase plans), ~13 min (quick tasks)
- Total execution time: ~2h 20m

**By Phase:**

| Phase | Plans | Completed | Avg/Plan |
|-------|-------|-----------|----------|
| 01-backend-foundation | 3 | 3 | ~40min |
| quick tasks | 1 | 1 | ~13min |
| 02-ios-core | 3 | 1 | - |
| 03-prayer-monetization | 3 | 0 | - |

**Recent Trend:**
- Last 5 plans: 01-01 (schema), 01-03 (edge functions), 01-02 (content seeding), quick/001 (iOS project init), 02-01 (iOS auth)
- Trend: Steady execution, Phase 2 started, auth foundation in place

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

### Pending Todos

None.

### Blockers/Concerns

None. Auth foundation complete, ready for prayer assembly (02-02) and settings (02-03).

## Session Continuity

Last session: 2026-02-09 14:24 UTC
Stopped at: Completed 02-01-PLAN.md (iOS project setup + auth flow)
Resume file: None

Auth is working (Apple, Google, Anonymous). Tab container shell has 3 placeholder tabs.
DependencyContainer pattern established for future repositories.
Ready for 02-02 (prayer assembly) and 02-03 (settings/preferences).
