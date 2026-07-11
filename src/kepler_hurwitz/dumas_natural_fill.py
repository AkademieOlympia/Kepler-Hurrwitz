from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, Sequence

from kepler_hurwitz.kepler_eabc_atlas import EABCChannel
from kepler_hurwitz.primvierling import Primvierling, build_prime_quadruplet

DumasRole = Literal["triple", "host"]

# Lean `EABCChannel` fin_cases order; blocks of three hostTriple slots → 12 total.
HOST_CHANNEL_ORDER: tuple[EABCChannel, ...] = (
    EABCChannel.E,
    EABCChannel.A,
    EABCChannel.B,
    EABCChannel.C,
)

# Dumas-Drillinge rotor (overview export): host label cycles E→A→B→C by quadruplet
# index.  This is a *role rotor*, not the EABC mod-12 class of D'Artagnan.
# Canonical quadruplet v = (p, p+2, p+6, p+8); D'Artagnan = p + s with periodic s.
ROTOR_OFFSET_CYCLE: tuple[int, int, int, int] = (8, 0, 2, 6)  # s for hosts E, A, B, C
ROTOR_POSITION_CYCLE: tuple[int, int, int, int] = (4, 1, 2, 3)  # 1-based in (p, p+2, p+6, p+8)

ROTOR_OFFSET_BY_HOST: dict[EABCChannel, int] = dict(
    zip(HOST_CHANNEL_ORDER, ROTOR_OFFSET_CYCLE, strict=True)
)
ROTOR_POSITION_BY_HOST: dict[EABCChannel, int] = dict(
    zip(HOST_CHANNEL_ORDER, ROTOR_POSITION_CYCLE, strict=True)
)

# EABC mod-12 residue classes (geometric labels); distinct from the overview rotor.
EABC_MOD12_RESIDUE: dict[EABCChannel, int] = {
    EABCChannel.E: 1,
    EABCChannel.A: 5,
    EABCChannel.B: 7,
    EABCChannel.C: 11,
}

# Lean `hostTripleGapPair` on canonical prime quadruplets (p, p+2, p+6, p+8).
HOST_TRIPLE_GAP_PAIR: dict[EABCChannel, tuple[int, int]] = {
    EABCChannel.E: (2, 4),
    EABCChannel.A: (4, 2),
    EABCChannel.B: (6, 2),
    EABCChannel.C: (2, 6),
}

DumasSlotCount = 12


@dataclass(frozen=True)
class DumasSlot:
    """One of twelve natural indices after Dumas (4 hosts × 3 musketeer slots)."""

    index: int
    host: EABCChannel
    slot_in_host: int
    prime: int
    role: DumasRole


@dataclass(frozen=True)
class DumasNaturalFill:
    """Systematic 1..12 assignment on a Primvierling after the Dumas lemma."""

    primvierling: Primvierling
    host_components: dict[str, int]
    triple_slots: tuple[DumasSlot, ...]
    host_slots: tuple[DumasSlot, ...]

    @property
    def slots(self) -> tuple[DumasSlot, ...]:
        return self.triple_slots + self.host_slots


def primvierling_four_set(v: Primvierling) -> frozenset[int]:
    return frozenset(v)


def host_component(host: EABCChannel, v: Primvierling) -> int:
    a, b, c, e = v
    match host:
        case EABCChannel.E:
            return e
        case EABCChannel.A:
            return a
        case EABCChannel.B:
            return b
        case EABCChannel.C:
            return c


def host_triple(host: EABCChannel, v: Primvierling) -> tuple[int, ...]:
    """Musketiere triple: components(v) \\ {hostComponent(host, v)} in ascending order."""
    omitted = host_component(host, v)
    return tuple(sorted(x for x in primvierling_four_set(v) if x != omitted))


def sorted_gap_pair(triple: Sequence[int]) -> tuple[int, int]:
    """Lean `sortedGapPair`: consecutive gaps in the sorted triple."""
    ordered = tuple(sorted(triple))
    if len(ordered) != 3:
        raise ValueError("triple must have exactly three elements")
    return (ordered[1] - ordered[0], ordered[2] - ordered[1])


def host_triple_gap_pair(host: EABCChannel) -> tuple[int, int]:
    """Lean `hostTripleGapPair` on canonical prime quadruplets."""
    return HOST_TRIPLE_GAP_PAIR[host]


def host_for_quadruplet_index(index: int) -> EABCChannel:
    """Rotor label E→A→B→C for Dumas-Drillinge overview rows (1-based index).

    The returned host is the *role rotor*, not the EABC mod-12 class of D'Artagnan.
    """
    if index < 1:
        raise ValueError("index must be >= 1")
    return HOST_CHANNEL_ORDER[(index - 1) % len(HOST_CHANNEL_ORDER)]


def rotor_d_artagnan_offset(host: EABCChannel) -> int:
    """Offset s in D'Artagnan = p + s on canonical quadruplets (p, p+2, p+6, p+8)."""
    return ROTOR_OFFSET_BY_HOST[host]


