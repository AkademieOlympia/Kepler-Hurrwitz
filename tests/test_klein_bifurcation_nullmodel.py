"""Tests for Klein V4 neighbor-bifurcation null model."""

from __future__ import annotations

import pytest

from kepler_hurwitz.klein_bifurcation_nullmodel import (
    KLEIN_BIFURCATION_TAG,
    KLEIN_MOD8_CLASSES,
    bifurcation_children_mod8,
    bifurcation_tree_labels,
    compare_bifurcation_tree_vs_syracuse_path,
    klein_label_mod8,
    nearest_klein_neighbors,
    true_syracuse_label_path,
)


class TestNearestKleinNeighbors:
    @pytest.mark.parametrize(
        ("label", "expected"),
        [
            (1, (7, 3)),
            (3, (1, 5)),
            (5, (3, 7)),
            (7, (5, 1)),
        ],
    )
    def test_neighbors_are_cyclic(self, label: int, expected: tuple[int, int]) -> None:
        assert nearest_klein_neighbors(label) == expected
        assert bifurcation_children_mod8(label) == expected

    def test_invalid_label_raises(self) -> None:
        with pytest.raises(ValueError, match="label must be one of"):
            nearest_klein_neighbors(2)


class TestKleinLabelMod8:
    @pytest.mark.parametrize(
        ("n", "label"),
        [(3, 3), (7, 7), (11, 3), (15, 7), (17, 1)],
    )
    def test_odd_labels(self, n: int, label: int) -> None:
        assert klein_label_mod8(n) == label
        assert label in KLEIN_MOD8_CLASSES

    def test_even_raises(self) -> None:
        with pytest.raises(ValueError, match="n must be odd"):
            klein_label_mod8(4)


class TestBifurcationTree:
    def test_tree_size_is_power_of_two(self) -> None:
        for depth in range(4):
            paths = bifurcation_tree_labels(3, depth)
            assert len(paths) == 2**depth
            assert all(len(path) == depth + 1 for path in paths)
            assert all(path[0] == 3 for path in paths)

    def test_depth_zero_is_root_only(self) -> None:
        assert bifurcation_tree_labels(5, 0) == [(5,)]

    def test_depth_one_branches_to_neighbors(self) -> None:
        assert set(bifurcation_tree_labels(3, 1)) == {(3, 1), (3, 5)}

    def test_invalid_root_raises(self) -> None:
        with pytest.raises(ValueError, match="label must be one of"):
            bifurcation_tree_labels(0, 1)


class TestTrueSyracuseLabelPath:
    def test_path_is_deterministic(self) -> None:
        assert true_syracuse_label_path(7, 3) == [7, 3, 1, 5]

    def test_zero_steps_is_start_label(self) -> None:
        assert true_syracuse_label_path(11, 0) == [3]

    def test_invalid_n_raises(self) -> None:
        with pytest.raises(ValueError, match="n must be odd"):
            true_syracuse_label_path(8, 1)


class TestCompareBifurcationVsSyracuse:
    def test_syracuse_path_is_single_branch_or_diverges(self) -> None:
        result = compare_bifurcation_tree_vs_syracuse_path(3, depth=3)
        assert result["tag"] == KLEIN_BIFURCATION_TAG
        assert result["bifurcation_path_count"] == 8
        assert result["syracuse_path"] == [3, 5, 1, 1]
        assert result["syracuse_in_bifurcation_tree"] is False
        assert result["first_divergence_step"] == 1

    def test_compare_for_n11_depth3(self) -> None:
        result = compare_bifurcation_tree_vs_syracuse_path(11, depth=3)
        assert result["root_label"] == 3
        assert result["syracuse_path"] == [3, 1, 5, 5]
        assert result["syracuse_in_bifurcation_tree"] is False
        assert result["first_divergence_step"] == 1

    def test_matching_branch_when_syracuse_follows_neighbors(self) -> None:
        # Construct a path that stays on Klein neighbors: 3 -> 1 -> 7 -> 5
        tree = bifurcation_tree_labels(3, depth=3)
        assert (3, 1, 7, 5) in tree

        # Syracuse from n=3 diverges at step 1 (5 not a neighbor choice issue - actually
        # 3->5 is valid). Document via compare that membership is explicit.
        result = compare_bifurcation_tree_vs_syracuse_path(3, depth=2)
        assert result["syracuse_path"] == [3, 5, 1]
        assert result["syracuse_in_bifurcation_tree"] is False
        assert result["first_divergence_step"] == 1
