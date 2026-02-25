# Android -> Supabase JSON -> iOS Localization Pipeline Tasks

**Date**: 2026-02-23  
**Status**: In Progress  
**Owner**: iOS app team

---

## Goal

Create a repeatable localization pipeline that:

1. Exports Android `strings.xml` resources into a canonical JSON file.
2. Uploads/downloads that JSON via Supabase Storage (single source of truth).
3. Generates iOS `Localizable.xcstrings` from the JSON.
4. Scans and aggressively replaces hardcoded UI strings when exact matches exist.
5. Reports unresolved/missing strings for manual review (no auto-append).

---

## Phase 1: Tooling Foundation

### 1.1 Android Export Script
**Priority**: Critical  
**Files**:
- `scripts/l10n/export_android_strings.py`

**Tasks**:
- [x] Parse Android `values*/strings.xml` files.
- [x] Map locales: `values -> en`, `values-iw -> he`, `values-fr -> fr`, `values-es -> es`, `values-de -> de`.
- [x] Preserve Android key names.
- [x] Normalize placeholders to iOS-friendly formats.
- [x] Output canonical JSON.

### 1.2 Supabase Storage Sync Scripts
**Priority**: Critical  
**Files**:
- `scripts/l10n/upload_json_to_supabase.sh`
- `scripts/l10n/download_json_from_supabase.sh`

**Tasks**:
- [ ] Upload canonical JSON to `ss:///localization/localizable.json`. (blocked: bucket missing)
- [ ] Download canonical JSON from the same path. (blocked: bucket missing)
- [x] Add usage and validation checks.

---

## Phase 2: iOS Generation

### 2.1 String Catalog Generator
**Priority**: Critical  
**Files**:
- `scripts/l10n/generate_xcstrings.py`
- `Sources/Resources/Localization/Localizable.xcstrings` (generated)

**Tasks**:
- [x] Generate `Localizable.xcstrings` with locales `en/he/fr/es/de`.
- [x] Include available per-locale values per key.
- [x] Keep `en` as source language fallback.

---

## Phase 3: App Migration Automation

### 3.1 Hardcoded String Scanner/Replacer
**Priority**: High  
**Files**:
- `scripts/l10n/scan_replace_swift_strings.py`

**Tasks**:
- [x] Scan Swift UI string literals from `Sources/`.
- [x] Aggressively replace exact literal matches using canonical JSON.
- [x] Support dry-run and apply modes.
- [x] Produce unresolved report JSON.

### 3.2 Missing Strings Report
**Priority**: High  
**Files**:
- `scripts/l10n/report_missing_strings.py`

**Tasks**:
- [x] Convert scan output into sorted actionable report.
- [x] Group by file and suggest candidate keys.
- [x] Keep report-only workflow (no auto-append to canonical JSON).

---

## Phase 4: Validation and Iteration

### 4.1 Pipeline Validation
**Priority**: High  
**Tasks**:
- [x] Run export from Android source.
- [ ] Upload canonical JSON to Supabase Storage. (blocked: bucket missing)
- [ ] Download and regenerate iOS `.xcstrings`. (download blocked; generation validated from local export)
- [x] Run scanner in dry-run, then apply.
- [x] Build app and review unresolved report.

### 4.2 Iterative Gap Closure
**Priority**: Medium  
**Tasks**:
- [ ] Manually add missing keys/values to canonical JSON.
- [ ] Re-upload and regenerate.
- [ ] Re-run scan/replace until acceptable residuals remain.

---

## Acceptance Criteria

- Canonical JSON is reproducible from Android source.
- JSON round-trips through Supabase Storage.
- iOS `Localizable.xcstrings` is generated from canonical JSON.
- Hardcoded strings are replaced where exact localization exists.
- Unresolved strings are reported for curation with file/line context.
