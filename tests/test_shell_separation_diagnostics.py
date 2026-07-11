import math

import pytest

from kepler_hurwitz.shell_construction import (
    CANONICAL_EPSILON_RULE_NAME,
    CANONICAL_METRIC_NAME,
    CANONICAL_NOT_IMPLEMENTED_MESSAGE,
    PHI_INV_SQ,
    THEOREMATIC_EPSILON_RULE_NAME,
    THEOREMATIC_MN_SEP_EPSILON_RULE_NAME,
    CanonicalShellConstruction,
    CombinedShellConstruction,
    ShellConstructionProtocol,
    SyntheticShellConstruction,
    ToyShellConstruction,
    get_construction,
    get_epsilon_rule,
    provisional_epsilon_n,
    shell_series_from_construction,
    theorematic_epsilon_n,
    theorematic_mn_sep_epsilon_n,
)
from kepler_hurwitz.shell_detector_controls import (
    evaluate_control,
    export_detector_controls_csv,
    generate_degenerate_shells,
    generate_overlapping_shells,
    generate_random_shells,
    generate_separated_shells,
    run_detector_controls,
)
from kepler_hurwitz.shell_separation_diagnostics import (
    SHELL_PRIME_MATCH_GATE_ACTIVE,
    SHELL_PRIME_MATCH_PRIMARY_TRACK,
    TRACK_B_ENERGIEDOKU_FULL_EXPLORATORY_N0,
    TRACK_B_ENERGIEDOKU_FULL_GATE_ELIGIBLE,
    box_dimension_estimate,
    box_dimension_from_counts,
    build_synthetic_shell_series,
    build_toy_shell_series_n_le_3,
    embedding_quality,
    first_loss,
    first_loss_n,
    overlap,
    pairwise_min_distance,
    run_shell_separation_diagnostics,
    sep,
    shell_min_separation,
    shell_overlap,
    shell_overlap_metric,
    shell_sep,
    shell_separation_loss,
)


class TestPairwiseMinDistance:
    def test_disjoint_sets(self):
        d = pairwise_min_distance([(0.0, 0.0)], [(3.0, 4.0)])
        assert d == pytest.approx(5.0)

    def test_rejects_empty(self):
        with pytest.raises(ValueError):
            pairwise_min_distance([], [(1.0, 0.0)])


class TestShellSep:
    def test_two_shells(self):
        shells = {0: ((0.0, 0.0),), 1: ((3.0, 0.0),)}
        assert shell_sep(shells) == pytest.approx(3.0)


class TestShellOverlapCount:
    def test_counts_close_pairs(self):
        shells = {0: ((0.0, 0.0),), 1: ((0.5, 0.0),), 2: ((5.0, 0.0),)}
        assert shell_overlap(shells, epsilon=1.0) == 1

    def test_overlap_at_level(self):
        shells = {0: ((0.0, 0.0),), 1: ((0.5, 0.0),)}
        assert overlap(2, shells, 1.0) == 1


class TestEmbeddingQuality:
    def test_ratio(self):
        assert embedding_quality(2.0, 1.0) == pytest.approx(2.0)

    def test_none_for_zero_epsilon(self):
        assert embedding_quality(1.0, 0.0) is None


class TestFirstLossRows:
    def test_from_rows(self):
        rows = [
            {"n": 1, "sep": 3.0, "epsilon": 1.0},
            {"n": 2, "sep": 0.4, "epsilon": 0.5},
        ]
        assert first_loss(rows) == 2


class TestBoxDimensionFromCounts:
    def test_from_precomputed(self):
        eps = (1.0, 0.5, 0.25)
        counts = (10, 40, 160)
        dim = box_dimension_from_counts(eps, counts)
        assert dim is not None
        assert dim == pytest.approx(2.0, abs=0.1)


class TestToyShellSeries:
    def test_only_n_le_3(self):
        series = build_toy_shell_series_n_le_3(dim=3)
        assert set(series) == {1, 2, 3}
        assert all(entry["source"] == "toy_n_le_3" for entry in series.values())

    def test_monotone_sep_for_toy(self):
        series = build_toy_shell_series_n_le_3(dim=2)
        seps = [series[n]["sep"] for n in (1, 2, 3)]
        assert seps[0] >= seps[1] >= seps[2]


class TestShellMinSeparation:
    def test_min_of_distances(self):
        assert shell_min_separation((3.0, 1.5, 2.0)) == 1.5

    def test_rejects_empty(self):
        with pytest.raises(ValueError):
            shell_min_separation(())

    def test_rejects_negative(self):
        with pytest.raises(ValueError):
            shell_min_separation((1.0, -0.1))


