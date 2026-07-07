#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
EABC six-state / mod-6 prime-axis simulation (sibling to E-093).

Maps naturals mod 6 to imaginary quaternion basis labels {a,b,c,ab,ac,bc};
primes p > 3 occupy only the conjugate pair (a, bc). Gap transitions among
consecutive primes are classified as same-axis or conjugate-flip [C].

Governance: [A/B] residue facts; [C] quaternion conjugation reading.
Does not replace mod-12 E/A/B/C channel partition in signatures.py.
"""

from sage.all import *
import json
import sys

SIX_STATES = ("a", "b", "c", "ab", "ac", "bc")

MOD6_TO_STATE = {
    0: "c",
    1: "a",
    2: "ac",
    3: "ab",
    4: "b",
    5: "bc",
}

PRIME_AXIS_STATES = frozenset(["a", "bc"])


def get_eabc_state(n):
    if n < 1:
        raise ValueError("n must be >= 1")
    return MOD6_TO_STATE[int(n) % 6]


def classify_gap_mod6(gap):
    if gap < 0:
        raise ValueError("gap must be >= 0")
    residue = int(gap) % 6
    if residue == 0:
        return "same_axis"
    if residue in (2, 4):
        return "conjugate_flip"
    return "other"


def prime_gap_transition(p1, p2):
    if p2 <= p1:
        raise ValueError("require p2 > p1")
    gap = int(p2) - int(p1)
    state1 = get_eabc_state(p1)
    state2 = get_eabc_state(p2)
    gap_class = classify_gap_mod6(gap)
    axis_flip = gap_class == "conjugate_flip" and (
        state1 in PRIME_AXIS_STATES and state2 in PRIME_AXIS_STATES
    )
    return {
        "p1": int(p1),
        "p2": int(p2),
        "gap": gap,
        "state1": state1,
        "state2": state2,
        "gap_class": gap_class,
        "axis_flip": axis_flip,
        "tag": "[C]",
    }


def analyze_prime_transitions(limit):
    limit = int(limit)
    if limit < 2:
        return []
    primes = list(primes(limit))
    return [prime_gap_transition(p1, p2) for p1, p2 in zip(primes, primes[1:])]


def print_mod6_table():
    print("mod-6 → six-state EABC map [A/B]:")
    for r in range(6):
        blocked = " (blocked for p>3)" if r in (0, 2, 3, 4) else ""
        print(f"  {r} → {MOD6_TO_STATE[r]}{blocked}")
    print("  prime axis: a (6k+1), bc (6k-1 ≡ 5 mod 6)")


def main():
    limit = 100
    as_json = False
    args = sys.argv[1:]
    if "--json" in args:
        as_json = True
        args = [a for a in args if a != "--json"]
    if args:
        limit = int(args[0])

    if as_json:
        print(json.dumps(analyze_prime_transitions(limit), indent=2))
        return

    print_mod6_table()
    print()
    rows = analyze_prime_transitions(limit)
    print(f"Consecutive prime transitions up to {limit} (count={len(rows)}):")
    for row in rows[:20]:
        flip = "flip" if row["axis_flip"] else "hold"
        print(
            f"  ({row['p1']},{row['p2']}) gap={row['gap']} "
            f"{row['state1']}→{row['state2']} [{row['gap_class']}/{flip}]"
        )
    if len(rows) > 20:
        print("  ...")


if __name__ == "__main__":
    main()
