---
status: testing
phase: 01-backend-foundation
source: 01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md
started: 2026-02-09T00:00:00Z
updated: 2026-02-09T00:01:00Z
---

## Current Test

number: 2
name: RLS Policies Enforce User Isolation
expected: |
  User-scoped tables enforce auth.uid() checks; public tables (geo_locations, prayer_content) allow anonymous read
awaiting: user response

## Tests

### 1. Supabase Schema Deployed
expected: All 8 core tables (profiles, purchases, user_settings, user_locations, geo_locations, user_notifications, prayer_content, content_versions) exist with correct columns and RLS policies enabled
result: pass

### 2. RLS Policies Enforce User Isolation
expected: User-scoped tables enforce auth.uid() checks; public tables (geo_locations, prayer_content) allow anonymous read
result: [pending]

### 3. Helper Functions Callable
expected: All 6 helper functions (update_updated_at, handle_new_user, handle_new_profile, increment_content_version, is_premium_user, search_locations) work correctly
result: [pending]

### 4. Triggers Auto-fire on Insert/Update
expected: User registration auto-creates profiles row, profiles INSERT auto-creates user_settings, UPDATE operations auto-update timestamps
result: [pending]

### 5. Prayer Content Seeded
expected: prayer_content table contains 2,616 rows with all nusach variants (default, sfarad, chabad, ashkenaz) in JSONB text_variants, no %1$s placeholders remain
result: [pending]

### 6. Geo Locations Seeded
expected: geo_locations table contains ~141K city records; search_locations('Jerusalem') returns results; search_locations('Paris, France') filters by country
result: [pending]

### 7. Placeholder Format Converted
expected: All prayer content uses named placeholders like {{aseret_insert}}, {{winter_summer_insert}}, etc. (zero Android-style %1$s, %2$d patterns)
result: [pending]

### 8. Content Versions Tracking
expected: content_versions table has initial seed entry documenting the operation
result: [pending]

### 9. Generate Prayer Edge Function Deployed
expected: generate-prayer edge function is active and can process requests for any prayer type/date/nusach combination
result: [pending]

### 10. Generate Prayer Batch Edge Function Deployed
expected: generate-prayer-batch edge function is active and can pre-fetch 14 days of prayers in a single request
result: [pending]

### 11. Prayer Generation Returns Correct Structure
expected: Calling generate-prayer returns prayer items with correct nusach resolution, placeholder replacement (using calendar state), and tfila mode filtering
result: [pending]

### 12. Batch Generation Handles Calendar Boundaries
expected: Calling generate-prayer-batch for 14 days correctly handles Shabbat, Rosh Chodesh, holidays, and other calendar boundary conditions
result: [pending]

### 13. Calendar State Derivation Works
expected: Edge functions correctly derive calendar state (Shabbat, holidays, fast days, seasons, omer count, parsha name) using kosher-zmanim
result: [pending]

### 14. Edge Functions Include CORS Headers
expected: Edge function responses include proper CORS headers for browser/app access
result: [pending]

## Summary

total: 14
passed: 1
issues: 0
pending: 13
skipped: 0

## Gaps

[none yet]
