# Phase 1: Backend Foundation - Context

**Gathered:** 2026-02-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Deploy the full Supabase backend: schema with RLS, seed 710+ prayer strings and 141K locations, and build edge functions that generate correct prayers for all 26+ types. This phase operates entirely in the `supabase/` directory of the existing SmartSiddur repo (which also contains the Android source code).

</domain>

<decisions>
## Implementation Decisions

### Content migration strategy
- **Primary content sources:** Most prayer text lives in `strings.xml`, some in JSON asset files — mixed style throughout the Android app
- **Migration approach:** Follow each prayer generator in the Android code to discover which strings/JSON it references. Trace generator → string/JSON references to build the extraction map. This is the authoritative way to find all content.
- **Prayer text vs UI strings:** Distinguish between prayer text (goes to `prayer_content` table in Supabase) and translatable UI placeholder strings (stay as app-level resources, not seeded to DB)
- **Android source is in this repo** (`app/` directory) — researcher can directly inspect generators and string resources

### Placeholder format
- Convert all Android-style positional placeholders (`%1$s`, `%2$d`) to named placeholders (`{{name}}`, `{{count}}`, etc.)
- Named placeholders are self-documenting and platform-independent

### Nusach variant storage
- One row per nusach variant in `prayer_content` — same prayer type gets separate rows for Ashkenaz, Sfard, Edot HaMizrach, etc.
- Simple queries: `WHERE nusach = 'ashkenaz'` — no JSONB unpacking needed

### Claude's Discretion
- Exact table schema design (column names, types, indexes)
- RLS policy structure
- Edge function architecture and error handling
- Location data import strategy (141K rows — batch approach, indexing)
- How to handle prayer content that has no nusach variation (shared across all variants)

</decisions>

<specifics>
## Specific Ideas

- The `xml_to_json.js` and `xml_to_json.sh` scripts already exist in the repo root — these may contain partial migration logic worth examining
- `MIGRATION_SPEC.md` exists at repo root — likely contains prior migration thinking that should inform the approach
- The Android generators are the source of truth for understanding prayer structure — each generator knows which strings it needs and what conditional logic applies

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-backend-foundation*
*Context gathered: 2026-02-08*
