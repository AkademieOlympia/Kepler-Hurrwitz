from kepler_hurwitz.signatures import eabc_mass, signature_from_nat

from examples.export_pure_prime_eabc_quaternions import (
    first_pure_prime_eabc_quaternions,
    is_pure_prime_eabc_quaternion,
)


class TestPurePrimeEABCQuaternions:
    def test_first_four_match_single_channel_primes(self):
        records = first_pure_prime_eabc_quaternions(4)
        assert [record.n for record in records] == [5, 7, 11, 13]
        assert [record.M for record in records] == [1, 1, 1, 1]
        assert records[0].eabc_channel == "A"
        assert records[1].eabc_channel == "B"
        assert records[2].eabc_channel == "C"
        assert records[3].eabc_channel == "E"

    def test_axis_composites_excluded(self):
        assert not is_pure_prime_eabc_quaternion(26)  # 2 * 13
        assert eabc_mass(26) == 1

    def test_signature_matches_signature_from_nat(self):
        for record in first_pure_prime_eabc_quaternions(20):
            sig = signature_from_nat(record.n)
            assert (record.E, record.A, record.B, record.C) == sig.as_tuple()
            assert record.M == eabc_mass(record.n)
            assert record.partition == ",".join(str(value) for value in sig.sorted_counts())
