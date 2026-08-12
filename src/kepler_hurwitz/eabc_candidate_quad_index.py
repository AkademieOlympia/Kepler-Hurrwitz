"""
Kanonische Nummerierung Φ(Q) von EABC-Kandidaten-Vierlingen
zwischen aufeinanderfolgenden Primzahlvierlingen.

Governance (G-007): rein kombinatorisch-arithmetisches Koordinatensystem
auf dem Sieb — keine Primzahleigenschaft, kein Diversitäts-Claim.

Intervall zwischen V_k=(p_k,…,p_k+8) und V_{k+1}:
    I_k = (p_k + 8, p_{k+1})

EABC-Vierling Q=(x1<x2<x3<x4) in I_k:
  - alle xi ≡ R_30 (mod 30), gcd(xi,6)=1
  - κ-Farben = {E,A,B,C} je genau einmal
  - alle xi im selben 30er-Block (Musterstufe)

Index (block-aligned, for Monotonie in x1):
    m(Q) = ⌊x1/30⌋ - ⌊(p_k+8)/30⌋
    r(Q) ∈ {1,…,K}  lex. Rang des Restmusters im Block
    I_local(Q) = K·m(Q) + r(Q)
    Φ_lattice(Q) = sum_{i<k} Capacity_i + I_local(Q)

Note: die naive Formel ⌊(x1-(p_k+8))/30⌋ mischt zwei 30er-Blöcke
in dieselbe m-Klasse und verletzt die Monotonie in x1.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations, product
from typing import Iterator, Sequence

from kepler_hurwitz.b016_quadruplet_greedy_sign import eabc_color
from kepler_hurwitz.primvierling import (
    build_prime_quadruplet,
    is_prime_quadruplet,
)

__all__ = [
    "R30",
    "K_PATTERNS",
    "PATTERN_RANK",
    "PATTERNS",
    "ALL_PERMUTATIONS_S4",
    "REALIZABLE_PERMUTATIONS",
    "BLOCKED_PERMUTATIONS",
    "COLOR_TAU",
    "EabcCandidateQ",
    "permutation_of",
    "color_tau",
    "tau_permutation",
    "shift_Q_by_30",
    "audit_pi_shift30_color_tau",
    "classification_triple",
    "pattern_permutation_table",
    "local_index",
    "global_phi",
    "enumerate_prime_quad_anchors",
    "enumerate_candidates_in_interval",
    "index_all_between_quads",
]

# Residues coprime to 30 (= to 2 and 3)
R30: tuple[int, ...] = (1, 7, 11, 13, 17, 19, 23, 29)

# Residues by EABC color within one 30-block
_COLOR_RESIDUES: dict[str, tuple[int, ...]] = {
    "E": (1, 13),
    "A": (17, 29),
    "B": (7, 19),
    "C": (11, 23),
}


def _build_patterns() -> tuple[tuple[int, ...], ...]:
    """
    All ways to pick one residue per color; store as sorted 4-tuples.
    Lexicographic order ⇒ ranks 1..K.
    """
    combos: list[tuple[int, ...]] = []
    for er, ar, br, cr in product(
        _COLOR_RESIDUES["E"],
        _COLOR_RESIDUES["A"],
        _COLOR_RESIDUES["B"],
        _COLOR_RESIDUES["C"],
    ):
        combos.append(tuple(sorted((er, ar, br, cr))))
    return tuple(sorted(set(combos)))


PATTERNS: tuple[tuple[int, ...], ...] = _build_patterns()
K_PATTERNS: int = len(PATTERNS)
PATTERN_RANK: dict[tuple[int, ...], int] = {
    pat: i + 1 for i, pat in enumerate(PATTERNS)
}

ALL_PERMUTATIONS_S4: frozenset[str] = frozenset(
    "".join(p) for p in permutations("EABC")
)


def permutation_of(Q: Sequence[int]) -> str:
    """
    Π(Q) = (κ(x1),…,κ(x4)) as a length-4 word over {E,A,B,C}.

    Must be computed from absolute values: color of residue r∈R_30
    depends on block parity because 30 ≡ 6 (mod 12).

    Order observable on the 4-config (classification triple
    (Φ_lattice, r, Π)) — not a fifth algebraic EABC object.
    """
    cols = [eabc_color(x) for x in Q]
    if any(c is None for c in cols) or len(set(cols)) != 4:
        raise ValueError(f"Q is not a full EABC color permutation: {Q}")
    return "".join(cols)  # type: ignore[arg-type]


# Color involution τ = (E,B)(A,C) induced by +30 ≡ +6 (mod 12).
COLOR_TAU: dict[str, str] = {"E": "B", "B": "E", "A": "C", "C": "A"}


def color_tau(c: str) -> str:
    """τ on a single EABC color: E↔B, A↔C."""
    if c not in COLOR_TAU:
        raise ValueError(f"unknown color {c!r}")
    return COLOR_TAU[c]


def tau_permutation(word: str) -> str:
    """Coordinatewise τ on a length-4 color word."""
    if len(word) != 4 or any(ch not in COLOR_TAU for ch in word):
        raise ValueError(f"not a color word: {word!r}")
    return "".join(color_tau(ch) for ch in word)


def shift_Q_by_30(Q: Sequence[int]) -> tuple[int, ...]:
    """Coordinatewise Q ↦ Q+30 (30-block shift)."""
    return tuple(x + 30 for x in Q)


def audit_pi_shift30_color_tau(
    *,
    block_bases: Sequence[int] = (0, 30, 60, 90),
) -> dict[str, object]:
    """
    [B] Finite-lattice audit of Π(Q+30)=τ(Π(Q)) on all K=16 patterns.

    Also checks τ(R)=R and τ(B)=B on the K=16 realizable/blocked sets.
    Does **not** claim |R|=14 for all K, D_Π-density, or Collatz.
    Lean [A] counterpart: `KeplerHurwitz/EABC/Permutation30Block.lean`.
    """
    failures: list[dict[str, object]] = []
    checked = 0
    for pat in PATTERNS:
        for base in block_bases:
            Q = tuple(base + r for r in pat)
            pi = permutation_of(Q)
            pi_shift = permutation_of(shift_Q_by_30(Q))
            expected = tau_permutation(pi)
            checked += 1
            if pi_shift != expected:
                failures.append(
                    {
                        "Q": Q,
                        "Pi": pi,
                        "Pi_shift30": pi_shift,
                        "tau_Pi": expected,
                    }
                )
    tau_R = {tau_permutation(w) for w in REALIZABLE_PERMUTATIONS}
    tau_B = {tau_permutation(w) for w in BLOCKED_PERMUTATIONS}
    return {
        "claim_level": "[B]",
        "checked_pairs": checked,
        "failures": failures,
        "pi_shift30_equals_tau": len(failures) == 0,
        "realizable_card": len(REALIZABLE_PERMUTATIONS),
        "blocked_card": len(BLOCKED_PERMUTATIONS),
        "tau_closes_realizable": tau_R == set(REALIZABLE_PERMUTATIONS),
        "tau_closes_blocked": tau_B == set(BLOCKED_PERMUTATIONS),
        "note": (
            "|R|=14 / |B|=10 is a finite K=16 lattice finding; "
            "not universal in K. C-H10 (D_Π / stabilization) remains open."
        ),
    }


def _pi_for_pattern_at_base(pattern: tuple[int, ...], block_base: int) -> str:
    return permutation_of(tuple(block_base + r for r in pattern))


def pattern_permutation_table() -> dict[tuple[int, ...], dict[str, str]]:
    """
    For each of the K=16 residue patterns: Π on even vs odd 30-blocks.

    Returns {pattern: {"even": Π, "odd": Π}}.
    """
    table: dict[tuple[int, ...], dict[str, str]] = {}
    for pat in PATTERNS:
        table[pat] = {
            "even": _pi_for_pattern_at_base(pat, 0),
            "odd": _pi_for_pattern_at_base(pat, 30),
        }
    return table


def _realizable_permutations() -> frozenset[str]:
    found: set[str] = set()
    for pat in PATTERNS:
        for k in range(2):
            found.add(_pi_for_pattern_at_base(pat, 30 * k))
    return frozenset(found)


REALIZABLE_PERMUTATIONS: frozenset[str] = _realizable_permutations()
BLOCKED_PERMUTATIONS: frozenset[str] = ALL_PERMUTATIONS_S4 - REALIZABLE_PERMUTATIONS


@dataclass(frozen=True, slots=True)
class EabcCandidateQ:
    Q: tuple[int, int, int, int]
    k: int  # interval index (1-based over anchor list)
    p_k: int
    p_next: int
    m: int
    r: int
    I_local: int
    Phi: int
    pattern: tuple[int, ...]
    color_word: str  # synonym of Π(Q); kept for compatibility

    @property
    def Pi(self) -> str:
        """Permutationsklasse Π(Q) ∈ S₄ (as color word)."""
        return self.color_word

    @property
    def block_parity(self) -> int:
        return (self.Q[0] // 30) % 2


def classification_triple(c: EabcCandidateQ) -> tuple[int, int, str]:
    """(Φ_lattice, r, Π) — fine structure for AP-1 plugins."""
    return (c.Phi, c.r, c.Pi)


def _residues_mod30(Q: Sequence[int]) -> tuple[int, ...]:
    return tuple(sorted(x % 30 for x in Q))


def _same_30_block(Q: Sequence[int]) -> bool:
    bases = {x - (x % 30) for x in Q}
    return len(bases) == 1


def _is_eabc_full(Q: Sequence[int]) -> bool:
    cols = [eabc_color(x) for x in Q]
    if any(c is None for c in cols):
        return False
    return set(cols) == {"E", "A", "B", "C"} and len(cols) == 4


def local_index(Q: Sequence[int], p_k: int) -> tuple[int, int, int, tuple[int, ...]]:
    """
    Return (m, r, I_local, pattern) for Q relative to anchor p_k.

    Raises ValueError if Q is not a same-block full-EABC candidate.
    """
    if len(Q) != 4 or list(Q) != sorted(Q) or len(set(Q)) != 4:
        raise ValueError("Q must be strictly increasing 4-tuple")
    if not _same_30_block(Q) or not _is_eabc_full(Q):
        raise ValueError("Q must be same 30-block with colors {E,A,B,C}")
    pattern = _residues_mod30(Q)
    if pattern not in PATTERN_RANK:
        raise ValueError(f"unknown pattern {pattern}")
    # Block-aligned relative index (see module docstring).
    m = (Q[0] // 30) - ((p_k + 8) // 30)
    if m < 0:
        raise ValueError("Q not to the right of V_k")
    r = PATTERN_RANK[pattern]
    return m, r, K_PATTERNS * m + r, pattern


def enumerate_prime_quad_anchors(limit: int) -> list[int]:
    """
    Non-overlapping standard-candle anchors: p=5 and p≡11 (mod 30),
    with full Q(p) prime, p+8 ≤ limit, and p > previous_end (no overlap).

    Note: (11,13,17,19) is a prime quadruplet but overlaps Q(5); it is skipped
    so that I_k = (p_k+8, p_{k+1}) is a nonempty open gap when a next candle exists.
    """
    anchors: list[int] = []
    prev_end = 0
    for p in [5] + list(range(11, limit - 7, 30)):
        q = build_prime_quadruplet(p)
        if q[-1] > limit:
            break
        if not is_prime_quadruplet(q):
            continue
        if p <= prev_end:
            continue
        anchors.append(p)
        prev_end = q[-1]
    return anchors


def _candidates_in_block(block_base: int, lo: int, hi: int) -> Iterator[tuple[int, ...]]:
    """Yield all EABC patterns in [block_base, block_base+30) ∩ (lo, hi)."""
    for pattern in PATTERNS:
        xs = tuple(block_base + r for r in pattern)
        if xs[0] <= lo or xs[-1] >= hi:
            continue
        if not all(lo < x < hi for x in xs):
            continue
        yield xs


def enumerate_candidates_in_interval(
    p_k: int,
    p_next: int,
    *,
    k: int = 1,
    phi_offset: int = 0,
) -> list[EabcCandidateQ]:
    """
    All EABC candidate Q in I_k = (p_k+8, p_next), indexed by I_local and Φ.
    """
    lo, hi = p_k + 8, p_next
    if hi - lo <= 1:
        return []
    out: list[EabcCandidateQ] = []
    # blocks that can intersect (lo, hi)
    first_base = ((lo + 1) // 30) * 30
    last_base = ((hi - 1) // 30) * 30
    for base in range(first_base, last_base + 1, 30):
        for Q in _candidates_in_block(base, lo, hi):
            m, r, I_loc, pattern = local_index(Q, p_k)
            pi = permutation_of(Q)
            out.append(
                EabcCandidateQ(
                    Q=Q,  # type: ignore[arg-type]
                    k=k,
                    p_k=p_k,
                    p_next=p_next,
                    m=m,
                    r=r,
                    I_local=I_loc,
                    Phi=phi_offset + I_loc,
                    pattern=pattern,
                    color_word=pi,
                )
            )
    out.sort(key=lambda c: (c.I_local, c.Q))
    return out


def global_phi(
    records: Sequence[EabcCandidateQ],
) -> list[EabcCandidateQ]:
    """Re-stamp Φ as dense 1..N in global monotonic order (optional normalize)."""
    ordered = sorted(records, key=lambda c: (c.k, c.I_local, c.Q))
    return [
        EabcCandidateQ(
            Q=c.Q,
            k=c.k,
            p_k=c.p_k,
            p_next=c.p_next,
            m=c.m,
            r=c.r,
            I_local=c.I_local,
            Phi=i,
            pattern=c.pattern,
            color_word=c.color_word,
        )
        for i, c in enumerate(ordered, start=1)
    ]


def index_all_between_quads(limit: int) -> list[EabcCandidateQ]:
    """
    Φ_lattice(Q) over gaps between consecutive standard-candle prime quadruplets.

    Offset uses interval *capacity* (max I_local), not raw count M_k:
    I_local = K·m+r is sparse near boundaries, so sum M_i + I_local
    would collide. Capacity-offset keeps Φ injective for the lattice formula.

    Dense enumeration 1…N is available via ``global_phi``.
    """
    anchors = enumerate_prime_quad_anchors(limit + 30 * 50)
    usable = [p for p in anchors if p + 8 < limit]
    out: list[EabcCandidateQ] = []
    phi_off = 0
    for k, p_k in enumerate(usable, start=1):
        nxt = next((p for p in anchors if p > p_k), None)
        if nxt is None:
            break
        chunk = enumerate_candidates_in_interval(
            p_k, nxt, k=k, phi_offset=phi_off
        )
        out.extend(chunk)
        phi_off += interval_capacity_Mk(p_k, nxt)
    return out


def interval_capacity_Mk(p_k: int, p_next: int) -> int:
    """
    Theoretical max I_local in I_k (full lattice), for Φ-offset bookkeeping.

    m_max = floor((p_next - 1 - (p_k+8) - 0) / 30) roughly from largest
    possible x1 < p_next; use last admissible pattern start.
    """
    lo, hi = p_k + 8, p_next
    if hi - lo <= 1:
        return 0
    # largest possible x1 in some pattern entirely inside (lo,hi)
    max_I = 0
    first_base = ((lo + 1) // 30) * 30
    last_base = ((hi - 1) // 30) * 30
    for base in range(first_base, last_base + 1, 30):
        for Q in _candidates_in_block(base, lo, hi):
            _, _, I_loc, _ = local_index(Q, p_k)
            if I_loc > max_I:
                max_I = I_loc
    return max_I
