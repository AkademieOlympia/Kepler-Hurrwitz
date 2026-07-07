"""Tests for Projekt Black Hole GWTC vs. Legendre gap diagnostics (E-093 / ORQ-093)."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
GWOSC_FIXTURE = ROOT / "data" / "black_hole" / "gwosc_fixture.csv"

from kepler_hurwitz.black_hole_legendre_gwtc import (
    BLACK_HOLE_TAG,
    GOVERNANCE,
    build_black_hole_analysis,
    calculate_pgap_monte_carlo,
    export_black_hole_bundle,
    fisher_exact,
    generate_split_normal_samples,
    get_forbidden_mass_integers,
    is_forbidden_by_legendre,
    load_gwtc_catalog,
    load_official_gwtc_catalog,
    mock_gwtc5_events,
    permutation_null_model,
    permutation_test_mc,
    run_eabc_statistical_test,
    sweep_kappa,
)


class TestLegendreCore:
    def test_tag_is_c(self):
        assert BLACK_HOLE_TAG == "[C]"

    def test_seven_forbidden(self):
        assert is_forbidden_by_legendre(7)
        assert is_forbidden_by_legendre(15)  # 8*1+7
        assert not is_forbidden_by_legendre(6)

    def test_four_adic_stripping(self):
        assert is_forbidden_by_legendre(28)  # 4*7

    def test_forbidden_mass_list_nonempty(self):
        forbidden = get_forbidden_mass_integers(max_norm=100)
        assert forbidden
        assert all(isinstance(m, int) for m in forbidden)


class TestFisherExact:
    def test_less_alternative_small_p(self):
        table = [[2, 18], [12, 8]]
        odds, p = fisher_exact(table, alternative="less")
        assert odds is not None
        assert 0.0 <= p <= 1.0

    def test_empty_table(self):
        odds, p = fisher_exact([[0, 0], [0, 0]])
        assert p == 1.0


class TestGwtcPipeline:
    def test_mock_events_count(self):
        events = mock_gwtc5_events(n_events=50, seed=1)
        assert len(events) == 50
        assert all(0.0 <= e.chi_p <= 1.0 for e in events)

    def test_statistical_test_runs(self):
        events = mock_gwtc5_events(n_events=100, seed=93)
        forbidden = get_forbidden_mass_integers(max_norm=200)
        result = run_eabc_statistical_test(events, forbidden, quantization_scale=1.0)
        matrix = result.table.as_matrix()
        assert sum(sum(row) for row in matrix) == 100
        assert 0.0 <= result.p_value <= 1.0

    def test_kappa_sweep_monotone_grid(self):
        events = mock_gwtc5_events(n_events=40, seed=7)
        forbidden = get_forbidden_mass_integers(max_norm=150)
        points = sweep_kappa(
            events,
            forbidden,
            kappa_min=0.1,
            kappa_max=0.5,
            kappa_step=0.1,
        )
        assert len(points) == 5

    def test_governance_fields(self):
        analysis = build_black_hole_analysis(kappa_sweep=False, permutation_null=False)
        assert analysis.governance["status"] == GOVERNANCE["status"]
        assert "not_claimed" in analysis.governance


class TestExport:
    def test_export_bundle_writes_json(self, tmp_path: Path):
        analysis = build_black_hole_analysis(
            mock_gwtc5_events(30),
            kappa_sweep=False,
            permutation_null=False,
        )
        paths = export_black_hole_bundle(analysis, tmp_path)
        summary = json.loads(paths["summary"].read_text(encoding="utf-8"))
        assert summary["evidence_id"] == "E-093"
        assert summary["governance"] == "[C]"


class TestGwoscLoader:
    def test_fixture_loads_gwosc_columns(self):
        assert GWOSC_FIXTURE.is_file()
        events = load_official_gwtc_catalog(GWOSC_FIXTURE)
        assert len(events) == 6  # one row dropped (NaN chi_p)
        assert events[0].event_id == "GW150914"
        assert events[0].m1_solar == pytest.approx(35.6)
        assert events[0].chi_p == pytest.approx(0.05)
        assert events[0].m1_source_lower == pytest.approx(34.0)
        assert events[0].m1_source_upper == pytest.approx(37.0)

    def test_load_gwtc_catalog_auto_detect(self):
        events = load_gwtc_catalog(GWOSC_FIXTURE)
        assert len(events) == 6

    def test_skips_comment_header_lines(self, tmp_path: Path):
        path = tmp_path / "gwosc_comment.csv"
        path.write_text(
            "# GWOSC metadata\n"
            "commonName,mass_1_source,mass_2_source,chi_p\n"
            "GWTEST,10.0,8.0,0.1\n",
            encoding="utf-8",
        )
        events = load_official_gwtc_catalog(path)
        assert len(events) == 1
        assert events[0].event_id == "GWTEST"


class TestPermutationNull:
    def test_mock_catalog_p_near_half(self):
        events = mock_gwtc5_events(n_events=300, seed=71)
        forbidden = get_forbidden_mass_integers(max_norm=300)
        result = permutation_null_model(
            events,
            forbidden,
            kappa=1.0,
            tau=0.5,
            iterations=500,
            seed=71,
        )
        assert 0.15 <= result.p_value <= 0.85
        assert result.obs_1g_in_gap >= 0
        assert result.iterations == 500
        assert result.null_max >= result.null_min

    def test_integrated_in_analysis_export(self, tmp_path: Path):
        analysis = build_black_hole_analysis(
            mock_gwtc5_events(80, seed=7),
            kappa_sweep=False,
            permutation_null=True,
            permutation_iterations=200,
            permutation_seed=7,
        )
        assert analysis.permutation_null is not None
        paths = export_black_hole_bundle(analysis, tmp_path)
        summary = json.loads(paths["summary"].read_text(encoding="utf-8"))
        assert summary["permutation_null"] is not None
        assert "p_value" in summary["permutation_null"]


class TestMonteCarloPgap:
    def test_split_normal_positive_masses(self):
        import random

        rng = random.Random(0)
        samples = generate_split_normal_samples(35.0, 1.6, 1.4, n_samples=500, rng=rng)
        assert len(samples) == 500
        assert all(s > 0 for s in samples)

    def test_pgap_in_unit_interval(self):
        import random

        forbidden = get_forbidden_mass_integers(max_norm=200)
        p = calculate_pgap_monte_carlo(
            35.0,
            1.0,
            1.0,
            forbidden,
            kappa=1.0,
            tau=0.5,
            n_samples=200,
            rng=random.Random(1),
        )
        assert 0.0 <= p <= 1.0

    def test_uncertainty_spanning_gap_higher_pgap(self):
        import random

        forbidden = get_forbidden_mass_integers(max_norm=500)
        # Pick a median with zero point-mass P_gap
        p_point = 1.0
        median_far = 100.0
        for trial in range(200):
            candidate = 20.0 + trial * 0.5
            p_point = calculate_pgap_monte_carlo(
                candidate,
                None,
                None,
                forbidden,
                kappa=1.0,
                tau=0.5,
                n_samples=200,
                rng=random.Random(2),
            )
            if p_point == 0.0:
                median_far = candidate
                break
        assert p_point == 0.0
        target_m = forbidden[10] if len(forbidden) > 10 else forbidden[0]
        p_wide = calculate_pgap_monte_carlo(
            float(target_m),
            8.0,
            8.0,
            forbidden,
            kappa=1.0,
            tau=0.5,
            n_samples=300,
            rng=random.Random(3),
        )
        assert p_wide > p_point

    def test_permutation_mc_reasonable_p(self):
        events = mock_gwtc5_events(n_events=300, seed=71)
        forbidden = get_forbidden_mass_integers(max_norm=300)
        result = permutation_test_mc(
            events,
            forbidden,
            kappa=1.0,
            tau=0.5,
            iterations=500,
            n_mc_samples=100,
            seed=71,
        )
        assert 0.0 <= result.p_value <= 1.0
        assert 0.15 <= result.p_value <= 0.85
        assert len(result.per_event_p_gaps) == 300

    def test_gwosc_fixture_mc_runs(self):
        events = load_official_gwtc_catalog(GWOSC_FIXTURE)
        forbidden = get_forbidden_mass_integers(max_norm=300)
        result = permutation_test_mc(
            events,
            forbidden,
            iterations=100,
            n_mc_samples=100,
            seed=11,
        )
        assert len(result.per_event_p_gaps) == len(events)
        assert all(0.0 <= p <= 1.0 for p in result.per_event_p_gaps)

    def test_integrated_mc_export(self, tmp_path: Path):
        analysis = build_black_hole_analysis(
            mock_gwtc5_events(40, seed=3),
            kappa_sweep=False,
            permutation_null=True,
            use_monte_carlo=True,
            permutation_iterations=100,
            mc_samples=100,
            permutation_seed=3,
        )
        assert analysis.use_monte_carlo
        assert analysis.permutation_null is None
        assert analysis.permutation_null_mc is not None
        paths = export_black_hole_bundle(analysis, tmp_path)
        summary = json.loads(paths["summary"].read_text(encoding="utf-8"))
        assert summary["monte_carlo"] is True
        assert summary["fisher_deprecated_when_mc_active"] is True
        assert summary["permutation_null_mc"] is not None
