from kepler_hurwitz.kepler_time_bridge import run_kepler_time_bridge_scenarios
from kepler_hurwitz.time_bridge_plots import export_spectral_histogram


def test_export_spectral_histogram_writes_dat_files(tmp_path):
    records = run_kepler_time_bridge_scenarios(steps=24, perturb_at_step=10, tail_length=16)
    paths = export_spectral_histogram(records, tmp_path)

    assert len(paths) == 5
    for path in paths:
        assert path.exists()
        text = path.read_text(encoding="utf-8")
        assert text.startswith("# Delta_M_rad")
        assert "\t" in text
