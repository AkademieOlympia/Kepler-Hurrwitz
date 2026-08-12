#!/usr/bin/env python3
"""Phase-A Funktionsgraph-Scan von oddCoreStep auf ungeraden Restklassen [B].

Kartografiert die nackte Graphentopologie ohne geometrische Schranken und
ohne Fano-/Charakterstrukturen a priori. Optional Phase-B-Rauchtest für
bekannte Observablen (Invarianz vs. Kovarianz).

Abbildung auf Restklassen
------------------------
``oddCoreStep`` auf ``Nat`` steigt im Allgemeinen **nicht** zu einer wohldefinierten
Abbildung auf ``Z/mZ`` ab: ``T(n) = oddCore(3n+1)`` hängt von der 2-Bewertung
``v2(3n+1)`` ab, die durch ``n mod m`` allein nicht bestimmt sein muss
(Beispiel: ``T(1)=1``, ``T(17)=13``, beide ≡ 1 mod 16).

Deshalb scannt dieses Skript die **kanonische Repräsentanten-Projektion**

    T_m : OddRes(m) → OddRes(m),
    T_m(r) := oddCoreStep(r) mod m

auf der endlichen Menge der ungeraden Reste ``{1,3,...,m-1}`` (für gerades ``m``).
Das ist der vollständige Digraph der Syracuse-Odd-Reste unter dieser
Deterministik — ehrlich dokumentiert als projizierte Abbildung, nicht als
modulare Deszendenz von Collatz.

Governance: kein Collatz-Beweis; schwach zusammenhängend ⇒ keine nichtkonstante
Invariante ``J ∘ T = J`` auf diesem Raum.

Ausführung:
    PYTHONPATH=src python examples/run_oddcore_function_graph_scan.py
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.graph_analyzer import (  # noqa: E402
    GOVERNANCE,
    analyze_quotient_dynamics,
    classify_function_graph,
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

EXPORT_JSON = ROOT / "docs/exports/oddcore_function_graph_phase_a.json"
DEFAULT_MODULI = (8, 16, 32, 64, 128)


def odd_residues_mod(m: int) -> tuple[int, ...]:
    if m < 2 or m % 2 != 0:
        raise ValueError("m must be even and >= 2")
    return tuple(r for r in range(1, m, 2))


def projected_odd_core_step(m: int):
    """T_m(r) = oddCoreStep(r) mod m on canonical odd residues."""

    def step(r: int) -> int:
        return odd_core_step(r) % m

    return step


def scan_modulus(m: int) -> dict[str, object]:
    states = odd_residues_mod(m)
    step = projected_odd_core_step(m)
    topology = classify_function_graph(states, step)
    weakly_connected = topology["weak_components_count"] == 1
    return {
        "modulus": m,
        "state_space": "odd_residues_mod_m",
        "state_count": len(states),
        "map_definition": (
            "T_m(r) := oddCoreStep(r) mod m on canonical odd representatives "
            "{1,3,...,m-1}; not claimed as modular descent of Nat-oddCoreStep"
        ),
        "weak_components_count": topology["weak_components_count"],
        "attractor_cycles_count": topology["attractor_cycles_count"],
        "attractor_cycles": [list(c) for c in topology["attractor_cycles"]],  # type: ignore[arg-type]
        "basin_sizes": list(topology["basin_sizes"]),  # type: ignore[arg-type]
        "weakly_connected": weakly_connected,
        "nonconstant_invariant_ruled_out": weakly_connected,
        "nonconstant_invariant_possible": topology["nonconstant_invariant_possible"],
        "honest_report": (
            "weakly connected ⇒ no nonconstant J with J∘T=J on this finite space"
            if weakly_connected
            else "multiple weak components ⇒ nonconstant invariants may exist"
        ),
    }


def phase_b_smoke(m: int = 32) -> list[dict[str, object]]:
    """Audit known observables on the projected odd-residue digraph."""
    states = odd_residues_mod(m)
    step = projected_odd_core_step(m)

    def channel_label_obs(r: int) -> str:
        return channel_label(e_schalen_sprung(r))

    observables: list[tuple[str, object]] = [
        (
            "disk_axis_parity_constant_1",
            disk_axis_parity,
        ),
        (
            "n_mod_8",
            channel_seven_residue,
        ),
        (
            "channel_seven_flag",
            lambda r: int(is_channel_seven(r)),
        ),
        (
            "smoothness_channel_label",
            channel_label_obs,
        ),
    ]

    reports: list[dict[str, object]] = []
    for name, obs in observables:
        result = analyze_quotient_dynamics(states, step, obs)  # type: ignore[arg-type]
        reports.append(
            {
                "observable": name,
                "modulus": m,
                "type": result["type"],
                "induced_map": result.get("induced_map"),
                "ambiguous_entries": result.get("ambiguous_entries"),
                "note": (
                    "diskAxisParity is constantly 1 on odd n — exact_invariant "
                    "is the trivial constant lock-in (connectivity symptom)"
                    if name == "disk_axis_parity_constant_1"
                    else None
                ),
            }
        )
    return reports


def main() -> int:
    print("OddCore Funktionsgraph Phase-A-Scan [B]")
    print(f"Governance: {GOVERNANCE}")
    print()

    moduli = DEFAULT_MODULI
    scans = [scan_modulus(m) for m in moduli]
    phase_b = phase_b_smoke(m=32)

    for row in scans:
        flag = (
            "NONCONSTANT_INVARIANT_RULED_OUT"
            if row["nonconstant_invariant_ruled_out"]
            else "components>1"
        )
        print(
            f"  m={row['modulus']:>3}: weak_components={row['weak_components_count']}, "
            f"cycles={row['attractor_cycles_count']}, "
            f"basin_sizes={row['basin_sizes']} [{flag}]"
        )

    print()
    print(f"Phase-B smoke (m=32):")
    for rep in phase_b:
        print(f"  {rep['observable']}: {rep['type']}")

    payload = {
        "status": "completed",
        "governance": GOVERNANCE,
        "generated_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "branch": "post-freeze/octonionic-collatz-proof-attempt",
        "phase": "A",
        "map": "oddCoreStep / syracuse odd step via kepler_hurwitz.odd_core_step",
        "projection_caveat": (
            "oddCoreStep on Nat does not always descend to Z/mZ; "
            "scan uses T_m(r)=oddCoreStep(r) mod m on canonical odd residues"
        ),
        "moduli": list(moduli),
        "scans": scans,
        "phase_b_smoke": phase_b,
        "satzschema_d": (
            "nonconstant finite-valued J∘T=J exists iff weak_components_count > 1; "
            "if weakly connected, search cyclic covariance J(Tx)=σ(J(x)), σ≠id"
        ),
        "not_claimed": (
            "No Collatz proof; Fano/character candidates remain hypotheses "
            "until graph findings; projected digraph ≠ modular Collatz descent"
        ),
        "reproduction": {
            "command": "PYTHONPATH=src python examples/run_oddcore_function_graph_scan.py",
            "pytest": "PYTHONPATH=src pytest tests/test_graph_analyzer.py -q",
        },
    }

    EXPORT_JSON.parent.mkdir(parents=True, exist_ok=True)
    EXPORT_JSON.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print()
    print(f"Export: {EXPORT_JSON.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
