"""
Primvierling C4 channel rotation, Δθ, and Φ_θ type labels.

Epistemic layers:
  B — congruence: for true prime quadruplets p>3, residue words are rotations of S;
      invariant transition word (+1,+1,+1); pure phase shift π; Φ_θ type map.
  C — terminology: transition word / Gaussian type word (inert / zerfallend).
  E — finite enumeration is an implementation regression test, not a proof.

Nomenclature: canonical label is ``inert`` (first-use note in docs: German „träge“).
Complement type: ``zerfallend``. Illustration ≠ physics; B3 remains blocked.

See docs/theory/primvierling_c4_rotation.md
and docs/energiedoku_exports/eabc_inert_c4_phase_shift_2026_07_17.md.
"""

from __future__ import annotations

from typing import Literal

from kepler_hurwitz.primvierling import Primvierling, is_prime_quadruplet

# Fixed order of EABC residues on the C4 state circle.
S_CYCLE: tuple[int, int, int, int] = (11, 1, 5, 7)
PHI: dict[int, int] = {11: 0, 1: 1, 5: 2, 7: 3}

WORD_P_EQ_11: tuple[int, int, int, int] = (11, 1, 5, 7)
WORD_P_EQ_5: tuple[int, int, int, int] = (5, 7, 11, 1)

SUCCESSIVE_GAPS: tuple[int, int, int] = (2, 4, 2)

# Gaussian types under Φ_θ (docs first-use: inert initially „träge“).
GaussianType = Literal["inert", "zerfallend"]
TYPE_BY_RESIDUE: dict[int, GaussianType] = {
    11: "inert",
    1: "zerfallend",
    5: "zerfallend",
    7: "inert",
}
TYPE_WORD_P_EQ_11: tuple[GaussianType, GaussianType, GaussianType, GaussianType] = (
    "inert",
    "zerfallend",
    "zerfallend",
    "inert",
)
TYPE_WORD_P_EQ_5: tuple[GaussianType, GaussianType, GaussianType, GaussianType] = (
    "zerfallend",
    "inert",
    "inert",
    "zerfallend",
)

ChannelKind = Literal["p_eq_11", "p_eq_5", "exception_q5", "invalid"]

__all__ = [
    "PHI",
    "S_CYCLE",
    "SUCCESSIVE_GAPS",
    "TYPE_BY_RESIDUE",
    "TYPE_WORD_P_EQ_11",
    "TYPE_WORD_P_EQ_5",
    "WORD_P_EQ_11",
    "WORD_P_EQ_5",
    "channel_kind",
    "delta_theta",
    "expected_type_word",
    "expected_word",
    "gaussian_type",
    "phi_theta",
    "residue_word",
    "successive_delta_theta",
    "type_word",
    "verify_quadruplet_c4",
]


def residue_word(v: Primvierling) -> tuple[int, int, int, int]:
    """Transition word w(Q) = (q_i mod 12) for the four Vierlingskomponenten."""
    return tuple(q % 12 for q in v)  # type: ignore[return-value]


def delta_theta(r: int, r_next: int) -> int:
    """
    Discrete rotation increment on C4 in units of π/2.

    Δθ(r, r') = (φ(r') - φ(r)) mod 4.
    """
    if r not in PHI or r_next not in PHI:
        raise ValueError(f"residues must lie in S={S_CYCLE}, got {r}, {r_next}")
    return (PHI[r_next] - PHI[r]) % 4


def successive_delta_theta(v: Primvierling) -> tuple[int, int, int]:
    """Δθ along the three successive edges of Q(p)."""
    word = residue_word(v)
    return (
        delta_theta(word[0], word[1]),
        delta_theta(word[1], word[2]),
        delta_theta(word[2], word[3]),
    )


def phi_theta(theta_index: int) -> GaussianType:
    """
    Φ_θ on C4 angle indices {0,1,2,3} ↔ {0, π/2, π, 3π/2}.

    Φ_θ(0) = Φ_θ(3π/2) = inert; Φ_θ(π/2) = Φ_θ(π) = zerfallend.
    """
    if theta_index not in (0, 1, 2, 3):
        raise ValueError(f"theta_index must be in {{0,1,2,3}}, got {theta_index}")
    return "inert" if theta_index in (0, 3) else "zerfallend"


def gaussian_type(r: int) -> GaussianType:
    """Gaussian type of an EABC residue on S via Φ_θ ∘ φ."""
    if r not in TYPE_BY_RESIDUE:
        raise ValueError(f"residue must lie in S={S_CYCLE}, got {r}")
    return TYPE_BY_RESIDUE[r]


def type_word(v: Primvierling) -> tuple[GaussianType, GaussianType, GaussianType, GaussianType]:
    """Gaussian type word of Q(p) under Φ_θ."""
    word = residue_word(v)
    return (
        gaussian_type(word[0]),
        gaussian_type(word[1]),
        gaussian_type(word[2]),
        gaussian_type(word[3]),
    )


def channel_kind(v: Primvierling) -> ChannelKind:
    """Classify a candidate by start residue; Q(5) is the documented exception."""
    if not is_prime_quadruplet(v):
        return "invalid"
    p = v[0]
    if v == (5, 7, 11, 13):
        return "exception_q5"
    if p % 12 == 11:
        return "p_eq_11"
    if p % 12 == 5:
        return "p_eq_5"
    return "invalid"


def expected_word(kind: ChannelKind) -> tuple[int, int, int, int] | None:
    if kind == "p_eq_11":
        return WORD_P_EQ_11
    if kind in ("p_eq_5", "exception_q5"):
        return WORD_P_EQ_5
    return None


def expected_type_word(
    kind: ChannelKind,
) -> tuple[GaussianType, GaussianType, GaussianType, GaussianType] | None:
    """Expected Gaussian type word; the two regular channels are algebraically complementary."""
    if kind == "p_eq_11":
        return TYPE_WORD_P_EQ_11
    if kind in ("p_eq_5", "exception_q5"):
        return TYPE_WORD_P_EQ_5
    return None


def verify_quadruplet_c4(v: Primvierling) -> dict[str, object]:
    """
    Check congruence expectations for one quadruplet.

    Returns a structured report for regression aggregation.
    """
    kind = channel_kind(v)
    word = residue_word(v)
    expected = expected_word(kind)
    expected_types = expected_type_word(kind)
    gaps = tuple(v[i + 1] - v[i] for i in range(3))
    types = type_word(v) if all(q % 12 in PHI for q in v) else None
    ok_kind = kind != "invalid"
    ok_word = expected is not None and word == expected
    ok_gaps = gaps == SUCCESSIVE_GAPS
    ok_types = expected_types is not None and types == expected_types
    deltas: tuple[int, int, int] | None = None
    ok_delta = False
    if ok_word:
        deltas = successive_delta_theta(v)
        ok_delta = deltas == (1, 1, 1)
    return {
        "v": v,
        "kind": kind,
        "word": word,
        "expected_word": expected,
        "type_word": types,
        "expected_type_word": expected_types,
        "gaps": gaps,
        "delta_theta": deltas,
        "ok": ok_kind and ok_word and ok_gaps and ok_delta and ok_types,
        "ok_kind": ok_kind,
        "ok_word": ok_word,
        "ok_gaps": ok_gaps,
        "ok_delta": ok_delta,
        "ok_types": ok_types,
    }
