"""
Canonical e³ decomposition for n = e * a.

[B] diagnostic — pure arithmetic identity n = q * e³ + r * e with
q = a // e² and r = a % e². Does not replace oddCore/Syracuse, does not
prove Collatz, and does not strengthen the Collatz conjecture.

Lemma 2 product split: when r = b * c, n = q * e³ + b * c * e.
Fine-structure / hyperfine analogy is [C] heuristic bridge only — not
physics identity, not Collatz proof, not EABC physical claim.
"""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Any, Literal, Sequence

E3_DECOMPOSITION_TAG = "[B]"
E3_PRODUCT_ANALOGY_TAG = "[C]"

CaseType = Literal[
    "valid_product_split",
    "valid_commutative_multiplet",
    "invalid_rest_product",
    "invalid_parity",
    "invalid_e",
]

EABC_GEOM_DIAGONAL = 24.0
EABC_CHANNEL_WEIGHTS: dict[int, int] = {1: 1, 5: 5, 7: 7, 11: 11}

E3_EABC_GOVERNANCE_NOTE = (
    "Der Vergleich konstruiert aus der E³-Split-Form eine normierte Richtung und "
    "kombiniert diese mit einem unabhängig vorgegebenen EABC-Kanalgewicht. Er prüft "
    "ausschließlich die interne Konsistenz dieses diagnostischen Rang-1-Modells. "
    "Daraus folgt weder eine Gleichheit der zugrunde liegenden Theorien noch eine "
    "Aussage über Collatz-Dynamik, oddCore, Syracuse oder prime_norm_full_restoration."
)

__all__ = [
    "E3_DECOMPOSITION_TAG",
    "E3_PRODUCT_ANALOGY_TAG",
    "EABC_CHANNEL_WEIGHTS",
    "EABC_GEOM_DIAGONAL",
    "abc_split_decomposition",
    "analyze_e3_commutative_multiplet",
    "analyze_e3_decomposition",
    "analyze_e3_with_product_split",
    "commutation_check",
    "compare_e3_eabc_anisotropy",
    "batch_e3_eabc_anisotropy_comparison",
    "e3_decompose",
    "e3_spectral_diagnostic",
    "E3_EABC_GOVERNANCE_NOTE",
    "export_e3_eabc_anisotropy_comparison_json",
    "eabc_channel_weight_from_factor",
    "eabc_defect_tensor",
    "eabc_retract_defect",
    "eabc_tensor_spectral_summary",
    "symmetric_operators",
    "verify_abc_split",
    "verify_e3_identity",
]


def _validate_positive_e(e: int) -> None:
    if e <= 0:
        raise ValueError("e must be positive")


def e3_decompose(a: int, e: int) -> tuple[int, int, int]:
    """
    Return ``(q, r, n)`` for the canonical e³ decomposition of ``n = e * a``.

    ``q = a // e²``, ``r = a % e²``, and ``n = q * e³ + r * e``.
    """
    _validate_positive_e(e)
    e2 = e * e
    q = a // e2
    r = a % e2
    n = e * a
    return q, r, n


def verify_e3_identity(a: int, e: int) -> bool:
    """Check whether ``e * a == q * e³ + r * e`` for the canonical ``(q, r)``."""
    q, r, n = e3_decompose(a, e)
    return n == q * (e**3) + r * e


def analyze_e3_decomposition(a: int, e: int) -> dict[str, Any]:
    """
    Analyze the e³ decomposition of ``n = e * a``.

    Returns quotient ``q``, remainder ``r``, product ``n``, and identity check.
    """
    _validate_positive_e(e)
    q, r, n = e3_decompose(a, e)
    e2 = e * e
    e3 = e**3
    reconstructed = q * e3 + r * e
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "a": a,
        "e": e,
        "e2": e2,
        "e3": e3,
        "q": q,
        "r": r,
        "n": n,
        "identity": f"n = q*e³ + r*e = {q}*{e3} + {r}*{e} = {reconstructed}",
        "identity_holds": reconstructed == n,
        "q_is_zero": q == 0,
        "r_below_e2": 0 <= r < e2,
    }


