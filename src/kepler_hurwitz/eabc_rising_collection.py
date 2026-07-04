"""Greedy rising EABC quadruple collection over the prime list.

Algorithm (documented choice for ambiguous collision cases)
----------------------------------------------------------

Scan the first *n* primes in ascending value.  Maintain a working
*collection* of EABC-class primes (residues 1, 5, 7, 11 mod 12 only;
2 and 3 are skipped).

For each candidate prime ``q``:

1. **Channel collision** — if ``q`` shares an EABC channel with an existing
   member ``old``:
   - *One member*: replace it with ``q`` (degenerate min=max case).
   - *Two or more*: if ``old`` is strictly between ``min(collection)`` and
     ``max(collection)`` (*inner*), remove ``old`` and append ``q``.
   - *Outer collision* (``old`` is the current minimum or maximum): skip ``q``
     (do not extend the collection).

2. **No collision** — append ``q``.

3. When the collection holds exactly four primes with four distinct EABC
   channels (E, A, B, C each once), record it as an **EABC-Vierling**, then
   **reset** the collection to empty and continue scanning for the next
   quadruple.

Rising order: primes and recorded quadruples appear in ascending value.
Quadruples need not be consecutive in the prime list or form canonical
``(p, p+2, p+6, p+8)`` patterns.

Greedy bound (``collect_eabc_rising_quadruples``)
-------------------------------------------------

Formal definition and theorem ``K_greedy <= K_bucket``: ``docs/eabc_partition.md`` §3.
Each recorded quadruple family is disjoint and EABC-complete, hence its size is bounded
by ``min_c |L_c|`` (combinatorial **[A]**).  Concrete ``K_greedy(n)`` values are
**[B+]** export statistics.

Channel-bucket partition (``partition_eabc_quadruples_by_channels``)
--------------------------------------------------------------------

Formal definition and maximality theorem: ``docs/eabc_partition.md`` §1–§2.

Overlap chain and disjoint extraction (``collect_eabc_rising_with_trace``)
---------------------------------------------------------------------------

Formal definition of the working-collection *Aufstiegskette mit Überlappung*
and the reset-based disjoint extraction rule: ``docs/eabc_partition.md`` §9.

Given the EABC stream ``S`` (EABC-class primes from the first *n* primes, in scan
order) and channel map ``κ`` (mod-12 residue → E/A/B/C), split ``S`` into four
rising lists ``L_E, L_A, L_B, L_C``.  For ``K = min_c |L_c|`` and slot ``i`` in
``0 .. K-1``, form quadruple ``Q_i = {L_E[i], L_A[i], L_B[i], L_C[i]}``.  Surplus
entries ``L_c[K..]`` form the remainder ``R``.  This yields a disjoint,
EABC-complete partition of maximal size ``K`` (each channel contributes exactly
one prime per quadruple, so no partition can exceed ``min_c |L_c|`` quadruples).
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Sequence

from kepler_hurwitz.dumas_natural_fill import eabc_channel_from_mod12
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel
from kepler_hurwitz.primvierling import is_prime, is_prime_quadruplet

EABC_CHANNELS: frozenset[EABCChannel] = frozenset(EABCChannel)
EABC_CHANNEL_ORDER: tuple[EABCChannel, ...] = (
    EABCChannel.E,
    EABCChannel.A,
    EABCChannel.B,
    EABCChannel.C,
)


@dataclass(frozen=True)
class EABCRisingQuadruple:
    """One recorded EABC-Vierling from the greedy scan."""

    index: int
    primes: tuple[int, int, int, int]
    channels: tuple[EABCChannel, EABCChannel, EABCChannel, EABCChannel]
    span: int
    gaps: tuple[int, int, int]
    canonical: bool

    @property
    def p1(self) -> int:
        return self.primes[0]

    @property
    def p2(self) -> int:
        return self.primes[1]

    @property
    def p3(self) -> int:
        return self.primes[2]

    @property
    def p4(self) -> int:
        return self.primes[3]

    def as_csv_row(self) -> dict[str, object]:
        channel_labels = ",".join(channel.value for channel in self.channels)
        gap_labels = ",".join(str(gap) for gap in self.gaps)
        return {
            "index": self.index,
            "p1": self.p1,
            "p2": self.p2,
            "p3": self.p3,
            "p4": self.p4,
            "channels": channel_labels,
            "span": self.span,
            "gaps": gap_labels,
            "canonical": self.canonical,
        }


def sieve_primes_up_to(limit: int) -> list[int]:
    """Return all primes <= *limit* in ascending order."""
    if limit < 2:
        return []
    is_composite = [False] * (limit + 1)
    for candidate in range(2, isqrt(limit) + 1):
        if not is_composite[candidate]:
            for multiple in range(candidate * candidate, limit + 1, candidate):
                is_composite[multiple] = True
    return [value for value in range(2, limit + 1) if not is_composite[value]]


def first_n_primes(n: int) -> list[int]:
    """Return the first *n* primes by value (2 is the first)."""
    if n < 1:
        raise ValueError("n must be >= 1")

    if n == 1:
        return [2]

    upper = max(20, n * (n // 10 + 2))
    while True:
        primes = sieve_primes_up_to(upper)
        if len(primes) >= n:
            return primes[:n]
        upper *= 2


def is_eabc_class_prime(p: int) -> bool:
    """True iff *p* lies in an EABC mod-12 residue class (1, 5, 7, 11)."""
    if not is_prime(p):
        return False
    try:
        eabc_channel_from_mod12(p)
    except ValueError:
        return False
    return True


def prime_eabc_channel(p: int) -> EABCChannel:
    """EABC channel label for an EABC-class prime."""
    return eabc_channel_from_mod12(p)


def is_canonical_prime_quadruplet(primes: Sequence[int]) -> bool:
    """True iff sorted *primes* equal ``(p, p+2, p+6, p+8)`` with all prime."""
    ordered = tuple(sorted(primes))
    if len(ordered) != 4:
        return False
    anchor = ordered[0]
    return is_prime_quadruplet((anchor, anchor + 2, anchor + 6, anchor + 8)) and ordered == (
        anchor,
        anchor + 2,
        anchor + 6,
        anchor + 8,
    )


def consecutive_gaps(primes: Sequence[int]) -> tuple[int, int, int]:
    ordered = tuple(sorted(primes))
    if len(ordered) != 4:
        raise ValueError("quadruple must have exactly four primes")
    return (
        ordered[1] - ordered[0],
        ordered[2] - ordered[1],
        ordered[3] - ordered[2],
    )


def _try_add_to_collection(collection: list[int], q: int) -> list[int]:
    """Apply collision rule; return updated sorted collection."""
    channel_q = prime_eabc_channel(q)
    same_channel = [member for member in collection if prime_eabc_channel(member) == channel_q]

    if not same_channel:
        return sorted(collection + [q])

    old = same_channel[0]
    if len(collection) == 1:
        return [q]

    lo = min(collection)
    hi = max(collection)
    if lo < old < hi:
        updated = [member for member in collection if member != old]
        updated.append(q)
        return sorted(updated)

    return collection


def _is_complete_eabc_quadruple(collection: Sequence[int]) -> bool:
    if len(collection) != 4:
        return False
    channels = {prime_eabc_channel(p) for p in collection}
    return channels == EABC_CHANNELS


def collect_eabc_rising_quadruples(
    prime_count: int = 2000,
    *,
    primes: Sequence[int] | None = None,
) -> tuple[list[EABCRisingQuadruple], list[int]]:
    """
    Run the greedy rising scan on the first *prime_count* primes.

    Returns ``(quadruples, eabc_prime_stream)`` where ``eabc_prime_stream`` is
    the subsequence of input primes that lie in EABC residue classes (in scan
    order).
    """
    if prime_count < 1:
        raise ValueError("prime_count must be >= 1")

    source = list(primes) if primes is not None else first_n_primes(prime_count)
    if primes is None and len(source) != prime_count:
        raise ValueError(f"expected {prime_count} primes, got {len(source)}")

    eabc_stream: list[int] = []
    collection: list[int] = []
    quadruples: list[EABCRisingQuadruple] = []

    for q in source:
        if not is_eabc_class_prime(q):
            continue
        eabc_stream.append(q)
        collection = _try_add_to_collection(collection, q)
        if _is_complete_eabc_quadruple(collection):
            ordered = tuple(sorted(collection))
            channels = tuple(prime_eabc_channel(p) for p in ordered)
            gaps = consecutive_gaps(ordered)
            quadruples.append(
                EABCRisingQuadruple(
                    index=len(quadruples) + 1,
                    primes=ordered,  # type: ignore[arg-type]
                    channels=channels,  # type: ignore[arg-type]
                    span=ordered[3] - ordered[0],
                    gaps=gaps,
                    canonical=is_canonical_prime_quadruplet(ordered),
                )
            )
            collection = []

    return quadruples, eabc_stream


def verify_quadruple_eabc_completeness(quadruple: EABCRisingQuadruple) -> bool:
    """Each EABC channel appears exactly once among the four primes."""
    return set(quadruple.channels) == EABC_CHANNELS


def summarize_quadruples(quadruples: Sequence[EABCRisingQuadruple]) -> dict[str, object]:
    """Aggregate statistics for reporting."""
    canonical_count = sum(1 for row in quadruples if row.canonical)
    return {
        "count": len(quadruples),
        "canonical_count": canonical_count,
        "noncanonical_count": len(quadruples) - canonical_count,
        "all_eabc_complete": all(verify_quadruple_eabc_completeness(q) for q in quadruples),
        "first": quadruples[0].as_csv_row() if quadruples else None,
        "last": quadruples[-1].as_csv_row() if quadruples else None,
    }


@dataclass(frozen=True)
class EABCCollectionStep:
    """One greedy scan step on the working collection."""

    step_index: int
    prime: int
    collection_before: tuple[int, ...]
    collection_after: tuple[int, ...]
    overlap_size: int
    size_before: int
    size_after: int
    recorded_quadruple_index: int | None
    build_index: int

    def as_csv_row(self) -> dict[str, object]:
        return {
            "step_index": self.step_index,
            "prime": self.prime,
            "size_before": self.size_before,
            "size_after": self.size_after,
            "overlap_size": self.overlap_size,
            "collection_before": ",".join(str(p) for p in self.collection_before),
            "collection_after": ",".join(str(p) for p in self.collection_after),
            "recorded_quadruple_index": self.recorded_quadruple_index or "",
            "build_index": self.build_index,
        }


def quadruple_prime_set(quadruple: EABCRisingQuadruple) -> frozenset[int]:
    """Return the four primes of *quadruple* as a set."""
    return frozenset(quadruple.primes)


def verify_pairwise_disjoint(quadruples: Sequence[EABCRisingQuadruple]) -> bool:
    """True iff no prime appears in more than one recorded quadruple."""
    seen: set[int] = set()
    for row in quadruples:
        members = quadruple_prime_set(row)
        if members & seen:
            return False
        seen |= members
    return True


def consecutive_recorded_overlap_sizes(
    quadruples: Sequence[EABCRisingQuadruple],
) -> list[int]:
    """Pairwise intersection sizes between consecutive *recorded* quadruples."""
    overlaps: list[int] = []
    for left, right in zip(quadruples, quadruples[1:]):
        overlaps.append(len(quadruple_prime_set(left) & quadruple_prime_set(right)))
    return overlaps


def extract_maximal_disjoint_subsequence(
    quadruples: Sequence[EABCRisingQuadruple],
) -> list[EABCRisingQuadruple]:
    """
    Greedy left-to-right maximal disjoint subsequence.

    Keep quadruple ``Q_i`` iff ``Q_i`` shares no primes with any earlier kept
    quadruple.  For the standard greedy scan output (reset after recording) this
    returns the full list unchanged.
    """
    chosen: list[EABCRisingQuadruple] = []
    used: set[int] = set()
    for row in quadruples:
        members = quadruple_prime_set(row)
        if members & used:
            continue
        chosen.append(row)
        used |= members
    return chosen


def collect_eabc_rising_with_trace(
    prime_count: int = 2000,
    *,
    primes: Sequence[int] | None = None,
    reset_after_record: bool = True,
) -> tuple[list[EABCRisingQuadruple], list[EABCCollectionStep], list[int]]:
    """
    Run the greedy rising scan and record every working-collection transition.

    When ``reset_after_record`` is True (default), each complete quadruple is
    recorded and the collection is cleared — the implemented greedy rule.

    When False, the collection is *not* cleared after recording; consecutive
    recorded quadruples then overlap heavily (typically three or four shared
    primes).  See ``docs/eabc_partition.md`` §9.
    """
    if prime_count < 1:
        raise ValueError("prime_count must be >= 1")

    source = list(primes) if primes is not None else first_n_primes(prime_count)
    if primes is None and len(source) != prime_count:
        raise ValueError(f"expected {prime_count} primes, got {len(source)}")

    eabc_stream: list[int] = []
    collection: list[int] = []
    quadruples: list[EABCRisingQuadruple] = []
    steps: list[EABCCollectionStep] = []
    build_index = 1
    step_index = 0

    for q in source:
        if not is_eabc_class_prime(q):
            continue
        eabc_stream.append(q)
        before = tuple(sorted(collection))
        collection = _try_add_to_collection(collection, q)
        after = tuple(sorted(collection))
        step_index += 1
        recorded_index: int | None = None
        if _is_complete_eabc_quadruple(collection):
            ordered = tuple(sorted(collection))
            channels = tuple(prime_eabc_channel(p) for p in ordered)
            gaps = consecutive_gaps(ordered)
            quadruples.append(
                EABCRisingQuadruple(
                    index=len(quadruples) + 1,
                    primes=ordered,  # type: ignore[arg-type]
                    channels=channels,  # type: ignore[arg-type]
                    span=ordered[3] - ordered[0],
                    gaps=gaps,
                    canonical=is_canonical_prime_quadruplet(ordered),
                )
            )
            recorded_index = quadruples[-1].index
            if reset_after_record:
                collection = []

        steps.append(
            EABCCollectionStep(
                step_index=step_index,
                prime=q,
                collection_before=before,
                collection_after=after,
                overlap_size=len(set(before) & set(after)),
                size_before=len(before),
                size_after=len(after),
                recorded_quadruple_index=recorded_index,
                build_index=build_index,
            )
        )
        if recorded_index is not None and reset_after_record:
            build_index += 1

    return quadruples, steps, eabc_stream


def transition_overlap_histogram(
    steps: Sequence[EABCCollectionStep],
) -> dict[tuple[int, int, int], int]:
    """Count transitions by ``(size_before, size_after, overlap_size)``."""
    histogram: dict[tuple[int, int, int], int] = {}
    for step in steps:
        key = (step.size_before, step.size_after, step.overlap_size)
        histogram[key] = histogram.get(key, 0) + 1
    return histogram


def summarize_rising_overlap_chain(
    prime_count: int = 2000,
    *,
    primes: Sequence[int] | None = None,
) -> dict[str, object]:
    """
    Overlap analysis for greedy rising collection (see ``docs/eabc_partition.md`` §9).

    Compares:
    - working-collection transitions (Aufstiegskette mit Überlappung),
    - recorded quadruples with reset (disjoint extraction rule),
    - recorded quadruples without reset (overlapping quadruple chain),
    - channel-bucket maximal disjoint partition.
    """
    quadruples_reset, steps, _eabc_stream = collect_eabc_rising_with_trace(
        prime_count,
        primes=primes,
        reset_after_record=True,
    )
    quadruples_no_reset, _, _ = collect_eabc_rising_with_trace(
        prime_count,
        primes=primes,
        reset_after_record=False,
    )
    bucket_quadruples, _, _remainder = partition_eabc_quadruples_by_channels(
        prime_count,
        primes=primes,
    )

    transition_hist = transition_overlap_histogram(steps)
    recorded_overlaps = consecutive_recorded_overlap_sizes(quadruples_reset)
    no_reset_overlaps = consecutive_recorded_overlap_sizes(quadruples_no_reset)
    disjoint_subseq_reset = extract_maximal_disjoint_subsequence(quadruples_reset)
    disjoint_subseq_no_reset = extract_maximal_disjoint_subsequence(quadruples_no_reset)

    transition_overlap_counts: dict[int, int] = {}
    for (_size_before, _size_after, overlap), count in transition_hist.items():
        transition_overlap_counts[overlap] = transition_overlap_counts.get(overlap, 0) + count

    no_reset_overlap_counts: dict[int, int] = {}
    for overlap in no_reset_overlaps:
        no_reset_overlap_counts[overlap] = no_reset_overlap_counts.get(overlap, 0) + 1

    recorded_consecutive_overlap_counts: dict[int, int] = {}
    for overlap in recorded_overlaps:
        recorded_consecutive_overlap_counts[overlap] = (
            recorded_consecutive_overlap_counts.get(overlap, 0) + 1
        )

    return {
        "K_greedy_reset": len(quadruples_reset),
        "K_greedy_no_reset": len(quadruples_no_reset),
        "K_bucket": len(bucket_quadruples),
        "K_disjoint_subseq_reset": len(disjoint_subseq_reset),
        "K_disjoint_subseq_no_reset": len(disjoint_subseq_no_reset),
        "recorded_pairwise_disjoint": verify_pairwise_disjoint(quadruples_reset),
        "recorded_consecutive_overlap_max": max(recorded_overlaps) if recorded_overlaps else 0,
        "recorded_consecutive_overlap_counts": recorded_consecutive_overlap_counts,
        "transition_step_count": len(steps),
        "transition_overlap_counts": dict(sorted(transition_overlap_counts.items())),
        "transition_histogram": {
            f"{size_before},{size_after},{overlap}": count
            for (size_before, size_after, overlap), count in sorted(transition_hist.items())
        },
        "no_reset_consecutive_overlap_counts": dict(sorted(no_reset_overlap_counts.items())),
        "build_count": max((step.build_index for step in steps), default=0),
    }


def extract_eabc_stream(
    prime_count: int = 2000,
    *,
    primes: Sequence[int] | None = None,
) -> list[int]:
    """Return EABC-class primes from the first *prime_count* primes in scan order."""
    if prime_count < 1:
        raise ValueError("prime_count must be >= 1")

    source = list(primes) if primes is not None else first_n_primes(prime_count)
    if primes is None and len(source) != prime_count:
        raise ValueError(f"expected {prime_count} primes, got {len(source)}")

    return [q for q in source if is_eabc_class_prime(q)]


def build_eabc_channel_buckets(
    eabc_stream: Sequence[int],
) -> dict[EABCChannel, list[int]]:
    """Split an EABC prime stream into four rising channel lists."""
    buckets: dict[EABCChannel, list[int]] = {channel: [] for channel in EABC_CHANNEL_ORDER}
    for prime in eabc_stream:
        buckets[prime_eabc_channel(prime)].append(prime)
    return buckets


def _quadruple_from_primes(index: int, primes: Sequence[int]) -> EABCRisingQuadruple:
    ordered = tuple(sorted(primes))
    channels = tuple(prime_eabc_channel(p) for p in ordered)
    gaps = consecutive_gaps(ordered)
    return EABCRisingQuadruple(
        index=index,
        primes=ordered,  # type: ignore[arg-type]
        channels=channels,  # type: ignore[arg-type]
        span=ordered[3] - ordered[0],
        gaps=gaps,
        canonical=is_canonical_prime_quadruplet(ordered),
    )


def partition_eabc_quadruples_by_channels(
    prime_count: int = 2000,
    *,
    primes: Sequence[int] | None = None,
) -> tuple[list[EABCRisingQuadruple], list[int], list[int]]:
    """
    Maximal disjoint EABC partition via synchronized channel buckets.

    Algorithm (see ``docs/eabc_partition.md`` for the formal definition and
    maximality theorem):

    1. Build EABC stream ``S`` from the first *prime_count* primes.
    2. Split ``S`` into rising channel lists ``L_E, L_A, L_B, L_C`` via ``κ``.
    3. Let ``K = min_c |L_c|``.  For each slot ``i`` in ``0 .. K-1``, record
       ``Q_i = {L_E[i], L_A[i], L_B[i], L_C[i]}`` as one quadruple.
    4. Collect surplus ``L_c[K..]`` into sorted remainder ``R``.

    Properties: every quadruple is EABC-complete; quadruples are pairwise
    disjoint; ``K`` equals the theoretical maximum for any such partition of
    ``S``; ``used ∪ R = S`` and ``used ∩ R = ∅``.

    Returns ``(quadruples, eabc_stream, remainder)``.
    """
    eabc_stream = extract_eabc_stream(prime_count, primes=primes)
    buckets = build_eabc_channel_buckets(eabc_stream)
    bucket_lengths = [len(buckets[channel]) for channel in EABC_CHANNEL_ORDER]
    quadruple_count = min(bucket_lengths)

    quadruples: list[EABCRisingQuadruple] = []
    for slot in range(quadruple_count):
        members = [buckets[channel][slot] for channel in EABC_CHANNEL_ORDER]
        quadruples.append(_quadruple_from_primes(slot + 1, members))

    remainder: list[int] = []
    for channel in EABC_CHANNEL_ORDER:
        remainder.extend(buckets[channel][quadruple_count:])
    remainder.sort()

    return quadruples, eabc_stream, remainder


def summarize_partition(
    quadruples: Sequence[EABCRisingQuadruple],
    eabc_stream: Sequence[int],
    remainder: Sequence[int],
) -> dict[str, object]:
    """Coverage statistics for a channel-bucket partition."""
    used = {prime for row in quadruples for prime in row.primes}
    stream_set = set(eabc_stream)
    greedy_quadruples, _ = collect_eabc_rising_quadruples(primes=eabc_stream)
    greedy_used = {prime for row in greedy_quadruples for prime in row.primes}
    bucket_lengths = build_eabc_channel_buckets(eabc_stream)
    channel_counts = {channel.value: len(bucket_lengths[channel]) for channel in EABC_CHANNEL_ORDER}
    theoretical_max = min(channel_counts.values()) if channel_counts else 0
    naive_floor = len(eabc_stream) // 4

    bucket_count = len(quadruples)
    greedy_count = len(greedy_quadruples)
    stream_len = len(eabc_stream)
    coverage = len(used) / stream_len if stream_len else 0.0
    greedy_efficiency = greedy_count / bucket_count if bucket_count else 0.0
    greedy_loss = 1.0 - greedy_efficiency

    return {
        "m": stream_len,
        "eabc_stream_count": stream_len,
        "K_bucket": bucket_count,
        "quadruple_count": bucket_count,
        "K_greedy": greedy_count,
        "used_prime_count": len(used),
        "R_bucket": len(remainder),
        "remainder_count": len(remainder),
        "Coverage_bucket": coverage,
        "coverage_ratio": coverage,
        "GreedyEfficiency": greedy_efficiency,
        "GreedyLoss": greedy_loss,
        "channel_counts": channel_counts,
        "theoretical_max_quadruples": theoretical_max,
        "naive_floor_n_div_4": naive_floor,
        "stream_remainder_mod_4": stream_len % 4,
        "all_eabc_complete": all(verify_quadruple_eabc_completeness(q) for q in quadruples),
        "disjoint": len(used) == 4 * bucket_count,
        "covers_stream": used | set(remainder) == stream_set and used & set(remainder) == set(),
        "greedy_quadruple_count": greedy_count,
        "greedy_used_prime_count": len(greedy_used),
        "greedy_coverage_ratio": len(greedy_used) / stream_len if stream_len else 0.0,
    }
