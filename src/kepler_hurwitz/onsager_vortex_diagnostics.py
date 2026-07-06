"""
Onsager vortex circulation diagnostics — Gap-Rotor loop holonomy on Primvierlinge.

Governance: [B] experimental stub — discrete winding and phase closure along
host-rotor and CEAB loops. Analog of quantised circulation Γ = n·h/m (ORQ-089);
not physical superfluidity; complements ORQ-080/083.

See docs/theory/onsager_quantization_bridge.md (ORQ-089).
"""

from __future__ import annotations

import csv
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Sequence

from kepler_hurwitz.dumas_cone_orbit import (
    EXPECTED_GAPS,
    HOSTS,
    channel_from_mod12,
    host_component,
    host_triple,
    musketeer_gaps,
)
from kepler_hurwitz.primvierling import (
    Primvierling,
    component_channels,
    orbit_under_ceab,
    symmetry_shift_ceab,
)

ONSAGER_VORTEX_TAG = "[B]"

# Discrete phase labels on the channel circle (E → A → B → C → E).
CHANNEL_PHASE: dict[str, int] = {host: index for index, host in enumerate(HOSTS)}

ModelType = str
MODEL_CANONICAL: ModelType = "canonical"
MODEL_CEAB_SHIFT: ModelType = "ceab_shift"
MODEL_CHANNEL_SHUFFLE: ModelType = "channel_shuffle"
NULLMODEL_CHOICES: frozenset[str] = frozenset({"ceab", "shuffle"})

__all__ = [
    "ONSAGER_VORTEX_TAG",
    "CeabHolonomyStep",
    "CirculationRecord",
    "GapRotorLoopStep",
    "accumulate_holonomy_phase",
    "ceab_holonomy_loop",
    "ceab_nullmodel_loop",
    "circulation_quantum_number",
    "compare_vortex_vs_trivial",
    "defect_core_prime",
    "defect_musketeer_overlap",
    "gap_rotor_loop",
    "gap_rotor_step",
    "holonomy_phase_closure_ok",
    "loop_encircles_defect_structure",
    "partial_rotor_winding",
    "trivial_host_loop",
    "build_circulation_record",
    "build_export_row",
    "build_export_rows_for_quadruplet",
    "export_rows_to_csv",
    "generate_prime_quadruplets_sieve",
    "gap_law_ok",
    "channel_shuffle_nullmodel",
    "parse_nullmodel_spec",
    "OnsagerVortexExportRow",
    "ONSAGER_VORTEX_CSV_FIELDS",
    "MODEL_CANONICAL",
    "MODEL_CEAB_SHIFT",
    "MODEL_CHANNEL_SHUFFLE",
]


@dataclass(frozen=True)
class GapRotorLoopStep:
    """One edge on the Dumas Gap-Rotor host cycle."""

    host: str
    gap_pair: tuple[int, int]
    defect_prime: int
    musketeers: tuple[int, int, int]
    phase_index: int
    d_artagnan_channel: str
    musketeer_overlap_with_defect: int


@dataclass(frozen=True)
class CeabHolonomyStep:
    """One CEAB involution step — component block swap (a,b,c,e) ↔ (c,e,a,b)."""

    state: Primvierling
    channels: tuple[str, str, str, str]
    phase_index: int
    pair_gaps: int


@dataclass(frozen=True)
class CirculationRecord:
    """Batch diagnostic for one Primvierling — vortex vs. trivial loop comparison."""

    primvierling: Primvierling
    vortex_winding: int
    trivial_winding: int
    holonomy_phase_total: int
    phase_closure_ok: bool
    encircles_defect: bool
    pop_threshold_steps: int
    ceab_loop_length: int
    ceab_phase_closure_ok: bool
    gap_law_ok: bool
    tag: str = ONSAGER_VORTEX_TAG


def gap_law_ok(v: Primvierling) -> bool:
    """All four host musketeer gap-pairs match Dumas EXPECTED_GAPS."""
    return all(
        musketeer_gaps(host_triple(host, v)) == EXPECTED_GAPS[host]
        for host in HOSTS
    )