def abc_split_decomposition(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """
    Return the Lemma-2 split ``n = q * e³ + b * c * e`` when ``r = b * c``.

    ``e * a = q * e³ + r * e`` with ``a = q * e² + r``; if ``r = b * c`` then
    ``n = q * e³ + b * c * e``.
    """
    _validate_positive_e(e)
    q, r, n = e3_decompose(a, e)
    e3 = e**3
    product = b * c
    split_n = q * e3 + product * e
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "a": a,
        "e": e,
        "b": b,
        "c": c,
        "q": q,
        "r": r,
        "n": n,
        "product": product,
        "rest_matches_product": r == product,
        "split_identity": f"n = q*e³ + b*c*e = {q}*{e3} + {b}*{c}*{e} = {split_n}",
        "split_holds": split_n == n,
        "product_below_e2": product < e * e,
    }


def verify_abc_split(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """Check ``r = b * c`` and return ``n``, ``q``, and the product-split form."""
    _validate_positive_e(e)
    q, r, n = e3_decompose(a, e)
    product = b * c
    e2 = e * e
    e3 = e**3
    rest_matches = r == product
    split_holds = n == q * e3 + product * e
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "valid": rest_matches and split_holds,
        "a": a,
        "e": e,
        "b": b,
        "c": c,
        "q": q,
        "r": r,
        "n": n,
        "product": product,
        "rest_matches_product": rest_matches,
        "split_holds": split_holds,
        "product_below_e2": product < e2 if rest_matches else None,
        "split_form": f"{q}*e³ + {b}*{c}*e",
        "analogy_governance": E3_PRODUCT_ANALOGY_TAG,
        "analogy_note": (
            "Fine-structure / hyperfine perturbation analogy is [C] heuristic "
            "bridge only — not physics identity, not Collatz proof."
        ),
    }


def analyze_e3_with_product_split(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """
    Analyze Lemma-1 decomposition together with a candidate product split ``r = b * c``.
    """
    base = analyze_e3_decomposition(a, e)
    split = abc_split_decomposition(a, e, b, c)
    product = b * c

    if e <= 0:
        case_type: CaseType = "invalid_e"
    elif base["r"] != product:
        case_type = "invalid_rest_product"
    else:
        case_type = "valid_product_split"

    return {
        **base,
        "case_type": case_type,
        "b": b,
        "c": c,
        "product": product,
        "rest_matches_product": split["rest_matches_product"],
        "split_holds": split["split_holds"],
        "product_below_e2": split["product_below_e2"],
        "split_identity": split["split_identity"],
        "analogy_governance": E3_PRODUCT_ANALOGY_TAG,
        "analogy_note": (
            "Fine-structure / hyperfine perturbation analogy is [C] heuristic "
            "bridge only — not physics identity, not Collatz proof."
        ),
    }


def commutation_check(b: int, c: int) -> dict[str, Any]:
    """
    Check the Nat-ring commutator ``[b, c] = b*c - c*b``.

    For integers this is always zero; the diagnostic records the identity for
    downstream symmetric-operator analysis. Quaternion ``[b,c] = 2*(v_b x v_c)``
    is **[C]** interpretive language only — not verified physics.
    """
    commutator = b * c - c * b
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "b": b,
        "c": c,
        "commutator": commutator,
        "commutes": commutator == 0,
        "analogy_governance": E3_PRODUCT_ANALOGY_TAG,
        "quaternion_note": (
            "In quaternion embedding, [b,c]=0 implies collinear vector parts "
            "— [C] heuristic only, not physics identity."
        ),
    }


def symmetric_operators(b: int, c: int) -> tuple[int, int]:
    """
    Return ``(S_+, S_-)`` with ``S_+ = (b+c)//2``, ``S_- = abs(b-c)//2``.

    Requires equal parity (``(b+c) % 2 == 0``) for exact ``b*c = S_+^2 - S_-^2``.
    """
    if (b + c) % 2 != 0:
        raise ValueError("b and c must have equal parity for exact symmetric split")
    return (b + c) // 2, abs(b - c) // 2


