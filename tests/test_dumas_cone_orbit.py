"""Numerical verification of Dumas Cone–Orbit hypotheses H1–H11.

Prüfmodule (see docs/theory/dumas_cone_orbit_model.md §17):
  A — Strukturkonsistenz (H1–H11): regression, always green
  B — Rotorphase vs. Lücken Δ_i (H12): open
  C — Umfeld-Entropie S_L(p) (H14/H15): open
  D — ABCE/CEAB-Bias (H13): open
  E — Gewichtungsorbit as feature (H14): open
"""

from __future__ import annotations

from math import isclose, log

import pytest

from kepler_hurwitz.dumas_cone_orbit import (
    EXPECTED_GAPS,
    HOSTS,
    ROTOR_GAP_CYCLE,
    channel_from_mod12,
    d_artagnan_channel_distribution,
    generate_twin_pairs,
    host_component,
    host_for_quadruplet_index,
    host_triple,
    l2_from_uniform,
    musketeer_gaps,
    natural_fill_slots,
    product_kepler,
    push_weight,
    scan_dumas_orbit_hypotheses,
    twin_channel_signature,
    verify_dumas_orbit,
    verify_kepler_circle,
    verify_natural_fill,
    verify_rotor_gap_sequence,
    verify_weight_orbit_entropy,
    weight_entropy,
)
from kepler_hurwitz.primvierling import generate_prime_quadruplets

CLASSIC = (11, 13, 17, 19)
FAST_STOP = 10_000
# Full scan: 166 canonical quadruplets with p <= 1_000_000
FULL_STOP = 1_000_000


@pytest.fixture(scope="module")
def fast_quadruplets() -> list[tuple[int, int, int, int]]:
    return generate_prime_quadruplets(2, FAST_STOP)


@pytest.fixture(scope="module")
def full_quadruplets() -> list[tuple[int, int, int, int]]:
    return generate_prime_quadruplets(2, FULL_STOP)


# --- Prüfmodul A: Strukturkonsistenz (H1–H11, regression) ---


@pytest.mark.regression
class TestDumasOrbitCore:
    def test_verify_dumas_orbit_classic(self):
        assert verify_dumas_orbit([CLASSIC]) == []

    def test_verify_dumas_orbit_fast_range(self, fast_quadruplets):
        assert verify_dumas_orbit(fast_quadruplets) == []

    @pytest.mark.slow
    def test_verify_dumas_orbit_full_1e6(self, full_quadruplets):
        assert len(full_quadruplets) == 166
        assert verify_dumas_orbit(full_quadruplets) == []


@pytest.mark.regression
class TestNaturalFillH2:
    def test_twelve_slots_classic(self):
        slots = natural_fill_slots(CLASSIC)
        assert len(slots) == 12

    def test_each_prime_three_times(self, fast_quadruplets):
        assert verify_natural_fill(fast_quadruplets) == []


@pytest.mark.regression
class TestGapFingerprintsH3:
    @pytest.mark.parametrize(
        ("host", "expected"),
        [
            ("E", (2, 4)),
            ("A", (4, 2)),
            ("B", (6, 2)),
            ("C", (2, 6)),
        ],
    )
    def test_host_gap_fingerprint_classic(self, host: str, expected: tuple[int, int]):
        assert musketeer_gaps(host_triple(host, CLASSIC)) == expected
        assert EXPECTED_GAPS[host] == expected

    def test_all_hosts_on_fast_range(self, fast_quadruplets):
        for v in fast_quadruplets:
            for host in HOSTS:
                assert musketeer_gaps(host_triple(host, v)) == EXPECTED_GAPS[host]


@pytest.mark.regression
class TestRotorGapSequenceH5:
    def test_rotor_cycle_prefix(self):
        quadruplets = generate_prime_quadruplets(2, 200)
        prefix = tuple(
            musketeer_gaps(host_triple(host_for_quadruplet_index(i + 1), quadruplets[i]))
            for i in range(4)
        )
        assert prefix == ROTOR_GAP_CYCLE

    def test_rotor_on_fast_range(self, fast_quadruplets):
        assert verify_rotor_gap_sequence(fast_quadruplets) == []

    @pytest.mark.slow
    def test_rotor_counts_166(self, full_quadruplets):
        counts = {h: 0 for h in HOSTS}
        for index in range(1, len(full_quadruplets) + 1):
            counts[host_for_quadruplet_index(index)] += 1
        assert counts == {"E": 42, "A": 42, "B": 41, "C": 41}


@pytest.mark.regression
class TestKeplerCircleH6H7:
    def test_product_signature_balanced(self):
        from kepler_hurwitz.diagnostics import primvierling_product
        from kepler_hurwitz.signatures import signature_from_nat

        sig = signature_from_nat(primvierling_product(CLASSIC))
        assert sig.as_tuple() == (1, 1, 1, 1)

    def test_kepler_invariants_classic(self):
        a, e, radius = product_kepler(CLASSIC)
        assert isclose(a, 1.0)
        assert isclose(e, 0.0)
        assert isclose(radius, 1.0)

    def test_kepler_on_fast_range(self, fast_quadruplets):
        assert verify_kepler_circle(fast_quadruplets) == []


