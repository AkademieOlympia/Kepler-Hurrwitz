"""Tests for Tao-inspired Collatz diagnostics."""

from __future__ import annotations

import pytest

from kepler_hurwitz.tao_collatz_diagnostics import (
    KLEIN_MOD8_CLASSES,
    Integer,
    active_sample_count_by_position,
    batch_first_passage_by_mod8,
    batch_first_passage_experiment,
    batch_fixed_threshold_first_passage_summaries,
    discrete_log_odd_sample,
    effective_profile_steps,
    first_passage_syracuse,
    free_geom2_distance_excluding_position_0,
    geom2_collective_profile_distance,
    geom2_profile_distance,
    lag1_autocorrelation,
    log_uniform_odd_sample,
    log_uniform_odd_sample_mod8,
    pair_distribution_l1_deviation,
    positional_geom2_distances,
    relative_net_descent_threshold,
    syracuse,
    syracuse_valuation_profile,
    syracuse_valuation_profile_censored,
    v2,
)


class TestV2:
    def test_v2_known_values(self):
        assert v2(12) == 2
        assert v2(7) == 0

    def test_v2_bit_trick_matches_loop(self):
        for n in (2, 4, 8, 12, 16, 24, 1024):
            assert v2(n) == (n & -n).bit_length() - 1

    def test_v2_accepts_integer_alias(self):
        assert v2(Integer(12)) == 2

    def test_v2_invalid(self):
        with pytest.raises(ValueError, match="n must be positive"):
            v2(0)


class TestSyracuse:
    def test_syracuse_n7(self):
        assert syracuse(7) == 11

    def test_syracuse_requires_odd(self):
        with pytest.raises(ValueError, match="n must be odd"):
            syracuse(8)


class TestValuationProfile:
    def test_profile_length(self):
        profile = syracuse_valuation_profile(7, 5)
        assert len(profile) == 5
        assert profile == [1, 1, 2, 3, 4]

    def test_profile_zero_steps(self):
        assert syracuse_valuation_profile(7, 0) == []

    def test_profile_censor_stops_at_syracuse_one(self):
        # S(5)=1 in one step; uncensored would repeat v2(4)=2 forever.
        assert syracuse_valuation_profile(5, 100, censor_at_one=True) == [4]
        assert syracuse_valuation_profile_censored(5, 100) == [4]
        uncensored = syracuse_valuation_profile(5, 5, censor_at_one=False)
        assert len(uncensored) == 5
        assert uncensored == [4, 2, 2, 2, 2]

    def test_effective_profile_steps_cap(self):
        assert effective_profile_steps(1000, 64, steps_cap_log_n=None) == 64
        capped = effective_profile_steps(
            1000, 64, steps_cap_log_n=1.0, steps_cap_coefficient=0.25
        )
        assert capped == max(1, int(0.25 * __import__("math").log(1000)))
        assert capped < 64


class TestFirstPassage:
    def test_first_passage_small_n(self):
        result = first_passage_syracuse(27, threshold=10, max_steps=200)
        assert result["hit"] is True
        assert isinstance(result["time"], int)
        assert result["time"] >= 1
        assert isinstance(result["location"], int)
        assert result["location"] <= 10

    def test_first_passage_already_below_threshold(self):
        result = first_passage_syracuse(7, threshold=100, max_steps=50)
        assert result == {"hit": True, "time": 0, "location": 7}

    def test_relative_net_descent_threshold(self):
        assert relative_net_descent_threshold(27) == 13
        assert relative_net_descent_threshold(7) == 3


class TestGeom2Distance:
    def test_geom2_distance_synthetic_profile(self):
        # Empirical P(1)=P(2)=0.5 vs Geom(2); tail-corrected TV at max_k=2 is 0.25.
        distance = geom2_profile_distance([1, 2, 1, 2], max_k=2)
        assert distance == pytest.approx(0.25)

    def test_geom2_distance_tail_correction_formula(self):
        counts = {1: 2, 2: 2}
        distances = {
            k: abs((counts.get(k, 0) / 4.0) - (0.5**k)) for k in (1, 2)
        }
        tail_mass = 0.25
        assert geom2_profile_distance(counts, max_k=2) == pytest.approx(
            0.5 * (sum(distances.values()) + tail_mass)
        )

    def test_geom2_distance_all_ones_far_from_geom2(self):
        distance = geom2_profile_distance([1, 1, 1, 1], max_k=1)
        assert distance == pytest.approx(0.5)

    def test_geom2_collective_matches_pooled_counts(self):
        profiles = [[1, 2], [1, 2]]
        assert geom2_collective_profile_distance(profiles, max_k=2) == geom2_profile_distance(
            [1, 2, 1, 2], max_k=2
        )

    def test_free_geom2_excludes_position_zero(self):
        profiles = [[1, 2, 1], [3, 2, 2]]
        free = free_geom2_distance_excluding_position_0(profiles, max_k=3)
        pooled_tail = [2, 1, 2, 2]
        assert free == geom2_profile_distance(pooled_tail, max_k=3)
        collective = geom2_collective_profile_distance(profiles, max_k=3)
        assert free != collective


