import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.smoothness_channel_scan import scan_smoothness_channels, summarize_scan


def main() -> None:
    limit_m = 1999
    b = 5
    samples = scan_smoothness_channels(limit_m=limit_m, b=b)
    summary = summarize_scan(samples)

    print("Smoothness-Channel-Scan")
    print("-----------------------")
    print(f"limit_m={limit_m}, b={b}, odd_samples={len(samples)}")
    for channel in ("klein", "mittel", "tief"):
        total = summary[channel]["total"]
        smooth = summary[channel]["b_smooth"]
        ratio = 0.0 if total == 0 else smooth / total
        print(f"{channel}: total={total}, b_smooth={smooth}, ratio={ratio:.3f}")


if __name__ == "__main__":
    main()
