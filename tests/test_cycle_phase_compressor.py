"""Tests für den kanonischen Phasen-/Kollisions-Auditor [B]."""

from __future__ import annotations

import pytest

from kepler_hurwitz.cycle_phase_compressor import (
    GOVERNANCE,
    audit_phase_reconstruction,
    audit_target_reconstruction,
    construct_cycle_phase,
    require,
)
from kepler_hurwitz.octonionic_collatz_freeze_diagnostic import odd_core_step


class TestRequire:
    def test_passes_on_true(self) -> None:
        require(True, "should not raise")

    def test_raises_on_false(self) -> None:
        with pytest.raises(RuntimeError, match="AUDIT FAILED"):
            require(False, "broken")


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


class TestMonolithOddMod8:
    def test_l1_passes_requires(self) -> None:
        m = 8
        states = tuple(r for r in range(1, m, 2))

        def step(r: int) -> int:
            return odd_core_step(r) % m

        phase, depth, report = construct_cycle_phase(states, step)
        assert report.cycle_length == 1
        assert report.phase_trivial is True
        assert set(phase.values()) == {0}
        assert depth[1] == 0
        assert report.max_depth >= 0
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
