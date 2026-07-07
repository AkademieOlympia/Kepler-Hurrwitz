"""
Pauli-symplectic [[5,1,3]] stabilizer bridge for L(s, chi_{-3}) zero gaps [C].

Maps nearest-neighbor gaps Delta gamma = gamma_{n+1} - gamma_n to one of 15
non-trivial symplectic coefficient vectors in GF(2)^4 \\ {0}, read as phase
transitions in the [[5,1,3]] stabilizer grammar.

Pauli-quaternion isomorphism (up to i) is standard [A/B] algebra; the claim that
prime distribution is stabilized by a QEC code is NOT made here.

Governance: [C] interpretive bridge; fundamental_freq is a calibration parameter
(not preregistered). Does not claim RH/L-zero implementation of [[5,1,3]].

Sibling: E-093, ``five_qubit_bridge.sage``, ``qec_bridge.py`` (E-044),
``eabc_monopole_axis_resonance.py`` (BH-C-08).
"""

from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Sequence

from kepler_hurwitz.qec_bridge import (
    FIVE_QUBIT_GENERATORS,
    multiply_commuting_pauli_strings,
)

SYMPLECTIC_BRIDGE_TAG = "[C]"

FUNDAMENTAL_FREQ_DEFAULT = 3.208

# First ten imaginary parts of non-trivial zeros of L(s, chi_{-3}) (user fallback).
FIRST_L_CHI_MINUS3_ZEROS: tuple[float, ...] = (
    8.0397,
    11.2492,
    15.7049,
    16.7369,
    20.4559,
    22.1952,
    26.0645,
    27.6087,
    31.0264,
    33.5135,
)

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive L-gap to symplectic stabilizer scaffold",
    "tag_interpretive": SYMPLECTIC_BRIDGE_TAG,
    "standard_math": (
        "Pauli algebra is quaternion-isomorphic up to i; "
        "[[5,1,3]] has 2^4-1=15 non-trivial commuting stabilizers [A/B]"
    ),
    "not_claimed": (
        "that Riemann or Dirichlet L zeros implement [[5,1,3]]; "
        "that primes are QEC-stabilized; "
        "discovery-taugliche gap histograms without preregistration; "
        "proof of the Riemann Hypothesis"
    ),
    "calibration": (
        f"fundamental_freq={FUNDAMENTAL_FREQ_DEFAULT} is [C] exploratory calibration, "
        "not preregistered"
    ),
    "sibling_register": "E-093",
    "claim_id": "BH-C-09",
    "related_scripts": (
        "five_qubit_bridge.sage, eabc_symplectic_stabilizer_bridge.sage, qec_bridge.py"
    ),
}

_SYMPLECTIC_VECTOR_RE = re.compile(r"^\(\d{2} \| \d{2}\)$")

__all__ = [
    "FUNDAMENTAL_FREQ_DEFAULT",
    "FIRST_L_CHI_MINUS3_ZEROS",
    "GOVERNANCE",
    "SYMPLECTIC_BRIDGE_TAG",
    "GapStabilizerRecord",
    "SymplecticStabilizerRecord",
    "analyze_stabilizer_bridge",
    "build_stabilizer_bridge_analysis",
    "export_stabilizer_bridge_json",
    "gap_to_symplectic_stabilizer",
    "stabilizer_histogram",
    "stabilizer_label",
]


@dataclass(frozen=True)
class SymplecticStabilizerRecord:
    symplectic_vector: str
    state_idx: int
    x_bits: str
    z_bits: str
    phase: float
    pauli_stabilizer: str
    tag: str = SYMPLECTIC_BRIDGE_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class GapStabilizerRecord:
    gamma_n: float
    gamma_next: float
    gap: float
    stabilizer: SymplecticStabilizerRecord
    tag: str = SYMPLECTIC_BRIDGE_TAG

    def as_dict(self) -> dict[str, Any]:
        payload = asdict(self)
        payload["stabilizer"] = self.stabilizer.as_dict()
        return payload


def stabilizer_label(state_idx: int) -> str:
    """Human-readable stabilizer tag S_1 .. S_15."""
    if not 1 <= state_idx <= 15:
        raise ValueError(f"state_idx must be in 1..15, got {state_idx}")
    return f"S_{state_idx}"


