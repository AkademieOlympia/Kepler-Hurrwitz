"""Tests für den Funktionsgraph-Scanner (Phase A/B) [B]."""

from __future__ import annotations

import pytest

from kepler_hurwitz.graph_analyzer import (
    GOVERNANCE,
    analyze_quotient_dynamics,
    classify_function_graph,
    require,
)


class TestRequire:
    def test_passes_on_true(self) -> None:
        require(True, "should not raise")

    def test_raises_on_false(self) -> None:
        with pytest.raises(RuntimeError, match="AUDIT FAILED"):
            require(False, "broken")


class TestClassifyFunctionGraph:
    def test_closed_universe_enforced(self) -> None:
        states = (0, 1)

        def step(x: int) -> int:
            return x + 1  # leaves universe

        with pytest.raises(RuntimeError, match="verlässt den Zustandsraum"):
            classify_function_graph(states, step)

    def test_weak_component_count_two_fixed_points(self) -> None:
        # Two isolated fixed points ⇒ two weak components.
        states = (0, 1)

        def step(x: int) -> int:
            return x

        result = classify_function_graph(states, step)
        assert result["weak_components_count"] == 2
        assert result["attraktor_cycles_count"] == 2
        assert result["basin_sizes"] == (1, 1)
        assert result["nonconstant_invariant_possible"] is True
        assert GOVERNANCE in str(result["governance"])

    def test_weakly_connected_single_cycle_basin(self) -> None:
        # 0 → 1 → 2 → 1  (cycle 1↔2, basin {0})
        states = (0, 1, 2)
        nxt = {0: 1, 1: 2, 2: 1}

        result = classify_function_graph(states, nxt.__getitem__)
        assert result["weak_components_count"] == 1
        assert result["attraktor_cycles_count"] == 1
        assert result["basin_sizes"] == (3,)
        assert result["nonconstant_invariant_possible"] is False
        cycles = result["attractor_cycles"]
        assert len(cycles) == 1
        assert set(cycles[0]) == {1, 2}


class TestAnalyzeQuotientDynamics:
    def test_identity_invariant_detection(self) -> None:
        states = (0, 1, 2, 3)
        # Two basins of fixed points; parity is invariant.
        nxt = {0: 0, 1: 1, 2: 2, 3: 3}

        result = analyze_quotient_dynamics(states, nxt.__getitem__, lambda x: x % 2)
        assert result["type"] == "exact_invariant"
        assert result["induced_map"] == {0: 0, 1: 1}

    def test_cyclic_covariance_detection(self) -> None:
        # Cycle 0→1→2→0; observable = identity ⇒ induced σ is the 3-cycle.
        states = (0, 1, 2)
        nxt = {0: 1, 1: 2, 2: 0}

        result = analyze_quotient_dynamics(states, nxt.__getitem__, lambda x: x)
        assert result["type"] == "cyclic_covariance"
        assert result["induced_map"] == {0: 1, 1: 2, 2: 0}

    def test_ambiguous_no_closed_quotient(self) -> None:
        # Even nodes disagree: 0→0 (even), 2→1 (odd) ⇒ parity not single-valued.
        states = (0, 1, 2)
        nxt = {0: 0, 1: 2, 2: 1}

        result = analyze_quotient_dynamics(states, nxt.__getitem__, lambda x: x % 2)
        assert result["type"] == "no_closed_quotient"
        assert 0 in result["ambiguous_entries"]
        assert set(result["ambiguous_entries"][0]) == {0, 1}
