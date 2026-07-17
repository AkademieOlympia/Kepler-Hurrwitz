"""[B]/[C] Collatz↔Oktonion-Freeze-Diagnostik (post-freeze proof attempt v1).

Mappt ungerade Collatz-Stationen / Kanal-7-Reste in Oktonion-Koordinaten und
misst algebraische Einfrierungs-Indikatoren (Hurwitz, Assoziator, Triaden-Split).

Governance
----------
- Einfrierung = algebraische Lock-in-Struktur ≠ Collatz-Beweis
- Assoziator-Defekt ≠ dynamischer Net-Descent
- Die Embed-Map ist heuristisch und als ``[B]/[C]`` markiert — kein Anspruch auf
  kanonische Eindeutigkeit oder Beweisrelevanz ohne weitere Lean-Brücke.
- Keine Astrophysik / keine Prim=Jet-Identität (E-098 Richtigstellung).
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Sequence

from kepler_hurwitz.discrete_time_flow import (
    Octonion,
    associator,
    fano_triples,
    is_hurwitz_lattice_point,
    octonion_norm_sq,
)
from kepler_hurwitz.octonionic_jet_diagnostic import (
    BASE_AXES,
    DISK_AXES,
    JET_AXES,
    fano_associator_witness,
    split_triad_coefficients,
    triad_projection,
)

OCTONIONIC_COLLATZ_FREEZE_TAG = "[B]/[C]"

GOVERNANCE: dict[str, str] = {
    "status": OCTONIONIC_COLLATZ_FREEZE_TAG,
    "evidence_id": "E-098",
    "attempt": "octonionic-collatz-freeze-proof-attempt-v1",
    "not_claimed": (
        "No Collatz proof; embed map is heuristic; freeze indicators do not "
        "imply BadRunNetDescentWitness or close bad_run_net_descent_witness_of_mod4_three"
    ),
    "depends_on": "discrete_time_flow, octonionic_jet_diagnostic",
}

# Fano-Witness-Tripel (keine Fano-Linie) — Lean: fano_witness_e2_e3_e4_*
WITNESS_TRIPLE: tuple[int, int, int] = (2, 3, 4)

__all__ = [
    "OCTONIONIC_COLLATZ_FREEZE_TAG",
    "GOVERNANCE",
    "WITNESS_TRIPLE",
    "FreezeIndicatorRecord",
    "collatz_oct_embed",
    "channel_seven_residue",
    "is_channel_seven",
    "imaginary_unit",
    "associator_norm_sq_on_triple",
    "fano_line_associator_profile",
    "freeze_indicators",
    "scan_odd_stations",
    "run_collatz_freeze_diagnostic",
    "export_collatz_freeze_diagnostic_json",
    "format_freeze_summary",
]


@dataclass(frozen=True)
class FreezeIndicatorRecord:
    n: int
    odd: bool
    channel_seven: bool
    residue_mod8: int
    residue_mod12: int
    coords: tuple[float, ...]
    is_hurwitz: bool
    hurwitz_note: str
    triad_base_norm_sq: float
    triad_disk_norm_sq: float
    triad_jet_norm_sq: float
    controlled_triad_associator_norm_sq: float
    witness_associator_norm_sq: float
    freeze_predicate_heuristic: bool
    map_status: str


def channel_seven_residue(n: int) -> int:
    """Restklasse modulo 8 (Kanal-7 = 7)."""
    return n % 8


def is_channel_seven(n: int) -> bool:
    return n % 2 == 1 and n % 8 == 7


def collatz_oct_embed(n: int) -> Octonion:
    """Heuristische Collatz→Oktonion-Einbettung ``[B]/[C]``.

    Entspricht Lean ``collatzOctEmbed``:
    ``n·e0 + ((n mod 8)/2)·e1 + (n mod 12)·e2 + χ₇·e7``.
    """
    if n < 0:
        raise ValueError("n must be non-negative")
    chi7 = 1.0 if n % 8 == 7 else 0.0
    return (
        float(n),
        float((n % 8) // 2),
        float(n % 12),
        0.0,
        0.0,
        0.0,
        0.0,
        chi7,
    )


def imaginary_unit(index: int) -> Octonion:
    if not 0 <= index <= 7:
        raise ValueError("index must be in 0..7")
    coords = [0.0] * 8
    coords[index] = 1.0
    return tuple(coords)  # type: ignore[return-value]


def associator_norm_sq_on_triple(i: int, j: int, k: int) -> float:
    return octonion_norm_sq(
        associator(imaginary_unit(i), imaginary_unit(j), imaginary_unit(k))
    )


def fano_line_associator_profile() -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for i, j, k in fano_triples():
        rows.append(
            {
                "triple": (i, j, k),
                "associator_norm_sq": associator_norm_sq_on_triple(i, j, k),
                "is_fano_line": True,
            }
        )
    # Witness (nicht auf einer Fano-Linie)
    i, j, k = WITNESS_TRIPLE
    rows.append(
        {
            "triple": (i, j, k),
            "associator_norm_sq": associator_norm_sq_on_triple(i, j, k),
            "is_fano_line": False,
            "note": "Fano witness — ambient non-associativity",
        }
    )
    return rows


def freeze_indicators(n: int) -> FreezeIndicatorRecord:
    """Freeze-Indikatoren für eine Station ``n``."""
    coords = collatz_oct_embed(n)
    split = split_triad_coefficients(coords)
    x_base, x_disk, _x_jet = triad_projection(coords)
    controlled = octonion_norm_sq(associator(x_disk, x_base, x_disk))
    witness = associator_norm_sq_on_triple(*WITNESS_TRIPLE)
    hurwitz = is_hurwitz_lattice_point(coords)
    # Heuristische FreezePredicate-Spiegelung (Lean-Definition):
    # Integer-Hurwitz ∧ kontrollierter Triaden-Assoziator = 0
    freeze = hurwitz and controlled == 0.0
    return FreezeIndicatorRecord(
        n=n,
        odd=(n % 2 == 1),
        channel_seven=is_channel_seven(n),
        residue_mod8=channel_seven_residue(n),
        residue_mod12=n % 12,
        coords=coords,
        is_hurwitz=hurwitz,
        hurwitz_note=(
            "integer/half-integer Hurwitz check via discrete_time_flow"
        ),
        triad_base_norm_sq=split.base_norm_sq,
        triad_disk_norm_sq=split.disk_norm_sq,
        triad_jet_norm_sq=split.jet_norm_sq,
        controlled_triad_associator_norm_sq=controlled,
        witness_associator_norm_sq=witness,
        freeze_predicate_heuristic=freeze,
        map_status=OCTONIONIC_COLLATZ_FREEZE_TAG,
    )


def scan_odd_stations(
    values: Sequence[int] | None = None,
    *,
    limit: int = 40,
) -> list[FreezeIndicatorRecord]:
    if values is None:
        odds = [n for n in range(1, 2 * limit + 1, 2)]
    else:
        odds = [int(n) for n in values if int(n) % 2 == 1]
    return [freeze_indicators(n) for n in odds]


def run_collatz_freeze_diagnostic(
    *,
    sample_odds: Sequence[int] | None = None,
) -> dict[str, object]:
    samples = scan_odd_stations(sample_odds)
    channel7 = [r for r in samples if r.channel_seven]
    frozen = [r for r in samples if r.freeze_predicate_heuristic]
    return {
        "governance": GOVERNANCE,
        "triad_axes": {
            "base": list(BASE_AXES),
            "disk": list(DISK_AXES),
            "jet": list(JET_AXES),
        },
        "fano_associator_witness": fano_associator_witness(*WITNESS_TRIPLE),
        "fano_line_associator_profile": fano_line_associator_profile(),
        "embed_map": {
            "status": OCTONIONIC_COLLATZ_FREEZE_TAG,
            "formula": "n*e0 + ((n mod 8)//2)*e1 + (n mod 12)*e2 + chi7*e7",
            "lean_anchor": "KeplerHurwitz.Collatz.Octonion.Freeze.collatzOctEmbed",
        },
        "sample_count": len(samples),
        "channel_seven_count": len(channel7),
        "freeze_heuristic_count": len(frozen),
        "samples": [asdict(r) for r in samples],
        "channel_seven_samples": [asdict(r) for r in channel7],
        "not_claimed": [
            "does_not_close_bad_run_net_descent_witness_of_mod4_three",
            "freeze_predicate_heuristic_is_not_a_Collatz_proof",
        ],
    }


def export_collatz_freeze_diagnostic_json(
    path: str | Path,
    *,
    sample_odds: Sequence[int] | None = None,
) -> Path:
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    payload = run_collatz_freeze_diagnostic(sample_odds=sample_odds)
    out.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out


def format_freeze_summary(payload: dict[str, object] | None = None) -> str:
    data = payload if payload is not None else run_collatz_freeze_diagnostic()
    witness = data["fano_associator_witness"]
    assert isinstance(witness, dict)
    return (
        f"octonionic_collatz_freeze [{data['governance']['status']}] "  # type: ignore[index]
        f"samples={data['sample_count']} "
        f"channel7={data['channel_seven_count']} "
        f"freeze≈{data['freeze_heuristic_count']} "
        f"witness‖·‖²={witness['associator_norm_sq']}"
    )
