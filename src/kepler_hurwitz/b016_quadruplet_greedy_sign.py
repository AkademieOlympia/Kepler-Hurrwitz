"""
B-016 — lokale Greedy-Entscheidungsfunktion d(v) auf Primzahlvierlingen.

AP-1 / Null-Noise-Labor: vollkommen lokal, objektiv, ohne sekundäre
Kalibrierungsparameter (nur: nächste Primzahl einer Restklassenfarbe
im Abstandssinn min_t∈T |r−t|).

Farbmap (kanonisch): 1→E, 5→A, 7→B, 11→C.

Vierling Q(p)=(p, p+2, p+6, p+8):
  - lead p≡5  (mod 12) → Farbwort ABCE
  - lead p≡11 (mod 12) → Farbwort CEAB
  (Hinweis: p≡11 (mod 30) liefert beide Wörter im Wechsel mod 12.)

Entscheidungsregel (Kernschritt / Phasenanker):
  Für Anker-Zwilling T und Kandidatenfarben vergleicht Greedy
  den minimalen Abstand zu einer *Erstfarbe* (noch nicht in T)
  mit dem zu einer *Selbfarbe* (bereits in T). Dann:

    d = +1  Erstergänzung  (min dist first < min dist self)
    d = -1  Selbsterweiterung
    d =  0  Gleichstand / kein Treffer im Suchraum

Governance: algorithmischer Score auf V — keine arithmetische
Vierlings-Invariante (G-007/G-008). K_{B1,B2}/E-101 orthogonal.
"""

from __future__ import annotations

import bisect
from typing import Iterable, Literal, Sequence

__all__ = [
    "eabc_color",
    "quad_color_word",
    "classify_population",
    "nearest_color_hit",
    "greedy_sign_for_anchor",
    "greedy_signs_on_quad",
]

Color = Literal["E", "A", "B", "C"]
Sign = Literal[-1, 0, 1]


def eabc_color(p: int) -> Color | None:
    """κ(p) for p>3; None outside U(12)-units."""
    return {1: "E", 5: "A", 7: "B", 11: "C"}.get(p % 12)  # type: ignore[return-value]


def quad_color_word(q: Sequence[int]) -> str:
    cols = [eabc_color(x) for x in q]
    if any(c is None for c in cols):
        raise ValueError(f"non-EABC prime in quadruplet {q}")
    return "".join(cols)  # type: ignore[arg-type]


def classify_population(p: int) -> Literal["ABCE", "CEAB", "other"]:
    """
    Population by lead class of Q(p).

    Correct congruence (do **not** invert):
      p ≡ 5  (mod 12) → ABCE
      p ≡ 11 (mod 12) → CEAB
    """
    r = p % 12
    if r == 5:
        return "ABCE"
    if r == 11:
        return "CEAB"
    if p == 5:
        return "ABCE"  # Q(5)=(5,7,11,13)
    return "other"


def nearest_color_hit(
    T: Sequence[int],
    X: Color,
    primes_by_color: dict[str, list[int]],
    exclude: set[int],
    *,
    window: int = 80,
) -> tuple[int, int] | None:
    """
    Nearest prime r of color X to the set T, measured as
    d(r,T)=min_{t∈T}|r−t|, excluding ``exclude`` and members of T.

    Returns (distance, r) or None.
    """
    cl = primes_by_color[X]
    best: tuple[int, int] | None = None
    for t in T:
        i = bisect.bisect_left(cl, t)
        for j in range(max(0, i - window), min(len(cl), i + window + 1)):
            r = cl[j]
            if r in exclude or r in T:
                continue
            d = min(abs(r - x) for x in T)
            if best is None or (d, r) < (best[0], best[1]):
                best = (d, r)
    return best


def greedy_sign_for_anchor(
    T: tuple[int, int],
    first_colors: tuple[Color, Color],
    self_colors: tuple[Color, Color],
    primes_by_color: dict[str, list[int]],
    exclude: set[int],
    *,
    window: int = 80,
) -> Sign:
    """
    Lokale Entscheidungsfunktion am Phasenanker T.

    Äquivalent zum Distanzvergleich in ``eabc_greedy_distance.greedy_sign_from_sectors``:
    Erstergänzung (+1) / Selbsterweiterung (−1) / Neutralität (0).
    """
    # Lazy import avoids circular init; both modules share nearest_color_hit.
    from kepler_hurwitz.eabc_greedy_distance import greedy_sign_from_sectors

    return greedy_sign_from_sectors(  # type: ignore[return-value]
        T, first_colors, self_colors, primes_by_color, exclude, window=window
    )


def greedy_signs_on_quad(
    q: tuple[int, int, int, int],
    primes_by_color: dict[str, list[int]],
    *,
    mode: Literal["OUT", "IN"] = "OUT",
    window: int = 80,
) -> dict[str, int | float | str]:
    """
    d_ce, d_ab und d_quad=(d_ce+d_ab)/2 für einen Vierling.

    Phase CE-Anker: Erstfarben A,B / Selbfarben C,E
    Phase AB-Anker: Erstfarben C,E / Selbfarben A,B
    """
    cols = [eabc_color(x) for x in q]
    if any(c is None for c in cols):
        raise ValueError(q)
    by_col = {c: x for c, x in zip(cols, q)}
    ce_T = (by_col["C"], by_col["E"])
    ab_T = (by_col["A"], by_col["B"])
    Qset = set(q)
    if mode == "OUT":
        ex_ce = Qset - set(ce_T)
        ex_ab = Qset - set(ab_T)
    else:
        ex_ce, ex_ab = set(), set()
    d_ce = greedy_sign_for_anchor(
        ce_T, ("A", "B"), ("C", "E"), primes_by_color, ex_ce, window=window
    )
    d_ab = greedy_sign_for_anchor(
        ab_T, ("C", "E"), ("A", "B"), primes_by_color, ex_ab, window=window
    )
    return {
        "p": q[0],
        "word": "".join(cols),  # type: ignore[arg-type]
        "population": classify_population(q[0]),
        "mode": mode,
        "d_ce": d_ce,
        "d_ab": d_ab,
        "d_quad": (d_ce + d_ab) / 2.0,
    }


def build_color_index(primes: Iterable[int]) -> dict[str, list[int]]:
    by: dict[str, list[int]] = {c: [] for c in "EABC"}
    for p in primes:
        c = eabc_color(p)
        if c is not None:
            by[c].append(p)
    return by
