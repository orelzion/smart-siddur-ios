---
version: alpha
name: SmartSiddur iOS
description: Native iOS design foundation for a calm, focused siddur, with warm cream and deep navy appearances and restrained gold accents.
colors:
  primary: "#DAB946"
  on-primary: "#1A1A2E"
  background: "#FAF8F5"
  background-end: "#FFFFFF"
  on-background: "#1A1A2E"
  surface: "#FFFFFF"
  on-surface: "#1A1A2E"
  on-surface-secondary: "#66738C"
  outline: "#00000014"
  success: "#4AC47F"
  success-container: "#4AC47F26"
  error: "#FF3B30"
  scrim: "#0000004D"
typography:
  large-title-bold: { fontFamily: SF Pro, fontSize: 34px, fontWeight: 700 }
  large-title: { fontFamily: SF Pro, fontSize: 34px, fontWeight: 400 }
  title: { fontFamily: SF Pro, fontSize: 28px, fontWeight: 400 }
  title2-bold: { fontFamily: SF Pro, fontSize: 22px, fontWeight: 700 }
  title2: { fontFamily: SF Pro, fontSize: 22px, fontWeight: 400 }
  title3-semibold: { fontFamily: SF Pro, fontSize: 20px, fontWeight: 600 }
  headline: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 600 }
  body-bold: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 700 }
  body-medium: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 500 }
  body: { fontFamily: SF Pro, fontSize: 17px, fontWeight: 400 }
  prayer-body: { fontFamily: SF Pro, fontSize: 20px, fontWeight: 400 }
  prayer-section: { fontFamily: SF Pro, fontSize: 18px, fontWeight: 600 }
  subheadline-semibold: { fontFamily: SF Pro, fontSize: 15px, fontWeight: 600 }
  subheadline: { fontFamily: SF Pro, fontSize: 15px, fontWeight: 400 }
  caption-bold: { fontFamily: SF Pro, fontSize: 12px, fontWeight: 700 }
  caption-semibold: { fontFamily: SF Pro, fontSize: 12px, fontWeight: 600 }
  caption: { fontFamily: SF Pro, fontSize: 12px, fontWeight: 400 }
  caption2-semibold: { fontFamily: SF Pro, fontSize: 11px, fontWeight: 600 }
  calendar-detail: { fontFamily: SF Pro, fontSize: 9px, fontWeight: 400 }
rounded:
  small: 8
  medium: 12
  card: 14
  large-card: 18
  round: 9999
spacing:
  hairline: 0.5
  xxs: 2
  xs: 4
  sm: 6
  compact: 8
  md: 10
  control: 12
  section: 14
  standard: 16
  roomy: 18
  page: 24
  screen-bottom: 30
  auth-gutter: 32
  auth-bottom: 40
components:
  primary-action:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.subheadline-semibold}"
    rounded: "{rounded.round}"
    padding: "{spacing.control}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.large-card}"
    padding: "{spacing.standard}"
  prayer-tile:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    typography: "{typography.subheadline-semibold}"
    rounded: "{rounded.card}"
    padding: "{spacing.control}"
    height: 112
  auth-button:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    typography: "{typography.body-medium}"
    rounded: "{rounded.medium}"
    height: 50
  calendar-day:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.round}"
    size: 40
