#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
EABC 2G merger heuristic — non-commutative multiplication response to Legendre blockade.

When s^2 = p - m^2 is forbidden (form 4^a(8b+7)), the model reads hierarchical merger
as the algebraic escape route via non-commutative quaternion multiplication (2G channel).

Governance: [C] interpretive — documents reading language only.
"""

from sage.all import *


def legendre_blockade_class(n):
    """Strip 4-adic factors and return (a_mod, residue mod 8) for obstruction diagnosis."""
    if n < 0:
        return None
    a = 0
    while n % 4 == 0 and n > 0:
        n //= 4
        a += 1
    return (a, n % 8)


def is_legendre_blocked(n):
    a, r = legendre_blockade_class(n)
    return r == 7


def merger_escape_label(s_squared):
    """
    Classify spin norm obstruction for merger reading language.

    Returns '1G_blocked' if three-squares obstruction active, else '1G_admissible'.
    2G merger is the [C] interpretive dual — not computed as physics.
    """
    if is_legendre_blocked(s_squared):
        return "1G_blocked -> 2G_merger[C]"
    return "1G_admissible"


def demo_merger_table(max_p=50):
    print("p | m | s^2 | merger_reading")
    for p in primes(max_p):
        for m in range(isqrt(p) + 1):
            s2 = p - m**2
            if s2 >= 0 and is_legendre_blocked(s2):
                print(f"{p} | {m} | {s2} | {merger_escape_label(s2)}")


if __name__ == "__main__":
    demo_merger_table()
