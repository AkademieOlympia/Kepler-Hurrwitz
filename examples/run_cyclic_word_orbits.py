import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.cyclic_words import reduce_words_by_orbit


def main() -> None:
    words = ["1011", "0111", "1101", "1110", "0101", "1010"]
    classes = reduce_words_by_orbit(words)
    print("Cyclic word orbit classes")
    print("-------------------------")
    for canonical, members in sorted(classes.items()):
        print(f"{canonical}: {sorted(members)}")


if __name__ == "__main__":
    main()
