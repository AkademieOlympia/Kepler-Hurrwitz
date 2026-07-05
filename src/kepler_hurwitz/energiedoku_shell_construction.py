"""
Theorematische Energiedoku-Schalenkonstruktion fuer n in {1, 2, 3}.

Governance
----------
Quelle: Energiedoku §8 (`docs/energiedoku_exports/eabc_renormalisierungsprogramm.md`)
und Lean ``EabcRenorm/ShellEmbedding.lean`` (``cardinalShellEmbedding_one/two/three``).

``ShellVertex(n)`` ist ein Wort der Laenge ``n`` ueber ``{E, A, B, C}`` (4-ary tree;
``|ShellVertex(n)| = 4^n``). Die Einbettung ``iota_n`` ist hier die **cardinal/lattice**
Realisierung aus Lean — nicht die Ikosaeder-Variante ``icosahedronShellEmbedding_one``.

Separationsparameter (Energiedoku §8):

- ``n=1``: ``epsilon_1 = 1``   (``cardinalShellEmbedding_one``)
- ``n=2``: ``epsilon_2 = phi^{-2}`` (``cardinalShellEmbedding_two``)
- ``n=3``: ``epsilon_3 = phi^{-3}`` (``cardinalShellEmbedding_three``)

Abweichung von ``canonical_from_qec_bridge``: qec_bridge nutzt dyadische Hurwitz-
Projektion und operational ``n+1`` Praefix-Vertices — **nicht** ``4^n`` Woerter.

Koordinaten-Source of Truth
---------------------------
Wenn ``docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv`` existiert,
werden Koordinaten daraus geladen (kanonische Audit-Regel). Fallback: code generation
aus Lean ``cardinalDir`` / lattice ``(phi^{-n}) * classIndex`` (siehe
``_embed_shell_word_from_code``).
"""

from __future__ import annotations

import csv
import itertools
import math
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import TYPE_CHECKING

from kepler_hurwitz.shell_construction import (
    PHI,
    PHI_INV_CUBE,
    PHI_INV_SQ,
    CANONICAL_METRIC_NAME,
)

if TYPE_CHECKING:
    from kepler_hurwitz.shell_separation_diagnostics import Point

ENERGIEDOKU_SOURCE_LABEL = "theorematic_energiedoku_cardinal_lattice"
"""Transparenzlabel fuer Exporte und Protokoll."""

ENERGIEDOKU_EMBEDDING_METHOD = "cardinal_dir_n1_lattice_phi_n2_n3"
"""
``n=1``: ``cardinalDir(c)``; ``n=2,3``: Gitter ``(phi^{-n}) * classIndex(c_i)`` in R³.
"""

ENERGIEDOKU_LEAN_REFERENCE = "EabcRenorm/ShellEmbedding.lean (cardinalShellEmbedding_*)"

DEFAULT_COORDINATES_CSV = (
    Path(__file__).resolve().parents[2]
    / "docs"
    / "energiedoku_exports"
    / "shell_coordinates_energiedoku_n1_n3.csv"
)
"""Kanonische maschinenlesbare Energiedoku-Koordinaten (n=1,2,3; volle 4^n)."""

ECLASS_ORDER: tuple[str, ...] = ("E", "A", "B", "C")

CSV_FIELDNAMES = ("n", "shell", "label", "x", "y", "z")


class EClass(str, Enum):
    """Vier EABC-Familien (Lean ``EClass``)."""

    E = "E"
    A = "A"
    B = "B"
    C = "C"


ShellWord = tuple[EClass, ...]

# Lazy-loaded coordinate table: n -> shell_index -> (label, point)
_COORDINATE_TABLE: dict[int, dict[int, tuple[str, Point]]] | None = None
_COORDINATE_SOURCE: str | None = None
_LABEL_LOOKUP: dict[tuple[int, str], Point] | None = None


def _round_r3(point: Point, *, digits: int = 6) -> Point:
    return tuple(round(c, digits) for c in point)


def class_index(c: EClass) -> int:
    """Lean ``classIndex``: E=0, A=1, B=2, C=3."""
    return ECLASS_ORDER.index(c.value)


