---
version: alpha
name: Smart Siddur iOS
description: A warm, traditional, devotional iOS system built around adaptive near-white or charcoal backgrounds, restrained teal accents, select gold outlines, solid cards, and native Apple typography.
colors:
  primary: "#009688"
  on-primary: "#000000D9"
  primary-container: "#B2DFDB"
  primary-outline: "#D9BA4599"
  background: "#FFFBFE"
  background-end: "#FFFFFF"
  surface: "#FFFFFF"
  on-surface: "#1A1A2E"
  on-surface-variant: "#49454F"
  outline: "#00000014"
  success: "#4AC480"
  success-container: "#4AC48026"
  error: "#B3261E"
  warning: "#FF9500"
  calendar-shabbat: "#AF52DE"
  calendar-rosh-chodesh: "#007AFF"
  calendar-chol-hamoed: "#34C759"
  auth-provider-surface: "#1C2133"
  auth-provider-outline: "#33384F"
  scrim: "#0000004D"
typography:
  large-title-bold: { fontFamily: SF Pro, fontSize: 34px, fontWeight: 700 }
  title2: { fontFamily: SF Pro, fontSize: 22px, fontWeight: 400 }
  title2-bold: { fontFamily: SF Pro, fontSize: 22px, fontWeight: 700 }
  title2-rounded-bold: { fontFamily: SF Pro Rounded, fontSize: 22px, fontWeight: 700 }
  title3-semibold: { fontFamily: SF Pro, fontSize: 20px, fontWeight: 600 }
  prayer-reading: { fontFamily: SF Pro, fontSize: 20px, fontWeight: 400 }
  prayer-reading-bold: { fontFamily: SF Pro, fontSize: 20px, fontWeight: 700 }
  headline: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 600 }
  body: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 400 }
  body-medium: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 500 }
  body-bold: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 700 }
  body-rounded: { fontFamily: SF Pro Rounded, fontSize: 17px, fontWeight: 400 }
  body-rounded-bold: { fontFamily: SF Pro Rounded, fontSize: 17px, fontWeight: 700 }
  label-medium: { fontFamily: SF Pro, fontSize: 16px, fontWeight: 500 }
  label-semibold: { fontFamily: SF Pro, fontSize: 16px, fontWeight: 600 }
  subheadline: { fontFamily: SF Pro, fontSize: 15px, fontWeight: 400 }
  subheadline-semibold: { fontFamily: SF Pro, fontSize: 15px, fontWeight: 600 }
  caption: { fontFamily: SF Pro, fontSize: 12px, fontWeight: 400 }
  caption-semibold: { fontFamily: SF Pro, fontSize: 12px, fontWeight: 600 }
  caption-rounded-bold: { fontFamily: SF Pro Rounded, fontSize: 12px, fontWeight: 700 }
  caption2-semibold: { fontFamily: SF Pro, fontSize: 11px, fontWeight: 600 }
  caption2-bold: { fontFamily: SF Pro, fontSize: 11px, fontWeight: 700 }
  calendar-micro: { fontFamily: SF Pro, fontSize: 9px, fontWeight: 400 }
rounded:
  small: 8
  control: 12
  tile: 14
  card: 18
  full: 9999
spacing:
  micro: 2
  badge-compact: 3
  tight: 4
  compact: 6
  small: 8
  pill-vertical: 9
  grid: 10
  standard: 12
  card-compact: 14
  content: 16
  section: 18
  large: 24
  calendar-bottom: 28
  screen-bottom: 30
  auth-gutter: 32
components:
  hero-card: { backgroundColor: "{colors.surface}", textColor: "{colors.on-surface}", typography: "{typography.headline}", rounded: "{rounded.card}", padding: 16 }
  prayer-grid-card: { backgroundColor: "{colors.surface}", textColor: "{colors.on-surface}", typography: "{typography.subheadline-semibold}", rounded: "{rounded.tile}", padding: 12, height: 112 }
  seasonal-badge: { backgroundColor: "{colors.success-container}", textColor: "{colors.success}", typography: "{typography.subheadline-semibold}", rounded: "{rounded.control}", padding: 8 }
  primary-action-pill: { backgroundColor: "{colors.primary}", textColor: "{colors.on-primary}", typography: "{typography.subheadline-semibold}", rounded: "{rounded.full}", padding: 12 }
  auth-provider-button: { backgroundColor: "{colors.auth-provider-surface}", textColor: "{colors.surface}", typography: "{typography.body-medium}", rounded: "{rounded.control}", height: 50 }
  calendar-navigation-button: { backgroundColor: "{colors.surface}", textColor: "{colors.on-surface}", typography: "{typography.headline}", rounded: "{rounded.full}", size: 34 }
  calendar-day-selection: { backgroundColor: "{colors.primary}", textColor: "{colors.surface}", typography: "{typography.body-rounded-bold}", rounded: "{rounded.full}", size: 40 }
  calendar-zman-row: { backgroundColor: "{colors.surface}", textColor: "{colors.on-surface}", typography: "{typography.subheadline}", rounded: "{rounded.control}", padding: 12 }
  settings-row: { backgroundColor: "{colors.surface}", textColor: "{colors.on-surface}", typography: "{typography.body}", height: 46 }
  prayer-reading-section: { backgroundColor: "{colors.surface}", textColor: "{colors.on-surface}", typography: "{typography.prayer-reading}", rounded: "{rounded.small}", padding: 8 }
