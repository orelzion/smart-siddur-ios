---
phase: 02-ios-core
plan: 03
subsystem: zmanim-calendar
tags: [kosherswift, swiftui, zmanim, jewish-calendar, hebrew-dates, gematria, observable]

# Dependency graph
requires:
  - phase: 01-backend-foundation
    provides: geo_locations table, user_settings table with zmanim opinion columns
  - phase: 02-ios-core/01
    provides: Auth flow, DependencyContainer, TabContainerView shell, Supabase client
  - phase: 02-ios-core/02
    provides: SettingsRepository, LocationRepository, UserLocation, SyncedUserSettings with opinion enums
provides:
  - ZmanimService wrapping KosherSwift ComplexZmanimCalendar with opinion-aware calculation
  - ZmanTime model with essential/comprehensive flag, next-zman highlighting, chronological sorting
  - ZmanimViewModel with opinion-aware recalculation, date override support, pull-to-refresh
  - ZmanimView with essential/comprehensive toggle and Shabbat times section
  - JewishCalendarService wrapping KosherSwift JewishCalendar for holidays, parsha, omer, Daf Yomi
  - JewishDay model with day type for calendar cell coloring
  - CalendarView with month grid, Hebrew/Gregorian segmented control toggle, month navigation
  - CalendarGridView with LazyVGrid, colored day markers, today highlight
  - DayDetailSheet with sunrise/sunset, day info, and "View Full Zmanim" cross-tab navigation
  - HebrewDateFormatterUtil with gematria, Hebrew month names, leap year handling
  - Cross-tab navigation via zmanimDateOverride and selectedTab on DependencyContainer
affects: [03-prayer-monetization/01, 03-prayer-monetization/02]

# Tech tracking
tech-stack:
  added: [KosherSwift]
  patterns:
    - "KosherSwift ComplexZmanimCalendar with opinion-mapped method dispatch"
    - "Cross-tab navigation via shared container state (zmanimDateOverride + selectedTab)"
    - "Chronological sorting of zmanim by computed time for both essential and comprehensive modes"
    - "Segmented control for binary mode toggle with clear active-state indication"
    - "HebrewDateFormatter gematria with special cases for 15 (Tet-Vav) and 16 (Tet-Zayin)"
    - "JewishCalendar holiday/parsha/omer detection via KosherSwift with Israel/Diaspora flag"
    - "Day type enum for calendar cell coloring (shabbat, yomTov, cholHamoed, fastDay, roshChodesh)"

key-files:
  created:
    - Sources/Core/Models/Domain/ZmanTime.swift
    - Sources/Core/Models/Domain/JewishDay.swift
    - Sources/Services/ZmanimService.swift
    - Sources/Services/JewishCalendarService.swift
    - Sources/Features/Zmanim/ZmanimView.swift
    - Sources/Features/Zmanim/ZmanimViewModel.swift
    - Sources/Features/Zmanim/ZmanRowView.swift
    - Sources/Features/Calendar/CalendarView.swift
    - Sources/Features/Calendar/CalendarViewModel.swift
    - Sources/Features/Calendar/CalendarGridView.swift
    - Sources/Features/Calendar/DayDetailSheet.swift
    - Sources/Features/Calendar/HebrewDateFormatter.swift
  modified:
    - Sources/Core/DI/DependencyContainer.swift
    - Sources/Features/Home/TabContainerView.swift
    - project.yml
    - SmartSiddur.xcodeproj/project.pbxproj

key-decisions:
  - "KosherSwift.GeoLocation qualified import to avoid collision with app's GeoLocation domain model"
  - "Opinion-mapped method dispatch: each user opinion enum maps to specific KosherSwift API method"
  - "DayDetailSheet shows only sunrise/sunset + special zmanim; full list via cross-tab navigation"
  - "Chronological sorting of zmanim by time rather than insertion order for natural day flow"
  - "Segmented control for calendar mode toggle instead of button for clear active-state indication"
  - "zmanimDateOverride + selectedTab on DependencyContainer for calendar-to-zmanim cross-tab navigation"
  - "English primary names for common zmanim (Sunrise, Sunset, etc.) with Hebrew subtitles; halachic terms kept as transliteration"
  - "KosherSwift month 7 = plain Adar in non-leap years (Swift Hebrew calendar quirk), leap year override for Adar I/II"

patterns-established:
  - "Cross-tab navigation: set shared state on DependencyContainer, onChange triggers in destination tab"
  - "Zmanim opinion dispatch: switch on enum to select KosherSwift method (extensible for new opinions)"
  - "Calendar grid: LazyVGrid with 7 columns, leading empty cells for month alignment"
  - "Day detail as .sheet with .presentationDetents for adaptive height"

