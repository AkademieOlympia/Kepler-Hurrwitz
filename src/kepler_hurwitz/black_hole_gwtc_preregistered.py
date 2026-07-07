"""
GWTC preregistered Phase-1/2 calibration pipeline — E-093 / ORQ-093 / BH-GOV-01 [C].

Implements the LOCK preregistration grid (kappa x tau, N_tests=92) on GWTC-3 for
parameter identification only. Phase 1 applies Bonferroni over 92 tests; a
significant Phase-1 minimum does NOT upgrade to [B]. Phase 2 is a single blind
verification stub for future GWTC-4/5 data.

Governance: [C] until Phase-2 blind test on real holdout data succeeds.
See ``docs/black_hole/preregistration_gwtc5.md``.
"""

from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Sequence

from kepler_hurwitz.black_hole_legendre_gwtc import (
    BLACK_HOLE_TAG,
    DEFAULT_CHI_P_1G_THRESHOLD,
    DEFAULT_MAX_NORM,
    DEFAULT_MC_SAMPLES,
    GOVERNANCE as BH_GOVERNANCE,
    GwtcEvent,
    get_forbidden_mass_integers,
    load_gwtc_catalog,
    permutation_test_mc,
)

PREREGISTRATION_PATH = (
    Path(__file__).resolve().parents[2] / "docs" / "black_hole" / "preregistration_gwtc5.md"
)

PHASE1_ALPHA = 0.05
PHASE1_N_TESTS = 92
PHASE2_ALPHA = 0.05

PREREG_GOVERNANCE: dict[str, str] = {
    "status": "C preregistered calibration scaffold",
    "phase1_claim_boundary": (
        "Phase 1 yields (kappa*, tau*) only — no [B] upgrade without Phase 2 blind test"
    ),
    "bonferroni": f"alpha_corrected = {PHASE1_ALPHA} / {PHASE1_N_TESTS}",
    "inherits_from": "BH-GOV-01, E-093",
    "not_claimed": BH_GOVERNANCE.get("not_claimed", ""),
}

__all__ = [
    "PHASE1_ALPHA",
    "PHASE1_N_TESTS",
    "PHASE2_ALPHA",
    "PREREGISTRATION_PATH",
    "PREREG_GOVERNANCE",
    "Phase1CalibrationResult",
    "Phase1GridPoint",
    "Phase2VerificationResult",
    "bonferroni_alpha_phase1",
    "filter_events_for_preregistration",
    "kappa_grid",
    "run_phase1_calibration",
    "run_phase2_verification",
    "tau_grid",
]


def kappa_grid() -> list[float]:
    """kappa in [0.5, 5.0] step 0.1 -> 46 values per preregistration."""
    values: list[float] = []
    kappa = 0.5
    while kappa <= 5.0 + 1e-12:
        values.append(round(kappa, 10))
        kappa += 0.1
    return values


def tau_grid() -> list[float]:
    """tau in {0.25, 0.5} per preregistration."""
    return [0.25, 0.5]


def bonferroni_alpha_phase1(*, n_tests: int = PHASE1_N_TESTS, alpha: float = PHASE1_ALPHA) -> float:
    return alpha / n_tests


def filter_events_for_preregistration(events: Sequence[GwtcEvent]) -> list[GwtcEvent]:
    """
    Apply preregistration exclusion criteria:

    - Require chi_p (non-None finite values — caller/loaders should already enforce).
    - Require M1 primary mass with published lower/upper source bounds.
    - M1 only: keep events where m1_solar >= m2_solar (primary is component 1).
    """
    filtered: list[GwtcEvent] = []
    for event in events:
        if event.m1_solar < event.m2_solar:
            continue
        if event.m1_source_lower is None or event.m1_source_upper is None:
            continue
        if not math.isfinite(event.chi_p):
            continue
        filtered.append(event)
    return filtered


@dataclass(frozen=True)
class Phase1GridPoint:
    kappa: float
    tau: float
    p_value: float
    obs_1g_expected_hits: float


@dataclass
class Phase1CalibrationResult:
    best_kappa: float
    best_tau: float
    best_p_value: float
    bonferroni_alpha: float
    bonferroni_significant: bool
    n_tests: int
    n_events_included: int
    n_events_excluded: int
    grid_results: list[Phase1GridPoint] = field(default_factory=list)
    tag: str = BLACK_HOLE_TAG
    governance: dict[str, str] = field(default_factory=lambda: dict(PREREG_GOVERNANCE))

    def as_dict(self) -> dict[str, Any]:
        d = asdict(self)
        d["grid_results"] = [asdict(g) for g in self.grid_results]
        return d


