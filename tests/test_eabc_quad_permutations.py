"""Tests for Π(Q) permutation fine-structure on the K=16 lattice."""

from __future__ import annotations

from kepler_hurwitz.eabc_candidate_quad_index import (
    ALL_PERMUTATIONS_S4,
    BLOCKED_PERMUTATIONS,
    COLOR_TAU,
    K_PATTERNS,
    REALIZABLE_PERMUTATIONS,
    audit_pi_shift30_color_tau,
    classification_triple,
    color_tau,
    enumerate_candidates_in_interval,
    pattern_permutation_table,
    permutation_of,
    shift_Q_by_30,
    tau_permutation,
)


def test_s4_cardinality_and_split():
    assert len(ALL_PERMUTATIONS_S4) == 24
    assert len(REALIZABLE_PERMUTATIONS) == 14
    assert len(BLOCKED_PERMUTATIONS) == 10
    assert REALIZABLE_PERMUTATIONS.isdisjoint(BLOCKED_PERMUTATIONS)
    assert REALIZABLE_PERMUTATIONS | BLOCKED_PERMUTATIONS == ALL_PERMUTATIONS_S4


def test_ceab_and_abce_are_realizable_via_parity():
    # Same residue pattern (11,13,17,19): even block → CEAB, odd → ABCE
    table = pattern_permutation_table()
    pat = (11, 13, 17, 19)
    assert table[pat]["even"] == "CEAB"
    assert table[pat]["odd"] == "ABCE"
    assert "CEAB" in REALIZABLE_PERMUTATIONS
    assert "ABCE" in REALIZABLE_PERMUTATIONS


def test_blocked_include_leading_A_heavy_words():
    # Geometrically blocked inside a single 30-block (examples)
    for w in ("ACBE", "CABE", "EACB"):
        assert w in BLOCKED_PERMUTATIONS


def test_permutation_of_and_triple():
    # odd block base 30: (41,43,47,49) = pattern (11,13,17,19) → ABCE
    Q = (41, 43, 47, 49)
    assert permutation_of(Q) == "ABCE"
    chunk = enumerate_candidates_in_interval(5, 101, k=1, phi_offset=0)
    hit = next(c for c in chunk if c.Q == Q)
    assert hit.Pi == "ABCE"
    assert hit.r <= K_PATTERNS
    assert classification_triple(hit) == (hit.Phi, hit.r, "ABCE")


def test_each_pattern_has_two_parity_images():
    table = pattern_permutation_table()
    assert len(table) == K_PATTERNS
    for pat, sides in table.items():
        assert sides["even"] in REALIZABLE_PERMUTATIONS
        assert sides["odd"] in REALIZABLE_PERMUTATIONS
        # parity typically flips the word (not always distinct, but usually)
        assert len(sides["even"]) == 4


def test_color_tau_is_involution_EB_AC():
    assert COLOR_TAU == {"E": "B", "B": "E", "A": "C", "C": "A"}
    for c in "EABC":
        assert color_tau(color_tau(c)) == c
    assert tau_permutation("CEAB") == "ABCE"
    assert tau_permutation("ABCE") == "CEAB"


def test_pi_shift30_equals_tau_pi_on_k16_lattice():
    """[B] audit of [A] law Π(Q+30)=τ(Π(Q)); |R|=14 stays finite-lattice only."""
    report = audit_pi_shift30_color_tau()
    assert report["pi_shift30_equals_tau"] is True
    assert report["failures"] == []
    assert report["tau_closes_realizable"] is True
    assert report["tau_closes_blocked"] is True
    # Finite K=16 finding — do not promote to all K
    assert report["realizable_card"] == 14
    assert report["blocked_card"] == 10
    Q = (11, 13, 17, 19)
    assert permutation_of(Q) == "CEAB"
    assert permutation_of(shift_Q_by_30(Q)) == "ABCE"
    assert permutation_of(shift_Q_by_30(Q)) == tau_permutation(permutation_of(Q))
