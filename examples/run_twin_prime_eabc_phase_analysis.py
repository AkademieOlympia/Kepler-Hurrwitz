#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.twin_prime_eabc_phase_analysis import (
    DEFAULT_LIMIT,
    DEFAULT_SIEVE_BOUND,
    enrichment,
    export_twin_prime_phase_analysis_json,
    export_twin_prime_phase_analysis_markdown,
    run_twin_prime_phase_analysis,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="EABC/Floquet phase-distribution analysis for twin-prime candidates [B]."
    )
    parser.add_argument("--limit", type=int, default=DEFAULT_LIMIT, help="Upper bound X (default 10^6).")
    parser.add_argument(
        "--sieve-bound",
        type=int,
        default=DEFAULT_SIEVE_BOUND,
        help="Small-prime sieve bound B (default 97).",
    )
    args = parser.parse_args()

    report = run_twin_prime_phase_analysis(
        limit=args.limit,
        sieve_bound=args.sieve_bound,
    )

    export_dir = ROOT / "docs" / "energiedoku_exports"
    json_path = export_dir / "twin_prime_eabc_phase_analysis.json"
    md_path = export_dir / "twin_prime_eabc_phase_analysis_report.md"

    export_twin_prime_phase_analysis_json(report, json_path)
    export_twin_prime_phase_analysis_markdown(report, md_path)

    uniform = report.primary_analysis
    exploratory = report.exploratory_analysis
    sieve_enrichment = enrichment(report.small_sieve.hit_rate, report.baseline.hit_rate)

    print("--- EABC/Floquet Phase Distribution Analysis [B] ---")
    print(f"mode: {report.mode}")
    print(f"status: {report.status}")
    print(f"not_claimed: {report.not_claimed}")
    print(f"primary_question: {report.primary_question}")
    print(f"limit: {report.limit} (n ≡ 11 mod 12)")
    print(f"sieve_bound: {report.sieve_bound}")
    print(
        f"baseline: candidates={report.baseline.candidate_count} "
        f"hits={report.baseline.hit_count} rate={report.baseline.hit_rate:.6f}"
    )
    print(
        f"small_sieve: candidates={report.small_sieve.candidate_count} "
        f"hits={report.small_sieve.hit_count} rate={report.small_sieve.hit_rate:.6f}"
    )
    print(f"sieve enrichment vs baseline: {sieve_enrichment}")
    print(f"\nPrimary {report.primary_evidence}:")
    print(f"  chi2={uniform.chi2:.6f} dof={uniform.degrees_of_freedom} p={uniform.p_value:.6f}")
    print(f"  rejects_uniformity={uniform.rejects_uniformity}")
    print(f"\nExploratory {report.exploratory_evidence}:")
    print(
        f"  best phase: step={exploratory.floquet_step} channel={exploratory.channel} "
        f"enrichment={exploratory.enrichment}"
    )
    print(f"  caveat: {exploratory.caveat}")
    print(f"\nquadruplet_neighborhood: {report.quadruplet_neighborhood}")
    print(f"\njson export: {json_path}")
    print(f"markdown report: {md_path}")


if __name__ == "__main__":
    main()