@dataclass(frozen=True)
class Phase2VerificationResult:
    kappa: float
    tau: float
    p_value: float
    obs_1g_expected_hits: float
    alpha: float
    significant: bool
    n_events: int
    tag: str = BLACK_HOLE_TAG
    note: str = "Phase 2 stub — single preregistered blind test; [B] only if significant here."

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def run_phase1_calibration(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int] | None = None,
    *,
    max_norm: int = DEFAULT_MAX_NORM,
    mc_samples: int = DEFAULT_MC_SAMPLES,
    perm_iterations: int = 10_000,
    seed: int = 93,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
    apply_exclusion_filter: bool = True,
) -> Phase1CalibrationResult:
    """
    Grid sweep over preregistered (kappa, tau) pairs on GWTC-3 calibration set.

    Selects (kappa*, tau*) minimizing permutation MC p-value. Reports Bonferroni
    threshold alpha/92; significance here does NOT constitute a [B] claim.
    """
    raw = list(events)
    included = filter_events_for_preregistration(raw) if apply_exclusion_filter else list(raw)
    excluded = len(raw) - len(included)
    forbidden = (
        list(forbidden_m)
        if forbidden_m is not None
        else get_forbidden_mass_integers(max_norm=max_norm)
    )

    grid_results: list[Phase1GridPoint] = []
    best_p = float("inf")
    best_kappa = kappa_grid()[0]
    best_tau = tau_grid()[0]
    best_obs = 0.0

    grid_seed = seed
    for tau in tau_grid():
        for kappa in kappa_grid():
            result = permutation_test_mc(
                included,
                forbidden,
                kappa=kappa,
                tau=tau,
                iterations=perm_iterations,
                n_mc_samples=mc_samples,
                seed=grid_seed,
                chi_p_threshold=chi_p_threshold,
            )
            grid_seed += 1
            point = Phase1GridPoint(
                kappa=kappa,
                tau=tau,
                p_value=result.p_value,
                obs_1g_expected_hits=result.obs_1g_expected_hits,
            )
            grid_results.append(point)
            if result.p_value < best_p:
                best_p = result.p_value
                best_kappa = kappa
                best_tau = tau
                best_obs = result.obs_1g_expected_hits

    bonf = bonferroni_alpha_phase1()
    return Phase1CalibrationResult(
        best_kappa=best_kappa,
        best_tau=best_tau,
        best_p_value=best_p,
        bonferroni_alpha=bonf,
        bonferroni_significant=best_p < bonf,
        n_tests=len(grid_results),
        n_events_included=len(included),
        n_events_excluded=excluded,
        grid_results=grid_results,
    )


def run_phase2_verification(
    events: Sequence[GwtcEvent],
    kappa_star: float,
    tau_star: float,
    forbidden_m: Sequence[int] | None = None,
    *,
    max_norm: int = DEFAULT_MAX_NORM,
    mc_samples: int = DEFAULT_MC_SAMPLES,
    perm_iterations: int = 10_000,
    seed: int = 9407,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
    alpha: float = PHASE2_ALPHA,
    apply_exclusion_filter: bool = True,
) -> Phase2VerificationResult:
    """
    Phase-2 stub: single preregistered test with fixed (kappa*, tau*).

    Intended for GWTC-4/5 holdout; one-sided alpha=0.05, no multiple-test correction.
    """
    raw = list(events)
    included = filter_events_for_preregistration(raw) if apply_exclusion_filter else list(raw)
    forbidden = (
        list(forbidden_m)
        if forbidden_m is not None
        else get_forbidden_mass_integers(max_norm=max_norm)
    )
    result = permutation_test_mc(
        included,
        forbidden,
        kappa=kappa_star,
        tau=tau_star,
        iterations=perm_iterations,
        n_mc_samples=mc_samples,
        seed=seed,
        chi_p_threshold=chi_p_threshold,
    )
    return Phase2VerificationResult(
        kappa=kappa_star,
        tau=tau_star,
        p_value=result.p_value,
        obs_1g_expected_hits=result.obs_1g_expected_hits,
        alpha=alpha,
        significant=result.p_value < alpha,
        n_events=len(included),
    )


def export_phase1_json(result: Phase1CalibrationResult, path: Path, *, data_note: str = "") -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = result.as_dict()
    payload["preregistration_path"] = str(PREREGISTRATION_PATH)
    payload["phase"] = 1
    payload["data_note"] = data_note
    payload["interpretation"] = (
        "Phase 1 calibration only; Bonferroni significance does not upgrade to [B]. "
        "Apply (kappa*, tau*) once in Phase 2 on GWTC-4/5 holdout."
    )
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return path


def load_and_filter_catalog(path: Path) -> tuple[list[GwtcEvent], list[GwtcEvent]]:
    """Load GWTC CSV and return (filtered, all_loaded)."""
    all_events = load_gwtc_catalog(path)
    filtered = filter_events_for_preregistration(all_events)
    return filtered, all_events
