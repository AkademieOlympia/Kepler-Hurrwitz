"""
Dumas Cone–Orbit verification kernel — combinatorial host/slot/weight diagnostics.

Governance: rigid complementarity and weight orbit on canonical prime quadruplets;
Kepler/double-cone vocabulary is methodical [C], not physical dynamics.
"""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from math import log, sqrt
from typing import Iterable, Sequence

from kepler_hurwitz.diagnostics import primvierling_product
from kepler_hurwitz.primvierling import Primvierling, is_prime
from kepler_hurwitz.signatures import EABCSignature4, signature_from_nat

CHANNELS: dict[int, str] = {1: "E", 5: "A", 7: "B", 11: "C"}
HOSTS: tuple[str, ...] = ("E", "A", "B", "C")

# Lean convention: v = (a, b, c, e); E -> e, A -> a, B -> b, C -> c
COMPONENT_IDX: dict[str, int] = {"A": 0, "B": 1, "C": 2, "E": 3}

EXPECTED_GAPS: dict[str, tuple[int, int]] = {
    "E": (2, 4),
    "A": (4, 2),
    "B": (6, 2),
    "C": (2, 6),
}

ROTOR_GAP_CYCLE: tuple[tuple[int, int], ...] = ((2, 4), (4, 2), (6, 2), (2, 6))


def channel_from_mod12(p: int) -> str:
    residue = p % 12
    if residue not in CHANNELS:
        raise ValueError(f"prime {p} has non-EABC residue {residue} mod 12")
    return CHANNELS[residue]


def host_component(host: str, v: Primvierling) -> int:
    return v[COMPONENT_IDX[host]]


def host_triple(host: str, v: Primvierling) -> tuple[int, int, int]:
    d = host_component(host, v)
    return tuple(x for x in v if x != d)


def musketeer_gaps(musketeers: Sequence[int]) -> tuple[int, int]:
    return (musketeers[1] - musketeers[0], musketeers[2] - musketeers[1])


def host_for_quadruplet_index(index: int) -> str:
    """1-based enumeration index -> rotor host (E, A, B, C, ...)."""
    if index < 1:
        raise ValueError("index must be >= 1")
    return HOSTS[(index - 1) % 4]


def channel_signature(v: Primvierling) -> tuple[int, int, int, int]:
    counts = Counter(channel_from_mod12(x) for x in v)
    return tuple(counts[h] for h in HOSTS)


def natural_fill_slots(v: Primvierling) -> tuple[tuple[str, int, int], ...]:
    """Four host triples linearised to 12 (host, slot_in_host, prime) slots."""
    slots: list[tuple[str, int, int]] = []
    for host in HOSTS:
        triple = host_triple(host, v)
        for slot_in_host, prime in enumerate(triple, start=1):
            slots.append((host, slot_in_host, prime))
    return tuple(slots)


def push_weight(v: Primvierling, host: str, omega: float) -> tuple[float, float, float, float]:
    d = host_component(host, v)
    weights = {x: omega if x == d else (1 - omega) / 3 for x in v}
    out = {h: 0.0 for h in HOSTS}
    for prime, weight in weights.items():
        out[channel_from_mod12(prime)] += weight
    return tuple(out[h] for h in HOSTS)


def weight_entropy(vec: Sequence[float]) -> float:
    return -sum(x * log(x) for x in vec if x > 0)


def l2_from_uniform(vec: Sequence[float]) -> float:
    return sqrt(sum((x - 0.25) ** 2 for x in vec))


def project_to_kepler(signature: EABCSignature4 | tuple[int, int, int, int]) -> tuple[float, float, float]:
    """
    Lean ``projectToKepler``: a = M/4, e_kep = (max-min)/(M+1), R_v = (1+e_kep)/(1-e_kep).

    Returns ``(a, e_kep, R_v)``. Here ``e_kep`` is Kepler eccentricity (spread-based),
    not the normal-form E-factor ``e`` in ``n = 2^α 3^β r e``.
    See ``docs/eabc_normal_form.md`` §7.
    """
    if isinstance(signature, EABCSignature4):
        channels = signature.as_tuple()
    else:
        channels = signature
    mass = sum(channels)
    if mass <= 0:
        raise ValueError("channel mass must be > 0")
    a = mass / 4
    spread = max(channels) - min(channels)
    e_kep = spread / (mass + 1)
    radius_ratio = (1 + e_kep) / (1 - e_kep) if e_kep < 1 else float("inf")
    return (a, e_kep, radius_ratio)


