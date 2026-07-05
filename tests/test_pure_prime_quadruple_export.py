from kepler_hurwitz.signatures import eabc_mass, signature_from_nat

from examples.export_pure_prime_quadruples import (
    first_pure_prime_quadruples,
    is_pure_prime_quadruple,
)


class TestPurePrimeQuadrupleExport:
    def test_first_quadruplet_is_canonical_witness(self):
        records = first_pure_prime_quadruples(1)
        record = records[0]
        assert record.p == 5
        assert (record.quat_a, record.quat_b, record.quat_c, record.quat_e) == (5, 7, 11, 13)
        assert record.M == 2
        assert record.product_M == 4
        assert (record.product_E, record.product_A, record.product_B, record.product_C) == (
            1,
            1,
            1,
            1,
        )

    def test_axis_aligned_single_prime_is_not_quadruple(self):
        assert not is_pure_prime_quadruple((5, 0, 0, 0))

    def test_signature_matches_signature_from_nat(self):
        for record in first_pure_prime_quadruples(10):
            sig_norm = signature_from_nat(record.n)
            assert (record.E, record.A, record.B, record.C) == sig_norm.as_tuple()
            assert record.M == eabc_mass(record.n)
            assert record.partition == ",".join(str(value) for value in sig_norm.sorted_counts())

            sig_prod = signature_from_nat(record.product_n)
            assert (
                record.product_E,
                record.product_A,
                record.product_B,
                record.product_C,
            ) == sig_prod.as_tuple()
            assert record.product_M == eabc_mass(record.product_n)