def _build_mask_to_pauli() -> dict[int, str]:
    """Map generator bitmask 1..15 to the corresponding [[5,1,3]] Pauli stabilizer."""
    mask_to_stabilizer: dict[int, str] = {}
    for mask in range(1, 16):
        selected = [
            FIVE_QUBIT_GENERATORS[index]
            for index in range(len(FIVE_QUBIT_GENERATORS))
            if mask & (1 << index)
        ]
        product = selected[0]
        for next_string in selected[1:]:
            product = multiply_commuting_pauli_strings(product, next_string)
        mask_to_stabilizer[mask] = product
    return mask_to_stabilizer


_MASK_TO_PAULI = _build_mask_to_pauli()


def _pauli_for_state_idx(state_idx: int) -> str:
    return _MASK_TO_PAULI[state_idx]


def gap_to_symplectic_stabilizer(
    gap: float,
    fundamental_freq: float = FUNDAMENTAL_FREQ_DEFAULT,
) -> SymplecticStabilizerRecord:
    """
    Project gap onto cyclic phase [0, 1) modulo ``fundamental_freq``, then to S_1..S_15.

    Symplectic vector uses 4-bit binary of ``state_idx``: (x_1 x_2 | z_1 z_2).
    """
    if fundamental_freq <= 0:
        raise ValueError("fundamental_freq must be positive.")
    phase = (gap % fundamental_freq) / fundamental_freq
    state_idx = int(phase * 15) + 1
    if not 1 <= state_idx <= 15:
        raise RuntimeError(f"internal mapping produced invalid state_idx={state_idx}")
    binary_str = format(state_idx, "04b")
    x_bits = binary_str[:2]
    z_bits = binary_str[2:]
    symplectic_vector = f"({x_bits} | {z_bits})"
    return SymplecticStabilizerRecord(
        symplectic_vector=symplectic_vector,
        state_idx=state_idx,
        x_bits=x_bits,
        z_bits=z_bits,
        phase=phase,
        pauli_stabilizer=_pauli_for_state_idx(state_idx),
    )


def analyze_stabilizer_bridge(
    gammas: Sequence[float],
    fundamental_freq: float = FUNDAMENTAL_FREQ_DEFAULT,
) -> list[GapStabilizerRecord]:
    """Pair consecutive gammas, compute gaps, map each gap to a stabilizer record."""
    if len(gammas) < 2:
        return []
    records: list[GapStabilizerRecord] = []
    for gamma_n, gamma_next in zip(gammas, gammas[1:]):
        gap = float(gamma_next) - float(gamma_n)
        stabilizer = gap_to_symplectic_stabilizer(gap, fundamental_freq=fundamental_freq)
        records.append(
            GapStabilizerRecord(
                gamma_n=float(gamma_n),
                gamma_next=float(gamma_next),
                gap=gap,
                stabilizer=stabilizer,
            )
        )
    return records


def stabilizer_histogram(bridge_records: Sequence[GapStabilizerRecord]) -> dict[int, int]:
    """Count occurrences of each stabilizer index 1..15 across bridge records."""
    hist = {index: 0 for index in range(1, 16)}
    for record in bridge_records:
        hist[record.stabilizer.state_idx] += 1
    return hist


def build_stabilizer_bridge_analysis(
    *,
    gammas: Sequence[float] | None = None,
    fundamental_freq: float = FUNDAMENTAL_FREQ_DEFAULT,
) -> dict[str, Any]:
    """Bundle bridge records, histogram, and governance for export."""
    zeros = tuple(gammas) if gammas is not None else FIRST_L_CHI_MINUS3_ZEROS
    records = analyze_stabilizer_bridge(zeros, fundamental_freq=fundamental_freq)
    histogram = stabilizer_histogram(records)
    return {
        "governance": SYMPLECTIC_BRIDGE_TAG,
        "governance_detail": GOVERNANCE,
        "fundamental_freq": fundamental_freq,
        "l_function": "L(s, chi_{-3})",
        "zero_count": len(zeros),
        "gap_count": len(records),
        "stabilizer_histogram": {str(k): v for k, v in sorted(histogram.items())},
        "records": [r.as_dict() for r in records],
    }


def export_stabilizer_bridge_json(
    analysis: dict[str, Any],
    path: Path,
) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(analysis, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def symplectic_vector_valid(symplectic_vector: str) -> bool:
    """True if vector matches ``(xx | zz)`` with binary digits."""
    return bool(_SYMPLECTIC_VECTOR_RE.match(symplectic_vector))
