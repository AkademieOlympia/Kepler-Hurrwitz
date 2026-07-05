"""
CSV-Export fuer den Diagnostics Parameter-Atlas (Top-8).

Governance: reine Diagnose-/Export-Schicht — keine Identitaetsbehauptungen,
keine Beweisclaims. Nicht anwendbare Parameter bleiben leer.
"""

from __future__ import annotations

import csv
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from kepler_hurwitz.diagnostics import (
    ATLAS_PRIMARY_FUNCTIONS,
    bad_run_cost,
    channel_entropy,
    collatz_net_descent_diagnostics,
    net_descent_margin_from_collatz,
    norm_signature_defect_from_primvierling,
    prime_grid_compression,
    prime_grid_compression_from_nat,
    projection_loss_from_nat,
    shrink_efficiency,
    steps_until_mod4_eq_one,
)
from kepler_hurwitz.primvierling import Primvierling, quat_norm
from kepler_hurwitz.signatures import EABCSignature4, signature_from_nat

ATLAS_EXPORT_COLUMNS: tuple[str, ...] = (
    "norm_signature_defect",
    "projection_loss",
    "channel_entropy",
    "prime_grid_compression",
    "net_descent_margin",
    "bad_run_cost",
    "shrink_efficiency",
    "chirality_norm",
)

METADATA_COLUMNS: tuple[str, ...] = ("source_kind", "source_key", "t_loc")

CSV_FIELDNAMES: tuple[str, ...] = METADATA_COLUMNS + ATLAS_EXPORT_COLUMNS

GOVERNANCE_NOTE = (
    "Parameter destillieren ja; Identifikation behaupten nein. "
    "Leere Zellen = Parameter fuer diese Zeile nicht anwendbar (Diagnose only)."
)


@dataclass(frozen=True)
class AtlasExportRow:
    source_kind: str
    source_key: str
    norm_signature_defect: int | None = None
    projection_loss: int | None = None
    channel_entropy: float | None = None
    prime_grid_compression: float | None = None
    net_descent_margin: int | None = None
    bad_run_cost: int | None = None
    shrink_efficiency: float | None = None
    chirality_norm: float | None = None
    t_loc: int | None = None

    def as_csv_dict(self) -> dict[str, Any]:
        payload: dict[str, Any] = {
            "source_kind": self.source_kind,
            "source_key": self.source_key,
            "t_loc": "" if self.t_loc is None else self.t_loc,
        }
        for column in ATLAS_EXPORT_COLUMNS:
            value = getattr(self, column)
            payload[column] = "" if value is None else value
        return payload


def _require_positive_nat(name: str, value: int) -> None:
    if value < 1:
        raise ValueError(f"{name} must be >= 1")


def first_positive_net_descent_t_loc(n: int, *, max_t_loc: int = 500) -> int | None:
    """
    Empirische Collatz-Diagnose: kleinstes t_loc >= 0 mit Delta_net > 0.

    Nur Witness-Diagnostics [C]; kein Beweis der uniformen Existenz.
    """
    _require_positive_nat("n", n)
    if max_t_loc < 0:
        raise ValueError("max_t_loc must be >= 0")
    t_good, m_good = steps_until_mod4_eq_one(n)
    for t_loc in range(max_t_loc + 1):
        if net_descent_margin_from_collatz(n, t_loc, m_good) > 0:
            return t_loc
    return None


def atlas_row_from_primvierling(v: Primvierling) -> AtlasExportRow:
    if len(v) != 4:
        raise ValueError("primvierling must have four components")
    norm = quat_norm(v)
    norm_signature = signature_from_nat(norm)
    return AtlasExportRow(
        source_kind="primvierling",
        source_key=f"p={v[0]}",
        norm_signature_defect=norm_signature_defect_from_primvierling(v),
        projection_loss=projection_loss_from_nat(norm),
        channel_entropy=channel_entropy(norm_signature.as_tuple()),
        prime_grid_compression=prime_grid_compression_from_nat(norm),
    )


def atlas_row_from_eabc(n: int) -> AtlasExportRow:
    _require_positive_nat("n", n)
    signature = signature_from_nat(n)
    mass = signature.total_weight()
    from kepler_hurwitz.signatures import prime_omega

    omega = prime_omega(n)
    compression: float | None = 0.0 if omega == 0 else prime_grid_compression(mass, omega)
    entropy: float | None = 0.0 if mass == 0 else channel_entropy(signature.as_tuple())
    return AtlasExportRow(
        source_kind="eabc",
        source_key=f"n={n}",
        projection_loss=projection_loss_from_nat(n),
        channel_entropy=entropy,
        prime_grid_compression=compression,
    )


def atlas_row_from_eabc_signature(signature: EABCSignature4, *, source_key: str) -> AtlasExportRow:
    if not source_key:
        raise ValueError("source_key must be non-empty")
    mass = signature.total_weight()
    entropy = 0.0 if mass == 0 else channel_entropy(signature.as_tuple())
    return AtlasExportRow(
        source_kind="eabc",
        source_key=source_key,
        channel_entropy=entropy,
        prime_grid_compression=None,
    )


def atlas_row_from_collatz(n: int, t_loc: int | None = None) -> AtlasExportRow:
    _require_positive_nat("n", n)
    if n % 4 != 3:
        raise ValueError("collatz atlas rows expect n % 4 == 3 (witness diagnostics)")
    resolved_t_loc = t_loc if t_loc is not None else first_positive_net_descent_t_loc(n)
    if resolved_t_loc is None:
        raise ValueError(f"no positive net_descent_margin found for n={n} within search bound")
    if resolved_t_loc < 0:
        raise ValueError("t_loc must be >= 0")
    record = collatz_net_descent_diagnostics(n, resolved_t_loc)
    return AtlasExportRow(
        source_kind="collatz",
        source_key=f"n={n}",
        net_descent_margin=record.net_descent_margin,
        bad_run_cost=record.bad_run_cost,
        shrink_efficiency=record.shrink_efficiency,
        t_loc=resolved_t_loc,
    )


def build_default_atlas_export_rows() -> list[AtlasExportRow]:
    from kepler_hurwitz.primvierling import generate_prime_quadruplets

    rows: list[AtlasExportRow] = []
    rows.extend(atlas_row_from_primvierling(v) for v in generate_prime_quadruplets(5, 101)[:5])
    rows.extend(atlas_row_from_eabc(n) for n in (6, 12, 30, 60, 210))
    rows.extend(atlas_row_from_collatz(n) for n in (3, 7, 15, 27, 31))
    return rows


def atlas_export_records(rows: list[AtlasExportRow]) -> list[dict[str, Any]]:
    return [row.as_csv_dict() for row in rows]


def export_atlas_parameters_csv(
    rows: list[AtlasExportRow],
    output_path: str | Path,
) -> Path:
    if not rows:
        raise ValueError("rows must be non-empty")
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(CSV_FIELDNAMES))
        writer.writeheader()
        for record in atlas_export_records(rows):
            writer.writerow(record)
    return destination


def assert_atlas_export_columns_match_primary_api() -> None:
    """Sanity check: CSV columns cover the same Top-8 API (order may differ)."""
    if set(ATLAS_EXPORT_COLUMNS) != set(ATLAS_PRIMARY_FUNCTIONS):
        raise AssertionError("ATLAS_EXPORT_COLUMNS diverges from ATLAS_PRIMARY_FUNCTIONS")
