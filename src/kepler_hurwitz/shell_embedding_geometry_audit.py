"""
Rigoroser Geometrie-Audit: canonical_from_qcc_bridge vs. Energiedoku-Einbettung.

Governance
----------
Modellvalidierung only — kein ``MetricSeparationLossExist``-Claim, kein
``first_loss_n`` in Audit-Output, ``shellPrimeMatchAtFirstLoss`` INACTIVE.
Meissner-Sprache nur als Interpretationsvokabular ``[C]``.

Invariantenvergleich (bis auf Translation, Rotation, Skalierung, Label-Permutation):
``sep(n)``, ``overlap(n)``, Distanzspektrum, Gram-Spektrum, Radiusprofil,
Procrustes-RMSD.

Siehe ``docs/reports/shell_embedding_comparison_protocol.md``.
"""

from __future__ import annotations

import csv
import itertools
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Literal

from kepler_hurwitz.canonical_shell_vertices import (
    CANONICAL_SOURCE_LABEL,
    shells_at_level as canonical_shells_at_level,
)
from kepler_hurwitz.energiedoku_shell_construction import (
    ENERGIEDOKU_SOURCE_LABEL,
    coordinates_source,
    shells_at_level as energiedoku_shells_at_level,
    theorematic_epsilon_for_level,
)
from kepler_hurwitz.shell_separation_diagnostics import (
    GOVERNANCE_GUARD,
    Point,
    overlap,
    shell_sep,
)

try:
    import numpy as np
except ImportError:  # pragma: no cover
    np = None  # type: ignore[assignment]

AuditMode = Literal["full", "matched_n_plus_1"]

CANONICAL_SOURCE_A = CANONICAL_SOURCE_LABEL
ENERGIEDOKU_SOURCE_B_FULL = f"{ENERGIEDOKU_SOURCE_LABEL}_full"
ENERGIEDOKU_SOURCE_B_MATCHED = f"{ENERGIEDOKU_SOURCE_LABEL}_matched_n_plus_1"

# Tolerances for invariant agreement (shape-normalized where noted)
SEP_REL_TOL = 1e-6
SEP_ABS_TOL = 1e-9
SPECTRUM_L2_TOL = 1e-4
PROCRUSTES_LARGE_TOL = 0.05
MAX_PERMUTATION_POINTS = 8

GOVERNANCE_BOX = (
    "Modellvalidierung only [C]. Kein MetricSeparationLossExist-Claim. "
    "Kein first_loss_n in diesem Audit. shellPrimeMatchAtFirstLoss INACTIVE. "
    "Meissner [C] only."
)


def _require_numpy() -> Any:
    if np is None:
        raise ImportError("shell_embedding_geometry_audit requires numpy.")
    return np


def _points_from_shells(shells: dict[int, list[Point]]) -> list[Point]:
    return [shells[i][0] for i in sorted(shells)]


def _center_scale(points: list[Point]) -> Any:
    """Center at centroid and scale to unit Frobenius norm (shape normalization)."""
    xp = _require_numpy()
    arr = xp.asarray(points, dtype=float)
    if arr.ndim != 2 or arr.shape[0] < 1:
        raise ValueError("Need at least one point.")
    centered = arr - arr.mean(axis=0)
    norm = xp.linalg.norm(centered)
    if norm < 1e-15:
        return centered
    return centered / norm


def pairwise_distances_sorted(points: list[Point]) -> Any:
    """Sorted upper-triangle pairwise distances."""
    xp = _require_numpy()
    arr = xp.asarray(points, dtype=float)
    n = arr.shape[0]
    dists = []
    for i in range(n):
        for j in range(i + 1, n):
            dists.append(float(xp.linalg.norm(arr[i] - arr[j])))
    return xp.sort(xp.asarray(dists, dtype=float))


