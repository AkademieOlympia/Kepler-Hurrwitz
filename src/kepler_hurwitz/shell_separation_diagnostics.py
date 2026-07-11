"""
Shell-Separationsdiagnostik — E-077 / E-078 / E-079 Mess-Schicht [C].

Governance
----------
Dieses Modul beweist **nicht** ``MetricSeparationLossExists``, keine globale
``R^3``-Einbettung und keine Minkowski-Bouligand-Dimensionsexistenz. Es
operationalisiert nur messbare Groessen: ``sep(n)``, ``overlap(n)``,
``ShellSeparationLoss(n)``, ``widehat{dim}_B(S)``.

Pre-Registration Gate (E-085) — Dual-Track n₀ Governance
--------------------------------------------------------
Die Hypothese ``shellPrimeMatchAtFirstLoss`` bleibt **GATE INACTIVE** /
**PRE-REGISTRATION NOT COMPLETE**, bis ein interner first-loss index ``n_0``
geometrisch blind feststeht:

``fixed shell model → sep(n) → ShellSeparationLoss(n) → n_0``.

**Track A (Primary Pre-Reg):** ``SHELL_PRIME_MATCH_PRIMARY_TRACK`` =
``canonical_from_qec_bridge``; Kombinatorik ``n+1``; ``first_loss_n`` = NONE
(``n`` = 1..17).

**Track B (Theorematic Reference, ``[C]``):** ``energiedoku_full``; Kombinatorik
``4^n``; exploratorisches ``n_0 = 2`` unter ``theorematic_energiedoku_v1`` allein —
**nicht gate-eligible**, solange Track A primary bleibt. Track-B-``n_0`` darf
**nicht** fuer ``shellPrimeMatchAtFirstLoss`` verwendet werden.

Erst danach darf die arithmetische Kopplung ``n_0 → shellPrimeMatchAtFirstLoss``
getestet werden — nur mit einem gate-eligible ``n_0`` aus der primary frozen
construction (Track A) oder nach expliziter Spur-Umstellung / unified ``ι_n``.
Vor Aktivierung muessen Konstruktion, Metrik, ``epsilon_n``, Suchbereich,
``sep(n)``, ``ShellSeparationLoss(n)`` und die ``n_0``-Extraktionsregel
eingefroren sein — ohne Primindex-, EABC-Kanal-, Rest- oder arithmetische Features.

Siehe ``docs/reports/shell_separation_diagnostics_protocol.md`` Abschnitte
"Pre-Registration Gate: shellPrimeMatchAtFirstLoss" und
"Dual-Track n₀ Governance", ``docs/reports/shell_n0_dual_track_decision.md`` und
``docs/reports/shell_separation_preregistration.json``.

Siehe ``docs/reports/shell_separation_diagnostics_protocol.md``,
``docs/open_mathematical_bridge_targets.md`` §2 und
``docs/diagnostics_parameter_atlas.md`` (E-077).
"""

from __future__ import annotations

import csv
import json
import math
from collections.abc import Callable, Mapping, Sequence
from dataclasses import asdict, dataclass
from itertools import combinations
from pathlib import Path
from typing import Any, overload

Point = tuple[float, ...]

GOVERNANCE_GUARD = (
    "Diagnostic only — does NOT prove MetricSeparationLossExists (E-077), "
    "global R³ embedding (E-078), or Minkowski–Bouligand dimension (E-079)."
)

# E-085 pre-registration gate: inactive until internal first_loss_n (n_0) is fixed
# without reference to prime indices. See
# docs/reports/shell_separation_diagnostics_protocol.md
# sections "Pre-Registration Gate: shellPrimeMatchAtFirstLoss" and
# "Dual-Track n₀ Governance" and docs/reports/shell_separation_preregistration.json.
SHELL_PRIME_MATCH_PRIMARY_TRACK = "canonical_from_qec_bridge"
SHELL_PRIME_MATCH_GATE_ACTIVE = False
# Track B (energiedoku_full, 4^n): exploratory_n_0=2 under theorematic_energiedoku_v1
# is documented but NOT gate-eligible while Track A remains primary.
TRACK_B_ENERGIEDOKU_FULL_EXPLORATORY_N0 = 2
TRACK_B_ENERGIEDOKU_FULL_GATE_ELIGIBLE = False

