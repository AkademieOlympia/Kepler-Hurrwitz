"""Tests für den kanonischen Phasen-/Kollisions-Auditor [B]."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

from kepler_hurwitz.cycle_phase_compressor import (
    GOVERNANCE,
    audit_phase_reconstruction,
    audit_target_reconstruction,
    construct_cycle_phase,
    require,
)
from kepler_hurwitz.odd_core_residue import (
    odd_core_step_mod,
    odd_residues_mod,
    projected_odd_core_step,
    require_power_of_two,
)
from kepler_hurwitz.octonionic_collatz_freeze_diagnostic import odd_core_step
from kepler_hurwitz.smoothness_channel_scan import next_odd_core_after_kick

PHASE_A_MODULI = (8, 16, 32, 64, 128)
ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


class TestRequire:
    def test_passes_on_true(self) -> None:
        require(True, "should not raise")

    def test_raises_on_false(self) -> None:
        with pytest.raises(RuntimeError, match="AUDIT FAILED"):
            require(False, "broken")


class TestOddCoreResidueBinding:
    """Production oddCoreStep binding — not a placeholder Collatz map."""

    def test_matches_lean_odd_core_step(self) -> None:
        for n in range(1, 200, 2):
            assert odd_core_step(n) == next_odd_core_after_kick(n)

    def test_mod_projection_matches_odd_core_step(self) -> None:
        for m in PHASE_A_MODULI:
            for r in odd_residues_mod(m):
                assert odd_core_step_mod(r, m) == odd_core_step(r) % m

    def test_rejects_non_power_of_two(self) -> None:
        with pytest.raises(ValueError, match="power of two"):
            require_power_of_two(12)
        with pytest.raises(ValueError, match="power of two"):
            odd_core_step_mod(1, 12)


class TestConstructCyclePhaseToy:
    """Toy graph: cycle 0→1→2→0 with trees feeding in; L=3."""

    @staticmethod
    def _toy_step() -> dict[int, int]:
        # Basin trees: 3→0, 4→3, 5→1
        return {0: 1, 1: 2, 2: 0, 3: 0, 4: 3, 5: 1}

    def test_phase_covariance_and_depth_descent(self) -> None:
        nxt = self._toy_step()
        states = tuple(sorted(nxt))
        phase, depth, report = construct_cycle_phase(states, nxt.__getitem__)

        assert report.cycle_length == 3
        assert report.max_depth == 2  # 4 → 3 → 0
        assert report.phase_trivial is False
        assert GOVERNANCE == "[B]"

        for x in states:
            assert phase[nxt[x]] == (phase[x] + 1) % 3
            assert depth[nxt[x]] <= depth[x]
            if depth[x] > 0:
                assert depth[nxt[x]] == depth[x] - 1

        # Cycle nodes have depth 0.
        assert depth[0] == depth[1] == depth[2] == 0
        assert depth[3] == 1
        assert depth[4] == 2
        assert depth[5] == 1

    def test_weak_connectivity_required(self) -> None:
        # Two fixed points: disconnected.
        states = (0, 1)
        nxt = {0: 0, 1: 1}
        with pytest.raises(RuntimeError, match="not weakly connected"):
            construct_cycle_phase(states, nxt.__getitem__)

    def test_anchored_vs_unanchored_phase_differ_by_global_constant(self) -> None:
        nxt = self._toy_step()
        states = tuple(sorted(nxt))
        phase_a, depth_a, report_a = construct_cycle_phase(
            states, nxt.__getitem__, canonical_key=lambda x: x
        )
        phase_b, depth_b, report_b = construct_cycle_phase(
            states, nxt.__getitem__, canonical_key=lambda x: -x
        )

        assert report_a.cycle_length == report_b.cycle_length == 3
        assert depth_a == depth_b

        # Different anchors ⇒ phases differ by a global additive constant mod L.
        offsets = {(phase_a[x] - phase_b[x]) % 3 for x in states}
        assert len(offsets) == 1
        assert offsets != {0}  # distinct anchors yield distinct gauges

        for x in states:
            assert phase_a[nxt[x]] == (phase_a[x] + 1) % 3
            assert phase_b[nxt[x]] == (phase_b[x] + 1) % 3

        # Unanchored construction still covaries; may match one gauge.
        phase_free, _, _ = construct_cycle_phase(states, nxt.__getitem__)
        for x in states:
            assert phase_free[nxt[x]] == (phase_free[x] + 1) % 3

    def test_unique_anchor_works_on_l_gt_1_toy(self) -> None:
        nxt = self._toy_step()
        states = tuple(sorted(nxt))
        phase, depth, report = construct_cycle_phase(
            states, nxt.__getitem__, canonical_key=lambda x: x
        )
        assert report.cycle_length == 3
        assert report.phase_trivial is False
        # Unique min key on cycle {0,1,2} is 0 ⇒ phase origin at 0.
        assert phase[0] == 0
        assert depth[0] == 0
        for x in states:
            assert phase[nxt[x]] == (phase[x] + 1) % 3

    def test_ambiguous_canonical_key_raises_audit_failed(self) -> None:
        nxt = self._toy_step()
        states = tuple(sorted(nxt))
        # Constant key makes every cycle node a minimum ⇒ N=3.
        with pytest.raises(
            RuntimeError,
            match=(
                r"AUDIT FAILED: Phase normalization is ambiguous: "
                r"canonical_key has 3 minimal cycle nodes\."
            ),
        ):
            construct_cycle_phase(
                states, nxt.__getitem__, canonical_key=lambda _x: 0
            )

        # Two cycle nodes share the same min key; third is larger.
        def two_minima(x: int) -> int:
            return 0 if x in (0, 1) else 1

        with pytest.raises(
            RuntimeError,
            match=(
                r"AUDIT FAILED: Phase normalization is ambiguous: "
                r"canonical_key has 2 minimal cycle nodes\."
            ),
        ):
            construct_cycle_phase(
                states, nxt.__getitem__, canonical_key=two_minima
            )


class TestAuditTargetReconstruction:
    def test_identity_success_reports_f_q_minimal(self) -> None:
        nxt = {0: 1, 1: 2, 2: 0, 3: 0}
        states = (0, 1, 2, 3)
        phase, _depth, _report = construct_cycle_phase(states, nxt.__getitem__)
        result = audit_target_reconstruction(states, phase, lambda x: x)
        assert result["reconstructs_target"] is True
        assert result["state_count"] == 4
        assert result["distinct_feature_vectors"] == 4
        assert result["target_classes_count"] == 3  # phases 0,1,2
        assert result["state_compression_ratio"] == pytest.approx(4 / 4)
        assert result["minimal_for_target"] is False  # F=4 > Q=3

    def test_depth_identity_is_minimal(self) -> None:
        nxt = {0: 1, 1: 2, 2: 0, 3: 0}
        states = (0, 1, 2, 3)
        _phase, depth, _report = construct_cycle_phase(states, nxt.__getitem__)
        # Feature = depth value itself ⇒ F == Q.
        result = audit_target_reconstruction(states, depth, lambda x: depth[x])
        assert result["reconstructs_target"] is True
        assert result["distinct_feature_vectors"] == result["target_classes_count"]
        assert result["minimal_for_target"] is True

    def test_collision_returns_full_witness_pair(self) -> None:
        nxt = {0: 1, 1: 2, 2: 0, 3: 0}
        states = (0, 1, 2, 3)
        phase, depth, _report = construct_cycle_phase(states, nxt.__getitem__)
        result = audit_target_reconstruction(states, depth, lambda _x: 0)
        assert result["reconstructs_target"] is False
        collision = result["collision"]
        assert set(collision) == {
            "feature_vector",
            "first_state",
            "first_value",
            "second_state",
            "second_value",
        }
        x = collision["first_state"]
        y = collision["second_state"]
        assert x != y
        assert collision["feature_vector"] == 0
        assert collision["first_value"] != collision["second_value"]
        assert depth[x] == collision["first_value"]
        assert depth[y] == collision["second_value"]
        # Constant M: M(x)=M(y) but d(x)≠d(y); φ may coincide or differ.
        assert depth[x] != depth[y]
        assert isinstance(phase[x], int) and isinstance(phase[y], int)

    def test_alias_matches_target_audit(self) -> None:
        nxt = {0: 0, 1: 0}
        states = (0, 1)
        _phase, depth, _report = construct_cycle_phase(states, nxt.__getitem__)
        a = audit_target_reconstruction(states, depth, lambda x: x)
        b = audit_phase_reconstruction(states, depth, lambda x: x)
        assert a == b

    def test_target_must_cover_universe(self) -> None:
        with pytest.raises(RuntimeError, match="does not cover exactly"):
            audit_target_reconstruction((0, 1), {0: 0}, lambda x: x)


class TestPhaseAOddCoreMonoliths:
    """Phase-A fact: L=1 monoliths on m∈{8..128} via real odd_core_step_mod."""

    @pytest.mark.parametrize("modulus", PHASE_A_MODULI)
    def test_monolith_phase_depth_cover(self, modulus: int) -> None:
        states = odd_residues_mod(modulus)
        step = projected_odd_core_step(modulus)
        phase, depth, report = construct_cycle_phase(
            states,
            step,
            canonical_key=lambda x: x,
        )

        assert report.state_count == modulus // 2
        assert report.cycle_length == 1
        assert report.phase_trivial is True
        assert set(phase.values()) == {0}
        assert set(phase) == set(states)
        assert set(depth) == set(states)
        assert depth[1] == 0  # unique attractor {1}
        assert sum(report.phase_histogram.values()) == report.state_count
        assert sum(report.depth_histogram.values()) == report.state_count

        for r in states:
            assert step(r) == odd_core_step_mod(r, modulus)
            assert phase[step(r)] == (phase[r] + 1) % 1
            assert depth[step(r)] <= depth[r]

        id_audit = audit_target_reconstruction(states, depth, lambda r: r)
        assert id_audit["reconstructs_target"] is True
        assert id_audit["state_count"] == len(states)
        assert "minimal_for_target" in id_audit
        if report.max_depth > 0:
            const_audit = audit_target_reconstruction(states, depth, lambda _r: 0)
            assert const_audit["reconstructs_target"] is False
            coll = const_audit["collision"]
            assert coll["first_state"] != coll["second_state"]
            assert coll["first_value"] != coll["second_value"]


class TestOptimizationFlagIndependence:
    """``require`` and audit stdout must be identical under ``python -O``."""

    def test_audit_runner_stdout_identical_under_dash_o(self, tmp_path: Path) -> None:
        import os

        moduli = ["8", "16"]
        env = os.environ.copy()
        env["PYTHONPATH"] = str(SRC)

        log_a = tmp_path / "audit_normal.log"
        log_b = tmp_path / "audit_opt.log"
        cmd_base = [
            "-m",
            "kepler_hurwitz.run_cycle_phase_audit",
            "--moduli",
            *moduli,
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
        assert "CYCLE PHASE AUDIT: PASSED" in r1.stdout
        assert r1.stdout == r2.stdout
        assert log_a.read_text(encoding="utf-8") == log_b.read_text(encoding="utf-8")
