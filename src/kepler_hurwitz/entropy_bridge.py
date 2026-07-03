from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass
from fractions import Fraction
from pathlib import Path
from typing import Any, Sequence

from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators
from kepler_hurwitz.metacommutation import classify_shell_operator_metacommutation

BALANCED_SPLIT = 0.5
N6_ASSOCIATIVE_RATIO = 0.767
N6_RATIONAL_RHO = Fraction(23, 30)
N6_SHELL_PROXY_NORM = 6
H3_BIFURCATION_X0 = 1.0
DEFAULT_TRANSITION_MATRIX_PATH = (
    Path(__file__).resolve().parents[2] / "docs" / "energiedoku_exports" / "arithmetic_transition_matrix.json"
)


@dataclass(frozen=True)
class AlgebraicLayerMetrics:
    """Statement A: associator-collapse density on the metacommutation layer."""

    rho_alg: float
    H_alg_bits: float
    operator_defect: float
    trace_distance_from_balanced: float


@dataclass(frozen=True)
class DynamicLayerMetrics:
    """Statement B: observed row law from the arithmetic transition matrix."""

    operator_label: str
    actual_norm: int
    x0_from: float
    P_row: tuple[tuple[float, float], ...]
    p_dyn_max: float
    H_row_bits: float


@dataclass(frozen=True)
class QuantizationLayerMetrics:
    """Statement C: explicit bridge via symmetry projection Q_sym and gap G."""

    Q_sym: tuple[float, float]
    H_Q_sym_bits: float
    quantization_gap: float
    quantization_gap_rational: str | None


@dataclass(frozen=True)
class EntropyBridgeReport:
    algebraic: AlgebraicLayerMetrics
    dynamic: DynamicLayerMetrics
    quantization: QuantizationLayerMetrics


def binary_entropy_h2(top_weight: float) -> float:
    """Binary Shannon entropy H_2(p) in bits for distribution (p, 1-p)."""
    p = top_weight
    if p <= 0.0 or p >= 1.0:
        return 0.0
    q = 1.0 - p
    return -(p * math.log2(p) + q * math.log2(q))


def quantize_symmetric_binary(rho_alg: float) -> tuple[float, float]:
    """
    Q_sym: symmetry-preserving two-branch projection on the observed window.

    At (N=6, x_0=1) the dynamical matrix enforces a balanced split; Q_sym maps any
    algebraic density weight to that symmetric resolution. The input is retained only
    to document that Q_sym is a layer map, not a trivial identity on rho_alg.
    """
    _ = rho_alg
    return (BALANCED_SPLIT, BALANCED_SPLIT)


def quantization_gap(rho_alg: float, *, p_dyn_max: float) -> float:
    """
    G = rho_alg - max_k P_k on the observed dynamic row.

    Equivalently G = rho_alg - max Q_sym(rho_alg) in the symmetric window.
    """
    return rho_alg - p_dyn_max


def quantization_gap_from_rho_only(rho_alg: float) -> float:
    """G = rho - 1/2 using the symmetric projection Q_sym(rho) = (1/2, 1/2)."""
    p_sym, _q_sym = quantize_symmetric_binary(rho_alg)
    return rho_alg - p_sym


def operator_defect(top_weight: float, *, balanced: float = BALANCED_SPLIT) -> float:
    return top_weight - balanced


def trace_distance_from_balanced(top_weight: float, *, balanced: float = BALANCED_SPLIT) -> float:
    return 2.0 * abs(top_weight - balanced)


def algebraic_layer_metrics(rho_alg: float) -> AlgebraicLayerMetrics:
    return AlgebraicLayerMetrics(
        rho_alg=rho_alg,
        H_alg_bits=binary_entropy_h2(rho_alg),
        operator_defect=operator_defect(rho_alg),
        trace_distance_from_balanced=trace_distance_from_balanced(rho_alg),
    )


def load_transition_matrix(path: Path | None = None) -> dict[str, Any]:
    matrix_path = path or DEFAULT_TRANSITION_MATRIX_PATH
    with matrix_path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def _row_probabilities_from_json(
    payload: dict[str, Any],
    *,
    operator_label: str,
    x0_from: float,
    round_digits: int = 6,
) -> tuple[tuple[float, float], ...]:
    grouped: dict[float, float] = {}
    for entry in payload.get("entries", []):
        if entry.get("operator_label") != operator_label:
            continue
        if round(entry.get("x0_from", 0.0), round_digits) != round(x0_from, round_digits):
            continue
        x0_to = float(entry["x0_to"])
        grouped[x0_to] = grouped.get(x0_to, 0.0) + float(entry["row_probability"])
    return tuple(sorted(grouped.items()))


def row_entropy_bits(probabilities: Sequence[tuple[float, float]]) -> float:
    entropy = 0.0
    for _target, prob in probabilities:
        if prob > 0.0:
            entropy -= prob * math.log2(prob)
    return entropy


