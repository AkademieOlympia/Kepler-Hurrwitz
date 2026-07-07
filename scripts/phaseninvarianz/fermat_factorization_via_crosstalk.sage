#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Fermat factorization bridge via EABC cross-talk ΔE [C].

ΔE = (bx²-cx²)(cy²-by²) = (bx-cx)(bx+cx)(cy-by)(cy+by).
Composite n on bc-axis (n ≡ 5 mod 6): amplitude patterns reconstruct factors.

Governance: E-094, PI-C-04. See docs/theory/phaseninvarianz_fermat_factorization_bridge.md
"""

from sage.all import *


var("bx cx by cy", domain="real")


def delta_e_symbolic(bx, by, cx, cy):
  return (bx**2 - cx**2) * (cy**2 - by**2)


def fermat_split_unit(f):
  """Odd f = (bx-cx)(bx+cx) with bx-cx = 1."""
  if f <= 0 or f % 2 == 0:
    raise ValueError("require positive odd f")
  bx = (f + 1) / 2
  cx = (f - 1) / 2
  return bx, cx


def amplitudes_for_semiprime(n):
  if n <= 3 or n % 6 != 5:
    return None
  fac = factor(n)
  if len(fac) != 2 or any(e != 1 for _, e in fac):
    return None
  p, q = [int(pr) for pr, _ in fac]
  bx, cx = fermat_split_unit(p)
  cy, by = fermat_split_unit(q)
  return dict(n=n, p=p, q=q, bx=bx, cx=cx, by=by, cy=cy,
              delta=float(delta_e_symbolic(bx, by, cx, cy)))


def demo_factorization_identity():
  print("=== ΔE four linear factors (symbolic) ===")
  dE = delta_e_symbolic(bx, by, cx, cy)
  print("ΔE =", expand(dE))
  lin = (bx - cx) * (bx + cx) * (cy - by) * (cy + by)
  print("linear product =", expand(lin))
  print("match:", simplify(dE - lin) == 0)
  print()


def demo_n35():
  print("=== n = 35 = 5 × 7 (bc-axis) ===")
  rec = amplitudes_for_semiprime(35)
  print(rec)
  bx, cx, by, cy = rec["bx"], rec["cx"], rec["by"], rec["cy"]
  print(f"  bx={bx}, cx={cx} => bx²-cx² = {bx**2 - cx**2}")
  print(f"  cy={cy}, by={by} => cy²-by² = {cy**2 - by**2}")
  print(f"  ΔE = {rec['delta']}")
  print()


def demo_n143():
  print("=== n = 143 = 11 × 13 (bc-axis) ===")
  rec = amplitudes_for_semiprime(143)
  print(rec)
  print(f"  ΔE = {rec['delta']}")
  print()


if __name__ == "__main__":
  demo_factorization_identity()
  demo_n35()
  demo_n143()
