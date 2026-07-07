#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Pauli-symplectic [[5,1,3]] stabilizer bridge for L(s, chi_{-3}) zero gaps [C].

Projects nearest-neighbor gaps Delta gamma onto 15 non-trivial symplectic states
in GF(2)^4 \\ {0}. Sibling to ``eabc_symplectic_stabilizer_bridge.py``.

Governance: [C] QEC analogy only; fundamental_freq=3.208 not preregistered.
"""

from sage.all import *

FUNDAMENTAL_FREQ_DEFAULT = 3.208

FIRST_L_CHI_MINUS3_ZEROS = [
    8.0397, 11.2492, 15.7049, 16.7369, 20.4559,
    22.1952, 26.0645, 27.6087, 31.0264, 33.5135,
]


def gap_to_symplectic_stabilizer(gap, fundamental_freq=FUNDAMENTAL_FREQ_DEFAULT):
    """
    Map gap modulo fundamental_freq to symplectic vector (x|z) and stabilizer S_i.

    Returns (symplectic_vector, state_idx, phase).
    """
    phase = (gap % fundamental_freq) / fundamental_freq
    state_idx = int(phase * 15) + 1
    binary_str = format(state_idx, "04b")
    symplectic_vector = "({} | {})".format(binary_str[:2], binary_str[2:])
    return symplectic_vector, state_idx, phase


def analyze_stabilizer_bridge(gammas=None, fundamental_freq=FUNDAMENTAL_FREQ_DEFAULT):
    """Print gap table and return list of (gamma_n, gap, symp_vec, state_idx)."""
    if gammas is None:
        gammas = FIRST_L_CHI_MINUS3_ZEROS
    rows = []
    print("gamma_n\t\tGap (Delta)\tSymplektisch (X|Z)\tStabilisator")
    print("-" * 75)
    for i in range(len(gammas) - 1):
        g1 = float(gammas[i])
        g2 = float(gammas[i + 1])
        gap = g2 - g1
        symp_vec, stat_id, _phase = gap_to_symplectic_stabilizer(gap, fundamental_freq)
        print("{:.4f}\t\t{:.4f}\t\t{}\t\tS_{}".format(g1, gap, symp_vec, stat_id))
        rows.append((g1, gap, symp_vec, stat_id))
    return rows


def stabilizer_histogram(rows):
    """Count S_1..S_15 from analyze_stabilizer_bridge output."""
    hist = {i: 0 for i in range(1, 16)}
    for _g1, _gap, _symp, stat_id in rows:
        hist[stat_id] += 1
    return hist


if __name__ == "__main__":
    print("[[5,1,3]] symplectic L-gap bridge [C] (E-093 / BH-C-09)")
    rows = analyze_stabilizer_bridge()
    hist = stabilizer_histogram(rows)
    print("\nStabilisator-Histogramm:")
    for idx in range(1, 16):
        if hist[idx]:
            print("  S_{}: {}".format(idx, hist[idx]))