def eabc_channel_weight_from_factor(e: int) -> int | None:
    """
    Map the outer factor ``e`` in ``n = e * a`` to EABC defect weight ``w_p``.

    Convention (E-053): invertible mod-12 residues ``1, 5, 7, 11`` map to
    ``w_E=1``, ``w_A=5``, ``w_B=7``, ``w_C=11``. Factors ``e <= 3`` or other
    residues return ``None`` (no EABC channel assignment).
    """
    if e <= 3:
        return None
    return EABC_CHANNEL_WEIGHTS.get(e % 12)


def _coefficient_unit_direction(q: int, bc: int) -> tuple[float, float, float]:
    """Unit direction for odd e-power coefficients ``(q, b*c, 1)``."""
    norm = math.sqrt(float(q * q + bc * bc + 1))
    return (q / norm, bc / norm, 1.0 / norm)


def _outer_product(v: tuple[float, float, float]) -> list[list[float]]:
    return [[v[i] * v[j] for j in range(3)] for i in range(3)]


def eabc_defect_tensor(
    w_p: float,
    direction: tuple[float, float, float],
    *,
    geom_diagonal: float = EABC_GEOM_DIAGONAL,
) -> list[list[float]]:
    """
    Build ``M_eff = geom_diagonal * I_3 + w_p * v v^T`` with unit ``v``.

    Matches the rank-1 defect model in ``eabc_renormalisierungsprogramm.md``;
    does not use the full 12-point shell sum ``M(σ)``.
    """
    outer = _outer_product(direction)
    return [
        [
            geom_diagonal * (1 if i == j else 0) + w_p * outer[i][j]
            for j in range(3)
        ]
        for i in range(3)
    ]


def eabc_retract_defect(
    w_p: float,
    direction: tuple[float, float, float],
    *,
    geom_diagonal: float = EABC_GEOM_DIAGONAL,
    matrix: list[list[float]] | None = None,
) -> list[list[float]]:
    """
    Explicit EABC retraction ``R*_EABC(M_eff, v, w_p) = M_eff - w_p v v^T``.

    For ``M_eff = geom_diagonal * I_3 + w_p v v^T`` with unit ``v``, this yields
    ``geom_diagonal * I_3`` and ``Δ(R*_EABC(M_eff)) = 0``.
    """
    m_eff = matrix if matrix is not None else eabc_defect_tensor(
        w_p, direction, geom_diagonal=geom_diagonal
    )
    outer = _outer_product(direction)
    return [
        [m_eff[i][j] - w_p * outer[i][j] for j in range(3)]
        for i in range(3)
    ]


def eabc_tensor_spectral_summary(
    matrix: list[list[float]],
    *,
    defect_rank: int | None = None,
    w_p: float | None = None,
    geom_diagonal: float = EABC_GEOM_DIAGONAL,
) -> dict[str, Any]:
    """
    Spectral summary for a symmetric 3×3 tensor.

    Eigenvalues are sorted ascending (``λ_min`` first). For the closed-form
    defect model ``geom_diagonal * I_3 + w_p v v^T`` with unit ``v``, pass
    ``w_p`` to use the analytic spectrum ``[d, d, d + w_p]``.
    """
    if w_p is not None:
        closed = _rank_one_defect_spectrum(w_p, geom_diagonal=geom_diagonal)
        eigenvalues = closed["eigenvalues"]
        if defect_rank is None:
            defect_rank = closed["defect_rank"]
    else:
        eigenvalues = _symmetric_3x3_eigenvalues(matrix)
        if defect_rank is None:
            spread = eigenvalues[-1] - eigenvalues[0]
            defect_rank = 0 if spread < 1e-12 else 1

    trace = sum(matrix[i][i] for i in range(3))
    frobenius_sq = sum(matrix[i][j] * matrix[i][j] for i in range(3) for j in range(3))
    return {
        "eigenvalues": eigenvalues,
        "lambda_min": eigenvalues[0],
        "lambda_max": eigenvalues[-1],
        "anisotropy": eigenvalues[-1] - eigenvalues[0],
        "trace": trace,
        "frobenius_norm": math.sqrt(frobenius_sq),
        "frobenius_sq": frobenius_sq,
        "defect_rank": defect_rank,
    }