def distance_spectrum_l2(points_a: list[Point], points_b: list[Point]) -> float:
    """
    L2 between sorted pairwise distance spectra after shape normalization.

    Requires equal point counts; raises ``ValueError`` otherwise.
    """
    if len(points_a) != len(points_b):
        raise ValueError(
            f"distance_spectrum_l2 requires equal counts; got {len(points_a)} vs {len(points_b)}."
        )
    xp = _require_numpy()
    spec_a = pairwise_distances_sorted(_center_scale(points_a).tolist())
    spec_b = pairwise_distances_sorted(_center_scale(points_b).tolist())
    if spec_a.shape != spec_b.shape:
        return float("inf")
    return float(xp.linalg.norm(spec_a - spec_b))


def gram_matrix(points: list[Point]) -> Any:
    xp = _require_numpy()
    arr = _center_scale(points)
    return arr @ arr.T


def gram_spectrum_l2(points_a: list[Point], points_b: list[Point]) -> float:
    """L2 between sorted eigenvalues of shape-normalized Gram matrices."""
    if len(points_a) != len(points_b):
        raise ValueError(
            f"gram_spectrum_l2 requires equal counts; got {len(points_a)} vs {len(points_b)}."
        )
    xp = _require_numpy()
    evals_a = xp.sort(xp.linalg.eigvalsh(gram_matrix(points_a)))
    evals_b = xp.sort(xp.linalg.eigvalsh(gram_matrix(points_b)))
    return float(xp.linalg.norm(evals_a - evals_b))


def radius_profile(points: list[Point]) -> Any:
    """Sorted distances from centroid (shape-normalized coordinates)."""
    xp = _require_numpy()
    arr = _center_scale(points)
    radii = xp.linalg.norm(arr, axis=1)
    return xp.sort(radii)


def radius_profile_l2(points_a: list[Point], points_b: list[Point]) -> float:
    if len(points_a) != len(points_b):
        raise ValueError(
            f"radius_profile_l2 requires equal counts; got {len(points_a)} vs {len(points_b)}."
        )
    xp = _require_numpy()
    prof_a = radius_profile(points_a)
    prof_b = radius_profile(points_b)
    return float(xp.linalg.norm(prof_a - prof_b))


def _procrustes_rmsd_fixed_order(
    points_a: list[Point],
    points_b: list[Point],
) -> float:
    """Similarity Procrustes RMSD (Kabsch + optimal scale), fixed row order."""
    xp = _require_numpy()
    if len(points_a) != len(points_b):
        raise ValueError("Point counts must match for Procrustes.")
    if len(points_a) == 0:
        return 0.0
    a = xp.asarray(points_a, dtype=float)
    b = xp.asarray(points_b, dtype=float)
    a_c = a - a.mean(axis=0)
    b_c = b - b.mean(axis=0)
    norm_a = xp.linalg.norm(a_c)
    norm_b = xp.linalg.norm(b_c)
    if norm_a < 1e-15 or norm_b < 1e-15:
        return float(xp.linalg.norm(a_c - b_c) / max(1.0, len(a)))
    a_n = a_c / norm_a
    b_n = b_c / norm_b
    cross = a_n.T @ b_n
    u, _, vt = xp.linalg.svd(cross, full_matrices=False)
    r = u @ vt
    if xp.linalg.det(r) < 0:
        u[:, -1] *= -1
        r = u @ vt
    b_aligned = norm_a * (b_n @ r)
    diff = a_c - b_aligned
    return float(xp.sqrt(xp.mean(xp.sum(diff * diff, axis=1))))


