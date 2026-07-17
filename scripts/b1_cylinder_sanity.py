#!/usr/bin/env python3
"""B1 sanity gatekeeper for the bigraded cylinder cutoff (Schicht B1).

Operational Vorab-Check only. Does **not** attest Schicht B2.
Hard ``SystemExit`` on any mismatch; single success line on stdout.

Usage (repo root)::

    PYTHONPATH=. python scripts/b1_cylinder_sanity.py

Epistemic::

    B1_SANITY deklariert ≠ B2 auf HEAD verankert ≠ B2 ausgeführt und beglaubigt
"""

from __future__ import annotations

from mathdictate.bigraded_cylinder_graph import (
    audit_cylinder_cutoff,
    complete_cutoff,
    compute_visible_valuation,
)


def fail(msg: str) -> None:
    raise SystemExit(f"B1_SANITY FAILED: {msg}")


def check_precision(P: int) -> None:
    cylinders = complete_cutoff(P)
    expected_states = (1 << P) - 1
    if len(cylinders) != expected_states:
        fail(f"cutoff size for P={P}: got {len(cylinders)}, expected {expected_states}")

    universe_keys = {(c.residue, c.precision) for c in cylinders}
    singular_by_p: dict[int, object] = {}
    internal_lifts = 0
    boundary_lifts = 0

    for c in cylinders:
        j = compute_visible_valuation(c.residue, c.precision)
        if not (1 <= j <= c.precision):
            fail(f"visible valuation out of range at r={c.residue} p={c.precision}: j={j}")

        if j < c.precision:
            next_p = c.precision - j
            next_r = ((3 * c.residue + 1) // (1 << j)) % (1 << next_p)
            target = (next_r, next_p)
            if target not in universe_keys:
                fail(f"dynamics target missing: ({c.residue},{c.precision}) -> {target}")
        else:
            if c.precision in singular_by_p:
                fail(f"more than one singular j=p on level p={c.precision}")
            singular_by_p[c.precision] = c
            r0, p = c.residue, c.precision
            j1 = compute_visible_valuation(r0, p + 1)
            j2 = compute_visible_valuation(r0 + (1 << p), p + 1)
            if {j1, j2} != {p, p + 1}:
                fail(f"singular split at p={p} r={r0}: got {{{j1},{j2}}}")

        for lift_r in (c.residue, c.residue + (1 << c.precision)):
            in_universe = (lift_r, c.precision + 1) in universe_keys
            expected_boundary = c.precision == P
            if in_universe == expected_boundary:
                fail(
                    f"lift boundary class at r={c.residue} p={c.precision} "
                    f"lift_r={lift_r}: in_universe={in_universe} "
                    f"expected_boundary={expected_boundary}"
                )
            if expected_boundary:
                boundary_lifts += 1
            else:
                internal_lifts += 1

    for p in range(1, P + 1):
        if p not in singular_by_p:
            fail(f"missing singular j=p on level p={p}")

    if internal_lifts != (1 << P) - 2:
        fail(f"internal lifts P={P}: got {internal_lifts}, expected {(1 << P) - 2}")
    if boundary_lifts != (1 << P):
        fail(f"boundary lifts P={P}: got {boundary_lifts}, expected {1 << P}")

    _, _, report = audit_cylinder_cutoff(cylinders)
    if report.state_count != expected_states:
        fail(f"auditor state_count P={P}: {report.state_count}")
    if report.internal_lift_edges != (1 << P) - 2:
        fail(f"auditor internal lifts P={P}: {report.internal_lift_edges}")
    if report.boundary_lift_edges != (1 << P):
        fail(f"auditor boundary lifts P={P}: {report.boundary_lift_edges}")
    if report.singular_split_verified_count != P:
        fail(
            f"auditor singular_split_verified_count P={P}: "
            f"{report.singular_split_verified_count}"
        )
    for p in range(1, P + 1):
        if report.lift_required_by_precision.get(p) != 1:
            fail(
                f"auditor singular count on p={p}: "
                f"{report.lift_required_by_precision.get(p)}"
            )


def main() -> None:
    for P in (4, 6):
        check_precision(P)
    print("B1_SANITY: PASSED")


if __name__ == "__main__":
    main()