class TestAutocorrelationAndPositional:
    def test_lag1_autocorrelation_increasing_positive(self):
        assert lag1_autocorrelation([1, 2, 3, 4]) == pytest.approx(1.0 / 3.0)

    def test_lag1_autocorrelation_alternating_negative(self):
        assert lag1_autocorrelation([1, 3, 1, 3]) < 0

    def test_lag1_autocorrelation_too_short(self):
        assert lag1_autocorrelation([1]) is None

    def test_positional_geom2_distances(self):
        profiles = [[1, 2, 1], [1, 2, 2]]
        distances = positional_geom2_distances(profiles, max_k=2)
        assert set(distances) == {0, 1, 2}
        assert distances[0] == geom2_profile_distance([1, 1], max_k=2)

    def test_pair_distribution_l1_deviation_independent_profile(self):
        profiles = [[1, 2], [1, 2]]
        assert pair_distribution_l1_deviation(profiles) == pytest.approx(0.0)

    def test_active_sample_count_decreases_with_absorption(self):
        profiles = [
            syracuse_valuation_profile_censored(5, 64),
            syracuse_valuation_profile_censored(7, 64),
            syracuse_valuation_profile_censored(27, 64),
        ]
        counts = active_sample_count_by_position(profiles)
        assert counts["0"] == 3
        assert counts["1"] <= counts["0"]
        assert counts[str(max(int(k) for k in counts))] <= counts["0"]
        assert any(
            counts[str(j)] < counts[str(j - 1)]
            for j in range(1, max(int(k) for k in counts) + 1)
        )


class TestSamplingAndBatch:
    def test_log_uniform_odd_sample(self):
        n = log_uniform_odd_sample(1_000_000, rng=__import__("random").Random(0))
        assert 3 <= n <= 1_000_000
        assert n % 2 == 1

    def test_discrete_log_odd_sample(self):
        rng = __import__("random").Random(0)
        n = discrete_log_odd_sample(100, rng=rng)
        assert 3 <= n <= 100
        assert n % 2 == 1

    def test_batch_first_passage_experiment_relative(self):
        result = batch_first_passage_experiment(
            limit=10_000,
            threshold="relative",
            samples=20,
            seed=42,
            max_steps=500,
        )
        assert len(result["rows"]) == 20
        summary = result["summary"]
        assert summary["samples"] == 20
        assert summary["threshold_mode"] == "relative"
        assert summary["status"] == "[B] numerical diagnostic"
        assert "tail_corrected_tv_mean" in summary
        assert "lag1_autocorr_mean" in summary
        assert "positional_geom2" in summary
        assert 0.0 <= summary["hit_rate"] <= 1.0
        for row in result["rows"]:
            assert row.threshold == row.n // 2

    def test_batch_fixed_threshold_summaries(self):
        result = batch_fixed_threshold_first_passage_summaries(
            limit=10_000,
            thresholds=[10, 100],
            samples=10,
            seed=7,
            max_steps=500,
            profile_steps=16,
        )
        fixed = result["tao_fixed_thresholds"]
        assert set(fixed) == {"10", "100"}
        assert fixed["10"]["threshold_type"] == "Tao-style fixed-x first passage"

    def test_log_uniform_odd_sample_mod8(self):
        rng = __import__("random").Random(7)
        for residue in KLEIN_MOD8_CLASSES:
            n = log_uniform_odd_sample_mod8(10_000, residue, rng=rng)
            assert 3 <= n <= 10_000
            assert n % 2 == 1
            assert n % 8 == residue

    def test_batch_first_passage_by_mod8(self):
        result = batch_first_passage_by_mod8(
            limit=10_000,
            threshold="relative",
            samples=8,
            seed=42,
            max_steps=500,
        )
        assert set(result["classes"]) == set(KLEIN_MOD8_CLASSES)
        assert len(result["rows"]) == 8 * len(KLEIN_MOD8_CLASSES)
        assert result["censor_at_one"] is True
        for residue in KLEIN_MOD8_CLASSES:
            summary = result["classes"][residue]
            assert summary["mod8"] == residue
            assert summary["samples"] == 8
            assert 0.0 <= summary["hit_rate"] <= 1.0
            assert "collective_geom2_distance" in summary
            assert "free_geom2_distance_excluding_position_0" in summary
            assert "geom2_delta_start" in summary
            assert "geom2_delta_free" in summary
            assert "active_sample_count_by_position" in summary
            assert summary["position_0_interpretation"] == (
                "deterministic mod-8 channel signature"
            )
            assert "tail_corrected_tv_mean" in summary
            assert "lag1_autocorr_mean" in summary
            assert "positional_geom2" in summary
            assert summary["collective_valuation_samples"] <= 8 * 64
            counts = summary["active_sample_count_by_position"]
            assert counts["0"] == 8
            assert counts["1"] <= counts["0"]
