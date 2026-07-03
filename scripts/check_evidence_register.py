#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


DEFAULT_LEVELS = {"A", "B", "C", "L4"}
FILE_EXTENSIONS = (".lean", ".md", ".json", ".py", ".toml", ".yaml", ".yml")
ID_PATTERN = re.compile(r"^\|\s*`(E-\d+)`\s*\|", re.MULTILINE)
SYMBOL_PATTERN = re.compile(r"^[A-Za-z_][A-Za-z0-9_']*$")


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError("JSON registry root must be an object.")
    return data


def extract_md_ids(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    return ID_PATTERN.findall(text)


def normalize_ref(raw: str) -> str:
    ref = raw.strip().strip("`")
    # Entferne optionale Annotationen wie "ARCHITECTURE.md (L4-Vertrag)".
    if " (" in ref and ref.endswith(")"):
        ref = ref.split(" (", 1)[0].strip()
    return ref


def looks_like_file_ref(raw: str) -> bool:
    ref = normalize_ref(raw)
    if ref.startswith("E-"):
        return False
    if "/" in ref:
        return True
    return ref.endswith(FILE_EXTENSIONS)


def resolve_ref_path(ref: str, root: Path, source_path: Path | None) -> Path | None:
    normalized = normalize_ref(ref)
    candidates: list[Path] = [root / normalized]
    # Wenn kein Pfadseparator vorhanden ist, pruefe auch relativ zur Source-Datei.
    if "/" not in normalized and source_path is not None:
        candidates.append(source_path.parent / normalized)
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def infer_symbol(entry: dict[str, Any]) -> str | None:
    symbol = entry.get("symbol")
    if isinstance(symbol, str) and SYMBOL_PATTERN.match(symbol):
        return symbol
    title = entry.get("title")
    if isinstance(title, str) and SYMBOL_PATTERN.match(title):
        return title
    return None


def validate(
    data: dict[str, Any],
    md_ids: list[str],
    root: Path,
    check_symbol_text: bool,
) -> list[str]:
    issues: list[str] = []
    entries = data.get("entries")
    if not isinstance(entries, list):
        return ["JSON registry must contain an entries list."]

    levels_obj = data.get("levels")
    if isinstance(levels_obj, dict):
        known_levels = set(levels_obj.keys())
    else:
        known_levels = set(DEFAULT_LEVELS)

    json_ids: list[str] = []
    for entry in entries:
        if not isinstance(entry, dict):
            issues.append(f"Invalid entry type (expected object): {entry!r}")
            continue
        entry_id = entry.get("id")
        if not isinstance(entry_id, str):
            issues.append(f"Entry without string id: {entry!r}")
            continue
        json_ids.append(entry_id)

    if len(json_ids) != len(set(json_ids)):
        issues.append("Duplicate IDs in EVIDENCE_REGISTER.json")
    if len(md_ids) != len(set(md_ids)):
        issues.append("Duplicate IDs in EVIDENCE_REGISTER.md")

    json_id_set = set(json_ids)
    md_id_set = set(md_ids)
    if json_id_set != md_id_set:
        only_json = sorted(json_id_set - md_id_set)
        only_md = sorted(md_id_set - json_id_set)
        if only_json:
            issues.append(f"IDs only in JSON: {only_json}")
        if only_md:
            issues.append(f"IDs only in Markdown: {only_md}")

    file_cache: dict[Path, str] = {}

    for entry in entries:
        if not isinstance(entry, dict):
            continue
        entry_id = str(entry.get("id", "<missing-id>"))
        level = entry.get("level")
        if not isinstance(level, str) or level not in known_levels:
            issues.append(
                f"{entry_id}: unknown evidence level {level!r} (known: {sorted(known_levels)})"
            )

        refs: list[str] = []
        source = entry.get("source")
        if isinstance(source, str) and source.strip():
            refs.append(source)

        for field in ("depends_on", "supports"):
            values = entry.get(field, [])
            if not isinstance(values, list):
                continue
            refs.extend(v for v in values if isinstance(v, str))

        source_path: Path | None = None
        if isinstance(source, str):
            normalized_source = normalize_ref(source)
            source_path = root / normalized_source
            if not source_path.exists():
                issues.append(f"{entry_id}: source file missing: {normalized_source}")

        for ref in refs:
            if not looks_like_file_ref(ref):
                continue
            normalized = normalize_ref(ref)
            ref_path = resolve_ref_path(ref, root=root, source_path=source_path)
            if ref_path is None:
                issues.append(f"{entry_id}: referenced file missing: {normalized}")

        if check_symbol_text and source_path is not None and source_path.exists():
            symbol = infer_symbol(entry)
            if symbol is not None:
                if source_path not in file_cache:
                    try:
                        file_cache[source_path] = source_path.read_text(encoding="utf-8")
                    except UnicodeDecodeError:
                        file_cache[source_path] = ""
                if symbol not in file_cache[source_path]:
                    rel = source_path.relative_to(root)
                    issues.append(
                        f"{entry_id}: symbol {symbol!r} not found textually in {rel}"
                    )

    return issues


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Minimaler Governance-Audit fuer Evidence-Register."
    )
    parser.add_argument(
        "--json",
        type=Path,
        default=Path("EVIDENCE_REGISTER.json"),
        help="Pfad zu EVIDENCE_REGISTER.json",
    )
    parser.add_argument(
        "--md",
        type=Path,
        default=Path("EVIDENCE_REGISTER.md"),
        help="Pfad zu EVIDENCE_REGISTER.md",
    )
    parser.add_argument(
        "--no-symbol-check",
        action="store_true",
        help="Optionalen Textcheck der Symbolnamen deaktivieren.",
    )
    args = parser.parse_args()

    root = Path.cwd()
    data = load_json(args.json)
    md_ids = extract_md_ids(args.md)
    issues = validate(
        data=data,
        md_ids=md_ids,
        root=root,
        check_symbol_text=not args.no_symbol_check,
    )

    print("Evidence Register Audit")
    print(f"- json: {args.json}")
    print(f"- md: {args.md}")
    print(f"- md_ids: {len(md_ids)}")
    print(f"- issues: {len(issues)}")
    if issues:
        print("Fehler:")
        for issue in issues:
            print(f"  - {issue}")
        return 1
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