def procrustes_rmsd(
    points_a: list[Point],
    points_b: list[Point],
    *,
    allow_permutation: bool = True,
) -> float:
    """
    Procrustes RMSD after optimal similarity transform and optional label permutation.

    For ``n <= MAX_PERMUTATION_POINTS`` tries all permutations of ``points_b``.
    """
    if len(points_a) != len(points_b):
        raise ValueError(
            f"procrustes_rmsd requires equal counts; got {len(points_a)} vs {len(points_b)}."
        )
    n = len(points_a)
    if n == 0:
        return 0.0
    if not allow_permutation or n > MAX_PERMUTATION_POINTS:
        return _procrustes_rmsd_fixed_order(points_a, points_b)
    best = float("inf")
    indices = list(range(n))
    for perm in itertools.permutations(indices):
        permuted = [points_b[i] for i in perm]
        best = min(best, _procrustes_rmsd_fixed_order(points_a, permuted))
    return best


def _sep_metrics(sep_a: float, sep_b: float) -> tuple[float, float]:
    abs_diff = abs(sep_a - sep_b)
    denom = max(abs(sep_a), abs(sep_b), 1e-15)
    rel_diff = abs_diff / denom
    return abs_diff, rel_diff


def _sep_agrees(sep_a: float, sep_b: float) -> bool:
    abs_diff, rel_diff = _sep_metrics(sep_a, sep_b)
    return abs_diff <= SEP_ABS_TOL or rel_diff <= SEP_REL_TOL


def _spectrum_agrees(value: float) -> bool:
    return math.isfinite(value) and value <= SPECTRUM_L2_TOL


def _procrustes_large(rmsd: float) -> bool:
    return math.isfinite(rmsd) and rmsd > PROCRUSTES_LARGE_TOL


def classify_geometry_row(
    *,
    n: int,
    sep_a: float,
    sep_b: float,
    distance_spectrum_l2_val: float,
    gram_spectrum_l2_val: float,
    procrustes_rmsd_val: float,
    point_count_match: bool,
) -> tuple[bool, str, str]:
    """
    Entscheidungslogik gemaess Protokoll.

    Returns ``(compatible, classification, notes_fragment)``.
    """
    sep_ok = _sep_agrees(sep_a, sep_b)
    dist_ok = _spectrum_agrees(distance_spectrum_l2_val)
    gram_ok = _spectrum_agrees(gram_spectrum_l2_val)
    proc_large = _procrustes_large(procrustes_rmsd_val)

    if not point_count_match:
        return (
            False,
            "count_mismatch",
            "point counts differ; invariants require matched_n_plus_1 mode for fair compare",
        )

    if sep_ok and dist_ok and gram_ok and not proc_large:
        return True, "compatible", "sep, distance spectrum, gram agree; Procrustes small"

    if sep_ok and proc_large and dist_ok and gram_ok:
        return (
            False,
            "label_orientation",
            "sep ok; Procrustes large — check label mapping / orientation",
        )

    if not dist_ok:
        if n == 3:
            return (
                False,
                "possible_first_break_n3",
                "distance spectrum differs at n=3 — isolate n=3; audit ι_n",
            )
        return (
            False,
            "true_geometric_deviation",
            "distance spectrum differs — true geometric deviation; audit ι_n",
        )

    if sep_ok and proc_large:
        return (
            False,
            "label_orientation",
            "sep ok; Procrustes large — check label mapping / orientation",
        )

    return (
        False,
        "incompatible",
        "invariants disagree (sep and/or shape spectra)",
    )