# Metrics
duration: ~38min
completed: 2026-02-09
---

# Phase 02 Plan 03: Zmanim + Calendar Summary

**Opinion-aware zmanim display via KosherSwift with essential/comprehensive toggle, full Hebrew/Gregorian calendar with day markers, and cross-tab navigation from day detail to full zmanim**

## Performance

- **Duration:** ~38 min (including checkpoint review and UX fixes)
- **Started:** 2026-02-09T14:43:56Z
- **Completed:** 2026-02-09T15:22:55Z
- **Tasks:** 3/3 (2 auto + 1 checkpoint with UX fixes)
- **Files created/modified:** 16

## Accomplishments

- KosherSwift 1.10.5 added as SPM dependency for client-side zmanim and Jewish calendar calculations
- ZmanimService wraps ComplexZmanimCalendar with opinion-aware method dispatch for 5 opinion categories (dawn: 3, sunrise: 2, zman: 2, dusk: 5, candle/havdalah minutes)
- 8 essential zmanim (alot, netz, sof zman shma, sof zman tfila, chatzot, mincha gedola, shkia, tzeit) plus 8 comprehensive additions (misheyakir, alternate opinions, mincha ketana, plag, tzeit variants, chatzot halaila)
- Shabbat times (candle lighting Friday, havdalah Saturday) in dedicated section
- Next upcoming zman highlighted with accent color background
- Zmanim list sorted chronologically by time in both essential and comprehensive modes
- Full calendar month grid with Hebrew date overlay using gematria formatting
- Gregorian-primary and Hebrew-primary modes via segmented control toggle
- Colored day markers: purple (Shabbat), orange (Yom Tov), red (fast day), blue (Rosh Chodesh), green (Chol HaMoed)
- Day detail sheet shows Hebrew date, holiday, parsha, omer count, Daf Yomi, sunrise/sunset, and "View Full Zmanim" cross-tab navigation
- JewishCalendarService provides holiday detection, parsha lookup, omer count, and Daf Yomi via KosherSwift JewishCalendar
- HebrewDateFormatterUtil handles gematria (with 15/16 special cases), Hebrew month names, and leap year Adar I/II

## Task Commits

Each task was committed atomically:

1. **Task 1: Build ZmanimService and zmanim display screen** - `732f564` (feat)
2. **Task 2: Build calendar screen with Hebrew/Gregorian views and day details** - `23930fa` (feat)
3. **UX fixes from checkpoint review** - `d8155cf` (fix)
4. **Post-completion fixes: Adar month name bug + English zman names** - `d061b5c` (fix)

## Files Created/Modified

- `Sources/Core/Models/Domain/ZmanTime.swift` - ZmanTime model with ZmanCategory enum, essential flag, next-upcoming flag, formatted time helper
- `Sources/Core/Models/Domain/JewishDay.swift` - JewishDay model with DayType enum for calendar cell coloring
- `Sources/Services/ZmanimService.swift` - KosherSwift wrapper with opinion-aware zmanim calculation and Shabbat times
- `Sources/Services/JewishCalendarService.swift` - JewishCalendar wrapper for holidays, parsha, omer, Daf Yomi, Hebrew dates
- `Sources/Features/Zmanim/ZmanimView.swift` - Main zmanim tab with essential/comprehensive toggle, Shabbat section, date override support
- `Sources/Features/Zmanim/ZmanimViewModel.swift` - Observable VM with opinion-aware recalculation, chronological sorting, next-zman detection
- `Sources/Features/Zmanim/ZmanRowView.swift` - Single zman row with accent highlight for next upcoming
- `Sources/Features/Calendar/CalendarView.swift` - Full calendar screen with month navigation, segmented mode toggle
- `Sources/Features/Calendar/CalendarViewModel.swift` - Calendar VM with month navigation, JewishDay calculation, day detail data
- `Sources/Features/Calendar/CalendarGridView.swift` - 7-column LazyVGrid with dual-mode date cells and colored day markers
- `Sources/Features/Calendar/DayDetailSheet.swift` - Day detail with sunrise/sunset, day info, "View Full Zmanim" cross-tab button
- `Sources/Features/Calendar/HebrewDateFormatter.swift` - Gematria conversion, Hebrew month names, leap year handling
- `Sources/Core/DI/DependencyContainer.swift` - Added zmanimService, jewishCalendarService, zmanimDateOverride, selectedTab
- `Sources/Features/Home/TabContainerView.swift` - Wired Zmanim and Calendar tabs, added tab selection binding
- `project.yml` - Added KosherSwift SPM dependency
- `SmartSiddur.xcodeproj/project.pbxproj` - Regenerated with new files and dependency

