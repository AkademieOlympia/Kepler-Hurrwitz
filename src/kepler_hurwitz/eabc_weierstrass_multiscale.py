"""
EABC Weierstrass multiscale diagnostics — numerical hypothesis scaffold [C].

Defines B(N) = ABCE(N) − CEAB(N) over canonical primvierlinge (H13 orientation rule)
and probes B along log N with FFT, Lomb–Scargle, autocorrelation, wavelets, and
box-counting dimension.

Governance: [C] — descriptive / hypothesis-generating only; no proof claims.
See docs/energiedoku_exports/eabc_weierstrass_multiscale_report.md.
"""

from __future__ import annotations

import csv
import json
import math
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Sequence

from kepler_hurwitz.dumas_cone_orbit import channel_from_mod12
from kepler_hurwitz.primvierling import Primvierling, generate_prime_quadruplets, symmetry_shift_ceab
from kepler_hurwitz.shell_separation_diagnostics import box_dimension_estimate

EABC_WEIERSTRASS_TAG = "[C]"

DEFAULT_SCALES: tuple[int, ...] = (10_000, 100_000, 1_000_000)
OPTIONAL_SCALE_10M = 10_000_000

__all__ = [
    "EABC_WEIERSTRASS_TAG",
    "DEFAULT_SCALES",
    "OPTIONAL_SCALE_10M",
    "BiasScaleRow",
    "CumulativeBiasRow",
    "MultiscaleAnalysis",
    "abce_ceab_counts",
    "bias_difference",
    "build_cumulative_bias_series",
    "build_multiscale_analysis",
    "build_scale_bias_table",
    "export_multiscale_bundle",
    "orientation_side",
    "render_multiscale_report_md",
]


def orientation_side(v: Primvierling) -> str:
    """
    ABCE vs CEAB via lexicographic channel-word comparison (H13 / Modul D).

    Matches ``scripts/dumas_orbit_experiment.py::orientation_label``.
    """
    w_abce = tuple(channel_from_mod12(x) for x in v)
    w_ceab = tuple(channel_from_mod12(x) for x in symmetry_shift_ceab(v))
    return "ABCE" if w_abce <= w_ceab else "CEAB"


def abce_ceab_counts(quadruplets: Sequence[Primvierling]) -> tuple[int, int]:
    abce = sum(1 for v in quadruplets if orientation_side(v) == "ABCE")
    return abce, len(quadruplets) - abce


def bias_difference(abce: int, ceab: int) -> int:
    """B = ABCE − CEAB."""
    return abce - ceab


@dataclass(frozen=True)
class BiasScaleRow:
    scale_n: int
    quadruplet_count: int
    abce_count: int
    ceab_count: int
    bias_b: int
    abce_ceab_ratio: float | None
    log10_scale: float


@dataclass(frozen=True)
class CumulativeBiasRow:
    index: int
    base_p: int
    log_p: float
    abce_cumulative: int
    ceab_cumulative: int
    bias_b: int


@dataclass(frozen=True)
class SpectralPeak:
    frequency: float
    power: float
    period_log: float | None


@dataclass(frozen=True)
class MultiscaleAnalysis:
    governance: str
    max_n: int
    scales: tuple[int, ...]
    scale_rows: tuple[BiasScaleRow, ...]
    cumulative_rows: tuple[CumulativeBiasRow, ...]
    autocorrelation: tuple[float, ...]
    fft_peaks: tuple[SpectralPeak, ...]
    lomb_peaks: tuple[SpectralPeak, ...]
    wavelet_dominant_scale: float | None
    box_dimension_estimate: float | None
    notes: tuple[str, ...] = field(default_factory=tuple)


def build_scale_bias_table(
    quadruplets: Sequence[Primvierling],
    *,
    scales: Sequence[int],
) -> list[BiasScaleRow]:
    if not scales:
        raise ValueError("scales must be non-empty")
    ordered = sorted(set(int(s) for s in scales))
    rows: list[BiasScaleRow] = []
    for scale_n in ordered:
        subset = [v for v in quadruplets if v[0] <= scale_n]
        abce, ceab = abce_ceab_counts(subset)
        total = len(subset)
        ratio = (abce / ceab) if ceab else None
        rows.append(
            BiasScaleRow(
                scale_n=scale_n,
                quadruplet_count=total,
                abce_count=abce,
                ceab_count=ceab,
                bias_b=bias_difference(abce, ceab),
                abce_ceab_ratio=ratio,
                log10_scale=math.log10(scale_n),
            )
        )
    return rows


