import csv
from pathlib import Path

import pytest

from kepler_hurwitz.dumas_natural_fill import (
    CLASSIC_PRIMVIERLING,
    CLASSIC_TRIPLE_SLOT_PRIMES,
    DumasSlotCount,
    HOST_CHANNEL_ORDER,
    ROTOR_OFFSET_BY_HOST,
    ROTOR_OFFSET_CYCLE,
    ROTOR_POSITION_BY_HOST,
    ROTOR_POSITION_CYCLE,
    build_dumas_natural_fill,
    build_dumas_natural_fill_for_anchor,
    dumas_slot_by_index,
    eabc_channel_from_mod12,
    host_component,
    host_for_quadruplet_index,
    host_triple,
    host_triple_gap_pair,
    natural_fill_index_gaps,
    prime_indices_for_component,
    rotor_d_artagnan,
    rotor_d_artagnan_offset,
    sorted_gap_pair,
    verify_dumas_lemma,
)
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel
from kepler_hurwitz.primvierling import build_prime_quadruplet


class TestDumasNaturalFillUpTo12:
    """Systematic natural-number slots 1..12 after the Dumas lemma."""

    @pytest.fixture(scope="class")
    def fill(self):
        return build_dumas_natural_fill(CLASSIC_PRIMVIERLING)

    @pytest.mark.parametrize("index", range(1, DumasSlotCount + 1))
    def test_triple_slot_index_is_canonical(self, fill, index: int):
        slot = dumas_slot_by_index(fill, index)
        assert slot.index == index
        assert slot.role == "triple"
        assert 1 <= slot.slot_in_host <= 3

    @pytest.mark.parametrize(
        ("index", "host", "prime"),
        [
            (1, EABCChannel.E, 11),
            (2, EABCChannel.E, 13),
            (3, EABCChannel.E, 17),
            (4, EABCChannel.A, 13),
            (5, EABCChannel.A, 17),
            (6, EABCChannel.A, 19),
            (7, EABCChannel.B, 11),
            (8, EABCChannel.B, 17),
            (9, EABCChannel.B, 19),
            (10, EABCChannel.C, 11),
            (11, EABCChannel.C, 13),
            (12, EABCChannel.C, 19),
        ],
    )
    def test_classic_slot_assignment(self, fill, index: int, host: EABCChannel, prime: int):
        slot = dumas_slot_by_index(fill, index)
        assert slot.host == host
        assert slot.prime == prime
        assert slot.prime != host_component(host, CLASSIC_PRIMVIERLING)

    @pytest.mark.parametrize("index", range(1, DumasSlotCount + 1))
    def test_gap_encodes_host(self, fill, index: int):
        slot = dumas_slot_by_index(fill, index)
        triple = host_triple(slot.host, CLASSIC_PRIMVIERLING)
        host_prime = host_component(slot.host, CLASSIC_PRIMVIERLING)
        assert slot.prime in triple
        assert host_prime not in triple
        assert slot.prime != host_prime

    @pytest.mark.parametrize(
        ("prime", "expected_indices"),
        [
            (11, (1, 7, 10)),
            (13, (2, 4, 11)),
            (17, (3, 5, 8)),
            (19, (6, 9, 12)),
        ],
    )
    def test_un_pour_tous_multiplicity_three(self, fill, prime: int, expected_indices: tuple[int, ...]):
        assert prime_indices_for_component(fill, prime) == expected_indices

    def test_host_components_match_dumas(self, fill):
        assert fill.host_components == {"E": 19, "A": 11, "B": 13, "C": 17}

    def test_classic_table_matches_constant(self, fill):
        assert tuple(slot.prime for slot in fill.triple_slots) == CLASSIC_TRIPLE_SLOT_PRIMES


def test_verify_dumas_lemma_classic():
    assert verify_dumas_lemma(CLASSIC_PRIMVIERLING)


def test_build_dumas_natural_fill_for_anchor():
    fill = build_dumas_natural_fill_for_anchor(11)
    assert fill.primvierling == CLASSIC_PRIMVIERLING
    assert len(fill.triple_slots) == DumasSlotCount


def test_dumas_slot_by_index_rejects_out_of_range():
    fill = build_dumas_natural_fill(CLASSIC_PRIMVIERLING)
    with pytest.raises(ValueError):
        dumas_slot_by_index(fill, 0)
    with pytest.raises(ValueError):
        dumas_slot_by_index(fill, 13)


def test_host_triple_gap_pair_classic():
    assert host_triple_gap_pair(EABCChannel.E) == (2, 4)
    assert host_triple_gap_pair(EABCChannel.A) == (4, 2)
    assert host_triple_gap_pair(EABCChannel.B) == (6, 2)
    assert host_triple_gap_pair(EABCChannel.C) == (2, 6)


def test_natural_fill_index_gaps_empty_for_classic():
    fill = build_dumas_natural_fill(CLASSIC_PRIMVIERLING)
    assert natural_fill_index_gaps(fill) == ()


