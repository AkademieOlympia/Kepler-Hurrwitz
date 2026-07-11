"""
Nuclear binding residual diagnostics — EABC vs. R(A,Z) hypothesis scaffold [C].

Defines B_exp(A,Z) = B_smooth(A,Z) + R(A,Z) with a preregistered Weizsäcker hull,
maps EABC invariants I_EABC(A,Z) from mass/proton numbers, and runs the ORQ-092
correlation battery (Pearson, Spearman, MI, PCA, Fourier/Wavelet) with null models.

Governance: [C] — descriptive / hypothesis-generating only; no nuclear physics claim.
See docs/atome_hypothese.md and docs/theory/nuclear_binding_multiscale_analogy.md (E-092).
"""

from __future__ import annotations

import csv
import json
import math
import random
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Sequence

from kepler_hurwitz.diagnostics import chirality_norm
from kepler_hurwitz.signatures import EABCSignature4, eabc_mass, signature_from_nat

ATOME_TAG = "[C]"

DEFAULT_WEIZSAECKER_PARAMS: dict[str, float] = {
    "a_v": 15.56,
    "a_s": 17.23,
    "a_c": 0.693,
    "a_a": 23.29,
    "a_p": 12.0,
}

__all__ = [
    "ATOME_TAG",
    "DEFAULT_WEIZSAECKER_PARAMS",
    "AtomeAnalysis",
    "CorrelationMetric",
    "EabcInvariantRecord",
    "NuclideRecord",
    "NullModelResult",
    "ResidualRecord",
    "WeizsaeckerParams",
    "build_atome_analysis",
    "build_residual_table",
    "correlate_eabc_residuals",
    "eabc_invariants",
    "export_atome_bundle",
    "load_nuclides_csv",
    "pearson_correlation",
    "run_nullmodels",
    "spearman_correlation",
    "toy_nuclides",
    "weizsaecker_binding",
]


@dataclass(frozen=True)
class WeizsaeckerParams:
    """Preregistered semi-empirical mass formula coefficients (MeV)."""

    a_v: float = 15.56
    a_s: float = 17.23
    a_c: float = 0.693
    a_a: float = 23.29
    a_p: float = 12.0

    def pairing_delta(self, a: int, z: int) -> float:
        if a % 2 != 0:
            return 0.0
        if z % 2 == 0:
            return self.a_p / math.sqrt(a)
        return -self.a_p / math.sqrt(a)


@dataclass(frozen=True)
class NuclideRecord:
    a: int
    z: int
    b_exp_mev: float
    label: str = ""

    @property
    def n(self) -> int:
        return self.a - self.z


@dataclass(frozen=True)
class ResidualRecord:
    a: int
    z: int
    label: str
    b_exp_mev: float
    b_smooth_mev: float
    residual_mev: float
    residual_per_nucleon_mev: float
    log_a: float


@dataclass(frozen=True)
class EabcInvariantRecord:
    a: int
    z: int
    label: str
    eabc_mass: int
    eabc_spread: int
    channel_e: int
    channel_a: int
    channel_b: int
    channel_c: int
    chiral_norm: float
    proton_eabc_mass: int


@dataclass(frozen=True)
class CorrelationMetric:
    feature: str
    pearson_r: float | None
    spearman_rho: float | None
    mutual_information: float | None


@dataclass(frozen=True)
class NullModelResult:
    mode: str
    feature: str
    observed_pearson: float | None
    null_pearson_mean: float
    null_pearson_std: float
    z_score: float | None
    trials: int


@dataclass(frozen=True)
class SpectralSummary:
    fft_peak_frequency: float | None
    fft_peak_power: float | None
    wavelet_dominant_scale: float | None


@dataclass(frozen=True)
class PcaSummary:
    explained_variance_ratio: tuple[float, ...]
    loadings: tuple[tuple[float, ...], ...]


@dataclass(frozen=True)
class AtomeAnalysis:
    governance: str
    weizsaecker_params: WeizsaeckerParams
    nuclide_count: int
    residuals: tuple[ResidualRecord, ...]
    invariants: tuple[EabcInvariantRecord, ...]
    correlations: tuple[CorrelationMetric, ...]
    nullmodels: tuple[NullModelResult, ...]
    pca: PcaSummary | None
    spectral: SpectralSummary | None
    notes: tuple[str, ...] = field(default_factory=tuple)


