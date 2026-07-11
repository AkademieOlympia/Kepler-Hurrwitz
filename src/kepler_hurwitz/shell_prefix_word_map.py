"""
Prefix ↔ EABC-Wortbaum-Abbildung (qec_bridge vs Energiedoku).

Governance
----------
Diagnose only — kein Lean-Satz, kein Beweis einer globalen Bijection.

``canonical_from_qec_bridge`` nutzt ``n+1`` Praefix-Vertices aus der Hurwitz-
Paritaetsliste; theorematisches ``ShellVertex(n)`` ist ``4^n`` Woerter ueber
``{E,A,B,C}`` in Lex-Reihenfolge. Eine **volle Bijection** existiert nicht
(cardinality mismatch + verschiedene Einbettungen).

Dieses Modul dokumentiert drei explizite Abbildungsregeln:

1. ``index_diagnostic`` — Praefix-Index ``i`` → ``i``-tes Lex-Wort (nur fuer
   Vergleich mit dem diagnostic subset ``min(n+1, 4^n)``).
2. ``coordinate_axis_label`` — kanonische R³-Koordinate → EABC-Buchstabe via
   dominantem Achsenvektor (mit Vorzeichen; Lean ``cardinalDir``-Vorzeichen).
3. ``coordinate_nearest_word`` — fuer Stufe ``n``, naechstes ``ShellVertex(n)``-
   Wort unter Energiedoku-Einbettung (partial, nicht injektiv auf vollem Praefix).

Siehe ``docs/reports/shell_separation_diagnostics_protocol.md`` Abschnitt
"Prefix mapping + full 4^n energiedoku (n=2,3)".
"""

from __future__ import annotations

import csv
import math
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Literal

from kepler_hurwitz.canonical_shell_vertices import (
    CANONICAL_SOURCE_LABEL,
    enumerate_canonical_shell_vertices,
    shell_vertex_count,
)
from kepler_hurwitz.energiedoku_shell_construction import (
    ENERGIEDOKU_SOURCE_LABEL,
    EClass,
    ECLASS_ORDER,
    ShellWord,
    cardinal_dir,
    diagnostic_shell_count,
    embed_shell_word,
    enumerate_shell_words,
    shell_word_count,
)

MappingRuleName = Literal[
    "index_diagnostic",
    "coordinate_axis_label",
    "coordinate_nearest_word",
]

BIJECTION_STATUS = "partial_no_global_bijection"
"""
Keine globale Bijection ``prefix_index ↔ ShellVertex(n)``:

- Kardinalitaet: Praefix ``n+1`` vs ``4^n`` Woerter.
- Reihenfolge: qec_bridge Paritaets-Entdeckungsreihenfolge vs Lex ``E<A<B<C``.
- Geometrie: Hurwitz-Projektion vs ``cardinalDir`` / ``phi^{-n}``-Gitter.
"""


class MappingRule(str, Enum):
    """Dokumentierte Abbildungsregeln (keine behauptete Bijection)."""

    INDEX_DIAGNOSTIC = "index_diagnostic"
    COORDINATE_AXIS_LABEL = "coordinate_axis_label"
    COORDINATE_NEAREST_WORD = "coordinate_nearest_word"


BIJECTION_REASONS: tuple[str, ...] = (
    "Cardinality: canonical prefix has n+1 vertices; ShellVertex(n) has 4^n words.",
    "Order: qec_bridge parity-class discovery order != lex E<A<B<C word order.",
    "Embedding: hurwitz_projected_imaginary_xyz != cardinalDir/lattice iota_n.",
    "Sign: canonical y/z axes are often negated vs Lean cardinalDir.",
    "Injective failure: multiple prefix indices can share nearest lex word at n>=2.",
)


def _round_r3(point: tuple[float, ...], *, digits: int = 6) -> tuple[float, ...]:
    return tuple(round(c, digits) for c in point)


def _l2(a: tuple[float, ...], b: tuple[float, ...]) -> float:
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b, strict=True)))


def _word_str(word: ShellWord) -> str:
    return "".join(c.value for c in word)


def canonical_prefix_coordinate(n: int, prefix_index: int) -> tuple[float, float, float]:
    """
    Track-A-Prefix-Koordinate ``(x,y,z)`` fuer Stufe ``n`` und Index ``prefix_index``.

    Shared helper for Path B2 unified bridge and prefix-word mapping.
    """
    if n not in (1, 2, 3):
        raise ValueError("canonical_prefix_coordinate supports n in {1,2,3} only.")
    vertices = enumerate_canonical_shell_vertices()
    needed = shell_vertex_count(n)
    if prefix_index < 0 or prefix_index >= needed:
        raise IndexError(
            f"prefix_index={prefix_index} out of range for n={n} (count={needed})."
        )
    return vertices[prefix_index].embedding_r3


