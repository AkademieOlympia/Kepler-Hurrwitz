from kepler_hurwitz.kepler import KeplerInvariants, kepler_invariants
from kepler_hurwitz.signatures import HurwitzSignature8D


def basic_signature_example() -> HurwitzSignature8D:
    return HurwitzSignature8D(1, 0, 1, 0, 1, 0, 1, 0)


def basic_kepler_example() -> KeplerInvariants:
    return kepler_invariants(2 / 3)
