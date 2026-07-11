"""
Unified interpretive bridge ι_n between Track A (qec_bridge) and Track B (energiedoku).

Governance
----------
Path B2 — **exploratory only**. Documents partial / interpretive correspondence rules
for ``n in {1,2,3}``; does **not** activate ``SHELL_PRIME_MATCH_GATE_ACTIVE``.

Status labels:
- ``[A]`` — algorithmically checkable (prefix restriction, uniform transform).
- ``[C]`` — diagnostic convention / measurement layer.
- ``[H]`` — heuristic interpretive correspondence (axis label, word guess).

No global prefix↔word bijection is claimed. See ``shell_prefix_word_map.BIJECTION_STATUS``.
"""

from __future__ import annotations

import csv
import math
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Callable, Literal

from kepler_hurwitz.canonical_shell_vertices import (
    CANONICAL_SOURCE_LABEL,
    enumerate_canonical_shell_vertices,
    shell_vertex_count,
    shells_at_level as canonical_shells_at_level,
)
from kepler_hurwitz.energiedoku_shell_construction import (
    ENERGIEDOKU_SOURCE_LABEL,
    EClass,
    embed_shell_word,
    shells_at_level as energiedoku_shells_at_level,
)
from kepler_hurwitz.shell_prefix_word_map import (
    BIJECTION_STATUS,
    axis_label_from_coordinate,
    axis_label_from_coordinate_signed,
)
from kepler_hurwitz.shell_separation_diagnostics import (
    Point,
    SHELL_PRIME_MATCH_GATE_ACTIVE,
    shell_sep,
)

ProofStatus = Literal["A", "C", "H"]

UNIFIED_BRIDGE_STATUS = "partial_interpretive_no_global_bijection"
UNIFIED_BRIDGE_GATE_ELIGIBLE = False
"""
Path B2 bridge remains **not gate-eligible** while Track A is primary and no
documented bijection on the primary track exists.
"""

COORDINATE_TRANSFORM_NOTE = (
    "Uniform sign flip on y and z: canonical qec_bridge Hurwitz projection often "
    "negates y/z vs Lean cardinalDir; transform (x,y,z) -> (x,-y,-z) aligns axis "
    "dominance with EABC cardinal axes at n=1."
)


def default_coordinate_transform(point: Point) -> Point:
    """Documented optional transform: flip y and z signs."""
    x, y, z = point
    return (x, -y, -z)


# Explicit interpretive axis-label rules for n=1,2,3 (prefix_index -> EABC letter).
# Values: (letter, proof_status). idx rules derived from sign-corrected axis dominance [C/H].
DOCUMENTED_AXIS_LABEL_RULES: dict[int, dict[int, tuple[str, ProofStatus]]] = {
    1: {0: ("C", "C"), 1: ("A", "C")},
    2: {0: ("C", "C"), 1: ("A", "C"), 2: ("B", "C")},
    3: {0: ("C", "C"), 1: ("A", "C"), 2: ("B", "C"), 3: ("B", "H")},
}


class BridgeRule(str, Enum):
    """Documented bridge rule components."""

    AXIS_LABEL_MAP = "axis_label_map"
    COORDINATE_TRANSFORM = "coordinate_transform"
    PREFIX_COMPATIBILITY = "prefix_compatibility"
    BRIDGED_SEP = "bridged_sep"