def _symmetric_3x3_eigenvalues(matrix: list[list[float]]) -> list[float]:
    """Sorted eigenvalues of a real symmetric 3×3 matrix."""
    diag = matrix[0][0]
    if (
        abs(matrix[0][0] - matrix[1][1]) < 1e-12
        and abs(matrix[1][1] - matrix[2][2]) < 1e-12
        and abs(matrix[0][1]) < 1e-12
        and abs(matrix[0][2]) < 1e-12
        and abs(matrix[1][2]) < 1e-12
    ):
        return [diag, diag, diag]

    a = matrix[0][0]
    b = matrix[0][1]
    c = matrix[0][2]
    d = matrix[1][1]
    e = matrix[1][2]
    f = matrix[2][2]
    m = a + d + f
    p = a * d + a * f + d * f - b * b - c * c - e * e
    q = a * d * f + 2.0 * b * c * e - a * e * e - d * c * c - f * b * b
    p_depressed = p - m * m / 3.0
    q_depressed = 2.0 * m * m * m / 27.0 - m * p / 3.0 + q
    if abs(p_depressed) < 1e-12:
        root = m / 3.0
        return sorted([root, root, root])
    half_q = q_depressed / 2.0
    third_p = p_depressed / 3.0
    discriminant = half_q * half_q + third_p * third_p * third_p
    if discriminant >= 0.0:
        sqrt_disc = math.sqrt(discriminant)
        u = math.copysign(abs(-half_q + sqrt_disc) ** (1.0 / 3.0), -half_q + sqrt_disc)
        v = math.copysign(abs(-half_q - sqrt_disc) ** (1.0 / 3.0), -half_q - sqrt_disc)
        root = u + v - m / 3.0
        return sorted([root, -(u + v) / 2.0 - m / 3.0, -(u + v) / 2.0 - m / 3.0])
    r = math.sqrt(-third_p * third_p * third_p)
    theta = math.acos(max(-1.0, min(1.0, -half_q / r)))
    factor = 2.0 * math.sqrt(-third_p)
    return sorted(
        [
            factor * math.cos(theta / 3.0) - m / 3.0,
            factor * math.cos((theta + 2.0 * math.pi) / 3.0) - m / 3.0,
            factor * math.cos((theta + 4.0 * math.pi) / 3.0) - m / 3.0,
        ]
    )


def _rank_one_defect_spectrum(
    w_p: float,
    *,
    geom_diagonal: float = EABC_GEOM_DIAGONAL,
) -> dict[str, Any]:
    """Closed-form spectrum for ``geom_diagonal * I_3 + w_p v v^T`` with ``||v||=1``."""
    gap = abs(w_p)
    eigenvalues = [geom_diagonal, geom_diagonal, geom_diagonal + w_p]
    trace = 3.0 * geom_diagonal + w_p
    frobenius_sq = (
        3.0 * geom_diagonal * geom_diagonal
        + 2.0 * geom_diagonal * w_p
        + w_p * w_p
    )
    return {
        "eigenvalues": eigenvalues,
        "lambda_min": eigenvalues[0],
        "lambda_max": eigenvalues[-1],
        "anisotropy": gap,
        "spectral_anisotropy_gap": gap,
        "trace": trace,
        "frobenius_norm": math.sqrt(frobenius_sq),
        "frobenius_sq": frobenius_sq,
        "defect_rank": 0 if w_p == 0 else 1,
    }


def _tensor_is_symmetric(matrix: list[list[float]], *, tol: float = 1e-12) -> bool:
    return all(abs(matrix[i][j] - matrix[j][i]) <= tol for i in range(3) for j in range(3))


def _direction_norm(direction: tuple[float, float, float]) -> float:
    return math.sqrt(sum(component * component for component in direction))