x-stag:
  schema: 1
  platform: ios
  peer: ../SmartSiddur/DESIGN.md
  facts:
    ui_framework: { primary: swiftui }
    deployment_target: "17.0"
    token_source: code
    generated: false
    accessor: null
    dark_mode:
      status: system
      mechanism: "SwiftUI colorScheme branches plus adaptive system colors"
      evidence:
        - Sources/Features/Home/NewHomeView.swift
        - Sources/Features/Calendar/CalendarView.swift
        - Sources/Features/Settings/SettingsView.swift
        - Sources/UI/Theme/AppTheme.swift
    spacing_scale: none
    swiftui_view_files: 24
    uikit_only_files: 2
    color_literal_occurrences: 50
    adaptive_color_files: 10
    liquid_glass: false
    dynamic_color: true
    migration: "The semantic palette is canonical; remaining native list and reading surfaces still need the surface, teal, and gold-outline system."
    trap: "Do not use the ShapeStyle theme accessors: they name color assets that are not present, and the active screens do not use them."
    confirmed:
      overall_vibe: "Warmer, more traditional and devotional"
      default_appearance: "Follow the iPhone setting"
      canonical_visual_source: "DESIGN.md semantic tokens for color; active redesigned screens for layout and component treatment"
      secondary_screen_style: "Extend the surface, teal, and gold-outline system across every screen"
      typography_preferences: "Apple system font for interface text; user-selectable font and size only for prayer reading"
  themes:
    default: light
    selection: system
    list:
      - { id: light, kind: appearance }
      - { id: dark, kind: appearance }
  values:
    colors.primary: { dark: "#009688" }
    colors.on-primary: { dark: "#000000D9" }
    colors.primary-container: { dark: "#00796B" }
    colors.primary-outline: { dark: "#D9BA4599" }
    colors.background: { dark: "#121212" }
    colors.background-end: { dark: "#03050A" }
    colors.surface: { dark: "#1E1E1E" }
    colors.on-surface: { dark: "#FFFFFF" }
    colors.on-surface-variant: { dark: "#CACACA" }
    colors.outline: { dark: "#FFFFFF1F" }
    colors.success: { dark: "#4AC480" }
    colors.success-container: { dark: "#4AC48026" }
    colors.error: { dark: "#F2B8B5" }
    colors.warning: { dark: "#FF9F0A" }
    colors.calendar-shabbat: { dark: "#BF5AF2" }
    colors.calendar-rosh-chodesh: { dark: "#0A84FF" }
    colors.calendar-chol-hamoed: { dark: "#30D158" }
    colors.auth-provider-surface: { dark: "#1C2133" }
    colors.auth-provider-outline: { dark: "#33384F" }
    colors.scrim: { dark: "#0000004D" }
  bindings:
    colors.primary: { native: "Color(red: 0.0, green: 0.5882352941, blue: 0.5333333333)", source: "Sources/Features/Home/NewHomeView.swift#gold" }
    colors.on-primary: { native: "Color.black.opacity(0.85)", source: "Sources/Features/Home/NewHomeView.swift#heroButton" }
    colors.primary-container: { native: "colorScheme == .dark ? Color(red: 0.0, green: 0.4745098039, blue: 0.4196078431) : Color(red: 0.6980392157, green: 0.8745098039, blue: 0.8588235294)", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    colors.primary-outline: { native: "gold.opacity(0.6)", source: "Sources/Features/Home/NewHomeView.swift#heroCard" }
    colors.background: { native: "colorScheme == .dark ? Color(red: 0.0705882353, green: 0.0705882353, blue: 0.0705882353) : Color(red: 1.0, green: 0.9843137255, blue: 0.9960784314)", source: "Sources/Features/Home/NewHomeView.swift#backgroundGradient" }
    colors.background-end: { native: "Color.white", source: "Sources/Features/Home/NewHomeView.swift#backgroundGradient" }
    colors.surface: { native: "colorScheme == .dark ? Color(red: 0.1176470588, green: 0.1176470588, blue: 0.1176470588) : Color.white", source: "Sources/Features/Home/NewHomeView.swift#cardFill" }
    colors.on-surface: { native: "colorScheme == .dark ? .white : Color(red: 0.10, green: 0.10, blue: 0.18)", source: "Sources/Features/Home/NewHomeView.swift#primaryText" }
    colors.on-surface-variant: { native: "colorScheme == .dark ? Color(red: 0.7921568627, green: 0.7921568627, blue: 0.7921568627) : Color(red: 0.2862745098, green: 0.2705882353, blue: 0.3098039216)", source: "Sources/Features/Home/NewHomeView.swift#secondaryText" }
    colors.outline: { native: "colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)", source: "Sources/Features/Home/NewHomeView.swift#borderColor" }
    colors.success: { native: "Color(red: 0.29, green: 0.77, blue: 0.50)", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    colors.success-container: { native: "Color(red: 0.29, green: 0.77, blue: 0.50).opacity(0.15)", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    colors.error: { native: "colorScheme == .dark ? Color(red: 0.9490196078, green: 0.7215686275, blue: 0.7098039216) : Color(red: 0.7019607843, green: 0.1490196078, blue: 0.1176470588)", source: "Sources/Features/Calendar/CalendarGridView.swift#dayTextColor" }
    colors.warning: { native: "Color.orange", source: "Sources/Features/Calendar/CalendarGridView.swift#dayTextColor" }
    colors.calendar-shabbat: { native: "Color.purple", source: "Sources/Features/Calendar/CalendarGridView.swift#dayTextColor" }
    colors.calendar-rosh-chodesh: { native: "Color.blue", source: "Sources/Features/Calendar/CalendarGridView.swift#dayTextColor" }
    colors.calendar-chol-hamoed: { native: "Color.green", source: "Sources/Features/Calendar/CalendarGridView.swift#dayTextColor" }
    colors.auth-provider-surface: { native: "Color(red: 0.11, green: 0.13, blue: 0.20)", source: "Sources/Features/Auth/LoginView.swift#Google button" }
    colors.auth-provider-outline: { native: "Color(red: 0.20, green: 0.22, blue: 0.31)", source: "Sources/Features/Auth/LoginView.swift#Google button" }
    colors.scrim: { native: "Color.black.opacity(0.3)", source: "Sources/Features/Auth/LoginView.swift#loading overlay" }
    typography.large-title-bold: { native: ".font(.largeTitle.weight(.bold))", source: "Sources/Features/Home/NewHomeView.swift#greetingHeader" }
    typography.title2: { native: ".font(.title2)", source: "Sources/Features/Auth/LoginView.swift#Google icon" }
    typography.title2-bold: { native: ".font(.title2.bold())", source: "Sources/Features/Calendar/DayDetailSheet.swift#header" }
    typography.title2-rounded-bold: { native: ".font(.system(.title2, design: .rounded).weight(.bold))", source: "Sources/Features/Home/NewHomeView.swift#heroCard" }
    typography.title3-semibold: { native: ".font(.title3.weight(.semibold))", source: "Sources/Features/Home/NewHomeView.swift#heroCard" }
    typography.prayer-reading: { native: ".system(size: 20)", source: "Sources/Extensions/AttributedString+HTML.swift#createAttributedString" }
    typography.prayer-reading-bold: { native: ".system(size: 20, weight: .bold)", source: "Sources/Extensions/AttributedString+HTML.swift#createAttributedString" }
    typography.headline: { native: ".font(.headline)", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    typography.body: { native: ".font(.body)", source: "Sources/Features/Zmanim/ZmanRowView.swift" }
    typography.body-medium: { native: ".font(.body.weight(.medium))", source: "Sources/Features/Auth/LoginView.swift#Google button" }
    typography.body-bold: { native: ".font(.body.bold())", source: "Sources/Features/Calendar/DayDetailSheet.swift" }
    typography.body-rounded: { native: ".font(.system(.body, design: .rounded, weight: .regular))", source: "Sources/Features/Calendar/CalendarGridView.swift#CalendarDayCell" }
    typography.body-rounded-bold: { native: ".font(.system(.body, design: .rounded, weight: .bold))", source: "Sources/Features/Calendar/CalendarGridView.swift#CalendarDayCell" }
    typography.label-medium: { native: ".font(.system(size: 16, weight: .medium))", source: "Sources/Features/Prayers/PrayerTextView.swift#TableOfContentsView" }
    typography.label-semibold: { native: ".font(.system(size: 16, weight: .semibold))", source: "Sources/Features/Prayers/PrayersMenuView.swift#SectionHeader" }
    typography.subheadline: { native: ".font(.subheadline)", source: "Sources/Features/Home/NewHomeView.swift#greetingHeader" }
    typography.subheadline-semibold: { native: ".font(.subheadline.weight(.semibold))", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    typography.caption: { native: ".font(.caption)", source: "Sources/Features/Calendar/DayDetailSheet.swift" }
    typography.caption-semibold: { native: ".font(.caption.weight(.semibold))", source: "Sources/Features/Calendar/CalendarView.swift#header" }
    typography.caption-rounded-bold: { native: ".font(.system(.caption, design: .rounded).weight(.bold))", source: "Sources/Features/Home/NewHomeView.swift#heroCard" }
    typography.caption2-semibold: { native: ".font(.caption2.weight(.semibold))", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    typography.caption2-bold: { native: ".font(.caption2.bold())", source: "Sources/Features/Calendar/CalendarGridView.swift" }
    typography.calendar-micro: { native: ".font(.system(size: 9))", source: "Sources/Features/Calendar/CalendarGridView.swift#CalendarDayCell" }
    rounded.small: { native: "RoundedRectangle(cornerRadius: 8)", source: "Sources/Features/Prayers/PrayerTextView.swift#prayerSectionView" }
    rounded.control: { native: ".rect(cornerRadius: 12)", source: "Sources/Features/Calendar/CalendarView.swift#zmanimSection" }
    rounded.tile: { native: ".rect(cornerRadius: 14)", source: "Sources/Features/Home/NewHomeView.swift#prayersSection" }
    rounded.card: { native: ".rect(cornerRadius: 18)", source: "Sources/Features/Home/NewHomeView.swift#heroCard" }
    rounded.full: { native: ".capsule or .circle", source: "Sources/Features/Home/NewHomeView.swift#heroButton" }
    spacing.micro: { native: "spacing: 2", source: "Sources/Features/Calendar/CalendarGridView.swift#CalendarDayCell" }
    spacing.badge-compact: { native: ".padding(.vertical, 3)", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    spacing.tight: { native: "spacing: 4", source: "Sources/Features/Calendar/CalendarView.swift#header" }
    spacing.compact: { native: "spacing: 6", source: "Sources/Features/Home/NewHomeView.swift#greetingHeader" }
    spacing.small: { native: "spacing: 8", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    spacing.pill-vertical: { native: ".padding(.vertical, 9)", source: "Sources/Features/Home/NewHomeView.swift#heroButton" }
    spacing.grid: { native: "spacing: 10", source: "Sources/Features/Home/NewHomeView.swift#prayersSection" }
    spacing.standard: { native: "spacing: 12", source: "Sources/Features/Home/NewHomeView.swift#heroCard" }
    spacing.card-compact: { native: ".padding(14)", source: "Sources/Features/Calendar/CalendarView.swift#datesCard" }
    spacing.content: { native: ".padding(.horizontal, 16)", source: "Sources/Features/Home/NewHomeView.swift" }
    spacing.section: { native: "spacing: 18", source: "Sources/Features/Home/NewHomeView.swift" }
    spacing.large: { native: "spacing: 24", source: "Sources/Features/Home/HomeView.swift" }
    spacing.calendar-bottom: { native: ".padding(.bottom, 28)", source: "Sources/Features/Calendar/CalendarView.swift" }
    spacing.screen-bottom: { native: ".padding(.bottom, 30)", source: "Sources/Features/Home/NewHomeView.swift" }
    spacing.auth-gutter: { native: ".padding(.horizontal, 32)", source: "Sources/Features/Auth/LoginView.swift" }
  fonts:
    - { family: SF Pro, files: [], registered_via: system, preview: system, used_by: "interface and prayer reading default" }
    - { family: SF Pro Rounded, files: [], registered_via: system, preview: system, used_by: "countdowns and calendar dates" }
    - { family: SF Hebrew, files: [], registered_via: system fallback, preview: system, used_by: "Hebrew interface and prayer text" }
  examples:
    - { screen: Home, path: Sources/Features/Home/NewHomeView.swift, shows: [adaptive gradient, gold hero card, seasonal badge, two-column prayer cards] }
    - { screen: Calendar and zmanim, path: Sources/Features/Calendar/CalendarView.swift, shows: [adaptive cards, segmented controls, navigation buttons, highlighted zman row] }
    - { screen: Calendar grid, path: Sources/Features/Calendar/CalendarGridView.swift, shows: [40-point day selection, event colors, rounded date typography] }
    - { screen: Settings, path: Sources/Features/Settings/SettingsView.swift, shows: [teal tint, adaptive background, 46-point rows] }
    - { screen: Sign in, path: Sources/Features/Auth/LoginView.swift, shows: [charcoal gradient, teal identity, 50-point provider buttons, loading scrim] }
    - { screen: Prayer reading, path: Sources/Features/Prayers/PrayerTextView.swift, shows: [right-to-left reading, 20-point prayer text, section cards, reading states] }
  known_off_system:
    - { id: duplicated-rgb-colors, pattern: "Color(red:green:blue:) outside semantic accessors", count: 49, replacement: "colors semantic tokens" }
    - { id: raw-fixed-typography, pattern: ".font(.system(size:))", count: 18, replacement: "typography roles; keep user sizing inside prayer reading only" }
    - { id: raw-corner-radii, pattern: "cornerRadius or RoundedRectangle numeric literals", count: 26, replacement: "rounded tokens" }
    - { id: legacy-system-surfaces, pattern: "Color(.systemBackground), Color(.secondarySystemGroupedBackground), Color(.systemGray6), or Color(.separator)", count: 7, replacement: "adaptive background, surface, and outline tokens" }
    - { id: native-list-surfaces, pattern: "standard SwiftUI List surfaces", count: 8, replacement: "surface, teal, and gold-outline sections and rows" }
    - { id: missing-color-assets, pattern: "Color(\"BgCard\"), Color(\"BorderCard\"), Color(\"AccentGold\"), Color(\"TextPrimary\"), Color(\"TextSecondary\"), Color(\"BadgeGreen\")", count: 6, replacement: "code-backed semantic tokens until real assets exist" }
    - { id: forced-dark-login, pattern: "LoginView always uses the dark charcoal gradient", count: 1, replacement: "system-following adaptive background tokens" }
    - { id: prayer-html-colors, pattern: "arbitrary font color values parsed from prayer HTML", count: 1, replacement: "semantic prayer-content color roles" }
  sizes:
    - { kind: button, name: auth-provider-button, height: 50, radius: 12 }
    - { kind: button, name: calendar-navigation-button, width: 34, height: 34, radius: 9999 }
    - { kind: pill, name: hero-prayer-action, radius: 9999, inset: 12 }
    - { kind: other, name: prayer-grid-card, height: 112, radius: 14 }
    - { kind: other, name: calendar-cell, height: 56 }
    - { kind: other, name: calendar-day-selection, width: 40, height: 40, radius: 9999, thickness: 1.3 }
    - { kind: icon, name: calendar-event-dot, width: 5, height: 5, radius: 9999 }
    - { kind: icon, name: login-mark, width: 72, height: 72 }
    - { kind: icon, name: notification-empty-state, width: 80, height: 80 }
    - { kind: bar, name: settings-row, height: 46 }
    - { kind: margin, name: screen-gutter, inset: 16 }
    - { kind: margin, name: auth-gutter, inset: 32 }
    - { kind: divider, name: legacy-card-outline, thickness: 0.5 }
  roles:
    primary: accent
    on-primary: text
    primary-container: surface
    primary-outline: border
    background: background
    background-end: background
    surface: surface
    on-surface: text
    on-surface-variant: textSecondary
    outline: border
    success: other
    success-container: surface
    error: error
    warning: other
    calendar-shabbat: other
    calendar-rosh-chodesh: other
    calendar-chol-hamoed: other
    auth-provider-surface: surface
    auth-provider-outline: border
    scrim: scrim
  usage:
    primary: Teal emphasis, selected states, times, and calls to prayer.
    on-primary: Text placed directly on solid teal actions.
    primary-container: Low-emphasis teal selection and badge fill.
    primary-outline: Strong gold card outline.
    background: First stop of the full-screen adaptive background.
    background-end: Second stop of the full-screen adaptive background.
    surface: Cards and rows above the background.
    on-surface: Primary interface and reading text.
    on-surface-variant: Dates, explanations, and supporting labels.
    outline: Default card and row border.
    success: Seasonal and currently available devotional context.
    success-container: Seasonal badge fill.
    error: Fast-day and error emphasis.
    warning: Yom Tov and warning emphasis.
    calendar-shabbat: Shabbat date and marker emphasis.
    calendar-rosh-chodesh: Rosh Chodesh date and marker emphasis.
    calendar-chol-hamoed: Chol HaMoed date and marker emphasis.
    auth-provider-surface: Dark third-party sign-in button.
    auth-provider-outline: Third-party sign-in button border.
    scrim: Loading overlay behind progress indicators.
  gaps:
    - The appearance picker stores System, Light, or Dark but no screen reads that preference; the current product follows the iPhone appearance.
    - The font family and size controls affect only their preview; prayer reading still renders with a fixed 20-point system font.
    - No custom font files are bundled, so the Frank Ruehl and David choices cannot be verified from this repository.
    - The active screens duplicate palette values instead of using one canonical accessor.
    - Six ShapeStyle accessors refer to color assets that do not exist and are not used by the screens.
    - The semantic primary color is #009688, while active screens render Color(red: 0.85, green: 0.73, blue: 0.27); the design token is canonical.
    - The approved redesign specifies a 28-point hero radius, while the active Home hero uses 18 points; the active screen size is canonical.
    - The semantic light background is #FFFBFE, while the active screens use Color(red: 0.98, green: 0.97, blue: 0.96); the design token is canonical.
    - The on-surface-variant token differs from the active Home and Calendar secondary text; the design token is canonical.
    - The shared backgroundPrimaryAdaptive function always returns the dark gradient and is not used by the adaptive screens.
    - Eight native List surfaces and the prayer reader have not yet adopted the confirmed surface, teal, and gold-outline treatment.
    - Login remains dark in both appearances even though the confirmed default is to follow the iPhone.
    - The shared component directory contains no implemented visual components; active screens currently define their cards inline.
    - Fixed custom font sizes do not opt into Dynamic Type scaling relative to a semantic text style.
    - Prayer HTML can introduce arbitrary named or hexadecimal colors outside the semantic palette.
    - The redesign document proposes future Culmus prayer fonts, while Settings currently lists Frank Ruehl, David, Arial, and Times New Roman.
    - Typography has 23 roles because the screens use distinct semantic, fixed-size, and rounded styles.
  deviations:
    rev: 2
    peer_rev_seen: 2
    items:
      - id: dv-bar-size
        subject: bar-size
        kind: component
        this: height 46 (settings-row)
        peer: height 48 (navigation-row)
        status: intentional
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: likely_intentional
      - id: dv-card-radius
        subject: card-radius
        kind: token
        this: 18 (card)
        peer: 16 (card)
        status: intentional
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: likely_accidental
      - id: dv-dark-mode
        subject: dark-mode
        kind: behavior
        this: follows the system setting
        peer: "follows the system, and people can pick"
        status: intentional
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: open
      - id: dv-divider
        subject: divider
        kind: component
        this: thickness 0.5 (legacy-card-outline)
        peer: "height 1, thickness 1 (legacy-divider)"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: open
      - id: dv-font-family
        subject: font-family
        kind: token
        this: "SF Hebrew, SF Pro, SF Pro Rounded"
        peer: "Alef, FontAwesome, Keter YG, Roboto, Shofar, Taamey Frank CLM"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: likely_accidental
      - id: dv-margin
        subject: margin
        kind: component
        this: inset 16 (screen-gutter)
        peer: width 16 (screen-margin)
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: open
      - id: dv-on-primary-color
        subject: on-primary-color
        kind: token
        this: "#000000D9 (on-primary), dark #000000D9"
        peer: "#FFFFFF (on-primary), dark #FFFFFF"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: likely_accidental
      - id: dv-on-surface-color
        subject: on-surface-color
        kind: token
        this: "#1A1A2E (on-surface), dark #FFFFFF"
        peer: "#1C1B1F (on-surface), dark #FFFFFF"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: likely_accidental
      - id: dv-other-size
        subject: other-size
        kind: component
        this: height 56 (calendar-cell)
        peer: "width 40, height 40, radius 9999 (calendar-date-cell)"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: open
      - id: dv-outline-color
        subject: outline-color
        kind: token
        this: "#00000014 (outline), dark #FFFFFF1F"
        peer: "#79747E (outline)"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: likely_accidental
      - id: dv-scrim-color
        subject: scrim-color
        kind: token
        this: "#0000004D (scrim), dark #0000004D"
        peer: "#00000060 (scrim)"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: likely_accidental
      - id: dv-theme-choice
        subject: theme-choice
        kind: behavior
        this: follows the system
        peer: "follows the system, and people can pick"
        status: intentional
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: open
      - id: dv-type-scale
        subject: type-scale
        kind: token
        this: "23 roles, 9 to 34 pt, SF Pro, SF Pro Rounded"
        peer: "32 roles, 8 to 30 sp, Alef, FontAwesome, Roboto, Taamey Frank CLM"
        status: open
        follows: unknown
        reason: ""
        decided_by: designer
        decided_on: 2026-10-26
        stag_guess: open
  generated_from:
    at: 2026-10-26T08:08:27Z
    inputs:
      - path: Info.plist
        sha256: 4862b53db77c1d8e59fa6ebe1e5669da8d203dda8562b23bb14086d77abfa503
      - path: SmartSiddur.xcodeproj/project.pbxproj
        sha256: 03fb3875cfa6422eb49f271efea7997b99170075199175ddd00a4e9c8d3f783f
      - path: SnapshotTests/PhonebookSnapshots.swift
        sha256: 88ae9a2c480efb1e0c7a145f79ec941ce4c7ed49864b3365d4d011b9acd3c08e
      - path: Sources/App/AppDelegate.swift
        sha256: ac3085587746dda24980cdb04c7d26b42b27fd330105c8213d39bde8c8c46f37
      - path: Sources/App/SmartSiddurApp.swift
        sha256: 717c649245aa1fa49f12e99b48006a8c0262561752ca718c7f6800bf2fbbd2db
      - path: Sources/Core/DI/DependencyContainer.swift
        sha256: dfc4dddeef404cb11a4821695bb48b5a495b4aac19630d575b397fc9d143cdd2
      - path: Sources/Core/LocalSettings.swift
        sha256: 52f40cc10537933a7280929190db443eed597067da7390d5c9f74808a7d2cb6c
      - path: Sources/Core/Models/DTO/AuthDTO.swift
        sha256: 62f0c48953334e6002ece05ce54a6aa69bcd887b2378e0a8c66c75530cf3367c
      - path: Sources/Core/Models/Domain/CachedPrayer.swift
        sha256: 8457fd310beb1a905918c44bff8c698c0932377d3ad6cb5c647e169b0b7182fe
      - path: Sources/Core/Models/Domain/GeoLocation.swift
        sha256: 0ebaea4f3980365d42cb57b323cedb2917b8ed8724e8994a8275ae7ce44e8ebe
      - path: Sources/Core/Models/Domain/JewishDay.swift
        sha256: 84dda62b7c2e2de606706bd4d7ca09e45b218cd8151003686b170af5081666b7
      - path: Sources/Core/Models/Domain/NextPrayerState.swift
        sha256: cc2cc20302223da003054cf4cd882411de89154d7ca2193c125dd105d36a2fb3
      - path: Sources/Core/Models/Domain/Prayer.swift
        sha256: d48e284dcdc5b1f41683e8a7adea13a105998e4cac3adfaa92eec4dc94f5f941
      - path: Sources/Core/Models/Domain/PrayerText.swift
        sha256: 913434a4591245845d250c1727f2530ecd71d2ae4d85a66de4ff35735f1df941
      - path: Sources/Core/Models/Domain/SyncedUserSettings.swift
        sha256: 5ee872fc1b95b3249c91315897246a15a576152289c4bc4b4d639e1861fd103f
      - path: Sources/Core/Models/Domain/UserLocation.swift
        sha256: 10e5dc611a2985998c725f9959c41f5d666c516aba14743c4074b73e72533079
      - path: Sources/Core/Models/Domain/UserProfile.swift
        sha256: 4669ce595ff5c8397f996779013ce918a13f125e3d2fcf90c01f92d72b230af2
      - path: Sources/Core/Models/Domain/ZmanTime.swift
        sha256: f5b85157d4ec6d82ce967e4d73cee0239fd36fddbce5f71bf267ee438ead6550
      - path: Sources/Core/Supabase/SupabaseClient+Config.swift
        sha256: ee6a122c99379157d8c999dc480a632cad310f9d7a299b6f3e93542c07281543
      - path: Sources/Data/Repositories/AuthRepository.swift
        sha256: 76f5fcd9823432483a3287b2b340c4047b9f1bb7ffaf6b2d72be0e7a14431816
      - path: Sources/Data/Repositories/LocationRepository.swift
        sha256: 120b57c23b7f64247c70e2c19ffe1d82e0ddd8111cafca273f9cabd2f02825de
      - path: Sources/Data/Repositories/SettingsRepository.swift
        sha256: bcf44b131e312470c4140b7d4aeaf245da9c7cc003de67446e409f3385b44f38
      - path: Sources/Extensions/AttributedString+HTML.swift
        sha256: 3672148459c7ab8c258d26345100c133d820966aad0e26d871d633f89fed02dc
      - path: Sources/Features/Auth/AuthViewModel.swift
        sha256: 943a6a79592daf3538b595e7ca3eabff1da0f3c09ecf8164ee7c514a5cb74861
      - path: Sources/Features/Auth/LoginView.swift
        sha256: 3fafc078c7fe91190e9251cf028496495c268c187ee62a396dc8b43a9373e3d6
      - path: Sources/Features/Auth/OnboardingView.swift
        sha256: 8fd81d1b00c5104b19dd16613a442f13d3bb975521bbca8622fe532bb1fa95ae
      - path: Sources/Features/Calendar/CalendarGridView.swift
        sha256: d75cecf76b0bda2947652a22e00ea2315bee5b18f142499b63bb5faba811bc4e
      - path: Sources/Features/Calendar/CalendarView.swift
        sha256: e9003fbe612bf1719bbb19cb3598ec482433bdbd08463c752f9b437bd975a123
      - path: Sources/Features/Calendar/CalendarViewModel.swift
        sha256: 4aa5b3663a742bb4f2805e376914f4faac49389f08d27510480c6a88f1d5236b
      - path: Sources/Features/Calendar/DayDetailSheet.swift
        sha256: e11570b169bc5a0b7942db265fa9c2bcaed7c4bda08f862616eb736c788408c5
      - path: Sources/Features/Calendar/HebrewDateFormatter.swift
        sha256: 64336d925b9cf60c40c2a417ed3e43abbe4cab89e819076f624d426c24789b03
      - path: Sources/Features/Home/HomeView.swift
        sha256: 739faffdd83c97ebba858373f5368b23cf29a1bf2df9713648686197548782d1
      - path: Sources/Features/Home/HomeViewModel.swift
        sha256: 91c13028c0cd8598b05d1d3d659db671f003ec166e2d00f83124b5b6858e2299
      - path: Sources/Features/Home/NewHomeView.swift
        sha256: 1708bfb4859e0ae90c3592a480f3373cc58ead878a3c194cf0e5ccb1f69d7a08
      - path: Sources/Features/Home/TabContainerView.swift
        sha256: 2ae532f680171198ad6e67fe355034659972e4f59bcb297e150188e96e68e90e
      - path: Sources/Features/Location/LocationPickerView.swift
        sha256: af2972fc0f9f2e06de1d1c3aab424e351f15ef06dce7ef87d5058a2683c903f8
      - path: Sources/Features/Location/LocationViewModel.swift
        sha256: 247ef2f650f97b7745d22f08c7e76b19a64f9fc433424ce186d8bf466ccc96da
      - path: Sources/Features/Prayers/PrayerTextView.swift
        sha256: b6837c106f24541b65404c70b5fff917806bd8f1f8444ee6c7aa4a91b32c8930
      - path: Sources/Features/Prayers/PrayerTextViewModel.swift
        sha256: 36afd35bc4d4d3b2ea37f26a3c3a0c773d7beffa0471766f93f7560a4bfaa9da
      - path: Sources/Features/Prayers/PrayersMenuView.swift
        sha256: 639165553d3438dab31015cf5572e5d40031ea7b497254ac3e545a2a04b928f4
      - path: Sources/Features/Prayers/PrayersMenuViewModel.swift
        sha256: ecb47671d9196bf0bea605771593f6c0392ce50ae6f373743987e76ba1c27bbb
      - path: Sources/Features/Settings/AppearanceSettingsView.swift
        sha256: 50e2d66d655bc2c5653d81f4c29f55eecdac791486b15c77c5c1512e04121376
      - path: Sources/Features/Settings/NusachPickerView.swift
        sha256: 3a1ad327bdb8a46a7d6954dd7701057203f2b75edeefaca97f6141c287941050
      - path: Sources/Features/Settings/SettingsView.swift
        sha256: 5c96d56cfcccc571a7b41e42605765bb6b06060b2fb92919c87227a132babb16
      - path: Sources/Features/Settings/SettingsViewModel.swift
        sha256: 763c2c376ede5ecadcf588173353ffabc749bfedc1c3f37fc8ce06790465a4d4
      - path: Sources/Features/Settings/ZmanimOpinionsView.swift
        sha256: 3831796c39b30b9ddceb35ebf2ad7978484d21ecf66b8d5e9ff777443d0a2e2b
      - path: Sources/Features/Zmanim/ZmanRowView.swift
        sha256: 3363d41ef5b8b1c66236699100f7acf9c0759680c7f7c3efea04f5468e203c40
      - path: Sources/Features/Zmanim/ZmanimView.swift
        sha256: 6658f0276d725ef5125ff2b1ed0b8862787dcf111e0a4cbb7fc741c025057949
      - path: Sources/Features/Zmanim/ZmanimViewModel.swift
        sha256: 350e268bae58e5421e2ccd262938e63e0a24298d0614b1946bd1d9b49e28925d
      - path: Sources/Services/JewishCalendarService.swift
        sha256: a3e687279e6dcb29e27fd9256da7225e1c8db151f5a02c3b514b4c5cd0dc0e88
      - path: Sources/Services/NextPrayerService.swift
        sha256: a57633a7319afb3ea12c131f973b9012f6a06a25df7707d4d479ec02781e6895
      - path: Sources/Services/PrayerBackgroundTaskManager.swift
        sha256: 9931b6253c8116937b4e886551ccbd74ae691c10ad0bab88769ff6f192698a6f
      - path: Sources/Services/PrayerCacheService.swift
        sha256: 29317ee35c5faaaa24758d0380538fa6af50c232768604e2bb10dbe5d00757b9
      - path: Sources/Services/PrayerService.swift
        sha256: 01f628f160845d6cded115dc6870a6697acdb94f951bb01a83d8fe3bb5ffb88e
      - path: Sources/Services/PrayerVisibilityService.swift
        sha256: c7e8d5d66fc77adf489f2d3b210ef3ac2cd83d897d6cc183ae18a74ee3b711ff
      - path: Sources/Services/ZmanimService.swift
        sha256: 7ddcaa58ac8c2076cad2463b7b76e8ddb0ee604b476b366638f3a95f994fcc9d
      - path: Sources/UI/Components/ComponentExports.swift
        sha256: bcab766b41473db4c9d03b524b0987701218ddc7c0fe752bd06658d42564c5c9
      - path: Sources/UI/Theme/AppTheme.swift
        sha256: 3efe97c3a808655d87f442ce513a2d8ef7fa76252ea9b147fdad32ea25dc1ae9
      - path: docs/plans/2026-02-23-visual-redesign.md
        sha256: 5a906d3a11d8d588a04d85a35564a6feda440577b33439fc89986b5d1d797baf
      - path: new_style.html
        sha256: 133807e0cbe7ed644f30df602cb22fdb526ee39844863939d4a8f48c089d31ef
      - path: phonebook.config.json
        sha256: c47bb7ad881a95c80acf93840a1a21c61da336b10276e8cd349a3981eb2cd0a8
      - path: project.yml
        sha256: 143edc189254dc5f738414ee0e9ba08ed993786ed8cf3ddbcf2d29e839c7bd90
      - path: sample_response.json
        sha256: 453faa225cce3d7284290d1149b62f3ec38b84abcb87769f7bbe099cb9ca988c
      - path: tasks.md
        sha256: 4da9105bdc5cd779115ddd58cb57924effd787f90fe2f9be9098e0220c6b6e18
---
## Overview
- Make Smart Siddur warmer, more traditional and devotional.
- Let sacred time and prayer feel considered and calm, using teal for actions and gold for focused outlines rather than decoration everywhere.
- Follow the iPhone's light or dark appearance while preserving one recognizable identity in both.

## Colors
- Use the near-white-to-white background in light appearance and the charcoal-to-near-black gradient in dark appearance.
- Use teal for prayer actions, selected states, and upcoming times.
- Keep surfaces white in light appearance and dark charcoal in dark appearance.
- Reserve green for seasonal or currently available devotional context.
- Keep the calendar's purple, orange, red, blue, and green meanings consistent across cells, dots, and details.

## Typography
- Use Apple's system typography for every interface label, control, date, and status.
- Use rounded system typography only for countdowns and compact calendar numerals.
- Keep prayer reading at 20 points by default, right aligned, and right-to-left.
- Apply user-selected family and size only inside prayer reading; never let it alter navigation, settings, buttons, or other interface text.

## Layout
- Use 16-point screen gutters on primary screens and 10-point gaps in two-column prayer grids.
- Stack primary sections with 18 points of separation and keep internal card spacing compact.
- Preserve native safe areas, scrolling behavior, and right-to-left layout.
- Keep prayer and calendar actions reachable without hiding essential content behind ornamental chrome.

## Elevation & Depth
- Create depth with solid surfaces, subtle outlines, and the background gradient.
- Use stronger gold outlines only for the current prayer, the next upcoming zman, or the selected calendar state.
- Avoid heavy shadows; let contrast and restrained transparency establish hierarchy.

## Shapes
- Use 18-point corners for hero and major information cards.
- Use 14-point corners for prayer tiles and 12-point corners for compact rows, badges, and controls.
- Use capsules for short prayer actions and circles for calendar selection and navigation buttons.

## Components
- Extend the Home and Calendar surface-card language to prayer reading, location, nusach, appearance, zmanim opinions, and account screens.
- Keep native Apple controls for toggles, pickers, navigation, sign in, and segmented selection, then tint and surface them with this system.
- Keep provider sign-in buttons 50 points high and calendar navigation targets 34 points square.
- Keep prayer tiles 112 points high so two-column grids remain stable across changing content.

## Do's and Don'ts
- Do follow the active redesigned Home, Calendar, Settings, and Login screens for layout and components, and follow the semantic color tokens here when colors differ.
- Do make every new color semantic and appearance-aware.
- Do preserve Dynamic Type for interface roles and isolate user-controlled typography to prayer reading.
- Don't introduce another teal, gold, near-white, charcoal, card radius, or surface opacity for a local screen.
- Don't use the missing named color assets or copy the current private palette into another view.
- Don't leave detail screens as visually separate native lists; bring them into the confirmed surface, teal, and gold-outline family.
