#!/usr/bin/env python3
"""
Dumas-Orbit Experimental Protocol runner.

Governance:
  - Dumas identities = regression checks (Modul A)
  - Only null-model-stable deviations = empirical evidence
  - Dumas = Normalform, not Generator

See docs/reports/dumas_orbit_experimental_protocol.md and
docs/theory/dumas_cone_orbit_model.md §17.
"""

from __future__ import annotations

import argparse
import csv
import math
import random
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.diagnostics import channel_entropy  # noqa: E402
from kepler_hurwitz.dumas_cone_orbit import (  # noqa: E402
    HOSTS,
    channel_from_mod12,
    host_for_quadruplet_index,
    l2_from_uniform,
    push_weight,
    verify_dumas_orbit,
    verify_kepler_circle,
    verify_natural_fill,
    verify_rotor_gap_sequence,
)
from kepler_hurwitz.primvierling import (  # noqa: E402
    Primvierling,
    build_prime_quadruplet,
    generate_prime_quadruplets,
    is_prime_quadruplet,
    symmetry_shift_ceab,
)
from kepler_hurwitz.signatures import signature_from_nat  # noqa: E402

DEFAULT_SCALES = (100_000, 1_000_000, 10_000_000)
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports"
CHANNELS_MOD12 = {1: 0, 5: 1, 7: 2, 11: 3}  # E, A, B, C index


def sieve_primes(limit: int) -> list[int]:
    if limit < 2:
        return []
    flags = bytearray(b"\x01") * (limit + 1)
    flags[0:2] = b"\x00\x00"
    for p in range(2, int(limit**0.5) + 1):
        if flags[p]:
            start = p * p
            flags[start : limit + 1 : p] = b"\x00" * len(range(start, limit + 1, p))
    return [i for i in range(2, limit + 1) if flags[i]]


def window_channel_signature(primes: Sequence[int]) -> tuple[int, int, int, int]:
    counts = [0, 0, 0, 0]
    for q in primes:
        residue = q % 12
        if residue in CHANNELS_MOD12:
            counts[CHANNELS_MOD12[residue]] += 1
    return tuple(counts)  # type: ignore[return-value]


def entropy_before(
    start: int,
    window: int,
    prime_list: Sequence[int],
) -> float:
    lo = max(2, start - window)
    window_primes = [q for q in prime_list if lo <= q < start]
    return channel_entropy(window_channel_signature(window_primes))


def primvierling_gaps(quadruplets: Sequence[Primvierling]) -> list[int]:
    return [quadruplets[i + 1][0] - quadruplets[i][0] for i in range(len(quadruplets) - 1)]


def gap_phases(n_gaps: int) -> list[str]:
    return [host_for_quadruplet_index(i + 2) for i in range(n_gaps)]


def channel_word(v: Primvierling) -> tuple[str, str, str, str]:
    return tuple(channel_from_mod12(x) for x in v)  # type: ignore[return-value]


def orientation_label(v: Primvierling) -> str:
    """ABCE vs CEAB via channel words under slot order vs shiftCEAB (H13)."""
    w_abce = channel_word(v)
    w_ceab = channel_word(symmetry_shift_ceab(v))
    return "ABCE" if w_abce <= w_ceab else "CEAB"


def mean_std(values: Sequence[float]) -> tuple[float, float]:
    if not values:
        return (float("nan"), float("nan"))
    mu = sum(values) / len(values)
    if len(values) == 1:
        return (mu, 0.0)
    var = sum((x - mu) ** 2 for x in values) / (len(values) - 1)
    return (mu, math.sqrt(var))


def group_by_phase(gaps: Sequence[int], phases: Sequence[str]) -> dict[str, list[int]]:
    groups: dict[str, list[int]] = {h: [] for h in HOSTS}
    for gap, phase in zip(gaps, phases, strict=True):
        groups[phase].append(gap)
    return groups


