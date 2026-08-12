#!/usr/bin/env python3
"""[E] Fano-defect scan for Exclusion of Infinite Bad Cylinders (Variante C).

Governance: **BCOP[E] diagnostic only** — does NOT prove Collatz, does NOT
instantiate ``ExclusionOfInfiniteBadCylindersProp``, and does NOT claim that
Fano/octonion geometry proves Collatz.

Lean anchor: ``KeplerHurwitz/Collatz/Octonion/BlockDescentBridge.lean``
(``fanoDefect``, ``fanoShellBound``, ``ExclusionOfInfiniteBadCylindersProp``).

Reuses ``tao_collatz_diagnostics.syracuse`` / ``v2``.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.tao_collatz_diagnostics import syracuse, v2  # noqa: E402

LOG2_3 = math.log2(3.0)
DEFAULT_PEAKS = (27, 703, 871, 6171, 77031)
DEFAULT_C_FANO = 1.0


def fano_defect(n: int) -> float:
    """Local Fano phase defect matching Lean ``fanoDefect`` (n > 0 odd preferred)."""
    if n <= 0:
        return 0.0
    nu = float(v2(3 * n + 1))
    t = 1.0 / (3.0 * float(n))
    corr = (math.log2(1.0 + t)) / (1.0 + t)
    return max(0.0, LOG2_3 - nu + corr)


def fano_shell_bound(n0: int, c_fano: float = DEFAULT_C_FANO) -> float:
    """Model shell potential ``C_Fano * log(shell + 1)``, shell = n0 // 12."""
    shell = n0 // 12
    return float(c_fano) * math.log(shell + 1.0)


def scan_orbit_defect(
    n0: int,
    *,
    max_steps: int,
    c_fano: float = DEFAULT_C_FANO,
) -> dict:
    """Accumulate D along Syracuse orbit until descent below n0 or max_steps."""
    if n0 <= 0 or n0 % 2 == 0:
        raise ValueError("n0 must be positive and odd")
    if max_steps < 0:
        raise ValueError("max_steps must be >= 0")

    current = n0
    peak = n0
    defect_sum = 0.0
    steps = 0
    descended = False
    for _ in range(max_steps):
        defect_sum += fano_defect(current)
        current = syracuse(current)
        steps += 1
        if current > peak:
            peak = current
        if current < n0:
            descended = True
            break

    bound = fano_shell_bound(n0, c_fano)
    return {
        "n0": n0,
        "steps": steps,
        "peak": peak,
        "end": current,
        "descended_below_start": descended,
        "defect_sum": defect_sum,
        "shell_bound_M": bound,
        "C_Fano": c_fano,
        "defect_sum_over_M": (defect_sum / bound) if bound > 0 else None,
        "governance": "BCOP[E] diagnostic only — not a Collatz proof",
    }


def batch_peaks(
    peaks: list[int],
    *,
    max_steps: int,
    c_fano: float,
) -> list[dict]:
    return [
        scan_orbit_defect(n, max_steps=max_steps, c_fano=c_fano) for n in peaks
    ]


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "[E] Scan Syracuse peaks for cumulative fanoDefect vs shell bound M. "
            "Diagnostic only — Collatz? NEIN."
        )
    )
    parser.add_argument(
        "--peaks",
        type=int,
        nargs="*",
        default=list(DEFAULT_PEAKS),
        help=f"Odd start peaks to scan (default: {list(DEFAULT_PEAKS)}).",
    )
    parser.add_argument(
        "--max-steps",
        type=int,
        default=50_000,
        help="Max Syracuse steps per orbit (default: 50000).",
    )
    parser.add_argument(
        "--c-fano",
        type=float,
        default=DEFAULT_C_FANO,
        help="Research calibration C_Fano for M(n0) (default: 1.0).",
    )
    parser.add_argument(
        "--json-out",
        type=Path,
        default=None,
        help="Optional JSON export path under docs/exports/.",
    )
    args = parser.parse_args()

    rows = batch_peaks(args.peaks, max_steps=args.max_steps, c_fano=args.c_fano)
    print(
        "verify_v2_defect_scan [E] — H_Fano-Defect diagnostic "
        "(NOT proved; Collatz NEIN)"
    )
    print(
        f"{'n0':>10} {'steps':>8} {'peak':>12} {'sum_D':>12} "
        f"{'M':>12} {'sum_D/M':>10} {'desc':>5}"
    )
    for r in rows:
        ratio = r["defect_sum_over_M"]
        ratio_s = f"{ratio:.4f}" if ratio is not None else "n/a"
        print(
            f"{r['n0']:10d} {r['steps']:8d} {r['peak']:12d} "
            f"{r['defect_sum']:12.6f} {r['shell_bound_M']:12.6f} "
            f"{ratio_s:>10} {str(r['descended_below_start']):>5}"
        )

    payload = {
        "tag": "exclusion_infinite_bad_cylinders_defect_scan",
        "hypothesis": "H_Fano-Defect",
        "lean_prop": "ExclusionOfInfiniteBadCylindersProp",
        "governance": "[E] diagnostic only; [B] Prop unproved; Collatz NEIN",
        "C_Fano": args.c_fano,
        "max_steps": args.max_steps,
        "rows": rows,
    }
    if args.json_out is not None:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(
            json.dumps(payload, indent=2) + "\n", encoding="utf-8"
        )
        print(f"wrote {args.json_out}")


if __name__ == "__main__":
    main()
