#!/usr/bin/env python3
"""Run §5.22 Φ_k relation-classifier audit (focus cycles k=10..14)."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.eabc_relation_classifier_phi_k import main  # noqa: E402

if __name__ == "__main__":
    raise SystemExit(main())
