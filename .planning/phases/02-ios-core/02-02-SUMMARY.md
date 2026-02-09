---
phase: 02-ios-core
plan: 02
subsystem: settings
tags: [supabase, swiftui, userdefaults, corelocation, gps, observable, optimistic-updates]

# Dependency graph
requires:
  - phase: 01-backend-foundation
    provides: user_settings table (20 columns), user_locations table with EXCLUDE constraint, geo_locations table (141K cities), search_locations RPC
  - phase: 02-ios-core/01
    provides: Auth flow, DependencyContainer, TabContainerView shell, Supabase client config
provides:
  - LocalSettings @Observable wrapper for 16 UserDefaults-backed local settings
  - SyncedUserSettings Codable struct matching all 17 synced user_settings columns
  - SettingsRepository with single-field optimistic update support
  - SettingsViewModel with optimistic update + rollback pattern
  - Full SettingsView with 10 sections covering all synced + local settings
  - NusachPickerView, ZmanimOpinionsView, AppearanceSettingsView sub-screens
  - GeoLocation and UserLocation domain models with CodingKeys for snake_case
  - LocationRepository with search_locations RPC, bounding box + Haversine nearest city, user_locations CRUD
  - LocationViewModel with 300ms debounced search, GPS detection via CLLocationManager
  - LocationPickerView with searchable city list, GPS button, country flag emojis
  - First-launch location prompt via TabContainerView
affects: [02-ios-core/03, 03-prayer-monetization/01, 03-prayer-monetization/02]

# Tech tracking
tech-stack:
  added: [CoreLocation]
  patterns:
    - "Optimistic update with rollback on synced settings"
    - "Single-field Supabase update to avoid full object roundtrip"
    - "@ObservationIgnored for CLLocationManager in @Observable class"
    - "Separate CLLocationManagerDelegate class to avoid @Observable + NSObject conflicts"
    - "300ms debounced search via Task.sleep cancellation"
    - "Bounding box + Haversine for nearest city from GPS coordinates"
    - "Country flag emoji derived from 2-letter country code"

key-files:
  created:
    - Sources/Core/Models/Domain/SyncedUserSettings.swift
    - Sources/Core/Models/Domain/GeoLocation.swift
    - Sources/Core/Models/Domain/UserLocation.swift
    - Sources/Data/Repositories/SettingsRepository.swift
    - Sources/Data/Repositories/LocationRepository.swift
    - Sources/Features/Settings/SettingsView.swift
    - Sources/Features/Settings/SettingsViewModel.swift
    - Sources/Features/Settings/NusachPickerView.swift
    - Sources/Features/Settings/ZmanimOpinionsView.swift
    - Sources/Features/Settings/AppearanceSettingsView.swift
    - Sources/Features/Location/LocationPickerView.swift
    - Sources/Features/Location/LocationViewModel.swift
  modified:
    - Sources/Core/LocalSettings.swift
    - Sources/Core/DI/DependencyContainer.swift
    - Sources/Features/Home/TabContainerView.swift
    - Info.plist
    - project.yml
    - SmartSiddur.xcodeproj/project.pbxproj

key-decisions:
  - "@MainActor on DependencyContainer to access @MainActor LocalSettings.shared"
  - "Separate LocationManagerDelegate class instead of NSObject subclass to avoid @Observable macro conflicts with lazy properties"
  - "Bounding box + Haversine client-side sort for GPS nearest city instead of PostgREST computed columns"
  - "Single-field updateSingleSetting for optimistic updates instead of full SyncedUserSettings roundtrip"
  - "NSLocationWhenInUseUsageDescription added for GPS permission"

patterns-established:
  - "Optimistic update pattern: apply locally, fire async Supabase update, rollback on failure"
  - "Settings split: synced (Supabase) vs local (UserDefaults) with instant local response"
  - "LocationManagerDelegate as separate class for @Observable compatibility"
  - "First-launch prompt: TabContainerView checks for saved location on appear"

# Metrics
duration: ~12min
completed: 2026-02-09
---

# Phase 02 Plan 02: Settings and Location Summary

**Full settings system (16 local + 17 synced fields) with optimistic Supabase updates, location picker searching 141K cities via RPC, and GPS nearest-city detection using Haversine**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-02-09T14:29:05Z
- **Completed:** 2026-02-09T14:41:00Z
- **Tasks:** 2/2
- **Files created/modified:** 18

## Accomplishments
- Complete settings system with 16 local (UserDefaults) and 17 synced (Supabase) settings covering all fields from MIGRATION_SPEC Sections 6.2 and 6.3
- Optimistic update pattern: local changes apply instantly, Supabase updates fire async with rollback on failure
- Location picker with 300ms debounced search against 141K seeded cities via search_locations RPC
- GPS detection using CLLocationManager with bounding box + Haversine distance for nearest city
- First-launch location prompt: auto-presents LocationPickerView when no saved location exists
- 10-section SettingsView organized by Identity, Location/Calendar, Zmanim Opinions, Personal Insertions, Shabbat, Appearance, Display, Prayer Mode, Temporary States, Account
- Sub-screens: NusachPickerView (4 nusachot with Hebrew names), ZmanimOpinionsView (4 opinion categories), AppearanceSettingsView (theme/font/size with live preview)

