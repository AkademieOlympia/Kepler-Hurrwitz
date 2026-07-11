import math

import pytest

from kepler_hurwitz.shell_embedding_geometry_audit import (
    classify_geometry_row,
    compare_sources,
    distance_spectrum_l2,
    gram_spectrum_l2,
    procrustes_rmsd,
    run_geometry_audit,
)


class TestProcrustesIdentity:
    def test_same_points_near_zero(self):
        pts = [(1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)]
        rmsd = procrustes_rmsd(pts, list(pts), allow_permutation=True)
        assert rmsd == pytest.approx(0.0, abs=1e-10)

    def test_same_points_permuted_near_zero(self):
        pts = [(1.0, 0.0, 0.0), (0.0, 1.0, 0.0)]
        perm = [pts[1], pts[0]]
        rmsd = procrustes_rmsd(pts, perm, allow_permutation=True)
        assert rmsd == pytest.approx(0.0, abs=1e-10)

    def test_similarity_transform_near_zero(self):
        pts_a = [(0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0)]
        # scale 2, swap x/y (rotation in xy-plane)
        pts_b = [(0.0, 0.0, 0.0), (0.0, 2.0, 0.0), (-2.0, 0.0, 0.0)]
        rmsd = procrustes_rmsd(pts_a, pts_b, allow_permutation=True)
        assert rmsd == pytest.approx(0.0, abs=1e-6)


class TestShapeInvariants:
    def test_distance_spectrum_identical_shapes(self):
        a = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
        b = [(0.0, 0.0), (2.0, 0.0), (0.0, 2.0)]
        assert distance_spectrum_l2(a, b) == pytest.approx(0.0, abs=1e-10)

    def test_gram_spectrum_identical_shapes(self):
        a = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
        b = [(0.0, 0.0), (3.0, 0.0), (0.0, 3.0)]
        assert gram_spectrum_l2(a, b) == pytest.approx(0.0, abs=1e-10)


class TestClassificationLogic:
    def test_compatible_when_all_agree(self):
        ok, cls, _ = classify_geometry_row(
            n=1,
            sep_a=1.0,
            sep_b=1.0,
            distance_spectrum_l2_val=0.0,
            gram_spectrum_l2_val=0.0,
            procrustes_rmsd_val=0.0,
            point_count_match=True,
        )
        assert ok is True
        assert cls == "compatible"

    def test_label_orientation_when_procrustes_large(self):
        ok, cls, _ = classify_geometry_row(
            n=1,
            sep_a=1.0,
            sep_b=1.0,
            distance_spectrum_l2_val=0.0,
            gram_spectrum_l2_val=0.0,
            procrustes_rmsd_val=1.0,
            point_count_match=True,
        )
        assert ok is False
        assert cls == "label_orientation"

    def test_true_geometric_deviation(self):
        ok, cls, _ = classify_geometry_row(
            n=2,
            sep_a=1.0,
            sep_b=0.5,
            distance_spectrum_l2_val=1.0,
            gram_spectrum_l2_val=0.0,
            procrustes_rmsd_val=0.0,
            point_count_match=True,
        )
        assert ok is False
        assert cls == "true_geometric_deviation"

    def test_possible_first_break_n3(self):
        ok, cls, _ = classify_geometry_row(
            n=3,
            sep_a=1.0,
            sep_b=1.0,
            distance_spectrum_l2_val=1.0,
            gram_spectrum_l2_val=0.0,
            procrustes_rmsd_val=0.0,
            point_count_match=True,
        )
        assert ok is False
        assert cls == "possible_first_break_n3"

    def test_count_mismatch(self):
        ok, cls, _ = classify_geometry_row(
            n=2,
            sep_a=1.0,
            sep_b=1.0,
            distance_spectrum_l2_val=0.0,
            gram_spectrum_l2_val=0.0,
            procrustes_rmsd_val=0.0,
            point_count_match=False,
        )
        assert ok is False
        assert cls == "count_mismatch"


class TestGeometryAuditRuns:
    def test_runs_n1_n2_n3(self):
        report = run_geometry_audit(n_max=3, mode="matched_n_plus_1")
        assert len(report.rows) == 3
        assert report.energiedoku_coordinates_source.startswith("csv:")
        for row in report.rows:
            assert row["point_count_a"] == row["point_count_b"]
            assert math.isfinite(row["sep_a"])
            assert math.isfinite(row["sep_b"])
            assert "classification" in row

    def test_compare_sources_row_schema(self):
        pts = [(1.0, 0.0, 0.0), (0.0, 1.0, 0.0)]
        row = compare_sources(1, pts, pts)
        assert row["compatible"] is True
        assert row["classification"] == "compatible"
        assert row["procrustes_rmsd"] == pytest.approx(0.0, abs=1e-10)

    def test_full_mode_count_mismatch(self):
        report = run_geometry_audit(n_max=2, mode="full")
        row = report.rows[1]
        assert row["point_count_a"] == 3
        assert row["point_count_b"] == 16
        assert row["compatible"] is False
        assert row["classification"] == "count_mismatch"
