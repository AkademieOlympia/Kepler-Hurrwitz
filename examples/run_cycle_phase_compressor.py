#!/usr/bin/env python3
"""Cycle-phase compression audit on Phase-A odd-residue spaces [B].

For each m ∈ {8,16,32,64,128} builds the projected digraph

    T_m : OddRes(m) → OddRes(m),  T_m(r) := oddCoreStep(r) mod m

then constructs canonical phase φ and depth d, and audits candidate
local feature vectors for reconstructing φ and/or d.

Honesty
-------
Phase-A monoliths on these moduli have attractor cycle {1}, so L=1.
Then φ ≡ 0 and the covariance φ(Tx)=φ(x)+1 (mod 1) is vacuous.
The compression question for φ collapses; **depth d** remains the
nontrivial Lyapunov observable. The interesting regime for φ is L>1.

Governance: no Collatz proof; Phase-C subclass invariants structurally
locked on weakly connected spaces; local freeze only after run protocol
+ hash + commit.

Ausführung:
    PYTHONPATH=src python examples/run_cycle_phase_compressor.py
"""

from __future__ import annotations

import hashlib
import json
import sys
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.cycle_phase_compressor import (  # noqa: E402
    GOVERNANCE,
    audit_phase_reconstruction,
    construct_cycle_phase,
)
from kepler_hurwitz.octonionic_collatz_freeze_diagnostic import (  # noqa: E402
    channel_seven_residue,
    disk_axis_parity,
    is_channel_seven,
    odd_core_step,
)
from kepler_hurwitz.smoothness_channel_scan import (  # noqa: E402
    channel_label,
    e_schalen_sprung,
)

EXPORT_JSON = ROOT / "docs/exports/oddcore_cycle_phase_compression.json"
DEFAULT_MODULI = (8, 16, 32, 64, 128)


def odd_residues_mod(m: int) -> tuple[int, ...]:
    if m < 2 or m % 2 != 0:
        raise ValueError("m must be even and >= 2")
    return tuple(r for r in range(1, m, 2))


def projected_odd_core_step(m: int):
    def step(r: int) -> int:
        return odd_core_step(r) % m

    return step


def feature_specs() -> list[tuple[str, object]]:
    return [
        ("residue_identity", lambda r: r),
        ("disk_axis_parity_constant_1", disk_axis_parity),
        ("constant_0", lambda _r: 0),
        ("n_mod_8", channel_seven_residue),
        ("channel_seven_flag", lambda r: int(is_channel_seven(r))),
        ("smoothness_channel_label", lambda r: channel_label(e_schalen_sprung(r))),
        ("n_mod_16", lambda r: r % 16),
        ("v2_proxy_3n_plus_1_parity", lambda r: ((3 * r + 1) // 2) % 2),
    ]


def audit_features(
    states: tuple[int, ...],
    target: dict[int, int],
    target_name: str,
) -> list[dict[str, object]]:
    reports: list[dict[str, object]] = []
    for name, feat in feature_specs():
        result = audit_phase_reconstruction(states, target, feat)  # type: ignore[arg-type]
        entry: dict[str, object] = {
            "feature": name,
            "target": target_name,
            "reconstructs_target": result["reconstructs_target"],
        }
        if result["reconstructs_target"]:
            entry["distinct_feature_vectors"] = result["distinct_feature_vectors"]
            entry["target_classes_count"] = result["target_classes_count"]
        else:
            collision = result["collision"]
            # Make JSON-safe (feature vectors may be ints/strs).
            entry["collision"] = {
                "feature_vector": collision["feature_vector"],
                "first_stored_value": collision["first_stored_value"],
                "colliding_state": collision["colliding_state"],
                "colliding_value": collision["colliding_value"],
            }
        reports.append(entry)
    return reports


def scan_modulus(m: int) -> dict[str, object]:
    states = odd_residues_mod(m)
    step = projected_odd_core_step(m)
    phase, depth, report = construct_cycle_phase(states, step)
    return {
        "modulus": m,
        "state_count": len(states),
        "cycle_length": report.cycle_length,
        "max_depth": report.max_depth,
        "phase_histogram": report.phase_histogram,
        "depth_histogram": report.depth_histogram,
        "phase_trivial": report.phase_trivial,
        "honesty": (
            "L=1 ⇒ φ constantly 0; mod-1 covariance vacuous; "
            "compression target for φ collapses; depth d remains live"
            if report.phase_trivial
            else "L>1 ⇒ nontrivial cycle-phase covariance"
        ),
        "phase_reconstruction": audit_features(states, phase, "phase"),
        "depth_reconstruction": audit_features(states, depth, "depth"),
    }


def main() -> int:
    print("OddCore cycle-phase compression audit [B]")
    print(f"Governance: {GOVERNANCE}")
    print(
        "Honesty: on Phase-A monoliths expect L=1 (attractor {1}); "
        "φ trivial, d nontrivial."
    )
    print()

    scans = [scan_modulus(m) for m in DEFAULT_MODULI]

    for row in scans:
        tag = "φ trivial" if row["phase_trivial"] else "φ live"
        print(
            f"  m={row['modulus']:>3}: L={row['cycle_length']}, "
            f"max_depth={row['max_depth']}, states={row['state_count']} [{tag}]"
        )
        depth_hits = [
            a["feature"]
            for a in row["depth_reconstruction"]  # type: ignore[union-attr]
            if a["reconstructs_target"]
        ]
        print(f"       depth reconstructed by: {depth_hits}")

    payload = {
        "status": "completed",
        "governance": GOVERNANCE,
        "generated_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "branch": "post-freeze/octonionic-collatz-proof-attempt",
        "phase": "B/C compression",
        "map": "T_m(r)=oddCoreStep(r) mod m on canonical odd residues",
        "projection_caveat": (
            "oddCoreStep on Nat does not always descend to Z/mZ; "
            "scan uses projected digraph as in Phase A"
        ),
        "honesty_L1": (
            "If cycle_length=1, φ is constantly 0 and "
            "φ(Tx)=φ(x)+1 mod 1 is vacuous. The interesting regime for φ "
            "is L>1. On these monoliths depth d is the live Lyapunov target."
        ),
        "phase_c_lockout": (
            "Forward-closed nonempty subclasses of a finite monolith still "
            "contain the unique attractor cycle ⇒ remain weakly connected; "
            "static subclass invariants are structurally locked out."
        ),
        "moduli": list(DEFAULT_MODULI),
        "scans": scans,
        "not_claimed": (
            "No Collatz proof; local freeze only after run protocol + hash + commit"
        ),
        "reproduction": {
            "command": "PYTHONPATH=src python examples/run_cycle_phase_compressor.py",
            "pytest": "PYTHONPATH=src pytest tests/test_cycle_phase_compressor.py -q",
        },
    }

    EXPORT_JSON.parent.mkdir(parents=True, exist_ok=True)
    text = json.dumps(payload, indent=2, ensure_ascii=False) + "\n"
    EXPORT_JSON.write_text(text, encoding="utf-8")
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()

    print()
    print(f"Export: {EXPORT_JSON.relative_to(ROOT)}")
    print(f"sha256: {digest}")
    print(
        "Local freeze: only after this run protocol + hash + commit "
        "(documented; not auto-frozen here)."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
