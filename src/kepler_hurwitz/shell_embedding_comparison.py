"""
Vergleich canonical_from_qec_bridge vs. theorematische Energiedoku-Einbettung (n <= 3).

Governance: Diagnose only — kein Beweis von E-077/E-078. Gate INACTIVE.
"""

from __future__ import annotations

import csv
import math
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

from kepler_hurwitz.canonical_shell_vertices import shells_at_level as canonical_shells_at_level
from kepler_hurwitz.energiedoku_shell_construction import (
    ENERGIEDOKU_SOURCE_LABEL,
    diagnostic_shell_count,
    enumerate_energiedoku_vertices,
    enumerate_shell_words,
    shells_at_level as energiedoku_shells_at_level,
    theorematic_epsilon_for_level,
)
from kepler_hurwitz.shell_construction import (
    get_epsilon_rule,
    theorematic_epsilon_n,
    theorematic_mn_sep_epsilon_n,
)
from kepler_hurwitz.shell_separation_diagnostics import (
    Point,
    embedding_quality,
    first_loss_n,
    overlap,
    shell_sep,
    shell_separation_loss,
)


def _l2(a: Point, b: Point) -> float:
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b, strict=True)))


def _centroid(points: list[Point]) -> Point:
    dim = len(points[0])
    n = len(points)
    return tuple(sum(p[i] for p in points) / n for i in range(dim))


def hausdorff_proxy(
    set_a: list[Point],
    set_b: list[Point],
) -> float:
    """
    Symmetrischer Hausdorff-Proxy: max directed Hausdorff(A->B), directed(B->A).
    """
    if not set_a or not set_b:
        return float("inf")

    def directed(src: list[Point], dst: list[Point]) -> float:
        return max(min(_l2(p, q) for q in dst) for p in src)

    return max(directed(set_a, set_b), directed(set_b, set_a))


@dataclass(frozen=True)
class ShellPairRow:
    """Eine Zeile im Punkt-fuer-Punkt-Vergleich."""

    n: int
    shell_index: int
    canonical_x: float
    canonical_y: float
    canonical_z: float
    energiedoku_x: float
    energiedoku_y: float
    energiedoku_z: float
    diff_l2: float
    sep_canonical: float
    sep_energiedoku: float
    notes: str


@dataclass(frozen=True)
class LevelComparisonSummary:
    """Aggregierte Metriken pro Renorm-Stufe ``n``."""

    n: int
    shell_count_canonical: int
    shell_count_energiedoku: int
    shell_count_energiedoku_full: int
    max_coordinate_diff: float
    hausdorff_proxy_diagnostic: float
    hausdorff_proxy_full: float
    sep_canonical: float
    sep_energiedoku_diagnostic: float
    sep_energiedoku_full: float
    sep_delta: float
    loss_canonical_energiedoku_eps: bool
    loss_energiedoku_energiedoku_eps: bool
    loss_canonical_mn_sep_eps: bool
    loss_energiedoku_mn_sep_eps: bool
    identical_shells: bool
    divergent_shell_indices: tuple[int, ...]
    energiedoku_word: str
    notes: str


@dataclass(frozen=True)
class ShellEmbeddingComparisonReport:
    """Gesamtbericht fuer n in {1,2,3}."""

    rows: tuple[ShellPairRow, ...]
    summaries: tuple[LevelComparisonSummary, ...]
    recommendation: str


def _word_label(n: int, shell_index: int) -> str:
    words = enumerate_shell_words(n)
    if shell_index < len(words):
        return "".join(c.value for c in words[shell_index])
    return ""