def interpretive_axis_label_for_prefix(
    n: int,
    prefix_index: int,
    *,
    apply_sign_correction: bool = True,
) -> tuple[str, str]:
    """
    Interpretives Achsenlabel fuer Prefix-Index (Path B2 bridge helper).

    Returns ``(letter, rule_name)`` where ``rule_name`` is one of the documented
    mapping rules. Applies optional ``(x,-y,-z)`` sign correction before axis lookup.
    """
    if n not in (1, 2, 3):
        raise ValueError("interpretive_axis_label_for_prefix supports n in {1,2,3} only.")
    point = canonical_prefix_coordinate(n, prefix_index)
    if apply_sign_correction:
        point = (point[0], -point[1], -point[2])
    cls = axis_label_from_coordinate(point)
    if cls is not None:
        return cls.value, MappingRule.COORDINATE_AXIS_LABEL.value
    signed = axis_label_from_coordinate_signed(
        canonical_prefix_coordinate(n, prefix_index)
    )
    if signed:
        if signed in ("C", "E"):
            return signed, MappingRule.COORDINATE_AXIS_LABEL.value
        return signed.lstrip("-"), MappingRule.COORDINATE_AXIS_LABEL.value
    return "?", MappingRule.COORDINATE_NEAREST_WORD.value


def axis_label_from_coordinate(point: tuple[float, float, float]) -> EClass | None:
    """
    Dominanter Achsenvektor → EABC-Buchstabe (Lean ``cardinalDir``-Raum).

    ``None`` wenn kein eindeutiger Achsen-Dominanzvektor (z. B. Ursprung oder
    gleichgewichtete Achsen).
    """
    x, y, z = point
    ax, ay, az = abs(x), abs(y), abs(z)
    tol = 1e-9
    nonzero = sum(1 for v in (ax, ay, az) if v > tol)
    if nonzero == 0:
        return None
    if nonzero > 1 and max(ax, ay, az) - sorted((ax, ay, az))[-2] < tol:
        return None
    if ax >= ay and ax >= az:
        return EClass.C if x < 0 else EClass.E
    if ay >= ax and ay >= az:
        return EClass.A
    return EClass.B


def axis_label_from_coordinate_signed(point: tuple[float, float, float]) -> str | None:
    """
    Achsenlabel mit Vorzeichen, z. B. ``-x→C``, ``+y→A``, ``-z→-B``.

    Fuer Praefix-Vertices mit reinen Achsenrichtungen (|coord| in {0,1}).
    """
    x, y, z = point
    tol = 1e-9
    comps = [(abs(x), "x", x), (abs(y), "y", y), (abs(z), "z", z)]
    comps.sort(reverse=True)
    if comps[0][0] <= tol:
        return None
    if len(comps) > 1 and comps[0][0] - comps[1][0] < tol:
        return None
    axis, val = comps[0][1], comps[0][2]
    sign = "+" if val >= 0 else "-"
    letter = {"x": "E/C", "y": "A", "z": "B"}[axis]
    if axis == "x":
        return f"{'C' if val < 0 else 'E'}"
    if axis == "y":
        return f"{'-A' if val < 0 else 'A'}"
    return f"{'-B' if val < 0 else 'B'}"


def diagnostic_lex_word(prefix_index: int, n: int) -> ShellWord:
    """Praefix-Index ``i`` → ``i``-tes Lex-Wort der Laenge ``n`` (diagnostic subset)."""
    words = enumerate_shell_words(n)
    if prefix_index >= len(words):
        raise IndexError(
            f"prefix_index={prefix_index} out of range for ShellVertex({n}) lex list "
            f"(len={len(words)})."
        )
    return words[prefix_index]


def nearest_shell_word(
    point: tuple[float, float, float],
    n: int,
) -> tuple[ShellWord, float]:
    """Naechstes ``ShellVertex(n)``-Wort unter Energiedoku-Einbettung."""
    if n not in (1, 2, 3):
        raise ValueError("nearest_shell_word supports n in {1,2,3} only.")
    best_word: ShellWord | None = None
    best_dist = float("inf")
    for word in enumerate_shell_words(n):
        dist = _l2(point, embed_shell_word(word))
        if dist < best_dist:
            best_dist = dist
            best_word = word
    assert best_word is not None
    return best_word, best_dist


