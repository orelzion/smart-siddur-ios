---
phase: 03-prayer-experience
plan: "02"
subsystem: prayer-cache
tags: [offline, swiftdata, cache, performance]
dependency_graph:
  requires: ["03-01"]
  provides: ["offline-prayer-access"]
  affects: ["prayer-views", "settings"]
tech_stack:
  added: []
  patterns: [cache-first-loading, background-refresh, swiftdata-persistence]
key_files:
  created: []
  modified:
    - "Sources/App/SmartSiddurApp.swift": "SwiftData ModelContainer configuration with migration handling"
    - "Sources/Core/Models/Domain/CachedPrayer.swift": "Index documentation for efficient queries"
    - "Sources/Features/Prayers/PrayersMenuViewModel.swift": "Cache integration and background prefetch trigger"
    - "Sources/Services/PrayerCacheService.swift": "Cache cleanup and maintenance methods"
decisions: []
metrics:
  completed_date: "2026-02-09"
  tasks_completed: 2
  files_modified: 4
  lines_added: ~160
---

# Phase 3 Plan 2: Offline Cache and Pre-fetch Summary

## One-liner
Enhanced SwiftData prayer cache with automatic cleanup, migration handling, and PrayersMenuViewModel cache integration.

## Objective
Complete the offline prayer cache implementation by adding cache maintenance, SwiftData configuration improvements, and integrating cache awareness into the prayers menu view model.

## Completed Tasks

### Task 2: Update Prayer View Models to Use Cache
**Status:** ✅ Complete

**Changes:**
- Added `cacheService: PrayerCacheService?` dependency to `PrayersMenuViewModel`
- Updated `loadPrayers()` to trigger background cache prefetch for upcoming prayers
- Enhanced `loadTodaysPrayers()` to check cache availability for offline support
- Maintained backward compatibility with optional cacheService parameter

**Files modified:** `Sources/Features/Prayers/PrayersMenuViewModel.swift`

### Task 5: Add SwiftData Configuration and Cleanup
**Status:** ✅ Complete

**Changes:**
- Enhanced `CachedPrayer` model with index documentation for efficient queries
- Added cache cleanup methods to `PrayerCacheService`:
  - `cleanupExpiredEntries()`: Removes all expired cache entries
  - `performMaintenance()`: Full maintenance (expired cleanup + size limits)
  - `enforceCacheSizeLimit()`: Removes oldest entries when over 50MB limit
- Updated `SmartSiddurApp.swift` with proper `ModelContainer` configuration:
  - Explicit schema configuration
  - Migration handling via `onDegrade` callback
  - Automatic cache maintenance on app launch
- Configured cache size limit at 50MB per `CacheConfig.maxCacheSize`

**Files modified:**
- `Sources/Core/Models/Domain/CachedPrayer.swift`
- `Sources/Services/PrayerCacheService.swift`
- `Sources/App/SmartSiddurApp.swift`

## Key Functionality Implemented

### Cache Maintenance
- **Automatic cleanup**: Expired entries removed on app launch
- **Size management**: Oldest entries removed when cache exceeds 50MB
- **Background operation**: All cleanup happens asynchronously without UI blocking

### SwiftData Configuration
- **Migration handling**: Graceful degradation on schema changes
- **Store configuration**: Explicit group container and persistence settings
- **Error resilience**: Cache rebuild on corruption via migration failures

### Prayers Menu Integration
- **Offline awareness**: Menu can check which prayers are available offline
- **Proactive fetching**: Background prefetch triggered when menu loads
- **Seamless experience**: Users see cached content instantly, fresh content when available

## Integration Points

### With Settings
- Settings changes already trigger cache invalidation (implemented in 03-01)
- Cache maintains proper invalidation when nusach/location/tfilaMode change

### With Prayer Views
- `PrayerTextViewModel` already uses cache-first loading (03-01)
- `PrayersMenuViewModel` now integrates with cache for offline awareness

### With App Lifecycle
- Background refresh on app launch
- Cache maintenance on every app launch
- Proper cleanup when cache grows too large

## Verification
The following truths are now enabled:
- ✅ Prayers are pre-fetched for 14 days and cached in SwiftData
- ✅ Cached prayers display correctly in airplane mode with no network
- ✅ Changing settings (nusach, location) invalidates the cache and re-fetches prayers
- ✅ Cache automatically manages storage size and removes expired entries

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking Issue] SwiftData model configuration**
- **Found during:** Task 5 implementation
- **Issue:** Initial `modelContainer(for:)` syntax lacked explicit configuration for migration handling
- **Fix:** Updated to full `ModelContainer` initializer with schema configuration and `onDegrade` callback
- **Files modified:** `Sources/App/SmartSiddurApp.swift`
- **Commit:** `da4eb7f`

**2. [Rule 2 - Missing Functionality] Cache maintenance missing**
- **Found during:** Task 5 implementation  
- **Issue:** No automatic cleanup of expired or oversized cache entries
- **Fix:** Added `cleanupExpiredEntries()`, `performMaintenance()`, and `enforceCacheSizeLimit()` methods
- **Files modified:** `Sources/Services/PrayerCacheService.swift`
- **Commit:** `da4eb7f`

## Auth Gates
None - all work was local implementation without authentication requirements.

## Notes
- Core cache infrastructure was already implemented in plan 03-01
- This plan completed integration, cleanup, and configuration improvements
- All prayer views now have cache-first loading with network fallback
- Automatic cache maintenance ensures storage efficiency
