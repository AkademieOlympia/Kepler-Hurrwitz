"""Compatibility runner: prefer ``python -m mathdictate.run_bigraded_cylinder_audit``.

Usage:
    PYTHONPATH=. python -m mathdictate.run_bigraded_cylinder_audit \\
      --max-precisions 4 6 8 10 12
"""

from __future__ import annotations

from mathdictate.run_bigraded_cylinder_audit import (  # noqa: F401
    DEFAULT_PRECISIONS,
    __all__,
    audit_precision,
    build_audit_payload,
    main,
)

if __name__ == "__main__":
    raise SystemExit(main())
