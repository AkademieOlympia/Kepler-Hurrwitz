#!/usr/bin/env python3
"""Full Dumas Cone–Orbit hypothesis scan up to p <= 1_000_000 (166 quadruplets)."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.dumas_cone_orbit import scan_dumas_orbit_hypotheses  # noqa: E402
from kepler_hurwitz.primvierling import generate_prime_quadruplets  # noqa: E402

FULL_STOP = 1_000_000


def main() -> None:
    quadruplets = generate_prime_quadruplets(2, FULL_STOP)
    summary = scan_dumas_orbit_hypotheses(quadruplets, twin_stop=FULL_STOP)
    print("Dumas Cone–Orbit hypothesis scan")
    print(f"  canonical quadruplets (p <= {FULL_STOP}): {summary.quadruplet_count}")
    print(f"  H1–H4 failures: {summary.h1_h4_failures}")
    print(f"  H2 (12-slot) failures: {summary.h2_failures}")
    print(f"  H5 (rotor) failures: {summary.h5_failures}")
    print(f"  H7 (Kepler circle) failures: {summary.h7_failures}")
    print("  D'Artagnan channel distribution (host != channel):")
    for host, counts in summary.host_channel_distribution.items():
        print(f"    {host}: {counts}")
    print(f"  twin pairs (excluding 3,5): {summary.twin_pair_count}")
    print(f"  twin EABC signatures: {summary.twin_signatures}")
    print(f"  weight entropy at omega=1/4: {summary.entropy_at_quarter}")
    print(f"  weight entropy at omega=1/2: {summary.entropy_at_half}")
    print(json.dumps(summary.as_dict(), indent=2))


if __name__ == "__main__":
    main()
