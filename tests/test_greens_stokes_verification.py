"""Tests for Green–Stokes disk verification (ORQ-089 reference)."""

from __future__ import annotations

import json
import math
from pathlib import Path

import pytest

from kepler_hurwitz.greens_stokes_verification import (
    GREENS_STOKES_TAG,
    analytic_value,
    curl_z_rotation_field,
    export_verification_json,
    greens_scalar_curl,
    line_integral_rotation_field,
    verify_greens_stokes,
)


class TestAnalyticReference:
    def test_tag_is_b(self):
        assert GREENS_STOKES_TAG == "[B]"

    def test_analytic_unit_disk(self):
        assert analytic_value(1.0) == pytest.approx(2.0 * math.pi)

    def test_scalar_curl_and_curl_z_match(self):
        assert greens_scalar_curl() == pytest.approx(curl_z_rotation_field())
        assert greens_scalar_curl() == pytest.approx(2.0)


class TestNumericalVerification:
    def test_line_integral_matches_analytic(self):
        r = 2.5
        line = line_integral_rotation_field(r, n_samples=8192)
        assert line == pytest.approx(analytic_value(r), rel=1e-4)

    def test_greens_and_stokes_match_analytic(self):
        result = verify_greens_stokes(1.0, n_samples=4096)
        assert result.analytic == pytest.approx(2.0 * math.pi)
        assert result.line_integral == pytest.approx(result.analytic, rel=1e-4)
        assert result.greens_double_integral == pytest.approx(result.analytic, rel=1e-3)
        assert result.stokes_surface_integral == pytest.approx(result.analytic, rel=1e-3)
        assert result.green_equals_stokes

    def test_scales_with_radius_squared(self):
        small = verify_greens_stokes(0.5)
        large = verify_greens_stokes(2.0)
        assert large.analytic / small.analytic == pytest.approx(16.0)

    def test_export_json(self, tmp_path: Path):
        result = verify_greens_stokes(1.0)
        path = export_verification_json(result, tmp_path / "verify.json")
        payload = json.loads(path.read_text(encoding="utf-8"))
        assert payload["governance"] == "[B]"
        assert "not_claimed" in payload
