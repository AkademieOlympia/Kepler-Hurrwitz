#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.kepler_eabc_atlas import (
    annotate_kepler_time_bridge_record,
    export_floquet_alignment_markdown,
    export_floquet_annotation_json,
    floquet_channel_table,
    summarize_annotated_delta_m,
)
from kepler_hurwitz.kepler_time_bridge import run_kepler_time_bridge_scenarios


def main() -> None:
    print("--- #Energiedoku: Kepler-EABC Floquet annotation [B/C] ---")
    print("Formal lift table (Lean mirror `floquetStepChannel`):")
    for row in floquet_channel_table():
        print(
            f"  step={row['step']} channel={row['channel']} "
            f"chi_phase={row['chi_phase']} lift_sheet={row['lift_sheet']}"
        )

    records = run_kepler_time_bridge_scenarios(steps=500, tail_length=64)
    export_dir = ROOT / "docs" / "energiedoku_exports"
    json_path = export_dir / "kepler_eabc_floquet_annotation.json"
    markdown_path = export_dir / "e033_floquet_channel_alignment.md"

    export = export_floquet_annotation_json(records, json_path)
    export_floquet_alignment_markdown(records, markdown_path)

    baseline = export.scenarios[0]["alignment_summary"]
    print()
    print(f"status: {export.status}")
    print(f"alignment_status: {export.alignment_status}")
    print(f"claim: {export.claim}")
    print(f"not_claimed: {export.not_claimed}")
    print(f"alignment_not_claimed: {export.alignment_not_claimed}")
    print(f"cycle: {' -> '.join(export.cycle)}")
    print(f"alignment_summary status: {baseline['status']}")
    print(
        "baseline max_lift_sheet_abs_difference: "
        f"{baseline['max_lift_sheet_abs_difference']}"
    )
    print(f"baseline max_abs_dual_sum: {baseline['max_abs_dual_sum']}")
    print(f"baseline all_orientation_flips: {baseline['all_orientation_flips']}")
    for record in records:
        alignment = summarize_annotated_delta_m(annotate_kepler_time_bridge_record(record))
        print(
            f"{record.control_name} max_lift_sheet_abs_difference="
            f"{alignment['max_lift_sheet_abs_difference']} "
            f"max_abs_dual_sum={alignment['max_abs_dual_sum']} "
            f"all_orientation_flips={alignment['all_orientation_flips']}"
        )
    print(f"json export: {json_path}")
    print(f"markdown report: {markdown_path}")


if __name__ == "__main__":
    main()
