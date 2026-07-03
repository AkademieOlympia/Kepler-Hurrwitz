import pytest

from kepler_hurwitz.discrete_time_flow import (
    default_demo_orbit,
    hurwitz_units_240,
    phi,
    simulate_physical_flow,
)
from kepler_hurwitz.kepler_eabc_atlas import (
    CHI_CYCLE_CHANNELS,
    EABCChannel,
    PHI_COORDINATE_FIBERS,
    PhiFiber,
    annotate_delta_m_with_channels,
    annotate_kepler_time_bridge_record,
    build_floquet_annotation_export,
    build_scenario_alignment_report,
    channel_alignment_summary,
    floquet_channel_table,
    floquet_step_channel,
    lift_sheet_pair_differences,
    max_lift_sheet_abs_difference,
    summarize_annotated_delta_m,
)
from kepler_hurwitz.kepler_time_bridge import build_kepler_time_bridge_record


def test_floquet_step_channel_period_four():
    for step in range(8):
        assert floquet_step_channel(step) == floquet_step_channel(step + 4)


def test_floquet_step_channel_order():
    assert [floquet_step_channel(step).value for step in range(8)] == [
        "E",
        "A",
        "C",
        "B",
        "E",
        "A",
        "C",
        "B",
    ]


def test_floquet_step_channel_matches_chi_cycle_constant():
    assert CHI_CYCLE_CHANNELS == ("E", "A", "C", "B")
    assert [floquet_step_channel(step).value for step in range(4)] == list(CHI_CYCLE_CHANNELS)


def test_floquet_channel_table_lift_sheets():
    rows = floquet_channel_table()
    assert [row["lift_sheet"] for row in rows] == [0, 0, 0, 0, 1, 1, 1, 1]
    assert [row["chi_phase"] for row in rows] == [0, 1, 2, 3, 0, 1, 2, 3]


def test_phi_coordinate_fibers_match_lean_atlas():
    assert len(PHI_COORDINATE_FIBERS) == 8
    assert PHI_COORDINATE_FIBERS[0] == PhiFiber.SCALE
    assert PHI_COORDINATE_FIBERS[7] == PhiFiber.PHASE_TIME


def test_annotate_delta_m_with_channels_shape():
    rows = annotate_delta_m_with_channels([0.1, -0.2, 0.3])
    assert len(rows) == 3
    assert rows[0]["channel"] == EABCChannel.E.value
    assert rows[1]["channel"] == EABCChannel.A.value
    assert rows[2]["channel"] == EABCChannel.C.value


def test_annotate_kepler_time_bridge_record_integration():
    result = simulate_physical_flow(
        phi(default_demo_orbit()),
        steps=16,
        operators=hurwitz_units_240()[:8],
        mode="cyclic",
        resolver_mode="soft",
        use_second_ring=True,
    )
    record = build_kepler_time_bridge_record("baseline", result, tail_length=16)
    annotations = annotate_kepler_time_bridge_record(record)
    assert len(annotations) == len(record.raw_delta_M_series)
    assert annotations[0]["channel"] == "E"


def test_build_floquet_annotation_export_metadata():
    result = simulate_physical_flow(
        phi(default_demo_orbit()),
        steps=12,
        operators=hurwitz_units_240()[:8],
        mode="cyclic",
        resolver_mode="soft",
        use_second_ring=True,
    )
    record = build_kepler_time_bridge_record("baseline", result, tail_length=12)
    export = build_floquet_annotation_export([record])
    assert export.status == "B/C annotation only"
    assert export.alignment_status == "B descriptive statistics only"
    assert export.cycle == ("E", "A", "C", "B", "E", "A", "C", "B")
    assert len(export.scenarios) == 1
    assert export.scenarios[0]["annotated_delta_M"]
    assert export.scenarios[0]["alignment_summary"]["channel_alignment_summary"]
    assert export.scenarios[0]["alignment_summary"]["status"] == "B/C alignment only"
    assert export.scenarios[0]["alignment_summary"]["max_lift_sheet_abs_difference"] is not None


