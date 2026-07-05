import pytest

from kepler_hurwitz.signatures import (
    EABCSignature4,
    eabc_mass,
    signature_from_nat,
)


class TestSignatureFromNat:
    def test_empty_signature_for_one(self):
        assert signature_from_nat(1) == EABCSignature4(0, 0, 0, 0)
        assert eabc_mass(1) == 0

    def test_axes_two_and_three_ignored(self):
        assert signature_from_nat(2) == EABCSignature4(0, 0, 0, 0)
        assert signature_from_nat(3) == EABCSignature4(0, 0, 0, 0)
        assert signature_from_nat(6) == EABCSignature4(0, 0, 0, 0)

    def test_single_channel_primes(self):
        assert signature_from_nat(13) == EABCSignature4(1, 0, 0, 0)  # E
        assert signature_from_nat(5) == EABCSignature4(0, 1, 0, 0)  # A
        assert signature_from_nat(7) == EABCSignature4(0, 0, 1, 0)  # B
        assert signature_from_nat(11) == EABCSignature4(0, 0, 0, 1)  # C

    def test_multiplicity_counts(self):
        assert signature_from_nat(169) == EABCSignature4(2, 0, 0, 0)  # 13^2
        assert signature_from_nat(539) == EABCSignature4(0, 0, 2, 1)  # 7^2 * 11

    def test_reference_n210(self):
        sig = signature_from_nat(210)
        assert sig == EABCSignature4(0, 1, 1, 0)
        assert eabc_mass(210) == 2

    def test_arbeitsprogramm_phase4_partitions(self):
        cases = [
            (13, (1, 0, 0, 0)),
            (169, (2, 0, 0, 0)),
            (65, (1, 1, 0, 0)),
            (2197, (3, 0, 0, 0)),
            (845, (2, 1, 0, 0)),
            (455, (1, 1, 1, 0)),
            (28561, (4, 0, 0, 0)),
            (10985, (3, 1, 0, 0)),  # 13^3 * 5
            (4225, (2, 2, 0, 0)),  # 13^2 * 5^2
            (5915, (2, 1, 1, 0)),  # 13^2 * 5 * 7
            (5005, (1, 1, 1, 1)),
        ]
        for n, partition in cases:
            sig = signature_from_nat(n)
            assert sig.sorted_counts() == partition
            assert eabc_mass(n) == sum(partition)

    def test_invalid_n_raises(self):
        with pytest.raises(ValueError, match="n must be >= 1"):
            signature_from_nat(0)