@dataclass(frozen=True)
class UnifiedEmbeddingBridge:
    """
    Documented partial bridge ι_n for ``n <= 3``.

    ``axis_label_map`` — interpretive prefix index → EABC letter (not a bijection).
    ``coordinate_transform`` — optional uniform sign correction (documented flips).
    ``restrict_to_n_le_3`` — hard cap matching theorematic energiedoku scope.
    """

    axis_label_map: dict[int, dict[int, tuple[str, ProofStatus]]]
    coordinate_transform: Callable[[Point], Point]
    restrict_to_n_le_3: bool = True
    bridge_status: str = UNIFIED_BRIDGE_STATUS
    coordinate_transform_note: str = COORDINATE_TRANSFORM_NOTE

    @classmethod
    def default(cls) -> UnifiedEmbeddingBridge:
        return cls(
            axis_label_map=dict(DOCUMENTED_AXIS_LABEL_RULES),
            coordinate_transform=default_coordinate_transform,
            restrict_to_n_le_3=True,
        )

    def _check_n(self, n: int) -> None:
        if n < 1:
            raise ValueError("n must be >= 1.")
        if self.restrict_to_n_le_3 and n > 3:
            raise ValueError("UnifiedEmbeddingBridge restricted to n <= 3.")

    def canonical_prefix_point(self, n: int, prefix_index: int) -> Point:
        """Raw Track A coordinate for ``prefix_index`` at level ``n``."""
        self._check_n(n)
        if prefix_index < 0 or prefix_index >= shell_vertex_count(n):
            raise IndexError(
                f"prefix_index={prefix_index} out of range for n={n} "
                f"(count={shell_vertex_count(n)})."
            )
        vertices = enumerate_canonical_shell_vertices()
        return vertices[prefix_index].embedding_r3

    def bridged_point(self, n: int, prefix_index: int) -> Point:
        """ι_n interpretive coordinate: transform applied to Track A prefix vertex."""
        raw = self.canonical_prefix_point(n, prefix_index)
        return self.coordinate_transform(raw)

    def axis_label(self, n: int, prefix_index: int) -> tuple[str, ProofStatus]:
        """Interpretive EABC letter for prefix index (documented map + fallback)."""
        self._check_n(n)
        if n in self.axis_label_map and prefix_index in self.axis_label_map[n]:
            return self.axis_label_map[n][prefix_index]
        bp = self.bridged_point(n, prefix_index)
        cls = axis_label_from_coordinate(bp)
        if cls is not None:
            return cls.value, "C"
        signed = axis_label_from_coordinate_signed(
            self.canonical_prefix_point(n, prefix_index)
        )
        if signed:
            letter = signed.replace("-", "").replace("E/C", "E")
            return letter[0] if letter else "?", "H"
        return "?", "H"

    def interpretive_word(self, n: int, prefix_index: int) -> tuple[str, ProofStatus]:
        """
        Repeat interpretive axis letter ``n`` times (diagnostic word guess).

        Not claimed injective; for comparison with lex / nearest maps only.
        """
        letter, status = self.axis_label(n, prefix_index)
        word = letter * n
        return word, status if status != "A" else "H"

    def energiedoku_point_from_word(self, word: str) -> Point | None:
        """Embed interpretive word when length in {1,2,3}."""
        if len(word) not in (1, 2, 3):
            return None
        try:
            shell_word = tuple(EClass(c) for c in word)
        except ValueError:
            return None
        return embed_shell_word(shell_word)

    def compatibility_check(
        self,
        n: int,
        n_plus_1: int | None = None,
        *,
        tol: float = 1e-9,
    ) -> CompatibilityResult:
        """
        Check ι_{n+1}|_{S_n} = ι_n on shared prefix indices ``0..n``.

        For Track A raw coordinates this is ``[A]`` (prefix list). Under uniform
        linear transform, compatibility is preserved ``[A]``. Energiedoku full words
        are **not** prefix-compatible — reported separately.
        """
        self._check_n(n)
        n1 = n_plus_1 if n_plus_1 is not None else n + 1
        if n1 != n + 1:
            raise ValueError("compatibility_check requires n_plus_1 == n + 1.")
        if self.restrict_to_n_le_3 and n1 > 3:
            return CompatibilityResult(
                n=n,
                n_plus_1=n1,
                shared_count=n + 1,
                bridged_compatible=True,
                raw_canonical_compatible=True,
                mismatched_indices=(),
                max_coord_delta=0.0,
                proof_status="C",
                notes="n+1 > 3 outside bridge scope; trivial prefix check skipped.",
            )

        mismatched: list[int] = []
        max_delta = 0.0
        for i in range(n + 1):
            p_n = self.bridged_point(n, i)
            p_n1 = self.bridged_point(n1, i)
            delta = _l2(p_n, p_n1)
            max_delta = max(max_delta, delta)
            if delta > tol:
                mismatched.append(i)

        raw_mismatched: list[int] = []
        for i in range(n + 1):
            r_n = self.canonical_prefix_point(n, i)
            r_n1 = self.canonical_prefix_point(n1, i)
            if _l2(r_n, r_n1) > tol:
                raw_mismatched.append(i)

        return CompatibilityResult(
            n=n,
            n_plus_1=n1,
            shared_count=n + 1,
            bridged_compatible=len(mismatched) == 0,
            raw_canonical_compatible=len(raw_mismatched) == 0,
            mismatched_indices=tuple(mismatched),
            max_coord_delta=max_delta,
            proof_status="A" if len(mismatched) == 0 else "C",
            notes=(
                "Uniform coordinate_transform preserves prefix compatibility [A]"
                if len(mismatched) == 0
                else f"Bridged mismatch at indices {mismatched}"
            ),
        )

    def bridge_sep(self, n: int) -> BridgeSepResult:
        """``sep(n)`` under bridged coordinates vs Track A and Track B diagnostic."""
        self._check_n(n)
        bridged_shells = {
            i: [self.bridged_point(n, i)] for i in range(shell_vertex_count(n))
        }
        sep_bridged = shell_sep(bridged_shells)
        sep_canonical = shell_sep(canonical_shells_at_level(n))
        sep_ed = shell_sep(energiedoku_shells_at_level(n, mode="diagnostic"))
        sep_ed_full = shell_sep(energiedoku_shells_at_level(n, mode="full"))

        return BridgeSepResult(
            n=n,
            sep_canonical=sep_canonical,
            sep_energiedoku_diagnostic=sep_ed,
            sep_energiedoku_full=sep_ed_full,
            sep_bridged=sep_bridged,
            sep_delta_bridged_vs_canonical=sep_bridged - sep_canonical,
            sep_delta_bridged_vs_energiedoku=sep_bridged - sep_ed,
            proof_status="C",
            notes=(
                f"bridged uses {self.coordinate_transform_note}; "
                "sep is diagnostic [C], not embedding proof."
            ),
        )


