"""Tests für Baustein 3.1 — Bamberg topologische Eichdynamik."""

import numpy as np

from kepler_hurwitz.bamberg_gauge_dynamics import (
    PlaquetteConnection,
    VertexGauge,
    audit_klein_f_asymptotics,
    audit_plaquette_holonomy_invariance,
    audit_trace_gauge_invariance,
    build_d_geom,
    klein_f_curvature_response,
    plaquette_holonomy_gauged,
    plaquette_holonomy_phase,
    run_gauge_dynamics_audit,
)
from kepler_hurwitz.erpc_233_hamiltonian import IntChargeConfig, build_d_int, random_d_int_blocks


def test_plaquette_flux_standard_form():
    conn = PlaquetteConnection(one_p=0.1, p_pq=0.2, q_pq=0.05, one_q=0.03)
    assert conn.flux == conn.one_p + conn.p_pq - conn.q_pq - conn.one_q


def test_plaquette_holonomy_gauge_invariant():
    q = IntChargeConfig(1, 1, -2)
    conn = PlaquetteConnection(one_p=0.15, p_pq=0.08, q_pq=0.05, one_q=0.03)
    gauge = VertexGauge(one=0.2, p=-0.4, q=0.7, pq=-0.1)
    audit = audit_plaquette_holonomy_invariance(q, conn, gauge)
    assert audit["passed"]
    assert audit["max_defect"] <= 1e-12


def test_klein_f_asymptotic_to_q_squared_over_two():
    audit = audit_klein_f_asymptotics()
    assert audit["passed"]
    for q in (-2, -1, 0, 1, 2):
        for f_val in (1e-3, 5e-4):
            observed = klein_f_curvature_response(q, f_val)
            target = 0.5 * q * q
            rel = abs(observed - target) / max(abs(target), 1e-15)
            assert rel <= 1e-3


def test_klein_f_at_zero():
    for q in (-3, 0, 4):
        assert klein_f_curvature_response(q, 0.0) == 0.5 * q * q


def test_trace_gauge_invariance():
    q = IntChargeConfig(1, 1, -2)
    conn = PlaquetteConnection(one_p=0.12, p_pq=0.06, q_pq=0.04, one_q=0.02)
    gauge = VertexGauge(one=0.3, p=0.1, q=-0.2, pq=0.5)
    rng = np.random.default_rng(0)
    d_int = build_d_int(**random_d_int_blocks(q, rng))
    audit = audit_trace_gauge_invariance(conn, q, d_int, gauge)
    assert audit["passed"]


def test_d_geom_hermitian():
    q = IntChargeConfig.neutral()
    conn = PlaquetteConnection(one_p=0.1, p_pq=0.0, q_pq=0.0, one_q=0.0)
    d_geom = build_d_geom(conn, q)
    defect = np.linalg.norm(d_geom - d_geom.conj().T, ord="fro")
    assert defect <= 1e-12


def test_run_gauge_dynamics_audit_passes():
    result = run_gauge_dynamics_audit(IntChargeConfig(1, 1, -2), seed=42)
    assert result.passed
    assert result.holonomy_invariant
    assert result.trace_gauge_invariant
    assert result.klein_f_passed


def test_neutral_holonomy_phase_is_one_at_zero_flux():
    conn = PlaquetteConnection()
    for charge in (0, 1, -1):
        phase = plaquette_holonomy_phase(charge, conn)
        assert abs(phase - 1.0) <= 1e-15
        gauged = plaquette_holonomy_gauged(charge, conn, VertexGauge(one=0.5, p=-0.3, q=0.2, pq=0.7))
        assert abs(gauged - 1.0) <= 1e-12
