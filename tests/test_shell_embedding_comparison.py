import math

import pytest

from kepler_hurwitz.energiedoku_shell_construction import (
    CSV_FIELDNAMES,
    DEFAULT_COORDINATES_CSV,
    EClass,
    EnergiedokuShellConstruction,
    build_energiedoku_shells_n_le_3,
    cardinal_dir,
    coordinate_count_for_level,
    coordinate_table,
    coordinates_source,
    diagnostic_shell_count,
    embed_shell_word,
    enumerate_shell_words,
    load_coordinates_from_csv,
    shell_word_count,
    shells_at_level,
    theorematic_epsilon_for_level,
)
from kepler_hurwitz.shell_construction import PHI_INV_CUBE, PHI_INV_SQ
from kepler_hurwitz.shell_embedding_comparison import (
    compare_level,
    export_comparison_csv,
    hausdorff_proxy,
    run_shell_embedding_comparison,
)
from kepler_hurwitz.shell_separation_diagnostics import shell_sep


class TestEnergiedokuShellConstruction:
    def test_builds_for_n_le_3(self):
        series = build_energiedoku_shells_n_le_3()
        assert set(series) == {1, 2, 3}
        for n, shells in series.items():
            assert len(shells) == diagnostic_shell_count(n)
            assert all(len(pts) == 1 for pts in shells.values())

    def test_shell_word_count(self):
        assert shell_word_count(1) == 4
        assert shell_word_count(2) == 16
        assert shell_word_count(3) == 64

    def test_cardinal_n1_matches_lean(self):
        assert embed_shell_word((EClass.E,)) == (1.0, 0.0, 0.0)
        assert embed_shell_word((EClass.C,)) == (-1.0, 0.0, 0.0)
        assert cardinal_dir(EClass.A) == (0.0, 1.0, 0.0)

    def test_lattice_n2_scale(self):
        word = (EClass.A, EClass.B)
        pt = embed_shell_word(word)
        assert pt[0] == pytest.approx(PHI_INV_SQ)
        assert pt[1] == pytest.approx(2 * PHI_INV_SQ)
        assert pt[2] == pytest.approx(0.0)

    def test_epsilon_values(self):
        assert theorematic_epsilon_for_level(1) == 1.0
        assert theorematic_epsilon_for_level(2) == pytest.approx(PHI_INV_SQ)
        assert theorematic_epsilon_for_level(3) == pytest.approx(PHI_INV_CUBE)

    def test_full_mode_has_four_pow_n(self):
        shells = shells_at_level(2, mode="full")
        assert len(shells) == 16
        sep = shell_sep(shells)
        assert math.isfinite(sep)
        assert sep == pytest.approx(PHI_INV_SQ, rel=0, abs=1e-6)

    def test_construction_protocol(self):
        c = EnergiedokuShellConstruction()
        assert c.construction_name() == "theorematic_energiedoku_cardinal_lattice"
        assert c.epsilon_rule(2) == pytest.approx(PHI_INV_SQ)
        shells = c.shells_at(1)
        assert len(shells) == 2

    def test_lex_order_words(self):
        words = enumerate_shell_words(1)
        assert [w[0].value for w in words] == ["E", "A", "B", "C"]


class TestEnergiedokuCoordinatesCsv:
    def test_default_csv_exists(self):
        assert DEFAULT_COORDINATES_CSV.is_file()

    def test_csv_loads_n1_n2_n3(self):
        table = load_coordinates_from_csv(DEFAULT_COORDINATES_CSV)
        assert set(table) == {1, 2, 3}

    def test_csv_point_counts_full(self):
        assert coordinate_count_for_level(1) == 4
        assert coordinate_count_for_level(2) == 16
        assert coordinate_count_for_level(3) == 64
        table = coordinate_table()
        assert sum(len(table[n]) for n in (1, 2, 3)) == 84

    def test_coordinates_source_is_csv_when_file_present(self):
        assert coordinates_source().startswith("csv:")

    def test_csv_columns(self):
        import csv

        with DEFAULT_COORDINATES_CSV.open(newline="", encoding="utf-8") as fh:
            reader = csv.DictReader(fh)
            assert tuple(reader.fieldnames) == CSV_FIELDNAMES

    def test_embed_matches_csv_for_sample(self):
        table = coordinate_table()
        for n in (1, 2, 3):
            for shell, (label, point) in table[n].items():
                word = tuple(EClass(c) for c in label)
                assert embed_shell_word(word) == point
                if shell >= 3:
                    break


class TestShellEmbeddingComparison:
    def test_comparison_produces_finite_diffs(self):
        report = run_shell_embedding_comparison(n_max=3)
        assert len(report.summaries) == 3
        for row in report.rows:
            if not math.isnan(row.diff_l2):
                assert math.isfinite(row.diff_l2)
        for s in report.summaries:
            assert math.isfinite(s.max_coordinate_diff)
            assert math.isfinite(s.hausdorff_proxy_diagnostic)

    def test_compare_level_n1(self):
        rows, summary = compare_level(1)
        assert len(rows) == 2
        assert summary.shell_count_canonical == 2
        assert summary.shell_count_energiedoku == 2

    def test_hausdorff_proxy_disjoint(self):
        d = hausdorff_proxy([(0.0, 0.0, 0.0)], [(3.0, 0.0, 0.0)])
        assert d == pytest.approx(3.0)

    def test_n2_energiedoku_loss_boundary(self):
        _, summary = compare_level(2)
        assert summary.loss_energiedoku_energiedoku_eps is True
        assert summary.loss_canonical_energiedoku_eps is False

    def test_export_csv(self, tmp_path):
        report = run_shell_embedding_comparison(n_max=3)
        path = export_comparison_csv(report, tmp_path / "cmp.csv")
        text = path.read_text(encoding="utf-8")
        assert "canonical_x" in text
        assert "energiedoku_x" in text
        assert text.count("\n") >= len(report.rows) + 1
