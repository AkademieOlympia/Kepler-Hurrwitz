"""
Riemann zero interference wave diagnostic — illustrative [B] export scaffold [C].

Wave sum over imaginary parts gamma_n of zeta zeros:

    f(x) = sum_n cos(gamma_n * ln x)

Hypothesis [C]: constructive interference at primes vs. destructive at bc-axis composite
nodes (35 = 5*7, 143 = 11*13). Governance: illustrative diagnostic only — does NOT prove
symmetry breaking, EABC bivector collapse, or that zeros cause factorization perturbation.

Sibling to E-093 energiedoku Riemann-axis program; see
``docs/theory/riemann_zero_interference_analogy.md``.
"""

from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Sequence

try:
    import numpy as np
except ImportError:  # pragma: no cover
    np = None  # type: ignore[assignment]

try:
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except ImportError:  # pragma: no cover
    plt = None  # type: ignore[assignment]

RIEMANN_INTERFERENCE_TAG = "[C]"
DEFAULT_NUM_ZEROS = 150

# First 150 imaginary parts of non-trivial zeta zeros (Odlyzko / mpmath reference table).
RIEMANN_INTERFERENCE_ZEROS: tuple[float, ...] = (
    14.1347251417347,
    21.0220396387716,
    25.0108575801457,
    30.4248761258595,
    32.9350615877392,
    37.5861781588257,
    40.9187190121475,
    43.327073280915,
    48.0051508811672,
    49.7738324776723,
    52.9703214777145,
    56.4462476970634,
    59.3470440026024,
    60.8317785246098,
    65.1125440480816,
    67.0798105294942,
    69.546401711174,
    72.0671576744819,
    75.7046906990839,
    77.1448400688748,
    79.3373750202494,
    82.910380854086,
    84.7354929805171,
    87.4252746131252,
    88.8091112076345,
    92.4918992705585,
    94.6513440405199,
    95.8706342282453,
    98.8311942181937,
    101.317851005731,
    103.725538040478,
    105.446623052326,
    107.168611184276,
    111.02953554317,
    111.874659176993,
    114.320220915453,
    116.226680320858,
    118.790782865976,
    121.370125002421,
    122.946829293553,
    124.256818554346,
    127.516683879596,
    129.578704199956,
    131.087688530933,
    133.497737202998,
    134.756509753374,
    138.116042054533,
    139.736208952121,
    141.123707404021,
    143.111845807621,
    146.000982486766,
    147.42276534256,
    150.053520420785,
    150.925257612241,
    153.024693811199,
    156.112909294238,
    157.597591817594,
    158.849988171421,
    161.188964137596,
    163.030709687182,
    165.5370691879,
    167.184439978175,
    169.094515415569,
    169.911976479412,
    173.411536519592,
    174.754191523366,
    176.44143429771,
    178.3774077761,
    179.916484020257,
    182.207078484366,
    184.874467848387,
    185.598783677707,
    187.228922583502,
    189.416158656017,
    192.026656360714,
    193.079726603846,
    195.265396679529,
    196.876481840958,
    198.015309676252,
    201.264751943704,
    202.493594514141,
    204.189671803105,
    205.394697202163,
    207.906258887806,
    209.576509716856,
    211.690862595365,
    213.347919359713,
    214.547044783491,
    216.169538508264,
    219.067596349021,
    220.714918839314,
    221.430705554693,
    224.007000254604,
    224.983324669582,
    227.421444279679,
    229.337413305525,
    231.250188700499,
    231.98723525318,
    233.693404178908,
    236.524229665816,
    237.769820480925,
    239.555477573328,
    241.049157796217,
    242.823271934223,
    244.070898497078,
    247.136990074898,
    248.101990060148,
    249.573689644707,
    251.014947795016,
    253.069986747999,
    255.306256454914,
    256.380713694434,
    258.610439491531,
    259.874406989678,
    260.805084504597,
    263.57389390487,
    265.557851838876,
    266.614973781501,
    267.921915082824,
    269.970449023998,
    271.494055641645,
    273.459609188403,
    275.587492649344,
    276.452049503133,
    278.250743529842,
    279.229250927745,
    282.465114765052,
    283.211185733234,
    284.835963980905,
    286.667445363003,
    287.911920501422,
    289.579854929219,
    291.846291329067,
    293.558434139356,
    294.965369619266,
    295.573254878958,
    297.979277061943,
    299.840326053721,
    301.649325462194,
    302.696749589607,
    304.864371340857,
    305.728912602037,
    307.21949612817,
    310.109463146702,
    311.165141530356,
    312.427801180601,
    313.985285731159,
    315.475616089476,
    317.73480594237,
    318.853104256317,
)

