"""Tests für den exhaustiven 2-adischen Zylinder-Cutoff-Auditor [B] (Schicht B2)."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import pytest

from kepler_hurwitz.bigraded_cylinder_graph import (
    GOVERNANCE,
    Cylinder,
    audit_cylinder_cutoff,
    complete_cutoff,
    compute_visible_valuation,
    require,
)

PRECISIONS = (3, 4, 6, 8)
ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


class TestRequire:
    def test_passes_on_true(self) -> None:
        require(True, "should not raise")

    def test_raises_on_false(self) -> None:
        with pytest.raises(RuntimeError, match="GOVERNANCE VIOLATION"):
            require(False, "broken")


class TestVisibleValuation:
    def test_basic_odd_residue(self) -> None:
        # r=1, p=3: 3*1+1=4 → v2=2 (< 3)
        assert compute_visible_valuation(1, 3) == 2

    def test_singular_at_p3(self) -> None:
        # -1/3 ≡ 5 (mod 8): j_3(5)=3
        assert compute_visible_valuation(5, 3) == 3


class TestCompleteCutoffAudit:
    @pytest.mark.parametrize("max_precision", PRECISIONS)
    def test_combinatorial_counts_and_singular_path(self, max_precision: int) -> None:
        cylinders = complete_cutoff(max_precision)
        lifts, dynamics, report = audit_cylinder_cutoff(cylinders)

        assert GOVERNANCE == "[B]"
        assert report.expected_states == (1 << max_precision) - 1
        assert report.state_count == report.expected_states
        assert len(cylinders) == report.expected_states

        assert report.singular_split_verified_count == max_precision
        assert len(report.singular_path_prefix) == max_precision
        assert all(
            report.lift_required_by_precision[p] == 1
            for p in range(1, max_precision + 1)
        )

        # Exactly one lift-required singular node per level
        for p in range(1, max_precision + 1):
            singulars = [
                c
                for c in cylinders
                if c.precision == p
                and compute_visible_valuation(c.residue, c.precision) == p
            ]
            assert len(singulars) == 1
            assert singulars[0] == report.singular_path_prefix[p - 1]

        # Singular path chain connections s_p ⇝ s_{p+1}
        for p in range(1, max_precision):
            current = report.singular_path_prefix[p - 1]
            nxt = report.singular_path_prefix[p]
            lift_a = Cylinder(current.residue, p + 1)
            lift_b = Cylinder(current.residue + (1 << p), p + 1)
            singular_lifts = [
                lift
                for lift in (lift_a, lift_b)
                if compute_visible_valuation(lift.residue, lift.precision) == p + 1
            ]
            assert singular_lifts == [nxt]

        # Internal dynamics: no missing targets (already audited); all targets in universe
        universe = set(cylinders)
        for edge in dynamics:
            assert edge.target in universe
            assert edge.source.precision - edge.valuation == edge.target.precision

        # Boundary / internal lift counts
        assert report.internal_lift_edges == (1 << max_precision) - 2
        assert report.boundary_lift_edges == 1 << max_precision
        assert report.internal_lift_edges == report.expected_internal_lifts
        assert report.boundary_lift_edges == report.expected_boundary_lifts
        assert sum(1 for e in lifts if e.is_boundary) == report.boundary_lift_edges
        assert sum(1 for e in lifts if not e.is_boundary) == report.internal_lift_edges

    def test_incomplete_universe_fails(self) -> None:
        cylinders = list(complete_cutoff(4))
        incomplete = tuple(c for c in cylinders if c != cylinders[0])
        with pytest.raises(
            RuntimeError,
            match=r"(GOVERNANCE VIOLATION|AUDIT FAILED)",
        ):
            audit_cylinder_cutoff(incomplete)

    def test_empty_universe_fails(self) -> None:
        with pytest.raises(RuntimeError, match="AUDIT FAILED"):
            audit_cylinder_cutoff(())

    def test_duplicates_fail(self) -> None:
        c = Cylinder(1, 1)
        with pytest.raises(RuntimeError, match="AUDIT FAILED"):
            audit_cylinder_cutoff((c, c))


class TestOptimizationFlagIndependence:
    """``require`` and audit stdout must be identical under ``python -O``."""

    def test_audit_runner_stdout_identical_under_dash_o(self, tmp_path: Path) -> None:
        precisions = ["4", "6"]
        env = os.environ.copy()
        env["PYTHONPATH"] = str(SRC)

        log_a = tmp_path / "audit_normal.log"
        log_b = tmp_path / "audit_opt.log"
        cmd_base = [
            "-m",
            "kepler_hurwitz.run_bigraded_cylinder_audit",
            "--precisions",
            *precisions,
            "--out",
        ]
        r1 = subprocess.run(
            [sys.executable, *cmd_base, str(log_a)],
            capture_output=True,
            text=True,
            env=env,
            check=False,
        )
        r2 = subprocess.run(
            [sys.executable, "-O", *cmd_base, str(log_b)],
            capture_output=True,
            text=True,
            env=env,
            check=False,
        )
        assert r1.returncode == 0, r1.stderr
        assert r2.returncode == 0, r2.stderr
        assert "BIGRADED CYLINDER AUDIT: PASSED" in r1.stdout
        assert r1.stdout == r2.stdout
        assert log_a.read_text(encoding="utf-8") == log_b.read_text(encoding="utf-8")
