import math

import pytest

from kepler_hurwitz.shell_prefix_word_map import (
    canonical_prefix_coordinate,
    interpretive_axis_label_for_prefix,
)
from kepler_hurwitz.shell_separation_diagnostics import (
    SHELL_PRIME_MATCH_GATE_ACTIVE,
)
from kepler_hurwitz.unified_shell_embedding import (
    UNIFIED_BRIDGE_GATE_ELIGIBLE,
    UNIFIED_BRIDGE_STATUS,
    UnifiedEmbeddingBridge,
    export_unified_bridge_csv,
    run_unified_bridge_report,
)


class TestUnifiedEmbeddingBridge:
    def test_bridge_builds_for_n123(self):
        bridge = UnifiedEmbeddingBridge.default()
        for n in (1, 2, 3):
            for i in range(n + 1):
                bp = bridge.bridged_point(n, i)
                assert len(bp) == 3
                assert all(math.isfinite(c) for c in bp)
                letter, status = bridge.axis_label(n, i)
                assert letter in ("E", "A", "B", "C", "?")
                assert status in ("A", "C", "H")

    def test_n1_sign_correction_aligns_axis_c(self):
        bridge = UnifiedEmbeddingBridge.default()
        bp = bridge.bridged_point(1, 0)
        assert bp == pytest.approx((-1.0, 0.0, 0.0))
        letter, _ = bridge.axis_label(1, 0)
        assert letter == "C"

    def test_compatibility_check_runs_and_passes(self):
        bridge = UnifiedEmbeddingBridge.default()
        for n in (1, 2):
            result = bridge.compatibility_check(n)
            assert result.n_plus_1 == n + 1
            assert result.bridged_compatible is True
            assert result.raw_canonical_compatible is True
            assert result.proof_status == "A"
            assert result.mismatched_indices == ()

    def test_bridge_sep_matches_canonical_under_uniform_transform(self):
        bridge = UnifiedEmbeddingBridge.default()
        for n in (1, 2, 3):
            sep = bridge.bridge_sep(n)
            assert sep.sep_bridged == pytest.approx(sep.sep_canonical)
            assert sep.sep_delta_bridged_vs_canonical == pytest.approx(0.0)

    def test_gate_still_inactive(self):
        report = run_unified_bridge_report(n_max=3)
        assert SHELL_PRIME_MATCH_GATE_ACTIVE is False
        assert UNIFIED_BRIDGE_GATE_ELIGIBLE is False
        assert report.gate_eligible is False
        assert report.gate_active is False

    def test_report_covers_all_prefix_rows(self):
        report = run_unified_bridge_report(n_max=3)
        expected = sum(n + 1 for n in (1, 2, 3))
        assert len(report.rows) == expected
        assert report.bridge_status == UNIFIED_BRIDGE_STATUS
        assert len(report.compatibility_results) == 2
        assert len(report.sep_results) == 3

    def test_export_csv(self, tmp_path):
        report = run_unified_bridge_report(n_max=3)
        path = export_unified_bridge_csv(report, tmp_path / "bridge.csv")
        text = path.read_text(encoding="utf-8")
        assert "axis_label_status" in text
        assert "gate_eligible" in text
        assert "False" in text
        assert text.count("\n") >= len(report.rows) + 1


class TestShellPrefixWordMapBridgeHelpers:
    def test_canonical_prefix_coordinate(self):
        p = canonical_prefix_coordinate(1, 0)
        assert p == (-1.0, 0.0, 0.0)

    def test_interpretive_axis_label_n1(self):
        letter, rule = interpretive_axis_label_for_prefix(1, 0)
        assert letter == "C"
        assert rule == "coordinate_axis_label"