BC_AXIS_COMPOSITE_NODES: tuple[int, ...] = (35, 143)
# Nearest lower prime neighbor for separation metrics at bc-axis composites.
BC_AXIS_PRIME_NEIGHBORS: dict[int, int] = {35: 31, 143: 139}
SYMMETRY_BREAKING_TEST_POINTS: tuple[int, ...] = (
    29,
    31,
    35,
    37,
    41,
    137,
    139,
    143,
    149,
)

DEFAULT_PLOT_WINDOWS: tuple[tuple[float, float, int], ...] = (
    (25.0, 45.0, 35),
    (130.0, 155.0, 143),
)

FRACTIONAL_INTERFERENCE_TAG = "[C]"
DEFAULT_FRACTIONAL_ALPHAS: tuple[float, ...] = (0.0, 0.5)

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive analogy with B illustrative plot export",
    "tag_interpretive": RIEMANN_INTERFERENCE_TAG,
    "plot_tag": "[B] illustrative diagnostic only",
    "fractional_kernel": (
        "fractional-weighted interference kernel Phi_R_alpha(x) = "
        "sum cos(gamma ln x) * x^(-alpha); NOT a Caputo derivative implementation"
    ),
    "not_claimed": (
        "proof that Riemann zeros cause EABC symmetry breaking; "
        "proof that zeros cause bivector collapse; "
        "physics identity between explicit-formula oscillations and Pauli stabilizers; "
        "discovery-taugliche prime-vs-composite separation without preregistration; "
        "proof that alpha=0.5 sharpens factorization detection at bc-axis nodes"
    ),
    "sibling_register": "E-095",
    "orq_id": "ORQ-095",
    "related_theory": "docs/theory/riemann_zero_interference_analogy.md",
}

__all__ = [
    "BC_AXIS_COMPOSITE_NODES",
    "DEFAULT_FRACTIONAL_ALPHAS",
    "DEFAULT_NUM_ZEROS",
    "DEFAULT_PLOT_WINDOWS",
    "FRACTIONAL_INTERFERENCE_TAG",
    "GOVERNANCE",
    "RIEMANN_INTERFERENCE_TAG",
    "RIEMANN_INTERFERENCE_ZEROS",
    "SYMMETRY_BREAKING_TEST_POINTS",
    "FractionalComparisonExport",
    "InterferenceNodeRecord",
    "PhaseCollapseExport",
    "calculate_interference_signal",
    "compare_fractional_orders",
    "export_fractional_comparison_bundle",
    "export_phase_collapse_bundle",
    "fractional_interference_signal",
    "fractional_symmetry_breaking_comparison",
    "is_prime",
    "plot_fractional_comparison",
    "plot_phase_collapse",
    "primes_in_range",
    "select_zeros",
    "symmetry_breaking_node_table",
    "evaluate_symmetry_breaking_nodes",
    "wave_function",
]


@dataclass(frozen=True)
class InterferenceNodeRecord:
    x: int
    signal: float
    is_prime: bool
    is_bc_composite: bool
    tag: str = RIEMANN_INTERFERENCE_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class FractionalComparisonExport:
    num_zeros: int
    alphas: tuple[float, ...]
    test_points: tuple[dict[str, Any], ...]
    separation_metrics: dict[str, Any]
    plot_windows: tuple[dict[str, float], ...]
    governance: dict[str, str]
    tag: str = FRACTIONAL_INTERFERENCE_TAG

    def as_dict(self) -> dict[str, Any]:
        return {
            "tag": self.tag,
            "governance": self.governance,
            "num_zeros": self.num_zeros,
            "wave": "sum cos(gamma_n * ln x) * x^(-alpha)",
            "alphas": list(self.alphas),
            "test_points": list(self.test_points),
            "separation_metrics": self.separation_metrics,
            "plot_windows": list(self.plot_windows),
        }