def test_channel_alignment_summary_counts_and_mean():
    rows = [
        {"step": 0, "channel": "E", "delta_m": 1.0},
        {"step": 4, "channel": "E", "delta_m": 3.0},
    ]
    summary = channel_alignment_summary(rows)
    assert summary["E"]["count"] == 2
    assert summary["E"]["mean_delta_m"] == 2.0


def test_channel_alignment_summary_groups_by_channel():
    rows = annotate_delta_m_with_channels([1.0, -2.0, 3.0, -4.0, 1.5, -2.5, 3.5, -4.5])
    summary = channel_alignment_summary(rows)
    assert set(summary) == {"A", "B", "C", "E"}
    assert summary["E"]["count"] == 2
    assert summary["E"]["mean_delta_m"] == 1.25
    assert summary["A"]["sign_pattern"]["signs"] == "--"


def test_lift_sheet_pair_differences_matches_phases():
    rows = annotate_delta_m_with_channels([1.0, 2.0, 3.0, 4.0, 1.1, 2.2, 3.3, 4.4])
    pairs = lift_sheet_pair_differences(rows)
    assert len(pairs) == 4
    assert [pair["phase"] for pair in pairs] == [0, 1, 2, 3]
    assert pairs[0]["channel"] == "E"
    assert pairs[0]["abs_difference"] == pytest.approx(0.1)


def test_build_scenario_alignment_report_includes_sheet_metrics():
    rows = annotate_delta_m_with_channels([1.0, 2.0, 3.0, 4.0, 2.0, 4.0, 6.0, 8.0])
    report = build_scenario_alignment_report(rows)
    assert report["max_lift_sheet_abs_difference"] == 4.0


def test_channel_alignment_summary_std_zero_for_single_value():
    rows = [{"step": 0, "delta_m": 5.0, "channel": "E"}]
    summary = channel_alignment_summary(rows)
    assert summary["E"]["count"] == 1
    assert summary["E"]["mean_delta_m"] == 5.0
    assert summary["E"]["std_delta_m"] == 0.0


def test_lift_sheet_pair_differences_skips_missing_pairs():
    rows = [
        {"step": 0, "channel": "E", "delta_m": 1.0},
        {"step": 1, "channel": "A", "delta_m": 2.0},
        {"step": 5, "channel": "A", "delta_m": 2.5},
    ]
    pairs = lift_sheet_pair_differences(rows)
    assert len(pairs) == 1
    assert pairs[0]["phase"] == 1


def test_max_lift_sheet_abs_difference_none_without_pairs():
    rows = [{"step": 0, "channel": "E", "delta_m": 1.0}]
    assert max_lift_sheet_abs_difference(rows) is None


def test_max_lift_sheet_abs_difference_edge_cases():
    assert max_lift_sheet_abs_difference([]) is None
    partial = annotate_delta_m_with_channels([1.0, 2.0, 3.0, 4.0, 1.1])
    assert max_lift_sheet_abs_difference(partial) == pytest.approx(0.1)
    full = annotate_delta_m_with_channels([1.0, 2.0, 3.0, 4.0, 2.0, 4.0, 6.0, 8.0])
    assert max_lift_sheet_abs_difference(full) == 4.0


def test_summarize_annotated_delta_m_governance_fields():
    rows = annotate_delta_m_with_channels([1.0, 2.0, 3.0, 4.0, 1.1, 2.2, 3.3, 4.4])
    summary = summarize_annotated_delta_m(rows)
    assert summary["status"] == "B/C alignment only"
    assert "not proven" in summary["not_claimed"]
    assert summary["channel_alignment_summary"]["E"]["count"] == 2
    assert len(summary["lift_sheet_pair_differences"]) == 4
    assert summary["max_lift_sheet_abs_difference"] == pytest.approx(0.4)
