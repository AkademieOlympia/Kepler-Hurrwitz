"""Export EABC six-state / mod-6 prime-axis transition table."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_six_state_prime_axes import (  # noqa: E402
    GOVERNANCE,
    MOD6_TO_STATE,
    SIX_STATE_TAG,
    analyze_prime_transitions,
    get_eabc_state,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export EABC six-state prime-axis diagnostics (sibling E-093)."
    )
    parser.add_argument("--limit", type=int, default=500, help="Prime upper bound.")
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT}).",
    )
    parser.add_argument(
        "--print-table",
        action="store_true",
        help="Print mod-6 residue table to stdout.",
    )
    args = parser.parse_args()

    if args.print_table:
        print(f"EABC six-state map {SIX_STATE_TAG}")
        for residue, state in sorted(MOD6_TO_STATE.items()):
            print(f"  {residue} → {state}")

    transitions = analyze_prime_transitions(args.limit)
    payload = {
        "tag": SIX_STATE_TAG,
        "limit": args.limit,
        "mod6_table": MOD6_TO_STATE,
        "governance": GOVERNANCE,
        "transitions": transitions,
    }

    args.out_dir.mkdir(parents=True, exist_ok=True)
    out_path = args.out_dir / "eabc_six_state_prime_transitions.json"
    out_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(transitions)} transitions → {out_path}")


if __name__ == "__main__":
    main()