@dataclass(frozen=True)
class PrefixWordMapRow:
    """Eine Zeile der Prefix↔Wort-Vergleichstabelle."""

    n: int
    prefix_index: int
    canonical_x: float
    canonical_y: float
    canonical_z: float
    diagnostic_lex_word: str
    diagnostic_lex_x: float
    diagnostic_lex_y: float
    diagnostic_lex_z: float
    diagnostic_lex_diff_l2: float
    axis_label: str
    axis_cardinal_x: float
    axis_cardinal_y: float
    axis_cardinal_z: float
    axis_cardinal_diff_l2: float
    nearest_word_n: str
    nearest_word_x: float
    nearest_word_y: float
    nearest_word_z: float
    nearest_word_diff_l2: float
    coordinate_match_diagnostic: bool
    coordinate_match_nearest: bool
    bijection_status: str
    notes: str


@dataclass(frozen=True)
class PrefixWordMapReport:
    """Aggregierter Mapping-Bericht fuer ``n in {1,2,3}``."""

    rows: tuple[PrefixWordMapRow, ...]
    bijection_status: str
    bijection_reasons: tuple[str, ...]
    injective_index_diagnostic: bool
    injective_coordinate_nearest: bool
    recommendation: str


def compare_mapped_coordinates(n: int) -> tuple[PrefixWordMapRow, ...]:
    """
    Vergleiche Praefix-Vertices mit abgebildeten EABC-Woertern auf Stufe ``n``.

    ``n`` muss in ``{1,2,3}`` liegen (theorematische Einbettung).
    """
    if n not in (1, 2, 3):
        raise ValueError("compare_mapped_coordinates supports n in {1,2,3} only.")

    vertices = enumerate_canonical_shell_vertices()
    prefix_len = shell_vertex_count(n)
    if prefix_len > len(vertices):
        raise ValueError(f"Not enough canonical vertices for n={n}.")

    rows: list[PrefixWordMapRow] = []
    for i in range(prefix_len):
        canon = vertices[i]
        cp = canon.embedding_r3

        d_word = diagnostic_lex_word(i, n)
        dp = embed_shell_word(d_word)
        d_diff = _l2(cp, dp)

        axis_lbl = axis_label_from_coordinate_signed(cp) or ""
        axis_cls = axis_label_from_coordinate(cp)
        if axis_cls is not None:
            ap = _round_r3(cardinal_dir(axis_cls))
        else:
            ap = (float("nan"), float("nan"), float("nan"))
        a_diff = _l2(cp, ap) if axis_cls is not None else float("nan")

        n_word, n_dist = nearest_shell_word(cp, n)
        np_pt = embed_shell_word(n_word)

        notes: list[str] = []
        if d_diff < 1e-9:
            notes.append("diagnostic_lex_exact")
        elif d_diff < 0.05:
            notes.append("diagnostic_lex_near")
        else:
            notes.append("diagnostic_lex_divergent")
        if n_dist < 1e-9:
            notes.append("nearest_exact")
        if axis_lbl and axis_lbl.startswith("-"):
            notes.append("canonical_axis_sign_flip_vs_cardinalDir")

        rows.append(
            PrefixWordMapRow(
                n=n,
                prefix_index=i,
                canonical_x=cp[0],
                canonical_y=cp[1],
                canonical_z=cp[2],
                diagnostic_lex_word=_word_str(d_word),
                diagnostic_lex_x=dp[0],
                diagnostic_lex_y=dp[1],
                diagnostic_lex_z=dp[2],
                diagnostic_lex_diff_l2=d_diff,
                axis_label=axis_lbl,
                axis_cardinal_x=ap[0],
                axis_cardinal_y=ap[1],
                axis_cardinal_z=ap[2],
                axis_cardinal_diff_l2=a_diff,
                nearest_word_n=_word_str(n_word),
                nearest_word_x=np_pt[0],
                nearest_word_y=np_pt[1],
                nearest_word_z=np_pt[2],
                nearest_word_diff_l2=n_dist,
                coordinate_match_diagnostic=d_diff < 1e-9,
                coordinate_match_nearest=n_dist < 1e-9,
                bijection_status=BIJECTION_STATUS,
                notes="; ".join(notes),
            )
        )
    return tuple(rows)


