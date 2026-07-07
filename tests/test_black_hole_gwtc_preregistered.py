"""Tests for GWTC preregistered Phase-1/2 calibration (BH-GOV-01 / ORQ-093)."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
GWTC3_FIXTURE = ROOT / "data" / "black_hole" / "gwosc_gwtc3_fixture.csv"

from kepler_hurwitz.black_hole_gwtc_preregistered import (
    PHASE1_N_TESTS,
    PREREGISTRATION_PATH,
    bonferroni_alpha_phase1,
    export_phase1_json,
    filter_events_for_preregistration,
    kappa_grid,
    load_and_filter_catalog,
    run_phase1_calibration,
    run_phase2_verification,
    tau_grid,
)


class TestPreregistrationGrid:
    def test_kappa_grid_size(self) -> None:
        grid = kappa_grid()
        assert len(grid) == 46
        assert grid[0] == pytest.approx(0.5)
        assert grid[-1] == pytest.approx(5.0)

    def test_tau_grid(self) -> None:
        assert tau_grid() == [0.25, 0.5]

    def test_total_tests(self) -> None:
        assert len(kappa_grid()) * len(tau_grid()) == PHASE1_N_TESTS == 92

    def test_bonferroni_alpha(self) -> None:
        alpha = bonferroni_alpha_phase1()
        assert alpha == pytest.approx(0.05 / 92)

    def test_preregistration_path_exists(self) -> None:
        assert PREREGISTRATION_PATH.is_file()
        assert "preregistration_gwtc5" in PREREGISTRATION_PATH.name


class TestEventFilter:
    def test_fixture_filters_m1_and_bounds(self) -> None:
        filtered, all_loaded = load_and_filter_catalog(GWTC3_FIXTURE)
        assert len(all_loaded) == 18
        assert len(filtered) == 18
        for event in filtered:
            assert event.m1_solar >= event.m2_solar
            assert event.m1_source_lower is not None
            assert event.m1_source_upper is not None

    def test_excludes_swapped_primary_without_bounds(self) -> None:
        from kepler_hurwitz.black_hole_legendre_gwtc import GwtcEvent

        events = [
            GwtcEvent(10.0, 30.0, 0.1, m1_source_lower=9.0, m1_source_upper=11.0),
            GwtcEvent(30.0, 10.0, 0.1, m1_source_lower=28.0, m1_source_upper=32.0),
            GwtcEvent(25.0, 10.0, 0.1),
        ]
        out = filter_events_for_preregistration(events)
        assert len(out) == 1
        assert out[0].m1_solar == 30.0


class TestPhase1Calibration:
    def test_phase1_runs_on_fixture(self) -> None:
        filtered, _ = load_and_filter_catalog(GWTC3_FIXTURE)
        result = run_phase1_calibration(
            filtered,
            mc_samples=50,
            perm_iterations=50,
            seed=1,
            apply_exclusion_filter=False,
        )
        assert result.n_tests == 92
        assert 0.0 <= result.best_p_value <= 1.0
        assert result.best_kappa in kappa_grid()
        assert result.best_tau in tau_grid()
        assert result.n_events_included == len(filtered)
        assert len(result.grid_results) == 92

    def test_export_json_roundtrip(self, tmp_path: Path) -> None:
        filtered, _ = load_and_filter_catalog(GWTC3_FIXTURE)
        result = run_phase1_calibration(
            filtered,
            mc_samples=30,
            perm_iterations=30,
            seed=2,
            apply_exclusion_filter=False,
        )
        out = tmp_path / "phase1.json"
        export_phase1_json(result, out, data_note="test fixture")
        data = json.loads(out.read_text(encoding="utf-8"))
        assert data["n_tests"] == 92
        assert data["phase"] == 1
        assert "Bonferroni" in data["interpretation"] or "bonferroni" in str(data).lower()


class TestPhase2Stub:
    def test_phase2_single_test(self) -> None:
        filtered, _ = load_and_filter_catalog(GWTC3_FIXTURE)
        phase1 = run_phase1_calibration(
            filtered,
            mc_samples=40,
            perm_iterations=40,
            seed=3,
            apply_exclusion_filter=False,
        )
        phase2 = run_phase2_verification(
            filtered,
            phase1.best_kappa,
            phase1.best_tau,
            mc_samples=40,
            perm_iterations=40,
            seed=4,
            apply_exclusion_filter=False,
        )
        assert phase2.kappa == phase1.best_kappa
        assert phase2.tau == phase1.best_tau
        assert 0.0 <= phase2.p_value <= 1.0
        assert phase2.alpha == pytest.approx(0.05)
        assert isinstance(phase2.significant, bool)
