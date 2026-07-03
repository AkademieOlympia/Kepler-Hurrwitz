from __future__ import annotations

import array
import json
import math
import os
import sys
from collections.abc import Sequence
from dataclasses import asdict, dataclass
from pathlib import Path

from kepler_hurwitz.kepler_time_bridge import KeplerTimeBridgeRecord

try:
    import numpy as np
except ImportError:  # pragma: no cover - optional acceleration path
    np = None  # type: ignore[assignment]

DEFAULT_RESONANCE_THRESHOLD = 0.05
DEFAULT_SAMPLE_COUNT = 100_000
DEFAULT_ZEROS_PATH = Path("data/riemann_zeros_imag_f8.bin")
DELTA_M_COSINE_METRIC = "delta_M_cosine_mean"
LOG_SCALE_COSINE_METRIC = "log_scale_cosine_mean"


@dataclass(frozen=True)
class RiemannInterferenceResult:
    probe_value: float
    sample_count: int
    interference_factor: float
    variance: float
    is_resonant: bool
    resonance_threshold: float
    metric: str = DELTA_M_COSINE_METRIC

    @property
    def delta_M(self) -> float:
        return self.probe_value


@dataclass(frozen=True)
class RiemannScaleInterferenceResult:
    x0: float
    sample_count: int
    interference_factor: float
    variance: float
    is_resonant: bool
    resonance_threshold: float
    metric: str = LOG_SCALE_COSINE_METRIC


@dataclass(frozen=True)
class RiemannResonanceScenarioResult:
    scenario_name: str
    probe_value: float
    diagnostics: RiemannInterferenceResult

    @property
    def delta_M(self) -> float:
        return self.probe_value


@dataclass(frozen=True)
class RiemannScaleResonanceScenarioResult:
    scenario_name: str
    x0: float
    diagnostics: RiemannScaleInterferenceResult


def default_riemann_zeros_path() -> Path:
    env_path = os.environ.get("RIEMANN_ZEROS_PATH")
    if env_path:
        return Path(env_path)
    return DEFAULT_ZEROS_PATH


def log_scale_from_semi_major(semi_major: float, *, a_0: float = 1.0) -> float:
    if a_0 <= 0.0:
        raise ValueError("a_0 must be positive.")
    if semi_major <= 0.0:
        raise ValueError("semi_major must be positive.")
    return math.log(semi_major / a_0)


def load_riemann_zeros_from_buffer(binary_data: bytes | memoryview) -> array.array[float]:
    """
    Laedt ein little-endian `<f8`-Array mit imaginaeren Teilen der Riemann-Nullstellen.
    """
    zeros = array.array("d")
    zeros.frombytes(bytes(binary_data))
    if sys.byteorder != "little":
        zeros.byteswap()
    return zeros


def load_riemann_zeros_from_file(path: str | Path) -> array.array[float]:
    source = Path(path)
    return load_riemann_zeros_from_buffer(source.read_bytes())


def _effective_sample_count(total_count: int, sample_count: int | None) -> int:
    if total_count <= 0:
        return 0
    if sample_count is None or sample_count <= 0:
        return total_count
    return min(sample_count, total_count)


def _cosine_interference_stats(
    zeros: Sequence[float] | array.array[float],
    scale: float,
    *,
    sample_count: int | None,
) -> tuple[int, float, float]:
    total_count = len(zeros)
    effective_count = _effective_sample_count(total_count, sample_count)
    if effective_count == 0:
        return 0, 0.0, 0.0

    scale_value = float(scale)
    if np is not None:
        sample = np.asarray(zeros[:effective_count], dtype=np.float64)
        cos_values = np.cos(sample * scale_value)
        interference_factor = float(np.mean(cos_values))
        variance = float(np.var(cos_values))
    else:
        cos_values = [math.cos(gamma * scale_value) for gamma in zeros[:effective_count]]
        interference_factor = sum(cos_values) / effective_count
        variance = sum((value - interference_factor) ** 2 for value in cos_values) / effective_count

    return effective_count, interference_factor, variance


