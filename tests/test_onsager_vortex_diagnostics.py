"""Tests for Onsager vortex circulation diagnostics (ORQ-089 / E-089)."""

from __future__ import annotations

import pytest

from kepler_hurwitz.dumas_cone_orbit import HOSTS, ROTOR_GAP_CYCLE, verify_dumas_orbit
from kepler_hurwitz.onsager_vortex_diagnostics import (
    MODEL_CANONICAL,
    MODEL_CEAB_SHIFT,
    MODEL_CHANNEL_SHUFFLE,
    ONSAGER_VORTEX_TAG,
    accumulate_holonomy_phase,
    build_circulation_record,
    build_export_rows_for_quadruplet,
    ceab_holonomy_loop,
    channel_shuffle_nullmodel,
    circulation_quantum_number,
    compare_vortex_vs_trivial,
    defect_musketeer_overlap,
    gap_law_ok,
    gap_rotor_loop,
    gap_rotor_step,
    generate_prime_quadruplets_sieve,
    holonomy_phase_closure_ok,
    loop_encircles_defect_structure,
    parse_nullmodel_spec,
    partial_rotor_winding,
    structured_circulation_quantum_number,
    structured_encircles_defect,
    structured_phase_closure_ok,
    trivial_host_loop,
    validate_dumas_defect_core,
)
from kepler_hurwitz.primvierling import (
    build_prime_quadruplet,
    generate_prime_quadruplets,
    symmetry_shift_ceab,
)

CLASSIC = build_prime_quadruplet(11)
FAST_STOP = 10_000
FULL_STOP = 1_000_000
FULL_QUADRUPLET_COUNT = 166


@pytest.fixture(scope="module")
def fast_quadruplets() -> list[tuple[int, int, int, int]]:
    return generate_prime_quadruplets(2, FAST_STOP)


@pytest.fixture(scope="module")
def full_quadruplets() -> list[tuple[int, int, int, int]]:
    return generate_prime_quadruplets(2, FULL_STOP)


SHUFFLE_SWAPS: tuple[tuple[int, int], ...] = ((0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3))


class TestOnsagerVortexDiagnostics:
    def test_tag_is_b(self):
        assert ONSAGER_VORTEX_TAG == "[B]"

    def test_defect_core_absent_from_musketeers(self):
        for host in HOSTS:
            assert defect_musketeer_overlap(CLASSIC, host) == 0

    def test_validate_dumas_defect_core(self):
        assert validate_dumas_defect_core(CLASSIC) is True

    def test_gap_rotor_step_matches_expected_gaps(self):
        step = gap_rotor_step(CLASSIC, "E")
        assert step.gap_pair == (2, 4)
        assert step.defect_prime == 19
        assert step.musketeers == (11, 13, 17)

    def test_full_rotor_loop_has_four_hosts(self):
        steps = gap_rotor_loop(CLASSIC, cycles=1)
        assert len(steps) == 4
        assert [s.host for s in steps] == list(HOSTS)

    def test_phase_closure_on_full_gap_rotor_loop(self):
        steps = gap_rotor_loop(CLASSIC, cycles=1)
        assert holonomy_phase_closure_ok(steps) is True
        assert accumulate_holonomy_phase(steps) == 0

    def test_vortex_winding_one_per_cycle(self):
        steps = gap_rotor_loop(CLASSIC, cycles=1)
        assert circulation_quantum_number(steps) == 1
        assert circulation_quantum_number(gap_rotor_loop(CLASSIC, cycles=2)) == 2

    def test_trivial_loop_zero_winding(self):
        steps = trivial_host_loop(CLASSIC, host="E", repeats=4)
        assert circulation_quantum_number(steps) == 0
        assert holonomy_phase_closure_ok(steps) is True

    def test_vortex_encircles_defect_structure(self):
        steps = gap_rotor_loop(CLASSIC, cycles=1)
        assert loop_encircles_defect_structure(steps) is True
        assert loop_encircles_defect_structure(trivial_host_loop(CLASSIC)) is False

    def test_pop_threshold_at_four_steps(self):
        assert partial_rotor_winding(1) == 0
        assert partial_rotor_winding(3) == 0
        assert partial_rotor_winding(4) == 1
        assert partial_rotor_winding(7) == 1
        assert partial_rotor_winding(8) == 2

    def test_compare_vortex_beats_trivial(self):
        n_vortex, n_trivial, holonomy, phase_ok, encircles = compare_vortex_vs_trivial(
            CLASSIC
        )
        assert n_vortex == 1
        assert n_trivial == 0
        assert holonomy == 0
        assert phase_ok is True
        assert encircles is True

    def test_record_batch(self):
        record = build_circulation_record(CLASSIC)
        assert record.vortex_winding == 1
        assert record.trivial_winding == 0
        assert record.phase_closure_ok is True
        assert record.encircles_defect is True
        assert record.gap_law_ok is True
        assert record.pop_threshold_steps == 4
        assert record.ceab_loop_length in (1, 2)

    def test_shuffle_breaks_structured_diagnostics(self):
        shuffled = channel_shuffle_nullmodel(CLASSIC)
        record = build_circulation_record(shuffled)
        assert record.gap_law_ok is False
        assert record.vortex_winding == 0
        assert record.phase_closure_ok is False
        assert record.encircles_defect is False

    def test_rotor_gap_cycle_prefix_on_classic_enumeration(self):
        observed = tuple(gap_rotor_step(CLASSIC, host).gap_pair for host in HOSTS)
        assert observed == ROTOR_GAP_CYCLE

    def test_rejects_invalid_cycles(self):
        with pytest.raises(ValueError):
            gap_rotor_loop(CLASSIC, cycles=0)


