# Phase 2: iOS Core - Context

**Gathered:** 2026-02-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can sign in, configure their halachic identity and preferences, pick their location, and view accurate daily zmanim — plus a full Hebrew/Gregorian calendar with day details. Auth (Apple, Google, Anonymous), synced + local settings, location picker, zmanim display, and calendar are all in scope. Prayer display, offline cache, and subscriptions belong to Phase 3.

</domain>

<decisions>
## Implementation Decisions

### Location Experience
- **Search UI**: Simple searchable list of city names with country/region — no map, fast and focused (like the Android app)
- **GPS behavior**: Auto-detect location on first launch — request permission early, auto-set nearest city from 141K seeded locations
- **Location model**: Single active location at a time — user goes to settings to change it, no multi-location favorites or quick-switcher
- **GPS fallback**: Show nearest seeded city with distance indicator (e.g., "Jerusalem (2km away)") and let user confirm or search manually

### Zmanim Display
- **Next zman**: Highlight the next upcoming time visually (bold/color) but no live countdown timer — calm, not clock-watching
- **Default times**: Essential set (~8-10 key times: Alot, Netz, Sof Zman Shma, Sof Zman Tfila, Chatzot, Mincha Gedola, Shkia, Tzeit) with an "All times" toggle to reveal the comprehensive set (~15-20 times including Plag, Mincha Ketana, Misheyakir, multiple Tzeit opinions)
- **Shabbat/Holiday times**: Candle lighting and havdalah shown in a dedicated separate section/card — not inline with regular zmanim

### Calendar
- **Calendar screen**: Full dedicated calendar view showing month grid with Hebrew dates overlaid — not just inline navigation on zmanim
- **Dual calendar**: Toggle between Gregorian-primary (Hebrew dates as secondary) and Hebrew-primary (Gregorian as secondary) month views
- **Day markers**: Colored dots or icons on calendar cells for Shabbat, holidays, fast days, Rosh Chodesh
- **Day tap action**: Bottom sheet/popup with zmanim for that day, parsha (on Shabbat), holiday info, and any special notes
- **Parsha display**: Shown in the day detail sheet when tapping a Shabbat day — not on the calendar grid itself
- **Daf Yomi**: Show today's Daf Yomi on the day detail sheet

### Claude's Discretion
- Zmanim list organization (grouped by period vs flat chronological)
- Onboarding flow design (auth → setup sequence, skippability)
- Settings screen organization and grouping
- Exact spacing, typography, and visual styling
- Error state handling throughout

</decisions>

<specifics>
## Specific Ideas

- Android app has a calendar view with Hebrew and Gregorian dates — iOS should have a similar concept with native iOS feel (full calendar screen, not a widget)
- Location search should feel like the Android app — simple list, fast, focused
- Calendar should show both calendar systems as first-class, with toggle between Hebrew-primary and Gregorian-primary

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-ios-core*
*Context gathered: 2026-02-09*
