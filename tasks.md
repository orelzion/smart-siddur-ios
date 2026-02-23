# Smart Siddur Visual Redesign - Task List

**Plan Reference**: `docs/plans/2026-02-23-visual-redesign.md`  
**Status**: Ready for Implementation  
**Created**: 2026-02-23

---

## Phase 1: Design System Foundation

### 1.1 Core Theme Infrastructure
**Agent**: SwiftUI Expert  
**Priority**: Critical  
**Depends On**: None  
**Files**:
- `Sources/UI/Theme/AppTheme.swift`
- `Colors.xcassets`

**Tasks**:
- [ ] Create `AppTheme.swift` with design token system
  - Dark theme tokens (bgPrimary gradient #0f172a -> #020617, bgCard, borderCard, accentGold, etc.)
  - Light theme tokens (warm cream #faf8f5, darker gold contrast, etc.)
  - Semantic color accessors
  - Environment-based theme switching
- [ ] Populate `Colors.xcassets` with adaptive color sets
  - All tokens from design spec with light/dark variants
  - Ensure proper system appearance adaptation
- [ ] Update `project.yml` for new color asset references

**Acceptance Criteria**:
- All design tokens accessible via `AppTheme`
- Colors automatically adapt to light/dark mode
- Compile-time safe color references

---

### 1.2 Shared UI Components Library
**Agent**: SwiftUI Expert  
**Priority**: Critical  
**Depends On**: Task 1.1  
**Files**: `Sources/UI/Components/`

**Tasks**:
- [ ] **GlassCard** view modifier
  - Glass background with blur effect
  - Border styling with theme tokens
  - Corner radius consistency
  - Light/dark theme variants
- [ ] **GoldGradientText** component
  - White-to-gold gradient fill
  - System font integration (SF Pro/Hebrew)
  - Accessibility contrast in light mode
- [ ] **PrimaryButton** component
  - Gold CTA styling
  - Haptic feedback integration
  - Disabled/pressed states
  - Spring animation on tap
- [ ] **SegmentedPicker** component
  - Custom styling matching design
  - Gold accent for selection
  - Glass background integration
- [ ] **ZmanRow** component
  - Glass card row layout
  - Gold time value display
  - Icon + label + time layout
  - Highlight state for next upcoming zman
- [ ] **SuggestedCard** component
  - Small quick-access glass card
  - Icon + title layout
  - Tap gesture handling
  - Badge overlay support
- [ ] **SeasonalBadge** component
  - Green-tinted background (#4ade80 on rgba(34,197,94,0.1))
  - Icon + text layout
  - Light/dark variants
- [ ] **HeroCard** component
  - Large prayer card with countdown
  - Multi-line layout: prayer name, milestone, countdown, context
  - Transitional state UI (both prayer options)
  - Gold border highlight
  - Automatic timer updates

**Acceptance Criteria**:
- All components work in light and dark themes
- Components support RTL layout
- Haptic feedback where specified
- Spring/fade animations implemented
- Components compile and preview correctly in isolation

---

## Phase 2: Home Tab Implementation

### 2.1 Data Models
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: None  
**Files**: `Sources/Models/`

**Tasks**:
- [ ] Create `NextPrayerState` model
  - Properties: prayer, currentMilestone, isTransitional, alternativePrayer
  - Equatable conformance for SwiftUI updates
- [ ] Create `PrayerMilestone` model
  - Properties: name, hebrewName, time, halachicDescription
  - Localization support
- [ ] Create `SuggestedItem` model
  - Properties: icon, title, prayerType, badgeText
- [ ] Create `SpecialZman` model (for Phase 3, but create now)
  - Properties: name, hebrewName, time, context

**Acceptance Criteria**:
- All models compile and are properly documented
- Models support Codable if needed for persistence
- Proper type safety for all properties

---

### 2.2 NextPrayerService Implementation
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Task 2.1  
**Files**: `Sources/Services/NextPrayerService.swift`

**Tasks**:
- [ ] Create `NextPrayerService` class
  - Dependency on `ZmanimService`
  - Timer management with milestone boundary firing (not every second)
  - Multi-stage milestone calculation (9 time windows from spec table)
  - `scenePhase` observation for background/foreground recalculation
  - Published `NextPrayerState` for SwiftUI binding
- [ ] Implement milestone logic for each time window:
  - Alot -> Netz: Shacharit, countdown to Netz
  - Netz -> Sof Zman Shma: Shacharit, countdown to Shma
  - Sof Zman Shma -> Sof Zman Tefila: Shacharit, countdown to Tefila
  - Sof Zman Tefila -> Chatzot: Shacharit, countdown to Chatzot
  - Chatzot -> Mincha Gedola: Waiting, countdown to Mincha Gedola
  - Mincha Gedola -> Shkia: Mincha, countdown to Shkia
  - Shkia -> Tzet: Transitional (both Mincha & Arvit), countdown to Tzet
  - Tzet -> Chatzot Layla: Arvit, countdown to Chatzot Layla
  - Chatzot Layla -> Alot: Arvit, countdown to Alot
- [ ] Add halachic context descriptions for each milestone (per spec table)
- [ ] Implement timer recalculation on milestone crossing
- [ ] Handle app lifecycle (background/foreground) correctly

**Acceptance Criteria**:
- Timer updates at milestone boundaries, not continuously
- Correct prayer shown for current time window
- Halachic context matches spec for each milestone
- No memory leaks from timer
- Handles timezone changes gracefully
- Works correctly after app backgrounding

---

### 2.3 Extended PrayerVisibilityService
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Task 2.1  
**Files**: `Sources/Services/PrayerVisibilityService.swift`

**Tasks**:
- [ ] Add `suggestedItems(for date:) -> [SuggestedItem]` method
  - Always include: Birkat HaMazon, Asher Yatzar
  - Omer count during Sefirah period
  - Havdala on Motzei Shabbat
  - Arvit quick-access during Shkia->Tzet window
  - Chanukah prayers during Chanukah
  - Other contextual blessings based on calendar

**Acceptance Criteria**:
- Returns relevant suggested items for any given date
- Correctly identifies seasonal/calendar-based items
- No duplicate items returned
- Items have proper icons and titles

---

### 2.4 Extended JewishCalendarService
**Agent**: SwiftUI Expert  
**Priority**: Medium  
**Depends On**: None  
**Files**: `Sources/Services/JewishCalendarService.swift`

**Tasks**:
- [ ] Add `seasonalBadge(for date:) -> String?` method
  - Chodesh Nisan: "Birkat Ha'Ilanot available"
  - Sefirat HaOmer: "Sefirat HaOmer tonight"
  - Chanukah: "Chanukah night [number]"
  - Other seasonal contexts per Jewish calendar month
  - Return nil if no special seasonal context

**Acceptance Criteria**:
- Returns appropriate seasonal badge text for special periods
- Returns nil for regular days
- Text is user-friendly and concise
- Works correctly with diaspora vs. Israel differences

---

### 2.5 HomeViewModel
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Tasks 2.2, 2.3, 2.4  
**Files**: `Sources/ViewModels/HomeViewModel.swift`

**Tasks**:
- [ ] Create `HomeViewModel` class (ObservableObject)
  - Inject dependencies: `NextPrayerService`, `PrayerVisibilityService`, `JewishCalendarService`, `AuthViewModel`, `ZmanimService`
  - Published properties for all Home screen data
  - Greeting text ("Shalom, [user name]")
  - Hebrew + Gregorian date
  - `NextPrayerState` from service
  - Suggested items
  - Seasonal badge text
  - Filtered prayer grid (dynamic based on today's relevance)
- [ ] Implement prayer grid filtering logic
  - Always shown: Shacharit, Mincha, Arvit, Birkat HaMazon, Kriat Shma Al HaMita, Birchot HaShachar
  - Conditionally: Hallel, Mussaf, Omer, Chanukah, Slichot, Tehillim
  - Hidden: prayers not applicable today
  - Highlight current/next prayer with gold border
- [ ] Handle lifecycle and timer updates

**Acceptance Criteria**:
- All Home screen data properly published
- Prayer grid dynamically filters based on date
- Correct prayer highlighted
- No unnecessary recomputations
- Memory efficient

---

### 2.6 NewHomeView UI
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: High  
**Depends On**: Tasks 1.2, 2.5  
**Files**: `Sources/Views/NewHomeView.swift`

**Tasks**:
- [ ] Create `NewHomeView` with ScrollView layout
- [ ] Greeting header section
  - "Shalom, [user name]" with GoldGradientText
  - Hebrew date + Gregorian date subtitle
- [ ] Hero card section
  - Use HeroCard component
  - Display NextPrayerState data
  - Multi-stage countdown timer
  - Halachic context subtitle
  - Transitional state UI (both prayer options)
  - Tap navigation to PrayerView
- [ ] Suggested For You section
  - SeasonalBadge if applicable
  - 2-column grid of SuggestedCards
  - Tap navigation to appropriate prayers/blessings
- [ ] All Prayers grid section
  - Section header: "All Prayers"
  - 2-column LazyVGrid
  - Filtered prayers from ViewModel
  - Gold border on current/next prayer
  - Tap navigation to PrayerView

---

## Backlog (TBD, Not Now)

- [ ] Daily Learning Integration (Sefaria API)
  - Fetch and display daily learning items (e.g., Daf Yomi / related tracks) from Sefaria API
  - Define caching/fallback strategy for offline mode
  - Add failure handling and rate-limit-safe refresh behavior
- [ ] Apply glass card styling throughout
- [ ] RTL layout verification
- [ ] Spring animations for state transitions

**Acceptance Criteria**:
- Matches `new_style.html` mockup aesthetically
- All interactive elements functional
- Smooth animations
- RTL layout correct
- Works in light and dark themes
- Dynamic Type support
- VoiceOver accessibility

---

## Phase 3: Unified Calendar/Zmanim Tab

### 3.1 Extended ZmanimService
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Task 2.1  
**Files**: `Sources/Services/ZmanimService.swift`

**Tasks**:
- [ ] Add `specialZmanim(for day:) -> [SpecialZman]` method
  - Erev Shabbat: candle lighting time
  - Motzei Shabbat: havdala time
  - Erev Yom Tov: candle lighting + yom tov name
  - Motzei Yom Tov: havdala
  - Chanukah: candle lighting (shkia/tzet per minhag) + night number
  - Regular fast days: fast begins (alot), fast ends (tzet)
  - Tisha B'Av: fast begins (previous shkia), fast ends
  - Erev Pesach: Sof Zman Achilat Chametz, Sof Zman Biur Chametz
  - Sefirat HaOmer: tonight's count (day + weeks)
  - Rosh Chodesh: molad time
  - Purim: megilla reading time (from tzet)
  - Erev Yom Kippur: Kol Nidrei time
  - Lag Ba'Omer: bonfire time (tzet)
  - All contexts from spec table in doc lines 116-134
- [ ] Handle diaspora vs. Israel differences
- [ ] Handle nidcheh (postponed) fast days

**Acceptance Criteria**:
- Returns all relevant special zmanim for any given day
- Correct times calculated based on location and opinions
- Diaspora/Israel differences handled
- Empty array for regular days with no special zmanim

---

### 3.2 UnifiedCalendarViewModel
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Task 3.1  
**Files**: `Sources/ViewModels/UnifiedCalendarViewModel.swift`

**Tasks**:
- [ ] Create `UnifiedCalendarViewModel` class (ObservableObject)
  - Inject dependencies: `JewishCalendarService`, `ZmanimService`, `LocationService`
  - Published properties:
    - `viewMode`: enum (day/month)
    - `dateDisplayMode`: enum (hebrew/gregorian)
    - `selectedDate`: Date
    - `currentMonthDays`: array of day data for grid
    - `selectedDayInfo`: day info card data
    - `essentialZmanim`: ~5-8 key times
    - `allZmanim`: full 16 zmanim
    - `specialZmanim`: from extended service
    - `showAllZmanim`: Bool toggle
  - Month navigation (previous/next)
  - Day navigation (previous/next for swipe)
  - Day type indicators (Shabbat, Yom Tov, Fast, Rosh Chodesh, Chol HaMoed)
  - Adaptive day info card data generation

**Acceptance Criteria**:
- Proper state management for all UI controls
- Efficient month/day data calculation
- Correct day type identification with colored dots
- Essential vs. all zmanim filtering
- Today highlighting

---

### 3.3 UnifiedCalendarView - Month View
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: High  
**Depends On**: Tasks 1.2, 3.2  
**Files**: `Sources/Views/UnifiedCalendarView.swift`

**Tasks**:
- [ ] Create `UnifiedCalendarView` with top controls
  - Day/Month SegmentedPicker
  - Hebrew/Gregorian SegmentedPicker
- [ ] Implement Month View mode
  - 7-column LazyVGrid in glass card
  - Day cells with primary date (large) + tiny secondary date
  - Colored dot indicators (purple=Shabbat, orange=Yom Tov, red=Fast, blue=Rosh Chodesh, green=Chol HaMoed)
  - Today: gold filled circle
  - Horizontal swipe gestures for month-to-month navigation
  - Small arrow buttons for month navigation
  - Day tap handler: updates selected day and shows inline day detail
- [ ] Inline day detail section (below grid)
  - Adaptive day info card
  - Essential zmanim list with ZmanRow components
  - "Show all zmanim" expandable button
  - Expanded: full 16 zmanim
  - Next upcoming zman highlighted
- [ ] Ensure no sheet overlays (inline only)

**Acceptance Criteria**:
- 7-column grid displays correctly
- Day cells show dual dates based on toggle
- Colored dots match day types
- Today highlighted in gold
- Swipe gestures work without conflicts
- Tap updates inline detail correctly
- Essential/all zmanim toggle works
- RTL layout correct

---

### 3.4 UnifiedCalendarView - Day View
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: High  
**Depends On**: Tasks 1.2, 3.2  
**Files**: `Sources/Views/UnifiedCalendarView.swift`

**Tasks**:
- [ ] Implement Day View mode
  - Single day info card (glass card)
  - Full adaptive day info card with all special zmanim
  - Essential zmanim list by default
  - "Show all zmanim" expandable button
  - Full 16 zmanim when expanded
  - Next upcoming zman highlighted
  - Horizontal swipe gestures to navigate between consecutive days
- [ ] Swipe gesture handling
  - Left swipe: next day
  - Right swipe: previous day
  - Update ViewModel selectedDate
  - Smooth transition animation

**Acceptance Criteria**:
- Day info card displays all relevant special zmanim
- Zmanim list functions identically to month view inline detail
- Swipe navigation works smoothly
- No conflicts with tab bar swipe
- Correct animations on day change
- RTL layout correct

---

### 3.5 Adaptive Day Info Card Logic
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Tasks 3.1, 3.2  
**Files**: `Sources/Views/Components/DayInfoCard.swift`

**Tasks**:
- [ ] Create `DayInfoCard` component
  - Always show: Hebrew date (primary), Gregorian date, Parsha (relevant week), Daf Yomi
  - Conditionally show special zmanim from `ZmanimService.specialZmanim()`
  - Layout: glass card with sections for each special zman type
  - Icons for each context type
  - Gold-colored time values
- [ ] Implement adaptive display logic from spec table (doc lines 116-134)

**Acceptance Criteria**:
- Displays all relevant info for any day
- Special zmanim only shown when applicable
- Layout is clean and readable
- RTL support
- Works in light and dark themes

---

## Phase 4: Tab Structure Migration

### 4.1 TabContainerView Restructure
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Tasks 2.6, 3.3, 3.4  
**Files**: `Sources/Views/TabContainerView.swift`

**Tasks**:
- [ ] Update `TabContainerView` from 4 tabs to 3 tabs
  - Tab 1: Home (NewHomeView)
  - Tab 2: Calendar/Zmanim (UnifiedCalendarView)
  - Tab 3: Settings (restyled in Phase 5)
- [ ] Remove old `PrayersMenuView` tab reference
- [ ] Style standard SwiftUI TabView
  - Glass background appearance
  - Gold accent tint color
- [ ] Tab icons (SF Symbols)
  - Home: house.fill
  - Calendar/Zmanim: calendar
  - Settings: gearshape.fill
- [ ] Implement spring/fade tab transition animations
- [ ] Add haptic feedback on tab switch

**Acceptance Criteria**:
- 3 tabs displayed correctly
- Tab bar has glass background styling
- Gold tint on selected tab
- Smooth transitions between tabs
- Haptic feedback works
- No visual glitches
- RTL layout correct

---

## Phase 5: Settings & Onboarding Restyle

### 5.1 Settings View Restyle
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: Medium  
**Depends On**: Task 1.2  
**Files**: `Sources/Views/SettingsView.swift` + all settings sub-views

**Tasks**:
- [ ] Restyle main `SettingsView`
  - Replace grouped List with glass card sections
  - Apply dark/gold theme
  - Gold accent for toggles, pickers, selected states
- [ ] Restyle all settings sub-views:
  - Identity settings
  - Location settings
  - Zmanim Opinions settings
  - Appearance settings
  - Display settings
  - Privacy settings
  - Account settings
- [ ] Maintain all existing functionality (no behavior changes)
- [ ] Apply GlassCard styling
- [ ] Use gold accent colors throughout
- [ ] Add haptic feedback on toggle changes

**Acceptance Criteria**:
- All settings screens match new design aesthetic
- No functionality broken
- Glass card sections instead of List rows
- Gold accents consistent
- Light and dark themes both work
- RTL layout correct
- Haptic feedback on interactions

---

### 5.2 Onboarding/Login Redesign
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: Medium  
**Depends On**: Task 1.2  
**Files**: `Sources/Views/LoginView.swift`, `Sources/Views/OnboardingView.swift`

**Tasks**:
- [ ] Restyle `LoginView`
  - Replace current blue gradient with dark/gold theme
  - Apply glass card styling for auth option buttons
  - Gold gradient app title/logo
  - Same auth options: Apple Sign-In, Google Sign-In, Anonymous
- [ ] Restyle `OnboardingView` if separate
  - Dark/gold theme matching login
  - Glass cards for onboarding steps
- [ ] Maintain all existing auth flow functionality
- [ ] Add spring animations for button interactions
- [ ] Add haptic feedback on button taps

**Acceptance Criteria**:
- Login screen matches new app identity
- All auth methods still functional
- Dark/gold aesthetic consistent with app
- Smooth animations
- Haptic feedback works
- Light theme variant if user preference set before login
- Accessibility maintained

---

## Phase 6: Polish & QA

### 6.1 Animation Refinement
**Agent**: SwiftUI Expert  
**Priority**: Low  
**Depends On**: All previous phases  
**Files**: All view files

**Tasks**:
- [ ] Audit all animations for consistency
  - Spring animations for state transitions
  - Fade animations for page/tab switches
  - Card appearance animations
  - Countdown timer smooth updates (not every second)
- [ ] Tune animation durations and spring parameters
- [ ] Ensure no janky or abrupt transitions
- [ ] Test animation performance on older devices

**Acceptance Criteria**:
- All animations feel smooth and premium
- Consistent animation language throughout app
- No performance issues on target devices (iPhone XR and newer)
- Countdown updates are smooth without excessive redraws

---

### 6.2 Light Theme QA
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: Medium  
**Depends On**: All previous phases  
**Files**: All view and theme files

**Tasks**:
- [ ] Comprehensive light theme testing across all screens
  - Home tab
  - Calendar/Zmanim tab (both modes)
  - Settings (all sub-screens)
  - Onboarding/Login
- [ ] Verify light theme color tokens
  - Warm cream background (#faf8f5) doesn't look washed out
  - Darker gold (#b8941e) has sufficient contrast
  - Card shadows vs. borders appropriate
- [ ] Adjust any colors that don't maintain premium feel
- [ ] Test in bright sunlight conditions (if possible via simulator brightness)

**Acceptance Criteria**:
- Light theme looks premium, not washed out
- All text has sufficient contrast (WCAG AA minimum)
- Gold accents visible and attractive
- Glass effects translate appropriately
- No visual glitches or misaligned elements

---

### 6.3 RTL Layout Verification
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: High  
**Depends On**: All previous phases  
**Files**: All view files

**Tasks**:
- [ ] Thorough RTL testing on all screens
  - Home tab (grids, cards, hero card)
  - Calendar/Zmanim (month grid, day view, swipes)
  - Settings (all sub-screens)
  - Onboarding/Login
- [ ] Verify all glass cards mirror correctly
- [ ] Verify all grids (2-column, 7-column) mirror correctly
- [ ] Verify swipe gestures work correctly in RTL
  - Day navigation (right swipe should go to next day, not previous)
  - Month navigation
- [ ] Test with Hebrew language setting and RTL locale

**Acceptance Criteria**:
- All layouts mirror correctly for RTL
- No overlapping or misaligned elements
- Swipe gestures feel natural in RTL context
- Text alignment correct (Hebrew right-aligned)
- Icons and badges positioned correctly
- No hardcoded LTR assumptions

---

### 6.4 Accessibility Audit
**Agent**: SwiftUI Expert + iOS Design  
**Priority**: High  
**Depends On**: All previous phases  
**Files**: All view files

**Tasks**:
- [ ] VoiceOver testing on all screens
  - All interactive elements have labels
  - Navigation makes sense with VoiceOver
  - Hero card countdown announced appropriately
  - Calendar grid navigable with VoiceOver
  - Zmanim times announced correctly
- [ ] Dynamic Type testing
  - All text scales appropriately
  - Layouts don't break at largest sizes
  - Minimum touch target sizes maintained (44x44pt)
- [ ] Color contrast testing
  - Gold text on glass backgrounds meets WCAG AA
  - Light theme contrast verified
  - Secondary text readable
- [ ] Add accessibility labels/hints where missing
- [ ] Test with Reduce Motion enabled
  - Fallback to simple transitions if animations cause issues

**Acceptance Criteria**:
- VoiceOver fully functional on all screens
- Dynamic Type works at all sizes without breaking layout
- All contrast ratios meet WCAG AA (AAA preferred)
- Reduce Motion respected
- No accessibility warnings in Xcode

---

## Cross-Cutting Concerns

### Risk Mitigation Tasks

#### Countdown Timer Risk
**Agent**: SwiftUI Expert  
**Priority**: Critical  
**Depends On**: Task 2.2  
**Tasks**:
- [ ] Implement robust scenePhase handling
  - Recalculate on .active transition
  - Cancel timers on .background transition
- [ ] Implement timer that fires at milestone boundaries only
  - Not every second to save battery
  - Schedule next firing at next milestone time
- [ ] Add unit tests for timer logic
- [ ] Test backgrounding/foregrounding scenarios
- [ ] Test timezone change handling
- [ ] Test date rollover at midnight

#### Dynamic Prayer Grid Testing
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Task 2.5  
**Tasks**:
- [ ] Comprehensive test coverage for prayer filtering logic
  - Regular weekdays
  - Shabbat
  - Rosh Chodesh
  - Yom Tov (single and double days)
  - Fast days
  - Chanukah (all 8 nights)
  - Sefirat HaOmer period
  - Elul and Aseret Yemei Teshuva (Slichot)
  - Special Shabbatot (Shekalim, Zachor, Parah, HaChodesh)
- [ ] Diaspora vs. Israel differences testing
- [ ] Edge case testing (nidcheh fast days, etc.)

#### Swipe Navigation Conflict Prevention
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Tasks 3.3, 3.4, 4.1  
**Tasks**:
- [ ] Implement gesture priority system
  - Day view swipe should not trigger tab change
  - Month view swipe should not trigger tab change
  - Proper gesture delegation
- [ ] Test on device (not just simulator)
- [ ] Ensure smooth gesture feel without interference

#### Special Zmanim Coverage
**Agent**: SwiftUI Expert  
**Priority**: High  
**Depends On**: Task 3.1  
**Tasks**:
- [ ] Comprehensive test suite for all Jewish calendar edge cases
  - Diaspora double days
  - Nidcheh fast days
  - Yom Tov falling on Shabbat
  - Two-day Yom Tov in diaspora
  - Purim/Shushan Purim
  - Erev Pesach on Shabbat (special chametz times)
- [ ] Verify against established luach for accuracy

---

## Testing & Documentation

### Integration Testing
**Agent**: SwiftUI Expert  
**Priority**: Medium  
**Depends On**: All implementation phases

**Tasks**:
- [ ] Write integration tests for critical user flows
  - Home tab displays correct next prayer at different times of day
  - Countdown updates correctly at milestone crossings
  - Calendar day selection updates zmanim display
  - Special zmanim appear on appropriate days
- [ ] Test app on physical devices (various models)
  - iPhone 12/13 (notch)
  - iPhone 14/15 (Dynamic Island)
  - iPhone SE (smaller screen)
  - iPad (if supported)

### Documentation
**Agent**: General  
**Priority**: Low  
**Depends On**: All implementation phases

**Tasks**:
- [ ] Document new services and their APIs
  - `NextPrayerService` usage
  - Extended service methods
- [ ] Document new UI components
  - Component parameters and usage examples
  - Theme token usage guidelines
- [ ] Update README if needed with new screenshots
- [ ] Create component library showcase (if desired)

---

## Notes

- **Total Estimated Tasks**: ~60+ discrete implementation tasks
- **Critical Path**: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6
- **Parallelizable**: Within each phase, many tasks can be done in parallel after dependencies are met
- **Risk Areas**: Noted throughout with specific mitigation tasks
- **No Backend Changes**: All data sources already exist; purely frontend redesign

---

## Agent Assignment Summary

- **SwiftUI Expert**: Primary agent for all implementation tasks (design system, services, view models, views, components)
- **iOS Design**: Co-agent for UI-heavy tasks (Home view, Calendar view, Settings restyle, accessibility audit)
- **General**: Documentation and non-specialized tasks

---

## Progress Tracking

Update this section as phases complete:

- [ ] Phase 1: Design System Foundation
- [ ] Phase 2: Home Tab Implementation
- [ ] Phase 3: Unified Calendar/Zmanim Tab
- [ ] Phase 4: Tab Structure Migration
- [ ] Phase 5: Settings & Onboarding Restyle
- [ ] Phase 6: Polish & QA