def compare_sources(
    n: int,
    points_a: list[Point],
    points_b: list[Point],
    labels_a: list[str] | None = None,
    labels_b: list[str] | None = None,
    *,
    source_a: str = CANONICAL_SOURCE_A,
    source_b: str = ENERGIEDOKU_SOURCE_B_MATCHED,
    mode: AuditMode = "matched_n_plus_1",
) -> dict[str, Any]:
    """
    Vergleiche zwei endliche Punktmengen auf Renorm-Stufe ``n``.

    Returns a flat row dict matching the CSV schema.
    """
    _ = labels_a, labels_b  # reserved for mapping diagnostics in notes
    count_a = len(points_a)
    count_b = len(points_b)
    point_count_match = count_a == count_b

    shells_a = {i: [p] for i, p in enumerate(points_a)}
    shells_b = {i: [p] for i, p in enumerate(points_b)}

    sep_a = shell_sep(shells_a) if count_a >= 2 else float("nan")
    sep_b = shell_sep(shells_b) if count_b >= 2 else float("nan")
    sep_abs_diff, sep_rel_diff = _sep_metrics(sep_a, sep_b) if point_count_match else (
        float("nan"),
        float("nan"),
    )

    eps = theorematic_epsilon_for_level(n) if n in (1, 2, 3) else float("nan")
    ov_a = overlap(n, shells_a, eps) if count_a >= 1 and math.isfinite(eps) else None
    ov_b = overlap(n, shells_b, eps) if count_b >= 1 and math.isfinite(eps) else None

    if point_count_match and count_a >= 1:
        dist_l2 = distance_spectrum_l2(points_a, points_b)
        gram_l2 = gram_spectrum_l2(points_a, points_b)
        radius_l2 = radius_profile_l2(points_a, points_b)
        proc = procrustes_rmsd(points_a, points_b, allow_permutation=True)
    else:
        dist_l2 = float("nan")
        gram_l2 = float("nan")
        radius_l2 = float("nan")
        proc = float("nan")

    compatible, classification, class_note = classify_geometry_row(
        n=n,
        sep_a=sep_a,
        sep_b=sep_b,
        distance_spectrum_l2_val=dist_l2,
        gram_spectrum_l2_val=gram_l2,
        procrustes_rmsd_val=proc,
        point_count_match=point_count_match,
    )

    note_parts = [
        f"mode={mode}",
        f"classification={classification}",
        class_note,
    ]
    if ov_a is not None and ov_b is not None:
        note_parts.append(f"overlap_a={ov_a}; overlap_b={ov_b}")
    if not point_count_match:
        note_parts.append(f"count_a={count_a}; count_b={count_b}")

    return {
        "n": n,
        "source_a": source_a,
        "source_b": source_b,
        "point_count_a": count_a,
        "point_count_b": count_b,
        "sep_a": sep_a,
        "sep_b": sep_b,
        "sep_abs_diff": sep_abs_diff,
        "sep_rel_diff": sep_rel_diff,
        "distance_spectrum_l2": dist_l2,
        "gram_spectrum_l2": gram_l2,
        "radius_profile_l2": radius_l2,
        "procrustes_rmsd": proc,
        "compatible": compatible,
        "notes": "; ".join(note_parts),
        "classification": classification,
    }


def load_comparison_points(
    n: int,
    *,
    mode: AuditMode = "matched_n_plus_1",
) -> tuple[list[Point], list[Point], str]:
    """Load canonical vs energiedoku point lists for level ``n``."""
    canon_shells = canonical_shells_at_level(n)
    points_a = _points_from_shells(canon_shells)

    if mode == "full":
        ed_shells = energiedoku_shells_at_level(n, mode="full")
        source_b = ENERGIEDOKU_SOURCE_B_FULL
    elif mode == "matched_n_plus_1":
        ed_shells = energiedoku_shells_at_level(n, mode="diagnostic")
        source_b = ENERGIEDOKU_SOURCE_B_MATCHED
    else:
        raise ValueError("mode must be 'full' or 'matched_n_plus_1'.")

    points_b = _points_from_shells(ed_shells)
    return points_a, points_b, source_b


@dataclass(frozen=True)
class GeometryAuditReport:
    """Aggregierter Geometrie-Audit fuer n in {1,2,3}."""

    rows: tuple[dict[str, Any], ...]
    recommendation: str
    iota_revision_needed: bool
    energiedoku_coordinates_source: str