## Decisions Made

1. **KosherSwift.GeoLocation qualified import** -- App already has a `GeoLocation` domain model for the Supabase geo_locations table. Used module-qualified `KosherSwift.GeoLocation` in ZmanimService to avoid name collision.

2. **Opinion-mapped method dispatch** -- Each user opinion enum (DawnOpinion, SunriseOpinion, ZmanOpinion, DuskOpinion) maps to a specific KosherSwift API method via switch statement. This is extensible for new opinions without changing the service interface.

3. **DayDetailSheet reduced scope** -- Per user feedback, the day detail sheet shows only sunrise/sunset + special zmanim (candle lighting, havdalah) instead of the full essential list. A "View Full Zmanim" button navigates to the Zmanim tab with the selected date.

4. **Chronological sorting** -- Zmanim are sorted by their calculated time in both essential and comprehensive modes, providing a natural day-flow reading experience instead of fixed insertion order.

5. **Segmented control for calendar mode** -- Per user feedback, replaced the single toggle button with a segmented control (`Picker(.segmented)`) that clearly shows which mode (Gregorian/Hebrew) is currently active.

6. **Cross-tab navigation via container state** -- The "View Full Zmanim" action sets `zmanimDateOverride` and `selectedTab` on DependencyContainer. The ZmanimView observes `zmanimDateOverride` via `onChange` and reloads for the new date. This avoids complex navigation coordinators.

## Deviations from Plan

### Auto-fixed Issues

None -- plan executed as written with post-checkpoint UX refinements.

### Post-Checkpoint UX Fixes

Per user testing feedback (3 issues):

1. **DayDetailSheet reduced to sunrise/sunset only** -- Added "View Full Zmanim" cross-tab navigation button
2. **Chronological sorting of zmanim list** -- Both essential and comprehensive lists now sorted by time
3. **Calendar mode segmented control** -- Replaced ambiguous toggle button with segmented control showing active state

These were committed as a separate fix commit (`d8155cf`) following the checkpoint review.

### Post-Completion Fixes (d061b5c)

Per user testing feedback (3 issues):

1. **[Rule 1 - Bug] Adar month name in non-leap years** -- KosherSwift's Swift Hebrew calendar returns month 7 (ADAR_II) for regular Adar in non-leap years. The `hebrewMonthNames` dictionary mapped month 7 to "אדר ב'" which is wrong for 5786 (non-leap year). Fixed by mapping month 7 to plain "אדר" in the base dictionary; leap year override dictionary correctly provides "אדר א'" / "אדר ב'" when needed. Same fix applied to English month names (month 7 now "Adar" instead of "Adar II" in base).

2. **English zman display names** -- Replaced Hebrew transliterations with English for common terms that have clear English equivalents: Alot HaShachar -> "Dawn", Netz HaChama -> "Sunrise", Chatzot -> "Midday", Shkia -> "Sunset", Tzeit HaKochavim -> "Nightfall", Chatzot HaLaila -> "Midnight", Tzeit 72 min -> "Nightfall 72 min", Tzeit Rabenu Tam -> "Nightfall Rabenu Tam". Hebrew names retained as subtitles in ZmanRowView. Halachic terms without clear English equivalents kept as-is (Sof Zman Shma, Mincha Gedola, Mincha Ketana, Plag HaMincha).

3. **Misheyakir renamed to Tallit & Tefillin** -- Changed display name from "Misheyakir" / "משייכיר" to "Tallit & Tefillin" / "זמן ציצית ותפילין" to better communicate what this time means to users.

## Issues Encountered

- KosherSwift `GeoLocation` class name collides with app's `GeoLocation` Codable struct. Resolved with module-qualified reference.
- Plan file paths used `SmartSiddur-iOS/Sources/` prefix but actual project structure uses `Sources/` directly. Adapted paths accordingly (same as 02-02).

## User Setup Required

None -- KosherSwift resolves via SPM automatically. No external service configuration needed.

## Next Phase Readiness

- Zmanim calculation fully working with opinion-aware methods
- Jewish calendar service provides all holiday/parsha/omer state needed for prayer assembly
- DependencyContainer holds zmanimService and jewishCalendarService for prayer generation (Phase 3)
- Cross-tab navigation pattern established for future features
- No blockers for Phase 3 (prayer assembly and monetization)

---
*Phase: 02-ios-core*
*Completed: 2026-02-09*
