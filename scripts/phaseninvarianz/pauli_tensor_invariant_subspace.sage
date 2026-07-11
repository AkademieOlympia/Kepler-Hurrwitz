#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Pauli tensor invariant subspace on bc-axis quartic energy [C].

Apply all 15 non-trivial tensor products P_b ⊗ P_c to
E_bc = (bx^2+by^2)(cx^2+cy^2), with single-qubit Pauli on each amplitude pair.

Governance: E-094, PI-C-02. See docs/theory/phaseninvarianz_tensor_invariant_subspace.md
"""

from sage.all import *


var("bx by cx cy", domain="real")

PAULI_OPS = ["I", "X", "Y", "Z"]


def energy_bc_symbolic(bx, by, cx, cy):
    return (bx**2 + by**2) * (cx**2 + cy**2)


def apply_pauli_to_pair(op, vx, vy):
    if op == "I":
        return vx, vy
    if op == "X":
        return vy, vx
    if op == "Z":
        return vx, -vy
    if op == "Y":
        return -vy, vx
    raise ValueError(f"Unknown Pauli op: {op}")


def tensor_operators():
    return [
        f"{ob}{oc}"
        for ob in PAULI_OPS
        for oc in PAULI_OPS
        if not (ob == "I" and oc == "I")
    ]


def analyze_invariant_subspaces():
    """Symbolic audit of all 15 tensor operators on E_bc."""
    E_bc = energy_bc_symbolic(bx, by, cx, cy)
    records = []
    inv_count = 0

    for op in tensor_operators():
        ob, oc = op[0], op[1]
        bx2, by2 = apply_pauli_to_pair(ob, bx, by)
        cx2, cy2 = apply_pauli_to_pair(oc, cx, cy)
        E_after = energy_bc_symbolic(bx2, by2, cx2, cy2)
        diff = simplify(E_bc - E_after)
        is_inv = bool(diff == 0)
        if is_inv:
            inv_count += 1
        records.append((op, is_inv, diff))
        print(f"  {op}: invariant={is_inv}")

    print(f"\ninvariant_count={inv_count}/15")
    print(f"all_invariant={inv_count == 15}")
    return records, inv_count


def demo_pair_invariance():
    """Show each single-qubit Pauli preserves E_pair = vx^2 + vy^2."""
    var("vx vy", domain="real")
    E_pair = vx**2 + vy**2
    print("Single-pair Pauli invariance on E_pair = vx^2 + vy^2:")
    for op in PAULI_OPS:
        vx2, vy2 = apply_pauli_to_pair(op, vx, vy)
        diff = simplify(E_pair - (vx2**2 + vy2**2))
        print(f"  {op}: invariant={diff == 0}")


if __name__ == "__main__":
    demo_pair_invariance()
    print("\nTensor subspace on E_bc:")
    analyze_invariant_subspaces()