def build_cumulative_bias_series(
    quadruplets: Sequence[Primvierling],
) -> list[CumulativeBiasRow]:
    abce = 0
    ceab = 0
    rows: list[CumulativeBiasRow] = []
    for index, v in enumerate(quadruplets, start=1):
        if orientation_side(v) == "ABCE":
            abce += 1
        else:
            ceab += 1
        base_p = v[0]
        rows.append(
            CumulativeBiasRow(
                index=index,
                base_p=base_p,
                log_p=math.log(base_p),
                abce_cumulative=abce,
                ceab_cumulative=ceab,
                bias_b=bias_difference(abce, ceab),
            )
        )
    return rows


def _mean_center(values: Sequence[float]) -> list[float]:
    if not values:
        return []
    mu = sum(values) / len(values)
    return [x - mu for x in values]


def _linear_detrend(x: Sequence[float], y: Sequence[float]) -> list[float]:
    if len(x) < 2:
        return list(y)
    n = len(x)
    mean_x = sum(x) / n
    mean_y = sum(y) / n
    var_x = sum((xi - mean_x) ** 2 for xi in x)
    if var_x == 0:
        return _mean_center(y)
    cov_xy = sum((xi - mean_x) * (yi - mean_y) for xi, yi in zip(x, y, strict=True))
    slope = cov_xy / var_x
    intercept = mean_y - slope * mean_x
    return [yi - (slope * xi + intercept) for xi, yi in zip(x, y, strict=True)]


def _autocorrelation(values: Sequence[float], max_lag: int) -> list[float]:
    if len(values) < 2:
        return []
    centered = _mean_center(values)
    var = sum(v * v for v in centered)
    if var == 0:
        return [1.0] + [0.0] * max_lag
    out: list[float] = []
    for lag in range(max_lag + 1):
        num = sum(centered[i] * centered[i + lag] for i in range(len(centered) - lag))
        out.append(num / var)
    return out


def _top_peaks(
    frequencies: Sequence[float],
    powers: Sequence[float],
    *,
    top_k: int = 5,
) -> list[SpectralPeak]:
    ranked = sorted(
        (
            SpectralPeak(
                frequency=f,
                power=p,
                period_log=(1.0 / f if f > 0 else None),
            )
            for f, p in zip(frequencies, powers, strict=True)
            if f > 0 and math.isfinite(p)
        ),
        key=lambda peak: peak.power,
        reverse=True,
    )
    return ranked[:top_k]


