from __future__ import annotations

from collections.abc import Sequence
from pathlib import Path

from kepler_hurwitz.kepler_time_bridge import KeplerTimeBridgeRecord


def _spectrum_counts(
    deltas: Sequence[float],
    *,
    round_digits: int = 5,
) -> dict[float, int]:
    counts: dict[float, int] = {}
    for delta in deltas:
        value = round(delta, round_digits)
        counts[value] = counts.get(value, 0) + 1
    return counts


def export_spectral_histogram(
    bridge_records: Sequence[KeplerTimeBridgeRecord],
    output_dir: str | Path = "docs/plots",
    *,
    round_digits: int = 5,
    bar_width: int = 20,
) -> tuple[Path, ...]:
    """
    Schreibt hochpräzise .dat-Dateien und druckt ASCII-Histogramme der diskreten
    Delta-M-Spektren zur direkten Einbindung in LaTeX oder Veröffentlichungen.
    """
    destination = Path(output_dir)
    destination.mkdir(parents=True, exist_ok=True)

    print("\n=== #Energiedoku Spektral-Plot-Export ===")
    written_paths: list[Path] = []

    for record in bridge_records:
        name = record.control_name
        deltas = record.raw_delta_M_series
        counts = _spectrum_counts(deltas, round_digits=round_digits)

        dat_path = destination / f"spectrum_{name.lower().replace(' ', '_')}.dat"
        with dat_path.open("w", encoding="utf-8") as handle:
            handle.write("# Delta_M_rad \t Absolute_Haeufigkeit\n")
            for value in sorted(counts):
                handle.write(f"{value:.{round_digits}f} \t {counts[value]}\n")

        written_paths.append(dat_path)
        print(f"\n[Export] {name} -> {dat_path}")
        print("  Diskretes Linienspektrum (ASCII-Vorschau):")

        max_count = max(counts.values()) if counts else 1
        for value in sorted(counts):
            bar = "#" * int((counts[value] / max_count) * bar_width)
            print(f"  ΔM = {value:8.{round_digits}f} rad/Schritt: {bar:<{bar_width}} (n={counts[value]})")

    print("=========================================")
    return tuple(written_paths)