def compare_e3_eabc_anisotropy(
    a: int,
    e: int,
    b: int,
    c: int,
    *,
    tol: float = 1e-9,
) -> dict[str, Any]:
    """
    Compare e³ spectral data with the EABC rank-1 defect model at fixed ``n = e * a``.

    **Bridging convention [B]:**

    1. e³ odd-power coefficients ``(q, b*c, 1)`` determine **only** the normalized
       direction ``v = (q, b*c, 1) / sqrt(q² + (b*c)² + 1)``.
    2. The raw profile norm ``‖(q, b*c, 1)‖²`` does **not** determine the defect weight.
    3. Outer factor ``e`` supplies EABC weight ``w_p >= 0`` when
       ``e % 12 ∈ {1,5,7,11}`` (prerequisite: table weights are non-negative).
    4. Effective tensor ``M_eff = 24 I_3 + w_p v v^T``; spectral gap
       ``Δ(M_eff) = |w_p|`` (for ``w_p >= 0``: ``Δ = w_p``).
    5. Retraction ``R*_EABC(M_eff, v, w_p) = M_eff - w_p v v^T = 24 I_3``;
       ``Δ(R*_EABC(M_eff)) = 0``.

    The raw e³ Gram profile energy ``‖(q, b*c, 1)‖²`` is reported separately as
    ``e3_profile_norm_sq``; legacy field ``anisotropy_gap`` aliases it but is **not**
    the spectral eigenvalue gap. Does not prove Collatz or
    ``prime_norm_full_restoration``.
    """
    _validate_positive_e(e)
    spectral = e3_spectral_diagnostic(a, e, b, c)
    q = spectral["q"]
    bc = spectral["coefficients_odd_e"]["e^1"]
    n = spectral["n"]
    w_p = eabc_channel_weight_from_factor(e)
    direction = _coefficient_unit_direction(q, bc)
    direction_norm = _direction_norm(direction)

    normalization = {
        "index_convention": "row-major 3x3 symmetric tensor, Fin 3 style",
        "eigenvalue_sort": "ascending (lambda_min first)",
        "geom_fixpoint": f"{EABC_GEOM_DIAGONAL} * I_3",
        "raw_profile": {"q": q, "bc": bc, "unit": 1},
        "e3_profile_norm_sq": spectral["e3_profile_norm_sq"],
        "defect_direction": {"q": q, "bc": bc, "unit": 1, "normalized": direction},
        "direction_norm": direction_norm,
        "defect_weight_source": "eabc_channel_weight_from_factor(e) only",
        "defect_weight_prerequisite": "w_p >= 0 for EABC channel table",
    }

    gram_payload = {
        "gram_eigenvalues": spectral["gram_eigenvalues"],
        "e3_profile_norm_sq": spectral["e3_profile_norm_sq"],
        "anisotropy_gap": spectral["anisotropy_gap"],
        "anisotropy_gap_note": (
            "Legacy alias for e3_profile_norm_sq; NOT the spectral eigenvalue gap."
        ),
        "split_valid": spectral["split_valid"],
    }

    governance = {
        "tag": E3_DECOMPOSITION_TAG,
        "e3_eabc_bridge_note": E3_EABC_GOVERNANCE_NOTE,
    }

    if w_p is None:
        return {
            "governance": governance,
            "n": n,
            "a": a,
            "e": e,
            "b": b,
            "c": c,
            "normalization": normalization,
            "e3": gram_payload,
            "eabc": {"applicable": False, "reason": f"e={e} has no EABC channel weight"},
            "comparison": {
                "status": "skip",
                "reason": "EABC bridge requires e > 3 with e % 12 in {1,5,7,11}",
            },
        }

    if w_p < 0:
        raise ValueError("EABC channel weight w_p must be non-negative")

    w_p_float = float(w_p)
    expected_gap = abs(w_p_float)
    bridged = _rank_one_defect_spectrum(w_p_float)

    m_eff = eabc_defect_tensor(w_p_float, direction)
    m_retracted = eabc_retract_defect(w_p_float, direction, matrix=m_eff)
    tensor_check = eabc_tensor_spectral_summary(
        m_eff, defect_rank=1 if w_p_float else 0, w_p=w_p_float
    )
    retract_check = eabc_tensor_spectral_summary(
        m_retracted, defect_rank=0, w_p=0.0
    )

    abs_error = abs(tensor_check["anisotropy"] - expected_gap)
    rel_error = abs_error / expected_gap if expected_gap else 0.0
    retracted_gap = retract_check["anisotropy"]
    status = (
        "pass"
        if abs_error <= tol
        and retracted_gap <= tol
        and abs(retract_check["lambda_min"] - EABC_GEOM_DIAGONAL) <= tol
        else "fail"
    )

    return {
        "governance": governance,
        "n": n,
        "a": a,
        "e": e,
        "b": b,
        "c": c,
        "normalization": normalization,
        "e3": {
            **gram_payload,
            "bridged_tensor": bridged,
            "effective_tensor": m_eff,
            "lambda_min": bridged["lambda_min"],
            "lambda_max": bridged["lambda_max"],
            "anisotropy": bridged["anisotropy"],
            "spectral_anisotropy_gap": bridged["spectral_anisotropy_gap"],
            "trace": bridged["trace"],
            "frobenius_norm": bridged["frobenius_norm"],
            "frobenius_sq": bridged["frobenius_sq"],
            "defect_rank": bridged["defect_rank"],
            "direction_norm": direction_norm,
            "tensor_symmetric": _tensor_is_symmetric(m_eff),
            "tensor_matrix_check": tensor_check,
        },
        "eabc": {
            "applicable": True,
            "defect_weight_w_p": w_p,
            "expected_anisotropy": expected_gap,
            "lambda_min": bridged["lambda_min"],
            "lambda_max": bridged["lambda_max"],
            "trace": bridged["trace"],
            "frobenius_norm": bridged["frobenius_norm"],
            "frobenius_sq": bridged["frobenius_sq"],
            "defect_rank": bridged["defect_rank"],
            "retraction_formula": "R*_EABC(M_eff, v, w_p) = M_eff - w_p v v^T",
            "after_retraction": {
                "retracted_tensor": m_retracted,
                "anisotropy": retracted_gap,
                "spectral_anisotropy_gap": retracted_gap,
                "lambda_min": retract_check["lambda_min"],
                "lambda_max": retract_check["lambda_max"],
                "trace": retract_check["trace"],
                "frobenius_norm": retract_check["frobenius_norm"],
                "defect_rank": retract_check["defect_rank"],
                "tensor_matrix_check": retract_check,
            },
        },
        "comparison": {
            "abs_error": abs_error,
            "rel_error": rel_error,
            "status": status,
            "bridge_note": (
                "e3 coefficients supply v only; w_p from EABC channel only; "
                "e3_profile_norm_sq is not spectral Δ."
            ),
        },
    }


