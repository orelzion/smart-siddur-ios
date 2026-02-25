#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 3 ]]; then
  echo "Usage: $0 <input-json> [bucket=localization] [object-path=localizable.json]" >&2
  exit 1
fi

INPUT_JSON="$1"
BUCKET="${2:-localization}"
OBJECT_PATH="${3:-localizable.json}"

if [[ ! -f "$INPUT_JSON" ]]; then
  echo "error: input file not found: $INPUT_JSON" >&2
  exit 1
fi

if ! command -v supabase >/dev/null 2>&1; then
  echo "error: supabase CLI not found" >&2
  exit 1
fi

DEST="ss:///$BUCKET/$OBJECT_PATH"
echo "Uploading $INPUT_JSON -> $DEST"
supabase --experimental storage cp "$INPUT_JSON" "$DEST"
echo "Upload complete."