def weizsaecker_binding(a: int, z: int, *, params: WeizsaeckerParams | None = None) -> float:
    """Semi-empirical Weizsäcker binding energy B_smooth(A,Z) in MeV."""
    if a < 1:
        raise ValueError("A must be >= 1")
    if z < 0 or z > a:
        raise ValueError(f"Z must satisfy 0 <= Z <= A, got Z={z}, A={a}")
    p = params or WeizsaeckerParams()
    coulomb = p.a_c * z * (z - 1) / (a ** (1.0 / 3.0))
    asymmetry = p.a_a * ((a - 2 * z) ** 2) / a
    return (
        p.a_v * a
        - p.a_s * (a ** (2.0 / 3.0))
        - coulomb
        - asymmetry
        + p.pairing_delta(a, z)
    )


def _chiral_norm_from_signature(signature: EABCSignature4) -> float:
    e, a, b, c = signature.as_tuple()
    return chirality_norm(float(e - c), float(a - b), float(e + a - b - c))


def eabc_invariants(a: int, z: int, *, label: str = "") -> EabcInvariantRecord:
    """
    Build I_EABC(A,Z) from mass number A and proton number Z.

    Governance [C]: H(A) and H(Z) are independent of the Weizsäcker hull fit.
  """
    sig_a = signature_from_nat(a)
    sig_z = signature_from_nat(z) if z >= 1 else EABCSignature4(0, 0, 0, 0)
    return EabcInvariantRecord(
        a=a,
        z=z,
        label=label,
        eabc_mass=eabc_mass(a),
        eabc_spread=sig_a.spread(),
        channel_e=sig_a.E,
        channel_a=sig_a.A,
        channel_b=sig_a.B,
        channel_c=sig_a.C,
        chiral_norm=_chiral_norm_from_signature(sig_a),
        proton_eabc_mass=sig_z.total_weight(),
    )


def build_residual_table(
    nuclides: Sequence[NuclideRecord],
    *,
    params: WeizsaeckerParams | None = None,
) -> list[ResidualRecord]:
    rows: list[ResidualRecord] = []
    for nuclide in nuclides:
        b_smooth = weizsaecker_binding(nuclide.a, nuclide.z, params=params)
        residual = nuclide.b_exp_mev - b_smooth
        rows.append(
            ResidualRecord(
                a=nuclide.a,
                z=nuclide.z,
                label=nuclide.label,
                b_exp_mev=nuclide.b_exp_mev,
                b_smooth_mev=b_smooth,
                residual_mev=residual,
                residual_per_nucleon_mev=residual / nuclide.a,
                log_a=math.log(nuclide.a),
            )
        )
    return rows


def _rank(values: Sequence[float]) -> list[float]:
    indexed = sorted(enumerate(values), key=lambda item: item[1])
    ranks = [0.0] * len(values)
    i = 0
    while i < len(indexed):
        j = i
        while j + 1 < len(indexed) and indexed[j + 1][1] == indexed[i][1]:
            j += 1
        avg_rank = (i + j + 2) / 2.0
        for k in range(i, j + 1):
            ranks[indexed[k][0]] = avg_rank
        i = j + 1
    return ranks


def pearson_correlation(x: Sequence[float], y: Sequence[float]) -> float | None:
    if len(x) != len(y) or len(x) < 2:
        return None
    mean_x = sum(x) / len(x)
    mean_y = sum(y) / len(y)
    cov = sum((xi - mean_x) * (yi - mean_y) for xi, yi in zip(x, y, strict=True))
    var_x = sum((xi - mean_x) ** 2 for xi in x)
    var_y = sum((yi - mean_y) ** 2 for yi in y)
    if var_x == 0 or var_y == 0:
        return None
    return cov / math.sqrt(var_x * var_y)


def spearman_correlation(x: Sequence[float], y: Sequence[float]) -> float | None:
    if len(x) != len(y) or len(x) < 2:
        return None
    return pearson_correlation(_rank(x), _rank(y))


