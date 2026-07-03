from kepler_hurwitz.smoothness_channel_scan import odd_core


def _is_klein_class(mod8: int) -> bool:
    return mod8 in {1, 3, 5, 7}


def test_collapse_maps_to_klein_four_classes():
    collapsed_mod8 = {odd_core(n) % 8 for n in range(1, 2000)}
    assert collapsed_mod8.issubset({1, 3, 5, 7})
    assert collapsed_mod8 == {1, 3, 5, 7}


def test_klein_class_invariant_under_pow_two_shell():
    odd_seeds = [m for m in range(1, 200, 2)]
    for m in odd_seeds:
        base_class = m % 8
        assert _is_klein_class(base_class)
        for k in range(0, 12):
            n = (2**k) * m
            assert odd_core(n) == m
            assert odd_core(n) % 8 == base_class
