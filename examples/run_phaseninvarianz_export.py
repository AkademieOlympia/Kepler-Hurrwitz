#!/usr/bin/env python3
"""Run Pauli phase invariance audit and export JSON [C]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports" / "phaseninvarianz_pauli_energy.json"
TENSOR_OUT = ROOT / "docs" / "exports" / "phaseninvarianz_tensor_invariants.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.phaseninvarianz_crosstalk import (  # noqa: E402
    GOVERNANCE as CROSSTALK_GOVERNANCE,
    analyze_crosstalk_swap,
)
from kepler_hurwitz.phaseninvarianz_pauli_energy import (  # noqa: E402
    GOVERNANCE,
    PHASENINVARIANZ_TAG,
    export_pauli_invariance_json,
    pauli_invariance_report,
)
from kepler_hurwitz.phaseninvarianz_fermat_factorization import (  # noqa: E402
    GOVERNANCE as FERMAT_GOVERNANCE,
    find_amplitudes_for_factors,
)
from kepler_hurwitz.phaseninvarianz_tensor_invariants import (  # noqa: E402
    build_tensor_invariant_analysis,
    export_tensor_invariants_json,
)

DEFAULT_SAMPLES = (
    {"ax": 1.0, "ay": 2.0, "bx": 3.0, "by": 1.0, "cx": 2.0, "cy": 4.0},
    {"ax": -1.5, "ay": 2.5, "bx": 1.0, "by": 0.5, "cx": 3.0, "cy": 2.0},
    {"ax": 2.0, "ay": 2.0, "bx": 1.0, "by": 1.0, "cx": 1.0, "cy": 1.0},
    {"ax": 0.0, "ay": 3.0, "bx": 2.0, "by": 2.0, "cx": 2.0, "cy": 2.0},
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Pauli phase invariance on EABC energy terms — export [C]."
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"JSON export path (default: {DEFAULT_OUT}).",
    )
    args = parser.parse_args()

    reports = [pauli_invariance_report(sample) for sample in DEFAULT_SAMPLES]
    crosstalk_sample = {"bx": 1.0, "by": 0.7, "cx": 2.0, "cy": 0.9}
    tensor_audit = build_tensor_invariant_analysis(**crosstalk_sample)
    crosstalk_report = analyze_crosstalk_swap(**crosstalk_sample).as_dict()
    fermat_cases = [35, 143]
    fermat_results = [find_amplitudes_for_factors(n).as_dict() for n in fermat_cases]
    analysis = {
        "tag": PHASENINVARIANZ_TAG,
        "claim_id": GOVERNANCE["claim_id"],
        "evidence_id": "E-094",
        "orq_id": "ORQ-094",
        "governance": GOVERNANCE,
        "reports": reports,
        "crosstalk": {
            "claim_id": CROSSTALK_GOVERNANCE["claim_id"],
            "governance": CROSSTALK_GOVERNANCE,
            "tensor_local_audit": tensor_audit,
            "crosstalk_swap_report": crosstalk_report,
        },
        "fermat_factorization": {
            "claim_id": FERMAT_GOVERNANCE["claim_id"],
            "governance": FERMAT_GOVERNANCE,
            "cases": fermat_results,
        },
        "summary": {
            "all_a_invariant_under_z": all(r["invariant_under_z"] for r in reports),
            "all_a_invariant_under_x": all(r["invariant_under_x"] for r in reports),
            "any_bc_vulnerable": any(not r["invariant_under_tensor_x"] for r in reports),
            "symmetric_special_cases": sum(
                1 for r in reports if r["symmetric_tensor_x_special_case"]
            ),
            "local_pauli_15_of_15_invariant": tensor_audit["summary"]["all_bc_invariant"],
            "crosstalk_delta_e_sample": crosstalk_report["delta_e"],
            "crosstalk_primality_preserved_sample": crosstalk_report["primality_preserved"],
            "fermat_n35_success": fermat_results[0]["success"],
            "fermat_n143_success": fermat_results[1]["success"],
        },
    }
    path = export_pauli_invariance_json(analysis, args.out)

    sample = DEFAULT_SAMPLES[0]
    tensor_analysis = build_tensor_invariant_analysis(
        sample["bx"],
        sample["by"],
        sample["cx"],
        sample["cy"],
        ax=sample["ax"],
        ay=sample["ay"],
    )
    tensor_path = export_tensor_invariants_json(tensor_analysis, TENSOR_OUT)

    print("Phaseninvarianz Pauli energy export")
    print(f"Tag: {PHASENINVARIANZ_TAG}")
    print(f"samples={len(reports)}")
    print(f"export: {path}")
    print("sample report:")
    sample = reports[0]
    print(
        f"  E_a: {sample['e_a_before']:.4f} "
        f"(Z->{sample['e_a_after_z']:.4f}, X->{sample['e_a_after_x']:.4f})"
    )
    print(
        f"  E_bc: {sample['e_bc_before']:.4f} "
        f"-> tensorX {sample['e_bc_after_tensor_x']:.4f} "
        f"invariant={sample['invariant_under_tensor_x']}"
    )
    print("fermat factorization (PI-C-04):")
    for case in fermat_results:
        print(
            f"  n={case['n']}: factors={case['factor1']}×{case['factor2']} "
            f"ΔE={case['delta_e']} success={case['success']}"
        )
    print(
        f"  local Pauli 15/15 invariant: {tensor_audit['summary']['all_bc_invariant']}; "
        f"crosstalk ΔE={crosstalk_report['delta_e']:.4f}"
    )
    print(
        f"tensor invariants: {tensor_analysis['summary']['bc_invariant_count']}/"
        f"{tensor_analysis['summary']['total_operators']} -> {tensor_path}"
    )


if __name__ == "__main__":
    main()
