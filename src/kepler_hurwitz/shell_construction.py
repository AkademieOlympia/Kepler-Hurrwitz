"""
Kanonische Schalenkonstruktion — Schnittstelle fuer E-077/E-078 [B]-Vorbereitung.

Governance
----------
Dieses Modul definiert die **fixierte Konvention** fuer Metrik und ``epsilon_n``-
Regel sowie explizite Konstruktions-Implementierungen (Toy, Synthetic, Canonical).

``CanonicalShellConstruction`` ist ein Scaffold: echte ``ShellVertex(n) -> R^3``-
Einbettung (``iota_n``) fehlt im Repo noch — siehe
``docs/reports/shell_separation_diagnostics_protocol.md`` Abschnitt
"Canonical construction gate for [B]".

Siehe ``docs/energiedoku_exports/eabc_renormalisierungsprogramm.md`` §8–9
(fuer die theoretische Spezifikation von ``iota_n``).
"""

from __future__ import annotations

import math
from collections.abc import Callable, Iterable, Mapping, Sequence
from dataclasses import dataclass
from typing import Any, Protocol, runtime_checkable

from kepler_hurwitz.shell_separation_diagnostics import (
    Point,
    build_synthetic_shell_series,
    build_toy_shell_series_n_le_3,
    shell_sep,
)

# ---------------------------------------------------------------------------
# Fixierte Konvention (provisional canonical rule — upgrade path to formal [B])
# ---------------------------------------------------------------------------

CANONICAL_METRIC_NAME = "euclidean_l2_r3"
"""Euklidische L2-Metrik auf R^3 (Centroid-Separation zwischen Schalen)."""

CANONICAL_EPSILON_RULE_NAME = "provisional_inverse_n"
"""Provisorische Schwelle ``epsilon_n = 1/n`` — explizit als Konvention markiert."""

THEOREMATIC_EPSILON_RULE_NAME = "theorematic_energiedoku_v1"
"""Energiedoku §8: ``epsilon_n in {1, phi^{-2}, phi^{-3}}`` fuer ``n in {1,2,3}``."""

THEOREMATIC_MN_SEP_EPSILON_RULE_NAME = "theorematic_mn_sep_v1"
"""``[C]`` Schwelle ``epsilon_n = 1 / M_n^sep = 4^{-n}`` (Energiedoku §7 ``M_n^sep = 4^n``)."""

CANONICAL_EPSILON_UPGRADE_NOTE = (
    "Upgrade to formal [B]: replace provisional_inverse_n with a theorem-backed "
    "threshold derived from M_n^sep = 4^n and the fixed shell metric."
)

# phi = (1 + sqrt(5)) / 2  (golden ratio)
PHI: float = (1.0 + math.sqrt(5.0)) / 2.0
PHI_INV_SQ: float = PHI ** -2  # phi^{-2} = (3 - sqrt(5)) / 2 ≈ 0.381966011250105
PHI_INV_CUBE: float = PHI ** -3  # phi^{-3} ≈ 0.236067977499790

THEOREMATIC_EPSILON_N_GT_3_MESSAGE = (
    "[C] theorematic_energiedoku_v1: Energiedoku §8 documents ε_n only for n∈{1,2,3}; "
    "no theorem-backed extension from M_n^sep=4^n is implemented in this repo."
)

THEOREMATIC_MN_SEP_EPSILON_MESSAGE = (
    "[C] theorematic_mn_sep_v1: Energiedoku §7 defines M_n^sep = 4^n; §8 gives explicit "
    "ε_n only for n∈{1,2,3} as {1, φ⁻², φ⁻³} — no theorem maps ε_n to 1/M_n^sep. "
    "Operational convention: ε_n = 4^{-n} = 1/M_n^sep (inverse separation scale)."
)

EPSILON_RULE_NAMES = frozenset(
    {
        CANONICAL_EPSILON_RULE_NAME,
        THEOREMATIC_EPSILON_RULE_NAME,
        THEOREMATIC_MN_SEP_EPSILON_RULE_NAME,
    }
)


def provisional_epsilon_n(n: int) -> float:
    """Provisorische kanonische Schwelle ``epsilon_n = 1/n``."""
    if n < 1:
        raise ValueError("n must be >= 1 for epsilon rule.")
    return 1.0 / n