def analyze_riemann_interference(
    zeros: Sequence[float] | array.array[float],
    delta_M_value: float,
    *,
    sample_count: int | None = DEFAULT_SAMPLE_COUNT,
    resonance_threshold: float = DEFAULT_RESONANCE_THRESHOLD,
) -> RiemannInterferenceResult:
    """
    Legacy-Metrik S(Delta_M) = mean_k cos(gamma_k * Delta_M).

    Negative Evidenz (E-034): fuer N=2_001_052 konvergiert |S| gegen ~10^-7
    ausser bei Delta_M=0 (triviales cos(0)=1).
    """
    effective_count, interference_factor, variance = _cosine_interference_stats(
        zeros,
        delta_M_value,
        sample_count=sample_count,
    )
    return RiemannInterferenceResult(
        probe_value=float(delta_M_value),
        sample_count=effective_count,
        interference_factor=interference_factor,
        variance=variance,
        is_resonant=abs(interference_factor) > resonance_threshold,
        resonance_threshold=resonance_threshold,
        metric=DELTA_M_COSINE_METRIC,
    )


def analyze_riemann_scale_interference(
    zeros: Sequence[float] | array.array[float],
    x0: float,
    *,
    sample_count: int | None = DEFAULT_SAMPLE_COUNT,
    resonance_threshold: float = DEFAULT_RESONANCE_THRESHOLD,
) -> RiemannScaleInterferenceResult:
    """
    Korrigierte Skalen-Metrik S(x_0) = mean_k cos(gamma_k * x_0) mit x_0 = log(a/a_0).
    """
    effective_count, interference_factor, variance = _cosine_interference_stats(
        zeros,
        x0,
        sample_count=sample_count,
    )
    return RiemannScaleInterferenceResult(
        x0=float(x0),
        sample_count=effective_count,
        interference_factor=interference_factor,
        variance=variance,
        is_resonant=abs(interference_factor) > resonance_threshold,
        resonance_threshold=resonance_threshold,
        metric=LOG_SCALE_COSINE_METRIC,
    )


def _unique_rounded_values(values: Sequence[float], *, round_digits: int = 6) -> tuple[float, ...]:
    return tuple(sorted(set(round(value, round_digits) for value in values)))


def analyze_bridge_record_resonance(
    zeros: Sequence[float] | array.array[float],
    record: KeplerTimeBridgeRecord,
    *,
    sample_count: int | None = DEFAULT_SAMPLE_COUNT,
    resonance_threshold: float = DEFAULT_RESONANCE_THRESHOLD,
) -> tuple[RiemannResonanceScenarioResult, ...]:
    results: list[RiemannResonanceScenarioResult] = []
    for delta_m in record.diagnostics.delta_M_spectrum:
        diagnostics = analyze_riemann_interference(
            zeros,
            delta_m,
            sample_count=sample_count,
            resonance_threshold=resonance_threshold,
        )
        results.append(
            RiemannResonanceScenarioResult(
                scenario_name=record.control_name,
                probe_value=delta_m,
                diagnostics=diagnostics,
            )
        )
    return tuple(results)


def analyze_bridge_record_scale_resonance(
    zeros: Sequence[float] | array.array[float],
    record: KeplerTimeBridgeRecord,
    *,
    sample_count: int | None = DEFAULT_SAMPLE_COUNT,
    resonance_threshold: float = DEFAULT_RESONANCE_THRESHOLD,
    round_digits: int = 6,
) -> tuple[RiemannScaleResonanceScenarioResult, ...]:
    x0_spectrum = _unique_rounded_values(record.raw_log_scale_series, round_digits=round_digits)
    results: list[RiemannScaleResonanceScenarioResult] = []
    for x0 in x0_spectrum:
        diagnostics = analyze_riemann_scale_interference(
            zeros,
            x0,
            sample_count=sample_count,
            resonance_threshold=resonance_threshold,
        )
        results.append(
            RiemannScaleResonanceScenarioResult(
                scenario_name=record.control_name,
                x0=x0,
                diagnostics=diagnostics,
            )
        )
    return tuple(results)