class TestShellOverlapMetric:
    def test_no_overlap_when_far_apart(self):
        overlap = shell_overlap_metric(
            ((0.0, 0.0), (10.0, 0.0)),
            (1.0, 1.0),
        )
        assert overlap == 0.0

    def test_full_overlap_when_coincident(self):
        overlap = shell_overlap_metric(
            ((0.0, 0.0), (0.0, 0.0)),
            (1.0, 1.0),
        )
        assert overlap == pytest.approx(1.0)


class TestSep:
    def test_from_precomputed_distances(self):
        data = {1: 2.5, 2: 1.0}
        assert sep(2, data) == 1.0

    def test_from_centroids_2d(self):
        data = {
            1: (
                (0.0, 0.0),
                (3.0, 4.0),
            )
        }
        assert sep(1, data) == pytest.approx(5.0)


class TestShellSeparationLoss:
    def test_loss_when_below_threshold(self):
        assert shell_separation_loss(0.5, 1.0) is True

    def test_no_loss_when_above_threshold(self):
        assert shell_separation_loss(1.5, 1.0) is False


class TestFirstLossN:
    def test_finds_first_loss(self):
        series = {1: 3.0, 2: 2.0, 3: 1.2, 4: 0.3}
        n0 = first_loss_n(series, lambda n: 1.0)
        assert n0 == 4

    def test_none_when_no_loss(self):
        series = {1: 5.0, 2: 4.0}
        assert first_loss_n(series, lambda n: 0.1) is None


class TestBoxDimensionEstimate:
    def test_line_like_set_in_2d(self):
        points = tuple((i * 0.01, 0.0) for i in range(1001))
        dim = box_dimension_estimate(points, (1.0, 0.5, 0.25, 0.125, 0.0625))
        assert dim is not None
        assert dim == pytest.approx(1.0, abs=0.35)

    def test_square_like_set_in_2d(self):
        points = tuple(
            (x * 0.01, y * 0.01)
            for x in range(50)
            for y in range(50)
        )
        dim = box_dimension_estimate(points, (0.5, 0.25, 0.125, 0.0625, 0.03125))
        assert dim is not None
        assert dim == pytest.approx(2.0, abs=0.15)


class TestSyntheticShellSeries:
    def test_separation_decreases_at_known_n(self):
        series = build_synthetic_shell_series(
            dim=2,
            n_max=5,
            first_loss_level=4,
            base_separation=2.0,
        )
        seps = [series[n]["sep"] for n in range(1, 6)]
        assert seps[0] > seps[1] >= seps[2]
        assert seps[2] > seps[3]  # Sprung beim first_loss_level
        assert seps[3] <= 1.0 / 4  # Verlust unter epsilon_4

    def test_first_loss_at_expected_level(self):
        series = build_synthetic_shell_series(
            dim=3,
            n_max=5,
            first_loss_level=4,
        )
        report = run_shell_separation_diagnostics(series, epsilon_fn=lambda n: 1.0 / n)
        assert report.first_loss_n == 4
        assert report.loss_flags[3] is False
        assert report.loss_flags[4] is True

    def test_3d_centroids_have_three_components(self):
        series = build_synthetic_shell_series(dim=3, n_max=3, first_loss_level=3)
        for entry in series.values():
            assert len(entry["centroids"][0]) == 3


class TestRunDiagnostics:
    def test_governance_note_present(self):
        series = build_synthetic_shell_series(n_max=3, first_loss_level=3)
        report = run_shell_separation_diagnostics(series, data_source="synthetic")
        assert "MetricSeparationLossExists" in report.governance_note
        assert report.overlap_count_series


class TestDegenerateCases:
    def test_single_shell_overlap_zero(self):
        assert shell_overlap({0: ((0.0, 0.0),)}, epsilon=1.0) == 0

    def test_no_loss_monotone_series(self):
        series = {1: 5.0, 2: 4.0, 3: 3.0}
        assert first_loss_n(series, lambda n: 0.1) is None


