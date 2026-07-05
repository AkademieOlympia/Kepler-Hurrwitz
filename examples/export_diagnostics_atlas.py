"""
Referenz-CSV fuer den Diagnostics Parameter-Atlas.

Governance (Diagnose only — keine Beweisclaims):
  - Werte sind reine Mess-/Diagnosegroessen; keine Identitaets- oder Theorem-Behauptungen.
  - norm_signature_defect misst L1-Abstand H(N) vs H(P); beweist keine Dedekind-Bruecke.
  - net_descent_margin > 0 ist lokale Collatz-Witness-Diagnose [C], kein globaler Beweis.

Siehe docs/diagnostics_parameter_atlas.md (Abschnitt Referenzexport).
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "docs" / "energiedoku_exports" / "diagnostics_atlas_reference.csv"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.diagnostics import (  # noqa: E402
    collatz_iterate,
    collatz_net_descent_diagnostics,
    distill_from_nat,
    distill_primvierling,
    net_descent_margin,
    prime_grid_compression_from_nat,
)
from kepler_hurwitz.primvierling import Primvierling, generate_prime_quadruplets  # noqa: E402

DEFAULT_PRIMVIERLING_COUNT = 5
DEFAULT_EABC_NATURALS = (6, 12, 30, 60, 210)
DEFAULT_COLLATZ_CASES = ((27, 3), (15, 3))

PRIMVIERLING_COLUMNS: tuple[str, ...] = (
    "p",
    "quadruple",
    "product",
    "norm",
    "product_signature",
    "norm_signature",
    "norm_signature_defect",
    "projection_loss",
    "channel_entropy_norm",
    "prime_grid_compression_norm",
)

COLLATZ_COLUMNS: tuple[str, ...] = (
    "n",
    "t_good",
    "m_good",
    "local_shrink_time",
    "descended_value",
    "net_descent_margin",
    "bad_run_cost",
    "shrink_efficiency",
)

CSV_FIELDNAMES: tuple[str, ...] = ("source_kind",) + PRIMVIERLING_COLUMNS + COLLATZ_COLUMNS


def format_tuple(values: tuple[int, ...]) -> str:
    inner = ", ".join(str(value) for value in values)
    return f"({inner})"


def _empty_row(source_kind: str) -> dict[str, Any]:
    return {"source_kind": source_kind, **{column: "" for column in PRIMVIERLING_COLUMNS + COLLATZ_COLUMNS}}


def primvierling_record(v: Primvierling) -> dict[str, Any]:
    record = distill_primvierling(v)
    row = _empty_row("primvierling")
    row.update(
        {
            "p": record.p,
            "quadruple": format_tuple(record.quadruple),
            "product": record.product,
            "norm": record.norm,
            "product_signature": format_tuple(record.product_signature),
            "norm_signature": format_tuple(record.norm_signature),
            "norm_signature_defect": record.norm_signature_defect,
            "projection_loss": record.projection_loss,
            "channel_entropy_norm": record.channel_entropy_norm,
            "prime_grid_compression_norm": prime_grid_compression_from_nat(record.norm),
        }
    )
    return row


def eabc_record(n: int) -> dict[str, Any]:
    record = distill_from_nat(n)
    row = _empty_row("eabc")
    row.update(
        {
            "n": n,
            "projection_loss": record.projection_loss,
            "channel_entropy_norm": record.channel_entropy,
            "prime_grid_compression_norm": record.prime_grid_compression,
        }
    )
    return row


def collatz_record(n: int, local_shrink_time: int) -> dict[str, Any]:
    diag = collatz_net_descent_diagnostics(n, local_shrink_time)
    descended_value = collatz_iterate(diag.m_good, local_shrink_time)
    assert net_descent_margin(n, descended_value) == diag.net_descent_margin
    row = _empty_row("collatz")
    row.update(
        {
            "n": diag.n,
            "t_good": diag.t_good,
            "m_good": diag.m_good,
            "local_shrink_time": local_shrink_time,
            "descended_value": descended_value,
            "net_descent_margin": diag.net_descent_margin,
            "bad_run_cost": diag.bad_run_cost,
            "shrink_efficiency": diag.shrink_efficiency,
        }
    )
    return row


def first_n_prime_quadruplets(count: int) -> list[Primvierling]:
    if count < 1:
        raise ValueError("count must be >= 1")
    stop = 100
    while True:
        quadruplets = generate_prime_quadruplets(5, stop)
        if len(quadruplets) >= count:
            return quadruplets[:count]
        stop *= 2


def build_reference_records(
    *,
    primvierling_count: int = DEFAULT_PRIMVIERLING_COUNT,
    eabc_naturals: tuple[int, ...] = DEFAULT_EABC_NATURALS,
    collatz_cases: tuple[tuple[int, int], ...] = DEFAULT_COLLATZ_CASES,
) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    records.extend(primvierling_record(v) for v in first_n_prime_quadruplets(primvierling_count))
    records.extend(eabc_record(n) for n in eabc_naturals)
    records.extend(collatz_record(n, t_loc) for n, t_loc in collatz_cases)
    return records


def export_diagnostics_atlas_reference_csv(
    output_path: str | Path,
    *,
    primvierling_count: int = DEFAULT_PRIMVIERLING_COUNT,
    eabc_naturals: tuple[int, ...] = DEFAULT_EABC_NATURALS,
    collatz_cases: tuple[tuple[int, int], ...] = DEFAULT_COLLATZ_CASES,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    records = build_reference_records(
        primvierling_count=primvierling_count,
        eabc_naturals=eabc_naturals,
        collatz_cases=collatz_cases,
    )
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(CSV_FIELDNAMES))
        writer.writeheader()
        writer.writerows(records)
    return destination


def main() -> None:
    path = export_diagnostics_atlas_reference_csv(OUT)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1
    print("Diagnostics atlas reference export (Diagnose only — keine Beweisclaims)")
    print(f"Wrote {path} ({row_count} data rows + header)")


if __name__ == "__main__":
    main()
