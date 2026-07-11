"""Tests for Collatz trajectory analytics."""

from __future__ import annotations

import math

import pytest

from kepler_hurwitz.collatz_analytics import (
    GEOMETRIC_MEAN_HEURISTIC,
    collatz_step,
    collatz_trajectory,
    inverse_predecessors,
    stopping_time,
)


class TestCollatzTrajectory:
    def test_trajectory_n7(self):
        assert collatz_trajectory(7) == [
            7,
            22,
            11,
            34,
            17,
            52,
            26,
            13,
            40,
            20,
            10,
            5,
            16,
            8,
            4,
            2,
            1,
        ]
        assert stopping_time(7) == 16

    def test_trajectory_n1(self):
        assert collatz_trajectory(1) == [1]
        assert stopping_time(1) == 0

    def test_invalid_n_raises(self):
        with pytest.raises(ValueError, match="n must be >= 1"):
            collatz_trajectory(0)
        with pytest.raises(ValueError, match="n must be >= 1"):
            stopping_time(-3)

    def test_collatz_step_matches_diagnostics(self):
        assert collatz_step(27) == 82
        assert collatz_step(10) == 5

    def test_inverse_predecessors_tree(self):
        assert inverse_predecessors(1) == (2,)
        assert inverse_predecessors(4) == (8, 1)
        assert inverse_predecessors(10) == (20, 3)

    def test_geometric_mean_heuristic_constant(self):
        assert GEOMETRIC_MEAN_HEURISTIC == pytest.approx(math.sqrt(3) / 2)