def kruskal_wallis(groups: dict[str, list[int]]) -> tuple[float, float]:
    """Kruskal-Wallis H with chi-square df=k-1 p-value (normal approx)."""
    ranked_data: list[tuple[float, int]] = []
    group_ids: dict[str, int] = {h: i for i, h in enumerate(HOSTS)}
    for host in HOSTS:
        for value in groups[host]:
            ranked_data.append((float(value), group_ids[host]))
    if len(ranked_data) < 2:
        return (0.0, 1.0)

    ranked_data.sort(key=lambda x: x[0])
    n = len(ranked_data)
    ranks = [0.0] * n
    i = 0
    while i < n:
        j = i
        while j + 1 < n and ranked_data[j + 1][0] == ranked_data[i][0]:
            j += 1
        avg_rank = (i + j + 2) / 2.0
        for k in range(i, j + 1):
            ranks[k] = avg_rank
        i = j + 1

    rank_sums = [0.0] * len(HOSTS)
    sizes = [0] * len(HOSTS)
    for rank, (_, gid) in zip(ranks, ranked_data, strict=True):
        rank_sums[gid] += rank
        sizes[gid] += 1

    nonempty = [s for s in sizes if s > 0]
    if len(nonempty) <= 1:
        return (0.0, 1.0)

    h = 0.0
    for rs, ni in zip(rank_sums, sizes, strict=True):
        if ni > 0:
            h += rs * rs / ni
    h = 12.0 / (n * (n + 1)) * h - 3.0 * (n + 1)

    df = len(nonempty) - 1
    p = chi2_sf(h, df)
    return (h, p)


def chi2_sf(x: float, df: int) -> float:
    if df <= 0 or x <= 0:
        return 1.0
    return math.exp(-0.5 * x) * sum(
        (0.5 * x) ** k / math.gamma(k + 1) for k in range(df // 2, df // 2 + 40)
    )


def one_way_anova(groups: dict[str, list[int]]) -> tuple[float, float]:
    all_values: list[int] = []
    group_means: list[float] = []
    sizes: list[int] = []
    for host in HOSTS:
        vals = groups[host]
        if not vals:
            continue
        all_values.extend(vals)
        group_means.append(sum(vals) / len(vals))
        sizes.append(len(vals))

    n = len(all_values)
    k = len(sizes)
    if n <= k or k <= 1:
        return (0.0, 1.0)

    grand_mean = sum(all_values) / n
    ss_between = sum(ni * (mi - grand_mean) ** 2 for ni, mi in zip(sizes, group_means, strict=True))
    ss_within = 0.0
    idx = 0
    for host in HOSTS:
        vals = groups[host]
        if not vals:
            continue
        mu = sum(vals) / len(vals)
        ss_within += sum((v - mu) ** 2 for v in vals)
        idx += 1

    df_between = k - 1
    df_within = n - k
    if df_within <= 0 or ss_within == 0:
        return (0.0, 1.0)

    f_stat = (ss_between / df_between) / (ss_within / df_within)
    p = f_distribution_sf(f_stat, df_between, df_within)
    return (f_stat, p)


def f_distribution_sf(f: float, d1: int, d2: int) -> float:
    if f <= 0:
        return 1.0
    x = d2 / (d2 + d1 * f)
    return regularized_incomplete_beta(d2 / 2.0, d1 / 2.0, x)


def regularized_incomplete_beta(a: float, b: float, x: float) -> float:
    if x <= 0:
        return 0.0
    if x >= 1:
        return 1.0
    ln_beta = math.lgamma(a) + math.lgamma(b) - math.lgamma(a + b)
    front = math.exp(a * math.log(x) + b * math.log(1.0 - x) - ln_beta) / a
    cf = betacf(a, b, x)
    return 1.0 - front * cf


def betacf(a: float, b: float, x: float) -> float:
    max_iter = 200
    eps = 3e-7
    fpmin = 1e-30
    qab = a + b
    qap = a + 1.0
    qam = a - 1.0
    c = 1.0
    d = 1.0 - qab * x / qap
    if abs(d) < fpmin:
        d = fpmin
    d = 1.0 / d
    h = d
    for m in range(1, max_iter + 1):
        m2 = 2 * m
        aa = m * (b - m) * x / ((qam + m2) * (a + m2))
        d = 1.0 + aa * d
        if abs(d) < fpmin:
            d = fpmin
        c = 1.0 + aa / c
        if abs(c) < fpmin:
            c = fpmin
        d = 1.0 / d
        h *= d * c
        aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
        d = 1.0 + aa * d
        if abs(d) < fpmin:
            d = fpmin
        c = 1.0 + aa / c
        if abs(c) < fpmin:
            c = fpmin
        d = 1.0 / d
        delta = d * c
        h *= delta
        if abs(delta - 1.0) < eps:
            break
    return h


def permutation_phase_pvalue(
    gaps: Sequence[int],
    phases: Sequence[str],
    permutations: int,
    seed: int,
) -> float:
    groups = group_by_phase(gaps, phases)
    h_obs, _ = kruskal_wallis(groups)
    rng = random.Random(seed)
    labels = list(phases)
    count_ge = 0
    for _ in range(permutations):
        shuffled = labels[:]
        rng.shuffle(shuffled)
        h_perm, _ = kruskal_wallis(group_by_phase(gaps, shuffled))
        if h_perm >= h_obs:
            count_ge += 1
    return (count_ge + 1) / (permutations + 1)


def pearson_r(xs: Sequence[float], ys: Sequence[float]) -> float:
    n = len(xs)
    if n < 2:
        return float("nan")
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys, strict=True))
    den_x = math.sqrt(sum((x - mx) ** 2 for x in xs))
    den_y = math.sqrt(sum((y - my) ** 2 for y in ys))
    if den_x == 0 or den_y == 0:
        return 0.0
    return num / (den_x * den_y)


