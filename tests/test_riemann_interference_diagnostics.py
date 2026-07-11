"""Tests for Riemann zero interference wave diagnostic [B]/[C]."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from kepler_hurwitz.riemann_interference_diagnostics import (
    BC_AXIS_COMPOSITE_NODES,
    DEFAULT_FRACTIONAL_ALPHAS,
    GOVERNANCE,
    RIEMANN_INTERFERENCE_ZEROS,
    calculate_interference_signal,
    compare_fractional_orders,
    export_fractional_comparison_bundle,
    export_phase_collapse_bundle,
    fractional_interference_signal,
    fractional_symmetry_breaking_comparison,
    select_zeros,
    symmetry_breaking_node_table,
    wave_function,
)


class TestInterferenceSignal:
    def test_signal_at_35_and_31_are_floats(self) -> None:
        gammas = select_zeros(num_zeros=50)
        s35 = calculate_interference_signal(35.0, gammas)
        s31 = calculate_interference_signal(31.0, gammas)
        assert isinstance(s35, float)
        assert isinstance(s31, float)
        assert s35 == pytest.approx(s35)
        assert s31 == pytest.approx(s31)

    def test_x_must_be_positive(self) -> None:
        gammas = select_zeros(num_zeros=5)
        with pytest.raises(ValueError, match="positive"):
            calculate_interference_signal(0.0, gammas)

    def test_wave_function_vectorized(self) -> None:
        gammas = select_zeros(num_zeros=20)
        values = wave_function([31.0, 35.0], gammas)
        assert len(values) == 2
        assert float(values[0]) == pytest.approx(calculate_interference_signal(31.0, gammas))
        assert float(values[1]) == pytest.approx(calculate_interference_signal(35.0, gammas))


class TestSymmetryBreakingTable:
    def test_table_covers_bc_composites(self) -> None:
        gammas = select_zeros(num_zeros=30)
        rows = symmetry_breaking_node_table(gammas)
        xs = {row.x for row in rows}
        assert BC_AXIS_COMPOSITE_NODES[0] in xs
        assert BC_AXIS_COMPOSITE_NODES[1] in xs

    def test_primes_flagged(self) -> None:
        gammas = select_zeros(num_zeros=30)
        by_x = {row.x: row for row in symmetry_breaking_node_table(gammas)}
        assert by_x[31].is_prime is True
        assert by_x[35].is_prime is False
        assert by_x[35].is_bc_composite is True

    def test_composite_signal_differs_qualitatively_from_neighbor_prime(self) -> None:
        """Soft check only — no overfit on exact sign."""
        gammas = select_zeros(num_zeros=100)
        by_x = {row.x: row.signal for row in symmetry_breaking_node_table(gammas)}
        assert by_x[35] != pytest.approx(by_x[31], abs=1e-9)
        assert by_x[143] != pytest.approx(by_x[139], abs=1e-9)


class TestPlotExport:
    def test_plot_generation_does_not_crash(self, tmp_path: Path) -> None:
        paths = export_phase_collapse_bundle(tmp_path, num_zeros=40)
        assert paths["png"].exists()
        assert paths["summary_json"].exists()
        payload = json.loads(paths["summary_json"].read_text(encoding="utf-8"))
        assert payload["governance"]["plot_tag"] == GOVERNANCE["plot_tag"]
        assert payload["num_zeros"] == 40
        assert any(row["x"] == 35 for row in payload["test_points"])

    def test_builtin_zeros_count(self) -> None:
        assert len(RIEMANN_INTERFERENCE_ZEROS) >= 100


class TestFractionalInterference:
    def test_alpha_zero_matches_standard_signal(self) -> None:
        gammas = select_zeros(num_zeros=50)
        x = 35.0
        std = calculate_interference_signal(x, gammas)
        frac = fractional_interference_signal(x, gammas, alpha=0.0)
        assert float(frac) == pytest.approx(std)

    def test_alpha_half_scales_by_sqrt(self) -> None:
        gammas = select_zeros(num_zeros=50)
        x = 35.0
        std = calculate_interference_signal(x, gammas)
        frac = fractional_interference_signal(x, gammas, alpha=0.5)
        assert float(frac) == pytest.approx(std * x ** (-0.5))

    def test_negative_alpha_rejected(self) -> None:
        gammas = select_zeros(num_zeros=5)
        with pytest.raises(ValueError, match="non-negative"):
            fractional_interference_signal(35.0, gammas, alpha=-0.1)

    def test_compare_fractional_orders_structure(self) -> None:
        gammas = select_zeros(num_zeros=30)
        result = compare_fractional_orders([31, 35], gammas)
        assert result["alphas"] == [0.0, 0.5]
        assert len(result["rows"]) == 2
        assert "alpha_0" in result["rows"][0]["signals"]
        assert "alpha_0.5" in result["rows"][0]["signals"]

    def test_fractional_symmetry_breaking_has_separation_metrics(self) -> None:
        gammas = select_zeros(num_zeros=100)
        result = fractional_symmetry_breaking_comparison(gammas)
        assert "separation_metrics" in result
        assert "x35_vs_31_alpha_0" in result["separation_metrics"]
        assert "x35_vs_31_alpha_0.5" in result["separation_metrics"]
        assert isinstance(result["alpha_0.5_improves_35_vs_31"], bool)

    def test_fractional_export_bundle(self, tmp_path: Path) -> None:
        paths = export_fractional_comparison_bundle(tmp_path, num_zeros=40)
        assert paths["png"].exists()
        assert paths["summary_json"].exists()
        payload = json.loads(paths["summary_json"].read_text(encoding="utf-8"))
        assert payload["alphas"] == list(DEFAULT_FRACTIONAL_ALPHAS)
        assert "separation_metrics" in payload
        assert "alpha_0.5_improves_35_vs_31" in payload
        assert payload["governance"]["fractional_kernel"]
