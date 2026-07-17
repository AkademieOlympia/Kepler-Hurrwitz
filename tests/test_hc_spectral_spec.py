"""
Normative validation of specs/hc_spectral_stability_spec.json.

Uses fractions.Fraction for exact rational arithmetic — no float drift
in the A/B algebraic layer before any numerical freeze run.
"""

from __future__ import annotations

import json
from fractions import Fraction
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
SPEC_PATH = ROOT / "specs" / "hc_spectral_stability_spec.json"


def _F(x) -> Fraction:
    return Fraction(str(x))


def load_spec() -> dict:
    with SPEC_PATH.open(encoding="utf-8") as f:
        return json.load(f)


def matrix_from_spec(rows) -> list[list[Fraction]]:
    return [[_F(entry) for entry in row] for row in rows]


def mat_add(A, B):
    return [
        [A[i][j] + B[i][j] for j in range(len(A[0]))]
        for i in range(len(A))
    ]


def mat_scale(A, s: Fraction):
    return [[s * A[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def mat_transpose(A):
    n, m = len(A), len(A[0])
    return [[A[j][i] for j in range(n)] for i in range(m)]


def is_hermitian(A) -> bool:
    return A == mat_transpose(A)


def mat_vec(A, v):
    return [sum(A[i][j] * v[j] for j in range(len(v))) for i in range(len(A))]


def dot(u, v) -> Fraction:
    return sum(u[i] * v[i] for i in range(len(u)))


def rayleigh(A, u) -> Fraction:
    return dot(u, mat_vec(A, u)) / dot(u, u)


def trace(A) -> Fraction:
    return sum(A[i][i] for i in range(len(A)))


@pytest.fixture(scope="module")
def spec():
    assert SPEC_PATH.is_file(), f"missing normative spec: {SPEC_PATH}"
    return load_spec()


@pytest.fixture(scope="module")
def matrices(spec):
    return {key: matrix_from_spec(rows) for key, rows in spec["matrices"].items()}


def test_schema_version_and_basis_order(spec):
    assert spec["schema_version"] == 1
    assert spec["governance"]["basis_order"] == [
        "rest_0",
        "channel_5",
        "channel_11",
        "rest_3",
    ]


def test_all_declared_matrices_hermitian(spec, matrices):
    for key in spec["analytical_checks"]["hermitian_keys"]:
        assert is_hermitian(matrices[key]), f"{key} not Hermitian over Q"


def test_L_C4_row_sums_zero(matrices):
    L = matrices["L_C4"]
    for i, row in enumerate(L):
        assert sum(row, Fraction(0)) == 0, f"L_C4 row {i} sum != 0"


def test_V_support(spec, matrices):
    V = matrices["V"]
    support = {tuple(pair) for pair in spec["analytical_checks"]["V_support"]}
    n = len(V)
    for i in range(n):
        for j in range(n):
            if V[i][j] != 0:
                assert (i, j) in support, f"unexpected V support at {(i, j)}"


def test_traces(spec, matrices):
    exp = spec["analytical_checks"]["expected"]
    assert trace(matrices["L_C4"]) == _F(exp["trace_L_C4"])
    assert trace(matrices["V"]) == _F(exp["trace_V"])


def test_bamberg_mode_rayleigh_identities(spec, matrices):
    mode = [_F(x) for x in spec["analytical_checks"]["bamberg_mode"]]
    exp = spec["analytical_checks"]["expected"]
    L = matrices["L_C4"]
    V = matrices["V"]
    H = mat_add(L, V)

    assert rayleigh(V, mode) == _F(exp["rayleigh_V_on_mode_e1_minus_e2"])
    assert rayleigh(L, mode) == _F(exp["rayleigh_L_C4_on_mode_e1_minus_e2"])
    assert rayleigh(H, mode) == _F(exp["rayleigh_H_LC4_V_on_mode_e1_minus_e2"])


def test_noise_classes_are_hermitian(matrices):
    for key in ("N_II_edge", "N_II_diag", "N_II_channel"):
        assert is_hermitian(matrices[key])


def test_N_II_channel_matches_V_support(matrices):
    """Channel-mimic noise uses the same support as normative V."""
    V = matrices["V"]
    N = matrices["N_II_channel"]
    n = len(V)
    for i in range(n):
        for j in range(n):
            if V[i][j] == 0:
                assert N[i][j] == 0
            else:
                assert N[i][j] != 0


def test_alpha_eps_perturbation_stays_rational(matrices):
    """L_C4 + ε N remains in Q for rational ε (freeze scaffolding)."""
    eps = Fraction(1, 1000)
    for key in ("N_II_edge", "N_II_diag", "N_II_channel"):
        H = mat_add(matrices["L_C4"], mat_scale(matrices[key], eps))
        assert is_hermitian(H)
        for row in H:
            for x in row:
                assert isinstance(x, Fraction)
