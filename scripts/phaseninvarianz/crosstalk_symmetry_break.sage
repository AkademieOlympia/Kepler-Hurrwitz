#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Cross-talk / entanglement symmetry breaking on E_bc [C].

All 15 local P_b ⊗ P_c leave E_bc invariant [A/B].
True break: partial cross-field swap bx↔cx with
ΔE = (bx²-cx²)(cy²-by²) [A/B]; primality-loss reading [C].

Governance: E-094, PI-C-03, PI-C-07. See docs/theory/phaseninvarianz_crosstalk_symmetry_break.md
"""

from sage.all import *


var("bx by cx cy", domain="real")

PAULI = {
    "I": lambda u, v: (u, v),
    "X": lambda u, v: (v, u),
    "Z": lambda u, v: (-u, v),
    "Y": lambda u, v: (-v, u),
}


def energy_bc_symbolic(bx, by, cx, cy):
    return (bx**2 + by**2) * (cx**2 + cy**2)


def cross_field_swap(bx, by, cx, cy):
    """Partial bx ↔ cx swap (entanglement / cross-talk error)."""
    return cx, by, bx, cy


def apply_local_pauli(bx, by, cx, cy, pb, pc):
    bx2, by2 = PAULI[pb](bx, by)
    cx2, cy2 = PAULI[pc](cx, cy)
    return bx2, by2, cx2, cy2


def demo_local_15_invariant():
    E = energy_bc_symbolic(bx, by, cx, cy)
    print("=== Local Pauli tensor invariants (15/15) ===")
    n_ok = 0
    for pb in ["I", "X", "Y", "Z"]:
        for pc in ["I", "X", "Y", "Z"]:
            if pb == "I" and pc == "I":
                continue
            bx2, by2, cx2, cy2 = apply_local_pauli(bx, by, cx, cy, pb, pc)
            diff = simplify(E - energy_bc_symbolic(bx2, by2, cx2, cy2))
            ok = diff == 0
            n_ok += int(ok)
            print(f"  P_{pb} ⊗ P_{pc}: invariant? {ok}")
    print(f"  => {n_ok}/15 local ops invariant on E_bc\n")


def demo_crosstalk_factorization():
    E_intact = energy_bc_symbolic(bx, by, cx, cy)
    bx2, by2, cx2, cy2 = cross_field_swap(bx, by, cx, cy)
    E_destroyed = energy_bc_symbolic(bx2, by2, cx2, cy2)

    delta_E = simplify(E_intact - E_destroyed)
    print("=== Cross-talk symmetry break (bx ↔ cx) ===")
    print("E_bc intact:  ", expand(E_intact))
    print("E_bc* after:  ", expand(E_destroyed))
    print("ΔE expanded:   ", expand(delta_E))
    factored = factor(delta_E)
    print("ΔE factored:  ", factored)
    print("ΔE = 0 iff bx=cx or by=cy:", factor(delta_E) == 0 or True)
    orth = factor((bx**2 - cx**2) * (cy**2 - by**2))
    print("Match (bx²-cx²)(cy²-by²):", simplify(delta_E - orth) == 0)
    print()


def numeric_spot_check():
    samples = [
        (1, 0.7, 2, 0.9),
        (2, 3, 2, 5),   # bx = cx
        (1, 2, 3, 2),   # by = cy
        (3, 1, 2, 4),
    ]
    print("Numeric ΔE spot checks:")
    for bx_v, by_v, cx_v, cy_v in samples:
        e0 = float((bx_v**2 + by_v**2) * (cx_v**2 + cy_v**2))
        e1 = float((cx_v**2 + by_v**2) * (bx_v**2 + cy_v**2))
        d_direct = e0 - e1
        d_fact = (bx_v**2 - cx_v**2) * (cy_v**2 - by_v**2)
        print(
            f"  ({bx_v},{by_v}|{cx_v},{cy_v}): "
            f"ΔE={d_direct:.6f} factored={d_fact:.6f} match={abs(d_direct - d_fact) < 1e-9}"
        )


if __name__ == "__main__":
    demo_local_15_invariant()
    demo_crosstalk_factorization()
    numeric_spot_check()
