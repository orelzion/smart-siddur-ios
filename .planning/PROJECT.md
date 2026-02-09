# SmartSiddur iOS

## What This Is

A full-featured iOS siddur (Jewish prayer book) app built with SwiftUI and powered by Supabase. It replaces the existing Android app's Firebase backend with Supabase Edge Functions for server-side prayer generation, an offline-first architecture with 14-day pre-fetch, and a remote content management system for 710+ prayer strings across 5 languages. The app serves observant Jewish users who need accurate, nusach-aware, calendar-sensitive daily prayers.

## Core Value

Reliable, offline-first prayer assembly with correct halachic logic — the right prayer text, with the right insertions, for the right day, available without network.

## Requirements

### Validated

- ✓ MIGRATION_SPEC.md documents complete schema, edge functions, data mapping, and iOS architecture — existing
- ✓ Android app proves the prayer generation logic across 50+ generators — existing
- ✓ 710+ prayer string resources across 5 languages (he, en, fr, es, de) — existing
- ✓ 141K geo_locations dataset for city search — existing
- ✓ KosherJava/KosherSwift zmanim calculation library — existing

### Active

- [ ] Supabase schema deployed (profiles, purchases, user_settings, user_locations, geo_locations, user_notifications, prayer_content, content_versions)
- [ ] Prayer content seeded from Android strings.xml + JSON assets into prayer_content table
- [ ] Geo locations seeded from Room database into geo_locations table
- [ ] Firebase user migration edge function (migrate-firebase-user)
- [ ] Prayer generation edge function (generate-prayer + generate-prayer-batch)
- [ ] Apple/Google receipt verification edge functions
- [ ] iOS app: Auth flow (Apple + Google + Anonymous via Supabase Auth)
- [ ] iOS app: Prayer list and display with offline cache
- [ ] iOS app: Zmanim calculation (KosherSwift) with user opinion settings
- [ ] iOS app: Settings (synced via Supabase + local via UserDefaults)
- [ ] iOS app: Location picker with server-side geo_locations search
- [ ] iOS app: StoreKit 2 subscription ($4.99/year) with legacy user support
- [ ] iOS app: Push notifications for omer count and zman alerts
- [ ] iOS app: Jewish calendar view
- [ ] iOS app: Offline-first with 14-day pre-fetch
- [ ] iOS app: Full feature parity with Android (all 26+ prayer types)
- [ ] Content sync protocol (delta sync via content_versions)

### Out of Scope

- Android app migration to Supabase — deferred to future milestone, stays on Firebase
- Admin dashboard for prayer content management — seed via scripts, edit via Supabase dashboard
- Real-time collaborative features — this is a personal prayer app
- Web client — native iOS only
- Custom notification sounds — use system defaults
- Widgets or Apple Watch — defer to post-launch

## Context

- The Android SmartSiddur app has been live on Google Play with Firebase Auth (Google + Anonymous), Firebase RTDB for user data, and Google Play Billing for a one-time "pro_mode" purchase.
- Prayer generation currently happens client-side via 50+ Java generator classes that assemble prayer text based on nusach, calendar state, user settings, and location. This moves server-side to Edge Functions.
- Prayer text is currently hardcoded in strings.xml (710+ strings) and JSON assets (slihot.json, sukot.json). This moves to a remote prayer_content table with version-tracked delta sync.
- The MIGRATION_SPEC.md (in repo root) is the authoritative reference for all schema designs, data mappings, edge function contracts, and iOS architecture decisions.
- Supabase project already exists and is configured.

## Constraints

- **Platform**: iOS 17+ — enables SwiftUI @Observable, SwiftData, modern NavigationStack
- **Backend**: Supabase (Postgres + Edge Functions in Deno/TypeScript)
- **Auth**: Supabase Auth natively (Apple + Google + Anonymous) — no custom auth
- **Zmanim**: Client-side via KosherSwift — too latency-sensitive for server
- **Offline**: Must work without network for 14 days of pre-fetched prayers
- **Content**: 5 languages (he, en, fr, es, de), 4 nusachot (edot, sfarad, ashkenaz, chabad)
- **Solo developer**: Minimize ceremony, maximize working code
- **Source of truth**: MIGRATION_SPEC.md for all architectural decisions and data mappings

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Prayer generation on server (Edge Functions) | Moves 50+ generators out of client, enables content updates without app releases | — Pending |
| SwiftData over CoreData | iOS 17+ target allows modern persistence, less boilerplate | — Pending |
| 14-day pre-fetch window | Covers two Shabbatot, no special Shabbat handling needed (observant users don't use phones) | — Pending |
| Settings split (synced + local) | Instant UI for display prefs, cross-device sync for halachic identity | — Pending |
| Subscription model ($4.99/yr) replacing one-time purchase | Sustainable revenue; legacy users get permanent free access | — Pending |
| Location search moves server-side | Eliminates 14MB local database, enables search without shipping data | — Pending |

---
*Last updated: 2026-02-08 after initialization*