def structured_non_quadruplet_primes(limit: int, rng: random.Random) -> list[int]:
    """Primes p where (p,p+2,p+6,p+8) is NOT a primvierling."""
    primes = sieve_primes(limit)
    candidates = [p for p in primes if p > 3 and not is_prime_quadruplet(build_prime_quadruplet(p))]
    if len(candidates) > 200:
        return rng.sample(candidates, 200)
    return candidates


@dataclass
class ScaleResult:
    scale_n: int
    quadruplet_count: int
    dumas_failures: int
    natural_fill_failures: int
    rotor_failures: int
    kepler_failures: int
    total_regression_failures: int
    gap_kruskal_h: float
    gap_kruskal_p: float
    gap_anova_f: float
    gap_anova_p: float
    f1_permutation_p: float
    entropy_primvierling_mean: float
    entropy_structured_mean: float
    entropy_random_mean: float
    abce_count: int
    ceab_count: int
    abce_ceab_ratio: float
    weight_corr_r: float
    elapsed_s: float


def analyze_scale(
    scale_n: int,
    window: int,
    permutations: int,
    seed: int,
) -> tuple[ScaleResult, list[dict], list[dict]]:
    t0 = time.time()
    quadruplets = generate_prime_quadruplets(2, scale_n)
    primes_up_to = sieve_primes(scale_n)

    dumas_f = len(verify_dumas_orbit(quadruplets))
    fill_f = len(verify_natural_fill(quadruplets))
    rotor_f = len(verify_rotor_gap_sequence(quadruplets))
    kepler_f = len(verify_kepler_circle(quadruplets))
    total_f = dumas_f + fill_f + rotor_f + kepler_f

    gaps = primvierling_gaps(quadruplets)
    phases = gap_phases(len(gaps))
    groups = group_by_phase(gaps, phases)
    h_stat, h_p = kruskal_wallis(groups)
    f_stat, f_p = one_way_anova(groups)
    f1_p = permutation_phase_pvalue(gaps, phases, permutations, seed)

    gap_rows: list[dict] = []
    for host in HOSTS:
        vals = groups[host]
        mu, sd = mean_std([float(v) for v in vals])
        gap_rows.append(
            {
                "scale_n": scale_n,
                "phase": host,
                "gap_mean": round(mu, 4) if not math.isnan(mu) else "",
                "gap_std": round(sd, 4) if not math.isnan(sd) else "",
                "gap_count": len(vals),
            }
        )

    rng = random.Random(seed)
    pv_entropies = [
        entropy_before(v[0], window, primes_up_to) for v in quadruplets
    ]
    structured = structured_non_quadruplet_primes(scale_n, rng)
    struct_entropies = [
        entropy_before(p, window, primes_up_to) for p in structured
    ]
    random_ns = [rng.randint(100, scale_n) for _ in range(min(200, len(quadruplets) * 2))]
    random_entropies = [entropy_before(n, window, primes_up_to) for n in random_ns]

    entropy_rows = [
        {
            "scale_n": scale_n,
            "group": "primvierling",
            "window_L": window,
            "entropy_mean": round(mean_std(pv_entropies)[0], 6),
            "entropy_std": round(mean_std(pv_entropies)[1], 6),
            "count": len(pv_entropies),
        },
        {
            "scale_n": scale_n,
            "group": "structured_control",
            "window_L": window,
            "entropy_mean": round(mean_std(struct_entropies)[0], 6),
            "entropy_std": round(mean_std(struct_entropies)[1], 6),
            "count": len(struct_entropies),
        },
        {
            "scale_n": scale_n,
            "group": "random_n",
            "window_L": window,
            "entropy_mean": round(mean_std(random_entropies)[0], 6),
            "entropy_std": round(mean_std(random_entropies)[1], 6),
            "count": len(random_entropies),
        },
    ]

    abce = sum(1 for v in quadruplets if orientation_label(v) == "ABCE")
    ceab = len(quadruplets) - abce
    ratio = abce / ceab if ceab else float("inf")

    features: list[float] = []
    gap_targets: list[float] = []
    for i, gap in enumerate(gaps):
        v = quadruplets[i]
        host = host_for_quadruplet_index(i + 1)
        feat = l2_from_uniform(push_weight(v, host, 0.5))
        features.append(feat)
        gap_targets.append(float(gap))
    w_corr = pearson_r(features, gap_targets)

    elapsed = time.time() - t0
    scale = ScaleResult(
        scale_n=scale_n,
        quadruplet_count=len(quadruplets),
        dumas_failures=dumas_f,
        natural_fill_failures=fill_f,
        rotor_failures=rotor_f,
        kepler_failures=kepler_f,
        total_regression_failures=total_f,
        gap_kruskal_h=round(h_stat, 6),
        gap_kruskal_p=round(h_p, 6),
        gap_anova_f=round(f_stat, 6),
        gap_anova_p=round(f_p, 6),
        f1_permutation_p=round(f1_p, 6),
        entropy_primvierling_mean=round(mean_std(pv_entropies)[0], 6),
        entropy_structured_mean=round(mean_std(struct_entropies)[0], 6),
        entropy_random_mean=round(mean_std(random_entropies)[0], 6),
        abce_count=abce,
        ceab_count=ceab,
        abce_ceab_ratio=round(ratio, 4),
        weight_corr_r=round(w_corr, 6),
        elapsed_s=round(elapsed, 2),
    )
    return scale, gap_rows, entropy_rows


