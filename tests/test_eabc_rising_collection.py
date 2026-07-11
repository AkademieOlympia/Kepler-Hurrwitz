import csv
from pathlib import Path

import pytest

from kepler_hurwitz.eabc_rising_collection import (
    EABCRisingQuadruple,
    collect_eabc_rising_quadruples,
    collect_eabc_rising_with_trace,
    consecutive_gaps,
    consecutive_recorded_overlap_sizes,
    extract_maximal_disjoint_subsequence,
    first_n_primes,
    is_canonical_prime_quadruplet,
    is_eabc_class_prime,
    partition_eabc_quadruples_by_channels,
    prime_eabc_channel,
    summarize_partition,
    summarize_quadruples,
    summarize_rising_overlap_chain,
    transition_overlap_histogram,
    verify_pairwise_disjoint,
    verify_quadruple_eabc_completeness,
    _try_add_to_collection,
)
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel


class TestEABCPrimeClassification:
    def test_eabc_residue_classes(self):
        assert prime_eabc_channel(5) == EABCChannel.A
        assert prime_eabc_channel(7) == EABCChannel.B
        assert prime_eabc_channel(11) == EABCChannel.C
        assert prime_eabc_channel(13) == EABCChannel.E

    def test_non_eabc_primes_skipped(self):
        assert not is_eabc_class_prime(2)
        assert not is_eabc_class_prime(3)


class TestCollisionRule:
    def test_single_member_replaced(self):
        assert _try_add_to_collection([5], 17) == [17]

    def test_inner_member_eliminated(self):
        collection = [5, 7, 11]
        assert _try_add_to_collection(collection, 19) == [5, 11, 19]

    def test_outer_collision_skips_new_prime(self):
        collection = [5, 7, 11]
        assert _try_add_to_collection(collection, 29) == [5, 7, 11]

    def test_append_without_collision(self):
        assert _try_add_to_collection([5, 7], 11) == [5, 7, 11]


class TestFirstQuadrupleWitness:
    def test_classic_first_vierling_from_small_primes(self):
        quadruples, stream = collect_eabc_rising_quadruples(primes=[5, 7, 11, 13, 17, 19])
        assert stream == [5, 7, 11, 13, 17, 19]
        assert len(quadruples) == 1
        row = quadruples[0]
        assert row.primes == (5, 7, 11, 13)
        assert set(row.channels) == {EABCChannel.E, EABCChannel.A, EABCChannel.B, EABCChannel.C}
        assert row.gaps == (2, 4, 2)
        assert row.span == 8
        assert row.canonical


class TestCanonicalDetection:
    def test_canonical_quadruplet(self):
        assert is_canonical_prime_quadruplet((11, 13, 17, 19))

    def test_non_canonical_set(self):
        assert not is_canonical_prime_quadruplet((5, 7, 11, 17))


class TestFullScan2000:
    @pytest.fixture(scope="class")
    def quadruples(self):
        return collect_eabc_rising_quadruples(2000)[0]

    def test_finds_multiple_quadruples(self, quadruples):
        assert len(quadruples) >= 10

    def test_every_row_is_eabc_complete(self, quadruples):
        assert all(verify_quadruple_eabc_completeness(row) for row in quadruples)

    def test_primes_strictly_rising_per_row(self, quadruples):
        for row in quadruples:
            p1, p2, p3, p4 = row.primes
            assert p1 < p2 < p3 < p4

    def test_quadruple_indices_are_contiguous(self, quadruples):
        assert [row.index for row in quadruples] == list(range(1, len(quadruples) + 1))

    def test_summary_stats(self, quadruples):
        stats = summarize_quadruples(quadruples)
        assert stats["count"] == len(quadruples)
        assert stats["all_eabc_complete"] is True