__all__ = [
    "GOVERNANCE_GUARD",
    "SHELL_PRIME_MATCH_GATE_ACTIVE",
    "SHELL_PRIME_MATCH_PRIMARY_TRACK",
    "TRACK_B_ENERGIEDOKU_FULL_EXPLORATORY_N0",
    "TRACK_B_ENERGIEDOKU_FULL_GATE_ELIGIBLE",
    "ShellSeparationReport",
    "box_dimension_estimate",
    "box_dimension_from_counts",
    "build_synthetic_shell_series",
    "build_toy_shell_series_n_le_3",
    "embedding_quality",
    "export_box_dimension_csv",
    "export_shell_separation_csv",
    "export_shell_separation_json",
    "first_loss",
    "first_loss_n",
    "overlap",
    "pairwise_min_distance",
    "run_shell_separation_diagnostics",
    "sep",
    "shell_min_separation",
    "shell_overlap",
    "shell_overlap_metric",
    "shell_sep",
    "shell_separation_loss",
]


def _euclidean(a: Point, b: Point) -> float:
    if len(a) != len(b):
        raise ValueError(f"Point dimension mismatch: {len(a)} vs {len(b)}")
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b, strict=True)))


def _centroid(points: Sequence[Point]) -> Point:
    if not points:
        raise ValueError("Cannot compute centroid of empty point set.")
    dim = len(points[0])
    if any(len(p) != dim for p in points):
        raise ValueError("All points must share the same dimension.")
    n = len(points)
    return tuple(sum(p[i] for p in points) / n for i in range(dim))


def pairwise_min_distance(
    points_a: Sequence[Point],
    points_b: Sequence[Point],
) -> float:
    """Minimale euklidische Distanz zwischen zwei Punktmengen."""
    if not points_a or not points_b:
        raise ValueError("Both point sets must be non-empty.")
    return min(_euclidean(a, b) for a in points_a for b in points_b)


def shell_sep(shells: Mapping[int, Sequence[Point]]) -> float:
    """
    Minimale paarweise Centroid-Separation zwischen Schalen auf einer Stufe.

    ``shells`` mappt ``shell_index -> Punktmenge`` (typisch ein Centroid pro Schale).
    """
    if len(shells) < 2:
        raise ValueError("shell_sep requires at least two shells.")
    centroids = {idx: _centroid(points) for idx, points in shells.items()}
    indices = sorted(centroids)
    distances = [
        _euclidean(centroids[i], centroids[j])
        for i, j in combinations(indices, 2)
    ]
    return shell_min_separation(distances)


def shell_overlap(shells: Mapping[int, Sequence[Point]], epsilon: float) -> int:
    """
    Anzahl Schalenpaare mit Centroid-Abstand ``< epsilon`` (Ueberlappungszaehler).

    Rein diagnostisch — kein metrischer Beweis von ShellSeparationLoss.
    """
    if epsilon < 0:
        raise ValueError("epsilon must be non-negative.")
    if len(shells) < 2:
        return 0
    centroids = {idx: _centroid(points) for idx, points in shells.items()}
    count = 0
    for i, j in combinations(sorted(centroids), 2):
        if _euclidean(centroids[i], centroids[j]) < epsilon:
            count += 1
    return count


def overlap(
    n: int,
    shells_at_n: Mapping[int, Sequence[Point]],
    epsilon: float,
) -> int:
    """Ueberlappungszaehler auf Stufe ``n`` (Alias fuer ``shell_overlap``)."""
    _ = n  # Stufenindex fuer tabellarische Exporte; Metrik haengt nur von shells ab.
    return shell_overlap(shells_at_n, epsilon)


def embedding_quality(sep_n: float, epsilon_n: float) -> float | None:
    """
    Optionaler Einbettungsqualitaets-Proxy: ``sep / epsilon``.

    ``None`` wenn ``epsilon_n <= 0``. Kein Nachweis globaler R³-Einbettung.
    """
    if epsilon_n <= 0:
        return None
    if sep_n < 0:
        raise ValueError("sep_n must be non-negative.")
    return sep_n / epsilon_n


