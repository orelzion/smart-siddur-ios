#!/usr/bin/env python3
import argparse
import difflib
import json
import re
import sys
from pathlib import Path


def slugify(value: str) -> str:
    s = value.strip().lower()
    s = re.sub(r"[^a-z0-9]+", "_", s)
    s = re.sub(r"_+", "_", s).strip("_")
    return s[:80] or "todo_key"


def normalize_for_match(value: str) -> str:
    s = value.lower()
    # Ignore Swift interpolation placeholders for matching.
    s = re.sub(r"\\\([^)]+\)", "{}", s)
    s = re.sub(r"[^a-z0-9{}]+", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def load_catalog(catalog_path: Path) -> list[dict]:
    payload = json.loads(catalog_path.read_text(encoding="utf-8"))
    out = []
    for key, per_locale in payload.get("strings", {}).items():
        en = per_locale.get("en")
        if not en:
            continue
        norm = normalize_for_match(en)
        if not norm:
            continue
        out.append(
            {
                "key": key,
                "en": en,
                "norm": norm,
                "key_tokens": [t for t in key.lower().split("_") if t],
            }
        )
    return out


def suggest_from_catalog(value: str, catalog_entries: list[dict], limit: int = 5) -> list[dict]:
    suggestions = []
    norm_value = normalize_for_match(value)
    if not norm_value:
        return suggestions

    words = [w for w in norm_value.split(" ") if w and w != "{}"]
    if len(norm_value) <= 4 or len(words) <= 1:
        threshold = 0.9
    else:
        threshold = 0.65

    for entry in catalog_entries:
        score = difflib.SequenceMatcher(None, norm_value, entry["norm"]).ratio()
        # Conservative boost only for meaningful phrase containment.
        if (
            len(norm_value) >= 6
            and len(entry["norm"]) >= 6
            and len(words) >= 2
            and (norm_value in entry["norm"] or entry["norm"] in norm_value)
        ):
            score = max(score, 0.92)
        if score < threshold:
            continue
        suggestions.append(
            {
                "key": entry["key"],
                "en": entry["en"],
                "score": round(score, 3),
            }
        )

    suggestions.sort(key=lambda x: (-x["score"], x["key"]))
    return suggestions[:limit]


def suggest_from_keys(suggested_key: str, catalog_entries: list[dict], limit: int = 5) -> list[dict]:
    if not suggested_key:
        return []

    results = []
    for entry in catalog_entries:
        key = entry["key"]

        if key == suggested_key:
            score = 1.0
        elif len(suggested_key) >= 5 and (suggested_key in key or key in suggested_key):
            score = 0.9
        else:
            continue

        if score < 0.9:
            continue
        results.append(
            {
                "key": key,
                "en": entry["en"],
                "score": round(score, 3),
            }
        )

    results.sort(key=lambda x: (-x["score"], x["key"]))
    return results[:limit]


def main() -> int:
    parser = argparse.ArgumentParser(description="Produce condensed unresolved localization report.")
    parser.add_argument("--input", required=True, help="scan_replace report JSON.")
    parser.add_argument("--output", required=True, help="missing strings report JSON.")
    parser.add_argument(
        "--catalog",
        help="Canonical JSON catalog path for Android-based suggestions.",
    )
    args = parser.parse_args()

    input_path = Path(args.input).expanduser().resolve()
    output_path = Path(args.output).expanduser().resolve()
    catalog_entries = []

    if not input_path.exists():
        print(f"error: input report not found: {input_path}", file=sys.stderr)
        return 1
    if args.catalog:
        catalog_path = Path(args.catalog).expanduser().resolve()
        if not catalog_path.exists():
            print(f"error: catalog not found: {catalog_path}", file=sys.stderr)
            return 1
        catalog_entries = load_catalog(catalog_path)

    scan_report = json.loads(input_path.read_text(encoding="utf-8"))

    unresolved = []
    for file_result in scan_report.get("files", []):
        for item in file_result.get("unresolved", []):
            unresolved.append(
                {
                    "file": item["file"],
                    "line": item["line"],
                    "value": item["value"],
                    "reason": item["reason"],
                    "candidateKeys": item.get("candidates", []),
                    "suggestedKey": slugify(item["value"]),
                }
            )

    for item in unresolved:
        by_value = suggest_from_catalog(item["value"], catalog_entries, limit=5)
        by_key = suggest_from_keys(item["suggestedKey"], catalog_entries, limit=5)

        merged = []
        seen = set()
        for suggestion in by_value + by_key:
            if suggestion["key"] in seen:
                continue
            seen.add(suggestion["key"])
            merged.append(suggestion)

        item["androidSuggestions"] = merged[:5]

    unresolved.sort(key=lambda x: (x["file"], x["line"], x["value"]))

    output = {
        "summary": {
            "unresolvedCount": len(unresolved),
            "withAndroidSuggestions": sum(1 for item in unresolved if item["androidSuggestions"]),
        },
        "items": unresolved,
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"wrote {output_path}")
    print(json.dumps(output["summary"], ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
