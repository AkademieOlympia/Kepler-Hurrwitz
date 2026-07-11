#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
EABC dual-axis energy asymmetry — vector a vs bivector bc [C].

a-axis (6k+1): E_a = ax^2 + ay^2  (quadratic, 2 modes)
bc-axis (6k-1): E_b = bx^2 + by^2, E_c = cx^2 + cy^2,
                E_bc = E_b * E_c   (quartic, 4 cross terms)

Sibling to ``eabc_energy_square_sum.py`` / ``eabc_dual_axis_energy_asymmetry`` tests.

Governance: [A/B] algebraic expansion; [C] meson/composite-particle reading.
Does not claim particle-physics proof or QM Hamiltonian identity.
"""

from sage.all import var, expand, SR

var("ax ay bx by cx cy EEG u")

# --- a-axis: vector energy (quadratic) ---
e_i_a = ax**2
e_j_a = ay**2
E_a = e_i_a + e_j_a
total_E_a = EEG * E_a

print("=== EABC dual-axis — vector a-axis (6k+1) ===")
print("E_a = ax^2 + ay^2     =", E_a)
print("total_E_a = EEG * E_a =", expand(total_E_a))
print()

# --- bc-axis: bivector energy (quartic via b x c coupling) ---
E_b = bx**2 + by**2
E_c = cx**2 + cy**2
E_bc = E_b * E_c
total_E_bc = EEG * E_bc

term1 = bx**2 * cx**2
term2 = bx**2 * cy**2
term3 = by**2 * cx**2
term4 = by**2 * cy**2

print("=== bc-axis bivector (6k-1) ===")
print("E_b = bx^2 + by^2     =", E_b)
print("E_c = cx^2 + cy^2     =", E_c)
print("E_bc = E_b * E_c      =", expand(E_bc))
print("four cross terms:")
print("  bx^2*cx^2 =", term1)
print("  bx^2*cy^2 =", term2)
print("  by^2*cx^2 =", term3)
print("  by^2*cy^2 =", term4)
print("sum of four terms   =", expand(term1 + term2 + term3 + term4))
print("total_E_bc = EEG * E_bc =", expand(total_E_bc))
print()

# --- equal-amplitude comparison ---
E_a_u = 2 * u**2
E_bc_u = (2 * u**2) * (2 * u**2)
ratio_u = E_bc_u / E_a_u

print("=== equal amplitudes (ax=ay=bx=by=cx=cy=u) ===")
print("E_a(u)  = 2*u^2       =", E_a_u)
print("E_bc(u) = 4*u^4       =", E_bc_u)
print("E_bc / E_a = 2*u^2   =", expand(ratio_u))
print("at u=1: E_a=2, E_bc=4, ratio=2")
print()

# --- quartic scaling: double all bc amplitudes ---
scale = SR(2)
E_bc_scaled = ((scale * bx)**2 + (scale * by)**2) * ((scale * cx)**2 + (scale * cy)**2)
scaling_factor = expand(E_bc_scaled / E_bc)

print("=== quartic scaling under amplitude doubling ===")
print("E_bc(2*amp) / E_bc(amp) =", scaling_factor)
print("expected: 2^4 = 16")
print()

print("Governance [C]: a = fundamental vector mode; bc = composite bivector (4 coupled amplitudes).")
print("Conjugate pair (a, bc) from six-state prime axes; chi_{-3} sign flip is analytic, not energetic.")