def shell_min_separation(sep_distances: Sequence[float]) -> float:
    """Minimale paarweise Separation aus vorberechneten Abstaenden."""
    values = tuple(sep_distances)
    if not values:
        raise ValueError("sep_distances must be non-empty.")
    if any(d < 0 for d in values):
        raise ValueError("sep_distances must be non-negative.")
    return min(values)


def shell_overlap_metric(
    shell_centroids: Sequence[Point],
    shell_radii: Sequence[float],
) -> float:
    """
    Einfacher Ueberlappungsproxy zwischen Schalen-Kugeln.

    Fuer jedes Paar (i, j) mit i != j:
        overlap_ij = max(0, (r_i + r_j - d_ij) / (r_i + r_j))

    Rueckgabe: Maximum ueber alle Paare in [0, 1].
    """
    centroids = tuple(shell_centroids)
    radii = tuple(shell_radii)
    if len(centroids) != len(radii):
        raise ValueError("shell_centroids and shell_radii must have equal length.")
    if len(centroids) < 2:
        return 0.0
    if any(r < 0 for r in radii):
        raise ValueError("shell_radii must be non-negative.")

    max_overlap = 0.0
    for (i, ci), (j, cj) in combinations(enumerate(centroids), 2):
        d_ij = _euclidean(ci, cj)
        denom = radii[i] + radii[j]
        if denom <= 0:
            continue
        overlap_ij = max(0.0, (denom - d_ij) / denom)
        max_overlap = max(max_overlap, overlap_ij)
    return max_overlap


def sep(
    n: int,
    shell_embeddings_or_distances: Mapping[int, Sequence[Point]] | Mapping[int, float],
) -> float:
    """
    Separation auf Stufe ``n``.

    Akzeptiert entweder
    - ``{shell_index: sequence of points}`` (Centroide pro Schale), oder
    - ``{shell_index: precomputed min distance to other shells}``.
    """
    if n not in shell_embeddings_or_distances:
        raise KeyError(f"Level n={n} not present in shell data.")
    payload = shell_embeddings_or_distances[n]

    if isinstance(payload, (int, float)):
        if payload < 0:
            raise ValueError(f"Precomputed separation at n={n} must be non-negative.")
        return float(payload)

    points_by_shell: Mapping[int, Sequence[Point]] = shell_embeddings_or_distances  # type: ignore[assignment]
    if n not in points_by_shell:
        raise KeyError(f"Level n={n} not present in shell embeddings.")
    shells = points_by_shell[n]
    if len(shells) < 2:
        raise ValueError(f"Level n={n} needs at least two shell centroids.")

    distances = [
        _euclidean(shells[i], shells[j])
        for i, j in combinations(range(len(shells)), 2)
    ]
    return shell_min_separation(distances)


def shell_separation_loss(sep_n: float, epsilon_n: float) -> bool:
    """Separationsverlust-Flag: ``sep(n) <= epsilon_n``."""
    if sep_n < 0 or epsilon_n < 0:
        raise ValueError("sep_n and epsilon_n must be non-negative.")
    return sep_n <= epsilon_n


def first_loss_n(
    sep_series: Mapping[int, float],
    threshold_fn: Callable[[int], float],
) -> int | None:
    """Erstes ``n`` (aufsteigend sortiert), an dem ``shell_separation_loss`` eintritt."""
    if not sep_series:
        return None
    for n in sorted(sep_series):
        if shell_separation_loss(sep_series[n], threshold_fn(n)):
            return n
    return None


def first_loss(rows: Sequence[Mapping[str, Any]]) -> int | None:
    """
    Erstes ``n`` aus tabellarischen Zeilen mit Schluesseln ``n``, ``sep``, ``epsilon``.

    Alternative zu ``first_loss_n`` fuer CSV-/Export-Pipelines.
    """
    if not rows:
        return None
    ordered = sorted(rows, key=lambda row: int(row["n"]))
    for row in ordered:
        if shell_separation_loss(float(row["sep"]), float(row["epsilon"])):
            return int(row["n"])
    return None


def _box_count(point_cloud: Sequence[Point], epsilon: float) -> int:
    if epsilon <= 0:
        raise ValueError("epsilon must be positive.")
    if not point_cloud:
        return 0
    dim = len(point_cloud[0])
    cells: set[tuple[int, ...]] = set()
    for point in point_cloud:
        if len(point) != dim:
            raise ValueError("All points must share the same dimension.")
        cell = tuple(int(math.floor(coord / epsilon)) for coord in point)
        cells.add(cell)
    return len(cells)


