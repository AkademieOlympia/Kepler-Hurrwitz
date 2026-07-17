#!/usr/bin/env python3
"""Thin example entry for the bigraded cylinder cutoff audit runner.

Prefer (attestation path):
    PYTHONPATH=. python -m mathdictate.run_bigraded_cylinder_audit \\
      --max-precisions 4 6 8 10 12
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from mathdictate.run_bigraded_cylinder_audit import main  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