def dynamic_layer_metrics_from_json(
    payload: dict[str, Any],
    *,
    operator_label: str = "shell_proxy_N6_for_5",
    x0_from: float = H3_BIFURCATION_X0,
) -> DynamicLayerMetrics:
    p_row = _row_probabilities_from_json(payload, operator_label=operator_label, x0_from=x0_from)
    if not p_row:
        raise ValueError(f"No transition row for operator={operator_label!r}, x0_from={x0_from!r}.")
    p_dyn_max = max(prob for _target, prob in p_row)
    actual_norm = next(
        (
            int(entry["actual_norm"])
            for entry in payload.get("entries", [])
            if entry.get("operator_label") == operator_label
        ),
        N6_SHELL_PROXY_NORM,
    )
    return DynamicLayerMetrics(
        operator_label=operator_label,
        actual_norm=actual_norm,
        x0_from=x0_from,
        P_row=p_row,
        p_dyn_max=p_dyn_max,
        H_row_bits=row_entropy_bits(p_row),
    )


def quantization_layer_metrics(rho_alg: float, *, p_dyn_max: float) -> QuantizationLayerMetrics:
    q_sym = quantize_symmetric_binary(rho_alg)
    rational_gap: str | None = None
    if abs(rho_alg - float(N6_RATIONAL_RHO)) < 1e-9:
        rational_gap = "4/15"
    return QuantizationLayerMetrics(
        Q_sym=q_sym,
        H_Q_sym_bits=row_entropy_bits(((0.0, q_sym[0]), (1.0, q_sym[1]))),
        quantization_gap=quantization_gap(rho_alg, p_dyn_max=p_dyn_max),
        quantization_gap_rational=rational_gap,
    )


def shell_associative_ratio(*, shell_index: int = 1) -> float:
    shell_ops = tuple(operator.element for operator in default_arithmetic_prime_operators())
    report = classify_shell_operator_metacommutation(shell_ops)
    key = f"shell_operator_{shell_index}"
    if key not in report:
        raise KeyError(f"Missing shell metacommutation profile {key!r}.")
    return float(report[key]["associative_ratio"])


def build_entropy_bridge_report(
    *,
    transition_matrix_path: Path | None = None,
    associative_ratio: float | None = None,
) -> EntropyBridgeReport:
    payload = load_transition_matrix(transition_matrix_path)
    rho_alg = N6_ASSOCIATIVE_RATIO if associative_ratio is None else associative_ratio
    if associative_ratio is None:
        try:
            rho_alg = shell_associative_ratio(shell_index=1)
        except (KeyError, RuntimeError):
            rho_alg = N6_ASSOCIATIVE_RATIO

    dynamic = dynamic_layer_metrics_from_json(payload)
    return EntropyBridgeReport(
        algebraic=algebraic_layer_metrics(rho_alg),
        dynamic=dynamic,
        quantization=quantization_layer_metrics(rho_alg, p_dyn_max=dynamic.p_dyn_max),
    )


def export_entropy_bridge_json(report: EntropyBridgeReport, path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    serializable = {
        "hypothesis": "H3",
        "layer_separation": {
            "A_algebraic_density": asdict(report.algebraic),
            "B_dynamic_row_law": {
                **asdict(report.dynamic),
                "P_row": [{"x0_to": target, "probability": prob} for target, prob in report.dynamic.P_row],
            },
            "C_quantization_bridge": {
                **asdict(report.quantization),
                "Q_sym": list(report.quantization.Q_sym),
                "note": "H_alg != H_row; Q_sym is the explicit layer map",
            },
        },
    }
    path.write_text(json.dumps(serializable, indent=2) + "\n", encoding="utf-8")
    return path


def format_entropy_bridge_table(report: EntropyBridgeReport) -> str:
    a = report.algebraic
    d = report.dynamic
    q = report.quantization
    prob_text = ", ".join(f"{target:g}->{prob:.3f}" for target, prob in d.P_row)
    rational = f" ({q.quantization_gap_rational} exact)" if q.quantization_gap_rational else ""
    return "\n".join(
        [
            "--- #Energiedoku: H3 Entropy Bridge (three statements) ---",
            f"A  rho_alg={a.rho_alg:.4f}, H_alg={a.H_alg_bits:.4f} Sh",
            f"B  P_row=({prob_text}), H_row={d.H_row_bits:.4f} Sh, p_dyn_max={d.p_dyn_max:.3f}",
            f"C  Q_sym={q.Q_sym}, H(Q_sym)={q.H_Q_sym_bits:.4f} Sh, G={q.quantization_gap:.4f}{rational}",
        ]
    )


# Backward-compatible aliases
binary_von_neumann_entropy = binary_entropy_h2
density_operator_metrics = algebraic_layer_metrics
transition_row_entropy = row_entropy_bits
transition_row_metrics_from_json = dynamic_layer_metrics_from_json
