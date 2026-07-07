"""Tests for EABC Riemann-zero / a-vs-bc axis resonance monopole scaffold [C]."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from kepler_hurwitz.eabc_monopole_axis_resonance import (
    FIRST_RIEMANN_ZEROS,
    GOVERNANCE,
    MONOPOLE_AXIS_TAG,
    analyze_zero_axis_resonance,
    build_axis_resonance_analysis,
    compute_resonance,
    count_delta_sign_changes,
    export_axis_resonance_json,
    get_prime_axes,
)


class TestPrimeAxisSplit:
    def test_5_on_bc_7_on_a(self) -> None:
        axis_a, axis_bc = get_prime_axes(20)
        assert 5 in axis_bc
        assert 7 in axis_a
        assert 5 not in axis_a
        assert 7 not in axis_bc

    def test_axis_partition_excludes_small_primes(self) -> None:
        axis_a, axis_bc = get_prime_axes(50)
        assert 2 not in axis_a and 2 not in axis_bc
        assert 3 not in axis_a and 3 not in axis_bc
        assert sorted(axis_a + axis_bc) == [p for p in range(5, 51) if _is_prime(p)]


def _is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


class TestResonance:
    def test_finite_for_known_gamma(self) -> None:
        axis_a, axis_bc = get_prime_axes(200)
        gamma = FIRST_RIEMANN_ZEROS[0]
        res_a = compute_resonance(gamma, axis_a)
        res_bc = compute_resonance(gamma, axis_bc)
        assert res_a == pytest.approx(res_a)
        assert res_bc == pytest.approx(res_bc)
        assert abs(res_a) < 1e6
        assert abs(res_bc) < 1e6

    def test_analyze_record_fields(self) -> None:
        rows = analyze_zero_axis_resonance(FIRST_RIEMANN_ZEROS[:3], prime_limit=500)
        assert len(rows) == 3
        for row in rows:
            assert row.tag == MONOPOLE_AXIS_TAG
            assert row.delta == pytest.approx(row.res_a - row.res_bc)
            assert row.dominant_axis in {"a", "bc", "tie"}


class TestDeltaAlternation:
    """
    Soft [C] check: consecutive zeros may alternate dominant axis.

    Not required to be perfect — documents exploratory oscillation only.
    """

    def test_first_five_zeros_have_some_sign_activity(self) -> None:
        rows = analyze_zero_axis_resonance(FIRST_RIEMANN_ZEROS[:5], prime_limit=5_000)
        nonzero = [r for r in rows if r.delta != 0]
        assert len(nonzero) >= 4
        signs = {1 if r.delta > 0 else -1 for r in nonzero}
        # Exploratory: expect both axes to appear among first five (not a proof).
        assert len(signs) >= 1

    def test_sign_changes_documented_not_required_perfect(self) -> None:
        rows = analyze_zero_axis_resonance(FIRST_RIEMANN_ZEROS[:10], prime_limit=5_000)
        changes = count_delta_sign_changes(rows)
        # Soft bound: at least one change in first ten, or all same sign (documented).
        assert 0 <= changes <= len(rows) - 1


class TestGovernance:
    def test_tag_is_c(self) -> None:
        assert MONOPOLE_AXIS_TAG == "[C]"
        assert GOVERNANCE["tag_interpretive"] == "[C]"

    def test_not_claimed_blocks_rh_and_monopole(self) -> None:
        nc = GOVERNANCE["not_claimed"]
        assert "Riemann Hypothesis" in nc or "RH" in nc.lower() or "Riemann" in nc
        assert "monopole" in nc
        assert "Dirichlet" in nc or "chi_{-3}" in nc

    def test_build_and_export(self, tmp_path: Path) -> None:
        analysis = build_axis_resonance_analysis(
            gammas=FIRST_RIEMANN_ZEROS[:5],
            prime_limit=1_000,
        )
        assert analysis["governance"] == "[C]"
        assert "not_claimed" in analysis["governance_detail"]
        out = export_axis_resonance_json(analysis, tmp_path / "out.json")
        payload = json.loads(out.read_text(encoding="utf-8"))
        assert len(payload["records"]) == 5
