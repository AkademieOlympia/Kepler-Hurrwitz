"""
Shell-separation detector validation controls — null and stress tests [C].

Governance
----------
These controls validate detector *measurement* behavior only. They do not prove
``MetricSeparationLossExist``, establish a global ``R^3`` embedding, or fix an
internal first-loss index ``n_0``. ``shellPrimeMatchAtFirstLoss`` remains
**GATE INACTIVE** throughout this layer.

See ``docs/reports/shell_separation_diagnostics_protocol.md`` section
"Detector Validation Controls".
"""

from __future__ import annotations

import csv
import random
from collections.abc import Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from kepler_hurwitz.shell_separation_diagnostics import (
    shell_overlap,
    shell_sep,
    shell_separation_loss,
)

Point = tuple[float, ...]

DEFAULT_EPSILON = 1.0
DEFAULT_N_SHELLS = 4
DEFAULT_POINTS_PER_SHELL = 5
DEFAULT_DIM = 3
DEFAULT_RANDOM_SEEDS: tuple[int, ...] = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

DETECTOR_CONTROLS_CSV_FIELDS: tuple[str, ...] = (
    "control_name",
    "seed",
    "n_shells",
    "points_per_shell",
    "epsilon",
    "sep",
    "overlap_count",
    "shell_separation_loss",
    "expected_loss",
    "passed",
    "notes",
)

__all__ = [
    "DETECTOR_CONTROLS_CSV_FIELDS",
    "ControlCase",
    "DEFAULT_RANDOM_SEEDS",
    "evaluate_control",
    "export_detector_controls_csv",
    "generate_degenerate_shells",
    "generate_overlapping_shells",
    "generate_random_shells",
    "generate_separated_shells",
    "run_detector_controls",
]


@dataclass(frozen=True)
class ControlCase:
    """Single detector validation control with expected outcome."""

    control_name: str
    shells: dict[int, tuple[Point, ...]]
    epsilon: float
    expected_loss: bool
    seed: int | None = None
    n_shells: int = DEFAULT_N_SHELLS
    points_per_shell: int = 1
    notes: str = ""


def _shells_from_centroids(centroids: Sequence[Point]) -> dict[int, tuple[Point, ...]]:
    return {i: (cent,) for i, cent in enumerate(centroids)}


def generate_overlapping_shells(
    *,
    n_shells: int = DEFAULT_N_SHELLS,
    epsilon: float = DEFAULT_EPSILON,
    dim: int = DEFAULT_DIM,
) -> ControlCase:
    """
    Positive control: intentionally overlapping shells.

    Centroids placed within ``epsilon / 2`` so ``overlap_count > 0`` and
    ``shell_separation_loss`` is expected ``True``.
    """
    if n_shells < 2:
        raise ValueError("n_shells must be >= 2 for overlapping control.")
    if epsilon <= 0:
        raise ValueError("epsilon must be positive.")
    if dim < 1:
        raise ValueError("dim must be >= 1.")

    step = epsilon / (4.0 * max(n_shells - 1, 1))
    centroids: list[Point] = []
    for i in range(n_shells):
        coords = [0.0] * dim
        coords[0] = i * step
        centroids.append(tuple(coords))

    shells = _shells_from_centroids(centroids)
    return ControlCase(
        control_name="positive_overlapping",
        shells=shells,
        epsilon=epsilon,
        expected_loss=True,
        n_shells=n_shells,
        points_per_shell=1,
        notes=f"centroid spacing={step:.4f} < epsilon={epsilon}",
    )


def generate_separated_shells(
    *,
    n_shells: int = DEFAULT_N_SHELLS,
    epsilon: float = DEFAULT_EPSILON,
    dim: int = DEFAULT_DIM,
    separation: float | None = None,
) -> ControlCase:
    """
    Negative control: clearly separated shells.

    Centroids spaced at ``separation`` (default ``10 * epsilon``); expected
    ``overlap_count = 0`` and ``shell_separation_loss = False``.
    """
    if n_shells < 2:
        raise ValueError("n_shells must be >= 2 for separated control.")
    if epsilon <= 0:
        raise ValueError("epsilon must be positive.")
    if dim < 1:
        raise ValueError("dim must be >= 1.")

    gap = separation if separation is not None else 10.0 * epsilon
    centroids: list[Point] = []
    for i in range(n_shells):
        coords = [0.0] * dim
        coords[i % dim] = i * gap
        centroids.append(tuple(coords))

    shells = _shells_from_centroids(centroids)
    return ControlCase(
        control_name="negative_separated",
        shells=shells,
        epsilon=epsilon,
        expected_loss=False,
        n_shells=n_shells,
        points_per_shell=1,
        notes=f"min centroid gap >= {gap:.4f} >> epsilon={epsilon}",
    )


