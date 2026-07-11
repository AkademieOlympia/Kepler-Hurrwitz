#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Pauli phase invariance on EABC quadratic/quartic energy terms [C].

Pauli Z (ax -> -ax) and X (ax <-> ay) leave E_a = ax^2 + ay^2 invariant [A/B].
Partial tensor X on bc (bx <-> cx) restructures quartic cross terms — generally
not invariant; bivector channel needs full QEC [C].

Governance: E-094, PI-C-01.. See docs/theory/phaseninvarianz_pauli_energy_bridge.md
"""

from sage.all import *


var("ax ay bx by cx cy", domain="real")


def energy_a_symbolic(ax, ay):
    return ax**2 + ay**2


def energy_bc_symbolic(bx, by, cx, cy):
    return (bx**2 + by**2) * (cx**2 + cy**2)


def apply_pauli_z_a(ax, ay):
    return -ax, ay


def apply_pauli_x_a(ax, ay):
    return ay, ax


def apply_tensor_x_bc(bx, by, cx, cy):
    return cx, by, bx, cy


def demo_invariance():
    E_a = energy_a_symbolic(ax, ay)
    E_bc = energy_bc_symbolic(bx, by, cx, cy)

  # Z invariance
    ax_z, ay_z = apply_pauli_z_a(ax, ay)
    z_diff = simplify(E_a - energy_a_symbolic(ax_z, ay_z))
    print("Pauli Z on a-axis: E_a invariant?", z_diff == 0)

  # X invariance
    ax_x, ay_x = apply_pauli_x_a(ax, ay)
    x_diff = simplify(E_a - energy_a_symbolic(ax_x, ay_x))
    print("Pauli X on a-axis: E_a invariant?", x_diff == 0)

  # Partial tensor X on bc
    bx2, by2, cx2, cy2 = apply_tensor_x_bc(bx, by, cx, cy)
    tensor_diff = simplify(E_bc - energy_bc_symbolic(bx2, by2, cx2, cy2))
    print("Partial tensor X on bc: E_bc invariant?", tensor_diff == 0)
    print("  (special case bx=cx or by=cy only)")

  # Cross-term restructuring
    terms_before = expand(E_bc)
    terms_after = expand(energy_bc_symbolic(bx2, by2, cx2, cy2))
    print("\nE_bc before:", terms_before)
    print("E_bc after tensor X:", terms_after)
    print("Cross-term diff:", simplify(terms_before - terms_after))


def numeric_spot_check():
    samples = [
        (1, 2, 3, 4, 5, 6),
        (2, 3, 1, 0, 4, 2),
        (1, 1, 2, 2, 2, 2),  # symmetric special case
    ]
    print("\nNumeric spot checks:")
    for ax_v, ay_v, bx_v, by_v, cx_v, cy_v in samples:
        e_a = float(ax_v**2 + ay_v**2)
        e_a_z = float((-ax_v)**2 + ay_v**2)
        e_a_x = float(ay_v**2 + ax_v**2)
        e_bc = float((bx_v**2 + by_v**2) * (cx_v**2 + cy_v**2))
        e_bc_err = float((cx_v**2 + by_v**2) * (bx_v**2 + cy_v**2))
        print(
            f"  ({ax_v},{ay_v}|{bx_v},{by_v},{cx_v},{cy_v}): "
            f"Z={e_a==e_a_z} X={e_a==e_a_x} tensorX={e_bc==e_bc_err}"
        )


if __name__ == "__main__":
    demo_invariance()
    numeric_spot_check()