def box_dimension_from_counts(
    epsilons: Sequence[float],
    cover_counts: Sequence[int],
) -> float | None:
    """
    Minkowski-Bouligand-artige Schaetzung aus vorberechneten Box-Counts.

    ``dim_B ≈ slope of log N(eps) vs log(1/eps)`` (lineare Regression).
    """
    if len(epsilons) != len(cover_counts):
        raise ValueError("epsilons and cover_counts must have equal length.")

    log_inv_eps: list[float] = []
    log_counts: list[float] = []
    for eps, count in zip(epsilons, cover_counts, strict=True):
        eps_f = float(eps)
        count_i = int(count)
        if eps_f <= 0 or count_i <= 1:
            continue
        inv_eps = 1.0 / eps_f
        if inv_eps <= 1.0:
            continue
        log_inv_eps.append(math.log(inv_eps))
        log_counts.append(math.log(count_i))

    if len(log_inv_eps) < 2:
        return None

    n_pts = len(log_inv_eps)
    mean_x = sum(log_inv_eps) / n_pts
    mean_y = sum(log_counts) / n_pts
    var_x = sum((x - mean_x) ** 2 for x in log_inv_eps)
    if var_x == 0:
        return None
    cov_xy = sum(
        (x - mean_x) * (y - mean_y) for x, y in zip(log_inv_eps, log_counts, strict=True)
    )
    return cov_xy / var_x


def _box_dimension_from_point_cloud(
    point_cloud: Sequence[Point],
    eps_grid: Sequence[float],
) -> float | None:
    eps_values = sorted({float(e) for e in eps_grid if e > 0})
    if len(eps_values) < 2:
        return None
    counts = [_box_count(point_cloud, eps) for eps in eps_values]
    return box_dimension_from_counts(eps_values, counts)


@overload
def box_dimension_estimate(
    epsilons: Sequence[float],
    cover_counts: Sequence[int],
) -> float | None: ...


@overload
def box_dimension_estimate(
    point_cloud: Sequence[Point],
    eps_grid: Sequence[float],
) -> float | None: ...


def box_dimension_estimate(
    first: Sequence[float] | Sequence[Point],
    second: Sequence[float] | Sequence[int],
) -> float | None:
    """
    Minkowski-Bouligand-artige Schaetzung.

    - ``box_dimension_estimate(epsilons, cover_counts)`` — vorberechnete Counts
    - ``box_dimension_estimate(point_cloud, eps_grid)`` — Box-Counting auf Punktwolke
    """
    if not first:
        return None
    head = first[0]
    if isinstance(head, (int, float)) and all(isinstance(x, (int, float)) for x in second):
        return box_dimension_from_counts(first, second)  # type: ignore[arg-type]
    return _box_dimension_from_point_cloud(first, second)  # type: ignore[arg-type]


def build_synthetic_shell_series(
    *,
    dim: int = 2,
    n_max: int = 5,
    first_loss_level: int = 4,
    base_separation: float = 2.0,
) -> dict[int, dict[str, Any]]:
    """
    Synthetische Schalenreihe: Separation faellt ab ``first_loss_level``.

    Jede Stufe ``n`` enthaelt zwei Schalen-Centroide, deren Abstand mit ``n``
    schrumpft (ab ``first_loss_level`` unter typische Schwellen).
    """
    if dim < 1:
        raise ValueError("dim must be >= 1.")
    if n_max < 1:
        raise ValueError("n_max must be >= 1.")
    if first_loss_level < 1 or first_loss_level > n_max:
        raise ValueError("first_loss_level must lie in [1, n_max].")

    series: dict[int, dict[str, Any]] = {}
    for n in range(1, n_max + 1):
        if n < first_loss_level:
            distance = base_separation + (first_loss_level - n) * 0.5
        elif n == first_loss_level:
            # Unter typischer Schwelle epsilon_n = 1/n (diagnostischer Verlustpunkt).
            distance = 0.2
        else:
            distance = base_separation / (2.0 ** (n - first_loss_level + 1))

        origin = tuple(0.0 for _ in range(dim))
        offset = tuple(0.0 for _ in range(dim))
        offset_list = list(offset)
        offset_list[0] = distance
        far = tuple(offset_list)

        series[n] = {
            "centroids": (origin, far),
            "radii": (0.5, 0.5),
            "sep": distance,
        }
    return series