def channel_shuffle_nullmodel(v: Primvierling, swap: tuple[int, int] = (0, 2)) -> Primvierling:
    """Permute two component slots — destroys gap law while keeping the prime multiset."""
    components = list(v)
    i, j = swap
    components[i], components[j] = components[j], components[i]
    return tuple(components)  # type: ignore[return-value]


def parse_nullmodel_spec(spec: str | None) -> frozenset[str]:
    if not spec or not spec.strip():
        return frozenset()
    tokens = {part.strip().lower() for part in spec.split(",") if part.strip()}
    unknown = tokens - NULLMODEL_CHOICES
    if unknown:
        allowed = ", ".join(sorted(NULLMODEL_CHOICES))
        raise ValueError(f"unknown nullmodel(s) {sorted(unknown)}; allowed: {allowed}")
    return frozenset(tokens)


def structured_circulation_quantum_number(
    steps: Sequence[GapRotorLoopStep],
    v: Primvierling,
) -> int:
    """
    Winding n requiring Dumas gap law and defect-core validity.

    Combinatorial host cycles alone are insufficient — shuffle nullmodels must fail here.
    """
    if not validate_dumas_defect_core(v) or not gap_law_ok(v):
        return 0
    if not all(step.gap_pair == EXPECTED_GAPS[step.host] for step in steps):
        return 0
    return circulation_quantum_number(steps)


def structured_encircles_defect(
    steps: Sequence[GapRotorLoopStep],
    v: Primvierling,
) -> bool:
    """Defect encirclement only when gap law and Dumas core structure hold."""
    return (
        loop_encircles_defect_structure(steps)
        and gap_law_ok(v)
        and validate_dumas_defect_core(v)
    )


def structured_phase_closure_ok(
    steps: Sequence[GapRotorLoopStep],
    v: Primvierling,
) -> bool:
    """Phase closure tied to valid Dumas structure — not host cycle alone."""
    return holonomy_phase_closure_ok(steps) and gap_law_ok(v) and validate_dumas_defect_core(v)


def defect_core_prime(v: Primvierling, host: str) -> int:
    """D'Artagnan / axis-isolated prime for host h — Vortex-core analogue (ρ → 0)."""
    return host_component(host, v)


def defect_musketeer_overlap(v: Primvierling, host: str) -> int:
    """
    Count of defect primes inside the musketeer triple.

    Dumas complementarity forces 0 — the core is absent from the rotating fluid.
    """
    core = defect_core_prime(v, host)
    return sum(1 for prime in host_triple(host, v) if prime == core)


def gap_rotor_step(v: Primvierling, host: str) -> GapRotorLoopStep:
    musketeers = host_triple(host, v)
    defect = defect_core_prime(v, host)
    return GapRotorLoopStep(
        host=host,
        gap_pair=musketeer_gaps(musketeers),
        defect_prime=defect,
        musketeers=musketeers,
        phase_index=CHANNEL_PHASE[host],
        d_artagnan_channel=channel_from_mod12(defect),
        musketeer_overlap_with_defect=defect_musketeer_overlap(v, host),
    )


def gap_rotor_loop(v: Primvierling, cycles: int = 1) -> tuple[GapRotorLoopStep, ...]:
    """
    Closed Gap-Rotor loop: E → A → B → C → … for ``cycles`` full turns.

    One complete cycle (4 steps) models one quantised circulation quantum n = 1.
    """
    if cycles < 1:
        raise ValueError("cycles must be >= 1")
    steps: list[GapRotorLoopStep] = []
    total = 4 * cycles
    for index in range(total):
        host = HOSTS[index % 4]
        steps.append(gap_rotor_step(v, host))
    return tuple(steps)


def trivial_host_loop(v: Primvierling, host: str = "E", repeats: int = 4) -> tuple[GapRotorLoopStep, ...]:
    """Loop that never advances the rotor — no vortex (n = 0) control path."""
    if repeats < 1:
        raise ValueError("repeats must be >= 1")
    return tuple(gap_rotor_step(v, host) for _ in range(repeats))


