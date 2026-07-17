"""
Hc numerical stability freeze — rational SSOT + certified ε_* brackets.

Governance (#Energiedoku):
  Modell-Definition ≠ physikalische Interpretation.
  ε_* / Rayleigh-Lücken sind dimensionslose Fluktuationskennzahlen,
  keine Naturkonstanten. Numerischer Freeze ≠ formaler Lean-Beweis.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import asdict, dataclass
from fractions import Fraction
from pathlib import Path
from typing import Any

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
SPEC_PATH = ROOT / "specs" / "hc_spectral_stability_spec.json"
REPORT_PATH = ROOT / "specs" / "hc_numerical_freeze_report.json"

THRESHOLD_GAP = Fraction(1, 4)
SEARCH_HIGH = 2.0
BISECT_ITERS = 48


def _F(x: Any) -> Fraction:
    return Fraction(str(x))


@dataclass(frozen=True)
class EpsilonBracket:
    estimate: float
    lower_pass: float
    upper_fail: float | None
    certified_to_search_high: bool


def load_spec(path: Path = SPEC_PATH) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def matrix_float(rows) -> np.ndarray:
    return np.array([[float(_F(e)) for e in row] for row in rows], dtype=np.float64)


def load_operators(spec: dict | None = None) -> dict[str, np.ndarray]:
    spec = spec or load_spec()
    return {k: matrix_float(v) for k, v in spec["matrices"].items()}


def bamberg_mode(spec: dict | None = None) -> np.ndarray:
    spec = spec or load_spec()
    u = np.array(
        [float(_F(x)) for x in spec["analytical_checks"]["bamberg_mode"]],
        dtype=np.float64,
    )
    return u / np.linalg.norm(u)


def rayleigh(H: np.ndarray, u: np.ndarray) -> float:
    H = 0.5 * (H + H.conj().T)
    return float(np.vdot(u, H @ u).real)


def spectral_projector_overlap(H: np.ndarray, u: np.ndarray) -> float:
    """Maximaler Überlapp |⟨v_i,u⟩|² mit Eigenvektoren von H (Bamberg-Mode-Treue)."""
    H = 0.5 * (H + H.conj().T)
    _evals, evecs = np.linalg.eigh(H)
    overlaps = np.abs(evecs.conj().T @ u) ** 2
    return float(np.max(overlaps))


def require_exact_controls(spec: dict | None = None) -> None:
    """Hard controls against the normative rational SSOT (float check with tight tol)."""
    spec = spec or load_spec()
    ops = load_operators(spec)
    L = ops["L_C4"]
    V = ops["V"]
    u = bamberg_mode(spec)
    exp = spec["analytical_checks"]["expected"]

    if not np.allclose(L, L.conj().T) or not np.allclose(V, V.conj().T):
        raise ValueError("Matrix Hermitizität verletzt")

    rL = rayleigh(L, u)
    rV = rayleigh(V, u)
    rH = rayleigh(L + V, u)
    if not np.isclose(rL, float(_F(exp["rayleigh_L_C4_on_mode_e1_minus_e2"])), atol=1e-12):
        raise ValueError(f"Rb(L) Check fehlgeschlagen: {rL}")
    if not np.isclose(rV, float(_F(exp["rayleigh_V_on_mode_e1_minus_e2"])), atol=1e-12):
        raise ValueError(f"Rb(V) Check fehlgeschlagen: {rV}")
    if not np.isclose(rH, float(_F(exp["rayleigh_H_LC4_V_on_mode_e1_minus_e2"])), atol=1e-12):
        raise ValueError(f"Rb(L+V) Check fehlgeschlagen: {rH}")

    if abs(np.trace(L) - float(_F(exp["trace_L_C4"]))) > 1e-12:
        raise ValueError("trace(L_C4) Check fehlgeschlagen")
    if abs(np.trace(V) - float(_F(exp["trace_V"]))) > 1e-12:
        raise ValueError("trace(V) Check fehlgeschlagen")


def passes_rayleigh_gap(
    L: np.ndarray,
    V: np.ndarray,
    N: np.ndarray,
    eps: float,
    u: np.ndarray,
    threshold: float = float(THRESHOLD_GAP),
) -> bool:
    r_struct = rayleigh(L + V, u)
    r_noise = rayleigh(L + float(eps) * N, u)
    return abs(r_struct - r_noise) >= threshold


def get_stability_bracket(
    L: np.ndarray,
    V: np.ndarray,
    N: np.ndarray,
    u: np.ndarray,
    *,
    search_high: float = SEARCH_HIGH,
    threshold: float = float(THRESHOLD_GAP),
) -> EpsilonBracket:
    """
    Größtes ε≥0, bis zu dem der Rayleigh-Gap ab 0 ununterbrochen hält.
    Wichtig: Nicht am Suchende „passes“ testen — Gaps können nach einem
    Fail wieder öffnen (z.B. N_II_channel bei ε>1).
    """
    if not passes_rayleigh_gap(L, V, N, 0.0, u, threshold):
        return EpsilonBracket(0.0, 0.0, 0.0, False)

    grid = np.linspace(0.0, search_high, 256)
    prev = 0.0
    first_fail: float | None = None
    for eps in grid[1:]:
        if not passes_rayleigh_gap(L, V, N, float(eps), u, threshold):
            first_fail = float(eps)
            break
        prev = float(eps)

    if first_fail is None:
        return EpsilonBracket(search_high, search_high, None, True)

    lo, hi = prev, first_fail
    for _ in range(BISECT_ITERS):
        mid = 0.5 * (lo + hi)
        if passes_rayleigh_gap(L, V, N, mid, u, threshold):
            lo = mid
        else:
            hi = mid

    return EpsilonBracket(
        estimate=float(lo),
        lower_pass=float(lo),
        upper_fail=float(hi),
        certified_to_search_high=False,
    )


def run_freeze(spec: dict | None = None) -> dict:
    spec = spec or load_spec()
    require_exact_controls(spec)
    ops = load_operators(spec)
    L, V = ops["L_C4"], ops["V"]
    u = bamberg_mode(spec)

    epsilon_star: dict[str, Any] = {}
    for key in spec["numerical_freeze"]["noise_classes"]:
        N = ops[key]
        bracket = get_stability_bracket(L, V, N, u)
        # Sekundärstatistik am Bracket-Punkt
        eps = bracket.estimate
        H_n = L + eps * N
        epsilon_star[key] = {
            "positive": asdict(bracket),
            "rayleigh_struct": rayleigh(L + V, u),
            "rayleigh_noise_at_estimate": rayleigh(H_n, u),
            "projector_overlap_struct": spectral_projector_overlap(L + V, u),
            "projector_overlap_noise_at_estimate": spectral_projector_overlap(H_n, u),
        }

    # Limiting = kleinste contiguous-from-zero Schranke (nicht alphabetisch)
    limiting = min(
        epsilon_star.keys(),
        key=lambda k: (
            epsilon_star[k]["positive"]["estimate"],
            0 if not epsilon_star[k]["positive"]["certified_to_search_high"] else 1,
            k,
        ),
    )
    eps_sym = epsilon_star[limiting]["positive"]["estimate"]

    payload = {
        "schema_version": 1,
        "freeze_status": "passed" if eps_sym > 0 else "failed",
        "spec_id": spec.get("spec_id", "hc_spectral_stability"),
        "limiting_noise_class": limiting,
        "limiting_criterion": "abs_rayleigh_gap_ge_1/4_contiguous_from_zero",
        "secondary_criterion": "spectral_projector_overlap",
        "threshold_gap": str(THRESHOLD_GAP),
        "epsilon_star_sym": eps_sym,
        "epsilon_star": epsilon_star,
        "governance": (
            "Numerical freeze radius only; not a Lean proof; "
            "dimensionless fluctuation index, not a natural constant"
        ),
    }
    raw = json.dumps(payload, sort_keys=True, indent=2).encode("utf-8")
    payload["content_sha256"] = hashlib.sha256(raw).hexdigest()
    return payload


def write_report(report: dict, path: Path = REPORT_PATH) -> Path:
    path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    return path