def product_kepler(v: Primvierling) -> tuple[float, float, float]:
    return project_to_kepler(signature_from_nat(primvierling_product(v)))


def verify_dumas_orbit(quadruplets: Iterable[Primvierling]) -> list[tuple]:
    """H1–H4, H6 combinatorial checks; returns failure records."""
    failures: list[tuple] = []
    for v in quadruplets:
        prime_set = set(v)
        membership: Counter[int] = Counter()
        for host in HOSTS:
            d = host_component(host, v)
            triple = host_triple(host, v)
            if set(triple) | {d} != prime_set:
                failures.append(("bad_cover", v, host))
            if d in triple:
                failures.append(("d_in_musketeers", v, host))
            if len(triple) != 3:
                failures.append(("bad_triple_size", v, host))
            if musketeer_gaps(triple) != EXPECTED_GAPS[host]:
                failures.append(("bad_gap_pair", v, host, musketeer_gaps(triple)))
            for prime in triple:
                membership[prime] += 1
        for prime in prime_set:
            if membership[prime] != 3:
                failures.append(("bad_membership_count", v, prime, membership[prime]))
        if channel_signature(v) != (1, 1, 1, 1):
            failures.append(("bad_channel_signature", v, channel_signature(v)))
    return failures


def verify_natural_fill(quadruplets: Iterable[Primvierling]) -> list[tuple]:
    """H2: 12 slots; each prime appears exactly three times as musketeer."""
    failures: list[tuple] = []
    for v in quadruplets:
        slots = natural_fill_slots(v)
        if len(slots) != 12:
            failures.append(("bad_slot_count", v, len(slots)))
        prime_counts = Counter(prime for _, _, prime in slots)
        for prime in v:
            if prime_counts[prime] != 3:
                failures.append(("bad_slot_multiplicity", v, prime, prime_counts[prime]))
        for host in HOSTS:
            host_slots = [s for s in slots if s[0] == host]
            if len(host_slots) != 3:
                failures.append(("bad_host_slot_count", v, host, len(host_slots)))
    return failures


def verify_rotor_gap_sequence(quadruplets: Sequence[Primvierling]) -> list[tuple]:
    """H5: index-mod-4 host rotor yields periodic gap-pair cycle."""
    failures: list[tuple] = []
    for index, v in enumerate(quadruplets, start=1):
        host = host_for_quadruplet_index(index)
        triple = host_triple(host, v)
        gap_pair = musketeer_gaps(triple)
        if gap_pair != EXPECTED_GAPS[host]:
            failures.append(("rotor_gap_mismatch", index, v, host, gap_pair))
    if len(quadruplets) >= 4:
        observed = tuple(
            musketeer_gaps(host_triple(host_for_quadruplet_index(i + 1), quadruplets[i]))
            for i in range(4)
        )
        if observed != ROTOR_GAP_CYCLE:
            failures.append(("rotor_cycle_prefix", observed))
    return failures


def verify_kepler_circle(quadruplets: Iterable[Primvierling]) -> list[tuple]:
    """H7: full product signature projects to (a, e, R_v) = (1, 0, 1)."""
    failures: list[tuple] = []
    for v in quadruplets:
        sig = signature_from_nat(primvierling_product(v))
        if sig.as_tuple() != (1, 1, 1, 1):
            failures.append(("bad_product_signature", v, sig.as_tuple()))
        a, e, radius = product_kepler(v)
        if not (abs(a - 1.0) < 1e-12 and abs(e) < 1e-12 and abs(radius - 1.0) < 1e-12):
            failures.append(("bad_kepler", v, (a, e, radius)))
    return failures


