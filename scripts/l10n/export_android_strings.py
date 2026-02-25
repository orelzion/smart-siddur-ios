#!/usr/bin/env python3
import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from xml.etree import ElementTree as ET

LOCALE_DIR_MAP = {
    "values": "en",
    "values-iw": "he",
    "values-fr": "fr",
    "values-es": "es",
    "values-de": "de",
}


def normalize_android_value(value: str) -> str:
    if value is None:
        return ""

    # Android escaped apostrophes and new lines.
    text = value.replace("\\'", "'").replace("\\n", "\n")

    # Convert Android printf string placeholders to iOS-compatible ones.
    # %s      -> %@
    # %1$s    -> %1$@
    # %d/%f   -> unchanged
    text = re.sub(r"%(\d+\$)?s", lambda m: f"%{m.group(1) or ''}@", text)
    return text


def parse_strings_xml(xml_path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    tree = ET.parse(xml_path)
    root = tree.getroot()

    for child in root:
        if child.tag != "string":
            continue

        if child.attrib.get("translatable") == "false":
            continue

        name = child.attrib.get("name", "").strip()
        if not name:
            continue

        value = normalize_android_value("".join(child.itertext()))
        out[name] = value

    # Android keeps many UI labels in arrays; expose them as stable keys too.
    # Key format: <array_name>__<index>
    for child in root:
        if child.tag not in {"string-array", "array"}:
            continue
        if child.attrib.get("translatable") == "false":
            continue

        array_name = child.attrib.get("name", "").strip()
        if not array_name:
            continue

        for idx, item in enumerate(child.findall("item")):
            raw = "".join(item.itertext()).strip()
            if not raw:
                continue
            # Skip references like @string/foo; those resolve via base string keys.
            if raw.startswith("@string/"):
                continue

            key = f"{array_name}__{idx}"
            out[key] = normalize_android_value(raw)

    return out


def main() -> int:
    parser = argparse.ArgumentParser(description="Export Android strings.xml files into canonical JSON.")
    parser.add_argument(
        "--android-res-dir",
        required=True,
        help="Path to Android res directory (contains values, values-fr, ...).",
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Output JSON path.",
    )
    args = parser.parse_args()

    res_dir = Path(args.android_res_dir).expanduser().resolve()
    output_path = Path(args.output).expanduser().resolve()

    if not res_dir.exists():
        print(f"error: android res dir not found: {res_dir}", file=sys.stderr)
        return 1

    strings: dict[str, dict[str, str]] = {}
    stats: dict[str, int] = {}

    for values_dir_name, locale in LOCALE_DIR_MAP.items():
        locale_entries: dict[str, str] = {}
        for xml_name in ("strings.xml", "arrays.xml"):
            xml_path = res_dir / values_dir_name / xml_name
            if not xml_path.exists():
                continue
            locale_entries.update(parse_strings_xml(xml_path))

        stats[locale] = len(locale_entries)
        for key, value in locale_entries.items():
            strings.setdefault(key, {})[locale] = value

    payload = {
        "version": 1,
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "source": {
            "type": "android_strings_xml",
            "path": str(res_dir),
        },
        "defaultLocale": "en",
        "locales": ["en", "he", "fr", "es", "de"],
        "stats": stats,
        "strings": dict(sorted(strings.items())),
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"wrote {output_path}")
    print(f"keys: {len(strings)}")
    print(f"locale stats: {stats}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
