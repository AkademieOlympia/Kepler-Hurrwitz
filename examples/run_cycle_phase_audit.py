#!/usr/bin/env python3
"""Thin example entry for the cycle-phase audit runner.

Prefer:
    PYTHONPATH=src python -m kepler_hurwitz.run_cycle_phase_audit
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.run_cycle_phase_audit import main  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
