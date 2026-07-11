#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Monopole gap test — stabilizer phase pairs vs. GUE spacing heuristic [C].

Compares nearest-neighbor spacings of normalized stabilizer phases to the Wigner
surmise for GUE (Riemann zero analogy language). Destructive interference in
stabilizer space is read alongside zeros on Re(s)=1/2 — no RH claim.

Governance: [C] statistical analogy only.
"""

from sage.all import *
import random


def wigner_gue_surmise(s):
    """GUE nearest-neighbor spacing surmise P(s) = (32/pi^2) s^2 exp(-4 s^2/pi)."""
    if s < 0:
        return 0.0
    return float(32 / pi**2 * s**2 * exp(-4 * s**2 / pi))


def normalized_spacings(phases):
    """Sorted phases on [0,1) -> unfolded nearest-neighbor spacings (toy)."""
    xs = sorted(phases)
    if len(xs) < 2:
        return []
    gaps = [xs[i + 1] - xs[i] for i in range(len(xs) - 1)]
    mean_gap = sum(gaps) / len(gaps) if gaps else 1.0
    if mean_gap == 0:
        return gaps
    return [g / mean_gap for g in gaps]


def gue_histogram_score(spacings, bins=10):
    """
    Toy score: L1 distance between empirical spacing histogram and GUE surmise grid.
    Lower is closer to GUE-like (exploratory only).
    """
    if not spacings:
        return None
    edges = [i / bins for i in range(bins + 1)]
    hist = [0] * bins
    width = 1.0 / bins
    for s in spacings:
        idx = min(bins - 1, int(s / width))
        hist[idx] += 1
    total = sum(hist)
    emp = [h / total for h in hist]
    mid = [(edges[i] + edges[i + 1]) / 2 for i in range(bins)]
    ref = [wigner_gue_surmise(m) * width for m in mid]
    norm = sum(ref)
    if norm > 0:
        ref = [r / norm for r in ref]
    return float(sum(abs(e - r) for e, r in zip(emp, ref)))


def demo_monopole_gap(n_phases=50, seed=93):
    rng = random.Random(seed)
    phases = [rng.random() for _ in range(n_phases)]
    spacings = normalized_spacings(phases)
    score = gue_histogram_score(spacings)
    print(f"Monopole gap test [C]: n={n_phases}, GUE L1 score={score}")


if __name__ == "__main__":
    demo_monopole_gap()