def run_riemann_resonance_from_bridge_records(
    bridge_records: Sequence[KeplerTimeBridgeRecord],
    zeros: Sequence[float] | array.array[float],
    *,
    sample_count: int | None = DEFAULT_SAMPLE_COUNT,
    resonance_threshold: float = DEFAULT_RESONANCE_THRESHOLD,
) -> tuple[RiemannResonanceScenarioResult, ...]:
    results: list[RiemannResonanceScenarioResult] = []
    for record in bridge_records:
        results.extend(
            analyze_bridge_record_resonance(
                zeros,
                record,
                sample_count=sample_count,
                resonance_threshold=resonance_threshold,
            )
        )
    return tuple(results)


def run_riemann_scale_resonance_from_bridge_records(
    bridge_records: Sequence[KeplerTimeBridgeRecord],
    zeros: Sequence[float] | array.array[float],
    *,
    sample_count: int | None = DEFAULT_SAMPLE_COUNT,
    resonance_threshold: float = DEFAULT_RESONANCE_THRESHOLD,
    round_digits: int = 6,
) -> tuple[RiemannScaleResonanceScenarioResult, ...]:
    results: list[RiemannScaleResonanceScenarioResult] = []
    for record in bridge_records:
        results.extend(
            analyze_bridge_record_scale_resonance(
                zeros,
                record,
                sample_count=sample_count,
                resonance_threshold=resonance_threshold,
                round_digits=round_digits,
            )
        )
    return tuple(results)


def export_riemann_resonance_json(
    results: Sequence[RiemannResonanceScenarioResult],
    output_path: str | Path,
    *,
    metric: str = DELTA_M_COSINE_METRIC,
    verdict: str = "negative_evidence",
    zeros_count: int | None = None,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "metric": metric,
        "verdict": verdict,
        "zeros_count": zeros_count,
        "results": [
            {
                "scenario_name": result.scenario_name,
                "delta_M": result.probe_value,
                **asdict(result.diagnostics),
            }
            for result in results
        ],
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_riemann_scale_resonance_json(
    results: Sequence[RiemannScaleResonanceScenarioResult],
    output_path: str | Path,
    *,
    metric: str = LOG_SCALE_COSINE_METRIC,
    verdict: str = "open_hypothesis",
    zeros_count: int | None = None,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "metric": metric,
        "verdict": verdict,
        "zeros_count": zeros_count,
        "results": [
            {
                "scenario_name": result.scenario_name,
                "x0": result.x0,
                **asdict(result.diagnostics),
            }
            for result in results
        ],
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_resonance_table(
    results: Sequence[RiemannResonanceScenarioResult],
) -> str:
    lines = [
        "scenario               | delta_M   | interference | variance   | resonant",
        "-" * 78,
    ]
    for result in results:
        diag = result.diagnostics
        resonant = "yes" if diag.is_resonant else "no"
        lines.append(
            f"{result.scenario_name:22s} | {result.probe_value:9.5f} | "
            f"{diag.interference_factor:12.6f} | {diag.variance:10.6f} | {resonant:8s}"
        )
    return "\n".join(lines)


def format_scale_resonance_table(
    results: Sequence[RiemannScaleResonanceScenarioResult],
) -> str:
    lines = [
        "scenario               | x0        | interference | variance   | resonant",
        "-" * 78,
    ]
    for result in results:
        diag = result.diagnostics
        resonant = "yes" if diag.is_resonant else "no"
        lines.append(
            f"{result.scenario_name:22s} | {result.x0:9.5f} | "
            f"{diag.interference_factor:12.6f} | {diag.variance:10.6f} | {resonant:8s}"
        )
    return "\n".join(lines)


def known_zeros_head(count: int = 8) -> array.array[float]:
    """
    Kleine Referenzmenge der ersten Riemann-Nullstellen fuer Tests und Demos.
    """
    head = (
        14.134725141734693,
        21.022039638771554,
        25.010857580145688,
        30.424876125859513,
        32.93506158773919,
        37.58617815882567,
        40.918719012147495,
        43.32707328091499,
    )
    return array.array("d", head[:count])