def generate_degenerate_shells(
    *,
    n_shells: int = DEFAULT_N_SHELLS,
    epsilon: float = DEFAULT_EPSILON,
    dim: int = DEFAULT_DIM,
) -> ControlCase:
    """
    Degenerate control: identical / collapsed shells.

    All centroids coincide; expected ``sep = 0`` and ``shell_separation_loss = True``.
    """
    if n_shells < 2:
        raise ValueError("n_shells must be >= 2 for degenerate control.")
    if epsilon < 0:
        raise ValueError("epsilon must be non-negative.")

    origin = tuple(0.0 for _ in range(dim))
    centroids = [origin] * n_shells
    shells = _shells_from_centroids(centroids)
    return ControlCase(
        control_name="degenerate_collapsed",
        shells=shells,
        epsilon=epsilon,
        expected_loss=True,
        n_shells=n_shells,
        points_per_shell=1,
        notes="all centroids at origin; sep=0",
    )


def generate_random_shells(
    seed: int,
    *,
    n_shells: int = DEFAULT_N_SHELLS,
    points_per_shell: int = DEFAULT_POINTS_PER_SHELL,
    epsilon: float = DEFAULT_EPSILON,
    dim: int = DEFAULT_DIM,
    scale: float = 5.0,
) -> ControlCase:
    """
    Random null-model control: non-canonical point clouds per shell.

    Reproducible for a fixed ``seed``. Outcome is recorded but not asserted
    (baseline calibration only).
    """
    if n_shells < 2:
        raise ValueError("n_shells must be >= 2 for random control.")
    if points_per_shell < 1:
        raise ValueError("points_per_shell must be >= 1.")
    if epsilon <= 0:
        raise ValueError("epsilon must be positive.")

    rng = random.Random(seed)
    shells: dict[int, tuple[Point, ...]] = {}
    for shell_idx in range(n_shells):
        offset = tuple(rng.uniform(-scale, scale) for _ in range(dim))
        points: list[Point] = []
        for _ in range(points_per_shell):
            jitter = tuple(rng.uniform(-0.1, 0.1) for _ in range(dim))
            points.append(
                tuple(o + j for o, j in zip(offset, jitter, strict=True))
            )
        shells[shell_idx] = tuple(points)

    return ControlCase(
        control_name="random_null",
        shells=shells,
        epsilon=epsilon,
        expected_loss=False,
        seed=seed,
        n_shells=n_shells,
        points_per_shell=points_per_shell,
        notes="null-model baseline; expected_loss not enforced",
    )


def evaluate_control(case: ControlCase) -> dict[str, Any]:
    """Evaluate one control case through the shell-separation detector API."""
    sep_val = shell_sep(case.shells)
    overlap_count = shell_overlap(case.shells, case.epsilon)
    loss = shell_separation_loss(sep_val, case.epsilon)

    if case.control_name == "random_null":
        passed = True
    elif case.control_name == "positive_overlapping":
        passed = loss is True and overlap_count > 0
    elif case.control_name == "negative_separated":
        passed = loss is False and overlap_count == 0
    elif case.control_name == "degenerate_collapsed":
        passed = sep_val == 0.0 and loss is True
    else:
        passed = loss == case.expected_loss

    return {
        "control_name": case.control_name,
        "seed": case.seed if case.seed is not None else "",
        "n_shells": case.n_shells,
        "points_per_shell": case.points_per_shell,
        "epsilon": case.epsilon,
        "sep": sep_val,
        "overlap_count": overlap_count,
        "shell_separation_loss": loss,
        "expected_loss": case.expected_loss,
        "passed": passed,
        "notes": case.notes,
    }


def run_detector_controls(
    *,
    epsilon: float = DEFAULT_EPSILON,
    n_shells: int = DEFAULT_N_SHELLS,
    points_per_shell: int = DEFAULT_POINTS_PER_SHELL,
    random_seeds: Sequence[int] | None = None,
) -> list[dict[str, Any]]:
    """
    Run the full detector validation control suite.

    Returns one row per control (deterministic controls + one row per random seed).
    """
    seeds = tuple(random_seeds) if random_seeds is not None else DEFAULT_RANDOM_SEEDS

    cases: list[ControlCase] = [
        generate_overlapping_shells(n_shells=n_shells, epsilon=epsilon),
        generate_separated_shells(n_shells=n_shells, epsilon=epsilon),
        generate_degenerate_shells(n_shells=n_shells, epsilon=epsilon),
    ]
    for seed in seeds:
        cases.append(
            generate_random_shells(
                seed,
                n_shells=n_shells,
                points_per_shell=points_per_shell,
                epsilon=epsilon,
            )
        )

    return [evaluate_control(case) for case in cases]


def export_detector_controls_csv(
    rows: Sequence[dict[str, Any]],
    path: Path | str,
) -> Path:
    """Export detector control results to CSV."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=DETECTOR_CONTROLS_CSV_FIELDS)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in DETECTOR_CONTROLS_CSV_FIELDS})
    return out