class TestShellConstructionProtocol:
    @pytest.mark.parametrize(
        "construction",
        [
            ToyShellConstruction(dim=3),
            SyntheticShellConstruction(n_max=5, first_loss_level=4),
            CombinedShellConstruction(
                toy=ToyShellConstruction(dim=3),
                synthetic=SyntheticShellConstruction(n_max=5, first_loss_level=4),
            ),
        ],
    )
    def test_protocol_compliance(self, construction):
        assert isinstance(construction, ShellConstructionProtocol)
        assert construction.metric_name() == CANONICAL_METRIC_NAME
        assert construction.epsilon_rule_name() == CANONICAL_EPSILON_RULE_NAME

    def test_toy_shells_at_n_le_3(self):
        toy = ToyShellConstruction(dim=3)
        shells = toy.shells_at(2)
        assert len(shells) >= 2
        assert all(len(pts) == 1 for pts in shells.values())

    def test_toy_rejects_n_gt_3(self):
        with pytest.raises(KeyError):
            ToyShellConstruction(dim=3).shells_at(4)

    def test_synthetic_shells_at_deterministic(self):
        syn = SyntheticShellConstruction(n_max=4, first_loss_level=3)
        a = syn.shells_at(2)
        b = syn.shells_at(2)
        assert a == b

    def test_combined_merge_synthetic_wins_on_overlap(self):
        combined = get_construction("combined", n_max=3, first_loss_level=3)
        series = shell_series_from_construction(combined, (1, 2, 3))
        syn_only = shell_series_from_construction(
            SyntheticShellConstruction(n_max=3, first_loss_level=3),
            (1, 2, 3),
        )
        for n in (1, 2, 3):
            assert series[n]["sep"] == syn_only[n]["sep"]

    def test_canonical_shells_at_n_le_3(self):
        canonical = CanonicalShellConstruction()
        for n in (1, 2, 3):
            shells = canonical.shells_at(n)
            assert len(shells) == n + 1
            assert all(len(pts) == 1 and len(pts[0]) == 3 for pts in shells.values())

    def test_canonical_construction_name(self):
        canonical = CanonicalShellConstruction()
        assert canonical.construction_name() == "canonical_from_qec_bridge"

    def test_canonical_raises_beyond_max(self):
        from kepler_hurwitz.canonical_shell_vertices import max_renorm_level

        canonical = CanonicalShellConstruction()
        with pytest.raises(NotImplementedError):
            canonical.shells_at(max_renorm_level() + 1)

    def test_canonical_metric_and_epsilon_rule_defined(self):
        canonical = CanonicalShellConstruction()
        assert canonical.metric_name() == CANONICAL_METRIC_NAME
        assert canonical.epsilon_rule(4) == pytest.approx(0.25)


class TestCanonicalConstructionDiagnostics:
    def test_separation_loss_computable(self):
        construction = get_construction("canonical", n_max=5)
        series = shell_series_from_construction(construction, (1, 2, 3, 4, 5))
        report = run_shell_separation_diagnostics(
            series,
            epsilon_fn=construction.epsilon_rule,
            data_source=construction.construction_name(),
            metric_name=construction.metric_name(),
            epsilon_rule_name=construction.epsilon_rule_name(),
        )
        assert report.metric_name == CANONICAL_METRIC_NAME
        assert report.epsilon_rule_name == CANONICAL_EPSILON_RULE_NAME
        assert all(n in report.loss_flags for n in (1, 2, 3, 4, 5))

    def test_degenerate_all_coincident_triggers_loss(self):
        """Degenerierter Fall: identische Centroide -> sep=0 -> Verlust."""
        degenerate = {
            1: {
                "centroids": ((0.0, 0.0, 0.0), (0.0, 0.0, 0.0)),
                "radii": (0.4, 0.4),
                "sep": 0.0,
                "construction": "test_degenerate",
                "metric_name": CANONICAL_METRIC_NAME,
                "epsilon_rule_name": CANONICAL_EPSILON_RULE_NAME,
            }
        }
        report = run_shell_separation_diagnostics(
            degenerate,
            data_source="test_degenerate",
        )
        assert report.loss_flags[1] is True
        assert report.first_loss_n == 1

    def test_canonical_prefix_compatibility(self):
        """Gemeinsame Indizes behalten R³-Koordinaten unter n -> n+1."""
        construction = CanonicalShellConstruction()
        s2 = construction.shells_at(2)
        s3 = construction.shells_at(3)
        for idx in s2:
            assert s2[idx] == s3[idx]


class TestProvisionalEpsilonRule:
    def test_inverse_n_deterministic(self):
        assert provisional_epsilon_n(1) == 1.0
        assert provisional_epsilon_n(4) == pytest.approx(0.25)
        assert provisional_epsilon_n(4) == provisional_epsilon_n(4)

    def test_rejects_n_lt_1(self):
        with pytest.raises(ValueError):
            provisional_epsilon_n(0)


