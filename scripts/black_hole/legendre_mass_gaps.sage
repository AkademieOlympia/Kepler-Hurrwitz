#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Legendre mass gaps for EABC quaternion norms (Projekt Black Hole, E-093).

Computes integers forbidden by Legendre's three-squares theorem and induced
forbidden mass shells m from prime norms p = m^2 + s^2.

Governance: [A/B] algebraic — no gravitational-wave claim.
"""

from sage.all import *
import sys


def is_forbidden_by_legendre(n):
    """True iff n = 4^a * (8b + 7)."""
    if n < 0:
        return False
    while n % 4 == 0 and n > 0:
        n //= 4
    return n % 8 == 7


def get_forbidden_mass_integers(max_norm=500):
    forbidden = set()
    for p in primes(max_norm):
        for m in range(isqrt(p) + 1):
            s_squared = p - m**2
            if s_squared >= 0 and is_forbidden_by_legendre(s_squared):
                forbidden.add(m)
    return sorted(forbidden)


def main():
    max_norm = 500
    if len(sys.argv) > 1:
        max_norm = int(sys.argv[1])
    forbidden = get_forbidden_mass_integers(max_norm=max_norm)
    print(f"Legendre forbidden mass shells (max_norm={max_norm}, count={len(forbidden)}):")
    print(forbidden[:30])
    if len(forbidden) > 30:
        print("...")


if __name__ == "__main__":
    main()