def accumulate_holonomy_phase(steps: Sequence[GapRotorLoopStep]) -> int:
    """
    Sum of discrete phase advances along consecutive hosts (mod 4).

    Each +1 step on E→A→B→C→E contributes unit holonomy; closure requires total ≡ 0 (mod 4)
    for a return to the same phase label after an integer number of windings.
    """
    if len(steps) < 2:
        return 0
    total = 0
    for previous, current in zip(steps, steps[1:]):
        delta = (CHANNEL_PHASE[current.host] - CHANNEL_PHASE[previous.host]) % 4
        total = (total + delta) % 4
    closing = (CHANNEL_PHASE[steps[0].host] - CHANNEL_PHASE[steps[-1].host]) % 4
    return (total + closing) % 4


def holonomy_phase_closure_ok(steps: Sequence[GapRotorLoopStep]) -> bool:
    """Phase closes on the loop — Onsager/Feynman single-valued ψ condition."""
    return accumulate_holonomy_phase(steps) == 0


def circulation_quantum_number(steps: Sequence[GapRotorLoopStep]) -> int:
    """
    Integer winding n with Γ ∝ n·h/m analogy.

    Counts complete E→A→B→C host cycles in the step sequence. A trivial loop
    (fixed host repeated) yields n = 0; one full Gap-Rotor cycle yields n = 1.
    """
    if not steps:
        return 0
    if len(set(step.host for step in steps)) == 1:
        return 0
    host_advances = 0
    for previous, current in zip(steps, steps[1:]):
        from_index = CHANNEL_PHASE[previous.host]
        to_index = CHANNEL_PHASE[current.host]
        forward = (to_index - from_index) % 4
        if forward == 0:
            continue
        host_advances += forward
    closing = (CHANNEL_PHASE[steps[0].host] - CHANNEL_PHASE[steps[-1].host]) % 4
    if closing:
        host_advances += closing
    return host_advances // 4


def loop_encircles_defect_structure(steps: Sequence[GapRotorLoopStep]) -> bool:
    """
    True when the loop visits all four host perspectives — each D'Artagnan slot once.

    Analogous to a vortex loop encircling the ρ = 0 core rather than a contractible path.
    """
    if len(steps) < 4:
        return False
    visited_hosts = {step.host for step in steps}
    if visited_hosts != set(HOSTS):
        return False
    defects = {step.defect_prime for step in steps}
    return len(defects) == 4


def partial_rotor_winding(step_count: int) -> int:
    """
    Pop-threshold model: circulation stays quantised at n = 0 until a full 4-step cycle completes.

    Mirrors superfluid vortex nucleation — no partial circulation below the first quantum.
    """
    if step_count < 4:
        return 0
    return step_count // 4


def ceab_holonomy_loop(v: Primvierling) -> tuple[CeabHolonomyStep, ...]:
    """CEAB involution orbit — two-step phase closure (shiftCEAB² = Id)."""
    from kepler_hurwitz.primvierling import pair_gaps

    states = orbit_under_ceab(v)
    return tuple(
        CeabHolonomyStep(
            state=state,
            channels=component_channels(state),
            phase_index=sum(CHANNEL_PHASE[ch] for ch in component_channels(state)) % 4,
            pair_gaps=pair_gaps(state),
        )
        for state in states
    )


def ceab_nullmodel_loop(v: Primvierling) -> tuple[CeabHolonomyStep, ...]:
    """CEAB rotation null model — same holonomy machinery on permuted axis order."""
    return ceab_holonomy_loop(symmetry_shift_ceab(v))


def _ceab_phase_closure_ok(steps: Sequence[CeabHolonomyStep]) -> bool:
    if len(steps) <= 1:
        return True
    return steps[0].state == steps[-1].state or (
        len(steps) == 2 and symmetry_shift_ceab(steps[0].state) == steps[1].state
    )