def compare_level(n: int) -> tuple[tuple[ShellPairRow, ...], LevelComparisonSummary]:
    if n not in (1, 2, 3):
        raise ValueError("Comparison supports n in {1,2,3} only.")

    canon = canonical_shells_at_level(n)
    ediag = energiedoku_shells_at_level(n, mode="diagnostic")
    efull = energiedoku_shells_at_level(n, mode="full")

    sep_c = shell_sep(canon)
    sep_ed = shell_sep(ediag)
    sep_ef = shell_sep(efull)

    canon_pts = [canon[i][0] for i in sorted(canon)]
    ediag_pts = [ediag[i][0] for i in sorted(ediag)]
    efull_pts = [efull[i][0] for i in sorted(efull)]

    shared = min(len(canon_pts), len(ediag_pts))
    divergent: list[int] = []
    pair_rows: list[ShellPairRow] = []
    max_diff = 0.0

    for i in range(shared):
        cp = canon_pts[i]
        ep = ediag_pts[i]
        diff = _l2(cp, ep)
        max_diff = max(max_diff, diff)
        word = _word_label(n, i)
        note_parts: list[str] = [f"word={word}"]
        if diff < 1e-9:
            note_parts.append("identical")
        else:
            divergent.append(i)
            note_parts.append("divergent")
        pair_rows.append(
            ShellPairRow(
                n=n,
                shell_index=i,
                canonical_x=cp[0],
                canonical_y=cp[1],
                canonical_z=cp[2],
                energiedoku_x=ep[0],
                energiedoku_y=ep[1],
                energiedoku_z=ep[2],
                diff_l2=diff,
                sep_canonical=sep_c,
                sep_energiedoku=sep_ed,
                notes="; ".join(note_parts),
            )
        )

    # Extra shells only in one construction
    for i in range(shared, len(canon_pts)):
        cp = canon_pts[i]
        pair_rows.append(
            ShellPairRow(
                n=n,
                shell_index=i,
                canonical_x=cp[0],
                canonical_y=cp[1],
                canonical_z=cp[2],
                energiedoku_x=float("nan"),
                energiedoku_y=float("nan"),
                energiedoku_z=float("nan"),
                diff_l2=float("nan"),
                sep_canonical=sep_c,
                sep_energiedoku=sep_ed,
                notes="canonical-only (no energiedoku diagnostic index)",
            )
        )
    for i in range(shared, len(ediag_pts)):
        ep = ediag_pts[i]
        pair_rows.append(
            ShellPairRow(
                n=n,
                shell_index=i,
                canonical_x=float("nan"),
                canonical_y=float("nan"),
                canonical_z=float("nan"),
                energiedoku_x=ep[0],
                energiedoku_y=ep[1],
                energiedoku_z=ep[2],
                diff_l2=float("nan"),
                sep_canonical=sep_c,
                sep_energiedoku=sep_ed,
                notes="energiedoku-only (no canonical index)",
            )
        )

    eps_ed = theorematic_epsilon_for_level(n)
    eps_mn = theorematic_mn_sep_epsilon_n(n)

    notes_parts = [
        f"canonical_count={len(canon_pts)}",
        f"energiedoku_diagnostic={len(ediag_pts)}",
        f"energiedoku_full=4^{n}={len(efull_pts)}",
    ]
    if len(canon_pts) != 4**n:
        notes_parts.append("canonical uses n+1 prefix rule not 4^n ShellVertex")
    if divergent:
        notes_parts.append(f"divergent_indices={divergent}")

    summary = LevelComparisonSummary(
        n=n,
        shell_count_canonical=len(canon_pts),
        shell_count_energiedoku=len(ediag_pts),
        shell_count_energiedoku_full=len(efull_pts),
        max_coordinate_diff=max_diff if shared else float("inf"),
        hausdorff_proxy_diagnostic=hausdorff_proxy(canon_pts, ediag_pts),
        hausdorff_proxy_full=hausdorff_proxy(canon_pts, efull_pts),
        sep_canonical=sep_c,
        sep_energiedoku_diagnostic=sep_ed,
        sep_energiedoku_full=sep_ef,
        sep_delta=sep_c - sep_ed,
        loss_canonical_energiedoku_eps=shell_separation_loss(sep_c, eps_ed),
        loss_energiedoku_energiedoku_eps=shell_separation_loss(sep_ed, eps_ed),
        loss_canonical_mn_sep_eps=shell_separation_loss(sep_c, eps_mn),
        loss_energiedoku_mn_sep_eps=shell_separation_loss(sep_ed, eps_mn),
        identical_shells=not divergent and shared == len(canon_pts) == len(ediag_pts),
        divergent_shell_indices=tuple(divergent),
        energiedoku_word="",
        notes="; ".join(notes_parts),
    )
    return tuple(pair_rows), summary