@dataclass(frozen=True)
class PhaseCollapseExport:
    num_zeros: int
    test_points: tuple[InterferenceNodeRecord, ...]
    plot_windows: tuple[dict[str, float], ...]
    governance: dict[str, str]
    tag: str = RIEMANN_INTERFERENCE_TAG

    def as_dict(self) -> dict[str, Any]:
        return {
            "tag": self.tag,
            "governance": self.governance,
            "num_zeros": self.num_zeros,
            "wave": "sum cos(gamma_n * ln x)",
            "test_points": [row.as_dict() for row in self.test_points],
            "plot_windows": list(self.plot_windows),
        }


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def primes_in_range(low: float, high: float) -> tuple[int, ...]:
    start = max(2, math.ceil(low))
    end = math.floor(high)
    return tuple(n for n in range(start, end + 1) if is_prime(n))


def select_zeros(
    gammas: Sequence[float] | None = None,
    *,
    num_zeros: int = DEFAULT_NUM_ZEROS,
) -> tuple[float, ...]:
    source = RIEMANN_INTERFERENCE_ZEROS if gammas is None else tuple(float(g) for g in gammas)
    if num_zeros <= 0:
        raise ValueError("num_zeros must be positive.")
    if num_zeros > len(source):
        raise ValueError(f"num_zeros={num_zeros} exceeds available zeros ({len(source)}).")
    return source[:num_zeros]


def calculate_interference_signal(x: float, gammas: Sequence[float]) -> float:
    """Scalar wave sum f(x) = sum_n cos(gamma_n * ln x) for x > 0."""
    if x <= 0:
        raise ValueError("x must be positive.")
    log_x = math.log(x)
    return sum(math.cos(gamma * log_x) for gamma in gammas)


def wave_function(x_values: Sequence[float], gammas: Sequence[float]):
    """
    Vectorized wave sum over x.

    Returns a NumPy array when NumPy is available, otherwise a list of floats.
    """
    if any(value <= 0 for value in x_values):
        raise ValueError("all x values must be positive.")
    if np is None:
        return [calculate_interference_signal(float(x), gammas) for x in x_values]

    x_arr = np.asarray(x_values, dtype=np.float64)
    gamma_arr = np.asarray(gammas, dtype=np.float64)
    log_x = np.log(x_arr)
    return np.cos(np.outer(gamma_arr, log_x)).sum(axis=0)


def fractional_interference_signal(
    x: float | Sequence[float],
    gammas: Sequence[float],
    *,
    alpha: float = 0.5,
) -> float | list[float]:
    """
    Fractional-weighted interference kernel [C]:

        Phi_R_alpha(x) = sum_n cos(gamma_n * ln x) * x^(-alpha)

    Heuristic memory filter — NOT a Caputo fractional derivative.
    For alpha=0 this reduces to ``calculate_interference_signal``.
    """
    if alpha < 0:
        raise ValueError("alpha must be non-negative.")

    if isinstance(x, (int, float)):
        if x <= 0:
            raise ValueError("x must be positive.")
        weight = float(x) ** (-alpha)
        return calculate_interference_signal(float(x), gammas) * weight

    x_values = [float(value) for value in x]
    if any(value <= 0 for value in x_values):
        raise ValueError("all x values must be positive.")
    if np is None:
        return [
            calculate_interference_signal(value, gammas) * (value ** (-alpha))
            for value in x_values
        ]

    x_arr = np.asarray(x_values, dtype=np.float64)
    base = wave_function(x_arr, gammas)
    return base * np.power(x_arr, -alpha)


def compare_fractional_orders(
    x_values: Sequence[float],
    gammas: Sequence[float],
    *,
    alphas: Sequence[float] = DEFAULT_FRACTIONAL_ALPHAS,
) -> dict[str, Any]:
    """Compare fractional-weighted signals across alpha orders at given x values."""
    points = [float(x) for x in x_values]
    alpha_list = tuple(float(a) for a in alphas)
    rows: list[dict[str, Any]] = []
    for x in points:
        signals: dict[str, float] = {}
        for alpha in alpha_list:
            value = fractional_interference_signal(x, gammas, alpha=alpha)
            signals[f"alpha_{alpha:g}"] = float(value)  # type: ignore[arg-type]
        rows.append({"x": x, "signals": signals})
    return {
        "alphas": list(alpha_list),
        "wave": "sum cos(gamma_n * ln x) * x^(-alpha)",
        "rows": rows,
        "tag": FRACTIONAL_INTERFERENCE_TAG,
    }