def mutual_information(
    x: Sequence[float],
    y: Sequence[float],
    *,
    bins: int = 8,
) -> float | None:
    if len(x) != len(y) or len(x) < 4:
        return None
    try:
        import numpy as np
    except ImportError:
        return _mutual_information_histogram(x, y, bins=bins)

    x_arr = np.asarray(x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    hist, _, _ = np.histogram2d(x_arr, y_arr, bins=bins)
    total = hist.sum()
    if total <= 0:
        return None
    p_xy = hist / total
    p_x = p_xy.sum(axis=1)
    p_y = p_xy.sum(axis=0)
    mi = 0.0
    for i in range(bins):
        for j in range(bins):
            if p_xy[i, j] > 0 and p_x[i] > 0 and p_y[j] > 0:
                mi += p_xy[i, j] * math.log(p_xy[i, j] / (p_x[i] * p_y[j]))
    return mi


def _mutual_information_histogram(
    x: Sequence[float],
    y: Sequence[float],
    *,
    bins: int,
) -> float | None:
    if len(x) < 4:
        return None
    x_min, x_max = min(x), max(x)
    y_min, y_max = min(y), max(y)
    if x_max == x_min or y_max == y_min:
        return None
    hist = [[0.0] * bins for _ in range(bins)]
    for xi, yi in zip(x, y, strict=True):
        i = min(bins - 1, int((xi - x_min) / (x_max - x_min) * bins))
        j = min(bins - 1, int((yi - y_min) / (y_max - y_min) * bins))
        hist[i][j] += 1.0
    total = sum(sum(row) for row in hist)
    p_x = [sum(hist[i][j] for j in range(bins)) / total for i in range(bins)]
    p_y = [sum(hist[i][j] for i in range(bins)) / total for j in range(bins)]
    mi = 0.0
    for i in range(bins):
        for j in range(bins):
            p_xy = hist[i][j] / total
            if p_xy > 0 and p_x[i] > 0 and p_y[j] > 0:
                mi += p_xy * math.log(p_xy / (p_x[i] * p_y[j]))
    return mi


def correlate_eabc_residuals(
    residuals: Sequence[ResidualRecord],
    invariants: Sequence[EabcInvariantRecord],
    *,
    features: Sequence[str] | None = None,
) -> list[CorrelationMetric]:
    if len(residuals) != len(invariants):
        raise ValueError("residuals and invariants must have equal length")
    feature_names = list(features or (
        "eabc_mass",
        "eabc_spread",
        "chiral_norm",
        "proton_eabc_mass",
        "channel_e",
        "channel_a",
        "channel_b",
        "channel_c",
    ))
    r_values = [row.residual_mev for row in residuals]
    inv_by_a = {row.a: row for row in invariants}
    metrics: list[CorrelationMetric] = []
    for name in feature_names:
        x_values = [float(getattr(inv_by_a[row.a], name)) for row in residuals]
        metrics.append(
            CorrelationMetric(
                feature=name,
                pearson_r=pearson_correlation(x_values, r_values),
                spearman_rho=spearman_correlation(x_values, r_values),
                mutual_information=mutual_information(x_values, r_values),
            )
        )
    return metrics


def _shuffle_invariant_feature(
    invariants: Sequence[EabcInvariantRecord],
    feature: str,
    rng: random.Random,
) -> list[float]:
    values = [float(getattr(inv, feature)) for inv in invariants]
    shuffled = values[:]
    rng.shuffle(shuffled)
    return shuffled


def _variance_matched_shuffle(
    values: Sequence[float],
    rng: random.Random,
) -> list[float]:
    mean = sum(values) / len(values)
    centered = [v - mean for v in values]
    var = sum(v * v for v in centered) / len(centered)
    if var == 0:
        return list(values)
    std = math.sqrt(var)
    normal_draws = [rng.gauss(0.0, std) for _ in values]
    draw_mean = sum(normal_draws) / len(normal_draws)
    draw_std = math.sqrt(sum((d - draw_mean) ** 2 for d in normal_draws) / len(normal_draws))
    if draw_std == 0:
        return [mean for _ in values]
    scale = std / draw_std
    return [mean + scale * (d - draw_mean) for d in normal_draws]


def run_nullmodels(
    residuals: Sequence[ResidualRecord],
    invariants: Sequence[EabcInvariantRecord],
    *,
    feature: str = "eabc_mass",
    modes: Sequence[str] = ("permute_R", "shuffle_channel", "variance_match"),
    trials: int = 200,
    seed: int = 92,
) -> list[NullModelResult]:
    if len(residuals) != len(invariants):
        raise ValueError("residuals and invariants must have equal length")
    if trials < 1:
        raise ValueError("trials must be >= 1")

    r_values = [row.residual_mev for row in residuals]
    x_values = [float(getattr(inv, feature)) for inv in invariants]
    observed = pearson_correlation(x_values, r_values)
    results: list[NullModelResult] = []

    for mode in modes:
        null_correlations: list[float] = []
        for trial in range(trials):
            rng = random.Random(seed + trial + hash(mode) % 10_000)
            if mode == "permute_R":
                shuffled_r = r_values[:]
                rng.shuffle(shuffled_r)
                corr = pearson_correlation(x_values, shuffled_r)
            elif mode == "shuffle_channel":
                shuffled_x = _shuffle_invariant_feature(invariants, feature, rng)
                corr = pearson_correlation(shuffled_x, r_values)
            elif mode == "variance_match":
                synthetic_r = _variance_matched_shuffle(r_values, rng)
                corr = pearson_correlation(x_values, synthetic_r)
            else:
                raise ValueError(f"unknown nullmodel mode: {mode!r}")
            if corr is not None:
                null_correlations.append(corr)

        if not null_correlations:
            results.append(
                NullModelResult(
                    mode=mode,
                    feature=feature,
                    observed_pearson=observed,
                    null_pearson_mean=0.0,
                    null_pearson_std=0.0,
                    z_score=None,
                    trials=trials,
                )
            )
            continue

        null_mean = sum(null_correlations) / len(null_correlations)
        null_var = sum((c - null_mean) ** 2 for c in null_correlations) / len(null_correlations)
        null_std = math.sqrt(null_var)
        z_score = None
        if observed is not None and null_std > 0:
            z_score = (observed - null_mean) / null_std

        results.append(
            NullModelResult(
                mode=mode,
                feature=feature,
                observed_pearson=observed,
                null_pearson_mean=null_mean,
                null_pearson_std=null_std,
                z_score=z_score,
                trials=trials,
            )
        )
    return results


def _pca_summary(
    residuals: Sequence[ResidualRecord],
    invariants: Sequence[EabcInvariantRecord],
) -> PcaSummary | None:
    if len(residuals) < 3:
        return None
    try:
        import numpy as np
    except ImportError:
        return None

    feature_names = ("eabc_mass", "eabc_spread", "chiral_norm", "proton_eabc_mass")
    inv_by_a = {row.a: row for row in invariants}
    matrix = np.array(
        [
            [float(getattr(inv_by_a[row.a], name)) for name in feature_names]
            + [row.residual_mev, row.residual_per_nucleon_mev]
            for row in residuals
        ],
        dtype=float,
    )
    matrix = matrix - matrix.mean(axis=0)
    cov = matrix.T @ matrix / max(len(residuals) - 1, 1)
    eigenvalues, eigenvectors = np.linalg.eigh(cov)
    order = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[order]
    eigenvectors = eigenvectors[:, order]
    total = float(eigenvalues.sum())
    if total <= 0:
        return None
    ratios = tuple(float(v / total) for v in eigenvalues[:3])
    loadings = tuple(tuple(float(x) for x in eigenvectors[:, k]) for k in range(min(3, len(feature_names) + 2)))
    return PcaSummary(explained_variance_ratio=ratios, loadings=loadings)


def _residual_spectral_summary(residuals: Sequence[ResidualRecord]) -> SpectralSummary | None:
    if len(residuals) < 8:
        return None
    ordered = sorted(residuals, key=lambda row: row.log_a)
    log_a = [row.log_a for row in ordered]
    r_vals = [row.residual_mev for row in ordered]

    from kepler_hurwitz.eabc_weierstrass_multiscale import (
        _fft_peaks_uniform_log_grid,
        _wavelet_dominant_scale,
    )

    peaks = _fft_peaks_uniform_log_grid(log_a, r_vals, top_k=1)
    dominant = _wavelet_dominant_scale(log_a, r_vals)
    if not peaks:
        return SpectralSummary(
            fft_peak_frequency=None,
            fft_peak_power=None,
            wavelet_dominant_scale=dominant,
        )
    return SpectralSummary(
        fft_peak_frequency=peaks[0].frequency,
        fft_peak_power=peaks[0].power,
        wavelet_dominant_scale=dominant,
    )


def toy_nuclides() -> list[NuclideRecord]:
    """Curated toy table for smoke tests (not a full AME export)."""
    return [
        NuclideRecord(4, 2, 28.296, "He-4"),
        NuclideRecord(6, 3, 31.998, "Li-6"),
        NuclideRecord(7, 3, 39.245, "Li-7"),
        NuclideRecord(9, 4, 58.165, "Be-9"),
        NuclideRecord(12, 6, 92.162, "C-12"),
        NuclideRecord(14, 7, 104.659, "N-14"),
        NuclideRecord(16, 8, 127.619, "O-16"),
        NuclideRecord(20, 10, 160.644, "Ne-20"),
        NuclideRecord(24, 12, 189.984, "Mg-24"),
        NuclideRecord(28, 14, 231.627, "Si-28"),
        NuclideRecord(40, 20, 341.523, "Ca-40"),
        NuclideRecord(48, 22, 416.001, "Ti-48"),
        NuclideRecord(56, 26, 492.254, "Fe-56"),
        NuclideRecord(58, 28, 508.449, "Ni-58"),
        NuclideRecord(64, 30, 545.390, "Zn-64"),
        NuclideRecord(90, 40, 783.916, "Zr-90"),
        NuclideRecord(120, 50, 1020.533, "Sn-120"),
        NuclideRecord(140, 60, 1171.890, "Ce-140"),
        NuclideRecord(180, 74, 1435.014, "Hf-180"),
        NuclideRecord(208, 82, 1630.468, "Pb-208"),
        NuclideRecord(238, 92, 1801.693, "U-238"),
    ]


def load_nuclides_csv(path: Path) -> list[NuclideRecord]:
    rows: list[NuclideRecord] = []
    with path.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        for record in reader:
            rows.append(
                NuclideRecord(
                    a=int(record["A"]),
                    z=int(record["Z"]),
                    b_exp_mev=float(record["b_exp_mev"]),
                    label=record.get("label", ""),
                )
            )
    return rows


def build_atome_analysis(
    nuclides: Sequence[NuclideRecord],
    *,
    params: WeizsaeckerParams | None = None,
    nullmodel_trials: int = 200,
    seed: int = 92,
) -> AtomeAnalysis:
    residuals = build_residual_table(nuclides, params=params)
    invariants = tuple(
        eabc_invariants(nuclide.a, nuclide.z, label=nuclide.label) for nuclide in nuclides
    )
    correlations = tuple(correlate_eabc_residuals(residuals, invariants))
    nullmodels = tuple(
        run_nullmodels(
            residuals,
            invariants,
            trials=nullmodel_trials,
            seed=seed,
        )
    )
    notes = (
        "Weizsäcker hull is preregistered — not EABC-optimized.",
        "Toy table / partial AME slice — not a physics claim.",
        "Nullmodel significance required for [B] upgrade (ORQ-092).",
    )
    return AtomeAnalysis(
        governance=ATOME_TAG,
        weizsaecker_params=params or WeizsaeckerParams(),
        nuclide_count=len(nuclides),
        residuals=tuple(residuals),
        invariants=invariants,
        correlations=correlations,
        nullmodels=nullmodels,
        pca=_pca_summary(residuals, invariants),
        spectral=_residual_spectral_summary(residuals),
        notes=notes,
    )


def _analysis_to_json_dict(analysis: AtomeAnalysis) -> dict[str, Any]:
    return {
        "governance": analysis.governance,
        "not_claimed": [
            "EABC explains nuclear binding or replaces SEMF",
            "R(A,Z) is identical to prime counting error E(x)",
            "Correlation without nullmodel exceeds chance",
        ],
        "weizsaecker_params": asdict(analysis.weizsaecker_params),
        "nuclide_count": analysis.nuclide_count,
        "residuals": [asdict(row) for row in analysis.residuals],
        "invariants": [asdict(row) for row in analysis.invariants],
        "correlations": [asdict(row) for row in analysis.correlations],
        "nullmodels": [asdict(row) for row in analysis.nullmodels],
        "pca": asdict(analysis.pca) if analysis.pca else None,
        "spectral": asdict(analysis.spectral) if analysis.spectral else None,
        "notes": list(analysis.notes),
    }


def export_atome_bundle(
    analysis: AtomeAnalysis,
    output_dir: Path,
    *,
    stem: str = "atome_residual",
) -> dict[str, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    summary_path = output_dir / f"{stem}_summary.json"
    residual_csv = output_dir / f"{stem}_table.csv"
    correlation_csv = output_dir / f"{stem}_correlations.csv"

    summary_path.write_text(
        json.dumps(_analysis_to_json_dict(analysis), indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    with residual_csv.open("w", encoding="utf-8", newline="") as handle:
        fields = [
            "label", "a", "z", "b_exp_mev", "b_smooth_mev",
            "residual_mev", "residual_per_nucleon_mev", "log_a",
            "eabc_mass", "eabc_spread", "chiral_norm",
        ]
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        inv_by_a = {row.a: row for row in analysis.invariants}
        for row in analysis.residuals:
            inv = inv_by_a[row.a]
            writer.writerow({
                "label": row.label,
                "a": row.a,
                "z": row.z,
                "b_exp_mev": row.b_exp_mev,
                "b_smooth_mev": row.b_smooth_mev,
                "residual_mev": row.residual_mev,
                "residual_per_nucleon_mev": row.residual_per_nucleon_mev,
                "log_a": row.log_a,
                "eabc_mass": inv.eabc_mass,
                "eabc_spread": inv.eabc_spread,
                "chiral_norm": inv.chiral_norm,
            })

    with correlation_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["feature", "pearson_r", "spearman_rho", "mutual_information"],
        )
        writer.writeheader()
        for row in analysis.correlations:
            writer.writerow(asdict(row))

    return {
        "summary_json": summary_path,
        "residual_csv": residual_csv,
        "correlation_csv": correlation_csv,
    }