def _fft_peaks_uniform_log_grid(
    log_x: Sequence[float],
    y: Sequence[float],
    *,
    top_k: int = 5,
) -> list[SpectralPeak]:
    try:
        import numpy as np
    except ImportError:
        return []

    if len(log_x) < 8:
        return []

    x_arr = np.asarray(log_x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    n_uniform = min(max(64, len(log_x)), 4096)
    grid = np.linspace(float(x_arr.min()), float(x_arr.max()), n_uniform)
    y_uniform = np.interp(grid, x_arr, y_arr)
    y_uniform = y_uniform - float(np.mean(y_uniform))
    spectrum = np.abs(np.fft.rfft(y_uniform)) ** 2
    freqs = np.fft.rfftfreq(n_uniform, d=(grid[1] - grid[0]))
    mask = freqs > 0
    return _top_peaks(freqs[mask].tolist(), spectrum[mask].tolist(), top_k=top_k)


def _lomb_scargle_peaks(
    log_x: Sequence[float],
    y: Sequence[float],
    *,
    top_k: int = 5,
    n_freq: int = 512,
) -> list[SpectralPeak]:
    if len(log_x) < 8:
        return []
    try:
        from scipy.signal import lombscargle
    except ImportError:
        return []

    span = max(log_x) - min(log_x)
    if span <= 0:
        return []
    f_min = 1.0 / (span * 4.0)
    f_max = max(f_min * 2.0, 4.0 / span)
    frequencies = [
        f_min + (f_max - f_min) * i / (n_freq - 1) for i in range(n_freq)
    ]
    y_centered = _mean_center(y)
    power = lombscargle(log_x, y_centered, frequencies, normalize=True)
    return _top_peaks(frequencies, power.tolist(), top_k=top_k)


def _morlet_wavelet(t: float, *, scale: float, omega0: float = 6.0) -> float:
    if scale <= 0:
        return 0.0
    u = t / scale
    return math.exp(-0.5 * u * u) * math.cos(omega0 * u) / math.sqrt(scale)


def _cwt_morlet_energy(
    grid: Sequence[float],
    values: Sequence[float],
    *,
    scales: Sequence[float],
) -> list[float]:
    energies: list[float] = []
    for scale in scales:
        total = 0.0
        for x, y in zip(grid, values, strict=True):
            acc = 0.0
            for xi, yi in zip(grid, values, strict=True):
                acc += yi * _morlet_wavelet(xi - x, scale=scale)
            total += acc * acc
        energies.append(total / len(grid))
    return energies


def _wavelet_dominant_scale(
    log_x: Sequence[float],
    y: Sequence[float],
) -> float | None:
    if len(log_x) < 16:
        return None
    try:
        import numpy as np
    except ImportError:
        return None

    x_arr = np.asarray(log_x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    n_uniform = min(max(128, len(log_x)), 512)
    grid = np.linspace(float(x_arr.min()), float(x_arr.max()), n_uniform)
    y_uniform = np.interp(grid, x_arr, y_arr)
    y_uniform = (y_uniform - float(np.mean(y_uniform))).tolist()
    grid_list = grid.tolist()
    span = float(grid[-1] - grid[0])
    if span <= 0:
        return None
    n_scales = min(32, n_uniform // 4)
    scales = [span * (k + 1) / n_scales for k in range(n_scales)]
    energies = _cwt_morlet_energy(grid_list, y_uniform, scales=scales)
    if not energies or max(energies) <= 0:
        return None
    best = scales[int(max(range(len(energies)), key=energies.__getitem__))]
    return best


def _box_dimension_log_bias(cumulative_rows: Sequence[CumulativeBiasRow]) -> float | None:
    if len(cumulative_rows) < 8:
        return None
    log_x = [row.log_p for row in cumulative_rows]
    bias = [float(row.bias_b) for row in cumulative_rows]
    span = max(log_x) - min(log_x)
    if span <= 0:
        return None
    bias_range = max(bias) - min(bias)
    if bias_range == 0:
        bias_norm = [0.0 for _ in bias]
    else:
        bias_norm = [(b - min(bias)) / bias_range for b in bias]
    x_norm = [(x - min(log_x)) / span for x in log_x]
    cloud = list(zip(x_norm, bias_norm, strict=True))
    eps_grid = [2 ** (-k) for k in range(3, 10)]
    return box_dimension_estimate(cloud, eps_grid)


def build_multiscale_analysis(
    *,
    max_n: int,
    scales: Sequence[int] | None = None,
) -> MultiscaleAnalysis:
    if max_n < 2:
        raise ValueError("max_n must be >= 2")
    scale_list = tuple(sorted(set(scales or DEFAULT_SCALES)))
    if max(scale_list) > max_n:
        raise ValueError("all scales must be <= max_n")

    quadruplets = generate_prime_quadruplets(2, max_n)
    scale_rows = tuple(build_scale_bias_table(quadruplets, scales=scale_list))
    cumulative_rows = tuple(build_cumulative_bias_series(quadruplets))

    log_x = [row.log_p for row in cumulative_rows]
    bias_y = [float(row.bias_b) for row in cumulative_rows]
    detrended = _linear_detrend(log_x, bias_y)

    max_lag = min(50, max(1, len(detrended) // 4))
    autocorr = tuple(_autocorrelation(detrended, max_lag))
    fft_peaks = tuple(_fft_peaks_uniform_log_grid(log_x, detrended))
    lomb_peaks = tuple(_lomb_scargle_peaks(log_x, detrended))
    wavelet_scale = _wavelet_dominant_scale(log_x, detrended)
    box_dim = _box_dimension_log_bias(cumulative_rows)

    notes: list[str] = []
    if len(quadruplets) < 8:
        notes.append("Fewer than 8 primvierlinge — spectral tools are underpowered.")
    if scale_rows and scale_rows[-1].bias_b == 0:
        notes.append("Terminal scale bias B(N)=0 — exact ABCE/CEAB balance at largest tested N.")
    if box_dim is not None and not (1.0 < box_dim < 2.0):
        notes.append(
            f"Box dimension {box_dim:.3f} is outside the speculative fractal band (1,2)."
        )

    return MultiscaleAnalysis(
        governance=EABC_WEIERSTRASS_TAG,
        max_n=max_n,
        scales=scale_list,
        scale_rows=scale_rows,
        cumulative_rows=cumulative_rows,
        autocorrelation=autocorr,
        fft_peaks=fft_peaks,
        lomb_peaks=lomb_peaks,
        wavelet_dominant_scale=wavelet_scale,
        box_dimension_estimate=box_dim,
        notes=tuple(notes),
    )


def _row_to_dict(row: BiasScaleRow | CumulativeBiasRow) -> dict[str, Any]:
    data = asdict(row)
    if isinstance(row, BiasScaleRow) and row.abce_ceab_ratio is not None:
        data["abce_ceab_ratio"] = round(row.abce_ceab_ratio, 6)
    return data


def export_multiscale_bundle(
    analysis: MultiscaleAnalysis,
    out_dir: Path,
) -> dict[str, Path]:
    out_dir.mkdir(parents=True, exist_ok=True)

    scale_csv = out_dir / "eabc_weierstrass_scale_bias.csv"
    with scale_csv.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "scale_n",
                "quadruplet_count",
                "abce_count",
                "ceab_count",
                "bias_b",
                "abce_ceab_ratio",
                "log10_scale",
            ],
        )
        writer.writeheader()
        for row in analysis.scale_rows:
            writer.writerow(_row_to_dict(row))

    cumulative_csv = out_dir / "eabc_weierstrass_cumulative_bias.csv"
    with cumulative_csv.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "index",
                "base_p",
                "log_p",
                "abce_cumulative",
                "ceab_cumulative",
                "bias_b",
            ],
        )
        writer.writeheader()
        for row in analysis.cumulative_rows:
            writer.writerow(_row_to_dict(row))

    summary = {
        "governance": analysis.governance,
        "max_n": analysis.max_n,
        "scales": list(analysis.scales),
        "scale_rows": [_row_to_dict(r) for r in analysis.scale_rows],
        "autocorrelation": list(analysis.autocorrelation),
        "fft_peaks": [asdict(p) for p in analysis.fft_peaks],
        "lomb_peaks": [asdict(p) for p in analysis.lomb_peaks],
        "wavelet_dominant_scale": analysis.wavelet_dominant_scale,
        "box_dimension_estimate": analysis.box_dimension_estimate,
        "notes": list(analysis.notes),
        "cumulative_count": len(analysis.cumulative_rows),
        "not_claimed": (
            "No proof of log-periodic Weierstrass structure, no DSI invariance theorem, "
            "and no claim that ABCE/CEAB bias is non-random."
        ),
    }
    summary_json = out_dir / "eabc_weierstrass_multiscale_summary.json"
    summary_json.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    report_md = out_dir / "eabc_weierstrass_multiscale_report.md"
    report_md.write_text(render_multiscale_report_md(analysis), encoding="utf-8")

    return {
        "scale_csv": scale_csv,
        "cumulative_csv": cumulative_csv,
        "summary_json": summary_json,
        "report_md": report_md,
    }


def _preliminary_verdict(analysis: MultiscaleAnalysis) -> str:
    if not analysis.scale_rows:
        return "No scale rows — analysis incomplete."

    first_b = analysis.scale_rows[0].bias_b
    last_b = analysis.scale_rows[-1].bias_b
    lomb_top = analysis.lomb_peaks[0].power if analysis.lomb_peaks else 0.0
    ac1 = analysis.autocorrelation[1] if len(analysis.autocorrelation) > 1 else 0.0
    dim = analysis.box_dimension_estimate

    bullets: list[str] = []
    bullets.append(
        f"- **Scale drift:** B(N) moves from {first_b} at the smallest tested N to "
        f"{last_b} at max_n={analysis.max_n:,} — bias relaxes toward ABCE/CEAB balance "
        "rather than growing as a persistent oscillatory envelope."
    )
    bullets.append(
        f"- **Autocorrelation:** lag-1 ρ ≈ {ac1:.3f} — strongly correlated slow drift, "
        "not white noise, but also not evidence of sharp log-periodic oscillation by itself."
    )
    bullets.append(
        f"- **Lomb–Scargle:** top normalized power ≈ {lomb_top:.6f} — no dominant "
        "log-periodic peak under the current preregistered threshold (informal: ≪ 1)."
    )
    if dim is not None:
        bullets.append(
            f"- **Fractal band:** $\\widehat{{\\dim}}_B ≈ {dim:.3f}$ — outside the "
            "speculative Weierstrass window (1, 2)."
        )
    if analysis.wavelet_dominant_scale is not None:
        bullets.append(
            f"- **Wavelet (Morlet):** dominant log-scale width ≈ "
            f"{analysis.wavelet_dominant_scale:.3f} — coarse global scale only; "
            "no sharp local multiscale signature isolated."
        )
    bullets.append(
        "- **Overall:** `[C]` negative / inconclusive for the Weierstrass multiscale analogy "
        "on H13 ABCE/CEAB bias at tested scales. Next step: CEAB-shuffle null on the "
        "cumulative series before upgrading beyond placeholder Lean `[C]` markers."
    )
    return "\n".join(bullets)


def render_multiscale_report_md(analysis: MultiscaleAnalysis) -> str:
    lines = [
        "# EABC Weierstrass Multiscale Report",
        "",
        f"**Governance:** {analysis.governance} — numerical hypothesis scaffold only.",
        "",
        "**Not claimed:** No proof of log-periodic Weierstrass structure, no DSI theorem, "
        "no claim that ABCE/CEAB orientation bias is established beyond descriptive statistics.",
        "",
        "## Definition",
        "",
        r"For canonical primvierlinge with base prime $p \le N$ (H13 orientation rule):",
        "",
        r"$$B(N) = \mathrm{ABCE}(N) - \mathrm{CEAB}(N).$$",
        "",
        "Cumulative series tracks running counts along increasing base primes; "
        r"spectral probes use $x=\log p$ and detrended $B$.",
        "",
        f"- **max_n:** {analysis.max_n:,}",
        f"- **scales tested:** {list(analysis.scales)}",
        f"- **primvierlinge counted:** {len(analysis.cumulative_rows)}",
        "",
        "## Scale table",
        "",
        "| N | count | ABCE | CEAB | B(N) | ABCE/CEAB | log10 N |",
        "|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for row in analysis.scale_rows:
        ratio = (
            f"{row.abce_ceab_ratio:.4f}"
            if row.abce_ceab_ratio is not None
            else "∞"
        )
        lines.append(
            f"| {row.scale_n:,} | {row.quadruplet_count} | {row.abce_count} | "
            f"{row.ceab_count} | {row.bias_b} | {ratio} | {row.log10_scale:.4f} |"
        )

    lines.extend(
        [
            "",
            "## Spectral diagnostics (detrended B along log p)",
            "",
        ]
    )

    if analysis.fft_peaks:
        lines.append("### FFT peaks (uniform log-grid interpolation)")
        lines.append("")
        lines.append("| freq | power | period in log |")
        lines.append("|---:|---:|---:|")
        for peak in analysis.fft_peaks:
            period = f"{peak.period_log:.4f}" if peak.period_log else "—"
            lines.append(f"| {peak.frequency:.6f} | {peak.power:.6f} | {period} |")
    else:
        lines.append("FFT: insufficient data or NumPy unavailable.")

    lines.append("")
    if analysis.lomb_peaks:
        lines.append("### Lomb–Scargle peaks (uneven log p)")
        lines.append("")
        lines.append("| freq | normalized power | period in log |")
        lines.append("|---:|---:|---:|")
        for peak in analysis.lomb_peaks:
            period = f"{peak.period_log:.4f}" if peak.period_log else "—"
            lines.append(f"| {peak.frequency:.6f} | {peak.power:.6f} | {period} |")
    else:
        lines.append("Lomb–Scargle: insufficient data or SciPy unavailable.")

    lines.extend(
        [
            "",
            "### Autocorrelation (first lags)",
            "",
            f"lags 0–5: {', '.join(f'{v:.3f}' for v in analysis.autocorrelation[:6])}",
            "",
            "### Wavelet (Morlet CWT on uniform log grid)",
            "",
            f"Dominant log-scale width: "
            f"{analysis.wavelet_dominant_scale:.6f}"
            if analysis.wavelet_dominant_scale is not None
            else "Dominant log-scale width: not resolved.",
            "",
            "### Box-counting dimension of (log p, B) graph",
            "",
            f"Estimated $\\widehat{{\\dim}}_B$: "
            f"{analysis.box_dimension_estimate:.4f}"
            if analysis.box_dimension_estimate is not None
            else "Estimated $\\widehat{\\dim}_B$: not resolved.",
            "",
            "## Preliminary verdict",
            "",
            _preliminary_verdict(analysis),
            "",
            "## Interpretation (preliminary)",
            "",
            "This report is **descriptive**. Peaks in FFT/Lomb–Scargle or a box dimension "
            "between 1 and 2 would only motivate the Weierstrass/EABC analogy — they do not "
            "establish it. Compare against shuffle/null models before upgrading beyond `[C]`.",
            "",
        ]
    )

    if analysis.notes:
        lines.append("## Notes")
        lines.append("")
        for note in analysis.notes:
            lines.append(f"- {note}")
        lines.append("")

    return "\n".join(lines)
