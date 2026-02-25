# Smart Siddur Localization (System-First) Task List

**Plan Reference**: `docs/plans/2026-02-23-localization-system-first.md`  
**Status**: In Progress  
**Created**: 2026-02-23

---

## Phase 1: Infrastructure and Settings Cleanup

### 1.1 Remove UI Language Source of Truth
**Priority**: Critical  
**Files**:
- `Sources/Features/Settings/SettingsView.swift`
- `Sources/Features/Settings/SettingsViewModel.swift`
- `Sources/Core/Models/Domain/SyncedUserSettings.swift`

**Tasks**:
- [x] Remove in-app language picker from Settings UI.
- [x] Add Settings explanatory copy that UI language follows iOS App Language.
- [x] Keep synced `language` model field and update API path for backend compatibility (no UI ownership).

**Acceptance Criteria**:
- No Settings control can directly change UI language.
- Users can discover where language is controlled (iOS Settings app).
- Prayer/backend request compatibility remains intact.

---

## Phase 2: String Localization Migration

### 2.1 Localization Resources Bootstrap
**Priority**: High  
**Files**:
- `Sources/Resources/Localization/`

**Tasks**:
- [ ] Add baseline localization resources for `en`, `he`, `fr`, `es`, `de`.
- [ ] Move newly introduced Settings explanatory copy to localization keys.
- [ ] Set fallback behavior to English for missing keys.

**Acceptance Criteria**:
- Localization resources compile and load.
- New copy is key-based and translatable.

---

## Phase 3: Locale-Driven Formatting

### 3.1 Shared Formatter Utilities
**Priority**: Critical  
**Files**:
- `Sources/Core/Models/Domain/ZmanTime.swift` (shared `LocaleFormatters`)

**Tasks**:
- [x] Create shared date/time formatting helpers using `Locale.autoupdatingCurrent`.
- [x] Support locale-aware long date formatting.
- [x] Support locale-aware date template formatting (`day + month + year`).
- [x] Support locale-aware time formatting with optional 24h override and timezone input.

### 3.2 Replace Hardcoded/Isolated Formatters in UI
**Priority**: High  
**Files**:
- `Sources/Features/Home/HomeViewModel.swift`
- `Sources/Features/Calendar/CalendarViewModel.swift`
- `Sources/Features/Calendar/CalendarView.swift`
- `Sources/Features/Calendar/DayDetailSheet.swift`
- `Sources/Features/Zmanim/ZmanimView.swift`
- `Sources/Core/Models/Domain/ZmanTime.swift`

**Tasks**:
- [x] Remove forced `en_US_POSIX` date formatting from Home.
- [x] Migrate Calendar month/day formatting to shared locale-aware helpers.
- [x] Migrate Zmanim and day-detail date rendering to shared helpers.
- [x] Migrate zman row time formatting to shared helpers.

**Acceptance Criteria**:
- Dates/times follow active iOS app locale.
- No hardcoded English locale remains in these UI paths.

---

## Phase 4: Directionality Policy Enforcement

### 4.1 Layout Direction Rules
**Priority**: High  
**Files**:
- `Sources/Features/Calendar/CalendarView.swift`
- `Sources/Features/Prayers/PrayerTextView.swift`

**Tasks**:
- [x] Remove non-prayer explicit `layoutDirection` overrides that conflict with system language direction.
- [x] Force RTL in prayer text screen regardless of app language.

**Acceptance Criteria**:
- Non-prayer screens use system language direction by default.
- Prayer text view stays RTL in all app languages.

---

## QA Checklist (Initial)

- [ ] Verify Settings screen has no UI language picker.
- [ ] Verify Settings language guidance text is visible.
- [ ] Verify Home/Calendar/Zmanim dates update format under different iOS app languages/locales.
- [ ] Verify prayer text screen remains RTL when app language is English.
- [ ] Verify non-prayer screens are LTR in English and RTL in Hebrew app language.