def _l2(a: Point, b: Point) -> float:
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b, strict=True)))


@dataclass(frozen=True)
class CompatibilityResult:
    n: int
    n_plus_1: int
    shared_count: int
    bridged_compatible: bool
    raw_canonical_compatible: bool
    mismatched_indices: tuple[int, ...]
    max_coord_delta: float
    proof_status: ProofStatus
    notes: str


@dataclass(frozen=True)
class BridgeSepResult:
    n: int
    sep_canonical: float
    sep_energiedoku_diagnostic: float
    sep_energiedoku_full: float
    sep_bridged: float
    sep_delta_bridged_vs_canonical: float
    sep_delta_bridged_vs_energiedoku: float
    proof_status: ProofStatus
    notes: str


@dataclass(frozen=True)
class UnifiedBridgeRow:
    n: int
    prefix_index: int
    canonical_x: float
    canonical_y: float
    canonical_z: float
    bridged_x: float
    bridged_y: float
    bridged_z: float
    axis_label: str
    axis_label_status: ProofStatus
    interpretive_word: str
    interpretive_word_status: ProofStatus
    energiedoku_interp_x: float
    energiedoku_interp_y: float
    energiedoku_interp_z: float
    energiedoku_interp_diff_l2: float
    sep_canonical: float
    sep_energiedoku_diagnostic: float
    sep_bridged: float
    bridged_compatible_n_nplus1: bool | None
    bridge_status: str
    gate_eligible: bool
    notes: str


@dataclass(frozen=True)
class UnifiedBridgeReport:
    rows: tuple[UnifiedBridgeRow, ...]
    compatibility_results: tuple[CompatibilityResult, ...]
    sep_results: tuple[BridgeSepResult, ...]
    bridge_status: str
    bijection_status: str
    gate_eligible: bool
    gate_active: bool
    recommendation: str


def build_bridge_rows(bridge: UnifiedEmbeddingBridge, n: int) -> tuple[UnifiedBridgeRow, ...]:
    bridge._check_n(n)
    sep_res = bridge.bridge_sep(n)
    compat: CompatibilityResult | None = None
    if n < 3:
        compat = bridge.compatibility_check(n)

    rows: list[UnifiedBridgeRow] = []
    for i in range(shell_vertex_count(n)):
        raw = bridge.canonical_prefix_point(n, i)
        bp = bridge.bridged_point(n, i)
        letter, lbl_status = bridge.axis_label(n, i)
        word, word_status = bridge.interpretive_word(n, i)
        ed_pt = bridge.energiedoku_point_from_word(word)
        if ed_pt is not None:
            ed_diff = _l2(bp, ed_pt)
            ex, ey, ez = ed_pt
        else:
            ed_diff = float("nan")
            ex = ey = ez = float("nan")

        notes: list[str] = []
        if ed_diff < 1e-9:
            notes.append("interpretive_word_exact")
        elif math.isfinite(ed_diff) and ed_diff < 0.05:
            notes.append("interpretive_word_near")
        elif math.isfinite(ed_diff):
            notes.append("interpretive_word_divergent")

        rows.append(
            UnifiedBridgeRow(
                n=n,
                prefix_index=i,
                canonical_x=raw[0],
                canonical_y=raw[1],
                canonical_z=raw[2],
                bridged_x=bp[0],
                bridged_y=bp[1],
                bridged_z=bp[2],
                axis_label=letter,
                axis_label_status=lbl_status,
                interpretive_word=word,
                interpretive_word_status=word_status,
                energiedoku_interp_x=ex,
                energiedoku_interp_y=ey,
                energiedoku_interp_z=ez,
                energiedoku_interp_diff_l2=ed_diff,
                sep_canonical=sep_res.sep_canonical,
                sep_energiedoku_diagnostic=sep_res.sep_energiedoku_diagnostic,
                sep_bridged=sep_res.sep_bridged,
                bridged_compatible_n_nplus1=(
                    compat.bridged_compatible if compat is not None else None
                ),
                bridge_status=bridge.bridge_status,
                gate_eligible=UNIFIED_BRIDGE_GATE_ELIGIBLE,
                notes="; ".join(notes) if notes else "bridge_row",
            )
        )
    return tuple(rows)


