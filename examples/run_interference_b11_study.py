import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "docs" / "energiedoku_exports"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.interference_b11_study import (  # noqa: E402
    run_interference_b11_study,
    study_result_record,
)


def main() -> None:
    limit_m = 200_001
    b_bound = 11
    mu = -2.5
    s = 15.0 / 4.0

    result = run_interference_b11_study(
        limit_m=limit_m,
        b_bound=b_bound,
        mu=mu,
        s=s,
    )

    payload = {
        "metadata": {
            "generated_at_utc": datetime.now(timezone.utc).isoformat(),
            "study_id": "E-003-B-v1",
            "script": "examples/run_interference_b11_study.py",
        },
        "result": study_result_record(result),
    }

    destination = OUT / "interference_b11_study.json"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    print("Interference-B11-Study geschrieben:")
    print(f"- {destination}")
    print(
        "Metriken:"
        f" admissible={result.is_interference_admissible},"
        f" hit_rate={result.b11_hit_rate:.6f},"
        f" violations={result.violation_count},"
        f" n={result.evaluated_count}"
    )


if __name__ == "__main__":
    main()