def theorematic_epsilon_n(n: int, *, allow_n_gt_3_fallback: bool = True) -> float:
    """
    Energiedoku §8 theorematische Schwellen (``docs/energiedoku_exports/
    eabc_renormalisierungsprogramm.md`` §8).

    - ``n=1``: ``epsilon_1 = 1``
    - ``n=2``: ``epsilon_2 = phi^{-2}`` ≈ 0.381966011250105
    - ``n=3``: ``epsilon_3 = phi^{-3}`` ≈ 0.236067977499790

    For ``n > 3``: Energiedoku gives no per-level threshold. With
    ``allow_n_gt_3_fallback=True`` (default for diagnostic runs), returns
    ``phi^{-3}`` as an explicit ``[C]`` placeholder — **not** a silent ``1/n``.
    With ``allow_n_gt_3_fallback=False``, raises ``NotImplementedError``.
    """
    if n < 1:
        raise ValueError("n must be >= 1 for epsilon rule.")
    if n == 1:
        return 1.0
    if n == 2:
        return PHI_INV_SQ
    if n == 3:
        return PHI_INV_CUBE
    if not allow_n_gt_3_fallback:
        raise NotImplementedError(THEOREMATIC_EPSILON_N_GT_3_MESSAGE)
    return PHI_INV_CUBE


def theorematic_mn_sep_epsilon_n(n: int) -> float:
    """
    ``[C]`` M_n^sep-basierte Schwelle (``docs/energiedoku_exports/
    eabc_renormalisierungsprogramm.md`` §7, §8).

    Energiedoku §7: ``M_n^sep = 4^n`` (separierte Ueberdeckungszahl).
    Energiedoku §8: explizite ``epsilon_n`` nur fuer ``n in {1,2,3}`` als
    ``{1, phi^{-2}, phi^{-3}}`` — **kein** Satz ``epsilon_n = 1/M_n^sep``.

    Operational convention (diagnostic extension for all ``n``):

    ``epsilon_n = 1 / M_n^sep = 4^{-n}``
    """
    if n < 1:
        raise ValueError("n must be >= 1 for epsilon rule.")
    return 4.0 ** (-n)


def get_epsilon_rule(
    name: str,
) -> tuple[Callable[[int], float], str]:
    """Resolve ``(epsilon_fn, epsilon_rule_name)`` from a rule label."""
    key = name.lower()
    if key == CANONICAL_EPSILON_RULE_NAME:
        return provisional_epsilon_n, CANONICAL_EPSILON_RULE_NAME
    if key == THEOREMATIC_EPSILON_RULE_NAME:
        return theorematic_epsilon_n, THEOREMATIC_EPSILON_RULE_NAME
    if key == THEOREMATIC_MN_SEP_EPSILON_RULE_NAME:
        return theorematic_mn_sep_epsilon_n, THEOREMATIC_MN_SEP_EPSILON_RULE_NAME
    raise ValueError(
        f"Unknown epsilon rule {name!r}; expected one of: "
        f"{', '.join(sorted(EPSILON_RULE_NAMES))}."
    )


CANONICAL_NOT_IMPLEMENTED_MESSAGE = (
    "CanonicalShellConstruction level out of range or degenerate. "
    "Implemented range: n in [1, max_renorm_level()] via "
    "canonical_from_qec_bridge (see canonical_shell_vertices.py). "
    "Theory spec: docs/energiedoku_exports/eabc_renormalisierungsprogramm.md "
    "§8–9; gate checklist: "
    "docs/reports/shell_separation_diagnostics_protocol.md "
    '"Canonical run v1". '
    "E-077–E-079 remain [C]: operational qec_bridge approximation, not formal [B]."
)


@runtime_checkable
class ShellConstructionProtocol(Protocol):
    """Schnittstelle fuer Schalenkonstruktionen auf Renorm-Stufe ``n``."""

    def shells_at(self, n: int) -> dict[int, list[Point]]:
        """Mappt ``shell_index -> Punktmenge`` auf Stufe ``n``."""
        ...

    def metric_name(self) -> str:
        """Name der fixierten Separationsmetrik."""
        ...

    def epsilon_rule(self, n: int) -> float:
        """Schwellenwert ``epsilon_n`` auf Stufe ``n``."""
        ...

    def epsilon_rule_name(self) -> str:
        """Name der fixierten ``epsilon_n``-Regel."""
        ...

    def construction_name(self) -> str:
        """Kurzlabel fuer Exporte und Protokoll."""
        ...


def _centroids_to_shells(centroids: Sequence[Point]) -> dict[int, list[Point]]:
    return {i: [cent] for i, cent in enumerate(centroids)}


