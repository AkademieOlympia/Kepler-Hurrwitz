"""
Klein V4 neighbor-bifurcation null model — Syracuse label-path comparison.

[B] branching nullmodel diagnostic. Compares Klein V4 neighbor-bifurcation graph
with true Syracuse label paths. Does not replace division by 2, does not model
odd-core decomposition, does not prove Collatz.
"""

from __future__ import annotations

from typing import Any

from kepler_hurwitz.tao_collatz_diagnostics import KLEIN_MOD8_CLASSES, syracuse

KLEIN_BIFURCATION_TAG = "[B]"

__all__ = [
    "KLEIN_BIFURCATION_TAG",
    "KLEIN_MOD8_CLASSES",
    "bifurcation_children_mod8",
    "bifurcation_tree_labels",
    "compare_bifurcation_tree_vs_syracuse_path",
    "klein_label_mod8",
    "nearest_klein_neighbors",
    "true_syracuse_label_path",
]

_KLEIN_INDEX: dict[int, int] = {label: index for index, label in enumerate(KLEIN_MOD8_CLASSES)}


def _validate_klein_label(label: int) -> None:
    if label not in _KLEIN_INDEX:
        raise ValueError(f"label must be one of {KLEIN_MOD8_CLASSES}, got {label}")


def nearest_klein_neighbors(label: int) -> tuple[int, int]:
    """Cyclic neighbors of ``label`` on the Klein mod-8 classes ``{1, 3, 5, 7}``."""
    _validate_klein_label(label)
    index = _KLEIN_INDEX[label]
    left = KLEIN_MOD8_CLASSES[(index - 1) % len(KLEIN_MOD8_CLASSES)]
    right = KLEIN_MOD8_CLASSES[(index + 1) % len(KLEIN_MOD8_CLASSES)]
    return left, right


def klein_label_mod8(n: int) -> int:
    """Mod-8 Klein label for odd positive ``n`` (always in ``KLEIN_MOD8_CLASSES``)."""
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2 == 0:
        raise ValueError("n must be odd")
    label = n % 8
    if label not in _KLEIN_INDEX:
        raise ValueError(f"odd n must lie in Klein classes, got n={n}, label={label}")
    return label


def bifurcation_children_mod8(label: int) -> tuple[int, int]:
    """Alias for Klein neighbor bifurcation at ``label``."""
    return nearest_klein_neighbors(label)


def bifurcation_tree_labels(root_label: int, depth: int) -> list[tuple[int, ...]]:
    """
    All Klein neighbor-bifurcation label paths from ``root_label``.

    ``depth`` is the number of bifurcation edges after the root; yields ``2**depth``
    paths, each of length ``depth + 1``.
    """
    _validate_klein_label(root_label)
    if depth < 0:
        raise ValueError("depth must be >= 0")
    if depth == 0:
        return [(root_label,)]

    paths: list[tuple[int, ...]] = [(root_label,)]
    for _ in range(depth):
        next_paths: list[tuple[int, ...]] = []
        for path in paths:
            left, right = bifurcation_children_mod8(path[-1])
            next_paths.append(path + (left,))
            next_paths.append(path + (right,))
        paths = next_paths
    return paths


def true_syracuse_label_path(n: int, steps: int) -> list[int]:
    """Deterministic Syracuse mod-8 label path for odd ``n`` over ``steps`` Syracuse steps."""
    if steps < 0:
        raise ValueError("steps must be >= 0")

    labels = [klein_label_mod8(n)]
    current = n
    for _ in range(steps):
        current = syracuse(current)
        labels.append(klein_label_mod8(current))
    return labels


def compare_bifurcation_tree_vs_syracuse_path(n: int, depth: int) -> dict[str, Any]:
    """
    Compare the Klein bifurcation tree at ``depth`` with the true Syracuse label path.

    The Syracuse orbit yields one path; the bifurcation null model yields ``2**depth``
    paths. Reports membership and the first Klein-neighbor divergence step, if any.
    """
    if depth < 0:
        raise ValueError("depth must be >= 0")

    root_label = klein_label_mod8(n)
    tree_paths = bifurcation_tree_labels(root_label, depth)
    syracuse_path = true_syracuse_label_path(n, depth)
    syracuse_tuple = tuple(syracuse_path)

    first_divergence: int | None = None
    for step in range(len(syracuse_path) - 1):
        parent = syracuse_path[step]
        child = syracuse_path[step + 1]
        if child not in bifurcation_children_mod8(parent):
            first_divergence = step
            break

    return {
        "tag": KLEIN_BIFURCATION_TAG,
        "n": n,
        "depth": depth,
        "root_label": root_label,
        "bifurcation_path_count": len(tree_paths),
        "syracuse_path": syracuse_path,
        "syracuse_in_bifurcation_tree": syracuse_tuple in tree_paths,
        "first_divergence_step": first_divergence,
    }
