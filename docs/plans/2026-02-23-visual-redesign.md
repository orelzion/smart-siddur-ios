# Smart Siddur Visual Redesign

**Date**: 2026-02-23
**Status**: Approved

---

## Overview

Complete visual redesign of Smart Siddur from a standard iOS List-based UI to a premium dark/gold glassmorphism aesthetic. Restructures the app from 4 tabs to 3 tabs, introduces a dynamic Home screen with intelligent prayer suggestions, and unifies the Calendar and Zmanim tabs.

Reference mockup: `new_style.html` in project root.

---

## Design Decisions

### Tab Structure: 3 Tabs
- **Home** -- greeting, hero card (next prayer + countdown), suggested items, dynamic prayer grid
- **Calendar/Zmanim** -- unified day/month calendar with inline zmanim
- **Settings** -- restyled existing settings

### Theme: Dark + Light
- Dark theme matches the `new_style.html` mockup (navy gradient + gold accents + glassmorphism)
- Light theme variant for accessibility (warm cream background + darker gold + subtle shadows)
- System/Light/Dark toggle retained in Settings

### Typography
- System fonts for all UI text (SF Pro / SF Hebrew)
- Culmus Taamey fonts for prayer text reading (future feature: user-selectable font picker from https://culmus.sourceforge.io/taamim/index.html)
  - Available fonts: Taamey Frank CLM, Taamey Ashkenaz, Shofar, Taamey David CLM, Keter Aram Tsova, Keter YG
- No custom fonts bundled in Phase 1

### Tab Bar
- Styled standard SwiftUI TabView (not custom implementation)
- Glass background appearance, gold accent tint

---

## Home Tab Design

### Greeting Header
- "Shalom, [user name]"
- Hebrew date + Gregorian date (e.g., "6 Adar 5786 / 23 February")
- Data sources: `AuthViewModel.displayName`, `JewishCalendarService`

### Hero Card -- Multi-Stage Dynamic Prayer CTA

The hero card shows the current prayer with a countdown that progresses through multiple zmanim milestones. Each milestone includes a brief halachic context subtitle.

| Time Window | CTA Prayer | Milestone Shown | Halachic Context |
|-------------|-----------|-----------------|------------------|
| Alot -> Netz | Shacharit | Countdown to Netz HaChama | "Sunrise - earliest preferred Shacharit" |
| Netz -> Sof Zman Shma | Shacharit | Countdown to Sof Zman Kriat Shma | "Last time to recite Shma - GR\"A" |
| Sof Zman Shma -> Sof Zman Tefila | Shacharit | Countdown to Sof Zman Tefila | "Last time for Amida - GR\"A" |
| Sof Zman Tefila -> Chatzot | Shacharit | Countdown to Chatzot HaYom | "Midday - last time for Shacharit makeup" |
| Chatzot -> Mincha Gedola | Waiting (no prayer) | Countdown to Mincha Gedola | "Mincha begins in..." |
| Mincha Gedola -> Shkia | Mincha | Countdown to Shkia | "Sunset" |
| Shkia -> Tzet | Transitional | Countdown to Tzet HaKochavim | "Between Mincha & Arvit" -- both options shown |
| Tzet -> Chatzot Layla | Arvit | Countdown to Chatzot Layla | "Halachic midnight" |
| Chatzot Layla -> Alot | Arvit | Countdown to Alot HaShachar | "Dawn" |

**Timer behavior**: Recalculates on each milestone crossing. Handles app backgrounding/foregrounding via `scenePhase` observation.

**Transitional state (Shkia -> Tzet)**: Shows "Between Mincha and Arvit" with both prayer options accessible. Arvit also appears in the quick-access cards during this window.

### Suggested For You Section

Extended from `PrayerVisibilityService`:

- **Seasonal badge** (green-tinted): contextual to Jewish calendar month/season
  - Examples: "Chodesh Nisan: Birkat Ha'Ilanot available", "Sefirat HaOmer tonight", "Chanukah night 3"
- **Quick-access cards** (2-column grid): common blessings and contextual items
  - Birkat HaMazon, Asher Yatzar (commonly used)
  - Omer count (during Sefirah), Havdala (Motzei Shabbat), etc.
- **Arvit quick-access**: shown in the sunset-to-dusk transitional window

### All Prayers Grid (Dynamic)

2-column grid filtered by today's relevance:
- **Always shown**: Shacharit, Mincha, Arvit, Birkat HaMazon, Kriat Shma Al HaMita, Birchot HaShachar
- **Conditionally shown**: Hallel, Mussaf, Omer, Chanukah, Slichot, Tehillim, etc.
- **Hidden**: prayers not applicable today (e.g., no Slichot outside Elul/Aseret Yemei Teshuva, no Omer outside Sefirah)
- Current/next prayer highlighted with gold border

---

## Calendar/Zmanim Unified Tab Design

### Controls
- **Day/Month segmented toggle**: switches between daily card view and monthly grid
- **Hebrew/Gregorian segmented toggle**: switches date display language

### Month View
- 7-column grid in a glass card
- **Day cells**: Primary date (large) + tiny secondary date based on Hebrew/Gregorian toggle
- **Day type indicators**: Colored dots preserved (purple=Shabbat, orange=Yom Tov, red=Fast, blue=Rosh Chodesh, green=Chol HaMoed)
- **Today**: Gold filled circle
- **Navigation**: Horizontal swipe gestures + small arrow buttons for month-to-month
- **Day tap**: Updates day info card and zmanim list inline below the grid (no sheet)

### Day View
- Single day info card with full zmanim list
- **Swipeable**: horizontal swipe to navigate between consecutive days
- Displays the adaptive day info card + zmanim for the selected day

### Day Info Card (Adaptive)

**Always shown:**
- Hebrew date (primary) + Gregorian date
- Parsha (on the relevant week)
- Daf Yomi

**Shown when applicable:**

| Context | Special Zmanim / Info |
|---------|----------------------|
| Erev Shabbat | Candle lighting time, Parsha |
| Motzei Shabbat | Havdala time |
| Erev Yom Tov | Candle lighting time, Yom Tov name |
| Motzei Yom Tov | Havdala time |
| Chanukah | Candle lighting time (shkia/tzet per minhag), night number |
| Fast day (regular: 10 Tevet, 17 Tammuz, Tzom Gedaliah, Ta'anit Esther) | Fast begins (alot), fast ends (tzet), fast name |
| Tisha B'Av | Fast begins (previous evening shkia), fast ends |
| Erev Pesach | Sof Zman Achilat Chametz, Sof Zman Biur Chametz |
| Sefirat HaOmer | Tonight's omer count (day + weeks) |
| Rosh Chodesh | Rosh Chodesh name, Molad time |
| Chol HaMoed | Holiday name + "Chol HaMoed" |
| Purim | Megilla reading time (from tzet) |
| Erev Yom Kippur | Kol Nidrei time, pre-fast reminders |
| Erev Sukkot | Candle lighting |
| Hoshana Rabba | Sunrise for Hoshana prayers |
| Shmini Atzeret / Simchat Torah | Mashiv HaRuach starts, candle lighting |
| Lag Ba'Omer | Bonfire time (tzet) |

### Zmanim List
- Essential zmanim shown by default (~5-8 key times)
- "Show all zmanim" expandable button reveals full 16
- Gold-colored time values
- Next upcoming zman highlighted
- Glass card rows

---

## Settings Tab Design

Restyled with dark/gold theme:
- Glass card sections instead of grouped List rows
- Gold accent for toggles, pickers, selected states
- Same functionality as current: Identity, Location, Zmanim Opinions, Appearance, Display, Privacy, Account

---

## Onboarding / Login Redesign

- Dark/gold theme replacing current blue gradient
- Same auth options: Apple Sign-In, Google Sign-In, Anonymous
- Styled to match the new app identity

---

## Design System

### Color Palette

**Dark Theme:**

| Token | Value | Purpose |
|-------|-------|---------|
| bgPrimary | #0f172a -> #020617 gradient | Main background |
| bgCard | rgba(255,255,255,0.06) | Glass card fill |
| borderCard | rgba(255,255,255,0.10) | Glass card border |
| accentGold | #d4af37 | Primary accent, buttons, highlights |
| accentGoldLight | #f3e5ab | Gradient text, subtle tints |
| textPrimary | #f8fafc | Main text |
| textSecondary | #94a3b8 | Subtitle, secondary info |
| seasonalGreen | #4ade80 on rgba(34,197,94,0.1) | Seasonal badges |

**Light Theme:**

| Token | Value | Purpose |
|-------|-------|---------|
| bgPrimary | #faf8f5 (warm cream) | Main background |
| bgCard | #ffffff with subtle shadow | Card fill |
| borderCard | rgba(0,0,0,0.08) | Card border |
| accentGold | #b8941e (darker for contrast) | Primary accent |
| accentGoldLight | #d4af37 | Gradient accents |
| textPrimary | #1a1a2e | Main text |
| textSecondary | #64748b | Secondary text |
| seasonalGreen | #16a34a on rgba(34,197,94,0.08) | Seasonal badges |

### Shared UI Components

| Component | Purpose |
|-----------|---------|
| GlassCard | View modifier: glass background, border, corner radius |
| GoldGradientText | Text with white-to-gold gradient fill |
| PrimaryButton | Gold CTA button style |
| SegmentedPicker | Styled segmented control matching design |
| ZmanRow | Glass card row with gold time display |
| SuggestedCard | Small quick-access glass card |
| SeasonalBadge | Green-tinted contextual badge |
| HeroCard | Next prayer card with multi-stage countdown |

### Animations & Haptics
- Spring animations for state transitions
- Fade animations for page/tab switches
- Haptic feedback on: CTA button tap, tab switch, toggle changes

---

## New Models

```swift
struct NextPrayerState {
    let prayer: PrayerType?            // nil during waiting/transition
    let currentMilestone: PrayerMilestone
    let isTransitional: Bool           // between Mincha and Arvit
    let alternativePrayer: PrayerType? // for transitional state
}

struct PrayerMilestone {
    let name: String                   // e.g., "Sof Zman Kriat Shma"
    let hebrewName: String             // e.g., "סוף זמן קריאת שמע"
    let time: Date
    let halachicDescription: String    // e.g., "Last time to recite Shma - GR\"A"
}

struct SuggestedItem {
    let icon: String                   // SF Symbol or emoji
    let title: String
    let prayerType: PrayerType
    let badgeText: String?             // for seasonal badge
}

struct SpecialZman {
    let name: String
    let hebrewName: String
    let time: Date
    let context: String                // e.g., "Fast ends", "Candle lighting"
}
```

## New / Extended Services

| Service | Type | Purpose |
|---------|------|---------|
| `NextPrayerService` | **New** | Multi-stage prayer milestone calculation with timer. Depends on `ZmanimService`. Recalculates at milestone boundaries and on scenePhase changes. |
| `PrayerVisibilityService` | **Extended** | Add `suggestedItems(for date:)` returning `[SuggestedItem]` for seasonal badges and contextual blessings. |
| `ZmanimService` | **Extended** | Add `specialZmanim(for day:)` returning `[SpecialZman]` for the adaptive day info card (candle lighting, fast times, chametz deadlines, etc.). |
| `JewishCalendarService` | **Extended** | Add `seasonalBadge(for date:)` returning optional seasonal context string. |

---

## Implementation Phases

### Phase 1: Design System Foundation
- `Sources/UI/Theme/AppTheme.swift` -- design tokens with dark/light variants
- `Colors.xcassets` -- adaptive color sets for all tokens
- All shared UI components in `Sources/UI/Components/`
- Update `project.yml` for new resources

### Phase 2: Home Tab
- `NextPrayerService` with multi-stage milestone logic and timer
- `NextPrayerState`, `PrayerMilestone`, `SuggestedItem` models
- Extended `PrayerVisibilityService` (suggested items + seasonal badges)
- `HomeViewModel` orchestrating all Home data
- `NewHomeView` with greeting, hero card, suggestions, dynamic prayer grid

### Phase 3: Unified Calendar/Zmanim Tab
- Merge `CalendarView` + `ZmanimView` into `UnifiedCalendarView`
- Day/month segmented toggle
- Hebrew/Gregorian segmented toggle
- Month view: glass grid, colored dots + gold today, swipe + arrows navigation
- Day view: swipeable between consecutive days
- Adaptive day info card with `SpecialZman` model and extended `ZmanimService`
- Essential zmanim by default, expandable to full list
- Inline day detail on month day tap (replace DayDetailSheet)

### Phase 4: Tab Structure Migration
- `TabContainerView`: 4 tabs -> 3 tabs (Home, Calendar/Zmanim, Settings)
- Styled standard TabView (glass background, gold tint)
- Remove old `PrayersMenuView` tab (absorbed into Home)
- Spring/fade tab transition animations

### Phase 5: Settings & Onboarding Restyle
- `SettingsView`: glass cards on dark background
- All settings sub-views restyled
- `LoginView` / `OnboardingView`: dark/gold theme
- Haptic feedback on key interactions

### Phase 6: Polish
- Animation refinements
- Light theme QA across all screens
- RTL layout thorough verification
- Accessibility audit (VoiceOver, Dynamic Type)

---

## Data Dependencies

- `NextPrayerService` depends on `ZmanimService` (exists)
- Suggested items depend on `JewishCalendarService` + `PrayerVisibilityService` (both exist)
- All UI work depends on Phase 1 (Design System)
- **No backend changes required** -- all data sources already exist

## Risk Areas

- **Countdown timer**: Must handle background/foreground correctly (scenePhase recalculation). Timer should fire at next milestone boundary, not every second.
- **Light theme**: Mockup is dark-only. Light variant colors need careful design to maintain the premium feel without looking washed out.
- **Dynamic prayer grid**: Filtering logic needs thorough testing across all calendar scenarios (holidays, double days in diaspora, fast days, special Shabbatot).
- **Swipe navigation conflicts**: Day view swiping (between days) and month view swiping (between months) must not interfere with each other or with the tab bar.
- **Special zmanim coverage**: Full coverage of all Jewish calendar edge cases (diaspora vs. Israel double holidays, nidcheh fast days, etc.).
- **RTL layout**: The entire design is RTL (Hebrew). All glass cards, grids, and navigation must respect RTL consistently.
