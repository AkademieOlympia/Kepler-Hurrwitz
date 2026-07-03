from kepler_hurwitz.primvierling import (
    analyze_primvierling,
    analyze_range,
    default_observables,
    generate_prime_quadruplets,
    orbit_under_ceab,
    quat_norm,
    quat_reduced_norm,
    symmetry_shift_ceab,
)


def test_symmetry_shift_ceab():
    assert symmetry_shift_ceab((11, 13, 17, 19)) == (17, 19, 11, 13)


def test_orbit_under_ceab_has_two_states():
    orbit = orbit_under_ceab((11, 13, 17, 19))
    assert orbit == ((11, 13, 17, 19), (17, 19, 11, 13))


def test_generate_prime_quadruplets_contains_classic_case():
    quadruplets = generate_prime_quadruplets(3, 50)
    assert (11, 13, 17, 19) in quadruplets


def test_analyze_primvierling_default_observables_invariant():
    analysis = analyze_primvierling((11, 13, 17, 19))
    assert all(result.is_invariant for result in analysis.invariants)


def test_default_observables_include_reduced_norm():
    observables = default_observables()
    assert "quat_reduced_norm" in observables


def test_quaternion_norms_agree_without_sage_dependency():
    v = (11, 13, 17, 19)
    assert quat_reduced_norm(v) == quat_norm(v)


def test_analyze_primvierling_detects_non_invariant_observable():
    analysis = analyze_primvierling(
        (11, 13, 17, 19),
        observables={"first_component": lambda t: t[0]},
    )
    assert analysis.invariants[0].is_invariant is False


def test_analyze_range_returns_analyses_for_range():
    analyses = analyze_range(3, 50)
    assert len(analyses) >= 1
    assert analyses[0].base[0] >= 3
