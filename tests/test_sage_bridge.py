import pytest

pytest.importorskip("sage.all")
import sage.all as sage  # type: ignore

from kepler_hurwitz.sage_bridge import (  # noqa: E402
    sage_resultant_mu,
    sage_resultant_Q,
    sage_verify_interference_points,
)


def test_interference_point_is_on_both_loci():
    result = sage_verify_interference_points()
    assert result["on_both"] is True


def test_resultants_are_nonzero():
    assert sage_resultant_mu() != 0
    assert sage_resultant_Q() != 0


def test_resultants_hit_known_interference_projection():
    resultant_mu = sage_resultant_mu()
    resultant_q = sage_resultant_Q()
    assert resultant_mu(-sage.QQ(5) / sage.QQ(2)) == 0
    assert resultant_q(sage.sqrt(sage.QQ(15)) / sage.QQ(2)) == 0