class TestOnsagerVortexExport:
    def test_sieve_matches_reference_count(self):
        from kepler_hurwitz.onsager_vortex_diagnostics import generate_prime_quadruplets_sieve
        from kepler_hurwitz.primvierling import generate_prime_quadruplets

        sieve = generate_prime_quadruplets_sieve(2, 10_000)
        reference = generate_prime_quadruplets(2, 10_000)
        assert sieve == reference

    def test_build_export_row_canonical(self):
        from kepler_hurwitz.onsager_vortex_diagnostics import (
            MODEL_CANONICAL,
            ONSAGER_VORTEX_CSV_FIELDS,
            build_export_row,
        )

        row = build_export_row(CLASSIC)
        assert row.base_p1 == 11
        assert row.model_type == MODEL_CANONICAL
        assert row.vortex_winding == 1
        assert row.phase_closure_ok is True
        assert row.encircles_defect is True
        assert row.gap_law_ok is True
        assert row.topological_contrast_vs_canonical is False
        assert set(row.as_csv_dict()) == set(ONSAGER_VORTEX_CSV_FIELDS)

    def test_nullmodel_rows_contrast_shuffle(self):
        from kepler_hurwitz.onsager_vortex_diagnostics import (
            MODEL_CANONICAL,
            MODEL_CHANNEL_SHUFFLE,
            build_export_rows_for_quadruplet,
        )

        rows = build_export_rows_for_quadruplet(
            CLASSIC,
            include_nullmodels=frozenset({"shuffle"}),
        )
        assert len(rows) == 2
        assert rows[0].model_type == MODEL_CANONICAL
        shuffle = rows[1]
        assert shuffle.model_type == MODEL_CHANNEL_SHUFFLE
        assert shuffle.base_p1 == 11
        assert shuffle.topological_contrast_vs_canonical is True
        assert shuffle.vortex_winding == 0
        assert shuffle.phase_closure_ok is False
        assert shuffle.encircles_defect is False

    def test_nullmodel_rows_include_ceab_and_shuffle(self):
        from kepler_hurwitz.onsager_vortex_diagnostics import (
            MODEL_CEAB_SHIFT,
            build_export_rows_for_quadruplet,
            parse_nullmodel_spec,
        )

        assert parse_nullmodel_spec("shuffle,ceab") == frozenset({"shuffle", "ceab"})
        rows = build_export_rows_for_quadruplet(
            CLASSIC,
            include_nullmodels=parse_nullmodel_spec("shuffle,ceab"),
        )
        assert len(rows) == 3
        assert rows[1].model_type == MODEL_CEAB_SHIFT
        assert rows[1].topological_contrast_vs_canonical is True

    def test_export_rows_to_csv(self, tmp_path):
        from kepler_hurwitz.onsager_vortex_diagnostics import (
            export_rows_to_csv,
            build_export_rows_for_quadruplet,
        )

        path = tmp_path / "onsager_vortex.csv"
        rows = build_export_rows_for_quadruplet(
            CLASSIC,
            include_nullmodels=frozenset({"shuffle"}),
        )
        export_rows_to_csv(rows, path)
        lines = path.read_text(encoding="utf-8").splitlines()
        assert lines[0].startswith("base_p1,model_type,")
        assert "channel_shuffle" in lines[2]