def _aggregate_recommendation(rows: tuple[dict[str, Any], ...]) -> tuple[str, bool]:
    """Empfehlung ob ι_n revision needed basierend auf allen Stufen."""
    by_n = {int(r["n"]): r for r in rows}
    n1_ok = by_n.get(1, {}).get("compatible", False)
    n2_ok = by_n.get(2, {}).get("compatible", False)
    n3_row = by_n.get(3, {})
    n3_ok = n3_row.get("compatible", False)
    n3_class = n3_row.get("classification", "")

    any_true_dev = any(
        r.get("classification") == "true_geometric_deviation" for r in rows
    )
    any_label = any(r.get("classification") == "label_orientation" for r in rows)

    if all(r.get("compatible") for r in rows):
        return (
            "All levels compatible up to similarity + label permutation; "
            "continue with ε_n calibration — no ι_n revision required.",
            False,
        )

    if n1_ok and n2_ok and not n3_ok and n3_class == "possible_first_break_n3":
        return (
            "n=1,2 compatible; n=3 shows possible first geometric break — "
            "isolate n=3 before revising unified ι_n bridge.",
            True,
        )

    if any_true_dev:
        return (
            "True geometric deviation detected (distance spectrum); "
            "audit theorematic ι_n mapping — do NOT rebuild unified bridge until "
            "invariant audit confirms deviation is not label/orientation only.",
            True,
        )

    if any_label:
        return (
            "Separation agrees but Procrustes/large residual — "
            "check prefix↔word label mapping and orientation; "
            "ι_n revision not indicated until mapping exhausted.",
            False,
        )

    return (
        "Geometries incompatible under invariant audit; "
        "review ι_n for affected levels — keep qec_bridge as all-n scaffold.",
        True,
    )


def run_geometry_audit(
    *,
    n_max: int = 3,
    mode: AuditMode = "matched_n_plus_1",
) -> GeometryAuditReport:
    """Run geometry audit for n = 1 .. n_max (max 3)."""
    cap = min(max(n_max, 1), 3)
    rows: list[dict[str, Any]] = []
    for n in range(1, cap + 1):
        points_a, points_b, source_b = load_comparison_points(n, mode=mode)
        rows.append(
            compare_sources(
                n,
                points_a,
                points_b,
                labels_a=None,
                labels_b=None,
                source_a=CANONICAL_SOURCE_A,
                source_b=source_b,
                mode=mode,
            )
        )
    row_tuple = tuple(rows)
    rec, iota_needed = _aggregate_recommendation(row_tuple)
    return GeometryAuditReport(
        rows=row_tuple,
        recommendation=rec,
        iota_revision_needed=iota_needed,
        energiedoku_coordinates_source=coordinates_source(),
    )


CSV_FIELDNAMES = [
    "n",
    "source_a",
    "source_b",
    "point_count_a",
    "point_count_b",
    "sep_a",
    "sep_b",
    "sep_abs_diff",
    "sep_rel_diff",
    "distance_spectrum_l2",
    "gram_spectrum_l2",
    "radius_profile_l2",
    "procrustes_rmsd",
    "compatible",
    "notes",
]


def export_geometry_audit_csv(
    report: GeometryAuditReport,
    path: Path | str,
) -> Path:
    """Export audit rows to CSV (exact column schema)."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=CSV_FIELDNAMES)
        writer.writeheader()
        for row in report.rows:
            writer.writerow({k: row[k] for k in CSV_FIELDNAMES})
    return out


__all__ = [
    "GOVERNANCE_BOX",
    "GOVERNANCE_GUARD",
    "AuditMode",
    "GeometryAuditReport",
    "CSV_FIELDNAMES",
    "CANONICAL_SOURCE_A",
    "ENERGIEDOKU_SOURCE_B_FULL",
    "ENERGIEDOKU_SOURCE_B_MATCHED",
    "classify_geometry_row",
    "compare_sources",
    "distance_spectrum_l2",
    "export_geometry_audit_csv",
    "gram_spectrum_l2",
    "load_comparison_points",
    "procrustes_rmsd",
    "radius_profile_l2",
    "run_geometry_audit",
]