def write_csv(path: Path, fieldnames: list[str], rows: list[dict]) -> int:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    return len(rows)


def scale_report_row(s: ScaleResult) -> dict:
    return {
        "scale_n": s.scale_n,
        "quadruplet_count": s.quadruplet_count,
        "dumas_failures": s.dumas_failures,
        "natural_fill_failures": s.natural_fill_failures,
        "rotor_failures": s.rotor_failures,
        "kepler_failures": s.kepler_failures,
        "total_regression_failures": s.total_regression_failures,
        "gap_kruskal_h": s.gap_kruskal_h,
        "gap_kruskal_p": s.gap_kruskal_p,
        "gap_anova_f": s.gap_anova_f,
        "gap_anova_p": s.gap_anova_p,
        "f1_permutation_p": s.f1_permutation_p,
        "entropy_primvierling_mean": s.entropy_primvierling_mean,
        "entropy_structured_mean": s.entropy_structured_mean,
        "entropy_random_mean": s.entropy_random_mean,
        "abce_count": s.abce_count,
        "ceab_count": s.ceab_count,
        "abce_ceab_ratio": s.abce_ceab_ratio,
        "weight_corr_r": s.weight_corr_r,
        "elapsed_s": s.elapsed_s,
    }


def run_experiment(
    scales: Sequence[int],
    out_dir: Path,
    window: int,
    permutations: int,
    seed: int,
) -> dict[str, int]:
    scale_rows: list[dict] = []
    gap_rows: list[dict] = []
    entropy_rows: list[dict] = []

    for scale_n in scales:
        print(f"Scale N={scale_n} ...", flush=True)
        scale, gaps, entropies = analyze_scale(scale_n, window, permutations, seed)
        scale_rows.append(scale_report_row(scale))
        gap_rows.extend(gaps)
        entropy_rows.extend(entropies)
        print(
            f"  quadruplets={scale.quadruplet_count}, "
            f"regression_failures={scale.total_regression_failures}, "
            f"F1_p={scale.f1_permutation_p}, "
            f"elapsed={scale.elapsed_s}s",
            flush=True,
        )

    report_fields = [
        "scale_n",
        "quadruplet_count",
        "dumas_failures",
        "natural_fill_failures",
        "rotor_failures",
        "kepler_failures",
        "total_regression_failures",
        "gap_kruskal_h",
        "gap_kruskal_p",
        "gap_anova_f",
        "gap_anova_p",
        "f1_permutation_p",
        "entropy_primvierling_mean",
        "entropy_structured_mean",
        "entropy_random_mean",
        "abce_count",
        "ceab_count",
        "abce_ceab_ratio",
        "weight_corr_r",
        "elapsed_s",
    ]
    gap_fields = ["scale_n", "phase", "gap_mean", "gap_std", "gap_count"]
    entropy_fields = ["scale_n", "group", "window_L", "entropy_mean", "entropy_std", "count"]

    counts = {
        "dumas_orbit_scale_report.csv": write_csv(
            out_dir / "dumas_orbit_scale_report.csv", report_fields, scale_rows
        ),
        "dumas_orbit_gap_phase.csv": write_csv(
            out_dir / "dumas_orbit_gap_phase.csv", gap_fields, gap_rows
        ),
        "dumas_orbit_entropy_windows.csv": write_csv(
            out_dir / "dumas_orbit_entropy_windows.csv", entropy_fields, entropy_rows
        ),
    }
    return counts


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Dumas-Orbit Experimental Protocol")
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT,
        help="CSV output directory (default: docs/energiedoku_exports/)",
    )
    parser.add_argument(
        "--window",
        type=int,
        default=50,
        help="Entropy window length L (default: 50)",
    )
    parser.add_argument(
        "--permutations",
        type=int,
        default=500,
        help="F1 rotor permutation count (default: 500)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=48,
        help="RNG seed (default: 48)",
    )
    parser.add_argument(
        "--include-1e8",
        action="store_true",
        help="Include scale N=10^8 (may be slow)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    scales = list(DEFAULT_SCALES)
    if args.include_1e8:
        scales.append(100_000_000)

    print("Dumas-Orbit Experimental Protocol")
    print(f"  scales: {scales}")
    print(f"  out-dir: {args.out_dir}")
    print(f"  window L: {args.window}")
    print(f"  F1 permutations: {args.permutations}")
    print()

    counts = run_experiment(scales, args.out_dir, args.window, args.permutations, args.seed)

    print()
    print("CSV outputs:")
    for name, n_rows in counts.items():
        print(f"  {args.out_dir / name}: {n_rows} data rows")


if __name__ == "__main__":
    main()