def build_toy_shell_series_n_le_3(*, dim: int = 3) -> dict[int, dict[str, Any]]:
    """
    Toy-Schalen fuer ``n in {1,2,3}`` — **kein** globaler ``R^3``-Einbettungsclaim.

    Basiert auf kleinen expliziten Centroide-Layouts als Regressionstest-Schicht
    fuer E-078-Vorlaeufer (nur n<=3 dokumentiert in Evidenzregister).
    """
    if dim not in (2, 3):
        raise ValueError("Toy layer supports dim in {2, 3} only.")

    if dim == 2:
        layouts: dict[int, tuple[Point, ...]] = {
            1: ((0.0, 0.0), (4.0, 0.0)),
            2: ((0.0, 0.0), (3.0, 0.0), (1.5, 2.6)),
            3: ((0.0, 0.0), (2.5, 0.0), (1.25, 2.2), (2.5, 2.2)),
        }
    else:
        layouts = {
            1: ((0.0, 0.0, 0.0), (3.0, 0.0, 0.0)),
            2: (
                (0.0, 0.0, 0.0),
                (2.5, 0.0, 0.0),
                (1.25, 2.2, 0.0),
            ),
            3: (
                (0.0, 0.0, 0.0),
                (2.0, 0.0, 0.0),
                (1.0, 1.73, 0.0),
                (1.0, 0.58, 1.63),
            ),
        }

    series: dict[int, dict[str, Any]] = {}
    for n, centroids in layouts.items():
        shells = {i: (cent,) for i, cent in enumerate(centroids)}
        sep_n = shell_sep(shells)
        series[n] = {
            "centroids": centroids,
            "radii": tuple(0.4 for _ in centroids),
            "sep": sep_n,
            "source": "toy_n_le_3",
            "dim": dim,
        }
    return series


@dataclass(frozen=True)
class ShellSeparationReport:
    """Aggregierter Diagnosebericht fuer eine Schalenreihe."""

    sep_series: dict[int, float]
    overlap_series: dict[int, float]
    overlap_count_series: dict[int, int]
    loss_flags: dict[int, bool]
    embedding_quality_series: dict[int, float | None]
    first_loss_n: int | None
    box_dimension: float | None
    epsilon_fn_description: str
    metric_name: str
    epsilon_rule_name: str
    governance_note: str
    data_source: str


def run_shell_separation_diagnostics(
    shell_series: Mapping[int, Mapping[str, Any]],
    *,
    epsilon_fn: Callable[[int], float] | None = None,
    eps_grid: Sequence[float] = (0.5, 0.25, 0.125, 0.0625),
    point_cloud_for_dimension: Sequence[Point] | None = None,
    data_source: str = "unspecified",
    metric_name: str | None = None,
    epsilon_rule_name: str | None = None,
) -> ShellSeparationReport:
    """Fuehrt die E-077/E-079-Diagnosekette auf einer Schalenreihe aus."""
    from kepler_hurwitz.shell_construction import (
        CANONICAL_EPSILON_RULE_NAME,
        CANONICAL_METRIC_NAME,
        provisional_epsilon_n,
    )

    resolved_metric = metric_name or CANONICAL_METRIC_NAME
    resolved_epsilon_rule = epsilon_rule_name or CANONICAL_EPSILON_RULE_NAME
    threshold = epsilon_fn or provisional_epsilon_n

    sep_series: dict[int, float] = {}
    overlap_series: dict[int, float] = {}
    overlap_count_series: dict[int, int] = {}
    loss_flags: dict[int, bool] = {}
    embedding_quality_series: dict[int, float | None] = {}

    for n in sorted(shell_series):
        entry = shell_series[n]
        centroids = entry.get("centroids")
        radii = entry.get("radii")
        eps_n = threshold(n)
        if centroids is not None:
            shells = {i: (cent,) for i, cent in enumerate(centroids)}
            sep_series[n] = shell_sep(shells)
            overlap_count_series[n] = overlap(n, shells, eps_n)
            if radii is not None:
                overlap_series[n] = shell_overlap_metric(centroids, radii)
        elif "sep" in entry:
            sep_series[n] = float(entry["sep"])
            overlap_count_series[n] = 0
        else:
            sep_series[n] = sep(n, entry)  # type: ignore[arg-type]
            overlap_count_series[n] = 0

        loss_flags[n] = shell_separation_loss(sep_series[n], eps_n)
        embedding_quality_series[n] = embedding_quality(sep_series[n], eps_n)

    cloud = point_cloud_for_dimension
    if cloud is None:
        merged: list[Point] = []
        for n in sorted(shell_series):
            entry = shell_series[n]
            centroids = entry.get("centroids")
            if centroids:
                merged.extend(centroids)
        cloud = tuple(merged)

    dim_est = _box_dimension_from_point_cloud(cloud or (), eps_grid) if cloud else None

    return ShellSeparationReport(
        sep_series=sep_series,
        overlap_series=overlap_series,
        overlap_count_series=overlap_count_series,
        loss_flags=loss_flags,
        embedding_quality_series=embedding_quality_series,
        first_loss_n=first_loss_n(sep_series, threshold),
        box_dimension=dim_est,
        epsilon_fn_description="custom" if epsilon_fn else f"default: {resolved_epsilon_rule}",
        metric_name=resolved_metric,
        epsilon_rule_name=resolved_epsilon_rule,
        governance_note=GOVERNANCE_GUARD,
        data_source=data_source,
    )