x-stag:
  schema: 1
  platform: ios
  peer: none
  facts:
    ui_framework: { primary: swiftui, swiftui_files: 24, uikit_only_files: 2 }
    deployment_target: "17.0"
    token_source: code
    generated: false
    accessor: null
    spacing_scale: none
    dark_mode:
      status: system
      mechanism: "SwiftUI colorScheme and adaptive system colors"
      evidence: [Sources/Features/Home/NewHomeView.swift, Sources/Features/Calendar/CalendarView.swift, Sources/Features/Settings/SettingsView.swift, Sources/Features/Prayers/PrayerTextView.swift]
    liquid_glass: false
    dynamic_color: true
    trap: "Color asset-style accessors exist, but there are no color assets and no screen uses those accessors."
    migration: "Move toward native iOS structure with gold as the accent; consolidate duplicated screen-local cream/navy/gold values into one code-owned token layer."
    confirmed:
      overall_feel: "Calm, reverent, and focused — warm cream in light mode, deep navy in dark mode, with restrained gold accents."
      canonical_style: "Use native iOS styling as the foundation; keep gold mainly as the app accent."
      appearance_direction: "Treat system/light/dark themes and prayer font customization as intended product behavior that future work should complete."
  themes:
    default: light
    selection: system_and_user
    list:
      - { id: light, kind: appearance }
      - { id: dark, kind: appearance }
  values:
    colors.primary: { dark: "#DAB946" }
    colors.on-primary: { dark: "#1A1A2E" }
    colors.background: { dark: "#0F172A" }
    colors.background-end: { dark: "#020617" }
    colors.on-background: { dark: "#FFFFFF" }
    colors.surface: { dark: "#FFFFFF14" }
    colors.on-surface: { dark: "#FFFFFF" }
    colors.on-surface-secondary: { dark: "#B3B8C7" }
    colors.outline: { dark: "#FFFFFF1F" }
    colors.success: { dark: "#4AC47F" }
    colors.success-container: { dark: "#4AC47F26" }
    colors.error: { dark: "#FF453A" }
    colors.scrim: { dark: "#0000004D" }
  bindings:
    colors.primary: { native: "Color(red: 0.85, green: 0.73, blue: 0.27)", source: "Sources/Features/Home/NewHomeView.swift#gold" }
    colors.on-primary: { native: "Color.black.opacity(0.85)", source: "Sources/Features/Home/NewHomeView.swift#heroButton" }
    colors.background: { native: "Color(red: 0.98, green: 0.97, blue: 0.96)", source: "Sources/Features/Home/NewHomeView.swift#backgroundGradient" }
    colors.background-end: { native: "Color.white", source: "Sources/Features/Home/NewHomeView.swift#backgroundGradient" }
    colors.on-background: { native: "Color(red: 0.10, green: 0.10, blue: 0.18)", source: "Sources/Features/Home/NewHomeView.swift#primaryText" }
    colors.surface: { native: "Color.white", source: "Sources/Features/Home/NewHomeView.swift#cardFill" }
    colors.on-surface: { native: "primaryText", source: "Sources/Features/Home/NewHomeView.swift#primaryText" }
    colors.on-surface-secondary: { native: "Color(red: 0.40, green: 0.45, blue: 0.55)", source: "Sources/Features/Home/NewHomeView.swift#secondaryText" }
    colors.outline: { native: "Color.black.opacity(0.08)", source: "Sources/Features/Home/NewHomeView.swift#borderColor" }
    colors.success: { native: "Color(red: 0.29, green: 0.77, blue: 0.50)", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    colors.success-container: { native: "Color(red: 0.29, green: 0.77, blue: 0.50).opacity(0.15)", source: "Sources/Features/Home/NewHomeView.swift#suggestedSection" }
    colors.error: { native: "Color.red", source: "Sources/Features/Zmanim/ZmanimView.swift" }
    colors.scrim: { native: "Color.black.opacity(0.3)", source: "Sources/Features/Auth/LoginView.swift#loading overlay" }
    typography.large-title-bold: { native: ".font(.largeTitle.weight(.bold))", source: "Sources/Features/Home/NewHomeView.swift#greetingHeader" }
    typography.headline: { native: ".font(.headline)", source: "Sources/Features/Home/NewHomeView.swift#heroCard" }
    typography.body: { native: ".font(.body)", source: "Sources/Features/Zmanim/ZmanRowView.swift" }
    typography.prayer-body: { native: ".font(.system(size: 20))", source: "Sources/Features/Prayers/PrayerTextView.swift" }
    typography.prayer-section: { native: ".font(.system(size: 18, weight: .semibold))", source: "Sources/Features/Prayers/PrayerTextView.swift" }
    typography.subheadline: { native: ".font(.subheadline)", source: "Sources/Features/Home/NewHomeView.swift" }
    typography.caption: { native: ".font(.caption)", source: "Sources/Features/Zmanim/ZmanimView.swift" }
    rounded.small: { native: "RoundedRectangle(cornerRadius: 8)", source: "Sources/Features/Prayers/PrayerTextView.swift" }
    rounded.medium: { native: "RoundedRectangle(cornerRadius: 12)", source: "Sources/Features/Home/NewHomeView.swift" }
    rounded.card: { native: "RoundedRectangle(cornerRadius: 14)", source: "Sources/Features/Home/NewHomeView.swift" }
    rounded.large-card: { native: "RoundedRectangle(cornerRadius: 18)", source: "Sources/Features/Home/NewHomeView.swift" }
    rounded.round: { native: ".capsule or .circle", source: "Sources/Features/Home/NewHomeView.swift" }
  fonts:
    - { family: SF Pro, files: [], registered_via: system, preview: system, used_by: "App UI, prayer text, calendar, and settings" }
  examples:
    - { screen: Home, path: Sources/Features/Home/NewHomeView.swift, shows: [adaptive background, gold accent, hero card, prayer tiles] }
    - { screen: Calendar, path: Sources/Features/Calendar/CalendarView.swift, shows: [native navigation, adaptive cards, calendar grid] }
    - { screen: Settings, path: Sources/Features/Settings/SettingsView.swift, shows: [native grouped list, adaptive background, gold tint] }
    - { screen: Prayer Text, path: Sources/Features/Prayers/PrayerTextView.swift, shows: [content-first layout, RTL text, reading typography] }
    - { screen: Sign In, path: Sources/Features/Auth/LoginView.swift, shows: [deep navy background, gold accent, 50-point actions] }
  known_off_system:
    - { id: duplicated-color-literals, pattern: "Color(red:green:blue:)", count: 49, replacement: "Use one code-owned semantic color accessor." }
    - { id: raw-system-font-sizes, pattern: ".font(.system(size:))", count: 18, replacement: "Use semantic typography roles, except data-dense calendar details and user-selected prayer size." }
    - { id: unused-color-asset-accessors, pattern: "Color(\"BgCard\") and related names", count: 6, replacement: "Remove or replace with the canonical code token accessor; no matching assets exist." }
    - { id: unapplied-appearance-settings, pattern: "Saved theme and font preferences only affect the Appearance preview", count: 3, replacement: "Apply theme at the app root and font family/size to prayer text." }
  sizes:
    - { kind: button, name: authentication-action, height: 50, radius: 12 }
    - { kind: button, name: gold-prayer-action, radius: 9999, inset: 12 }
    - { kind: pill, name: status-badge, radius: 12, inset: 12 }
    - { kind: other, name: prayer-tile, height: 112, radius: 14, inset: 12 }
    - { kind: other, name: hero-card, radius: 18, inset: 16 }
    - { kind: other, name: calendar-day-cell, width: 40, height: 40, radius: 9999 }
    - { kind: icon, name: sign-in-mark, width: 72, height: 72 }
    - { kind: icon, name: empty-state, width: 48, height: 48 }
    - { kind: margin, name: screen-gutter, inset: 16 }
  roles:
    primary: accent
    on-primary: text
    background: background
    background-end: background
    on-background: text
    surface: surface
    on-surface: text
    on-surface-secondary: textSecondary
    outline: border
    success: other
    success-container: fieldFill
    error: error
    scrim: scrim
  usage:
    primary: "Restrained gold for tint, selection, emphasis, and primary prayer actions."
    background: "Warm cream start of the light appearance background."
    background-end: "White end of the light appearance background."
    surface: "Native-feeling cards, rows, and reading surfaces."
    on-surface-secondary: "Supporting dates, locations, hints, and metadata."
    outline: "Subtle card and tile boundaries."
    success: "Seasonal or timely positive status."
    error: "Errors and destructive status only."
  gaps:
    - "The Theme picker saves system, light, and dark choices, but the app does not yet apply that preference at its root."
    - "The font family and size controls are intended for prayer reading, but only the preview currently uses the chosen size and no chosen family is applied."
    - "DesignTokens claims to be unified, but active screens duplicate its values and do not call it."
    - "Color asset accessors name six assets that do not exist in the repository."
    - "Login is always dark while authenticated screens adapt to system appearance."
    - "Typography roles merge rounded and monospaced variants with their matching size and weight to stay within a compact role set."
    - "The named prayer font options have no bundled files and are not yet connected to rendered prayer text."
  deviations: none
  generated_from:
    at: 2026-11-07T22:53:17Z
    inputs:
      - path: .agents/skills/mobile-ios-design/SKILL.md
        sha256: b353d5744bbb5eafa1610f6083b50fefc683001f08e4227fced7b986864caf6d
      - path: .agents/skills/mobile-ios-design/references/swiftui-components.md
        sha256: 3eb82e50121d529ee664685da10f42f59aa8dee4cc14acaca4c5d377d8cd8700
      - path: Sources/App/SmartSiddurApp.swift
        sha256: 717c649245aa1fa49f12e99b48006a8c0262561752ca718c7f6800bf2fbbd2db
      - path: Sources/Core/LocalSettings.swift
        sha256: 52f40cc10537933a7280929190db443eed597067da7390d5c9f74808a7d2cb6c
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
      - path: Sources/UI/Theme/AppTheme.swift
        sha256: 3efe97c3a808655d87f442ce513a2d8ef7fa76252ea9b147fdad32ea25dc1ae9
      - path: project.yml
        sha256: 43dc158df765e75127c4308f42369f32b560d23d7e76130b652e6e924781a658
---
## Overview
- Keep SmartSiddur calm, reverent, and focused: use warm cream in light mode, deep navy in dark mode, and restrained gold accents.
- Start from native iOS navigation, controls, lists, typography, and accessibility behavior.
- Let prayer content and timely information carry the hierarchy; keep decoration quiet.

## Colors
- Use gold for app tint, selected states, brief emphasis, and primary prayer actions—not as a general text color.
- Use warm cream-to-white backgrounds in light mode and the coded deep navy gradient in dark mode.
- Use adaptive semantic text and surface colors so every screen remains legible in both appearances.
- Reserve green for positive seasonal status and red for errors or destructive meaning.

## Typography
- Prefer SwiftUI semantic text styles so interface text follows Dynamic Type.
- Use the reading roles for prayer content; apply the user-selected prayer family and size when that migration is completed.
- Use rounded or monospaced digits only for times and countdowns.
- Keep dense 9-point calendar details exceptional and never use them for actionable text.

## Layout
- Use a 16-point screen gutter and native safe areas.
- Separate major home sections by 18 points and use 10–12 points inside compact groups.
- Keep reading content full-width, right-aligned, and right-to-left where the prayer language requires it.
- Prefer native grouped lists for settings and utility flows.

## Elevation & Depth
- Create hierarchy with surface contrast and fine outlines before adding shadows.
- Keep cards quiet and flat enough that content remains primary.
- Use translucent dark surfaces only where the coded dark appearance calls for them.

## Shapes
- Use 18-point corners for feature cards, 14-point corners for tiles, and 12-point corners for compact controls and badges.
- Use capsules for short primary actions and small labels; use circles for calendar selections and icon-only controls.

## Components
- Build new utility screens from native SwiftUI controls and grouped lists, tinted with the primary gold.
- Keep primary prayer actions short, gold, capsule-shaped, and high contrast.
- Keep prayer tiles consistent at 112 points high with 12-point internal padding.
- Apply theme selection at the app root and prayer typography preferences at the prayer reader when completing the appearance migration.

## Do's and Don'ts
- Do reuse one semantic token source when touching duplicated cream, navy, gold, text, surface, or outline values.
- Do preserve system, light, and dark as intended user-selectable appearances.
- Do keep sign-in recognizably part of the same system while respecting provider button requirements.
- Don't introduce new hard-coded color copies or private typography scales.
- Don't make every surface gold, glassy, or heavily elevated.
- Don't present the current Appearance controls as fully implemented until their choices affect the app.