def _entry_to_shells(entry: Mapping[str, Any]) -> dict[int, list[Point]]:
    centroids = entry.get("centroids")
    if centroids is None:
        raise ValueError("Shell series entry missing 'centroids'.")
    return _centroids_to_shells(centroids)


@dataclass(frozen=True)
class ToyShellConstruction:
    """
    Explizit gelabelte Toy-Schalen fuer ``n in {1, 2, 3}`` — **kein** globaler
    ``R^3``-Einbettungsclaim (E-078-Vorlaeufer, Regressionstest-Schicht).
    """

    dim: int = 3

    def shells_at(self, n: int) -> dict[int, list[Point]]:
        series = build_toy_shell_series_n_le_3(dim=self.dim)
        if n not in series:
            raise KeyError(
                f"ToyShellConstruction supports n in {{1,2,3}} only; got n={n}."
            )
        return _entry_to_shells(series[n])

    def metric_name(self) -> str:
        return CANONICAL_METRIC_NAME

    def epsilon_rule(self, n: int) -> float:
        return provisional_epsilon_n(n)

    def epsilon_rule_name(self) -> str:
        return CANONICAL_EPSILON_RULE_NAME

    def construction_name(self) -> str:
        return "toy_n_le_3"


@dataclass(frozen=True)
class SyntheticShellConstruction:
    """
    Synthetische Schalenreihe mit kontrolliertem Separationsverfall —
    Pipeline-Test-Schicht, **kein** Beweis von MetricSeparationLossExists.
    """

    dim: int = 3
    n_max: int = 5
    first_loss_level: int = 4
    base_separation: float = 2.0

    def shells_at(self, n: int) -> dict[int, list[Point]]:
        if n < 1 or n > self.n_max:
            raise KeyError(
                f"SyntheticShellConstruction supports n in [1, {self.n_max}]; got n={n}."
            )
        series = build_synthetic_shell_series(
            dim=self.dim,
            n_max=self.n_max,
            first_loss_level=self.first_loss_level,
            base_separation=self.base_separation,
        )
        return _entry_to_shells(series[n])

    def metric_name(self) -> str:
        return CANONICAL_METRIC_NAME

    def epsilon_rule(self, n: int) -> float:
        return provisional_epsilon_n(n)

    def epsilon_rule_name(self) -> str:
        return CANONICAL_EPSILON_RULE_NAME

    def construction_name(self) -> str:
        return "synthetic"


@dataclass(frozen=True)
class CombinedShellConstruction:
    """
    Toy (n<=3) plus Synthetic (n=1..n_max).

    Bei ueberlappenden Stufen gewinnt Synthetic — entspricht dem bisherigen
    ``_merge_series(toy, synthetic)``-Default.
    """

    toy: ToyShellConstruction
    synthetic: SyntheticShellConstruction

    def _merged_series(self) -> dict[int, dict[str, Any]]:
        toy_series = build_toy_shell_series_n_le_3(dim=self.toy.dim)
        syn_series = build_synthetic_shell_series(
            dim=self.synthetic.dim,
            n_max=self.synthetic.n_max,
            first_loss_level=self.synthetic.first_loss_level,
            base_separation=self.synthetic.base_separation,
        )
        merged = dict(toy_series)
        merged.update(syn_series)
        return merged

    def shells_at(self, n: int) -> dict[int, list[Point]]:
        series = self._merged_series()
        if n not in series:
            raise KeyError(
                f"CombinedShellConstruction supports n in [1, {self.synthetic.n_max}]; got n={n}."
            )
        return _entry_to_shells(series[n])

    def metric_name(self) -> str:
        return CANONICAL_METRIC_NAME

    def epsilon_rule(self, n: int) -> float:
        return provisional_epsilon_n(n)

    def epsilon_rule_name(self) -> str:
        return CANONICAL_EPSILON_RULE_NAME

    def construction_name(self) -> str:
        return "combined"

    @property
    def n_levels(self) -> tuple[int, ...]:
        return tuple(range(1, self.synthetic.n_max + 1))