@pytest.mark.regression
class TestWeightOrbitEntropyH8H9:
    @pytest.mark.parametrize("omega", [0.0, 0.25, 0.5, 0.75, 1.0])
    def test_entropy_constant_across_hosts(self, fast_quadruplets, omega: float):
        stats = verify_weight_orbit_entropy(fast_quadruplets, omega)
        assert stats is not None

    def test_omega_quarter_is_uniform_fixpoint(self):
        vec = push_weight(CLASSIC, "E", 0.25)
        assert vec == (0.25, 0.25, 0.25, 0.25)
        assert weight_entropy(vec) == pytest.approx(log(4))
        assert l2_from_uniform(vec) == pytest.approx(0.0)

    def test_omega_half_non_uniform_orbit(self):
        vectors = {push_weight(CLASSIC, host, 0.5) for host in HOSTS}
        assert len(vectors) == 4
        for vec in vectors:
            assert weight_entropy(vec) == pytest.approx(1.242453, rel=1e-5)
            assert l2_from_uniform(vec) == pytest.approx(0.288675, rel=1e-5)


@pytest.mark.regression
class TestHostNotChannel:
    def test_classic_witness_host_differs_from_channel(self):
        assert channel_from_mod12(host_component("E", CLASSIC)) == "B"
        assert channel_from_mod12(host_component("A", CLASSIC)) == "C"

    @pytest.mark.slow
    def test_d_artagnan_channel_84_82_split(self, full_quadruplets):
        dist = d_artagnan_channel_distribution(full_quadruplets)
        assert dist["E"] == {"E": 84, "B": 82}
        assert dist["A"] == {"A": 84, "C": 82}
        assert dist["B"] == {"B": 84, "E": 82}
        assert dist["C"] == {"C": 84, "A": 82}


@pytest.mark.regression
class TestTwinDegenerateH10:
    def test_twin_signatures_only_delta1_edges(self):
        twins = [pair for pair in generate_twin_pairs(5, 10_000) if pair != (3, 5)]
        signatures = {twin_channel_signature(p, q) for p, q in twins}
        assert signatures <= {(1, 0, 0, 1), (0, 1, 1, 0)}

    @pytest.mark.slow
    def test_twin_counts_up_to_1e6(self):
        twins = [pair for pair in generate_twin_pairs(5, FULL_STOP) if pair != (3, 5)]
        ce_count = sum(1 for p, q in twins if twin_channel_signature(p, q) == (1, 0, 0, 1))
        ab_count = sum(1 for p, q in twins if twin_channel_signature(p, q) == (0, 1, 1, 0))
        assert len(twins) == 8168
        assert ce_count == 4122
        assert ab_count == 4046


@pytest.mark.regression
class TestScanSummary:
    def test_fast_scan_all_zero_failures(self, fast_quadruplets):
        summary = scan_dumas_orbit_hypotheses(fast_quadruplets, twin_stop=FAST_STOP)
        assert summary.h1_h4_failures == 0
        assert summary.h2_failures == 0
        assert summary.h5_failures == 0
        assert summary.h7_failures == 0


# --- Prüfmodule B–E: statistical falsification (open, [B0]) ---


@pytest.mark.skip(reason="Prüfmodul B (H12): Rotorphase vs. Δ_i — nullmodell control pending")
class TestPruefmodulBRotorphaseVsLuecken:
    """Rotorphase i mod 4 vs. Primvierlingslücken Δ_i.

    See docs/theory/dumas_cone_orbit_model.md §17.4, H12.
    H0: phase does not explain Δ_i beyond permutation null.
    """


@pytest.mark.skip(reason="Prüfmodul C (H14/H15): Umfeld-Entropie S_L(p) — comparison groups pending")
class TestPruefmodulCUmfeldEntropie:
    """Channel entropy S_L(p) in window before primvierling start p.

    See docs/theory/dumas_cone_orbit_model.md §17.5, H14/H15.
    H0: S_L indistinguishable from nullmodell quadruplets.
    """


@pytest.mark.skip(reason="Prüfmodul D (H13): ABCE/CEAB bias — scale-robust test pending")
class TestPruefmodulDAbceCeabBias:
    """Orientation ratio Pr(ABCE)/Pr(CEAB) over canonical primvierlinge.

    See docs/theory/dumas_cone_orbit_model.md §17.6, H13.
    Upgrade to [B+] only if asymmetry is scale-robust.
    """


@pytest.mark.skip(reason="Prüfmodul E (H14): weight orbit as feature — correlation test pending")
class TestPruefmodulEGewichtungsorbitFeature:
    """Weight orbit w^(h)(omega) as diagnostic feature for next gap Δ_i.

    See docs/theory/dumas_cone_orbit_model.md §17.7, H14.
    Not entropy constancy (H8, Modul A) — predictive correlation vs. null.
    """
