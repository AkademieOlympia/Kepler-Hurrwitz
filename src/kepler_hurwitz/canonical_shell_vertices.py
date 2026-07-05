"""
Kanonische ShellVertex-Enumeration und R³-Einbettung (E-077/E-078 Vorlaeufe).

Governance
----------
Quelle: ``canonical_from_qec_bridge`` — **Approximation**, kein Lean-Satz.

``ShellVertex(n)`` ist hier operational definiert als das Praefix der Laenge ``n+1``
aus einer fixierten, reproduzierbaren Liste dyadischer Norm-2-Wurzeln (Hurwitz-
Oktonion-Sphaere), gruppiert nach eindeutiger ``build_shell_projection_bundle``-
Imaginaerteil-R³-Koordinate. Der Ursprung ``(0,0,0)`` wird als degeneriert
ausgeschlossen.

Kompatibilitaet: ``iota_{n+1}`` beschraenkt sich auf die ersten ``n+1`` Vertices
derselben Liste — gleiche R³-Koordinaten fuer gemeinsame Indizes.

Abweichung von Energiedoku §8: dort existieren theorematische Einbettungen fuer
``n in {1,2,3}`` mit ``epsilon_n in {1, phi^{-2}, phi^{-3}}``; diese Pipeline
verwendet stattdessen ``provisional_inverse_n = 1/n`` und die qec_bridge-Projektion.

Siehe ``docs/reports/shell_separation_diagnostics_protocol.md`` Abschnitt
"Canonical run v1".
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from typing import TYPE_CHECKING

from kepler_hurwitz.metacommutation import enumerate_dyadic_norm2_integer_roots
from kepler_hurwitz.qec_bridge import build_shell_projection_bundle, classify_dyadic_roots

if TYPE_CHECKING:
    from kepler_hurwitz.discrete_time_flow import Octonion
    from kepler_hurwitz.shell_separation_diagnostics import Point

CANONICAL_SOURCE_LABEL = "canonical_from_qec_bridge"
"""Transparenzlabel fuer Exporte und Protokoll."""

CANONICAL_EMBEDDING_METHOD = "hurwitz_projected_imaginary_xyz"
"""
R³-Koordinaten: ``(projected[1], projected[2], projected[3])`` aus
``build_shell_projection_bundle`` (Hurwitz-Lattice-Projektion).
"""

CANONICAL_COMPATIBILITY_NOTE = (
    "iota_{n+1} uses prefix of length n+1 of fixed vertex list; "
    "shared indices retain identical R³ coordinates."
)

CANONICAL_APPROXIMATION_NOTE = (
    "ShellVertex(n) is operationally defined from dyadic norm-2 root parity "
    "classes via qec_bridge Hurwitz projection — not the formal Energiedoku "
    "ShellVertex type. No global all-n theorem; max level bounded by unique "
    "non-degenerate R³ representatives."
)


@dataclass(frozen=True)
class CanonicalShellVertex:
    """Ein Shell-Vertex mit fixierter R³-Einbettung."""

    vertex_index: int
    class_id: int
    parity_mask: int
    root: Octonion
    embedding_r3: Point
    residue_norm_sq: float


def _round_r3(point: Point, *, digits: int = 6) -> Point:
    return tuple(round(c, digits) for c in point)


def _embed_imaginary_xyz(root: Octonion) -> Point:
    bundle = build_shell_projection_bundle(root)
    projected = bundle.projected
    return _round_r3((projected[1], projected[2], projected[3]))


def _residue_norm_sq(root: Octonion) -> float:
    from kepler_hurwitz.discrete_time_flow import octonion_norm_sq

    bundle = build_shell_projection_bundle(root)
    return octonion_norm_sq(bundle.residue)


@lru_cache(maxsize=1)
def enumerate_canonical_shell_vertices() -> tuple[CanonicalShellVertex, ...]:
    """
    Fixierte, reproduzierbare ShellVertex-Liste (ein Repraesentant pro eindeutiger
    R³-Imaginaerteil-Koordinate, ohne Ursprung).
    """
    roots = enumerate_dyadic_norm2_integer_roots()
    classes = classify_dyadic_roots(roots)
    seen_r3: set[Point] = set()
    vertices: list[CanonicalShellVertex] = []

    for cls in classes:
        root = roots[cls.class_id]
        embedding = _embed_imaginary_xyz(root)
        if embedding == (0.0, 0.0, 0.0):
            continue
        if embedding in seen_r3:
            continue
        seen_r3.add(embedding)
        vertices.append(
            CanonicalShellVertex(
                vertex_index=len(vertices),
                class_id=cls.class_id,
                parity_mask=cls.parity_mask,
                root=root,
                embedding_r3=embedding,
                residue_norm_sq=_residue_norm_sq(root),
            )
        )

    return tuple(vertices)


def max_renorm_level() -> int:
    """Groesstes ``n`` mit ``|ShellVertex(n)| = n+1 >= 2`` unter der Praefix-Regel."""
    count = len(enumerate_canonical_shell_vertices())
    if count < 2:
        return 0
    return count - 1


def shell_vertex_count(n: int) -> int:
    """Anzahl Vertices auf Renorm-Stufe ``n`` (operational: ``n+1``)."""
    if n < 1:
        raise ValueError("n must be >= 1.")
    return n + 1


def shells_at_level(n: int) -> dict[int, list[Point]]:
    """
    ``shell_index -> [centroid]`` auf Stufe ``n``.

    Wirft ``NotImplementedError`` wenn ``n`` die implementierte Obergrenze ueberschreitet.
    """
    if n < 1:
        raise ValueError("n must be >= 1.")
    vertices = enumerate_canonical_shell_vertices()
    needed = shell_vertex_count(n)
    if needed > len(vertices):
        raise NotImplementedError(
            f"Canonical shell construction supports n in [1, {max_renorm_level()}]; "
            f"got n={n} requiring {needed} vertices but only {len(vertices)} available. "
            f"Source: {CANONICAL_SOURCE_LABEL}. "
            f"{CANONICAL_APPROXIMATION_NOTE}"
        )
    if needed < 2:
        raise NotImplementedError(
            f"Level n={n} yields fewer than two shells after degeneracy filtering."
        )

    selected = vertices[:needed]
    # Radii proxy: residue norm (diagnostic only)
    return {
        v.vertex_index: [v.embedding_r3]
        for v in selected
    }


def shell_radii_at_level(n: int) -> tuple[float, ...]:
    """Schalenradien-Proxy aus Residuum-Norm (diagnostisch)."""
    vertices = enumerate_canonical_shell_vertices()
    needed = shell_vertex_count(n)
    if needed > len(vertices):
        raise NotImplementedError(
            f"Canonical shell construction supports n in [1, {max_renorm_level()}]; got n={n}."
        )
    return tuple(max(0.1, min(0.5, v.residue_norm_sq**0.5)) for v in vertices[:needed])


__all__ = [
    "CANONICAL_APPROXIMATION_NOTE",
    "CANONICAL_COMPATIBILITY_NOTE",
    "CANONICAL_EMBEDDING_METHOD",
    "CANONICAL_SOURCE_LABEL",
    "CanonicalShellVertex",
    "enumerate_canonical_shell_vertices",
    "max_renorm_level",
    "shell_radii_at_level",
    "shell_vertex_count",
    "shells_at_level",
]