def compare_vortex_vs_trivial(
    v: Primvierling,
    *,
    cycles: int = 1,
    trivial_host: str = "E",
) -> tuple[int, int, int, bool, bool]:
    """
    Return (n_vortex, n_trivial, holonomy_total, phase_ok, encircles_defect).

    Core comparison: full Gap-Rotor loop vs. fixed-host control loop.
    """
    vortex_steps = gap_rotor_loop(v, cycles=cycles)
    trivial_steps = trivial_host_loop(v, host=trivial_host, repeats=4 * cycles)
    holonomy = accumulate_holonomy_phase(vortex_steps)
    return (
        structured_circulation_quantum_number(vortex_steps, v),
        structured_circulation_quantum_number(trivial_steps, v),
        holonomy,
        structured_phase_closure_ok(vortex_steps, v),
        structured_encircles_defect(vortex_steps, v),
    )


def build_circulation_record(v: Primvierling, *, cycles: int = 1) -> CirculationRecord:
    vortex_steps = gap_rotor_loop(v, cycles=cycles)
    ceab_steps = ceab_holonomy_loop(v)
    holonomy = accumulate_holonomy_phase(vortex_steps)
    pop_at = next(
        (k for k in range(1, 5) if partial_rotor_winding(k) == 1),
        4,
    )
    return CirculationRecord(
        primvierling=v,
        vortex_winding=structured_circulation_quantum_number(vortex_steps, v),
        trivial_winding=structured_circulation_quantum_number(
            trivial_host_loop(v, repeats=4 * cycles),
            v,
        ),
        holonomy_phase_total=holonomy,
        phase_closure_ok=structured_phase_closure_ok(vortex_steps, v),
        encircles_defect=structured_encircles_defect(vortex_steps, v),
        pop_threshold_steps=pop_at,
        ceab_loop_length=len(ceab_steps),
        ceab_phase_closure_ok=_ceab_phase_closure_ok(ceab_steps),
        gap_law_ok=gap_law_ok(v),
    )


def validate_dumas_defect_core(v: Primvierling) -> bool:
    """Sanity: every host has zero musketeer overlap — structural ρ = 0 at core."""
    return all(defect_musketeer_overlap(v, host) == 0 for host in HOSTS)


ONSAGER_VORTEX_CSV_FIELDS: tuple[str, ...] = (
    "base_p1",
    "model_type",
    "p1",
    "p2",
    "p3",
    "p4",
    "vortex_winding",
    "trivial_winding",
    "holonomy_phase_total",
    "phase_closure_ok",
    "encircles_defect",
    "pop_threshold_steps",
    "ceab_loop_length",
    "ceab_phase_closure_ok",
    "gap_law_ok",
    "canonical_vortex_winding",
    "topological_contrast_vs_canonical",
    "defect_core_valid",
    "tag",
)


@dataclass(frozen=True)
class OnsagerVortexExportRow:
    """One CSV row — vortex diagnostics with optional nullmodel grouping."""

    base_p1: int
    model_type: ModelType
    p1: int
    p2: int
    p3: int
    p4: int
    vortex_winding: int
    trivial_winding: int
    holonomy_phase_total: int
    phase_closure_ok: bool
    encircles_defect: bool
    pop_threshold_steps: int
    ceab_loop_length: int
    ceab_phase_closure_ok: bool
    gap_law_ok: bool
    canonical_vortex_winding: int
    topological_contrast_vs_canonical: bool
    defect_core_valid: bool
    tag: str = ONSAGER_VORTEX_TAG

    def as_csv_dict(self) -> dict[str, object]:
        row = asdict(self)
        row["phase_closure_ok"] = int(self.phase_closure_ok)
        row["encircles_defect"] = int(self.encircles_defect)
        row["ceab_phase_closure_ok"] = int(self.ceab_phase_closure_ok)
        row["gap_law_ok"] = int(self.gap_law_ok)
        row["topological_contrast_vs_canonical"] = int(self.topological_contrast_vs_canonical)
        row["defect_core_valid"] = int(self.defect_core_valid)
        return row


def _records_differ(
    left: CirculationRecord,
    right: CirculationRecord,
) -> bool:
    return (
        left.vortex_winding != right.vortex_winding
        or left.phase_closure_ok != right.phase_closure_ok
        or left.encircles_defect != right.encircles_defect
        or left.gap_law_ok != right.gap_law_ok
    )


