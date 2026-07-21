"""Tests for §5.22 arithmetic Φ_k relation classifier [B]."""

from __future__ import annotations

import random

from kepler_hurwitz.eabc_lift_coherence import (
    MAT_E00,
    MAT_E01,
    classify_bool_matrix,
    edge_relation,
    matrices_equal,
    relation_matrix,
)
from kepler_hurwitz.eabc_modular_wrap_surgery import build_modular_graph, cut_graph
from kepler_hurwitz.eabc_relation_classifier_phi_k import (
    FOCUS_SPECS,
    is_cyclic_E00_power_E01,
    phi_k_refined,
    phi_k_stated,
    run_phi_k_audit,
    v2_3u1,
)


def test_matrix_shapes():
    assert matrices_equal(MAT_E00, [[1, 0], [0, 0]])
    assert matrices_equal(MAT_E01, [[0, 1], [0, 0]])


def test_phi_stated_on_small_residues():
    # 1: ν₂(4)=2 → E00 for k>2
    assert v2_3u1(1) == 2
    assert phi_k_stated(1, 4) == "E00"
    # 3: ν₂(10)=1 → stated E01
    assert v2_3u1(3) == 1
    assert phi_k_stated(3, 4) == "E01"
    # 5: ν₂(16)=4 → Z for k=4
    assert v2_3u1(5) == 4
    assert phi_k_stated(5, 4) == "Z"


def test_refined_matches_lift_matrix_k4_to_8():
    rng = random.Random(42)
    for k in range(4, 9):
        g, meta = build_modular_graph(k)
        g1, _ = build_modular_graph(k + 1)
        nodes = list(g.keys())
        sample = nodes if len(nodes) <= 40 else rng.sample(nodes, 40)
        for u in sample:
            v = g[u]
            actual = classify_bool_matrix(relation_matrix(edge_relation(u, v, k, g1)))
            assert phi_k_refined(meta[u], k) == actual


def test_cut_edges_are_E00_and_stated_fails_on_v1():
    for k in range(4, 9):
        g, meta = build_modular_graph(k)
        cut, _, _, _ = cut_graph(g, meta)
        g1, _ = build_modular_graph(k + 1)
        saw_v1 = False
        for u, v in cut.items():
            actual = classify_bool_matrix(relation_matrix(edge_relation(u, v, k, g1)))
            assert actual == "E00"
            assert phi_k_refined(meta[u], k) == "E00"
            if meta[u].valuation == 1:
                saw_v1 = True
                assert phi_k_stated(u, k) == "E01"
                assert phi_k_stated(u, k) != actual
        assert saw_v1  # classifier gap is witnessed


def test_cyclic_word_helper():
    assert is_cyclic_E00_power_E01(["E00", "E00", "E01"])
    assert is_cyclic_E00_power_E01(["E01", "E00", "E00"])
    assert not is_cyclic_E00_power_E01(["E00", "E01", "E01"])
    assert not is_cyclic_E00_power_E01(["E00", "E00"])


def test_focus_audit_k10_14():
    report = run_phi_k_audit(10, 14)
    finding = report["audit_finding"]
    assert finding["refined_classifier_holds_on_F_k"] is True
    assert finding["stated_classifier_holds_on_G_k_cut"] is False
    assert finding["G_k_cut_acyclic_in_range"] is True
    assert finding["G_k_cut_edges_all_E00"] is True
    assert finding["focus_refined_match"] is True
    assert finding["focus_cyclic_word_E00_pow_E01"] is True
    assert finding["focus_MatchesUnitDefectPattern"] is True
    assert report["claim_wall"]["NOT_collatz"] is True
    assert len(report["focus_cycles"]) == len(FOCUS_SPECS)
    for row in report["focus_cycles"]:
        assert row["refined_match_rate"] == 1.0
        assert row["cyclic_word_E00_pow_E01"] is True
        assert row["BoolTrace"] == 0
        assert row["CycleLiftable"] is False
        assert row["in_G_k_cut"] is False
        assert row["n_wrap_edges"] == 1
