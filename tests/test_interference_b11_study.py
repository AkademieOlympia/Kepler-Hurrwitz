from kepler_hurwitz.interference_b11_study import run_interference_b11_study


def test_interference_b11_study_at_canonical_point_has_no_violations():
    result = run_interference_b11_study(
        limit_m=2001,
        b_bound=11,
        mu=-2.5,
        s=15.0 / 4.0,
    )
    assert result.is_interference_admissible is True
    assert result.evaluated_count == result.sample_count
    assert result.violation_count == 0
    assert result.violating_residues == ()
    assert result.b11_hit_rate == 1.0


def test_interference_b11_study_blocks_non_admissible_point():
    result = run_interference_b11_study(
        limit_m=2001,
        b_bound=11,
        mu=-2.0,
        s=4.0,
    )
    assert result.is_interference_admissible is False
    assert result.evaluated_count == 0
