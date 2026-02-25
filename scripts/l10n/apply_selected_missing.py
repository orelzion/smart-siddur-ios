#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path
from typing import Dict, List, Optional


UI_HINTS = [
    "Text(",
    "Button(",
    "Section(",
    "Toggle(",
    "Picker(",
    "ProgressView(",
    "Label(",
    "TextField(",
    ".navigationTitle(",
    ".alert(",
]


def is_ui_line(line: str) -> bool:
    return any(hint in line for hint in UI_HINTS)


def first_selected_key(item: dict) -> Optional[str]:
    for suggestion in item.get("androidSuggestions") or []:
        if str(suggestion.get("use", "")).strip().lower() == "yes":
            key = suggestion.get("key")
            if key:
                return str(key)
    return None


def apply_item(lines: List[str], item: dict, key: str) -> bool:
    value = item.get("value", "")
    if not value:
        return False

    line_idx = int(item.get("line", 0)) - 1
    literal = f'"{value}"'
    replacement = f'"{key}"'

    # Preferred: exact line + UI hint.
    if 0 <= line_idx < len(lines):
        line = lines[line_idx]
        if is_ui_line(line) and literal in line:
            lines[line_idx] = line.replace(literal, replacement, 1)
            return True

    # Fallback: nearest UI line with same literal in +/- 3 lines.
    for delta in (1, -1, 2, -2, 3, -3):
        i = line_idx + delta
        if i < 0 or i >= len(lines):
            continue
        line = lines[i]
        if is_ui_line(line) and literal in line:
            lines[i] = line.replace(literal, replacement, 1)
            return True

    # Last resort: any UI line in file with the literal.
    for i, line in enumerate(lines):
        if is_ui_line(line) and literal in line:
            lines[i] = line.replace(literal, replacement, 1)
            return True

    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply selected missing-string suggestions (use: yes).")
    parser.add_argument("--input", required=True, help="Path to missing-strings.apply.json")
    parser.add_argument("--report", required=True, help="Output apply report JSON")
    parser.add_argument("--apply", action="store_true", help="Write changes to files")
    args = parser.parse_args()

    input_path = Path(args.input).expanduser().resolve()
    report_path = Path(args.report).expanduser().resolve()

    if not input_path.exists():
        print(f"error: input not found: {input_path}", file=sys.stderr)
        return 1

    payload = json.loads(input_path.read_text(encoding="utf-8"))
    items = payload.get("items") or []

    selected = []
    for item in items:
        key = first_selected_key(item)
        if key:
            selected.append({**item, "selectedKey": key})

    by_file: Dict[str, List[dict]] = {}
    for item in selected:
        by_file.setdefault(item["file"], []).append(item)

    applied = []
    failed = []
    files_changed = 0

    for file_path, file_items in by_file.items():
        path = Path(file_path)
        if not path.exists():
            for item in file_items:
                failed.append({**item, "error": "file-not-found"})
            continue

        original = path.read_text(encoding="utf-8")
        lines = original.splitlines(keepends=True)

        file_applied_count = 0
        for item in sorted(file_items, key=lambda x: int(x.get("line", 0))):
            ok = apply_item(lines, item, item["selectedKey"])
            if ok:
                file_applied_count += 1
                applied.append(
                    {
                        "file": item["file"],
                        "line": item["line"],
                        "value": item["value"],
                        "key": item["selectedKey"],
                    }
                )
            else:
                failed.append({**item, "error": "literal-not-found"})

        updated = "".join(lines)
        if args.apply and updated != original:
            path.write_text(updated, encoding="utf-8")
            files_changed += 1

    out = {
        "mode": "apply" if args.apply else "dry-run",
        "summary": {
            "selected": len(selected),
            "applied": len(applied),
            "failed": len(failed),
            "filesChanged": files_changed,
        },
        "applied": applied,
        "failed": failed,
    }

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"wrote {report_path}")
    print(json.dumps(out["summary"], ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
