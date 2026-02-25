#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 3 ]]; then
  echo "Usage: $0 <output-json> [bucket=localization] [object-path=localizable.json]" >&2
  exit 1
fi

OUTPUT_JSON="$1"
BUCKET="${2:-localization}"
OBJECT_PATH="${3:-localizable.json}"

if ! command -v supabase >/dev/null 2>&1; then
  echo "error: supabase CLI not found" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_JSON")"

SRC="ss:///$BUCKET/$OBJECT_PATH"
echo "Downloading $SRC -> $OUTPUT_JSON"
supabase --experimental storage cp "$SRC" "$OUTPUT_JSON"
echo "Download complete."
