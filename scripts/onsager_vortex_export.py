#!/usr/bin/env python3
"""
Export Onsager vortex circulation diagnostics.

Status:
    [B] experimental diagnostic.

This script does not claim physical vortex detection.
It exports combinatorial circulation records for Dumas/EABC
Gap-Rotor loops over prime quadruplets.

Reference bridge:
    ORQ-089 / E-089
    docs/theory/onsager_quantization_bridge.md

Title (governance):
    onsager_vortex_circulation = Dumas/EABC circulation diagnostic, not physics claim.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
import time
from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterator

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.dumas_cone_orbit import ROTOR_GAP_CYCLE  # noqa: E402
from kepler_hurwitz.onsager_vortex_diagnostics import (  # noqa: E402
    MODEL_CANONICAL,
    ONSAGER_VORTEX_CSV_FIELDS,
    ONSAGER_VORTEX_TAG,
    OnsagerVortexExportRow,
    build_circulation_record,
    build_export_rows_for_quadruplet,
    export_rows_to_csv,
    gap_rotor_loop,
    generate_prime_quadruplets_sieve,
    parse_nullmodel_spec,
)
from kepler_hurwitz.primvierling import Primvierling, is_prime  # noqa: E402

PrimeQuadruplet = Primvierling

DEFAULT_LIMIT = 1_000_000
DEFAULT_OUT = ROOT / "docs" / "exports" / "onsager_vortex_circulation_upto_1000000.csv"
DEFAULT_SUMMARY = ROOT / "docs" / "exports" / "onsager_vortex_circulation_upto_1000000.summary.json"
DEFAULT_EXTENDED_OUT = (
    ROOT / "docs" / "exports" / "onsager_vortex_circulation_extended_upto_1000000.csv"
)
CANONICAL_ROTOR_GAP_CYCLE = ";".join(f"({a},{b})" for a, b in ROTOR_GAP_CYCLE)

CIRCULATION_CSV_FIELDS: tuple[str, ...] = (
    "p",
    "p_plus_2",
    "p_plus_6",
    "p_plus_8",
    "vortex_winding",
    "trivial_winding",
    "phase_closure_ok",
    "ceab_closure_ok",
    "encircles_defect",
    "pop_threshold_steps",
    "rotor_steps",
    "rotor_gap_cycle",
    "status",
)


def prime_quadruplets_upto(limit: int) -> Iterator[PrimeQuadruplet]:
    """Yield prime quadruplets ``(p, p+2, p+6, p+8)`` with ``p+8 <= limit``.

    Uses the fast sieve for large bounds; trial division for tiny ranges.
    """
    if limit < 11:
        return
    max_p = limit - 8
    if max_p < 3:
        return
    if max_p >= 1000:
        yield from generate_prime_quadruplets_sieve(3, max_p)
        return
    for p in range(3, max_p + 1, 2):
        candidate = (p, p + 2, p + 6, p + 8)
        if all(is_prime(value) for value in candidate):
            yield candidate


def rotor_gap_cycle_string(v: Primvierling, *, cycles: int = 1) -> str:
    """Format observed Gap-Rotor gap pairs along one host cycle."""
    steps = gap_rotor_loop(v, cycles=cycles)
    cycle_steps = steps[:4 * cycles]
    if not cycle_steps:
        return CANONICAL_ROTOR_GAP_CYCLE
    return ";".join(f"({step.gap_pair[0]},{step.gap_pair[1]})" for step in cycle_steps)


def normalize_record(v: PrimeQuadruplet, *, cycles: int = 1) -> dict[str, object]:
    """Build one CSV-ready Onsager vortex circulation record."""
    record = build_circulation_record(v, cycles=cycles)
    vortex_steps = gap_rotor_loop(v, cycles=cycles)
    return {
        "p": v[0],
        "p_plus_2": v[1],
        "p_plus_6": v[2],
        "p_plus_8": v[3],
        "vortex_winding": record.vortex_winding,
        "trivial_winding": record.trivial_winding,
        "phase_closure_ok": record.phase_closure_ok,
        "ceab_closure_ok": record.ceab_phase_closure_ok,
        "encircles_defect": record.encircles_defect,
        "pop_threshold_steps": record.pop_threshold_steps,
        "rotor_steps": len(vortex_steps),
        "rotor_gap_cycle": rotor_gap_cycle_string(v, cycles=cycles),
        "status": "B",
    }


@dataclass(frozen=True)
class CirculationExportSummary:
    limit: int
    records: int
    cycles: int
    all_phase_closed: bool
    all_vortex_winding_one: bool
    all_trivial_winding_zero: bool
    all_encircles_defect: bool
    all_pop_threshold_four: bool
    elapsed_seconds: float
    status: str = "B"
    claim: str = "combinatorial circulation diagnostic only"
    tag: str = ONSAGER_VORTEX_TAG


def build_circulation_summary(
    rows: list[dict[str, object]],
    *,
    limit: int,
    cycles: int,
    elapsed_seconds: float,
) -> CirculationExportSummary:
    return CirculationExportSummary(
        limit=limit,
        records=len(rows),
        cycles=cycles,
        all_phase_closed=all(bool(row["phase_closure_ok"]) for row in rows),
        all_vortex_winding_one=all(row["vortex_winding"] == 1 for row in rows),
        all_trivial_winding_zero=all(row["trivial_winding"] == 0 for row in rows),
        all_encircles_defect=all(bool(row["encircles_defect"]) for row in rows),
        all_pop_threshold_four=all(row["pop_threshold_steps"] == 4 for row in rows),
        elapsed_seconds=elapsed_seconds,
    )


def export_records(
    limit: int,
    output_path: Path,
    *,
    cycles: int = 1,
    summary_path: Path | None = None,
) -> int:
    """Export circulation records and return number of rows written."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    t0 = time.perf_counter()
    rows = [normalize_record(v, cycles=cycles) for v in prime_quadruplets_upto(limit)]
    with output_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(CIRCULATION_CSV_FIELDS))
        writer.writeheader()
        writer.writerows(rows)
    elapsed = time.perf_counter() - t0
    if summary_path is not None:
        summary = build_circulation_summary(rows, limit=limit, cycles=cycles, elapsed_seconds=elapsed)
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        summary_path.write_text(json.dumps(asdict(summary), indent=2) + "\n", encoding="utf-8")
    return len(rows)


