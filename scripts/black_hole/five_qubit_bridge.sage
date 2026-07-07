#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Five-qubit [[5,1,3]] bridge — Hamilton rule a*b=c as anticommuting stabilizer grammar.

Maps the EABC Hamilton product rule to Pauli stabilizer anticommutation for the
[[5,1,3]] quantum error correcting code. Precession chi_p is read as syndrome
measurement language [C] — not LIGO inference identity.

Governance: [C] QEC analogy only.
"""

from sage.all import *


def pauli_multiply(p1, p2):
    """Multiply two Pauli strings (I,X,Y,Z) with phase tracking mod 4."""
    phase = 0
    out = []
    for a, b in zip(p1, p2):
        table = {
            ("I", "I"): ("I", 0),
            ("I", "X"): ("X", 0),
            ("I", "Y"): ("Y", 0),
            ("I", "Z"): ("Z", 0),
            ("X", "I"): ("X", 0),
            ("X", "X"): ("I", 0),
            ("X", "Y"): ("Z", 2),
            ("X", "Z"): ("Y", 1),
            ("Y", "I"): ("Y", 0),
            ("Y", "X"): ("Z", 3),
            ("Y", "Y"): ("I", 0),
            ("Y", "Z"): ("X", 1),
            ("Z", "I"): ("Z", 0),
            ("Z", "X"): ("Y", 3),
            ("Z", "Y"): ("X", 2),
            ("Z", "Z"): ("I", 0),
        }
        sym, p = table[(a, b)]
        phase = (phase + p) % 4
        out.append(sym)
    return tuple(out), phase


def anticommutes(p1, p2):
    """True if Pauli strings anticommute (odd number of X/Y/Z mismatches on non-identity)."""
    n = 0
    for a, b in zip(p1, p2):
        if a != "I" and b != "I" and a != b:
            n += 1
    return n % 2 == 1


def hamilton_to_stabilizer_reading(a_label, b_label, c_label):
    """
    Abstract [C] reading: channel product a*b=c parallels stabilizer commutation class.
    """
    return {
        "a": a_label,
        "b": b_label,
        "c": c_label,
        "bridge": "[C] Hamilton a*b=c <-> stabilizer syndrome grammar",
    }


# Minimal [[5,1,3]]-style stabilizer sketch (5 physical qubits)
S1 = ("X", "X", "I", "I", "I")
S2 = ("Z", "Z", "Z", "Z", "Z")


def demo_five_qubit():
    print("[[5,1,3]] stabilizer anticommutation demo (E-093 [C]):")
    print(f"S1 = {S1}, S2 = {S2}, anticommute = {anticommutes(S1, S2)}")
    print(hamilton_to_stabilizer_reading("E", "A", "B"))


if __name__ == "__main__":
    demo_five_qubit()