def cardinal_dir(c: EClass) -> Point:
    """Lean ``cardinalDir`` — cardinalShellEmbedding_one."""
    mapping: dict[EClass, Point] = {
        EClass.E: (1.0, 0.0, 0.0),
        EClass.A: (0.0, 1.0, 0.0),
        EClass.B: (0.0, 0.0, 1.0),
        EClass.C: (-1.0, 0.0, 0.0),
    }
    return mapping[c]


def _embed_shell_word_from_code(word: ShellWord) -> Point:
    """
    Fallback code generation from Lean cardinal/lattice rules.

    ``n=1``: ``cardinalDir``; ``n=2,3``: ``(phi^{-n}) * classIndex`` lattice in R³.
    """
    n = len(word)
    if n == 1:
        return _round_r3(cardinal_dir(word[0]))
    if n == 2:
        s = PHI_INV_SQ
        return _round_r3(
            (
                s * class_index(word[0]),
                s * class_index(word[1]),
                0.0,
            )
        )
    if n == 3:
        s = PHI_INV_CUBE
        return _round_r3(
            (
                s * class_index(word[0]),
                s * class_index(word[1]),
                s * class_index(word[2]),
            )
        )
    raise NotImplementedError(
        f"Energiedoku cardinal/lattice embedding implemented for n in {{1,2,3}}; got n={n}."
    )


def _generate_coordinate_table_from_code() -> dict[int, dict[int, tuple[str, Point]]]:
    """Build full 4^n coordinate table from Lean/cardinal/lattice rules."""
    table: dict[int, dict[int, tuple[str, Point]]] = {}
    for n in (1, 2, 3):
        level: dict[int, tuple[str, Point]] = {}
        for i, w in enumerate(enumerate_shell_words(n)):
            label = "".join(c.value for c in w)
            level[i] = (label, _embed_shell_word_from_code(w))
        table[n] = level
    return table


def _parse_coordinate_row(row: dict[str, str]) -> tuple[int, int, str, Point]:
    n = int(row["n"])
    shell = int(row["shell"])
    label = row["label"].strip()
    point = (float(row["x"]), float(row["y"]), float(row["z"]))
    return n, shell, label, point