def _nearest_prime_neighbor(x: int, candidates: Sequence[int]) -> int | None:
    """Return the designated bc-axis prime neighbor if defined, else closest prime in candidates."""
    if x in BC_AXIS_PRIME_NEIGHBORS:
        neighbor = BC_AXIS_PRIME_NEIGHBORS[x]
        if neighbor in candidates:
            return neighbor
    primes = [p for p in candidates if is_prime(p) and p != x]
    if not primes:
        return None
    return min(primes, key=lambda p: abs(p - x))


def fractional_symmetry_breaking_comparison(
    gammas: Sequence[float],
    test_points: Sequence[int] | None = None,
    *,
    alphas: Sequence[float] = DEFAULT_FRACTIONAL_ALPHAS,
) -> dict[str, Any]:
    """
    Evaluate fractional-weighted signals at bc-axis test nodes for multiple alphas.

    Returns per-point signals plus separation metrics at composite nodes 35 and 143
    vs. their nearest prime neighbors in the test set.
    """
    points = (
        SYMMETRY_BREAKING_TEST_POINTS if test_points is None else tuple(int(p) for p in test_points)
    )
    alpha_list = tuple(float(a) for a in alphas)
    comparison = compare_fractional_orders(points, gammas, alphas=alpha_list)
    rows: list[dict[str, Any]] = []
    for row in comparison["rows"]:
        x = int(row["x"])
        rows.append(
            {
                "x": x,
                "is_prime": is_prime(x),
                "is_bc_composite": x in BC_AXIS_COMPOSITE_NODES,
                "signals": row["signals"],
                "tag": FRACTIONAL_INTERFERENCE_TAG,
            }
        )

    separation_metrics: dict[str, Any] = {}
    for composite in BC_AXIS_COMPOSITE_NODES:
        if composite not in points:
            continue
        neighbor = _nearest_prime_neighbor(composite, points)
        if neighbor is None:
            continue
        by_x = {int(r["x"]): r["signals"] for r in rows}
        for alpha in alpha_list:
            key = f"alpha_{alpha:g}"
            sep = abs(by_x[composite][key] - by_x[neighbor][key])
            separation_metrics[f"x{composite}_vs_{neighbor}_{key}"] = {
                "composite": composite,
                "neighbor_prime": neighbor,
                "alpha": alpha,
                "separation": sep,
                "composite_signal": by_x[composite][key],
                "neighbor_signal": by_x[neighbor][key],
            }

    improves_35: bool | None = None
    improves_143: bool | None = None
    sep0_35 = separation_metrics.get("x35_vs_31_alpha_0", {}).get("separation")
    sep05_35 = separation_metrics.get("x35_vs_31_alpha_0.5", {}).get("separation")
    if sep0_35 is not None and sep05_35 is not None:
        improves_35 = sep05_35 > sep0_35
    sep0_143 = separation_metrics.get("x143_vs_139_alpha_0", {}).get("separation")
    sep05_143 = separation_metrics.get("x143_vs_139_alpha_0.5", {}).get("separation")
    if sep0_143 is not None and sep05_143 is not None:
        improves_143 = sep05_143 > sep0_143

    return {
        "tag": FRACTIONAL_INTERFERENCE_TAG,
        "alphas": list(alpha_list),
        "test_points": rows,
        "separation_metrics": separation_metrics,
        "alpha_0.5_improves_35_vs_31": improves_35,
        "alpha_0.5_improves_143_vs_139": improves_143,
    }


def symmetry_breaking_node_table(
    gammas: Sequence[float],
    *,
    points: Sequence[int] | None = None,
) -> tuple[InterferenceNodeRecord, ...]:
    """Evaluate the interference signal at the user's bc-axis test table."""
    test_points = SYMMETRY_BREAKING_TEST_POINTS if points is None else tuple(int(p) for p in points)
    records: list[InterferenceNodeRecord] = []
    for x in test_points:
        signal = calculate_interference_signal(float(x), gammas)
        records.append(
            InterferenceNodeRecord(
                x=x,
                signal=signal,
                is_prime=is_prime(x),
                is_bc_composite=x in BC_AXIS_COMPOSITE_NODES,
            )
        )
    return tuple(records)


# Public alias (avoid ``test_*`` name — pytest would collect it as a test).
evaluate_symmetry_breaking_nodes = symmetry_breaking_node_table