## Task Commits

Each task was committed atomically:

1. **Task 1: Build settings system** - `f7cbae4` (feat)
2. **Task 2: Build location picker with search and GPS** - `6c702f1` (feat)

## Files Created/Modified

- `Sources/Core/LocalSettings.swift` - Full @Observable UserDefaults wrapper with 16 local settings and 4 enums (TfilaMode, AppTheme, FontFamily, SilentMode)
- `Sources/Core/Models/Domain/SyncedUserSettings.swift` - Codable struct with 17 fields, CodingKeys for snake_case, 8 enums (Nusach, AppLanguage, MukafMode, DateChangeRule, DawnOpinion, SunriseOpinion, ZmanOpinion, DuskOpinion)
- `Sources/Core/Models/Domain/GeoLocation.swift` - Codable model for geo_locations table with country flag emoji helper
- `Sources/Core/Models/Domain/UserLocation.swift` - Codable model for user_locations table
- `Sources/Data/Repositories/SettingsRepository.swift` - Protocol + implementation: fetchSyncedSettings, updateSyncedSettings, updateSingleSetting
- `Sources/Data/Repositories/LocationRepository.swift` - Protocol + implementation: searchLocations (RPC), findNearestCity (bounding box + Haversine), getSelectedLocation, getUserLocations, saveLocation (deselect + insert)
- `Sources/Features/Settings/SettingsView.swift` - Main settings screen with 10 sections
- `Sources/Features/Settings/SettingsViewModel.swift` - @Observable with optimistic update + rollback for all 16 synced fields
- `Sources/Features/Settings/NusachPickerView.swift` - List picker for 4 nusachot with Hebrew names
- `Sources/Features/Settings/ZmanimOpinionsView.swift` - Grouped pickers for dawn, sunrise, zman, dusk opinions
- `Sources/Features/Settings/AppearanceSettingsView.swift` - Theme picker, font family, font size slider with live preview
- `Sources/Features/Location/LocationPickerView.swift` - Searchable city list with GPS button and country flags
- `Sources/Features/Location/LocationViewModel.swift` - @Observable with debounced search, GPS detection, location selection
- `Sources/Core/DI/DependencyContainer.swift` - Updated with settingsRepository, localSettings, locationRepository, selectedLocationName
- `Sources/Features/Home/TabContainerView.swift` - Wired SettingsView, added first-launch location prompt
- `Info.plist` - Added NSLocationWhenInUseUsageDescription
- `project.yml` - Added NSLocationWhenInUseUsageDescription

## Decisions Made

1. **@MainActor on DependencyContainer** -- Required because LocalSettings.shared is @MainActor isolated (Swift 6 strict concurrency). DependencyContainer is always used from the main thread anyway (SwiftUI environment).

2. **Separate LocationManagerDelegate class** -- @Observable macro conflicts with lazy properties and NSObject subclass patterns. Created a separate delegate class that forwards CLLocationManager events via closures, using @ObservationIgnored for the manager/delegate references.

3. **Bounding box + Haversine for nearest city** -- Instead of complex PostgREST computed columns, fetch ~50 cities within 1-degree bounding box from Supabase, then sort client-side by Haversine distance. Simple, accurate, and avoids custom SQL functions.

4. **Single-field updates** -- updateSingleSetting sends only the changed column to Supabase instead of the full SyncedUserSettings object, reducing payload and avoiding race conditions when multiple settings change rapidly.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] @Observable + lazy CLLocationManager conflict**
- **Found during:** Task 2 (LocationViewModel build)
- **Issue:** Swift @Observable macro cannot synthesize observation tracking for lazy properties. The lazy var locationManager pattern caused init accessor errors.
- **Fix:** Created separate LocationManagerDelegate class, used @ObservationIgnored for stored CLLocationManager and delegate references.
- **Files modified:** Sources/Features/Location/LocationViewModel.swift
- **Verification:** Build succeeded
- **Committed in:** 6c702f1 (Task 2 commit)

**2. [Rule 3 - Blocking] DependencyContainer not @MainActor caused concurrency error**
- **Found during:** Task 1 (build verification)
- **Issue:** DependencyContainer.init() accessed LocalSettings.shared which is @MainActor isolated, but DependencyContainer itself was not.
- **Fix:** Added @MainActor to DependencyContainer class declaration.
- **Files modified:** Sources/Core/DI/DependencyContainer.swift
- **Verification:** Build succeeded
- **Committed in:** f7cbae4 (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking)
**Impact on plan:** Both fixes required for Swift 6 strict concurrency compliance. No scope creep.

## Issues Encountered
- Plan file paths used `SmartSiddur-iOS/Sources/` prefix but actual project structure uses `Sources/` directly. Adapted paths accordingly.
- Swift 6 strict concurrency (`SWIFT_STRICT_CONCURRENCY: complete`) required careful actor isolation throughout.

## User Setup Required
None - no external service configuration required. GPS permission is requested at runtime.

## Next Phase Readiness
- Settings system complete with all synced and local fields
- Location picker fully functional with search and GPS
- DependencyContainer holds all repositories needed for prayer assembly (next plan)
- Nusach, language, zmanim opinions, and location are all available for prayer generation
- No blockers

---
*Phase: 02-ios-core*
*Completed: 2026-02-09*