def build_export_row(
    v: Primvierling,
    *,
    model_type: ModelType = MODEL_CANONICAL,
    base_p1: int | None = None,
    canonical_record: CirculationRecord | None = None,
    cycles: int = 1,
) -> OnsagerVortexExportRow:
    record = build_circulation_record(v, cycles=cycles)
    anchor_p1 = base_p1 if base_p1 is not None else v[0]
    if canonical_record is None:
        canonical_record = record
    return OnsagerVortexExportRow(
        base_p1=anchor_p1,
        model_type=model_type,
        p1=v[0],
        p2=v[1],
        p3=v[2],
        p4=v[3],
        vortex_winding=record.vortex_winding,
        trivial_winding=record.trivial_winding,
        holonomy_phase_total=record.holonomy_phase_total,
        phase_closure_ok=record.phase_closure_ok,
        encircles_defect=record.encircles_defect,
        pop_threshold_steps=record.pop_threshold_steps,
        ceab_loop_length=record.ceab_loop_length,
        ceab_phase_closure_ok=record.ceab_phase_closure_ok,
        gap_law_ok=record.gap_law_ok,
        canonical_vortex_winding=canonical_record.vortex_winding,
        topological_contrast_vs_canonical=_records_differ(record, canonical_record),
        defect_core_valid=validate_dumas_defect_core(v),
    )


def build_export_rows_for_quadruplet(
    v: Primvierling,
    *,
    include_nullmodels: frozenset[str] = frozenset(),
    cycles: int = 1,
) -> tuple[OnsagerVortexExportRow, ...]:
    """Emit canonical row plus optional CEAB/shuffle nullmodel rows sharing ``base_p1``."""
    canonical_record = build_circulation_record(v, cycles=cycles)
    rows: list[OnsagerVortexExportRow] = [
        build_export_row(
            v,
            model_type=MODEL_CANONICAL,
            base_p1=v[0],
            canonical_record=canonical_record,
            cycles=cycles,
        )
    ]
    if "ceab" in include_nullmodels:
        rows.append(
            build_export_row(
                symmetry_shift_ceab(v),
                model_type=MODEL_CEAB_SHIFT,
                base_p1=v[0],
                canonical_record=canonical_record,
                cycles=cycles,
            )
        )
    if "shuffle" in include_nullmodels:
        rows.append(
            build_export_row(
                channel_shuffle_nullmodel(v),
                model_type=MODEL_CHANNEL_SHUFFLE,
                base_p1=v[0],
                canonical_record=canonical_record,
                cycles=cycles,
            )
        )
    return tuple(rows)


def export_rows_to_csv(rows: Sequence[OnsagerVortexExportRow], path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(ONSAGER_VORTEX_CSV_FIELDS))
        writer.writeheader()
        for row in rows:
            writer.writerow(row.as_csv_dict())
    return path


def generate_prime_quadruplets_sieve(start: int, stop: int) -> list[Primvierling]:
    """
    Sieve-backed canonical quadruplet search: v = (p, p+2, p+6, p+8).

    Faster than per-candidate ``is_prime`` trial division for batch export.
    """
    if stop < start:
        raise ValueError("stop must be >= start")
    limit = stop + 8
    if limit < 2:
        return []
    flags = bytearray(b"\x01") * (limit + 1)
    flags[0:2] = b"\x00\x00"
    for candidate in range(2, int(limit**0.5) + 1):
        if flags[candidate]:
            step_start = candidate * candidate
            flags[step_start : limit + 1 : candidate] = b"\x00" * len(
                range(step_start, limit + 1, candidate)
            )
    quadruplets: list[Primvierling] = []
    for p in range(max(2, start), stop + 1):
        if p <= 3:
            continue
        if flags[p] and flags[p + 2] and flags[p + 6] and flags[p + 8]:
            quadruplets.append((p, p + 2, p + 6, p + 8))
    return quadruplets
