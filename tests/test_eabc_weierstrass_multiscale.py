"""Tests for EABC Weierstrass multiscale diagnostics [C]."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from kepler_hurwitz.eabc_weierstrass_multiscale import (
    EABC_WEIERSTRASS_TAG,
    abce_ceab_counts,
    bias_difference,
    build_cumulative_bias_series,
    build_multiscale_analysis,
    build_scale_bias_table,
    export_multiscale_bundle,
    orientation_side,
    render_multiscale_report_md,
)
from kepler_hurwitz.primvierling import build_prime_quadruplet, generate_prime_quadruplets


CLASSIC = build_prime_quadruplet(11)


class TestOrientationAndBias:
    def test_tag_is_c(self):
        assert EABC_WEIERSTRASS_TAG == "[C]"

    def test_orientation_side_is_abce_or_ceab(self):
        side = orientation_side(CLASSIC)
        assert side in {"ABCE", "CEAB"}

    def test_bias_difference(self):
        assert bias_difference(7, 5) == 2
        assert bias_difference(5, 5) == 0

    def test_abce_ceab_partition(self):
        abce, ceab = abce_ceab_counts([CLASSIC, build_prime_quadruplet(101)])
        assert abce + ceab == 2


class TestScaleTables:
    @pytest.fixture(scope="class")
    def quadruplets(self):
        return generate_prime_quadruplets(2, 10_000)

    def test_scale_table_monotone_count(self, quadruplets):
        rows = build_scale_bias_table(quadruplets, scales=(10_000,))
        assert len(rows) == 1
        assert rows[0].quadruplet_count == len(quadruplets)

    def test_cumulative_series_length(self, quadruplets):
        cumulative = build_cumulative_bias_series(quadruplets)
        assert len(cumulative) == len(quadruplets)
        assert cumulative[-1].bias_b == bias_difference(*abce_ceab_counts(quadruplets))


class TestMultiscaleAnalysis:
    def test_build_analysis_fast(self):
        analysis = build_multiscale_analysis(max_n=10_000, scales=(10_000,))
        assert analysis.governance == "[C]"
        assert len(analysis.scale_rows) == 1
        assert len(analysis.cumulative_rows) >= 1
        assert len(analysis.autocorrelation) >= 2

    def test_export_bundle(self, tmp_path: Path):
        analysis = build_multiscale_analysis(max_n=10_000, scales=(10_000,))
        paths = export_multiscale_bundle(analysis, tmp_path)
        assert paths["summary_json"].exists()
        payload = json.loads(paths["summary_json"].read_text(encoding="utf-8"))
        assert payload["governance"] == "[C]"
        assert "not_claimed" in payload
        report = paths["report_md"].read_text(encoding="utf-8")
        assert "[C]" in report
        assert render_multiscale_report_md(analysis) == report
