#!/usr/bin/env python3
import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional


UI_PATTERNS = [
    re.compile(r'(?P<prefix>\bText\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\bButton\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\bSection\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\bToggle\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\bPicker\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\bProgressView\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\bLabel\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\bTextField\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\.navigationTitle\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
    re.compile(r'(?P<prefix>\.alert\s*\(\s*)"(?P<value>(?:[^"\\]|\\.)*)"'),
]


def swift_unescape(value: str) -> str:
    return (
        value.replace(r"\\", "\\")
        .replace(r"\"", '"')
        .replace(r"\n", "\n")
        .replace(r"\t", "\t")
    )


def should_skip_literal(value: str) -> bool:
    stripped = value.strip()
    if not stripped:
        return True
    if stripped.startswith("http://") or stripped.startswith("https://"):
        return True
    if stripped.startswith("com.") or stripped.startswith("ss:///"):
        return True
    if stripped.startswith("Error:") or stripped.startswith("Failed to"):
        return True
    return False


@dataclass
class MatchAction:
    kind: str
    key: Optional[str]
    candidates: List[str]


def build_value_to_keys(catalog_payload: dict) -> dict[str, list[str]]:
    mapping: dict[str, list[str]] = {}
    for key, per_locale in catalog_payload.get("strings", {}).items():
        en_value = per_locale.get("en")
        if not en_value:
            continue
        mapping.setdefault(en_value, []).append(key)
    return mapping


def action_for_literal(value: str, value_to_keys: dict[str, list[str]]) -> MatchAction:
    if should_skip_literal(value):
        return MatchAction(kind="skipped", key=None, candidates=[])

    candidates = value_to_keys.get(value, [])
    if len(candidates) == 1:
        return MatchAction(kind="replace", key=candidates[0], candidates=candidates)
    if len(candidates) > 1:
        return MatchAction(kind="ambiguous", key=None, candidates=sorted(candidates))
    return MatchAction(kind="missing", key=None, candidates=[])


def process_file(path: Path, value_to_keys: dict[str, list[str]], apply: bool) -> dict:
    original = path.read_text(encoding="utf-8")
    content = original
    replacements = []
    unresolved = []
    skipped = []

    for pattern in UI_PATTERNS:
        def repl(match: re.Match) -> str:
            raw_value = match.group("value")
            value = swift_unescape(raw_value)
            line = content.count("\n", 0, match.start()) + 1
            action = action_for_literal(value, value_to_keys)

            if action.kind == "replace":
                replacements.append(
                    {
                        "file": str(path),
                        "line": line,
                        "value": value,
                        "key": action.key,
                    }
                )
                return f'{match.group("prefix")}"{action.key}"'

            if action.kind == "ambiguous":
                unresolved.append(
                    {
                        "file": str(path),
                        "line": line,
                        "value": value,
                        "reason": "ambiguous",
                        "candidates": action.candidates,
                    }
                )
            elif action.kind == "missing":
                unresolved.append(
                    {
                        "file": str(path),
                        "line": line,
                        "value": value,
                        "reason": "missing",
                        "candidates": [],
                    }
                )
            else:
                skipped.append(
                    {
                        "file": str(path),
                        "line": line,
                        "value": value,
                        "reason": "skip-filter",
                    }
                )
            return match.group(0)

        content = pattern.sub(repl, content)

    file_changed = content != original
    if apply and file_changed:
        path.write_text(content, encoding="utf-8")

    return {
        "file": str(path),
        "changed": file_changed,
        "replacements": replacements,
        "unresolved": unresolved,
        "skipped": skipped,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan and aggressively replace Swift UI string literals.")
    parser.add_argument("--catalog", required=True, help="Canonical JSON path.")
    parser.add_argument("--sources-dir", default="Sources", help="Swift source root directory.")
    parser.add_argument("--report", required=True, help="Output report JSON path.")
    parser.add_argument("--apply", action="store_true", help="Write replacements to files.")
    args = parser.parse_args()

    catalog_path = Path(args.catalog).expanduser().resolve()
    sources_dir = Path(args.sources_dir).expanduser().resolve()
    report_path = Path(args.report).expanduser().resolve()

    if not catalog_path.exists():
        print(f"error: catalog not found: {catalog_path}", file=sys.stderr)
        return 1
    if not sources_dir.exists():
        print(f"error: sources dir not found: {sources_dir}", file=sys.stderr)
        return 1

    payload = json.loads(catalog_path.read_text(encoding="utf-8"))
    value_to_keys = build_value_to_keys(payload)

    files = sorted(sources_dir.rglob("*.swift"))
    file_results = []
    total_replacements = 0
    total_unresolved = 0
    total_skipped = 0
    changed_files = 0

    for path in files:
        result = process_file(path, value_to_keys, apply=args.apply)
        file_results.append(result)
        if result["changed"]:
            changed_files += 1
        total_replacements += len(result["replacements"])
        total_unresolved += len(result["unresolved"])
        total_skipped += len(result["skipped"])

    report = {
        "mode": "apply" if args.apply else "dry-run",
        "catalog": str(catalog_path),
        "sourcesDir": str(sources_dir),
        "summary": {
            "filesScanned": len(files),
            "filesChanged": changed_files,
            "replacements": total_replacements,
            "unresolved": total_unresolved,
            "skipped": total_skipped,
        },
        "files": file_results,
    }

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"wrote {report_path}")
    print(json.dumps(report["summary"], ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
