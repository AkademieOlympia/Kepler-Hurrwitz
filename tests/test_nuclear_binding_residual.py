"""Tests for Projekt Atome nuclear binding residual diagnostics (E-092 / ORQ-092)."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from kepler_hurwitz.nuclear_binding_residual import (
    ATOME_TAG,
    WeizsaeckerParams,
    build_atome_analysis,
    build_residual_table,
    correlate_eabc_residuals,
    eabc_invariants,
    export_atome_bundle,
    mutual_information,
    pearson_correlation,
    run_nullmodels,
    spearman_correlation,
    toy_nuclides,
    weizsaecker_binding,
)


class TestWeizsaeckerHull:
    def test_tag_is_c(self):
        assert ATOME_TAG == "[C]"

    def test_he4_binding_positive(self):
        b = weizsaecker_binding(4, 2)
        assert 20.0 < b < 35.0

    def test_rejects_invalid_z(self):
        with pytest.raises(ValueError):
            weizsaecker_binding(10, 12)

    def test_pairing_even_even(self):
        params = WeizsaeckerParams()
        assert params.pairing_delta(4, 2) > 0
        assert params.pairing_delta(5, 3) == 0.0


class TestResidualTable:
    def test_residuals_sum_definition(self):
        nuclides = toy_nuclides()[:5]
        rows = build_residual_table(nuclides)
        for nuclide, row in zip(nuclides, rows, strict=True):
            expected = nuclide.b_exp_mev - weizsaecker_binding(nuclide.a, nuclide.z)
            assert row.residual_mev == pytest.approx(expected)
            assert row.residual_per_nucleon_mev == pytest.approx(row.residual_mev / nuclide.a)


class TestEabcInvariants:
    def test_invariants_independent_of_hull(self):
        inv = eabc_invariants(56, 26, label="Fe-56")
        assert inv.eabc_mass >= 0
        assert inv.chiral_norm >= 0.0
        assert inv.label == "Fe-56"


class TestCorrelations:
    def test_pearson_perfect_positive(self):
        x = [1.0, 2.0, 3.0, 4.0, 5.0]
        assert pearson_correlation(x, x) == pytest.approx(1.0)

    def test_spearman_monotone(self):
        x = [1.0, 2.0, 3.0, 4.0, 5.0]
        y = [2.0, 4.0, 6.0, 8.0, 10.0]
        assert spearman_correlation(x, y) == pytest.approx(1.0)

    def test_mutual_information_positive_for_dependent(self):
        x = [float(i) for i in range(20)]
        y = [2.0 * xi + 1.0 for xi in x]
        mi = mutual_information(x, y)
        assert mi is not None
        assert mi > 0.0

    def test_correlate_battery_runs(self):
        nuclides = toy_nuclides()
        residuals = build_residual_table(nuclides)
        invariants = [eabc_invariants(n.a, n.z, label=n.label) for n in nuclides]
        metrics = correlate_eabc_residuals(residuals, invariants)
        assert len(metrics) >= 4
        assert all(m.feature for m in metrics)


class TestNullmodels:
    def test_nullmodels_return_trials(self):
        nuclides = toy_nuclides()
        residuals = build_residual_table(nuclides)
        invariants = [eabc_invariants(n.a, n.z) for n in nuclides]
        results = run_nullmodels(residuals, invariants, trials=50, seed=1)
        assert len(results) == 3
        assert all(r.trials == 50 for r in results)


class TestAtomeExport:
    def test_build_analysis(self):
        analysis = build_atome_analysis(toy_nuclides(), nullmodel_trials=20)
        assert analysis.governance == "[C]"
        assert analysis.nuclide_count == len(toy_nuclides())
        assert len(analysis.correlations) >= 4

    def test_export_bundle(self, tmp_path: Path):
        analysis = build_atome_analysis(toy_nuclides()[:10], nullmodel_trials=10)
        paths = export_atome_bundle(analysis, tmp_path)
        assert paths["summary_json"].exists()
        payload = json.loads(paths["summary_json"].read_text(encoding="utf-8"))
        assert payload["governance"] == "[C]"
        assert "not_claimed" in payload
        assert paths["residual_csv"].read_text(encoding="utf-8").startswith("label,")
