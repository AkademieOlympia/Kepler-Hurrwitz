import math

from kepler_hurwitz.significance import (
    b_bound_summary,
    b_bound_trend_records,
    b_bound_trends,
    b_bound_matrix_records,
    channel_counts,
    chi_square_smoothness_by_channel,
    scan_b_bound_matrix,
    scale_stability_records,
    scan_scale_stability,
)
from kepler_hurwitz.smoothness_channel_scan import scan_smoothness_channels


def test_channel_counts_cover_all_samples():
    samples = scan_smoothness_channels(limit_m=63, b=5)
    counts = channel_counts(samples)
    assert sum(row.total for row in counts) == len(samples)
    assert [row.channel for row in counts] == ["klein", "mittel", "tief"]


def test_chi_square_result_is_well_formed():
    samples = scan_smoothness_channels(limit_m=1999, b=5)
    result = chi_square_smoothness_by_channel(samples)
    assert result.degrees_of_freedom == 2
    assert result.sample_count == len(samples)
    assert result.chi2 >= 0
    assert 0 <= result.p_value <= 1
    assert 0 <= result.cramers_v <= 1


def test_dof2_pvalue_formula_matches_exp_form():
    samples = scan_smoothness_channels(limit_m=511, b=5)
    result = chi_square_smoothness_by_channel(samples)
    assert math.isclose(result.p_value, math.exp(-result.chi2 / 2), rel_tol=1e-12)


def test_scan_scale_stability_returns_points_in_input_order():
    points = scan_scale_stability(b=5, limits=[999, 1999, 3999])
    assert [point.limit_m for point in points] == [999, 1999, 3999]
    assert all(point.sample_size > 0 for point in points)


def test_scale_stability_records_shape():
    points = scan_scale_stability(b=5, limits=[999, 1999])
    records = scale_stability_records(points)
    assert records[0]["limit_m"] == 999
    assert "cramers_v" in records[0]


def test_scan_b_bound_matrix_shape():
    matrix = scan_b_bound_matrix(b_bounds=[3, 5], limits=[999, 1999])
    assert [row.b_bound for row in matrix] == [3, 5]
    assert all(len(row.results) == 2 for row in matrix)


def test_b_bound_matrix_records_shape():
    matrix = scan_b_bound_matrix(b_bounds=[3, 5], limits=[999])
    records = b_bound_matrix_records(matrix)
    assert records[0]["b_bound"] == 3
    assert records[0]["results"][0]["limit_m"] == 999


def test_b_bound_trends_and_summary_shape():
    matrix = scan_b_bound_matrix(b_bounds=[3, 5], limits=[999, 1999])
    trends = b_bound_trends(matrix)
    records = b_bound_trend_records(trends)
    summary = b_bound_summary(trends, matrix)
    assert len(records) == 2
    assert "stability_score" in records[0]
    assert "most_stable_b_bound" in summary
    assert "max_effect_size_scale_last" in summary