def load_coordinates_from_csv(
    path: Path | str = DEFAULT_COORDINATES_CSV,
) -> dict[int, dict[int, tuple[str, Point]]]:
    """
    Load canonical Energiedoku coordinates from CSV.

    Expected columns: ``n,shell,label,x,y,z``.
    """
    csv_path = Path(path)
    if not csv_path.is_file():
        raise FileNotFoundError(f"Energiedoku coordinates CSV not found: {csv_path}")

    table: dict[int, dict[int, tuple[str, Point]]] = {}
    with csv_path.open(newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        if reader.fieldnames is None or tuple(reader.fieldnames) != CSV_FIELDNAMES:
            raise ValueError(
                f"Expected CSV columns {CSV_FIELDNAMES}; got {reader.fieldnames}."
            )
        for row in reader:
            n, shell, label, point = _parse_coordinate_row(row)
            if n not in table:
                table[n] = {}
            table[n][shell] = (label, point)
    return table


def _build_label_lookup(
    table: dict[int, dict[int, tuple[str, Point]]],
) -> dict[tuple[int, str], Point]:
    lookup: dict[tuple[int, str], Point] = {}
    for n, shells in table.items():
        for _shell, (label, point) in shells.items():
            lookup[(n, label)] = point
    return lookup


def _ensure_coordinate_table(
    *,
    csv_path: Path | str | None = None,
    force_reload: bool = False,
) -> None:
    """Load coordinate table once: CSV if present, else code generation fallback."""
    global _COORDINATE_TABLE, _COORDINATE_SOURCE, _LABEL_LOOKUP

    if _COORDINATE_TABLE is not None and not force_reload:
        return

    path = Path(csv_path) if csv_path is not None else DEFAULT_COORDINATES_CSV
    if path.is_file():
        _COORDINATE_TABLE = load_coordinates_from_csv(path)
        _COORDINATE_SOURCE = f"csv:{path.name}"
    else:
        _COORDINATE_TABLE = _generate_coordinate_table_from_code()
        _COORDINATE_SOURCE = "code_generated_fallback"
    _LABEL_LOOKUP = _build_label_lookup(_COORDINATE_TABLE)


def coordinates_source(
    *,
    csv_path: Path | str | None = None,
) -> str:
    """Return active coordinate source label (``csv:...`` or ``code_generated_fallback``)."""
    _ensure_coordinate_table(csv_path=csv_path)
    assert _COORDINATE_SOURCE is not None
    return _COORDINATE_SOURCE


def coordinate_table(
    *,
    csv_path: Path | str | None = None,
    force_reload: bool = False,
) -> dict[int, dict[int, tuple[str, Point]]]:
    """Return loaded coordinate table for n in {1,2,3}."""
    _ensure_coordinate_table(csv_path=csv_path, force_reload=force_reload)
    assert _COORDINATE_TABLE is not None
    return _COORDINATE_TABLE


def coordinate_count_for_level(n: int) -> int:
    """Number of coordinates available for level ``n`` in the active table."""
    table = coordinate_table()
    if n not in table:
        raise NotImplementedError(
            f"Energiedoku coordinates available for n in {{1,2,3}}; got n={n}."
        )
    return len(table[n])


def export_energiedoku_coordinates_csv(
    path: Path | str = DEFAULT_COORDINATES_CSV,
    *,
    use_code_generation: bool = True,
) -> Path:
    """
    Write canonical coordinate CSV from code generation (Lean/cardinal/lattice rules).

    Used to (re)generate ``shell_coordinates_energiedoku_n1_n3.csv``.
    """
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    table = (
        _generate_coordinate_table_from_code()
        if use_code_generation
        else coordinate_table(force_reload=True)
    )
    with out.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(CSV_FIELDNAMES)
        for n in sorted(table):
            for shell in sorted(table[n]):
                label, (x, y, z) = table[n][shell]
                writer.writerow([n, shell, label, x, y, z])
    return out


def enumerate_shell_words(n: int) -> tuple[ShellWord, ...]:
    """
    Alle ``ShellVertex(n)`` in fixierter Lex-Reihenfolge (E < A < B < C).

    ``|words| = 4^n``.
    """
    if n < 1:
        raise ValueError("n must be >= 1 for ShellVertex(n).")
    classes = tuple(EClass(c) for c in ECLASS_ORDER)
    return tuple(tuple(w) for w in itertools.product(classes, repeat=n))


def shell_word_count(n: int) -> int:
    """``4^n`` — Lean ``shellVertex_card``."""
    if n < 1:
        raise ValueError("n must be >= 1.")
    return 4**n


def diagnostic_shell_count(n: int) -> int:
    """
    Operational diagnostic shell count aligned with ``canonical_from_qec_bridge``:

    ``n+1`` Praefix-Vertices (protokoll-kompatibel fuer ``sep(n)``-Vergleich).
    """
    if n < 1:
        raise ValueError("n must be >= 1.")
    return min(n + 1, shell_word_count(n))


def embed_shell_word(word: ShellWord) -> Point:
    """
    ``iota_n(w)`` fuer ``n = len(word) in {1,2,3}`` (cardinal/lattice branch).

    Uses canonical CSV coordinates when available; falls back to code generation.
    """
    n = len(word)
    if n not in (1, 2, 3):
        raise NotImplementedError(
            f"Energiedoku cardinal/lattice embedding implemented for n in {{1,2,3}}; got n={n}."
        )
    _ensure_coordinate_table()
    assert _LABEL_LOOKUP is not None
    label = "".join(c.value for c in word)
    if (n, label) in _LABEL_LOOKUP:
        return _LABEL_LOOKUP[(n, label)]
    return _embed_shell_word_from_code(word)


def theorematic_epsilon_for_level(n: int) -> float:
    """Energiedoku §8 Separationsparameter fuer ``n in {1,2,3}``."""
    if n == 1:
        return 1.0
    if n == 2:
        return PHI_INV_SQ
    if n == 3:
        return PHI_INV_CUBE
    raise NotImplementedError(
        f"Energiedoku §8 documents epsilon_n only for n in {{1,2,3}}; got n={n}."
    )


def shells_at_level(
    n: int,
    *,
    mode: str = "diagnostic",
) -> dict[int, list[Point]]:
    """
    ``shell_index -> [centroid]`` auf Renorm-Stufe ``n``.

    ``mode='diagnostic'``: erste ``n+1`` Woerter (Vergleich mit qec_bridge-Praefix).
    ``mode='full'``: alle ``4^n`` Woerter (theorematische ShellVertex-Menge).

    Koordinaten aus kanonischer CSV (wenn vorhanden) oder Code-Fallback.
    """
    if n not in (1, 2, 3):
        raise NotImplementedError(
            f"build_energiedoku_shells_n_le_3 supports n in {{1,2,3}}; got n={n}."
        )
    table = coordinate_table()
    shells_sorted = sorted(table[n].items())
    if mode == "diagnostic":
        shells_sorted = shells_sorted[: diagnostic_shell_count(n)]
    elif mode != "full":
        raise ValueError("mode must be 'diagnostic' or 'full'.")
    return {shell: [point] for shell, (_label, point) in shells_sorted}


def build_energiedoku_shells_n_le_3(
    *,
    mode: str = "diagnostic",
) -> dict[int, dict[int, list[Point]]]:
    """Convenience: ``n -> shells_at_level(n)`` fuer ``n in {1,2,3}``."""
    return {n: shells_at_level(n, mode=mode) for n in (1, 2, 3)}


@dataclass(frozen=True)
class EnergiedokuShellVertex:
    """Ein Shell-Vertex mit theorematischer R³-Einbettung."""

    shell_index: int
    word: ShellWord
    embedding_r3: Point


def enumerate_energiedoku_vertices(
    n: int,
    *,
    mode: str = "diagnostic",
) -> tuple[EnergiedokuShellVertex, ...]:
    """Liste der eingebetteten Vertices auf Stufe ``n``."""
    table = coordinate_table()
    items = sorted(table[n].items())
    if mode == "diagnostic":
        items = items[: diagnostic_shell_count(n)]
    elif mode != "full":
        raise ValueError("mode must be 'diagnostic' or 'full'.")
    result: list[EnergiedokuShellVertex] = []
    for shell, (label, point) in items:
        word = tuple(EClass(c) for c in label)
        result.append(
            EnergiedokuShellVertex(
                shell_index=shell,
                word=word,
                embedding_r3=point,
            )
        )
    return tuple(result)


@dataclass(frozen=True)
class EnergiedokuShellConstruction:
    """
    Theorematische ``ShellVertex(n) -> R^3`` fuer ``n in {1,2,3}``.

    Siehe ``EnergiedokuShellConstruction`` / ``build_energiedoku_shells_n_le_3``.
    """

    mode: str = "diagnostic"

    def shells_at(self, n: int) -> dict[int, list[Point]]:
        return shells_at_level(n, mode=self.mode)

    def metric_name(self) -> str:
        return CANONICAL_METRIC_NAME

    def epsilon_rule(self, n: int) -> float:
        return theorematic_epsilon_for_level(n)

    def epsilon_rule_name(self) -> str:
        return "theorematic_energiedoku_v1"

    def construction_name(self) -> str:
        return ENERGIEDOKU_SOURCE_LABEL

    def coordinates_source(self) -> str:
        return coordinates_source()


__all__ = [
    "CSV_FIELDNAMES",
    "DEFAULT_COORDINATES_CSV",
    "ENERGIEDOKU_EMBEDDING_METHOD",
    "ENERGIEDOKU_LEAN_REFERENCE",
    "ENERGIEDOKU_SOURCE_LABEL",
    "EClass",
    "ECLASS_ORDER",
    "EnergiedokuShellConstruction",
    "EnergiedokuShellVertex",
    "ShellWord",
    "build_energiedoku_shells_n_le_3",
    "cardinal_dir",
    "class_index",
    "coordinate_count_for_level",
    "coordinate_table",
    "coordinates_source",
    "diagnostic_shell_count",
    "embed_shell_word",
    "enumerate_energiedoku_vertices",
    "enumerate_shell_words",
    "export_energiedoku_coordinates_csv",
    "load_coordinates_from_csv",
    "shell_word_count",
    "shells_at_level",
    "theorematic_epsilon_for_level",
]
