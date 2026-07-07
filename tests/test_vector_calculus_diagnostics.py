"""Symbolic Green/Stokes tests (SageMath required)."""

import pytest

pytest.importorskip("sage.all")

from kepler_hurwitz.vector_calculus_diagnostics import (  # noqa: E402
    VECTOR_CALCULUS_TAG,
    verify_greens_stokes_symbolic,
    verify_greens_theorem_example,
    verify_stokes_theorem_example,
)


class TestSymbolicGreenStokes:
    def test_tag_is_b(self):
        assert VECTOR_CALCULUS_TAG == "[B]"

    @pytest.mark.parametrize("radius", [1, 2, 3, 5])
    def test_green_symbolic(self, radius):
        result = verify_greens_theorem_example(radius)
        assert result.verified
        assert str(result.line_integral) == str(result.area_integral)

    @pytest.mark.parametrize("radius", [1, 2, 3])
    def test_stokes_symbolic(self, radius):
        result = verify_stokes_theorem_example(radius)
        assert result.verified
        assert str(result.line_integral) == str(result.area_integral)

    def test_green_equals_stokes_on_disk(self):
        results = verify_greens_stokes_symbolic(3)
        assert results["green"].area_integral == results["stokes"].area_integral
