#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path
from typing import Any


VALID_A_CLASSES = {"A-T", "A-I", "A-D"}
VALID_STABILITY = {"stable", "experimental", "deprecated", "superseded"}


def load_registry(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError("Registry root must be an object")
    entries = data.get("entries")
    if not isinstance(entries, list):
        raise ValueError("Registry must contain an entries list")
    return data


def validate_registry(data: dict[str, Any]) -> list[str]:
    issues: list[str] = []
    entries = data["entries"]

    ids: list[str] = []
    for entry in entries:
        entry_id = entry.get("id")
        if not isinstance(entry_id, str):
            issues.append(f"Entry without valid string id: {entry!r}")
            continue
        ids.append(entry_id)
    id_set = set(ids)
    if len(ids) != len(id_set):
        issues.append("Duplicate evidence IDs detected")

    for entry in entries:
        entry_id = str(entry.get("id", "<missing-id>"))
        level = entry.get("level")
        aclass = entry.get("aclass")

        if level == "A":
            if aclass not in VALID_A_CLASSES:
                issues.append(f"{entry_id}: invalid aclass for level A ({aclass!r})")
        else:
            if aclass not in (None, "", "-"):
                issues.append(f"{entry_id}: non-A entry must not carry aclass ({aclass!r})")

        stability = entry.get("stability")
        if stability not in VALID_STABILITY:
            issues.append(f"{entry_id}: invalid stability ({stability!r})")

        if level == "B":
            if not entry.get("scope"):
                issues.append(f"{entry_id}: B-entry missing scope")
            if not entry.get("metric_or_result"):
                issues.append(f"{entry_id}: B-entry missing metric_or_result")

        for field in ("depends_on", "supports"):
            refs = entry.get(field, [])
            if not isinstance(refs, list):
                issues.append(f"{entry_id}: {field} must be a list")
                continue
            for ref in refs:
                if isinstance(ref, str) and ref.startswith("E-") and ref not in id_set:
                    issues.append(f"{entry_id}: references missing {field} id {ref}")

    return issues


def _node_key(label: str) -> str:
    return "N_" + re.sub(r"[^A-Za-z0-9_]", "_", label)


def write_graphs(data: dict[str, Any], out_dir: Path) -> tuple[Path, Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    entries = data["entries"]
    ids = [entry["id"] for entry in entries if isinstance(entry.get("id"), str)]
    id_set = set(ids)

    node_labels: set[str] = set(ids)
    edges: list[tuple[str, str, str]] = []
    for entry in entries:
        src = entry["id"]
        for field in ("depends_on", "supports"):
            for ref in entry.get(field, []):
                if not isinstance(ref, str):
                    continue
                dst = ref
                node_labels.add(dst)
                edges.append((src, dst, field))

    dot_path = out_dir / "evidence_graph.dot"
    mmd_path = out_dir / "evidence_graph.mmd"

    # DOT
    dot_lines = ["digraph EvidenceGraph {", "  rankdir=LR;"]
    for label in sorted(node_labels):
        key = _node_key(label)
        shape = "box" if label in id_set else "ellipse"
        dot_lines.append(f'  {key} [label="{label}", shape={shape}];')
    for src, dst, rel in edges:
        dot_lines.append(
            f'  {_node_key(src)} -> {_node_key(dst)} [label="{rel}"];'
        )
    dot_lines.append("}")
    dot_path.write_text("\n".join(dot_lines) + "\n", encoding="utf-8")

    # Mermaid
    mmd_lines = ["graph TD"]
    for label in sorted(node_labels):
        key = _node_key(label)
        mmd_lines.append(f'  {key}["{label}"]')
    for src, dst, rel in edges:
        mmd_lines.append(f"  {_node_key(src)} -->|{rel}| {_node_key(dst)}")
    mmd_path.write_text("\n".join(mmd_lines) + "\n", encoding="utf-8")

    return dot_path, mmd_path


def print_report(data: dict[str, Any], issues: list[str], out_dir: Path) -> None:
    entries = data["entries"]
    by_level = Counter(entry.get("level", "<missing>") for entry in entries)
    by_stability = Counter(entry.get("stability", "<missing>") for entry in entries)

    missing_depends: list[str] = []
    missing_supports: list[str] = []
    id_set = {entry.get("id") for entry in entries}
    for entry in entries:
        entry_id = entry.get("id", "<missing-id>")
        for ref in entry.get("depends_on", []):
            if isinstance(ref, str) and ref.startswith("E-") and ref not in id_set:
                missing_depends.append(f"{entry_id}->{ref}")
        for ref in entry.get("supports", []):
            if isinstance(ref, str) and ref.startswith("E-") and ref not in id_set:
                missing_supports.append(f"{entry_id}->{ref}")

    print("Evidence Registry Report")
    print(f"- entries_total: {len(entries)}")
    print(f"- by_level: {dict(by_level)}")
    print(f"- by_stability: {dict(by_stability)}")
    print(f"- orphan_depends_on: {missing_depends}")
    print(f"- orphan_supports: {missing_supports}")
    print(f"- issues: {len(issues)}")
    print(f"- graph_dir: {out_dir}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate and graph evidence registry.")
    parser.add_argument(
        "--registry",
        type=Path,
        default=Path("EVIDENCE_REGISTER.json"),
        help="Path to JSON evidence registry.",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=Path("results"),
        help="Directory for generated graph files.",
    )
    args = parser.parse_args()

    data = load_registry(args.registry)
    issues = validate_registry(data)
    dot_path, mmd_path = write_graphs(data, args.out_dir)
    print_report(data, issues, args.out_dir)
    print(f"- dot: {dot_path}")
    print(f"- mermaid: {mmd_path}")

    if issues:
        print("Validation errors:")
        for issue in issues:
            print(f"  - {issue}")
        return 1
    print("Registry validation: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