class TestTheorematicEpsilonRule:
    def test_n123_exact_values(self):
        assert theorematic_epsilon_n(1) == 1.0
        assert theorematic_epsilon_n(2) == pytest.approx((3.0 - math.sqrt(5.0)) / 2.0)
        assert theorematic_epsilon_n(3) == pytest.approx(
            ((1.0 + math.sqrt(5.0)) / 2.0) ** -3
        )

    def test_n_gt_3_fallback_is_phi_inv_cube(self):
        assert theorematic_epsilon_n(4) == pytest.approx(
            ((1.0 + math.sqrt(5.0)) / 2.0) ** -3
        )
        assert theorematic_epsilon_n(17) == theorematic_epsilon_n(4)

    def test_n_gt_3_strict_raises(self):
        with pytest.raises(NotImplementedError, match=r"\[C\]"):
            theorematic_epsilon_n(4, allow_n_gt_3_fallback=False)

    def test_rejects_n_lt_1(self):
        with pytest.raises(ValueError):
            theorematic_epsilon_n(0)

    def test_get_epsilon_rule_resolves_names(self):
        fn, name = get_epsilon_rule("theorematic_energiedoku_v1")
        assert name == THEOREMATIC_EPSILON_RULE_NAME
        assert fn(2) == pytest.approx(PHI_INV_SQ)

        fn2, name2 = get_epsilon_rule("provisional_inverse_n")
        assert name2 == CANONICAL_EPSILON_RULE_NAME
        assert fn2(2) == pytest.approx(0.5)

    def test_get_epsilon_rule_rejects_unknown(self):
        with pytest.raises(ValueError):
            get_epsilon_rule("unknown_rule")


class TestTheorematicMnSepEpsilonRule:
    def test_inverse_four_power(self):
        assert theorematic_mn_sep_epsilon_n(1) == pytest.approx(0.25)
        assert theorematic_mn_sep_epsilon_n(2) == pytest.approx(0.0625)
        assert theorematic_mn_sep_epsilon_n(3) == pytest.approx(0.015625)
        assert theorematic_mn_sep_epsilon_n(4) == pytest.approx(4.0 ** -4)

    def test_matches_one_over_mn_sep(self):
        for n in (1, 2, 3, 5, 17):
            mn_sep = 4.0**n
            assert theorematic_mn_sep_epsilon_n(n) == pytest.approx(1.0 / mn_sep)

    def test_rejects_n_lt_1(self):
        with pytest.raises(ValueError):
            theorematic_mn_sep_epsilon_n(0)

    def test_get_epsilon_rule_resolves_name(self):
        fn, name = get_epsilon_rule("theorematic_mn_sep_v1")
        assert name == THEOREMATIC_MN_SEP_EPSILON_RULE_NAME
        assert fn(3) == pytest.approx(4.0 ** -3)

    def test_stricter_than_provisional_for_n_ge_2(self):
        for n in range(2, 8):
            assert theorematic_mn_sep_epsilon_n(n) < provisional_epsilon_n(n)


class TestTheorematicCanonicalDiagnostics:
    def test_canonical_no_loss_with_theorematic_rule(self):
        construction = get_construction("canonical", n_max=17)
        series = shell_series_from_construction(construction, tuple(range(1, 18)))
        epsilon_fn, rule_name = get_epsilon_rule("theorematic_energiedoku_v1")
        report = run_shell_separation_diagnostics(
            series,
            epsilon_fn=epsilon_fn,
            data_source=construction.construction_name(),
            metric_name=construction.metric_name(),
            epsilon_rule_name=rule_name,
        )
        assert report.epsilon_rule_name == THEOREMATIC_EPSILON_RULE_NAME
        assert report.first_loss_n is None
        assert all(not flag for flag in report.loss_flags.values())

    def test_canonical_no_loss_with_mn_sep_rule(self):
        construction = get_construction("canonical", n_max=17)
        series = shell_series_from_construction(construction, tuple(range(1, 18)))
        epsilon_fn, rule_name = get_epsilon_rule("theorematic_mn_sep_v1")
        report = run_shell_separation_diagnostics(
            series,
            epsilon_fn=epsilon_fn,
            data_source=construction.construction_name(),
            metric_name=construction.metric_name(),
            epsilon_rule_name=rule_name,
        )
        assert report.epsilon_rule_name == THEOREMATIC_MN_SEP_EPSILON_RULE_NAME
        assert report.first_loss_n is None
        assert all(not flag for flag in report.loss_flags.values())


