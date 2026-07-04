"""Export greedy rising overlap statistics and transition trace."""

from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_SUMMARY_OUT = ROOT / "docs" / "energiedoku_exports" / "eabc_rising_overlap_summary_2000.json"
DEFAULT_TRACE_OUT = ROOT / "docs" / "energiedoku_exports" / "eabc_rising_overlap_trace_2000.csv"
DEFAULT_PRIME_COUNT = 2000
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_rising_collection import (  # noqa: E402
    collect_eabc_rising_with_trace,
    summarize_rising_overlap_chain,
)

TRACE_FIELDS = [
    "step_index",
    "prime",
    "size_before",
    "size_after",
    "overlap_size",
    "collection_before",
    "collection_after",
    "recorded_quadruple_index",
    "build_index",
]


def export_rising_overlap_summary_json(
    output_path: str | Path,
    prime_count: int = DEFAULT_PRIME_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    summary = summarize_rising_overlap_chain(prime_count)
    with destination.open("w", encoding="utf-8") as handle:
        json.dump(summary, handle, indent=2, sort_keys=True)
        handle.write("\n")
    return destination


def export_rising_overlap_trace_csv(
    output_path: str | Path,
    prime_count: int = DEFAULT_PRIME_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    _quadruples, steps, _stream = collect_eabc_rising_with_trace(prime_count)
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=TRACE_FIELDS)
        writer.writeheader()
        for step in steps:
            writer.writerow(step.as_csv_row())
    return destination


def main() -> None:
    summary_path = export_rising_overlap_summary_json(DEFAULT_SUMMARY_OUT, DEFAULT_PRIME_COUNT)
    trace_path = export_rising_overlap_trace_csv(DEFAULT_TRACE_OUT, DEFAULT_PRIME_COUNT)
    summary = summarize_rising_overlap_chain(DEFAULT_PRIME_COUNT)
    print(f"Wrote {summary_path}")
    print(f"Wrote {trace_path} ({summary['transition_step_count']} transition rows)")
    print(json.dumps(summary, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
