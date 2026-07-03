import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.primvierling import analyze_range, summarize_analysis


def main() -> None:
    analyses = analyze_range(start=3, stop=300)
    print(summarize_analysis(analyses))


if __name__ == "__main__":
    main()
