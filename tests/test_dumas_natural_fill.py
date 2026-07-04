import pytest

from kepler_hurwitz.dumas_natural_fill import (
    CLASSIC_PRIMVIERLING,
    CLASSIC_TRIPLE_SLOT_PRIMES,
    DumasSlotCount,
    build_dumas_natural_fill,
    build_dumas_natural_fill_for_anchor,
    dumas_slot_by_index,
    host_component,
    host_triple,
    prime_indices_for_component,
    verify_dumas_lemma,
)
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel


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
