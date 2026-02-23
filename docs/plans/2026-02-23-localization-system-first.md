# Smart Siddur Localization Plan (System-First)

**Date**: 2026-02-23  
**Status**: Planned (Deferred)  
**Owner**: iOS app team

---

## Goal

Move app UI localization to native iOS behavior:

- Use system language picker (iOS app language / preferred languages)
- Use system locale for formatting (date/time/number)
- Keep prayer-reading screen forced RTL
- Use language-driven direction on all other screens

This plan is saved for a later implementation cycle.

---

## Key Decisions

1. **System language is source of truth for UI**
- No custom in-app language selector for UI rendering.
- UI text comes from iOS localization resources.

2. **System locale formatting everywhere**
- Date/time/number formatting follows active locale automatically.
- Remove hardcoded locale values for UI formatting.

3. **Layout direction policy**
- Prayer text screens: always RTL.
- All other screens: direction follows selected app language (system-managed).

4. **Synced `language` setting scope**
- Do not use synced language as UI source.
- Keep/update only if needed for backend prayer generation compatibility.
- Add migration note to avoid user confusion in Settings UI.

---

## Scope

### In Scope
- String localization across app UI (Home, Calendar, Zmanim, Settings, Auth, Location, Prayers shell).
- System-locale-based formatting.
- Directionality behavior per policy above.
- Settings UX cleanup around language source.

### Out of Scope
- Rewriting prayer body generation backend logic.
- New custom language override UX.

---

## Architecture

1. **Localization assets**
- Introduce/expand String Catalog(s) (`.xcstrings`) for `en`, `he`, `fr`, `es`, `de`.
- Replace hardcoded strings with localization keys.

2. **Root app environment**
- Rely on iOS app language behavior by default.
- Avoid custom `.environment(\.locale, ...)` unless required for isolated previews/tests.

3. **Direction handling**
- Default app direction from locale.
- In prayer text view, explicitly force RTL for content layout and text alignment.

4. **Formatting abstraction**
- Create light formatter helpers for date/time/number display using `Locale.autoupdatingCurrent`.
- Ensure helpers are used consistently in Home/Calendar/Zmanim.

---

## Implementation Phases

## Phase 1: Infrastructure and Settings Cleanup

### Tasks
- Remove/disable UI language picker in Settings screen.
- Add explanatory text: app language follows iOS language settings.
- Keep backward-compatible storage for synced language only where backend requires it.

### Acceptance Criteria
- No in-app UI language selector controls localization.
- Language behavior is consistent with iOS Settings app language.

---

## Phase 2: String Localization Migration

### Tasks
- Replace hardcoded UI strings with localization keys across:
  - `Sources/Features/Home/`
  - `Sources/Features/Calendar/`
  - `Sources/Features/Zmanim/`
  - `Sources/Features/Settings/`
  - `Sources/Features/Auth/`
  - `Sources/Features/Location/`
  - `Sources/Features/Prayers/` (chrome/UI shell only)
- Localize prayer/category display names where shown as UI labels.

### Acceptance Criteria
- All visible app chrome text localizes in `en/he/fr/es/de`.
- Missing key fallback is English.

---

## Phase 3: Locale-Driven Formatting

### Tasks
- Remove forced locale usage (e.g., hardcoded POSIX/English formatters).
- Standardize locale-aware date/time formatting utilities.
- Audit Home and Calendar date strings for locale correctness.

### Acceptance Criteria
- Dates/times change format correctly per active app language/locale.
- No hardcoded English formatting remains in UI paths.

---

## Phase 4: Directionality Policy Enforcement

### Tasks
- Ensure non-prayer screens follow locale direction automatically.
- Keep prayer text screen explicitly RTL regardless of app language.
- Validate navigation bars, grids, and alignment under Hebrew vs non-Hebrew languages.

### Acceptance Criteria
- Prayer text remains RTL in all languages.
- Other screens mirror correctly for Hebrew and remain LTR otherwise.

---

## QA Plan

1. **Language matrix**
- Verify `en`, `he`, `fr`, `es`, `de` on key screens.

2. **Direction checks**
- Hebrew: non-prayer screens RTL, prayer screens RTL.
- English/French/Spanish/German: non-prayer screens LTR, prayer screens RTL.

3. **Formatting checks**
- Date/time format differences visible between locales.

4. **Regression checks**
- Prayer fetch still works with backend language requirements.
- Settings save/load remains stable after language UI changes.

---

## Risks and Mitigations

1. **Risk**: Partial migration leaves mixed-language UI.
- **Mitigation**: Track migration by screen checklist; block release until complete.

2. **Risk**: Backend still depends on synced language.
- **Mitigation**: Keep mapping layer for requests; decouple from UI localization.

3. **Risk**: Directionality regressions in custom layouts.
- **Mitigation**: Snapshot/screenshots in Hebrew and English for every tab.

---

## Deliverables

- Updated localization resources for 5 languages.
- Refactored UI strings and formatters.
- Settings language UX aligned with system behavior.
- Directionality behavior implemented per policy.
- QA evidence for language/direction/formatting matrix.