class TestConstructionDiagnosticsIntegration:
    def test_csv_fields_in_report(self):
        construction = get_construction("synthetic", n_max=3, first_loss_level=3)
        series = shell_series_from_construction(construction, (1, 2, 3))
        report = run_shell_separation_diagnostics(
            series,
            epsilon_fn=construction.epsilon_rule,
            data_source=construction.construction_name(),
            metric_name=construction.metric_name(),
            epsilon_rule_name=construction.epsilon_rule_name(),
        )
        assert report.metric_name == CANONICAL_METRIC_NAME
        assert report.epsilon_rule_name == CANONICAL_EPSILON_RULE_NAME
        assert report.first_loss_n == 3


class TestDetectorValidationControls:
    def test_positive_control_triggers_loss(self):
        case = generate_overlapping_shells()
        row = evaluate_control(case)
        assert row["shell_separation_loss"] is True
        assert row["overlap_count"] > 0
        assert row["passed"] is True

    def test_negative_control_no_loss(self):
        case = generate_separated_shells()
        row = evaluate_control(case)
        assert row["shell_separation_loss"] is False
        assert row["overlap_count"] == 0
        assert row["passed"] is True

    def test_degenerate_sep_zero_loss(self):
        case = generate_degenerate_shells()
        row = evaluate_control(case)
        assert row["sep"] == 0.0
        assert row["shell_separation_loss"] is True
        assert row["passed"] is True

    def test_random_reproducible_at_fixed_seed(self):
        a = evaluate_control(generate_random_shells(42))
        b = evaluate_control(generate_random_shells(42))
        assert a["sep"] == b["sep"]
        assert a["overlap_count"] == b["overlap_count"]
        assert a["shell_separation_loss"] == b["shell_separation_loss"]

    def test_random_differs_across_seeds(self):
        rows = [
            evaluate_control(generate_random_shells(seed))
            for seed in (0, 1, 2, 3, 4)
        ]
        seps = {row["sep"] for row in rows}
        assert len(seps) > 1

    def test_run_detector_controls_suite(self):
        rows = run_detector_controls(random_seeds=(0, 1))
        names = {r["control_name"] for r in rows}
        assert "positive_overlapping" in names
        assert "negative_separated" in names
        assert "degenerate_collapsed" in names
        assert "random_null" in names
        deterministic = [r for r in rows if r["control_name"] != "random_null"]
        assert all(r["passed"] for r in deterministic)

    def test_export_controls_csv(self, tmp_path):
        rows = run_detector_controls(random_seeds=(0,))
        out = export_detector_controls_csv(rows, tmp_path / "controls.csv")
        text = out.read_text(encoding="utf-8")
        assert "control_name" in text
        assert "positive_overlapping" in text
        assert out.exists()


class TestDualTrackN0Governance:
    """E-085 dual-track governance: gate inactive; Track B n_0 not gate-eligible."""

    def test_gate_inactive_both_tracks(self):
        assert SHELL_PRIME_MATCH_GATE_ACTIVE is False

    def test_primary_track_is_canonical(self):
        assert SHELL_PRIME_MATCH_PRIMARY_TRACK == "canonical_from_qec_bridge"

    def test_track_b_n0_documented_but_not_gate_eligible(self):
        assert TRACK_B_ENERGIEDOKU_FULL_EXPLORATORY_N0 == 2
        assert TRACK_B_ENERGIEDOKU_FULL_GATE_ELIGIBLE is False

    def test_preregistration_json_dual_tracks(self):
        import json
        from pathlib import Path

        root = Path(__file__).resolve().parents[1]
        path = root / "docs" / "reports" / "shell_separation_preregistration.json"
        data = json.loads(path.read_text(encoding="utf-8"))

        assert data["dual_track_governance"]["gate_active"] is False
        assert data["dual_track_governance"]["primary_track_id"] == "track_a_canonical"

        track_a = data["tracks"]["track_a_canonical"]
        assert track_a["construction"] == "canonical_from_qec_bridge"
        assert track_a["n_0"] is None
        assert track_a["first_loss_n"] is None
        assert track_a["gate_eligible"] is True

        track_b = data["tracks"]["track_b_energiedoku_full"]
        assert track_b["construction"] == "energiedoku_full"
        assert track_b["exploratory_n_0"] == 2
        assert track_b["first_loss_n"] == 2
        assert track_b["gate_eligible"] is False
        assert track_b["epsilon_rule"] == "theorematic_energiedoku_v1"

    def test_gate_inactive_implies_no_arithmetic_coupling(self):
        """Gate inactive: neither track activates shellPrimeMatchAtFirstLoss today."""
        assert SHELL_PRIME_MATCH_GATE_ACTIVE is False
        assert TRACK_B_ENERGIEDOKU_FULL_GATE_ELIGIBLE is False