def verify_weight_orbit_entropy(
    quadruplets: Sequence[Primvierling],
    omega: float,
) -> tuple[float, float] | None:
    """
    H8/H9: entropy and L2 distance from uniform are constant across hosts.
    Returns (entropy, l2_distance) when all hosts agree; None if empty.
    """
    if not quadruplets:
        return None
    reference: tuple[float, float] | None = None
    for v in quadruplets:
        for host in HOSTS:
            vec = push_weight(v, host, omega)
            stats = (weight_entropy(vec), l2_from_uniform(vec))
            if reference is None:
                reference = stats
            elif stats != reference:
                return None
    return reference


def d_artagnan_channel_distribution(
    quadruplets: Sequence[Primvierling],
) -> dict[str, Counter[str]]:
    """Host -> Counter of mod-12 channel of the D'Artagnan prime."""
    dist: dict[str, Counter[str]] = {h: Counter() for h in HOSTS}
    for v in quadruplets:
        for host in HOSTS:
            d = host_component(host, v)
            dist[host][channel_from_mod12(d)] += 1
    return dist


def generate_twin_pairs(start: int, stop: int) -> list[tuple[int, int]]:
    pairs: list[tuple[int, int]] = []
    for p in range(max(2, start), stop + 1):
        q = p + 2
        if q <= stop and is_prime(p) and is_prime(q):
            pairs.append((p, q))
    return pairs


def twin_channel_signature(p: int, q: int) -> tuple[int, int, int, int]:
    return signature_from_nat(p * q).as_tuple()


@dataclass(frozen=True)
class DumasOrbitScanSummary:
    quadruplet_count: int
    h1_h4_failures: int
    h2_failures: int
    h5_failures: int
    h7_failures: int
    host_channel_distribution: dict[str, dict[str, int]]
    twin_pair_count: int
    twin_signatures: dict[tuple[int, int, int, int], int]
    entropy_at_quarter: tuple[float, float]
    entropy_at_half: tuple[float, float]

    def as_dict(self) -> dict:
        return {
            "quadruplet_count": self.quadruplet_count,
            "h1_h4_failures": self.h1_h4_failures,
            "h2_failures": self.h2_failures,
            "h5_failures": self.h5_failures,
            "h7_failures": self.h7_failures,
            "host_channel_distribution": self.host_channel_distribution,
            "twin_pair_count": self.twin_pair_count,
            "twin_signatures": {str(k): v for k, v in self.twin_signatures.items()},
            "entropy_at_quarter": self.entropy_at_quarter,
            "entropy_at_half": self.entropy_at_half,
        }


def scan_dumas_orbit_hypotheses(
    quadruplets: Sequence[Primvierling],
    twin_stop: int = 1_000_000,
) -> DumasOrbitScanSummary:
    twins = [pair for pair in generate_twin_pairs(5, twin_stop) if pair != (3, 5)]
    twin_sigs: Counter[tuple[int, int, int, int]] = Counter()
    for p, q in twins:
        twin_sigs[twin_channel_signature(p, q)] += 1

    dist = d_artagnan_channel_distribution(quadruplets)
    return DumasOrbitScanSummary(
        quadruplet_count=len(quadruplets),
        h1_h4_failures=len(verify_dumas_orbit(quadruplets)),
        h2_failures=len(verify_natural_fill(quadruplets)),
        h5_failures=len(verify_rotor_gap_sequence(quadruplets)),
        h7_failures=len(verify_kepler_circle(quadruplets)),
        host_channel_distribution={h: dict(c) for h, c in dist.items()},
        twin_pair_count=len(twins),
        twin_signatures=dict(twin_sigs),
        entropy_at_quarter=verify_weight_orbit_entropy(quadruplets, 0.25) or (0.0, 0.0),
        entropy_at_half=verify_weight_orbit_entropy(quadruplets, 0.5) or (0.0, 0.0),
    )
