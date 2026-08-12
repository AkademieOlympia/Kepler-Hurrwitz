#!/usr/bin/env python3
"""CLI: Hc numerical stability freeze against normative SSOT."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.hc_spectral_freeze import (  # noqa: E402
    REPORT_PATH,
    require_exact_controls,
    run_freeze,
    write_report,
)


def main() -> int:
    print("Hard Controls…")
    require_exact_controls()
    print("Hard Controls: PASSED")

    report = run_freeze()
    out = write_report(report)
    print(f"freeze_status: {report['freeze_status']}")
    print(f"limiting_noise_class: {report['limiting_noise_class']}")
    print(f"epsilon_star_sym: {report['epsilon_star_sym']:.6g}")
    for key, block in report["epsilon_star"].items():
        b = block["positive"]
        uf = b["upper_fail"]
        uf_s = "None" if uf is None else f"{uf:.6g}"
        print(
            f"  {key}: estimate={b['estimate']:.6g} "
            f"lower_pass={b['lower_pass']:.6g} upper_fail={uf_s}"
        )
    print(f"report: {out}")
    print(f"(canonical path: {REPORT_PATH})")
    return 0 if report["freeze_status"] == "passed" else 1


if __name__ == "__main__":
    raise SystemExit(main())
