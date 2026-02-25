# Localization Pipeline Scripts

## 1) Export Android XML -> Canonical JSON

```bash
python3 scripts/l10n/export_android_strings.py \
  --android-res-dir ~/git/SmartSiddur/app/src/main/res \
  --output scripts/l10n/out/localizable.json
```

## 2) Upload Canonical JSON -> Supabase Storage

```bash
bash scripts/l10n/upload_json_to_supabase.sh \
  scripts/l10n/out/localizable.json \
  localization \
  localizable.json
```

## 3) Download JSON from Supabase Storage

```bash
bash scripts/l10n/download_json_from_supabase.sh \
  scripts/l10n/out/localizable.from.supabase.json \
  localization \
  localizable.json
```

## 4) Generate iOS String Catalog

```bash
python3 scripts/l10n/generate_xcstrings.py \
  --input scripts/l10n/out/localizable.from.supabase.json \
  --output Sources/Resources/Localization/Localizable.xcstrings
```

## 5) Scan and Replace Hardcoded Swift Strings

Dry-run:

```bash
python3 scripts/l10n/scan_replace_swift_strings.py \
  --catalog scripts/l10n/out/localizable.from.supabase.json \
  --sources-dir Sources \
  --report scripts/l10n/out/scan-report.json
```

Apply:

```bash
python3 scripts/l10n/scan_replace_swift_strings.py \
  --catalog scripts/l10n/out/localizable.from.supabase.json \
  --sources-dir Sources \
  --report scripts/l10n/out/scan-report.apply.json \
  --apply
```

## 6) Generate Missing Strings Report

```bash
python3 scripts/l10n/report_missing_strings.py \
  --input scripts/l10n/out/scan-report.json \
  --output scripts/l10n/out/missing-strings.json
```

## Notes

- Supabase CLI commands expect access to the target project storage API.
- `upload_json_to_supabase.sh` and `download_json_from_supabase.sh` use `supabase storage cp` with `ss:///bucket/path`.
- Missing strings are report-only and are **not** auto-appended to canonical JSON.
