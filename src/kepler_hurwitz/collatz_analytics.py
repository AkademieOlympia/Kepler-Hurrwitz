"""
Collatz trajectory analytics — populärwissenschaftliche Perspektiven neben Lean V2.

Governance:
- Trajektorien und Stopping Times sind empirische/experimentelle Hilfsmittel `[B]`.
- Geometrischer Mittelwert sqrt(3)/2 ist eine Heuristik `[C]`, kein Satz.
- Terence Tao (2019) ist externe Literatur `[C]`, kein Projektbeweis.

Siehe docs/collatz_analytical_perspectives.md und docs/collatz_v2_evidence_chain.md.
"""

from __future__ import annotations

import math
from typing import Sequence

from kepler_hurwitz.diagnostics import collatz_step

__all__ = [
    "GEOMETRIC_MEAN_HEURISTIC",
    "collatz_step",
    "collatz_trajectory",
    "inverse_predecessors",
    "stopping_time",
]

# Heuristik: ungerade Schritte ~ (3n+1)/n, gerade ~ 1/2; gemischt oft als sqrt(3)/2 zitiert.
# NICHT als Beweis oder uniforme Schranke verwenden — nur `[C]`-Lesesprache.
GEOMETRIC_MEAN_HEURISTIC = math.sqrt(3) / 2


def collatz_trajectory(n: int, *, max_steps: int = 1_000_000) -> list[int]:
    """
    Collatz-Trajektorie von ``n`` bis Eintreffen in 1 (inklusive Start und Endpunkt).

    Parameters
    ----------
    n
        Startwert, muss >= 1 sein.
    max_steps
        Schritt-Obergrenze als Sicherheitsnetz (hypothetische Nicht-Termination).

    Notes
    -----
    Die oft zitierte Kollaps-Heuristik mit geometrischem Mittel ``sqrt(3)/2 ≈ 0.866``
    beschreibt im Mittel erwartete Multiplikationsfaktoren über Paritätswechsel — das ist
    **kein** formaler Abstiegsbeweis und steht getrennt von V2.7 ``Δ_net > 0`` (Lean `[C]`).
    """
    if n < 1:
        raise ValueError("n must be >= 1")
    if max_steps < 0:
        raise ValueError("max_steps must be >= 0")

    trajectory = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            return trajectory
        current = collatz_step(current)
        trajectory.append(current)

    raise ValueError(
        f"trajectory did not reach 1 within {max_steps} steps starting from n={n}"
    )


def stopping_time(n: int, *, max_steps: int = 1_000_000) -> int:
    """Anzahl Collatz-Schritte bis 1 — ``len(trajectory) - 1``."""
    return len(collatz_trajectory(n, max_steps=max_steps)) - 1


def inverse_predecessors(x: int) -> tuple[int, ...]:
    """
    Vorgänger von ``x`` im inversen Collatz-Baum (Wurzel 1).

    Jeder Knoten hat mindestens den Vorgänger ``2*x``. Zusätzlich, wenn ``x ≡ 4 (mod 6)``,
    ist ``(x - 1) // 3`` ein ungerader Vorgänger mit ``collatz_step((x-1)//3) == x``.
    """
    if x < 1:
        raise ValueError("x must be >= 1")

    preds: list[int] = [2 * x]
    if x % 6 == 4:
        pred = (x - 1) // 3
        if pred >= 1 and pred % 2 == 1:
            preds.append(pred)
    return tuple(preds)


def batch_stopping_times(
    values: Sequence[int], *, max_steps: int = 1_000_000
) -> list[tuple[int, int]]:
    """Paare ``(n, stopping_time(n))`` für eine Folge natürlicher Startwerte."""
    return [(n, stopping_time(n, max_steps=max_steps)) for n in values]