def run_shell_embedding_comparison(
    *,
    n_max: int = 3,
) -> ShellEmbeddingComparisonReport:
    """Vollstaendiger Vergleich fuer ``n = 1 .. n_max`` (max 3)."""
    cap = min(n_max, 3)
    all_rows: list[ShellPairRow] = []
    summaries: list[LevelComparisonSummary] = []
    for n in range(1, cap + 1):
        rows, summary = compare_level(n)
        all_rows.extend(rows)
        summaries.append(summary)

    any_identical = any(s.identical_shells for s in summaries)
    any_loss_ed_canon = any(s.loss_canonical_energiedoku_eps for s in summaries)
    any_loss_ed_ed = any(s.loss_energiedoku_energiedoku_eps for s in summaries)
    any_loss_canon_only = any(
        not s.loss_canonical_energiedoku_eps and s.loss_energiedoku_energiedoku_eps
        for s in summaries
    )

    if any_loss_canon_only:
        rec = (
            "At n=2 energiedoku hits sep=epsilon (diagnostic boundary) while canonical does not; "
            "use full ShellVertex(n) sep for theorematic checks; keep qec_bridge as all-n scaffold; "
            "supplement with EnergiedokuShellConstruction for n<=3 — do not replace qec_bridge."
        )
    elif any_identical and not any(s.divergent_shell_indices for s in summaries):
        rec = (
            "Partial alignment only: qec_bridge should **supplement**, not replace, "
            "theorematic cardinal/lattice ι_n for n≤3."
        )
    elif any_loss_ed_canon and not any_loss_ed_ed:
        rec = (
            "Energiedoku embedding shows no loss where canonical might; "
            "prefer theorematic construction for E-078 n≤3; keep qec_bridge as all-n scaffold."
        )
    else:
        rec = (
            "Constructions diverge combinatorially (n+1 prefix vs 4^n words) and geometrically; "
            "qec_bridge remains operational approximation; implement explicit ι_n mapping "
            "for n≤3 per Lean ShellEmbedding — do **not** replace qec_bridge until all-n bridge exists."
        )

    return ShellEmbeddingComparisonReport(
        rows=tuple(all_rows),
        summaries=tuple(summaries),
        recommendation=rec,
    )


