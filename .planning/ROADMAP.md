# Roadmap: SmartSiddur iOS

## Overview

This roadmap delivers a complete iOS siddur app backed by Supabase in 4 phases. Phase 1 builds the entire backend (schema, seeded content, prayer generation edge functions) in this repo under `supabase/`. Phases 2-4 build the iOS app in a new SmartSiddur-iOS repo. Phase 2 builds foundational features (auth, settings, location, zmanim). Phase 3 delivers the core prayer experience with offline caching for all prayers. Phase 4 adds premium subscription and feature gating. Phases are compressed for speed; within Phase 1, schema, content seeding, and edge functions can execute in parallel after the schema plan lands first.

**Repo split:**
- **Phase 1**: This repo (SmartSiddur) — `supabase/` directory for migrations, edge functions, seeding scripts
- **Phases 2-4**: New repo (SmartSiddur-iOS) — Xcode project with SwiftUI app

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3, 4): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Backend Foundation** - Deploy Supabase schema, seed all content and geo data, build prayer generation edge functions
- [x] **Phase 2: iOS Core** - Auth, settings, location picker, and zmanim calculation
- [x] **Phase 3: Prayer Experience** - Prayer display with offline cache (all prayers free)
- [ ] **Phase 4: Monetization** - StoreKit subscriptions and premium feature gating

## Phase Details

### Phase 1: Backend Foundation
**Goal**: The Supabase backend is fully operational -- schema deployed with RLS, 710+ prayer strings and 141K locations seeded, and edge functions correctly generating prayers for all 26+ types
**Depends on**: Nothing (first phase)
**Requirements**: SCHM-01, SCHM-02, SCHM-03, SCHM-04, CONT-01, CONT-02, CONT-03, CONT-04, CONT-05, EDGE-01, EDGE-02, EDGE-03
**Success Criteria** (what must be TRUE):
  1. All 7 core tables exist in Supabase with RLS policies that block cross-user access and allow public read on geo_locations and prayer_content
  2. Calling `search_locations('Jerusalem')` returns correct results from the 141K seeded geo_locations rows
  3. Querying prayer_content for any of the 26+ prayer types returns correctly structured rows with nusach-variant text and named placeholders (no `%1$s` format strings remain)
  4. Calling generate-prayer with a Shacharit request for a specific date/nusach returns fully resolved prayer items that match the Android app's output for the same inputs
  5. Calling generate-prayer-batch for 14 days returns correct prayers across calendar boundary conditions (Shabbat, Rosh Chodesh, holidays)
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md -- Deploy Supabase schema (all tables, RLS, triggers, helper functions) [Wave 1]
- [x] 01-02-PLAN.md -- Seed prayer content and geo locations (strings.xml migration, JSON assets, 141K locations import) [Wave 2, depends on 01-01]
- [x] 01-03-PLAN.md -- Build prayer generation edge functions (generate-prayer + generate-prayer-batch with all conditional logic) [Wave 2, depends on 01-01]

### Phase 2: iOS Core
**Goal**: Users can sign in, configure their halachic identity and preferences, pick their location, and view accurate daily zmanim
**Depends on**: Phase 1 (schema must exist for auth triggers, settings sync, location search)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04, SETT-01, SETT-02, SETT-03, ZMAN-01, ZMAN-02, ZMAN-03, LOCN-01, LOCN-02, LOCN-03, LOCN-04
**Success Criteria** (what must be TRUE):
  1. User can sign in with Apple, Google, or anonymously and their session persists across app launches
  2. User can set nusach, language, zmanim opinions, and other synced settings that persist to Supabase and appear on another device
  3. User can set local display preferences (theme, font size, tfila mode) that respond instantly without network
  4. User can search cities by name, use GPS, save multiple locations, and switch between them
  5. User can view daily halachic times (zmanim) that respect their selected location and opinion settings
**Plans**: 3 plans

Plans:
- [x] 02-01-PLAN.md -- iOS project setup + Auth flow (Xcode project, supabase-swift SPM, Apple/Google/Anonymous auth, session persistence, tab shell) [Wave 1]
- [x] 02-02-PLAN.md -- Settings and Location (synced + local settings, location picker with server search, GPS auto-detect) [Wave 2, depends on 02-01]
- [x] 02-03-PLAN.md -- Zmanim + Calendar (KosherSwift zmanim, opinion-aware display, Hebrew/Gregorian calendar, day detail sheets) [Wave 3, depends on 02-02]

### Phase 3: Prayer Experience
**Goal**: Users can open any prayer and see the correct text for today's date, nusach, and settings -- even in airplane mode
**Depends on**: Phase 1 (edge functions for prayer generation, content for sync), Phase 2 (auth for user identity, settings/location for prayer requests)
**Requirements**: PRAY-01, PRAY-02, PRAY-03, PRAY-04, PRAY-05
**Success Criteria** (what must be TRUE):
  1. User can see a prayer menu and open any of the 26+ prayer types to view fully rendered text with correct nusach and calendar-sensitive insertions
  2. Prayers are pre-fetched for 14 days and display correctly in airplane mode with no network
  3. Changing settings (nusach, location) invalidates the cache and re-fetches prayers with the new parameters
  4. All prayers are available to all users (no premium gating in this phase)
**Plans**: 2 plans

Plans:
- [x] 03-01-PLAN.md -- Prayer list, display, and rendering (main menu, prayer text view, backend integration) [Wave 1]
- [x] 03-02-PLAN.md -- Offline cache and pre-fetch (14-day SwiftData cache, background refresh, cache invalidation) [Wave 2, depends on 03-01]

### Phase 4: Monetization
**Goal**: Generate sustainable revenue while maintaining free access to core prayers
**Depends on**: Phase 3 (prayer experience must be complete before monetizing)
**Requirements**: PRAY-06, PURCH-01, PURCH-02, PURCH-03, PURCH-04
**Success Criteria** (what must be TRUE):
  1. Premium prayers are gated behind $4.99/year subscription
  2. Free users see core prayers (Shacharit, Mincha, Arvit, Birkat HaMazon, Omer)
  3. User can purchase a $4.99/year subscription with 7-day trial
  4. Legacy migrated users have permanent free premium access
  5. Premium status is checked via is_premium_user() function
**Plans**: 1 plan

Plans:
- [ ] 04-01: StoreKit 2 subscriptions and premium gating (purchase flow, trial, legacy support, feature matrix)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4
(Within Phase 1, plans 01-01 executes first, then 01-02 and 01-03 can run in parallel)

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Backend Foundation | 3/3 | ✓ Complete | 2026-02-09 |
| 2. iOS Core | 3/3 | ✓ Complete | 2026-02-09 |
| 3. Prayer Experience | 2/2 | Planned | 2026-02-09 |
| 4. Monetization | 0/1 | Not started | - |