@pytest.mark.parametrize(
    ("index", "host", "quadruplet", "d_artagnan", "musketiere", "gap_pair"),
    [
        (1, EABCChannel.E, (5, 7, 11, 13), 13, (5, 7, 11), (2, 4)),
        (2, EABCChannel.A, (11, 13, 17, 19), 11, (13, 17, 19), (4, 2)),
        (3, EABCChannel.B, (101, 103, 107, 109), 103, (101, 107, 109), (6, 2)),
        (4, EABCChannel.C, (191, 193, 197, 199), 197, (191, 193, 199), (2, 6)),
        (5, EABCChannel.E, (821, 823, 827, 829), 829, (821, 823, 827), (2, 4)),
    ],
)
def test_drillinge_overview_witness_rows(
    index: int,
    host: EABCChannel,
    quadruplet: tuple[int, int, int, int],
    d_artagnan: int,
    musketiere: tuple[int, int, int],
    gap_pair: tuple[int, int],
):
    assert host_for_quadruplet_index(index) == host
    assert host_component(host, quadruplet) == d_artagnan
    assert host_triple(host, quadruplet) == musketiere
    assert sorted_gap_pair(musketiere) == gap_pair
    assert host_triple_gap_pair(host) == gap_pair


def test_host_triple_gap_pair_matches_sorted_gaps_on_canonical_quadruplets():
    for anchor in (5, 11, 101, 191, 821):
        v = build_prime_quadruplet(anchor)
        for host in HOST_CHANNEL_ORDER:
            triple = host_triple(host, v)
            assert sorted_gap_pair(triple) == host_triple_gap_pair(host)


DRILLINGE_CSV = (
    Path(__file__).resolve().parents[1] / "docs" / "energiedoku_exports" / "dumas_drillinge.csv"
)


def _parse_int_tuple(text: str) -> tuple[int, ...]:
    inner = text.strip().strip("()")
    return tuple(int(part.strip()) for part in inner.split(","))


def _load_drillinge_rows() -> list[dict[str, object]]:
    with DRILLINGE_CSV.open(encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


class TestDumasDrillingeRotor:
    """Rotor pattern in docs/energiedoku_exports/dumas_drillinge.csv."""

    @pytest.fixture(scope="class")
    def rows(self):
        return _load_drillinge_rows()

    def test_rotor_offset_and_position_cycles(self):
        assert ROTOR_OFFSET_CYCLE == (8, 0, 2, 6)
        assert ROTOR_POSITION_CYCLE == (4, 1, 2, 3)
        for host in HOST_CHANNEL_ORDER:
            assert ROTOR_OFFSET_BY_HOST[host] == rotor_d_artagnan_offset(host)
            idx = HOST_CHANNEL_ORDER.index(host)
            assert ROTOR_POSITION_BY_HOST[host] == ROTOR_POSITION_CYCLE[idx]

    @pytest.mark.parametrize(
        ("host", "offset", "position"),
        [
            (EABCChannel.E, 8, 4),
            (EABCChannel.A, 0, 1),
            (EABCChannel.B, 2, 2),
            (EABCChannel.C, 6, 3),
        ],
    )
    def test_rotor_offset_position_by_host(
        self, host: EABCChannel, offset: int, position: int
    ):
        assert ROTOR_OFFSET_BY_HOST[host] == offset
        assert ROTOR_POSITION_BY_HOST[host] == position

    def test_rotor_formulas_on_csv_rows(self, rows):
        for row in rows:
            index = int(row["index"])
            host = EABCChannel(str(row["host"]))
            v = _parse_int_tuple(str(row["quell_v"]))
            d = int(row["d_artagnan"])
            musketiere = _parse_int_tuple(str(row["musketiere"]))
            gap_pair = _parse_int_tuple(str(row["gap_pair"]))

            assert host_for_quadruplet_index(index) == host
            assert rotor_d_artagnan(host, v) == d
            assert host_component(host, v) == d
            assert v[ROTOR_POSITION_BY_HOST[host] - 1] == d
            assert host_triple(host, v) == musketiere
            assert host_triple_gap_pair(host) == gap_pair
            assert sorted_gap_pair(musketiere) == gap_pair

    def test_first_row_is_exceptional_quadruplet(self, rows):
        first = rows[0]
        assert _parse_int_tuple(str(first["quell_v"])) == (5, 7, 11, 13)

    def test_anchor_congruent_11_mod_30_after_first_row(self, rows):
        for row in rows[1:]:
            p = _parse_int_tuple(str(row["quell_v"]))[0]
            assert p % 30 == 11

    def test_host_rotor_differs_from_d_artagnan_mod12_class(self, rows):
        mismatches = []
        for row in rows:
            host = EABCChannel(str(row["host"]))
            d = int(row["d_artagnan"])
            d_class = eabc_channel_from_mod12(d)
            if d_class != host:
                mismatches.append(int(row["index"]))

        assert 2 in mismatches  # witness: host=A, d=11 ≡ C (mod 12)
        assert len(mismatches) == 504
        assert len(mismatches) < len(rows)
