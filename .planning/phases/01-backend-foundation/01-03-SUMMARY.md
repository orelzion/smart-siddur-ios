---
phase: 01-backend-foundation
plan: 03
subsystem: api
tags: [supabase, edge-functions, deno, kosher-zmanim, prayer-generation, typescript]

# Dependency graph
requires:
  - phase: 01-backend-foundation/01
    provides: Database schema (prayer_content table, RLS policies, helper functions)
provides:
  - generate-prayer edge function (single prayer generation for any type/date/nusach)
  - generate-prayer-batch edge function (14-day offline pre-fetch)
  - Shared prayer assembly engine (_shared/assembler.ts)
  - Shared calendar state module (_shared/calendar.ts)
  - Shared TypeScript types (_shared/types.ts)
affects: [02-ios-app, prayer-content-seeding, 01-02]

# Tech tracking
tech-stack:
  added: [kosher-zmanim@0.9.0, supabase-js@2 (JSR)]
  patterns: [data-driven prayer assembly, nusach resolution from JSONB text_variants, placeholder replacement engine, content caching for batch operations]

key-files:
  created:
    - supabase/functions/_shared/types.ts
    - supabase/functions/_shared/calendar.ts
    - supabase/functions/_shared/assembler.ts
    - supabase/functions/generate-prayer/index.ts
    - supabase/functions/generate-prayer-batch/index.ts
  modified: []

key-decisions:
  - "Used kosher-zmanim@0.9.0 (latest available) -- getParsha() returns Parsha enum, not getParshaIndex()"
  - "Data-driven assembly pattern: assembler.ts contains all 35+ generator logic in one module with section-based content fetching"
  - "Batch function pre-fetches all prayer_content in one query, caches in Map for reuse across dates/types"
  - "Parsha names resolved from Parsha enum with title-case formatting"

patterns-established:
  - "Nusach resolution: row.text_variants[nusach] || row.text_variants['default'] || ''"
  - "Placeholder pattern: {{name}} resolved by regex with calendar/user state context"
  - "Assembly sequence pattern: getXxxSequence() returns AssemblyStep[] for each prayer type"
  - "Content caching: Map<string, PrayerContentRow[]> passed through assembly for batch reuse"
  - "CORS headers on all edge function responses"

# Metrics
duration: ~45min
completed: 2026-02-08
---

# Plan 01-03: Build Prayer Generation Edge Functions Summary

**Two Supabase edge functions deployed: generate-prayer (single) and generate-prayer-batch (14-day pre-fetch) with kosher-zmanim calendar logic, nusach resolution, placeholder engine, and tfila mode filtering**

## Performance

- **Duration:** ~45 min
- **Started:** 2026-02-08T22:00:00Z
- **Completed:** 2026-02-08T22:45:00Z
- **Tasks:** 2
- **Files created:** 5

## Accomplishments
- Built complete prayer assembly engine porting logic from 35+ Java generator classes to TypeScript
- Deployed generate-prayer edge function handling all 26+ prayer types with full conditional logic
- Deployed generate-prayer-batch edge function with single-query content pre-fetch and performance guards
- Implemented calendar state derivation using kosher-zmanim v0.9.0 (Shabbat, holidays, fast days, seasons, omer, parsha)
- Implemented nusach resolution, placeholder engine, tfila mode filtering, and user state filtering

## Task Commits

Each task was committed atomically:

1. **Task 1: Build and deploy generate-prayer edge function** - `186fa3b` (feat)
2. **Task 2: Build and deploy generate-prayer-batch edge function** - `f001f94` (feat)

## Files Created/Modified
- `supabase/functions/_shared/types.ts` - All TypeScript interfaces: PrayerType (26+), Nusach, TfilaMode, request/response contracts, PrayerContentRow
- `supabase/functions/_shared/calendar.ts` - Calendar state derivation from kosher-zmanim JewishCalendar; ports Zemanim.java ivri encoding, season detection, no-tahanun rules, halel, vihi noam
- `supabase/functions/_shared/assembler.ts` - Prayer assembly engine (~1186 lines): assemblePrayer(), resolveNusach(), resolvePlaceholders(), assembly sequences for shacharit/mincha/arvit/mazon/omer, shared Amida sequence with 19 brachot
- `supabase/functions/generate-prayer/index.ts` - Edge function entry point with Deno.serve, request validation, CORS, error handling
- `supabase/functions/generate-prayer-batch/index.ts` - Batch endpoint with single-query content pre-fetch, date range iteration, performance guards (max 30 days, 10 types, 100 total)

## Decisions Made

1. **kosher-zmanim v0.9.0**: Latest available version. Uses `getParsha()` (returns Parsha enum) instead of non-existent `getParshaIndex()`. All needed constants (PURIM, CHANUKAH, TISHA_BEAV, etc.) and methods (isYomTov, isTaanis, getDayOfOmer, etc.) confirmed available.

2. **Single assembler module**: Rather than 35+ separate generator files (as in Android), all assembly logic is in one `assembler.ts` with function-based sequences (`getShacharitSequence()`, `getAmidaSequence()`, etc.). This is cleaner for server-side and easier to maintain.

3. **Content caching strategy**: Batch function fetches all prayer_content rows in one query and stores in `Map<string, PrayerContentRow[]>`. Individual function fetches per-section. Both paths go through the same `assemblePrayer()` function.

4. **Parsha name formatting**: Parsha enum values like `LECH_LECHA` are converted to "Lech Lecha" via split/titlecase for display.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] kosher-zmanim version 0.10.3 does not exist**
- **Found during:** Task 1 (first deployment attempt)
- **Issue:** Initial import used `npm:kosher-zmanim@0.10.3` but only v0.9.0 exists on npm
- **Fix:** Changed all imports to `npm:kosher-zmanim@0.9.0` in calendar.ts and assembler.ts
- **Files modified:** calendar.ts, assembler.ts
- **Verification:** Deployment succeeded after version fix
- **Committed in:** 186fa3b (Task 1 commit)

**2. [Rule 1 - Bug] getParshaIndex() does not exist in kosher-zmanim 0.9.0**
- **Found during:** Task 1 (API compatibility testing)
- **Issue:** calendar.ts called `jc.getParshaIndex()` which returns undefined in v0.9.0
- **Fix:** Replaced with `jc.getParsha()` which returns Parsha enum value, then resolve name via `Parsha[value]`
- **Files modified:** calendar.ts
- **Verification:** Tested with known Shabbat dates -- returns correct parsha values (17=YISRO, 18=MISHPATIM)
- **Committed in:** 186fa3b (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug)
**Impact on plan:** Both fixes necessary for correct deployment. No scope creep.

## Issues Encountered
- kosher-zmanim npm registry only has up to v0.9.0 (not 0.10.3) -- fixed by using correct version
- `getParshaIndex` method does not exist in v0.9.0 API -- replaced with `getParsha()` + Parsha enum lookup
- prayer_content table is empty (Plan 01-02 content seeding runs in parallel) -- functions handle this gracefully by returning empty items

## User Setup Required

None - edge functions deployed automatically. JWT verification is enabled by default.

## Next Phase Readiness
- Both edge functions are ACTIVE and deployed to Supabase project dekdhfjyukihnggfftui
- Functions will return populated prayer data once Plan 01-02 seeds prayer_content
- iOS app (Phase 2) can call these endpoints with authenticated requests
- Content versioning supported via content_version field in response metadata
- No blockers for Phase 2

---
*Phase: 01-backend-foundation*
*Completed: 2026-02-08*