def plot_fractional_comparison(
    gammas: Sequence[float],
    output_path: str | Path,
    *,
    windows: Sequence[tuple[float, float, int]] | None = None,
    alphas: Sequence[float] = DEFAULT_FRACTIONAL_ALPHAS,
    num_samples: int = 800,
) -> Path:
    """Two-panel overlay of alpha=0 vs alpha=0.5 fractional-weighted interference [B]."""
    if plt is None:
        raise RuntimeError("matplotlib is required for plot_fractional_comparison.")

    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    plot_windows = DEFAULT_PLOT_WINDOWS if windows is None else tuple(windows)
    alpha_list = tuple(float(a) for a in alphas)
    colors = {0.0: "#1f4e79", 0.5: "#e65100"}
    labels = {
        0.0: r"$\alpha=0$: $\sum\cos(\gamma_n\ln x)$",
        0.5: r"$\alpha=0.5$: $\sum\cos(\gamma_n\ln x)\,x^{-1/2}$",
    }

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5), constrained_layout=True)
    for ax, (x_min, x_max, center) in zip(axes, plot_windows, strict=True):
        xs = np.linspace(x_min, x_max, num_samples) if np is not None else [
            x_min + (x_max - x_min) * i / (num_samples - 1) for i in range(num_samples)
        ]
        for alpha in alpha_list:
            ys = fractional_interference_signal(xs, gammas, alpha=alpha)
            color = colors.get(alpha, "#455a64")
            label = labels.get(alpha, rf"$\alpha={alpha:g}$")
            ax.plot(xs, ys, color=color, linewidth=1.4, label=label)

        for prime in primes_in_range(x_min, x_max):
            ax.axvline(prime, color="#2e7d32", linestyle=":", linewidth=1.0, alpha=0.85)

        for composite in BC_AXIS_COMPOSITE_NODES:
            if x_min <= composite <= x_max:
                ax.axvline(
                    composite,
                    color="#c62828",
                    linestyle="--",
                    linewidth=1.2,
                    alpha=0.95,
                )

        ax.axvline(center, color="#6a1b9a", linestyle="-.", linewidth=0.9, alpha=0.6)
        ax.set_title(f"x in [{x_min:g}, {x_max:g}] (center {center})")
        ax.set_xlabel("x")
        ax.set_ylabel(r"$\Phi_{R,\alpha}(x)$")
        ax.grid(True, alpha=0.25)
        ax.legend(loc="upper right", fontsize=8, frameon=False)

    fig.suptitle(
        "Fractional-weighted Riemann interference — alpha=0 vs 0.5 [B]",
        fontsize=11,
    )
    fig.savefig(destination, dpi=160)
    plt.close(fig)
    return destination


def build_fractional_comparison_export(
    *,
    gammas: Sequence[float] | None = None,
    num_zeros: int = DEFAULT_NUM_ZEROS,
    alphas: Sequence[float] = DEFAULT_FRACTIONAL_ALPHAS,
) -> FractionalComparisonExport:
    zeros = select_zeros(gammas, num_zeros=num_zeros)
    alpha_list = tuple(float(a) for a in alphas)
    comparison = fractional_symmetry_breaking_comparison(zeros, alphas=alpha_list)
    return FractionalComparisonExport(
        num_zeros=len(zeros),
        alphas=alpha_list,
        test_points=tuple(comparison["test_points"]),
        separation_metrics=comparison["separation_metrics"],
        plot_windows=tuple(
            {"x_min": low, "x_max": high, "center": center}
            for low, high, center in DEFAULT_PLOT_WINDOWS
        ),
        governance=dict(GOVERNANCE),
    )


def export_fractional_comparison_bundle(
    output_dir: str | Path,
    *,
    gammas: Sequence[float] | None = None,
    num_zeros: int = DEFAULT_NUM_ZEROS,
    alphas: Sequence[float] = DEFAULT_FRACTIONAL_ALPHAS,
    png_name: str = "riemann_fractional_interference_comparison.png",
    json_name: str = "riemann_fractional_interference_comparison.summary.json",
) -> dict[str, Path]:
    """Write fractional alpha comparison PNG and summary JSON."""
    destination = Path(output_dir)
    destination.mkdir(parents=True, exist_ok=True)
    zeros = select_zeros(gammas, num_zeros=num_zeros)
    export = build_fractional_comparison_export(
        gammas=zeros, num_zeros=len(zeros), alphas=alphas
    )
    comparison = fractional_symmetry_breaking_comparison(zeros, alphas=alphas)

    png_path = plot_fractional_comparison(zeros, destination / png_name, alphas=alphas)
    payload = export.as_dict()
    payload["alpha_0.5_improves_35_vs_31"] = comparison["alpha_0.5_improves_35_vs_31"]
    payload["alpha_0.5_improves_143_vs_139"] = comparison["alpha_0.5_improves_143_vs_139"]
    json_path = destination / json_name
    json_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return {"png": png_path, "summary_json": json_path}