@pytest.mark.regression
class TestOnsagerVortexNumericalScale:
    """Batch numerical verification on canonical prime quadruplet ranges."""

    def test_sieve_matches_reference_at_1e6(self):
        sieve = generate_prime_quadruplets_sieve(2, FULL_STOP)
        reference = generate_prime_quadruplets(2, FULL_STOP)
        assert sieve == reference
        assert len(sieve) == FULL_QUADRUPLET_COUNT

    def test_gap_law_holds_on_fast_range(self, fast_quadruplets):
        assert all(gap_law_ok(v) for v in fast_quadruplets)

    def test_defect_core_valid_on_fast_range(self, fast_quadruplets):
        assert all(validate_dumas_defect_core(v) for v in fast_quadruplets)

    def test_structured_winding_one_on_fast_range(self, fast_quadruplets):
        for v in fast_quadruplets:
            steps = gap_rotor_loop(v, cycles=1)
            assert structured_circulation_quantum_number(steps, v) == 1
            assert structured_phase_closure_ok(steps, v) is True
            assert structured_encircles_defect(steps, v) is True

    def test_trivial_host_zero_winding_all_hosts(self, fast_quadruplets):
        for v in fast_quadruplets[:20]:
            for host in HOSTS:
                steps = trivial_host_loop(v, host=host, repeats=4)
                assert structured_circulation_quantum_number(steps, v) == 0

    def test_two_cycles_double_winding(self, fast_quadruplets):
        for v in fast_quadruplets[:20]:
            steps = gap_rotor_loop(v, cycles=2)
            assert circulation_quantum_number(steps) == 2
            record = build_circulation_record(v, cycles=2)
            assert record.vortex_winding == 2

    def test_holonomy_zero_on_all_canonical_loops(self, fast_quadruplets):
        for v in fast_quadruplets:
            steps = gap_rotor_loop(v, cycles=1)
            assert accumulate_holonomy_phase(steps) == 0
            assert holonomy_phase_closure_ok(steps) is True

    def test_pop_threshold_uniform(self, fast_quadruplets):
        for v in fast_quadruplets:
            assert build_circulation_record(v).pop_threshold_steps == 4

    @pytest.mark.parametrize("swap", SHUFFLE_SWAPS)
    def test_all_shuffle_swaps_break_gap_law_classic(self, swap: tuple[int, int]):
        shuffled = channel_shuffle_nullmodel(CLASSIC, swap=swap)
        assert gap_law_ok(shuffled) is False
        record = build_circulation_record(shuffled)
        assert record.vortex_winding == 0
        assert record.phase_closure_ok is False
        assert record.encircles_defect is False

    def test_ceab_shift_breaks_gap_law_on_fast_range(self, fast_quadruplets):
        for v in fast_quadruplets:
            shifted = symmetry_shift_ceab(v)
            assert gap_law_ok(shifted) is False
            record = build_circulation_record(shifted)
            assert record.vortex_winding == 0
            assert record.phase_closure_ok is False
            assert record.encircles_defect is False

    def test_nullmodel_contrast_full_fast_range(self, fast_quadruplets):
        ceab_contrast = 0
        shuffle_contrast = 0
        for v in fast_quadruplets:
            rows = build_export_rows_for_quadruplet(
                v,
                include_nullmodels=frozenset({"ceab", "shuffle"}),
            )
            canonical = rows[0]
            assert canonical.model_type == MODEL_CANONICAL
            assert canonical.topological_contrast_vs_canonical is False
            assert rows[1].topological_contrast_vs_canonical is True
            assert rows[2].topological_contrast_vs_canonical is True
            ceab_contrast += int(rows[1].topological_contrast_vs_canonical)
            shuffle_contrast += int(rows[2].topological_contrast_vs_canonical)
        n = len(fast_quadruplets)
        assert ceab_contrast == n
        assert shuffle_contrast == n

    def test_canonical_implies_dumas_orbit_clean(self, fast_quadruplets):
        assert verify_dumas_orbit(fast_quadruplets) == []

    def test_structured_stricter_than_combinatorial_on_shuffle(self):
        shuffled = channel_shuffle_nullmodel(CLASSIC)
        steps = gap_rotor_loop(shuffled, cycles=1)
        assert circulation_quantum_number(steps) == 1
        assert structured_circulation_quantum_number(steps, shuffled) == 0

    def test_ceab_holonomy_involution_classic(self):
        steps = ceab_holonomy_loop(CLASSIC)
        assert len(steps) == 2
        assert steps[0].state == CLASSIC
        assert steps[1].state == symmetry_shift_ceab(CLASSIC)
        assert steps[0].pair_gaps == steps[1].pair_gaps

    def test_compare_vortex_vs_trivial_fast_sample(self, fast_quadruplets):
        for v in fast_quadruplets:
            n_v, n_t, holonomy, phase_ok, encircles = compare_vortex_vs_trivial(v)
            assert (n_v, n_t, holonomy, phase_ok, encircles) == (1, 0, 0, True, True)

    def test_parse_nullmodel_spec_empty(self):
        assert parse_nullmodel_spec("") == frozenset()
        assert parse_nullmodel_spec(None) == frozenset()

    def test_parse_nullmodel_spec_rejects_unknown(self):
        with pytest.raises(ValueError, match="unknown nullmodel"):
            parse_nullmodel_spec("bogus")


