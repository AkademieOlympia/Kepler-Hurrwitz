"""DH-QPID bounded-search prototype (E-061 / E-062).

Cardoso-Machiavelo reference orders H_{1,7} and H_{7,13}: compare norm-Euclidean
division (EUC) with Dedekind-Hasse correction witnesses.

Governance: numerical prototype only — no EABC claim.
"""

from __future__ import annotations

import csv
import json
from collections.abc import Iterable, Sequence
from dataclasses import asdict, dataclass
from fractions import Fraction
from math import gcd, isqrt
from pathlib import Path
from typing import Literal

OrderName = Literal["H17", "H713"]

F = Fraction

# Exclude single-axis ±2 on the first two basis directions (Cardoso bounded pool).
_H17_ALPHA_AXIS_EXCLUDE = {
    (2, 0, 0, 0),
    (-2, 0, 0, 0),
    (0, 2, 0, 0),
    (0, -2, 0, 0),
}


@dataclass(frozen=True)
class Quat:
    w: Fraction
    x: Fraction
    y: Fraction
    z: Fraction

    @staticmethod
    def from_ints(w: int, x: int, y: int, z: int) -> Quat:
        return Quat(F(w), F(x), F(y), F(z))

    def __add__(self, other: Quat) -> Quat:
        return Quat(
            self.w + other.w,
            self.x + other.x,
            self.y + other.y,
            self.z + other.z,
        )

    def __sub__(self, other: Quat) -> Quat:
        return Quat(
            self.w - other.w,
            self.x - other.x,
            self.y - other.y,
            self.z - other.z,
        )

    def __mul__(self, other: Quat) -> Quat:
        w1, x1, y1, z1 = self.w, self.x, self.y, self.z
        w2, x2, y2, z2 = other.w, other.x, other.y, other.z
        return Quat(
            w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2,
            w1 * x2 + x1 * w2 + y1 * z2 - z1 * y2,
            w1 * y2 - x1 * z2 + y1 * w2 + z1 * x2,
            w1 * z2 + x1 * y2 - y1 * x2 + z1 * w2,
        )

    def scale(self, scalar: Fraction) -> Quat:
        return Quat(self.w * scalar, self.x * scalar, self.y * scalar, self.z * scalar)

    def norm_sq(self) -> Fraction:
        return self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z

    def coeff_key(self) -> tuple[Fraction, Fraction, Fraction, Fraction]:
        return (self.w, self.x, self.y, self.z)


@dataclass(frozen=True)
class OrderSpec:
    name: OrderName
    basis: tuple[Quat, Quat, Quat, Quat]
    max_prime: int
    coeff_bound: int
    alpha_coeff_bound: int


H17_ORDER = OrderSpec(
    name="H17",
    basis=(
        Quat.from_ints(1, 0, 0, 0),
        Quat.from_ints(0, 1, 0, 0),
        Quat(F(1, 2), F(0), F(1, 2), F(0)),
        Quat(F(0), F(1, 2), F(0), F(1, 2)),
    ),
    max_prime=13,
    coeff_bound=2,
    alpha_coeff_bound=2,
)

H713_ORDER = OrderSpec(
    name="H713",
    basis=(
        Quat.from_ints(1, 0, 0, 0),
        Quat(F(1, 2), F(1, 2), F(0), F(0)),
        Quat(F(0), F(1, 7), F(0), F(1, 7)),
        Quat(F(1, 2), F(1, 14), F(1, 2), F(1, 14)),
    ),
    max_prime=11,
    coeff_bound=2,
    alpha_coeff_bound=2,
)

GOVERNANCE = (
    "Bounded DH-QPID prototype for Cardoso-Machiavelo orders. "
    "Does not prove EABC structure or PID globally."
)


def _gcd4(coeffs: Sequence[int]) -> int:
    value = 0
    for coeff in coeffs:
        value = gcd(value, abs(coeff))
    return value


def _passes_h17_alpha_axis_filter(coeffs: Sequence[int]) -> bool:
    return tuple(coeffs) not in _H17_ALPHA_AXIS_EXCLUDE


def from_coeffs(spec: OrderSpec, coeffs: Sequence[int]) -> Quat:
    b0, b1, b2, b3 = spec.basis
    a, b, c, d = coeffs
    return (
        b0.scale(F(a))
        + b1.scale(F(b))
        + b2.scale(F(c))
        + b3.scale(F(d))
    )