def plot_phase_collapse(
    gammas: Sequence[float],
    output_path: str | Path,
    *,
    windows: Sequence[tuple[float, float, int]] | None = None,
    num_samples: int = 800,
) -> Path:
    """Two-panel matplotlib export around bc-axis nodes 35 and 143."""
    if plt is None:
        raise RuntimeError("matplotlib is required for plot_phase_collapse.")

    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    plot_windows = DEFAULT_PLOT_WINDOWS if windows is None else tuple(windows)

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5), constrained_layout=True)
    for ax, (x_min, x_max, center) in zip(axes, plot_windows, strict=True):
        xs = np.linspace(x_min, x_max, num_samples) if np is not None else [
            x_min + (x_max - x_min) * i / (num_samples - 1) for i in range(num_samples)
        ]
        ys = wave_function(xs, gammas)
        ax.plot(xs, ys, color="#1f4e79", linewidth=1.4, label=r"$f(x)=\sum\cos(\gamma_n\ln x)$")

        for prime in primes_in_range(x_min, x_max):
            ax.axvline(prime, color="#2e7d32", linestyle=":", linewidth=1.0, alpha=0.85)

        for composite in BC_AXIS_COMPOSITE_NODES:
            if x_min <= composite <= x_max:
                ax.axvline(
                    composite,
                    color="#c62828",
                    linestyle="--",
                    linewidth=1.2,
                    alpha=0.95,
                )

        ax.axvline(center, color="#6a1b9a", linestyle="-.", linewidth=0.9, alpha=0.6)
        ax.set_title(f"x in [{x_min:g}, {x_max:g}] (center {center})")
        ax.set_xlabel("x")
        ax.set_ylabel("f(x)")
        ax.grid(True, alpha=0.25)

    handles = [
        plt.Line2D([0], [0], color="#1f4e79", linewidth=1.4, label="wave sum"),
        plt.Line2D([0], [0], color="#2e7d32", linestyle=":", label="prime"),
        plt.Line2D([0], [0], color="#c62828", linestyle="--", label="bc composite"),
    ]
    fig.legend(handles=handles, loc="upper center", ncol=3, frameon=False)
    fig.suptitle(
        "Riemann zero interference — illustrative phase-collapse diagnostic [B]",
        fontsize=11,
    )
    fig.savefig(destination, dpi=160)
    plt.close(fig)
    return destination


def build_phase_collapse_export(
    *,
    gammas: Sequence[float] | None = None,
    num_zeros: int = DEFAULT_NUM_ZEROS,
) -> PhaseCollapseExport:
    zeros = select_zeros(gammas, num_zeros=num_zeros)
    return PhaseCollapseExport(
        num_zeros=len(zeros),
        test_points=symmetry_breaking_node_table(zeros),
        plot_windows=tuple(
            {"x_min": low, "x_max": high, "center": center}
            for low, high, center in DEFAULT_PLOT_WINDOWS
        ),
        governance=dict(GOVERNANCE),
    )


def export_phase_collapse_bundle(
    output_dir: str | Path,
    *,
    gammas: Sequence[float] | None = None,
    num_zeros: int = DEFAULT_NUM_ZEROS,
    png_name: str = "riemann_interference_phase_collapse.png",
    json_name: str = "riemann_interference_phase_collapse.summary.json",
) -> dict[str, Path]:
    """Write manuscript PNG and summary JSON with signals at test points."""
    destination = Path(output_dir)
    destination.mkdir(parents=True, exist_ok=True)
    zeros = select_zeros(gammas, num_zeros=num_zeros)
    export = build_phase_collapse_export(gammas=zeros, num_zeros=len(zeros))

    png_path = plot_phase_collapse(zeros, destination / png_name)
    json_path = destination / json_name
    json_path.write_text(json.dumps(export.as_dict(), indent=2), encoding="utf-8")
    return {"png": png_path, "summary_json": json_path}
