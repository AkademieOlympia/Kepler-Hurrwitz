import csv
from pathlib import Path

import pytest

from kepler_hurwitz.diagnostics_export import (
    ATLAS_EXPORT_COLUMNS,
    CSV_FIELDNAMES,
    GOVERNANCE_NOTE,
    assert_atlas_export_columns_match_primary_api,
    atlas_export_records,
    atlas_row_from_collatz,
    atlas_row_from_eabc,
    atlas_row_from_primvierling,
    build_default_atlas_export_rows,
    export_atlas_parameters_csv,
    first_positive_net_descent_t_loc,
)
from kepler_hurwitz.diagnostics import ATLAS_PRIMARY_FUNCTIONS


class TestDiagnosticsExport:
    def test_atlas_columns_match_primary_api(self):
        assert_atlas_export_columns_match_primary_api()
        assert set(ATLAS_EXPORT_COLUMNS) == set(ATLAS_PRIMARY_FUNCTIONS)

    def test_primvierling_row_example(self):
        row = atlas_row_from_primvierling((5, 7, 11, 13))
        assert row.source_kind == "primvierling"
        assert row.norm_signature_defect == 2
        assert row.projection_loss == 2
        assert row.net_descent_margin is None
        assert row.chirality_norm is None

    def test_eabc_row_example(self):
        row = atlas_row_from_eabc(6)
        assert row.source_kind == "eabc"
        assert row.projection_loss == 2
        assert row.norm_signature_defect is None
        assert row.net_descent_margin is None

    def test_collatz_row_mod4_three_guard(self):
        with pytest.raises(ValueError, match="n % 4 == 3"):
            atlas_row_from_collatz(4)

    def test_collatz_row_witness_diagnostics(self):
        row = atlas_row_from_collatz(3, t_loc=4)
        assert row.source_kind == "collatz"
        assert row.net_descent_margin == 1
        assert row.bad_run_cost == 2
        assert row.shrink_efficiency == pytest.approx(1 / 3)
        assert row.t_loc == 4

    def test_first_positive_net_descent_t_loc(self):
        assert first_positive_net_descent_t_loc(3) == 4
        assert first_positive_net_descent_t_loc(27) == 94

    def test_rejects_invalid_naturals(self):
        with pytest.raises(ValueError):
            atlas_row_from_eabc(0)
        with pytest.raises(ValueError):
            first_positive_net_descent_t_loc(0)

    def test_export_csv_headers_and_rows(self, tmp_path: Path):
        rows = build_default_atlas_export_rows()
        output = tmp_path / "atlas.csv"
        export_atlas_parameters_csv(rows, output)
        with output.open(encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            assert reader.fieldnames == list(CSV_FIELDNAMES)
            records = list(reader)
        assert len(records) == len(rows)
        assert records[0]["source_kind"] == "primvierling"
        assert "norm_signature_defect" in records[0]
        assert records[0]["chirality_norm"] == ""

    def test_export_rejects_empty_rows(self, tmp_path: Path):
        with pytest.raises(ValueError, match="non-empty"):
            export_atlas_parameters_csv([], tmp_path / "empty.csv")

    def test_governance_note_present(self):
        assert "Identifikation behaupten nein" in GOVERNANCE_NOTE

    def test_atlas_export_records_roundtrip(self):
        row = atlas_row_from_primvierling((5, 7, 11, 13))
        record = atlas_export_records([row])[0]
        assert record["norm_signature_defect"] == 2
        assert record["net_descent_margin"] == ""
