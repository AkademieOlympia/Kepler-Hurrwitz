import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.examples import basic_kepler_example, basic_signature_example


def main() -> None:
    signature = basic_signature_example()
    invariants = basic_kepler_example()

    print("Kepler-Hurrwitz basic example")
    print("----------------------------")
    print(f"signature={signature.as_tuple()}")
    print(f"total_weight={signature.total_weight()}")
    print(f"orientation_balance={signature.orientation_balance()}")
    print()
    print(f"eccentricity={invariants.eccentricity}")
    print(f"radius_ratio={invariants.radius_ratio}")
    print(f"velocity_ratio={invariants.velocity_ratio}")


if __name__ == "__main__":
    main()
