import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "docs" / "energiedoku_exports"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.export import (
    export_cyclic_word_classes_csv,
    export_cyclic_word_classes_json,
    export_octonionic_slice_csv,
    export_octonionic_slice_json,
    export_primvierling_analysis_csv,
    export_primvierling_analysis_json,
    export_smoothness_b_bound_matrix_json,
    export_smoothness_b_bound_summary_json,
    export_smoothness_channels_csv,
    export_smoothness_channels_json,
    export_smoothness_scale_stability_json,
    export_smoothness_significance_json,
)
from kepler_hurwitz.primvierling import analyze_range
from kepler_hurwitz.smoothness_channel_scan import scan_smoothness_channels


def main() -> None:
    analyses = analyze_range(start=3, stop=500)
    words = ["1011", "0111", "1101", "1110", "0101", "1010", "0011", "1100"]
    limit_m = 1999
    b = 5
    smoothness_samples = scan_smoothness_channels(limit_m=limit_m, b=b)
    mu_values = [-4.0, -3.0, -2.5, -2.0, -1.0, 0.0]
    q_values = [-3.0, -2.0, -(15**0.5) / 2.0, 0.0, (15**0.5) / 2.0, 2.0, 3.0]

    prim_json = export_primvierling_analysis_json(analyses, OUT / "primvierling.json")
    prim_csv = export_primvierling_analysis_csv(analyses, OUT / "primvierling.csv")
    word_json = export_cyclic_word_classes_json(words, OUT / "cyclic_words.json")
    word_csv = export_cyclic_word_classes_csv(words, OUT / "cyclic_words.csv")
    smooth_json = export_smoothness_channels_json(
        smoothness_samples,
        OUT / "smoothness_channels.json",
        limit_m=limit_m,
        b=b,
    )
    smooth_csv = export_smoothness_channels_csv(
        smoothness_samples,
        OUT / "smoothness_channels.csv",
        limit_m=limit_m,
        b=b,
    )
    smooth_significance_json = export_smoothness_significance_json(
        smoothness_samples,
        OUT / "smoothness_significance.json",
        limit_m=limit_m,
        b=b,
    )
    scale_stability_json = export_smoothness_scale_stability_json(
        OUT / "smoothness_scale_stability.json",
        b=b,
        limits=[1000, 10000, 100000],
    )
    b_bound_matrix_json = export_smoothness_b_bound_matrix_json(
        OUT / "smoothness_b_bound_matrix.json",
        b_bounds=[3, 5, 7, 11],
        limits=[1000, 10000, 100000],
    )
    b_bound_summary_json = export_smoothness_b_bound_summary_json(
        OUT / "smoothness_b_bound_summary.json",
        b_bounds=[3, 5, 7, 11],
        limits=[1000, 10000, 100000],
    )
    octonionic_json = export_octonionic_slice_json(
        OUT / "octonionic_slice_constraints.json",
        mu_values=mu_values,
        q_values=q_values,
    )
    octonionic_csv = export_octonionic_slice_csv(
        OUT / "octonionic_slice_constraints.csv",
        mu_values=mu_values,
        q_values=q_values,
    )

    print("Energiedoku exports geschrieben:")
    print(f"- {prim_json}")
    print(f"- {prim_csv}")
    print(f"- {word_json}")
    print(f"- {word_csv}")
    print(f"- {smooth_json}")
    print(f"- {smooth_csv}")
    print(f"- {smooth_significance_json}")
    print(f"- {scale_stability_json}")
    print(f"- {b_bound_matrix_json}")
    print(f"- {b_bound_summary_json}")
    print(f"- {octonionic_json}")
    print(f"- {octonionic_csv}")


if __name__ == "__main__":
    main()
