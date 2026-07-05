"""Arithmetic and symmetry tests for canonical prime quadruplets (Primzahlvierlinge)."""

from __future__ import annotations

import csv
import math
from pathlib import Path

import pytest

from kepler_hurwitz.primvierling import (
    build_prime_quadruplet,
    ceab_orbit,
    ceab_rotate,
    component_channels,
    is_prime,
    is_prime_quadruplet,
    quat_norm,
)
from kepler_hurwitz.signatures import eabc_mass, signature_from_nat

ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "docs" / "energiedoku_exports" / "pure_prime_quadruples.csv"

KNOWN_QUADRUPLETS = [
    (5, 7, 11, 13),
    (11, 13, 17, 19),
    (101, 103, 107, 109),
]

NEGATIVE_ANCHORS = [7, 13, 17]


def quadruple_product(v: tuple[int, int, int, int]) -> int:
    return math.prod(v)


@pytest.mark.parametrize("v", KNOWN_QUADRUPLETS)
def test_known_prime_quadruplets_are_detected(v: tuple[int, int, int, int]) -> None:
    p = v[0]
    assert v == (p, p + 2, p + 6, p + 8)
    assert all(is_prime(x) for x in v)
    assert is_prime_quadruplet(v)


@pytest.mark.parametrize("p", NEGATIVE_ANCHORS)
def test_non_quadruplets_are_rejected(p: int) -> None:
    assert not is_prime_quadruplet(build_prime_quadruplet(p))


def test_quadruple_components_cover_all_eabc_channels() -> None:
    v = (5, 7, 11, 13)
    assert component_channels(v) == ("A", "B", "C", "E")
    assert set(component_channels(v)) == {"E", "A", "B", "C"}


@pytest.mark.parametrize("v", KNOWN_QUADRUPLETS)
def test_quadruple_components_have_distinct_eabc_channels(
    v: tuple[int, int, int, int],
) -> None:
    channels = component_channels(v)
    assert len(set(channels)) == 4
    assert set(channels) == {"E", "A", "B", "C"}


@pytest.mark.parametrize("v", KNOWN_QUADRUPLETS)
def test_quadruple_product_signature_full_coverage(v: tuple[int, int, int, int]) -> None:
    product = quadruple_product(v)
    sig = signature_from_nat(product)
    assert sig.as_tuple() == (1, 1, 1, 1)
    assert sig.sorted_counts() == (1, 1, 1, 1)
    assert sig.total_weight() == 4
    assert eabc_mass(product) == 4


def test_quadruple_norm_signature_reference_case() -> None:
    v = (5, 7, 11, 13)
    n = quat_norm(v)
    assert n == 364
    assert signature_from_nat(n).as_tuple() == (1, 0, 1, 0)
    assert signature_from_nat(n).sorted_counts() == (1, 1, 0, 0)
    assert eabc_mass(n) == 2


def test_norm_mass_differs_from_product_mass_reference_case() -> None:
    v = (5, 7, 11, 13)
    norm_mass = eabc_mass(quat_norm(v))
    product_mass = eabc_mass(quadruple_product(v))
    assert norm_mass == 2
    assert product_mass == 4
    assert norm_mass != product_mass


def _load_csv_rows(limit: int) -> list[dict[str, str]]:
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        return [row for _, row in zip(range(limit), reader)]


def test_pure_prime_quadruples_csv_first_rows() -> None:
    assert CSV_PATH.is_file()
    rows = _load_csv_rows(20)
    assert rows

    seen_quadruples: set[tuple[int, int, int, int]] = set()
    for row in rows:
        a = int(row["quat_a"])
        b = int(row["quat_b"])
        c = int(row["quat_c"])
        e = int(row["quat_e"])
        assert (b, c, e) == (a + 2, a + 6, a + 8)
        assert all(is_prime(x) for x in (a, b, c, e))
        assert is_prime_quadruplet((a, b, c, e))

        product_sig = signature_from_nat(a * b * c * e)
        assert product_sig.sorted_counts() == (1, 1, 1, 1)
        assert product_sig.total_weight() == 4
        assert int(row["product_M"]) == 4

        norm = a * a + b * b + c * c + e * e
        assert int(row["quat_norm"]) == norm
        assert int(row["n"]) == norm
        assert int(row["M"]) == eabc_mass(norm)
        assert signature_from_nat(norm).as_tuple() == (
            int(row["E"]),
            int(row["A"]),
            int(row["B"]),
            int(row["C"]),
        )

        seen_quadruples.add((a, b, c, e))

    assert len(seen_quadruples) == len(rows)


@pytest.mark.parametrize("v", KNOWN_QUADRUPLETS)
def test_ceab_rotation_preserves_quat_norm(v: tuple[int, int, int, int]) -> None:
    assert quat_norm(v) == quat_norm(ceab_rotate(v))


def test_all_ceab_orbit_states_share_quat_norm() -> None:
    v = (101, 103, 107, 109)
    norms = {quat_norm(state) for state in ceab_orbit(v)}
    assert len(norms) == 1