@dataclass(frozen=True)
class CanonicalShellConstruction:
    """
    Operationale ``ShellVertex(n) -> R^3``-Einbettung via qec_bridge.

    Quelle: ``canonical_from_qec_bridge`` (siehe ``canonical_shell_vertices``).
    Kein Lean-Satz, kein globaler all-``n``-Claim — Stufen ausserhalb
    ``[1, max_renorm_level()]`` werfen ``NotImplementedError``.
    """

    n_max: int | None = None
    """Optionale Obergrenze; Default = ``max_renorm_level()``."""

    def _resolved_n_max(self) -> int:
        from kepler_hurwitz.canonical_shell_vertices import max_renorm_level

        cap = max_renorm_level()
        if self.n_max is None:
            return cap
        return min(self.n_max, cap)

    def shells_at(self, n: int) -> dict[int, list[Point]]:
        from kepler_hurwitz.canonical_shell_vertices import shells_at_level

        if n < 1 or n > self._resolved_n_max():
            raise NotImplementedError(CANONICAL_NOT_IMPLEMENTED_MESSAGE)
        return shells_at_level(n)

    def metric_name(self) -> str:
        return CANONICAL_METRIC_NAME

    def epsilon_rule(self, n: int) -> float:
        return provisional_epsilon_n(n)

    def epsilon_rule_name(self) -> str:
        return CANONICAL_EPSILON_RULE_NAME

    def construction_name(self) -> str:
        from kepler_hurwitz.canonical_shell_vertices import CANONICAL_SOURCE_LABEL

        return CANONICAL_SOURCE_LABEL


def get_construction(
    name: str,
    *,
    dim: int = 3,
    n_max: int = 5,
    first_loss_level: int = 4,
) -> ShellConstructionProtocol:
    """Factory fuer benannte Konstruktionsschichten."""
    key = name.lower()
    if key == "toy":
        return ToyShellConstruction(dim=dim)
    if key == "synthetic":
        return SyntheticShellConstruction(
            dim=dim,
            n_max=n_max,
            first_loss_level=first_loss_level,
        )
    if key == "combined":
        return CombinedShellConstruction(
            toy=ToyShellConstruction(dim=dim),
            synthetic=SyntheticShellConstruction(
                dim=dim,
                n_max=n_max,
                first_loss_level=first_loss_level,
            ),
        )
    if key == "canonical":
        return CanonicalShellConstruction(n_max=n_max if n_max > 0 else None)
    raise ValueError(
        f"Unknown construction {name!r}; expected toy, synthetic, combined, or canonical."
    )


def shell_series_from_construction(
    construction: ShellConstructionProtocol,
    n_levels: Iterable[int],
) -> dict[int, dict[str, Any]]:
    """
    Konvertiert eine Konstruktion in das ``shell_series``-Format fuer
    ``run_shell_separation_diagnostics``.
    """
    from kepler_hurwitz.canonical_shell_vertices import (
        CANONICAL_SOURCE_LABEL,
        shell_radii_at_level,
    )

    series: dict[int, dict[str, Any]] = {}
    for n in sorted(set(n_levels)):
        shells = construction.shells_at(n)
        centroids = tuple(shells[i][0] for i in sorted(shells))
        sep_n = shell_sep({i: (c,) for i, c in enumerate(centroids)})
        entry: dict[str, Any] = {
            "centroids": centroids,
            "radii": tuple(0.4 for _ in centroids),
            "sep": sep_n,
            "construction": construction.construction_name(),
            "metric_name": construction.metric_name(),
            "epsilon_rule_name": construction.epsilon_rule_name(),
        }
        if construction.construction_name() == CANONICAL_SOURCE_LABEL:
            try:
                entry["radii"] = shell_radii_at_level(n)
            except NotImplementedError:
                pass
            entry["construction_source"] = CANONICAL_SOURCE_LABEL
        series[n] = entry
    return series


__all__ = [
    "CANONICAL_EPSILON_RULE_NAME",
    "CANONICAL_EPSILON_UPGRADE_NOTE",
    "CANONICAL_METRIC_NAME",
    "CANONICAL_NOT_IMPLEMENTED_MESSAGE",
    "EPSILON_RULE_NAMES",
    "PHI",
    "PHI_INV_CUBE",
    "PHI_INV_SQ",
    "THEOREMATIC_EPSILON_N_GT_3_MESSAGE",
    "THEOREMATIC_EPSILON_RULE_NAME",
    "THEOREMATIC_MN_SEP_EPSILON_MESSAGE",
    "THEOREMATIC_MN_SEP_EPSILON_RULE_NAME",
    "CanonicalShellConstruction",
    "CombinedShellConstruction",
    "ShellConstructionProtocol",
    "SyntheticShellConstruction",
    "ToyShellConstruction",
    "get_construction",
    "get_epsilon_rule",
    "provisional_epsilon_n",
    "shell_series_from_construction",
    "theorematic_epsilon_n",
    "theorematic_mn_sep_epsilon_n",
]
