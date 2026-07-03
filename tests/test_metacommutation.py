from kepler_hurwitz.discrete_time_flow import hurwitz_units_240, is_hurwitz_lattice_point, octonion_mul, octonion_norm_sq
from kepler_hurwitz.metacommutation import (
    analyze_dyadic_metacommutation,
    enumerate_dyadic_norm2_integer_roots,
    export_metacommutation_json,
    find_metacommutation_partners,
    summarize_metacommutation,
)


def test_enumerate_dyadic_norm2_integer_roots_count():
    roots = enumerate_dyadic_norm2_integer_roots()
    assert len(roots) == 112
    for root in roots:
        assert is_hurwitz_lattice_point(root)
        assert abs(octonion_norm_sq(root) - 2.0) < 1e-9


def test_metacommutation_resolves_all_pairs():
    roots = enumerate_dyadic_norm2_integer_roots()
    units = hurwitz_units_240()
    records = analyze_dyadic_metacommutation(dyadic_roots=roots, units=units)
    summary = summarize_metacommutation(records, dyadic_root_count=len(roots), unit_count=len(units))
    assert summary.pair_count == 112 * 240
    assert summary.unresolved_pairs == 0
    assert summary.resolved_pairs == summary.pair_count


def test_find_metacommutation_partners_reconstructs_product():
    roots = enumerate_dyadic_norm2_integer_roots()
    units = hurwitz_units_240()
    prime_root = roots[0]
    unit_from = units[0]
    records = find_metacommutation_partners(prime_root, unit_from, dyadic_roots=roots, units=units)
    assert records
    record = records[0]
    product = octonion_mul(record.unit_to, record.prime_partner)
    assert octonion_norm_sq(
        tuple(a - b for a, b in zip(octonion_mul(prime_root, unit_from), product, strict=True))
    ) < 1e-9


def test_export_metacommutation_json(tmp_path):
    records = analyze_dyadic_metacommutation()
    summary = summarize_metacommutation(records)
    path = export_metacommutation_json(records, summary, tmp_path / "metacommutation.json")
    assert path.exists()
