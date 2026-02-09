# Phase 3: Prayer Experience - Context

**Gathered:** 2026-02-09
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can open any prayer and see the correct text for today's date, nusach, and settings -- even in airplane mode. Phase includes: prayer list/menu with all 26+ prayer types, prayer text display with correct nusach and calendar-sensitive insertions, 14-day offline cache, new "Prayers" tab in TabContainerView, and content delta sync from backend. All prayers are free (no premium gating).

</domain>

<decisions>
## Implementation Decisions

### Prayer menu organization
- Hybrid organization: first by time of day (Morning/Afternoon/Evening), then separate "Special Occasions" section
- Within time sections: order by prayer importance/sequence (main service first, then additional prayers in traditional order)
- Special occasions (like Hallel in Nissan) appear in separate section
- "Today" section at top showing current day's relevant prayers
- No search functionality in Phase 3 - simple browsing only

### Prayer text display
- Full scrolling view (not paginated or card-based)
- Table of contents overlay for navigation within long prayers
- iOS Dynamic Type for font size controls
- Always show nikud and teamim (vowel points and cantillation marks)
- Hebrew only (no English translations)
- For repetitions: first time full text, then "repeat" notation for subsequent repetitions
- Text variations based on nusach (already handled by backend)

### Navigation flow
- Back to menu each time (always return to prayer list to choose another)
- No favorites system or recently used list
- No search in Phase 3
- Prayers tab opens to "Today's prayers view" showing relevant prayers

### Offline experience
- No offline indication (seamless experience)
- Block access to cached prayers when cache expires (until refresh)
- Silent background updates when device is online

### Claude's Discretion
- Exact visual design of prayer menu sections and separators
- Table of contents implementation details and UI
- Cache refresh timing and background processing approach

</decisions>

<specifics>
## Specific Ideas

- "Now section, with time of day, and special occasion like ברכת האילנות on Nissan. Then by categorize"
- User wants clear distinction between daily prayers and special occasion prayers
- For today's prayers: show at top of menu what's relevant to current day
- Traditional prayer sequence should be respected within each time section

</specifics>

<deferred>
## Deferred Ideas

- Search functionality within prayers — defer to later phase
- Favorites system for frequently used prayers — defer to later phase
- English translations or transliterations — defer to later phase
- Advanced pronunciation guides — defer to later phase

</deferred>

---

*Phase: 03-prayer-experience*
*Context gathered: 2026-02-09*