def run_prefix_word_map(*, n_max: int = 3) -> PrefixWordMapReport:
    """Vollstaendiger Mapping-Lauf fuer ``n = 1 .. min(n_max, 3)``."""
    cap = min(n_max, 3)
    all_rows: list[PrefixWordMapRow] = []
    for n in range(1, cap + 1):
        all_rows.extend(compare_mapped_coordinates(n))

    # Injectivity checks on coordinate_nearest within each level
    nearest_injective = True
    for n in range(1, cap + 1):
        level_rows = [r for r in all_rows if r.n == n]
        nearest_words = [r.nearest_word_n for r in level_rows]
        if len(nearest_words) != len(set(nearest_words)):
            nearest_injective = False

    index_injective = True
    for n in range(1, cap + 1):
        if shell_vertex_count(n) > shell_word_count(n):
            index_injective = False

    exact_diag = sum(1 for r in all_rows if r.coordinate_match_diagnostic)
    exact_near = sum(1 for r in all_rows if r.nearest_word_diff_l2 < 1e-9)

    rec = (
        "No global prefix↔word bijection: cardinality n+1 vs 4^n, different orders, "
        "different embeddings. Use index_diagnostic only for aligned shell-count "
        "comparison; use coordinate_axis_label for sign-aware axis correspondence "
        "(canonical idx0≈C not E); use EnergiedokuShellConstruction mode='full' for "
        "theorematic ShellVertex(n) at n≤3. Do not replace qec_bridge prefix scaffold."
    )
    if exact_diag == 0 and exact_near == 0:
        rec += " Zero exact coordinate matches on diagnostic lex map — expected."

    return PrefixWordMapReport(
        rows=tuple(all_rows),
        bijection_status=BIJECTION_STATUS,
        bijection_reasons=BIJECTION_REASONS,
        injective_index_diagnostic=index_injective,
        injective_coordinate_nearest=nearest_injective,
        recommendation=rec,
    )


def export_prefix_word_map_csv(
    report: PrefixWordMapReport,
    path: Path | str,
) -> Path:
    """CSV-Export gemaess Protokoll-Vorgabe."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "n",
        "prefix_index",
        "canonical_x",
        "canonical_y",
        "canonical_z",
        "diagnostic_lex_word",
        "diagnostic_lex_x",
        "diagnostic_lex_y",
        "diagnostic_lex_z",
        "diagnostic_lex_diff_l2",
        "axis_label",
        "axis_cardinal_x",
        "axis_cardinal_y",
        "axis_cardinal_z",
        "axis_cardinal_diff_l2",
        "nearest_word_n",
        "nearest_word_x",
        "nearest_word_y",
        "nearest_word_z",
        "nearest_word_diff_l2",
        "coordinate_match_diagnostic",
        "coordinate_match_nearest",
        "bijection_status",
        "notes",
    ]
    with out.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for row in report.rows:
            writer.writerow(
                {
                    "n": row.n,
                    "prefix_index": row.prefix_index,
                    "canonical_x": row.canonical_x,
                    "canonical_y": row.canonical_y,
                    "canonical_z": row.canonical_z,
                    "diagnostic_lex_word": row.diagnostic_lex_word,
                    "diagnostic_lex_x": row.diagnostic_lex_x,
                    "diagnostic_lex_y": row.diagnostic_lex_y,
                    "diagnostic_lex_z": row.diagnostic_lex_z,
                    "diagnostic_lex_diff_l2": row.diagnostic_lex_diff_l2,
                    "axis_label": row.axis_label,
                    "axis_cardinal_x": row.axis_cardinal_x,
                    "axis_cardinal_y": row.axis_cardinal_y,
                    "axis_cardinal_z": row.axis_cardinal_z,
                    "axis_cardinal_diff_l2": row.axis_cardinal_diff_l2,
                    "nearest_word_n": row.nearest_word_n,
                    "nearest_word_x": row.nearest_word_x,
                    "nearest_word_y": row.nearest_word_y,
                    "nearest_word_z": row.nearest_word_z,
                    "nearest_word_diff_l2": row.nearest_word_diff_l2,
                    "coordinate_match_diagnostic": row.coordinate_match_diagnostic,
                    "coordinate_match_nearest": row.coordinate_match_nearest,
                    "bijection_status": row.bijection_status,
                    "notes": row.notes,
                }
            )
    return out


__all__ = [
    "BIJECTION_REASONS",
    "BIJECTION_STATUS",
    "MappingRule",
    "PrefixWordMapReport",
    "PrefixWordMapRow",
    "axis_label_from_coordinate",
    "axis_label_from_coordinate_signed",
    "canonical_prefix_coordinate",
    "compare_mapped_coordinates",
    "diagnostic_lex_word",
    "interpretive_axis_label_for_prefix",
    "export_prefix_word_map_csv",
    "nearest_shell_word",
    "run_prefix_word_map",
]
