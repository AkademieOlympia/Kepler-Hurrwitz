#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Dirichlet chi_{-3} conjugator — lightweight Sage cross-check [C].

Verifies chi_{-3} on small primes and compares partial L(s, chi) sums to the
Python module ``eabc_dirichlet_chi_minus3``.

Governance: [C] interpretive; no RH claim.
"""

from sage.all import *
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.eabc_dirichlet_chi_minus3 import (  # noqa: E402
    chi_minus3,
    compute_l_chi_partial_sum,
    compare_zeta_vs_lchi_axis_resonance,
)
from kepler_hurwitz.eabc_monopole_axis_resonance import FIRST_RIEMANN_ZEROS  # noqa: E402


def sage_kronecker(n):
    """Kronecker symbol (3/n) matches chi_{-3} for n > 0."""
    return kronecker(3, n)


def main():
    print("[C] chi_{-3} conjugator Sage cross-check")
    for p in primes(50):
        py = chi_minus3(int(p))
        sg = sage_kronecker(int(p))
        assert py == sg, f"mismatch at p={p}: py={py} sage={sg}"
    print("  chi_{-3} agrees with kronecker(3,n) for primes <= 50")

    s_real = 2.0
    limit = 10_000
    py_sum = compute_l_chi_partial_sum(s_real, limit)
    sage_sum = sum(sage_kronecker(int(p)) * float(p) ** (-s_real) for p in primes(limit))
    print(f"  L-partial sum Re(s)={s_real}, limit={limit}:")
    print(f"    python: {py_sum:.8f}")
    print(f"    sage:   {sage_sum:.8f}")

    gamma = float(FIRST_RIEMANN_ZEROS[0])
    cmp = compare_zeta_vs_lchi_axis_resonance(gamma, 5_000)
    print(f"  resonance gamma={gamma:.4f}:")
    print(f"    psi_a - psi_bc = {cmp.delta_unweighted:.6f}")
    print(f"    lchi_weighted  = {cmp.lchi_weighted_sum:.6f}")
    print(f"    asymmetry_ratio = {cmp.asymmetry_ratio:.6f}")
    print("  done.")


if __name__ == "__main__":
    main()
