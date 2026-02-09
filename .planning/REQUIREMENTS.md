# Requirements: SmartSiddur iOS

**Defined:** 2026-02-08
**Core Value:** Reliable, offline-first prayer assembly with correct halachic logic — the right prayer text, with the right insertions, for the right day, available without network.

## v1 Requirements

### Schema

- [ ] **SCHM-01**: All 7 core tables deployed (profiles, purchases, user_settings, user_locations, geo_locations, user_notifications, prayer_content + content_versions)
- [ ] **SCHM-02**: RLS policies enforce user-only access on all user tables, public read on geo_locations and prayer_content
- [ ] **SCHM-03**: Auto-create triggers (profile on auth signup, settings on profile create, updated_at on all tables)
- [ ] **SCHM-04**: Helper functions deployed (is_premium_user, search_locations, increment_content_version)

### Content

- [ ] **CONT-01**: 710+ prayer strings migrated from strings.xml across 5 locales into prayer_content with correct text_variants JSONB
- [ ] **CONT-02**: JSON assets (slihot.json, sukot.json) migrated with nusach/section structure preserved
- [ ] **CONT-03**: All %1$s format strings converted to {{named}} placeholders per spec Section 2.4
- [ ] **CONT-04**: 141K geo_locations rows imported from Room database
- [ ] **CONT-05**: Content delta sync protocol working (content_versions tracking, client fetches only changed rows)

### Edge Functions

- [ ] **EDGE-01**: generate-prayer returns correct prayer items for all 26+ prayer types with nusach/calendar/mode logic
- [ ] **EDGE-02**: generate-prayer-batch returns 14 days of prayers for multiple types in one response
- [ ] **EDGE-03**: Conditional logic covers all categories: nusach, calendar state, season, tfila mode, location, user state, day-of-week, holidays

### iOS Auth

- [x] **AUTH-01**: User can sign in with Apple via Supabase Auth
- [x] **AUTH-02**: User can sign in with Google via Supabase Auth
- [x] **AUTH-03**: User can use app anonymously (Supabase anonymous auth)
- [x] **AUTH-04**: Auth session persists across app launches

### iOS Prayer

- [ ] **PRAY-01**: User can view list of available prayer types (main menu)
- [ ] **PRAY-02**: User can open a prayer and see fully rendered text with correct insertions
- [ ] **PRAY-03**: Prayers are pre-fetched for 14 days and cached in SwiftData
- [ ] **PRAY-04**: Cached prayers display correctly in airplane mode
- [ ] **PRAY-05**: Cache invalidates on settings change (settingsHash) or content version bump
- [ ] **PRAY-06**: Free vs premium feature gating matches Android (spec Section 5.4)

### iOS Zmanim

- [x] **ZMAN-01**: User can view daily halachic times calculated via KosherSwift
- [x] **ZMAN-02**: Zmanim respect user's dawn/sunrise/dusk opinion settings
- [x] **ZMAN-03**: Zmanim use selected location's coordinates and timezone

### iOS Settings

- [x] **SETT-01**: Synced settings (nusach, is_woman, language, zmanim opinions, etc.) persist to Supabase and sync across devices
- [x] **SETT-02**: Local settings (tfila_mode, theme, font, is_avel, etc.) stored in UserDefaults with instant response
- [x] **SETT-03**: Settings UI allows changing all synced + local settings per spec Sections 6.2 and 6.3

### iOS Location

- [x] **LOCN-01**: User can search cities via server-side geo_locations search
- [x] **LOCN-02**: User can use GPS to detect current location
- [x] **LOCN-03**: User can save and switch between multiple locations
- [x] **LOCN-04**: Selected location persists in user_locations table

### iOS Purchase

- [ ] **PURCH-01**: User can purchase $4.99/year subscription via StoreKit 2
- [ ] **PURCH-02**: 7-day free trial available for new subscribers
- [ ] **PURCH-03**: Legacy migrated users have permanent free premium access
- [ ] **PURCH-04**: Premium status checked via is_premium_user() function

## v2 Requirements

### Notifications

- **NOTF-01**: User can set omer count daily reminders
- **NOTF-02**: User can set zman-relative alerts (e.g., 20 min before sunset)
- **NOTF-03**: Notification configs persist in user_notifications table

### Calendar

- **CALR-01**: User can view Jewish calendar with holidays and parsha

### Migration

- **MIGR-01**: Firebase users can migrate to Supabase via migrate-firebase-user edge function
- **MIGR-02**: Legacy purchases preserved during migration

### Receipt Verification

- **RCPT-01**: Apple receipts verified via App Store Server API v2
- **RCPT-02**: Purchase status updated in purchases table after verification

## Out of Scope

| Feature | Reason |
|---------|--------|
| Android Supabase migration | Deferred — Android stays on Firebase for now |
| Admin dashboard | Use Supabase dashboard + seed scripts |
| Apple Watch / Widgets | Post-launch feature |
| Web client | Native iOS only |
| Real-time features | Personal prayer app, no collaboration |
| Custom notification sounds | System defaults sufficient |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SCHM-01 | Phase 1 | Pending |
| SCHM-02 | Phase 1 | Pending |
| SCHM-03 | Phase 1 | Pending |
| SCHM-04 | Phase 1 | Pending |
| CONT-01 | Phase 1 | Pending |
| CONT-02 | Phase 1 | Pending |
| CONT-03 | Phase 1 | Pending |
| CONT-04 | Phase 1 | Pending |
| CONT-05 | Phase 1 | Pending |
| EDGE-01 | Phase 1 | Pending |
| EDGE-02 | Phase 1 | Pending |
| EDGE-03 | Phase 1 | Pending |
| AUTH-01 | Phase 2 | Pending |
| AUTH-02 | Phase 2 | Pending |
| AUTH-03 | Phase 2 | Pending |
| AUTH-04 | Phase 2 | Pending |
| SETT-01 | Phase 2 | Pending |
| SETT-02 | Phase 2 | Pending |
| SETT-03 | Phase 2 | Pending |
| ZMAN-01 | Phase 2 | Pending |
| ZMAN-02 | Phase 2 | Pending |
| ZMAN-03 | Phase 2 | Pending |
| LOCN-01 | Phase 2 | Pending |
| LOCN-02 | Phase 2 | Pending |
| LOCN-03 | Phase 2 | Pending |
| LOCN-04 | Phase 2 | Pending |
| PRAY-01 | Phase 3 | Pending |
| PRAY-02 | Phase 3 | Pending |
| PRAY-03 | Phase 3 | Pending |
| PRAY-04 | Phase 3 | Pending |
| PRAY-05 | Phase 3 | Pending |
| PRAY-06 | Phase 4 | Pending |
| PURCH-01 | Phase 4 | Pending |
| PURCH-02 | Phase 4 | Pending |
| PURCH-03 | Phase 4 | Pending |
| PURCH-04 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 36 total
- Mapped to phases: 36
- Unmapped: 0

---
*Requirements defined: 2026-02-08*
*Last updated: 2026-02-08 after roadmap creation*