def rotor_d_artagnan(host: EABCChannel, v: Primvierling) -> int:
    """D'Artagnan prime for rotor host on canonical quadruplet v = (p, p+2, p+6, p+8)."""
    return v[0] + rotor_d_artagnan_offset(host)


def eabc_channel_from_mod12(residue: int) -> EABCChannel:
    """Map an odd invertible residue mod 12 to its EABC channel label."""
    normalized = residue % 12
    for host, expected in EABC_MOD12_RESIDUE.items():
        if normalized == expected:
            return host
    raise ValueError(f"residue {residue} is not an EABC mod-12 class")


def build_dumas_natural_fill(v: Primvierling) -> DumasNaturalFill:
    """
    Fill the post-Dumas 4×3 lattice with naturals 1..12.

    Indices 1..12 label sorted hostTriple entries (E-block, A-block, B-block, C-block).
    Host components are recorded separately in ``host_slots`` with the same channel order.
    """
    _validate_distinct_primvierling(v)

    triple_slots: list[DumasSlot] = []
    index = 1
    for host in HOST_CHANNEL_ORDER:
        for slot_in_host, prime in enumerate(host_triple(host, v), start=1):
            triple_slots.append(
                DumasSlot(
                    index=index,
                    host=host,
                    slot_in_host=slot_in_host,
                    prime=prime,
                    role="triple",
                )
            )
            index += 1

    host_slots = tuple(
        DumasSlot(
            index=0,
            host=host,
            slot_in_host=0,
            prime=host_component(host, v),
            role="host",
        )
        for host in HOST_CHANNEL_ORDER
    )
    host_components = {host.value: host_component(host, v) for host in HOST_CHANNEL_ORDER}

    return DumasNaturalFill(
        primvierling=v,
        host_components=host_components,
        triple_slots=tuple(triple_slots),
        host_slots=host_slots,
    )


def dumas_slot_by_index(fill: DumasNaturalFill, index: int) -> DumasSlot:
    if not 1 <= index <= DumasSlotCount:
        raise ValueError(f"index must lie in 1..{DumasSlotCount}, got {index}")
    return fill.triple_slots[index - 1]


def prime_indices_for_component(fill: DumasNaturalFill, prime: int) -> tuple[int, ...]:
    """Return the three natural indices where ``prime`` appears in a hostTriple."""
    return tuple(slot.index for slot in fill.triple_slots if slot.prime == prime)


def natural_fill_index_gaps(fill: DumasNaturalFill) -> tuple[int, ...]:
    """Missing naturals in ``1..12`` among triple slots (empty iff gap-free)."""
    present = {slot.index for slot in fill.triple_slots}
    return tuple(i for i in range(1, DumasSlotCount + 1) if i not in present)


def verify_dumas_lemma(v: Primvierling) -> bool:
    """Check the finite Dumas bundle on ``v`` (card 3, union, multiplicity 3, gap encodes host)."""
    _validate_distinct_primvierling(v)
    four_set = primvierling_four_set(v)
    if len(four_set) != 4:
        return False

    for host in HOST_CHANNEL_ORDER:
        triple = host_triple(host, v)
        host_prime = host_component(host, v)
        if len(triple) != 3:
            return False
        if frozenset(triple) | {host_prime} != four_set:
            return False
        if host_prime in triple:
            return False

    for prime in four_set:
        hosts_containing = [
            host
            for host in HOST_CHANNEL_ORDER
            if prime in host_triple(host, v)
        ]
        if len(hosts_containing) != 3:
            return False
        excluded = next(host for host in HOST_CHANNEL_ORDER if host_component(host, v) == prime)
        if prime in host_triple(excluded, v):
            return False

    fill = build_dumas_natural_fill(v)
    if len(fill.triple_slots) != DumasSlotCount:
        return False
    if tuple(slot.index for slot in fill.triple_slots) != tuple(range(1, DumasSlotCount + 1)):
        return False

    return True


def build_dumas_natural_fill_for_anchor(anchor: int) -> DumasNaturalFill:
    """Convenience wrapper for the canonical quadruplet ``(p, p+2, p+6, p+8)``."""
    return build_dumas_natural_fill(build_prime_quadruplet(anchor))


def _validate_distinct_primvierling(v: Primvierling) -> None:
    if len(set(v)) != 4:
        raise ValueError("primvierling components must be pairwise distinct")


# Classic witness used throughout the repo (Lean `example` in PrimvierlingSymmetry.lean).
CLASSIC_PRIMVIERLING: Primvierling = (11, 13, 17, 19)

# Expected triple-slot primes for CLASSIC_PRIMVIERLING (indices 1..12).
CLASSIC_TRIPLE_SLOT_PRIMES: tuple[int, ...] = (
    11,
    13,
    17,  # host E
    13,
    17,
    19,  # host A
    11,
    17,
    19,  # host B
    11,
    13,
    19,  # host C
)