def run_unified_bridge_report(*, n_max: int = 3) -> UnifiedBridgeReport:
    """Full Path B2 report for ``n = 1 .. min(n_max, 3)``."""
    bridge = UnifiedEmbeddingBridge.default()
    cap = min(n_max, 3)
    all_rows: list[UnifiedBridgeRow] = []
    compat_results: list[CompatibilityResult] = []
    sep_results: list[BridgeSepResult] = []

    for n in range(1, cap + 1):
        all_rows.extend(build_bridge_rows(bridge, n))
        sep_results.append(bridge.bridge_sep(n))
        if n < cap:
            compat_results.append(bridge.compatibility_check(n))

    all_bridged_compat = all(c.bridged_compatible for c in compat_results)
    rec = (
        "Path B2 unified ι_n is partial/interpretive only: axis_label_map + sign-corrected "
        "coordinates align Track A prefix with EABC cardinal axes at n=1 [C]; "
        f"prefix compatibility ι_{{n+1}}|_{{S_n}}=ι_n holds on bridged coords [A] "
        f"({'verified' if all_bridged_compat else 'check failures'}). "
        "No global bijection; gate remains INACTIVE on primary track. "
        "Track B stays separate theorematic reference unless B1 pre-reg switch or "
        "full bijection on primary track is proven."
    )

    return UnifiedBridgeReport(
        rows=tuple(all_rows),
        compatibility_results=tuple(compat_results),
        sep_results=tuple(sep_results),
        bridge_status=UNIFIED_BRIDGE_STATUS,
        bijection_status=BIJECTION_STATUS,
        gate_eligible=UNIFIED_BRIDGE_GATE_ELIGIBLE,
        gate_active=SHELL_PRIME_MATCH_GATE_ACTIVE,
        recommendation=rec,
    )


def export_unified_bridge_csv(report: UnifiedBridgeReport, path: Path | str) -> Path:
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "n",
        "prefix_index",
        "canonical_x",
        "canonical_y",
        "canonical_z",
        "bridged_x",
        "bridged_y",
        "bridged_z",
        "axis_label",
        "axis_label_status",
        "interpretive_word",
        "interpretive_word_status",
        "energiedoku_interp_x",
        "energiedoku_interp_y",
        "energiedoku_interp_z",
        "energiedoku_interp_diff_l2",
        "sep_canonical",
        "sep_energiedoku_diagnostic",
        "sep_bridged",
        "bridged_compatible_n_nplus1",
        "bridge_status",
        "bijection_status",
        "gate_eligible",
        "gate_active",
        "track_a_source",
        "track_b_source",
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
                    "bridged_x": row.bridged_x,
                    "bridged_y": row.bridged_y,
                    "bridged_z": row.bridged_z,
                    "axis_label": row.axis_label,
                    "axis_label_status": row.axis_label_status,
                    "interpretive_word": row.interpretive_word,
                    "interpretive_word_status": row.interpretive_word_status,
                    "energiedoku_interp_x": row.energiedoku_interp_x,
                    "energiedoku_interp_y": row.energiedoku_interp_y,
                    "energiedoku_interp_z": row.energiedoku_interp_z,
                    "energiedoku_interp_diff_l2": row.energiedoku_interp_diff_l2,
                    "sep_canonical": row.sep_canonical,
                    "sep_energiedoku_diagnostic": row.sep_energiedoku_diagnostic,
                    "sep_bridged": row.sep_bridged,
                    "bridged_compatible_n_nplus1": row.bridged_compatible_n_nplus1,
                    "bridge_status": row.bridge_status,
                    "bijection_status": report.bijection_status,
                    "gate_eligible": row.gate_eligible,
                    "gate_active": report.gate_active,
                    "track_a_source": CANONICAL_SOURCE_LABEL,
                    "track_b_source": ENERGIEDOKU_SOURCE_LABEL,
                    "notes": row.notes,
                }
            )
    return out


__all__ = [
    "BIJECTION_STATUS",
    "BridgeRule",
    "BridgeSepResult",
    "CompatibilityResult",
    "COORDINATE_TRANSFORM_NOTE",
    "DOCUMENTED_AXIS_LABEL_RULES",
    "ProofStatus",
    "UNIFIED_BRIDGE_GATE_ELIGIBLE",
    "UNIFIED_BRIDGE_STATUS",
    "UnifiedBridgeReport",
    "UnifiedBridgeRow",
    "UnifiedEmbeddingBridge",
    "build_bridge_rows",
    "default_coordinate_transform",
    "export_unified_bridge_csv",
    "run_unified_bridge_report",
]