@dataclass(frozen=True)
class ExtendedExportSummary:
    limit: int
    quadruplet_count: int
    row_count: int
    cycles: int
    include_nullmodels: tuple[str, ...]
    elapsed_seconds: float
    nullmodel_contrast_count: int
    contrast_by_model_type: dict[str, int]
    tag: str = ONSAGER_VORTEX_TAG


def export_extended_records(
    limit: int,
    output_path: Path,
    *,
    cycles: int = 1,
    include_nullmodels: frozenset[str] = frozenset(),
) -> ExtendedExportSummary:
    """Export extended rows with nullmodel grouping (legacy energiedoku schema)."""
    max_p = limit - 8
    t0 = time.perf_counter()
    quadruplets = generate_prime_quadruplets_sieve(3, max_p)
    rows: list[OnsagerVortexExportRow] = []
    for v in quadruplets:
        rows.extend(
            build_export_rows_for_quadruplet(
                v,
                include_nullmodels=include_nullmodels,
                cycles=cycles,
            )
        )
    export_rows_to_csv(rows, output_path)
    contrast_counter = Counter(
        row.model_type for row in rows if row.topological_contrast_vs_canonical
    )
    return ExtendedExportSummary(
        limit=limit,
        quadruplet_count=len(quadruplets),
        row_count=len(rows),
        cycles=cycles,
        include_nullmodels=tuple(sorted(include_nullmodels)),
        elapsed_seconds=time.perf_counter() - t0,
        nullmodel_contrast_count=sum(1 for row in rows if row.topological_contrast_vs_canonical),
        contrast_by_model_type=dict(contrast_counter),
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export Onsager vortex circulation diagnostics (Dumas/EABC, not physics).",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=DEFAULT_LIMIT,
        help="Upper bound for p+8. Default: 1,000,000.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUT,
        help="Output CSV path.",
    )
    parser.add_argument(
        "--summary-json",
        type=Path,
        default=DEFAULT_SUMMARY,
        help="Governance summary JSON path.",
    )
    parser.add_argument(
        "--no-summary",
        action="store_true",
        help="Skip summary JSON export.",
    )
    parser.add_argument(
        "--cycles",
        type=int,
        default=1,
        help="Gap-Rotor full cycles per quadruplet (default: 1).",
    )
    parser.add_argument(
        "--include-nullmodels",
        type=str,
        default="",
        help="Optional extended export: ceab, shuffle (writes separate extended CSV).",
    )
    parser.add_argument(
        "--extended-csv",
        type=Path,
        default=DEFAULT_EXTENDED_OUT,
        help="Extended CSV path when --include-nullmodels is set.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.cycles < 1:
        raise SystemExit("--cycles must be >= 1")
    if args.limit < 11:
        raise SystemExit("--limit must be >= 11")

    summary_path = None if args.no_summary else args.summary_json
    count = export_records(
        limit=args.limit,
        output_path=args.output,
        cycles=args.cycles,
        summary_path=summary_path,
    )

    print(f"Onsager vortex circulation export [{ONSAGER_VORTEX_TAG}]")
    print("  Claim: combinatorial Dumas/EABC diagnostic — not physical vortex detection")
    print(f"  Limit (p+8):    {args.limit}")
    print(f"  Records:        {count}")
    print(f"  Gap-Rotor cycles per row: {args.cycles}")
    print(f"  Output CSV:     {args.output}")
    if summary_path is not None:
        print(f"  Summary JSON:   {summary_path}")

    if args.include_nullmodels.strip():
        try:
            nullmodels = parse_nullmodel_spec(args.include_nullmodels)
        except ValueError as exc:
            raise SystemExit(str(exc)) from exc
        extended = export_extended_records(
            limit=args.limit,
            output_path=args.extended_csv,
            cycles=args.cycles,
            include_nullmodels=nullmodels,
        )
        print(f"\nExtended nullmodel CSV: {args.extended_csv} ({extended.row_count} rows)")
        print(f"  Nullmodels:     {', '.join(extended.include_nullmodels)}")
        print(f"  Contrasts:      {extended.nullmodel_contrast_count}")
        for model_type, contrast_count in sorted(extended.contrast_by_model_type.items()):
            if model_type != MODEL_CANONICAL:
                print(f"    {model_type}: {contrast_count}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
