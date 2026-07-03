from kepler_hurwitz.octonionic_slice import (
    circle_invariant_residual,
    circle_locus_mu_s_residual,
    classify_slice_point,
    intersection_points,
    is_admissible_interference,
    lambda_norm,
    lambda_trace,
    quartic_locus_mu_s_residual,
    quartic_invariant_residual,
    quartic_locus_residual,
    resultant_mu_residual,
    resultant_s_residual,
)


def test_intersection_points_are_on_both_loci():
    points = intersection_points()
    assert len(points) == 2
    for point in points:
        assert classify_slice_point(point.mu, point.q) == "both"


def test_trace_norm_residuals_for_known_circle_point():
    mu = -2.0
    q = 0.0
    trace = lambda_trace(mu)
    norm = lambda_norm(mu, q)
    assert circle_invariant_residual(trace, norm) == 0.0


def test_quartic_trace_norm_has_known_zero():
    # For trace=0 and norm=0, N^2 + (3T + 1)N - 4T^2 - 28T = 0.
    assert quartic_invariant_residual(0.0, 0.0) == 0.0


def test_mu_s_residuals_match_mu_q_forms():
    mu = -2.5
    q = (15**0.5) / 2.0
    s = q**2
    assert quartic_locus_mu_s_residual(mu, s) == quartic_locus_residual(mu, q)
    assert abs(circle_locus_mu_s_residual(mu, s)) < 1e-12


def test_interference_point_is_strictly_admissible():
    mu = -2.5
    s = 15.0 / 4.0
    assert abs(resultant_mu_residual(mu)) < 1e-12
    assert abs(resultant_s_residual(s)) < 1e-12
    assert is_admissible_interference(mu, s) is True


def test_non_interference_point_is_not_admissible():
    mu = -2.0
    s = 4.0
    assert is_admissible_interference(mu, s) is False