class TestExportScript:
    def test_export_writes_expected_columns(self, tmp_path: Path):
        from examples.export_eabc_rising_quadruples import export_eabc_rising_quadruples_csv

        out = tmp_path / "rising.csv"
        export_eabc_rising_quadruples_csv(out, prime_count=200)
        with out.open(encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            rows = list(reader)
        assert reader.fieldnames == [
            "index",
            "p1",
            "p2",
            "p3",
            "p4",
            "channels",
            "span",
            "gaps",
            "canonical",
        ]
        assert rows
        first = rows[0]
        assert first["p1"] == "5"
        assert first["p4"] == "13"


def test_first_n_primes_count():
    assert len(first_n_primes(2000)) == 2000
    assert first_n_primes(10)[-1] == 29


def test_consecutive_gaps():
    assert consecutive_gaps((5, 7, 11, 13)) == (2, 4, 2)


def test_eabc_rising_quadruple_csv_row():
    row = EABCRisingQuadruple(
        index=1,
        primes=(5, 7, 11, 13),
        channels=(
            EABCChannel.A,
            EABCChannel.B,
            EABCChannel.C,
            EABCChannel.E,
        ),
        span=8,
        gaps=(2, 4, 2),
        canonical=False,
    )
    assert row.as_csv_row()["channels"] == "A,B,C,E"


class TestChannelBucketPartition:
    def test_first_quadruple_matches_classic_witness(self):
        quadruples, stream, remainder = partition_eabc_quadruples_by_channels(
            primes=[5, 7, 11, 13, 17, 19]
        )
        assert stream == [5, 7, 11, 13, 17, 19]
        assert len(quadruples) == 1
        assert quadruples[0].primes == (5, 7, 11, 13)
        assert remainder == [17, 19]

    def test_partition_2000_reaches_channel_theoretical_max(self):
        quadruples, stream, remainder = partition_eabc_quadruples_by_channels(2000)
        stats = summarize_partition(quadruples, stream, remainder)
        assert stats["m"] == 1998
        assert stats["eabc_stream_count"] == 1998
        assert stats["K_bucket"] == 486
        assert stats["quadruple_count"] == 486
        assert stats["K_greedy"] == 310
        assert stats["used_prime_count"] == 1944
        assert stats["R_bucket"] == 54
        assert stats["remainder_count"] == 54
        assert stats["theoretical_max_quadruples"] == 486
        assert stats["all_eabc_complete"] is True
        assert stats["disjoint"] is True
        assert stats["covers_stream"] is True
        assert stats["Coverage_bucket"] == pytest.approx(1944 / 1998, rel=1e-9)
        assert stats["coverage_ratio"] == pytest.approx(1944 / 1998, rel=1e-9)
        assert stats["greedy_quadruple_count"] == 310
        assert stats["GreedyEfficiency"] == pytest.approx(310 / 486, rel=1e-9)
        assert stats["GreedyLoss"] == pytest.approx(1 - 310 / 486, rel=1e-9)

    def test_export_comparison_csv(self, tmp_path: Path):
        from examples.export_eabc_partition_comparison import export_partition_comparison_csv

        out = tmp_path / "comparison.csv"
        export_partition_comparison_csv(out, prime_count=2000)
        with out.open(encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            assert reader.fieldnames == [
                "m",
                "K_bucket",
                "K_greedy",
                "R_bucket",
                "Coverage_bucket",
                "GreedyEfficiency",
                "GreedyLoss",
            ]
            rows = list(reader)
        assert len(rows) == 1
        row = rows[0]
        assert int(row["m"]) == 1998
        assert int(row["K_bucket"]) == 486
        assert int(row["K_greedy"]) == 310
        assert int(row["R_bucket"]) == 54
        assert float(row["Coverage_bucket"]) == pytest.approx(1944 / 1998, rel=1e-6)
        assert float(row["GreedyEfficiency"]) == pytest.approx(310 / 486, rel=1e-6)
        assert float(row["GreedyLoss"]) == pytest.approx(1 - 310 / 486, rel=1e-6)

    def test_export_partition_quadruples_csv(self, tmp_path: Path):
        from examples.export_eabc_partition_quadruples import export_eabc_partition_quadruples_csv

        out = tmp_path / "partition.csv"
        export_eabc_partition_quadruples_csv(out, prime_count=200)
        with out.open(encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            rows = list(reader)
        assert reader.fieldnames == [
            "index",
            "p1",
            "p2",
            "p3",
            "p4",
            "channels",
            "span",
            "gaps",
            "canonical",
        ]
        assert rows
        assert rows[0]["p1"] == "5"
        assert rows[0]["p4"] == "13"


class TestRisingOverlapChain:
    def test_recorded_quadruples_are_pairwise_disjoint_2000(self):
        quadruples, _steps, _stream = collect_eabc_rising_with_trace(2000)
        assert len(quadruples) == 310
        assert verify_pairwise_disjoint(quadruples)
        assert consecutive_recorded_overlap_sizes(quadruples) == [0] * 309

    def test_within_build_transitions_overlap(self):
        _quadruples, steps, _stream = collect_eabc_rising_with_trace(
            primes=[5, 7, 11, 13, 17, 19]
        )
        histogram = transition_overlap_histogram(steps)
        assert histogram[(1, 2, 1)] >= 1
        assert histogram[(2, 3, 2)] == 1
        assert histogram[(3, 4, 3)] == 1

    def test_no_reset_chain_overlaps_heavily(self):
        quadruples, _steps, _stream = collect_eabc_rising_with_trace(
            2000,
            reset_after_record=False,
        )
        overlaps = consecutive_recorded_overlap_sizes(quadruples)
        assert len(quadruples) == 1995
        assert min(overlaps) >= 3
        assert len(extract_maximal_disjoint_subsequence(quadruples)) == 1

    def test_disjoint_subsequence_equals_greedy_count(self):
        quadruples, _steps, _stream = collect_eabc_rising_with_trace(2000)
        extracted = extract_maximal_disjoint_subsequence(quadruples)
        assert len(extracted) == 310

    def test_summarize_rising_overlap_chain_2000(self):
        summary = summarize_rising_overlap_chain(2000)
        assert summary["K_greedy_reset"] == 310
        assert summary["K_greedy_no_reset"] == 1995
        assert summary["K_bucket"] == 486
        assert summary["K_disjoint_subseq_reset"] == 310
        assert summary["K_disjoint_subseq_no_reset"] == 1
        assert summary["recorded_pairwise_disjoint"] is True
        assert summary["recorded_consecutive_overlap_max"] == 0
        assert summary["transition_step_count"] == 1998
        assert summary["transition_overlap_counts"] == {0: 349, 1: 311, 2: 711, 3: 627}

    def test_export_overlap_stats(self, tmp_path: Path):
        from examples.export_eabc_rising_overlap_stats import (
            export_rising_overlap_summary_json,
            export_rising_overlap_trace_csv,
        )

        summary_out = tmp_path / "summary.json"
        trace_out = tmp_path / "trace.csv"
        export_rising_overlap_summary_json(summary_out, prime_count=200)
        export_rising_overlap_trace_csv(trace_out, prime_count=200)
        with summary_out.open(encoding="utf-8") as handle:
            import json

            summary = json.load(handle)
        assert summary["K_greedy_reset"] >= 10
        with trace_out.open(encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            rows = list(reader)
        assert reader.fieldnames == [
            "step_index",
            "prime",
            "size_before",
            "size_after",
            "overlap_size",
            "collection_before",
            "collection_after",
            "recorded_quadruple_index",
            "build_index",
        ]
        assert rows
