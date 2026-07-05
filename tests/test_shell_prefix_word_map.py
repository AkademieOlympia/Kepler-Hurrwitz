import math

import pytest

from kepler_hurwitz.energiedoku_shell_construction import (
    diagnostic_shell_count,
    shell_word_count,
    shells_at_level,
)
from kepler_hurwitz.shell_embedding_comparison import (
    export_full_energiedoku_csv,
    run_full_energiedoku_diagnostics,
)
from kepler_hurwitz.shell_prefix_word_map import (
    BIJECTION_STATUS,
    compare_mapped_coordinates,
    export_prefix_word_map_csv,
    run_prefix_word_map,
)
from kepler_hurwitz.shell_separation_diagnostics import shell_sep


class TestShellPrefixWordMap:
    def test_bijection_status_is_partial(self):
        report = run_prefix_word_map(n_max=3)
        assert report.bijection_status == BIJECTION_STATUS
        assert report.bijection_status == "partial_no_global_bijection"
        assert len(report.bijection_reasons) >= 3
        assert sum(1 for r in report.rows if r.coordinate_match_diagnostic) == 0

    def test_compare_mapped_coordinates_n123(self):
        for n in (1, 2, 3):
            rows = compare_mapped_coordinates(n)
            assert len(rows) == n + 1
            for row in rows:
                assert row.n == n
                assert math.isfinite(row.diagnostic_lex_diff_l2)
                assert math.isfinite(row.nearest_word_diff_l2)

    def test_no_exact_diagnostic_lex_matches(self):
        report = run_prefix_word_map(n_max=3)
        exact = [r for r in report.rows if r.coordinate_match_diagnostic]
        assert exact == []

    def test_export_prefix_map_csv(self, tmp_path):
        report = run_prefix_word_map(n_max=3)
        path = export_prefix_word_map_csv(report, tmp_path / "map.csv")
        text = path.read_text(encoding="utf-8")
        assert "diagnostic_lex_word" in text
        assert "nearest_word_n" in text
        assert text.count("\n") >= len(report.rows) + 1


class TestFullEnergiedokuDiagnostics:
    def test_full_n2_has_16_vertices(self):
        shells = shells_at_level(2, mode="full")
        assert len(shells) == 16
        assert shell_word_count(2) == 16

    def test_full_n3_has_64_vertices(self):
        shells = shells_at_level(3, mode="full")
        assert len(shells) == 64
        assert shell_word_count(3) == 64

    def test_n2_sep_equals_phi_inv_sq_on_full(self):
        shells = shells_at_level(2, mode="full")
        sep = shell_sep(shells)
        assert sep == pytest.approx(0.381966011250105, rel=0, abs=1e-6)

    def test_n2_loss_robust_on_full(self):
        report = run_full_energiedoku_diagnostics(levels=(2,))
        assert report.rows[0].shell_count == 16
        assert report.n2_loss_robust_on_full is True
        assert report.rows[0].shell_separation_loss_energiedoku is True
        assert report.rows[0].shell_separation_loss_mn_sep is False

    def test_first_loss_n_energiedoku_is_2(self):
        report = run_full_energiedoku_diagnostics(levels=(1, 2, 3))
        assert report.first_loss_n_energiedoku == 2
        assert report.first_loss_n_mn_sep is None

    def test_diagnostic_vs_full_count(self):
        assert diagnostic_shell_count(2) == 3
        assert len(shells_at_level(2, mode="diagnostic")) == 3

    def test_export_full_csv(self, tmp_path):
        report = run_full_energiedoku_diagnostics(levels=(1, 2, 3))
        path = export_full_energiedoku_csv(report, tmp_path / "full.csv")
        text = path.read_text(encoding="utf-8")
        assert "shell_separation_loss_energiedoku" in text
        assert "first_loss_n_energiedoku" in text