SHELL_DIAGNOSTICS_CSV_FIELDS: tuple[str, ...] = (
    "n",
    "sep",
    "overlap_count",
    "overlap_metric",
    "epsilon_n",
    "epsilon_rule_name",
    "metric_name",
    "shell_separation_loss",
    "embedding_quality",
    "data_source",
)

BOX_DIMENSION_CSV_FIELDS: tuple[str, ...] = (
    "epsilon",
    "cover_count",
    "data_source",
)


def export_shell_separation_csv(
    report: ShellSeparationReport,
    path: Path | str,
    *,
    epsilon_fn: Callable[[int], float] | None = None,
) -> Path:
    """Exportiert Stufen-Diagnose als CSV."""
    from kepler_hurwitz.shell_construction import provisional_epsilon_n

    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    threshold = epsilon_fn or provisional_epsilon_n

    with out.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=SHELL_DIAGNOSTICS_CSV_FIELDS)
        writer.writeheader()
        for n in sorted(report.sep_series):
            eps_n = threshold(n)
            writer.writerow(
                {
                    "n": n,
                    "sep": report.sep_series[n],
                    "overlap_count": report.overlap_count_series.get(n, 0),
                    "overlap_metric": report.overlap_series.get(n, ""),
                    "epsilon_n": eps_n,
                    "epsilon_rule_name": report.epsilon_rule_name,
                    "metric_name": report.metric_name,
                    "shell_separation_loss": report.loss_flags[n],
                    "embedding_quality": report.embedding_quality_series.get(n, ""),
                    "data_source": report.data_source,
                }
            )
    return out


def export_box_dimension_csv(
    point_cloud: Sequence[Point],
    eps_grid: Sequence[float],
    path: Path | str,
    *,
    data_source: str = "unspecified",
    dim_estimate: float | None = None,
) -> Path:
    """Exportiert Box-Counting-Stuetzpunkte und optionale Dimensions-Schaetzung."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    eps_values = sorted({float(e) for e in eps_grid if e > 0})

    rows: list[dict[str, Any]] = []
    for eps in eps_values:
        rows.append(
            {
                "epsilon": eps,
                "cover_count": _box_count(point_cloud, eps) if point_cloud else 0,
                "data_source": data_source,
            }
        )

    with out.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=(*BOX_DIMENSION_CSV_FIELDS, "dim_B_estimate"),
        )
        writer.writeheader()
        est = dim_estimate
        if est is None and point_cloud:
            est = _box_dimension_from_point_cloud(point_cloud, eps_values)
        for idx, row in enumerate(rows):
            payload = dict(row)
            payload["dim_B_estimate"] = est if idx == 0 else ""
            writer.writerow(payload)
    return out


def export_shell_separation_json(
    report: ShellSeparationReport,
    path: Path | str,
) -> Path:
    """Exportiert Diagnosebericht als JSON."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    payload = asdict(report)
    out.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out
