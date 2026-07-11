#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
EABC Riemann-zero / a-vs-bc axis resonance monopole test [C] — Sage driver.

Compares cosine partial sums on the mod-6 prime axes (a, bc) at zeta zero
imaginary parts gamma_n. Tries lcalc.zeros(); falls back to built-in gammas.

Governance: [C] interpretive — no RH claim, no discovery without preregistration.
See docs/theory/eabc_riemann_axis_monopole.md and monopole_gap_test.sage (E-093).
"""

from sage.all import *
import math
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "src"))

from kepler_hurwitz.eabc_monopole_axis_resonance import (  # noqa: E402
    FIRST_RIEMANN_ZEROS,
    MONOPOLE_AXIS_TAG,
    analyze_zero_axis_resonance,
    get_prime_axes,
)

FALLBACK_GAMMAS = list(FIRST_RIEMANN_ZEROS[:10])


def load_gammas(count=10):
    """Try lcalc.zeros(); fallback to built-in FIRST_RIEMANN_ZEROS."""
    try:
        from sage.libs.pari.convert_sage import gen_to_sage
        import lcalc

        raw = lcalc.zeros(count)
        return [float(gen_to_sage(z)) for z in raw]
    except Exception:
        return list(FIRST_RIEMANN_ZEROS[:count])


def demo_axis_resonance(prime_limit=10000, zero_count=10):
    gammas = load_gammas(zero_count)
    records = analyze_zero_axis_resonance(gammas, prime_limit)
    axis_a, axis_bc = get_prime_axes(prime_limit)
    print(f"EABC monopole axis resonance {MONOPOLE_AXIS_TAG}")
    print(f"prime_limit={prime_limit}, |a|={len(axis_a)}, |bc|={len(axis_bc)}, zeros={len(gammas)}")
    for rec in records[:5]:
        print(
            f"  gamma={rec.gamma:.6f}  res_a={rec.res_a:+.6f}  res_bc={rec.res_bc:+.6f}  "
            f"delta={rec.delta:+.6f}  dominant={rec.dominant_axis}"
        )
    return records


if __name__ == "__main__":
    limit = 10000
    n_zeros = 10
    if len(sys.argv) > 1:
        limit = int(sys.argv[1])
    if len(sys.argv) > 2:
        n_zeros = int(sys.argv[2])
    demo_axis_resonance(prime_limit=limit, zero_count=n_zeros)
