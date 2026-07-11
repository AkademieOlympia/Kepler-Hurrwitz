# Sage mirror for E-093 Monte Carlo P_gap layer [C]
# Lightweight wrapper: delegates to Python module when available.

import sys
from pathlib import Path

ROOT = Path.cwd()
if not (ROOT / "src" / "kepler_hurwitz").is_dir():
    ROOT = Path(__file__).resolve().parents[2]

sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.black_hole_legendre_gwtc import (  # noqa: E402
    calculate_pgap_monte_carlo,
    compute_pgap_table,
    generate_split_normal_samples,
    get_forbidden_mass_integers,
    load_gwtc_catalog,
    permutation_test_mc,
)

FIXTURE = ROOT / "data" / "black_hole" / "gwosc_fixture.csv"

if FIXTURE.is_file():
    events = load_gwtc_catalog(FIXTURE)
else:
    from kepler_hurwitz.black_hole_legendre_gwtc import mock_gwtc5_events

    events = mock_gwtc5_events(n_events=50, seed=42)

forbidden = get_forbidden_mass_integers(max_norm=300)
p_gaps = compute_pgap_table(events, forbidden, kappa=1.0, tau=0.5, n_samples=500, seed=7)
result = permutation_test_mc(
    events,
    forbidden,
    kappa=1.0,
    tau=0.5,
    iterations=200,
    n_mc_samples=500,
    seed=7,
)

print("[C] Monte Carlo P_gap demo (E-093)")
print("  events:", len(events))
print("  mean P_gap:", float(sum(p_gaps) / len(p_gaps)))
print("  permutation MC p-value:", float(result.p_value))
print("  obs_1g_expected_hits:", float(result.obs_1g_expected_hits))