@pytest.mark.slow
class TestOnsagerVortexFullScale:
    """Full-range checks up to p <= 1_000_000 (166 quadruplets)."""

    def test_full_quadruplet_count(self, full_quadruplets):
        assert len(full_quadruplets) == FULL_QUADRUPLET_COUNT

    def test_structured_invariants_all_166(self, full_quadruplets):
        for v in full_quadruplets:
            record = build_circulation_record(v)
            assert record.vortex_winding == 1
            assert record.trivial_winding == 0
            assert record.phase_closure_ok is True
            assert record.encircles_defect is True
            assert record.gap_law_ok is True
            assert record.holonomy_phase_total == 0

    def test_nullmodel_contrast_all_166(self, full_quadruplets):
        total = 0
        for v in full_quadruplets:
            rows = build_export_rows_for_quadruplet(
                v,
                include_nullmodels=frozenset({"ceab", "shuffle"}),
            )
            assert len(rows) == 3
            assert rows[0].model_type == MODEL_CANONICAL
            assert rows[1].model_type == MODEL_CEAB_SHIFT
            assert rows[2].model_type == MODEL_CHANNEL_SHUFFLE
            total += sum(int(r.topological_contrast_vs_canonical) for r in rows[1:])
        assert total == 2 * FULL_QUADRUPLET_COUNT

    def test_export_row_count_full_batch(self, full_quadruplets):
        rows = [
            row
            for v in full_quadruplets
            for row in build_export_rows_for_quadruplet(
                v,
                include_nullmodels=frozenset({"ceab", "shuffle"}),
            )
        ]
        assert len(rows) == 3 * FULL_QUADRUPLET_COUNT
