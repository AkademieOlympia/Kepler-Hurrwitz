"""Tests for EABC candidate quadruplet index Φ(Q)."""

from __future__ import annotations

from kepler_hurwitz.eabc_candidate_quad_index import (
    K_PATTERNS,
    PATTERNS,
    PATTERN_RANK,
    enumerate_candidates_in_interval,
    enumerate_prime_quad_anchors,
    global_phi,
    index_all_between_quads,
    local_index,
)


def test_K_is_16_patterns():
    assert K_PATTERNS == 16
    assert len(PATTERNS) == 16
    assert PATTERN_RANK[PATTERNS[0]] == 1
    assert PATTERN_RANK[PATTERNS[-1]] == 16


def test_local_index_monotone_in_block():
    # p_k=5 → lo=13; block base 30
    Q1 = (31, 37, 41, 47)  # residues 1,7,11,17
    Q2 = (31, 37, 41, 59)  # 1,7,11,29 — different pattern, same x1
    m1, r1, I1, _ = local_index(Q1, 5)
    m2, r2, I2, _ = local_index(Q2, 5)
    assert m1 == m2 == (31 // 30) - (13 // 30)
    assert r1 != r2
    assert I1 == K_PATTERNS * m1 + r1


def test_enumerate_gap_after_5():
    anchors = enumerate_prime_quad_anchors(500)
    assert anchors[0] == 5
    assert anchors[1] == 101  # non-overlapping next candle
    chunk = enumerate_candidates_in_interval(5, 101, k=1, phi_offset=0)
    assert len(chunk) > 0
    assert all(13 < c.Q[0] and c.Q[-1] < 101 for c in chunk)
    locs = [c.I_local for c in chunk]
    assert len(locs) == len(set(locs))
    # I_local monotone in strict x1
    ordered = sorted(chunk, key=lambda c: c.I_local)
    for a, b in zip(ordered, ordered[1:]):
        if a.Q[0] != b.Q[0]:
            assert a.Q[0] < b.Q[0]


def test_phi_injective_and_monotone():
    rows = index_all_between_quads(400)
    assert len(rows) > 10
    assert len({c.Phi for c in rows}) == len(rows)
    dense = global_phi(rows)
    assert [c.Phi for c in dense] == list(range(1, len(dense) + 1))
    for a, b in zip(dense, dense[1:]):
        if a.Q[0] != b.Q[0]:
            assert a.Q[0] < b.Q[0]