def _invert_4x4(matrix: list[list[Fraction]]) -> list[list[Fraction]] | None:
    aug = [row[:] + [F(int(i == j)) for j in range(4)] for i, row in enumerate(matrix)]
    for col in range(4):
        pivot = None
        for row in range(col, 4):
            if aug[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return None
        aug[col], aug[pivot] = aug[pivot], aug[col]
        scale = aug[col][col]
        aug[col] = [value / scale for value in aug[col]]
        for row in range(4):
            if row == col:
                continue
            factor = aug[row][col]
            if factor == 0:
                continue
            aug[row] = [aug[row][c] - factor * aug[col][c] for c in range(8)]
    return [row[4:] for row in aug]


def order_coeffs(spec: OrderSpec, q: Quat) -> tuple[int, int, int, int] | None:
    """Return Z-basis coefficients for q in spec, else None."""
    matrix = [
        [spec.basis[j].w for j in range(4)],
        [spec.basis[j].x for j in range(4)],
        [spec.basis[j].y for j in range(4)],
        [spec.basis[j].z for j in range(4)],
    ]
    inverse = _invert_4x4(matrix)
    if inverse is None:
        return None
    target = [q.w, q.x, q.y, q.z]
    raw = [sum(inverse[row][col] * target[row] for row in range(4)) for col in range(4)]
    if any(value.denominator != 1 for value in raw):
        return None
    return tuple(int(value) for value in raw)


def is_in_order(spec: OrderSpec, q: Quat) -> bool:
    return order_coeffs(spec, q) is not None


def enumerate_order_elements(spec: OrderSpec) -> list[tuple[tuple[int, int, int, int], Quat]]:
    bound = spec.coeff_bound
    values = range(-bound, bound + 1)
    out: list[tuple[tuple[int, int, int, int], Quat]] = []
    for a in values:
        for b in values:
            for c in values:
                for d in values:
                    if a == b == c == d == 0:
                        continue
                    coeffs = (a, b, c, d)
                    out.append((coeffs, from_coeffs(spec, coeffs)))
    return out


def build_alpha_pool(spec: OrderSpec) -> list[tuple[tuple[int, int, int, int], Quat]]:
    elements = enumerate_order_elements(
        OrderSpec(
            name=spec.name,
            basis=spec.basis,
            max_prime=spec.max_prime,
            coeff_bound=spec.alpha_coeff_bound,
            alpha_coeff_bound=spec.alpha_coeff_bound,
        )
    )
    if spec.name == "H17":
        return [(coeffs, q) for coeffs, q in elements if _passes_h17_alpha_axis_filter(coeffs)]
    return [
        (coeffs, q)
        for coeffs, q in elements
        if _passes_h17_alpha_axis_filter(coeffs)
        and _gcd4(coeffs) == 1
        and q.norm_sq() <= 6
        and q.norm_sq() != 1
    ]


def build_beta_pool(spec: OrderSpec) -> list[tuple[tuple[int, int, int, int], Quat]]:
    return enumerate_order_elements(spec)


def primes_up_to(limit: int) -> list[int]:
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for p in range(2, isqrt(limit) + 1):
        if sieve[p]:
            step = p
            start = p * p
            sieve[start : limit + 1 : step] = [False] * len(range(start, limit + 1, step))
    return [p for p, flag in enumerate(sieve) if flag]


@dataclass(frozen=True)
class Candidate:
    order: OrderName
    prime: int
    delta_coeffs: tuple[int, int, int, int]
    rho: Quat


@dataclass(frozen=True)
class WitnessResult:
    candidate: Candidate
    euc_success: bool
    dh_success: bool
    rescue: bool
    best_euc_norm: Fraction
    best_dh_norm: Fraction
    alpha_coeffs: tuple[int, int, int, int] | None
    beta_coeffs: tuple[int, int, int, int] | None
    alpha_norm_sq: int | None


def generate_candidates(spec: OrderSpec) -> list[Candidate]:
    delta_pool = enumerate_order_elements(spec)
    seen: set[tuple[int, tuple[Fraction, Fraction, Fraction, Fraction]]] = set()
    candidates: list[Candidate] = []
    for prime in primes_up_to(spec.max_prime):
        for delta_coeffs, delta in delta_pool:
            rho = delta.scale(F(1, prime))
            if is_in_order(spec, rho):
                continue
            norm_sq = rho.norm_sq()
            if not (F(0) < norm_sq < F(1)):
                continue
            key = (prime, rho.coeff_key())
            if key in seen:
                continue
            seen.add(key)
            candidates.append(
                Candidate(
                    order=spec.name,
                    prime=prime,
                    delta_coeffs=delta_coeffs,
                    rho=rho,
                )
            )
    return candidates


def _norm_sq_scaled(q: Quat, scale: int) -> int:
    """Return 4 * N(q) as integer when q has denominator dividing scale."""
    w = int(q.w * scale)
    x = int(q.x * scale)
    y = int(q.y * scale)
    z = int(q.z * scale)
    return w * w + x * x + y * y + z * z


def search_witness(
    spec: OrderSpec,
    candidate: Candidate,
    beta_elements: list[tuple[tuple[int, int, int, int], Quat]],
    alpha_elements: list[tuple[tuple[int, int, int, int], Quat]],
) -> WitnessResult:
    rho = candidate.rho
    best_euc = min((rho - beta).norm_sq() for _, beta in beta_elements)
    euc_success = best_euc < 1

    best_dh: Fraction | None = None
    best_alpha: tuple[int, int, int, int] | None = None
    best_beta: tuple[int, int, int, int] | None = None
    for alpha_coeffs, alpha in alpha_elements:
        alpha_rho = alpha * rho
        for beta_coeffs, beta in beta_elements:
            remainder_norm = (alpha_rho - beta).norm_sq()
            if best_dh is None or remainder_norm < best_dh:
                best_dh = remainder_norm
                best_alpha = alpha_coeffs
                best_beta = beta_coeffs
                if remainder_norm < 1:
                    break
        if best_dh is not None and best_dh < 1:
            break

    assert best_dh is not None
    dh_success = best_dh < 1
    rescue = (not euc_success) and dh_success
    alpha_norm_sq = None
    if best_alpha is not None:
        alpha_norm_sq = int(from_coeffs(spec, best_alpha).norm_sq())

    return WitnessResult(
        candidate=candidate,
        euc_success=euc_success,
        dh_success=dh_success,
        rescue=rescue,
        best_euc_norm=best_euc,
        best_dh_norm=best_dh,
        alpha_coeffs=best_alpha,
        beta_coeffs=best_beta,
        alpha_norm_sq=alpha_norm_sq,
    )


@dataclass(frozen=True)
class OrderSummary:
    order: OrderName
    max_prime: int
    candidates: int
    alpha_pool: int
    beta_pool: int
    euc_success: int
    dh_success: int
    dh_failures: int
    rescue_cases: int
    max_alpha_norm_sq: int | None


def run_order_prototype(spec: OrderSpec) -> tuple[OrderSummary, list[WitnessResult]]:
    beta_elements = build_beta_pool(spec)
    alpha_elements = build_alpha_pool(spec)
    candidates = generate_candidates(spec)
    results = [
        search_witness(spec, candidate, beta_elements, alpha_elements)
        for candidate in candidates
    ]
    alpha_norms = [row.alpha_norm_sq for row in results if row.alpha_norm_sq is not None]
    summary = OrderSummary(
        order=spec.name,
        max_prime=spec.max_prime,
        candidates=len(candidates),
        alpha_pool=len(alpha_elements),
        beta_pool=len(beta_elements),
        euc_success=sum(1 for row in results if row.euc_success),
        dh_success=sum(1 for row in results if row.dh_success),
        dh_failures=len(candidates) - sum(1 for row in results if row.dh_success),
        rescue_cases=sum(1 for row in results if row.rescue),
        max_alpha_norm_sq=max(alpha_norms) if alpha_norms else None,
    )
    return summary, results


def run_dhqpid_prototype() -> dict[str, object]:
    h17_summary, h17_results = run_order_prototype(H17_ORDER)
    h713_summary, h713_results = run_order_prototype(H713_ORDER)
    return {
        "governance": GOVERNANCE,
        "orders": {
            "H17": asdict(h17_summary),
            "H713": asdict(h713_summary),
        },
        "H17_results": [asdict(row) for row in h17_results],
        "H713_results": [asdict(row) for row in h713_results],
    }


def _format_quat(q: Quat) -> str:
    return f"({q.w},{q.x},{q.y},{q.z})"


def write_csv(path: Path, results: Iterable[WitnessResult]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(
            [
                "order",
                "prime",
                "delta_coeffs",
                "rho",
                "euc_success",
                "dh_success",
                "rescue",
                "best_euc_norm",
                "best_dh_norm",
                "alpha_coeffs",
                "beta_coeffs",
                "alpha_norm_sq",
            ]
        )
        for row in results:
            writer.writerow(
                [
                    row.candidate.order,
                    row.candidate.prime,
                    row.candidate.delta_coeffs,
                    _format_quat(row.candidate.rho),
                    int(row.euc_success),
                    int(row.dh_success),
                    int(row.rescue),
                    str(row.best_euc_norm),
                    str(row.best_dh_norm),
                    row.alpha_coeffs,
                    row.beta_coeffs,
                    row.alpha_norm_sq,
                ]
            )


def write_summary_csv(path: Path, summaries: Sequence[OrderSummary]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(asdict(summaries[0]).keys()))
        writer.writeheader()
        for summary in summaries:
            writer.writerow(asdict(summary))


def write_markdown_report(
    path: Path,
    summaries: Sequence[OrderSummary],
    h17_results: Sequence[WitnessResult],
    h713_results: Sequence[WitnessResult],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# DH-QPID Prototype Report (E-061 / E-062)",
        "",
        GOVERNANCE,
        "",
        "## Summary",
        "",
        "| Order | p max | Candidates | α-pool | β-pool | EUC ok | DH ok | DH fail | Rescues | max ‖α‖² |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for summary in summaries:
        max_alpha = summary.max_alpha_norm_sq if summary.max_alpha_norm_sq is not None else "-"
        lines.append(
            f"| {summary.order} | {summary.max_prime} | {summary.candidates} | "
            f"{summary.alpha_pool} | {summary.beta_pool} | {summary.euc_success} | "
            f"{summary.dh_success} | {summary.dh_failures} | {summary.rescue_cases} | {max_alpha} |"
        )
    lines.extend(
        [
            "",
            "## Interpretation",
            "",
            "- **Rescue** means `EUC(ρ)=0` and `DH(ρ)=1` in the bounded search.",
            "- Open DH failures are **not** counterexamples — search window may be too small.",
            "- **E-062** tracks `alpha_norm_sq` as arithmetical correction energy, not physics.",
            "",
            "## E-063 (future)",
            "",
            "Stratify α/δ profiles by residue classes `1,5,7,11 mod 12` — not yet implemented.",
            "",
            "## Example rescue (H17, if present)",
            "",
        ]
    )
    example = next((row for row in h17_results if row.rescue), None)
    if example is not None:
        lines.append(
            f"- p={example.candidate.prime}, δ={example.candidate.delta_coeffs}, "
            f"ρ={_format_quat(example.candidate.rho)}"
        )
        lines.append(
            f"- best EUC norm={example.best_euc_norm}, DH norm={example.best_dh_norm}, "
            f"α={example.alpha_coeffs}, β={example.beta_coeffs}"
        )
    else:
        lines.append("- (none in current bounded window)")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def export_prototype_artifacts(out_dir: Path) -> dict[str, object]:
    h17_summary, h17_results = run_order_prototype(H17_ORDER)
    h713_summary, h713_results = run_order_prototype(H713_ORDER)
    summaries = [h17_summary, h713_summary]

    write_summary_csv(out_dir / "dhqpid_prototype_summary.csv", summaries)
    write_csv(out_dir / "dhqpid_prototype_H17.csv", h17_results)
    write_csv(out_dir / "dhqpid_prototype_H713.csv", h713_results)
    write_markdown_report(
        out_dir / "dhqpid_prototype_report.md",
        summaries,
        h17_results,
        h713_results,
    )

    payload = {
        "governance": GOVERNANCE,
        "summary": {summary.order: asdict(summary) for summary in summaries},
    }
    (out_dir / "dhqpid_prototype.json").write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return payload
