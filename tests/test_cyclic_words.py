from kepler_hurwitz.cyclic_words import (
    analyze_word_orbit,
    canonical_representative,
    orbit_under_cyclic_shift,
    reduce_words_by_orbit,
    rotations,
)


def test_rotations_for_binary_word():
    assert rotations("1011") == ("1011", "0111", "1110", "1101")


def test_orbit_under_cyclic_shift_deduplicates_periodic_words():
    assert orbit_under_cyclic_shift("0101") == ("0101", "1010")


def test_canonical_representative_matches_lexicographic_minimum():
    assert canonical_representative("1011") == "0111"


def test_analyze_word_orbit_returns_canonical_and_orbit():
    analysis = analyze_word_orbit("1011")
    assert analysis.canonical == "0111"
    assert "1011" in analysis.orbit


def test_reduce_words_by_orbit_groups_equivalent_words():
    grouped = reduce_words_by_orbit(["1011", "0111", "1100", "0011"])
    assert sorted(grouped["0111"]) == ["0111", "1011"]
    assert sorted(grouped["0011"]) == ["0011", "1100"]