def batch_e3_eabc_anisotropy_comparison(
    cases: Sequence[tuple[int, int, int, int]],
    *,
    tol: float = 1e-9,
) -> dict[str, Any]:
    """Run ``compare_e3_eabc_anisotropy`` for a batch of ``(a, e, b, c)`` tuples."""
    rows = [
        compare_e3_eabc_anisotropy(a, e, b, c, tol=tol)
        for a, e, b, c in cases
    ]
    return {
        "governance": {
            "tag": E3_DECOMPOSITION_TAG,
            "e3_eabc_bridge_note": E3_EABC_GOVERNANCE_NOTE,
        },
        "normalization": {
            "case_format": "(a, e, b, c) with n = e * a and Lemma-2 split r = b * c",
            "index_convention": "row-major 3x3 symmetric tensor, Fin 3 style",
            "eigenvalue_sort": "ascending (lambda_min first)",
            "geom_fixpoint": f"{EABC_GEOM_DIAGONAL} * I_3",
            "defect_weight_prerequisite": "w_p >= 0 for EABC channel table",
        },
        "cases": rows,
    }


def export_e3_eabc_anisotropy_comparison_json(
    payload: dict[str, Any],
    path: Path | str,
) -> Path:
    """Write batch comparison payload to JSON."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out


def e3_spectral_diagnostic(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """
    Spectral **[B]** diagnostic for odd e-power coefficients in ``n = q*e³ + b*c*e``.

    Builds the rank-1 Gram matrix from coefficient vector ``(q, b*c, 1)`` and
    reports sorted eigenvalues plus profile energy ``e3_profile_norm_sq = q² + (b*c)² + 1``.

    Legacy field ``anisotropy_gap`` aliases ``e3_profile_norm_sq`` for backward
    compatibility; it is **not** the spectral eigenvalue gap on the EABC bridged
    tensor. Does not prove Collatz, does not replace oddCore/Syracuse, and does
    not imply EABC tensor physics.
    """
    _validate_positive_e(e)
    q, r, n = e3_decompose(a, e)
    split = abc_split_decomposition(a, e, b, c)
    bc = b * c
    profile_norm_sq = float(q * q + bc * bc + 1)
    evals = [0.0, 0.0, profile_norm_sq]
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "a": a,
        "e": e,
        "b": b,
        "c": c,
        "q": q,
        "r": r,
        "n": n,
        "coefficients_odd_e": {"e^3": q, "e^1": bc},
        "gram_eigenvalues": evals,
        "e3_profile_norm_sq": profile_norm_sq,
        "anisotropy_gap": profile_norm_sq,
        "split_valid": split["split_holds"],
        "rest_matches_product": split["rest_matches_product"],
    }


def analyze_e3_commutative_multiplet(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """
    Lemma 3 — commutative multiplet split when ``r = b*c`` and ``[b,c]=0``.

    Under equal parity: ``a = q*e² + S_+² - S_-²`` and
    ``n = q*e³ + S_+²*e - S_-²*e``. Zeeman/Stark analogy is **[C]** only.
    """
    _validate_positive_e(e)
    base = analyze_e3_with_product_split(a, e, b, c)
    comm = commutation_check(b, c)
    e3 = e**3

    if not comm["commutes"]:
        case_type: CaseType = "invalid_parity"
    elif (b + c) % 2 != 0:
        case_type = "invalid_parity"
    elif base["case_type"] != "valid_product_split":
        case_type = base["case_type"]  # type: ignore[assignment]
    else:
        case_type = "valid_commutative_multiplet"

    s_plus, s_minus = (0, 0)
    s_plus_sq = 0
    s_minus_sq = 0
    multiplet_holds = False
    multiplet_identity = ""

    if case_type == "valid_commutative_multiplet":
        s_plus, s_minus = symmetric_operators(b, c)
        s_plus_sq = s_plus * s_plus
        s_minus_sq = s_minus * s_minus
        q = base["q"]
        n = base["n"]
        reconstructed = q * e3 + s_plus_sq * e - s_minus_sq * e
        multiplet_holds = reconstructed == n
        multiplet_identity = (
            f"n = q*e³ + S_+²*e - S_-²*e = {q}*{e3} + {s_plus_sq}*{e} - {s_minus_sq}*{e} "
            f"= {reconstructed}"
        )

    return {
        **base,
        "case_type": case_type,
        "commutation": comm,
        "s_plus": s_plus,
        "s_minus": s_minus,
        "s_plus_sq": s_plus_sq,
        "s_minus_sq": s_minus_sq,
        "a_split_form": f"q*e² + S_+² - S_-²" if case_type == "valid_commutative_multiplet" else None,
        "multiplet_identity": multiplet_identity,
        "multiplet_holds": multiplet_holds,
        "zeeman_analogy_governance": E3_PRODUCT_ANALOGY_TAG,
        "zeeman_analogy_note": (
            "Zeeman/Stark multiplet analogy (q*e³, +S_+²*e, -S_-²*e) is [C] "
            "interpretive bridge only — not physics identity, not Collatz proof."
        ),
    }
