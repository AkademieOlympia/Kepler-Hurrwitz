#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.kepler_time_bridge import run_kepler_time_bridge_scenarios
from kepler_hurwitz.riemann_resonance_checker import (
    analyze_riemann_interference,
    analyze_riemann_scale_interference,
    default_riemann_zeros_path,
    export_riemann_resonance_json,
    export_riemann_scale_resonance_json,
    format_resonance_table,
    format_scale_resonance_table,
    known_zeros_head,
    load_riemann_zeros_from_file,
    log_scale_from_semi_major,
    run_riemann_resonance_from_bridge_records,
    run_riemann_scale_resonance_from_bridge_records,
)


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="#Energiedoku: Arithmetischer Riemann-Resonanztest fuer die Kepler-Zeit-Leiter",
    )
    parser.add_argument(
        "--zeros-path",
        type=Path,
        default=default_riemann_zeros_path(),
        help="Pfad zur `<f8`-Binärdatei mit imaginaeren Riemann-Nullstellen",
    )
    parser.add_argument(
        "--sample-count",
        type=int,
        default=100_000,
        help="Anzahl der Nullstellen fuer die Interferenzsumme (0 = alle)",
    )
    parser.add_argument(
        "--steps",
        type=int,
        default=500,
        help="Simulationsschritte fuer die Kepler-Zeit-Bruecke",
    )
    parser.add_argument(
        "--tail-length",
        type=int,
        default=64,
        help="Tail-Fenster fuer die Zeit-Leiter-Diagnose",
    )
    parser.add_argument(
        "--demo",
        action="store_true",
        help="Nutze eine kleine Referenzmenge statt der Vollbinärdatei",
    )
    parser.add_argument(
        "--export-json",
        type=Path,
        default=ROOT / "docs" / "energiedoku_exports" / "riemann_resonance.json",
        help="JSON-Export der Delta-M-Resonanzdiagnose",
    )
    parser.add_argument(
        "--export-scale-json",
        type=Path,
        default=ROOT / "docs" / "energiedoku_exports" / "riemann_scale_resonance.json",
        help="JSON-Export der korrigierten Skalen-Interferenz",
    )
    return parser.parse_args()


def main() -> None:
    args = _parse_args()

    if args.demo or not args.zeros_path.exists():
        if not args.demo:
            print(
                f"Hinweis: Keine Nullstellen-Datei unter {args.zeros_path}. "
                "Verwende Referenz-Head (--demo). "
                "Setze RIEMANN_ZEROS_PATH oder lege data/riemann_zeros_imag_f8.bin ab."
            )
        zeros = known_zeros_head()
    else:
        zeros = load_riemann_zeros_from_file(args.zeros_path)
        print(f"Geladen: {len(zeros):,} Riemann-Nullstellen aus {args.zeros_path}")

    sample_count = None if args.sample_count <= 0 else args.sample_count
    print("\n=== #Energiedoku: Arithmetischer Riemann-Resonanztest ===")
    print(f"Nullstellen im Datensatz: {len(zeros):,}")
    effective_sample = sample_count if sample_count is not None else len(zeros)
    print(f"Stichprobe fuer Summe: {min(effective_sample, len(zeros)):,}")

    perturb_at_step = min(100, max(1, args.steps // 2))
    records = run_kepler_time_bridge_scenarios(
        steps=args.steps,
        tail_length=args.tail_length,
        perturb_at_step=perturb_at_step,
    )

    print("\n--- Metrik 1 (widerlegt): S(Delta_M) = mean cos(gamma * Delta_M) ---")
    resonance_results = run_riemann_resonance_from_bridge_records(
        records,
        zeros,
        sample_count=sample_count,
    )
    print(format_resonance_table(resonance_results))

    anchor = analyze_riemann_interference(zeros, 0.0, sample_count=sample_count)
    baseline = analyze_riemann_interference(zeros, 1.85619, sample_count=sample_count)
    print("\nInterpretation (Delta_M-Metrik, E-034 negative Evidenz):")
    print(
        f"- Delta_M=0: interference={anchor.interference_factor:.6f} "
        "(trivial: cos(0)=1, keine Riemann-Kopplung)"
    )
    print(
        f"- Delta_M=1.85619: interference={baseline.interference_factor:.12f}, "
        f"resonant={'yes' if baseline.is_resonant else 'no'}"
    )

    print("\n--- Metrik 2 (korrigiert): S(x_0) = mean cos(gamma * log(a/a_0)) ---")
    scale_results = run_riemann_scale_resonance_from_bridge_records(
        records,
        zeros,
        sample_count=sample_count,
    )
    print(format_scale_resonance_table(scale_results))

    demo_x0 = log_scale_from_semi_major(1.5)
    demo_scale = analyze_riemann_scale_interference(zeros, demo_x0, sample_count=sample_count)
    print("\nInterpretation (Skalen-Metrik, E-035 offene Hypothese):")
    print(
        f"- Demo-Orbit x_0=log(1.5)={demo_x0:.6f}: "
        f"interference={demo_scale.interference_factor:.12f}, "
        f"resonant={'yes' if demo_scale.is_resonant else 'no'}"
    )

    export_path = export_riemann_resonance_json(
        resonance_results,
        args.export_json,
        verdict="negative_evidence",
        zeros_count=len(zeros),
    )
    scale_export_path = export_riemann_scale_resonance_json(
        scale_results,
        args.export_scale_json,
        verdict="open_hypothesis",
        zeros_count=len(zeros),
    )
    print(f"\nExport Delta_M: {export_path}")
    print(f"Export Skala:   {scale_export_path}")


if __name__ == "__main__":
    main()
