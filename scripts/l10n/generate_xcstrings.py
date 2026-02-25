#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path


def build_xcstrings(payload: dict) -> dict:
    strings = payload.get("strings", {})
    default_locale = payload.get("defaultLocale", "en")

    xcstrings = {
        "sourceLanguage": default_locale,
        "strings": {},
        "version": "1.0",
    }

    for key in sorted(strings.keys()):
        per_locale = strings[key]
        localizations = {}
        for locale, value in per_locale.items():
            if value is None:
                continue
            localizations[locale] = {
                "stringUnit": {
                    "state": "translated",
                    "value": value,
                }
            }

        xcstrings["strings"][key] = {
            "extractionState": "manual",
            "localizations": localizations,
        }

    return xcstrings


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate Localizable.xcstrings from canonical JSON.")
    parser.add_argument("--input", required=True, help="Canonical JSON path.")
    parser.add_argument("--output", required=True, help="Output .xcstrings path.")
    args = parser.parse_args()

    input_path = Path(args.input).expanduser().resolve()
    output_path = Path(args.output).expanduser().resolve()

    if not input_path.exists():
        print(f"error: input not found: {input_path}", file=sys.stderr)
        return 1

    payload = json.loads(input_path.read_text(encoding="utf-8"))
    xcstrings = build_xcstrings(payload)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(xcstrings, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"wrote {output_path}")
    print(f"keys: {len(xcstrings['strings'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