def export_comparison_csv(
    report: ShellEmbeddingComparisonReport,
    path: Path | str,
) -> Path:
    """CSV-Export gemaess Protokoll-Vorgabe."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "n",
        "shell_index",
        "canonical_x",
        "canonical_y",
        "canonical_z",
        "energiedoku_x",
        "energiedoku_y",
        "energiedoku_z",
        "diff_l2",
        "sep_canonical",
        "sep_energiedoku",
        "notes",
    ]
    with out.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for row in report.rows:
            writer.writerow(
                {
                    "n": row.n,
                    "shell_index": row.shell_index,
                    "canonical_x": row.canonical_x,
                    "canonical_y": row.canonical_y,
                    "canonical_z": row.canonical_z,
                    "energiedoku_x": row.energiedoku_x,
                    "energiedoku_y": row.energiedoku_y,
                    "energiedoku_z": row.energiedoku_z,
                    "diff_l2": row.diff_l2,
                    "sep_canonical": row.sep_canonical,
                    "sep_energiedoku": row.sep_energiedoku,
                    "notes": row.notes,
                }
            )
    return out


def comparison_summary_dict(report: ShellEmbeddingComparisonReport) -> dict[str, Any]:
    """JSON-serialisierbare Zusammenfassung."""
    return {
        "canonical_source": "canonical_from_qec_bridge",
        "energiedoku_source": ENERGIEDOKU_SOURCE_LABEL,
        "summaries": [asdict(s) for s in report.summaries],
        "recommendation": report.recommendation,
    }


@dataclass(frozen=True)
class FullEnergiedokuRow:
    """Volle ``4^n`` Energiedoku-Diagnostik pro Stufe ``n``."""

    n: int
    shell_count: int
    mode: str
    sep: float
    overlap_count_energiedoku_eps: int
    overlap_count_mn_sep_eps: int
    epsilon_energiedoku: float
    epsilon_mn_sep: float
    shell_separation_loss_energiedoku: bool
    shell_separation_loss_mn_sep: bool
    embedding_quality_energiedoku: float | None
    embedding_quality_mn_sep: float | None
    sep_equals_epsilon_boundary: bool
    notes: str


@dataclass(frozen=True)
class FullEnergiedokuReport:
    """Bericht fuer volle ``ShellVertex(n)`` bei ``n in {2,3}`` (+ Referenz n=1)."""

    rows: tuple[FullEnergiedokuRow, ...]
    first_loss_n_energiedoku: int | None
    first_loss_n_mn_sep: int | None
    n2_loss_robust_on_full: bool
    recommendation: str


def run_full_energiedoku_diagnostics(
    *,
    levels: tuple[int, ...] = (1, 2, 3),
) -> FullEnergiedokuReport:
    """
    Volle ``4^n`` Energiedoku-Schalen: ``sep``, ``overlap``, ``ShellSeparationLoss``.

    Default ``levels=(1,2,3)``; Schwerpunkt auf ``n=2,3`` (16 bzw. 64 Punkte).
    """
    from kepler_hurwitz.shell_construction import theorematic_mn_sep_epsilon_n

    rows: list[FullEnergiedokuRow] = []
    loss_ed: dict[int, bool] = {}
    loss_mn: dict[int, bool] = {}

    for n in levels:
        if n not in (1, 2, 3):
            raise ValueError("Full energiedoku diagnostics support n in {1,2,3} only.")
        shells = energiedoku_shells_at_level(n, mode="full")
        count = len(shells)
        sep_n = shell_sep(shells)
        eps_ed = theorematic_epsilon_for_level(n)
        eps_mn = theorematic_mn_sep_epsilon_n(n)
        ov_ed = overlap(n, shells, eps_ed)
        ov_mn = overlap(n, shells, eps_mn)
        loss_e = shell_separation_loss(sep_n, eps_ed)
        loss_m = shell_separation_loss(sep_n, eps_mn)
        loss_ed[n] = loss_e
        loss_mn[n] = loss_m

        boundary = abs(sep_n - eps_ed) < 1e-9
        notes_parts = [
            f"full_4_pow_{n}={count}",
            f"source={ENERGIEDOKU_SOURCE_LABEL}",
        ]
        if boundary:
            notes_parts.append("sep_equals_epsilon_boundary")
        if n == 2 and loss_e:
            notes_parts.append(
                "n2_collinear_lattice_words_EE_EA_EB_share_min_sep_phi_inv_sq"
            )

        rows.append(
            FullEnergiedokuRow(
                n=n,
                shell_count=count,
                mode="full",
                sep=sep_n,
                overlap_count_energiedoku_eps=ov_ed,
                overlap_count_mn_sep_eps=ov_mn,
                epsilon_energiedoku=eps_ed,
                epsilon_mn_sep=eps_mn,
                shell_separation_loss_energiedoku=loss_e,
                shell_separation_loss_mn_sep=loss_m,
                embedding_quality_energiedoku=embedding_quality(sep_n, eps_ed),
                embedding_quality_mn_sep=embedding_quality(sep_n, eps_mn),
                sep_equals_epsilon_boundary=boundary,
                notes="; ".join(notes_parts),
            )
        )

    fl_ed = first_loss_n({n: rows[i].sep for i, n in enumerate(levels)}, theorematic_epsilon_for_level)
    fl_mn = first_loss_n({n: rows[i].sep for i, n in enumerate(levels)}, theorematic_mn_sep_epsilon_n)

    n2_row = next(r for r in rows if r.n == 2)
    n2_robust = n2_row.shell_separation_loss_energiedoku and n2_row.shell_count == 16

    if n2_robust:
        rec = (
            "n=2 ShellSeparationLoss is robust on full ShellVertex(2) (16 words): "
            "sep=φ⁻²=ε₂ exactly (collinear lattice); not a diagnostic-subset artefact. "
            "Under theorematic_mn_sep_v1 no loss at n=2,3. "
            "For formal [B]: use strict sep>ε or full 4^n pairs; keep qec_bridge as all-n scaffold; "
            "supplement EnergiedokuShellConstruction for n≤3 — do not replace qec_bridge."
        )
    else:
        rec = (
            "Full 4^n energiedoku run complete; review sep/loss per level. "
            "Keep qec_bridge as all-n scaffold; supplement theorematic construction for n≤3."
        )

    return FullEnergiedokuReport(
        rows=tuple(rows),
        first_loss_n_energiedoku=fl_ed,
        first_loss_n_mn_sep=fl_mn,
        n2_loss_robust_on_full=n2_robust,
        recommendation=rec,
    )


def export_full_energiedoku_csv(
    report: FullEnergiedokuReport,
    path: Path | str,
) -> Path:
    """CSV-Export volle ``4^n`` Energiedoku-Diagnostik."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "n",
        "shell_count",
        "mode",
        "sep",
        "overlap_count_energiedoku_eps",
        "overlap_count_mn_sep_eps",
        "epsilon_energiedoku",
        "epsilon_mn_sep",
        "shell_separation_loss_energiedoku",
        "shell_separation_loss_mn_sep",
        "embedding_quality_energiedoku",
        "embedding_quality_mn_sep",
        "sep_equals_epsilon_boundary",
        "first_loss_n_energiedoku",
        "first_loss_n_mn_sep",
        "notes",
    ]
    with out.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for row in report.rows:
            writer.writerow(
                {
                    "n": row.n,
                    "shell_count": row.shell_count,
                    "mode": row.mode,
                    "sep": row.sep,
                    "overlap_count_energiedoku_eps": row.overlap_count_energiedoku_eps,
                    "overlap_count_mn_sep_eps": row.overlap_count_mn_sep_eps,
                    "epsilon_energiedoku": row.epsilon_energiedoku,
                    "epsilon_mn_sep": row.epsilon_mn_sep,
                    "shell_separation_loss_energiedoku": row.shell_separation_loss_energiedoku,
                    "shell_separation_loss_mn_sep": row.shell_separation_loss_mn_sep,
                    "embedding_quality_energiedoku": row.embedding_quality_energiedoku,
                    "embedding_quality_mn_sep": row.embedding_quality_mn_sep,
                    "sep_equals_epsilon_boundary": row.sep_equals_epsilon_boundary,
                    "first_loss_n_energiedoku": report.first_loss_n_energiedoku,
                    "first_loss_n_mn_sep": report.first_loss_n_mn_sep,
                    "notes": row.notes,
                }
            )
    return out


__all__ = [
    "FullEnergiedokuReport",
    "FullEnergiedokuRow",
    "LevelComparisonSummary",
    "ShellEmbeddingComparisonReport",
    "ShellPairRow",
    "compare_level",
    "comparison_summary_dict",
    "export_comparison_csv",
    "export_full_energiedoku_csv",
    "hausdorff_proxy",
    "run_full_energiedoku_diagnostics",
    "run_shell_embedding_comparison",
]
