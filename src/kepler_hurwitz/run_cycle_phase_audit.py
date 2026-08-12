"""Executable cycle-phase audit runner bound to production oddCoreStep.

Constructs φ/d on Phase-A odd-residue spaces with unique-anchor semantics
(``canonical_key=lambda x: x``) and emits a deterministic JSON protocol.

Usage:
    PYTHONPATH=src python -m kepler_hurwitz.run_cycle_phase_audit
    PYTHONPATH=src python examples/run_cycle_phase_audit.py
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict
from pathlib import Path
from typing import Any

from kepler_hurwitz.cycle_phase_compressor import (
    GOVERNANCE,
    construct_cycle_phase,
    require,
)
from kepler_hurwitz.odd_core_residue import (
    odd_core_step_mod,
    odd_residues_mod,
    projected_odd_core_step,
)

DEFAULT_MODULI = (8, 16, 32, 64, 128)

__all__ = [
    "DEFAULT_MODULI",
    "audit_modulus",
    "build_audit_payload",
    "main",
]


def audit_modulus(modulus: int) -> dict[str, Any]:
    """Run unique-anchor cycle-phase construction for one power-of-two modulus."""
    states = odd_residues_mod(modulus)
    step = projected_odd_core_step(modulus)
    phase, depth, report = construct_cycle_phase(
        states,
        step,
        canonical_key=lambda x: x,
    )
    # Spot-check binding identity (-O safe via require, not assert).
    for r in states:
        require(
            step(r) == odd_core_step_mod(r, modulus),
            f"projected step disagree with odd_core_step_mod at r={r}, m={modulus}",
        )

    return {
        "modulus": modulus,
        "state_count": report.state_count,
        "cycle_length": report.cycle_length,
        "max_depth": report.max_depth,
        "phase_trivial": report.phase_trivial,
        "phase_histogram": {str(k): v for k, v in report.phase_histogram.items()},
        "depth_histogram": {str(k): v for k, v in report.depth_histogram.items()},
        "report": asdict(report),
        "anchor": {
            "canonical_key": "identity",
            "phase_origin_state": min(s for s in states if depth[s] == 0),
            "phase_at_origin": phase[min(s for s in states if depth[s] == 0)],
        },
        "binding": "kepler_hurwitz.odd_core_residue.odd_core_step_mod → odd_core_step",
    }


def build_audit_payload(moduli: list[int]) -> dict[str, Any]:
    """Deterministic protocol body (no wall-clock) for hash / ``-O`` diff."""
    scans = [audit_modulus(m) for m in moduli]
    return {
        "status": "PASSED",
        "governance": GOVERNANCE,
        "branch": "post-freeze/octonionic-collatz-proof-attempt",
        "map": "T_m(r)=oddCoreStep(r) mod m on canonical odd residues",
        "binding": (
            "odd_core_step_mod → octonionic_collatz_freeze_diagnostic.odd_core_step "
            "→ next_odd_core_after_kick (Lean oddCoreStep / Syracuse odd step)"
        ),
        "canonical_key": "identity (unique-anchor phase origin)",
        "moduli": list(moduli),
        "scans": scans,
        "honesty_L1": (
            "If cycle_length=1, φ is constantly 0 and "
            "φ(Tx)=φ(x)+1 mod 1 is vacuous; depth d is the live Lyapunov target."
        ),
        "not_claimed": (
            "No Collatz proof; local freeze only after run protocol + hash + commit"
        ),
    }


def render_protocol(payload: dict[str, Any]) -> str:
    return json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Executable cycle-phase audit [B]: unique-anchor φ/d construction "
            "on odd residues via production oddCoreStep."
        )
    )
    parser.add_argument(
        "--moduli",
        type=int,
        nargs="+",
        default=list(DEFAULT_MODULI),
        help="Power-of-two moduli (default: 8 16 32 64 128)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Optional logfile path for the JSON protocol (hash/diff)",
    )
    args = parser.parse_args(argv)

    payload = build_audit_payload(list(args.moduli))
    text = render_protocol(payload)

    print("CYCLE PHASE AUDIT: PASSED")
    print(text, end="")

    if args.out is not None:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(text, encoding="utf-8")
        print(f"Wrote {args.out}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
