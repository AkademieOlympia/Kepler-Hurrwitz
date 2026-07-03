import array
import struct

from kepler_hurwitz.kepler_time_bridge import run_kepler_time_bridge_scenarios
from kepler_hurwitz.riemann_resonance_checker import (
    analyze_bridge_record_resonance,
    analyze_bridge_record_scale_resonance,
    analyze_riemann_interference,
    analyze_riemann_scale_interference,
    export_riemann_resonance_json,
    export_riemann_scale_resonance_json,
    known_zeros_head,
    load_riemann_zeros_from_buffer,
    log_scale_from_semi_major,
    run_riemann_resonance_from_bridge_records,
    run_riemann_scale_resonance_from_bridge_records,
)


def test_load_riemann_zeros_from_buffer_roundtrip():
    values = (14.134725, 21.02204, 25.010858)
    payload = struct.pack("<3d", *values)
    zeros = load_riemann_zeros_from_buffer(payload)
    assert len(zeros) == 3
    assert abs(zeros[0] - values[0]) < 1e-12


def test_analyze_riemann_interference_zero_delta_is_constructive():
    zeros = known_zeros_head()
    result = analyze_riemann_interference(zeros, 0.0, sample_count=len(zeros))
    assert result.interference_factor == 1.0
    assert result.variance == 0.0
    assert result.is_resonant is True


def test_analyze_bridge_record_resonance_uses_spectrum():
    records = run_kepler_time_bridge_scenarios(steps=24, perturb_at_step=10, tail_length=16)
    baseline = records[0]
    zeros = known_zeros_head()
    results = analyze_bridge_record_resonance(zeros, baseline, sample_count=len(zeros))
    assert len(results) == baseline.diagnostics.unique_delta_M_count
    assert results[0].scenario_name == "baseline_cyclic"


def test_run_riemann_resonance_from_bridge_records_exports_json(tmp_path):
    records = run_kepler_time_bridge_scenarios(steps=24, perturb_at_step=10, tail_length=16)
    zeros = array.array("d", [14.134725, 21.02204, 25.010858, 30.424876])
    results = run_riemann_resonance_from_bridge_records(
        records,
        zeros,
        sample_count=len(zeros),
    )
    export_path = export_riemann_resonance_json(results, tmp_path / "riemann_resonance.json")
    assert export_path.exists()
    assert len(results) >= 5


def test_analyze_riemann_scale_interference_uses_log_scale():
    zeros = known_zeros_head()
    x0 = log_scale_from_semi_major(1.5)
    result = analyze_riemann_scale_interference(zeros, x0, sample_count=len(zeros))
    assert result.metric == "log_scale_cosine_mean"
    assert result.x0 == x0


def test_analyze_bridge_record_scale_resonance_uses_tail_log_scales():
    records = run_kepler_time_bridge_scenarios(steps=24, perturb_at_step=10, tail_length=16)
    baseline = records[0]
    zeros = known_zeros_head()
    results = analyze_bridge_record_scale_resonance(zeros, baseline, sample_count=len(zeros))
    assert len(results) >= 1
    assert results[0].scenario_name == "baseline_cyclic"


def test_run_riemann_scale_resonance_exports_json(tmp_path):
    records = run_kepler_time_bridge_scenarios(steps=24, perturb_at_step=10, tail_length=16)
    zeros = array.array("d", [14.134725, 21.02204, 25.010858, 30.424876])
    results = run_riemann_scale_resonance_from_bridge_records(
        records,
        zeros,
        sample_count=len(zeros),
    )
    export_path = export_riemann_scale_resonance_json(
        results,
        tmp_path / "riemann_scale_resonance.json",
    )
    assert export_path.exists()
    assert len(results) >= 5
