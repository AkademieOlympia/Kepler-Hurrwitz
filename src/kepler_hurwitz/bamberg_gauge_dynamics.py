"""
[B/C] Bamberg topologische Eichdynamik — Baustein 3.1.

Numerische Audits fuer ladungsabhaengige Plakettenholonomie, Eichinvarianz von
Tr(D_X(A)^2) und Klein-F-Asymptotik (1-cos(qF))/F^2 -> q^2/2.

Lean: KeplerHurwitz/BambergGaugeCovariance.lean
Protokoll: docs/energiedoku_exports/bamberg_gauge_dynamics_protocol.md (E-111)

Governance:
  [C] theoretische Herleitung (Manuskript)
  [B] lokale numerische Pruefung
  Nicht beansprucht: g_eff, alpha_eff, physikalische Eichkopplungsstaerke
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Any

import numpy as np

from kepler_hurwitz.erpc_233_hamiltonian import (
    NORB,
    IntChargeConfig,
    build_d_int,
    build_internal_gauge_matrix,
    random_d_int_blocks,
)

GOVERNANCE_DYNAMICS = "[B/C]"

NUM_VERTICES = 4
EDGE_NAMES = ("one_p", "p_pq", "q_pq", "one_q")
EDGE_SOURCES = (0, 1, 2, 0)  # 1, p, q, 1
EDGE_TARGETS = (1, 3, 3, 2)  # p, pq, pq, q
EDGE_SIGNS = (1, 1, -1, -1)


@dataclass(frozen=True)
class PlaquetteConnection:
    """Kantenverbindungen a_e auf dem minimalen Quadratkomplex."""

    one_p: float = 0.0
    p_pq: float = 0.0
    q_pq: float = 0.0
    one_q: float = 0.0

    def as_vector(self) -> np.ndarray:
        return np.array([self.one_p, self.p_pq, self.q_pq, self.one_q], dtype=float)

    @property
    def flux(self) -> float:
        """F_f = a_1p + a_p,pq - a_q,pq - a_1q."""
        return float(
            EDGE_SIGNS[0] * self.one_p
            + EDGE_SIGNS[1] * self.p_pq
            + EDGE_SIGNS[2] * self.q_pq
            + EDGE_SIGNS[3] * self.one_q
        )


@dataclass(frozen=True)
class VertexGauge:
    """Lokale Eichphasen theta_v an den vier Vertices."""

    one: float = 0.0
    p: float = 0.0
    q: float = 0.0
    pq: float = 0.0

    def as_vector(self) -> np.ndarray:
        return np.array([self.one, self.p, self.q, self.pq], dtype=float)


def sector_charges(q: IntChargeConfig) -> tuple[int, ...]:
    """Aktive Ladungseigenwerte (ohne Duplikate)."""
    values = {q.q_ea, q.q_b, q.q_c}
    return tuple(sorted(values))


def plaquette_holonomy_phase(q: int, connection: PlaquetteConnection) -> complex:
    """exp(i q F_f) auf einem Ladungssektor."""
    return complex(math.cos(q * connection.flux), math.sin(q * connection.flux))


def gauged_edge_phase(
    q: int,
    edge_idx: int,
    connection: PlaquetteConnection,
    gauge: VertexGauge,
) -> complex:
    """U_e^g = g_source exp(i q a_e) g_target^{-1} auf einem Ladungssektor."""
    a = connection.as_vector()[edge_idx]
    src = EDGE_SOURCES[edge_idx]
    tgt = EDGE_TARGETS[edge_idx]
    theta = gauge.as_vector()
    return (
        complex(math.cos(q * theta[src]), math.sin(q * theta[src]))
        * complex(math.cos(q * a), math.sin(q * a))
        / complex(math.cos(q * theta[tgt]), math.sin(q * theta[tgt]))
    )


def plaquette_holonomy_gauged(
    q: int,
    connection: PlaquetteConnection,
    gauge: VertexGauge,
) -> complex:
    """Produkt der gauged Kantenlinks entlang des Plakettenrandes."""
    phases = [gauged_edge_phase(q, i, connection, gauge) for i in range(4)]
    return phases[0] * phases[1] / phases[2] / phases[3]


def klein_f_curvature_response(q: int, flux: float) -> float:
    """(1 - cos(qF)) / F^2 mit Limes q^2/2 bei F=0."""
    if abs(flux) < 1e-15:
        return 0.5 * q * q
    qf = q * flux
    return (1.0 - math.cos(qf)) / (flux * flux)


def build_incidence_matrix() -> np.ndarray:
    """Untwisted Ko-Rand d_0: C^4 -> C^4 (4 Kanten)."""
    d0 = np.zeros((4, NUM_VERTICES), dtype=complex)
    for e, (src, tgt) in enumerate(zip(EDGE_SOURCES, EDGE_TARGETS, strict=True)):
        d0[e, tgt] = 1.0
        d0[e, src] = -1.0
    return d0


def build_gauge_edge_operators(
    connection: PlaquetteConnection,
    q: IntChargeConfig,
    gauge: VertexGauge | None = None,
) -> list[np.ndarray]:
    """
    Kanten-Linkoperatoren U_e auf H_int fuer jede Kante.

    Ohne Gauge: U_e = exp(i a_e Q).
    Mit Gauge: U_e^g = g_source U_e g_target^{-1}.
    """
    a = connection.as_vector()
    theta = np.zeros(NUM_VERTICES) if gauge is None else gauge.as_vector()
    ops: list[np.ndarray] = []
    for e, (src, tgt) in enumerate(zip(EDGE_SOURCES, EDGE_TARGETS, strict=True)):
        u_edge = build_internal_gauge_matrix(a[e], q)
        if gauge is not None:
            g_src = build_internal_gauge_matrix(theta[src], q)
            g_tgt = build_internal_gauge_matrix(theta[tgt], q)
            u_edge = g_src @ u_edge @ np.linalg.inv(g_tgt)
        ops.append(u_edge)
    return ops


def build_twisted_coboundary(
    connection: PlaquetteConnection,
    q: IntChargeConfig,
    gauge: VertexGauge | None = None,
) -> np.ndarray:
    """Getwisteter Ko-Rand d_A auf C^4 ⊗ C^8 (4*8 = 32)."""
    d0 = build_incidence_matrix()
    edge_ops = build_gauge_edge_operators(connection, q, gauge)
    dim = NUM_VERTICES * NORB
    d_a = np.zeros((4 * NORB, dim), dtype=complex)
    for e, (src, tgt) in enumerate(zip(EDGE_SOURCES, EDGE_TARGETS, strict=True)):
        row = slice(e * NORB, (e + 1) * NORB)
        col_src = slice(src * NORB, (src + 1) * NORB)
        col_tgt = slice(tgt * NORB, (tgt + 1) * NORB)
        d_a[row, col_src] = -np.eye(NORB)
        d_a[row, col_tgt] = edge_ops[e]
    return d_a


def build_d_geom(
    connection: PlaquetteConnection,
    q: IntChargeConfig,
    gauge: VertexGauge | None = None,
) -> np.ndarray:
    """D_geom(A) = d_A + d_A^dagger auf dem 0-Kettenraum (dim 32)."""
    d_a = build_twisted_coboundary(connection, q, gauge)
    return d_a + d_a.conj().T


def build_d_x(
    connection: PlaquetteConnection,
    q: IntChargeConfig,
    d_int: np.ndarray,
    gauge: VertexGauge | None = None,
) -> np.ndarray:
    """D_X(A) = D_geom(A) + I_4 ⊗ D_int (dim 32)."""
    d_geom = build_d_geom(connection, q, gauge)
    d_int_lift = np.kron(np.eye(NUM_VERTICES), d_int)
    return d_geom + d_int_lift


def trace_d_x_squared(
    connection: PlaquetteConnection,
    q: IntChargeConfig,
    d_int: np.ndarray,
    gauge: VertexGauge | None = None,
) -> float:
    """Tr(D_X(A)^2) — Strukturobservable, keine Naturkopplung."""
    d_x = build_d_x(connection, q, d_int, gauge)
    return float(np.real(np.trace(d_x @ d_x)))


def curvature_coefficient_from_trace(
    q: IntChargeConfig,
    d_int: np.ndarray,
    *,
    flux: float = 0.1,
    fd_step: float = 1e-4,
) -> dict[int, float]:
    """
    Numerische ∂²/∂F² Tr(D_X^2) via zentrale Differenz auf F_f.

    Isoliert die quadratische Ladungsantwort pro Ladungseigenwert (Sektor-Split).
    """
    base = PlaquetteConnection(one_p=0.0, p_pq=0.0, q_pq=0.0, one_q=0.0)
    out: dict[int, float] = {}
    for charge in sector_charges(q):
        q_single = IntChargeConfig(charge, charge, charge)
        def trace_at(f_val: float) -> float:
            conn = PlaquetteConnection(
                one_p=f_val,
                p_pq=0.0,
                q_pq=0.0,
                one_q=0.0,
            )
            return trace_d_x_squared(conn, q_single, d_int)

        f_plus = trace_at(flux + fd_step)
        f_minus = trace_at(flux - fd_step)
        f_center = trace_at(flux)
        second_deriv = (f_plus - 2.0 * f_center + f_minus) / (fd_step * fd_step)
        out[charge] = second_deriv
    return out


@dataclass
class GaugeDynamicsAuditResult:
    """Ergebnis eines Baustein-3.1-Audits."""

    holonomy_invariant: bool
    max_holonomy_defect: float
    trace_gauge_invariant: bool
    max_trace_defect: float
    klein_f_passed: bool
    max_klein_f_error: float
    charge: IntChargeConfig
    seed: int = 0
    details: dict[str, Any] = field(default_factory=dict)

    @property
    def passed(self) -> bool:
        return self.holonomy_invariant and self.trace_gauge_invariant and self.klein_f_passed


def audit_klein_f_asymptotics(
    charges: tuple[int, ...] = (-2, -1, 0, 1, 2),
    flux_values: tuple[float, ...] = (1e-3, 5e-4, 2e-4, 1e-4),
    *,
    rtol: float = 1e-3,
) -> dict[str, Any]:
    """
    Prueft (1-cos(qF))/F^2 -> q^2/2 fuer kleine F.

    Bestaetigt die geometrische Klein-F-Asymptotik — keine physikalische Kopplungsstaerke.
    """
    errors: dict[str, float] = {}
    for q in charges:
        target = 0.5 * q * q
        for f_val in flux_values:
            observed = klein_f_curvature_response(q, f_val)
            rel = abs(observed - target) / max(abs(target), 1e-15)
            errors[f"q={q},F={f_val}"] = rel
    max_error = max(errors.values()) if errors else 0.0
    return {
        "errors": errors,
        "max_error": max_error,
        "passed": max_error <= rtol,
    }


def audit_plaquette_holonomy_invariance(
    q: IntChargeConfig,
    connection: PlaquetteConnection,
    gauge: VertexGauge,
    *,
    atol: float = 1e-12,
) -> dict[str, Any]:
    """U_f^g = U_f auf allen Ladungseigenwerten."""
    defects: dict[int, float] = {}
    for charge in sector_charges(q):
        raw = plaquette_holonomy_phase(charge, connection)
        gauged = plaquette_holonomy_gauged(charge, connection, gauge)
        defects[charge] = abs(gauged - raw)
    max_defect = max(defects.values()) if defects else 0.0
    return {
        "defects": defects,
        "max_defect": max_defect,
        "passed": max_defect <= atol,
    }


def build_vertex_gauge_matrix(gauge: VertexGauge, q: IntChargeConfig) -> np.ndarray:
    """Globale Vertex-Eichtransformation G_g = diag(g_v) auf C^4 ⊗ C^8."""
    blocks = [build_internal_gauge_matrix(float(theta), q) for theta in gauge.as_vector()]
    return np.block([[blocks[i] if i == j else np.zeros((NORB, NORB), dtype=complex)
                      for j in range(NUM_VERTICES)] for i in range(NUM_VERTICES)])


def build_d_x_gauge_similarity(
    connection: PlaquetteConnection,
    q: IntChargeConfig,
    d_int: np.ndarray,
    gauge: VertexGauge,
) -> np.ndarray:
    """D_X(A^g) = G_g D_X(A) G_g^{-1} (unitäre Eichkovarianz)."""
    d_x = build_d_x(connection, q, d_int, None)
    g = build_vertex_gauge_matrix(gauge, q)
    g_inv = np.linalg.inv(g)
    return g @ d_x @ g_inv


def audit_trace_gauge_invariance(
    connection: PlaquetteConnection,
    q: IntChargeConfig,
    d_int: np.ndarray,
    gauge: VertexGauge,
    *,
    rtol: float = 1e-10,
) -> dict[str, Any]:
    """Tr(D_X(A^g)^2) = Tr(D_X(A)^2) via unitärer Ähnlichkeit."""
    tr_base = trace_d_x_squared(connection, q, d_int, None)
    d_x_g = build_d_x_gauge_similarity(connection, q, d_int, gauge)
    tr_gauged = float(np.real(np.trace(d_x_g @ d_x_g)))
    rel = abs(tr_gauged - tr_base) / max(abs(tr_base), 1e-15)
    return {
        "trace_base": tr_base,
        "trace_gauged": tr_gauged,
        "relative_defect": rel,
        "passed": rel <= rtol,
    }


def run_gauge_dynamics_audit(
    q: IntChargeConfig | None = None,
    *,
    seed: int = 0,
    connection: PlaquetteConnection | None = None,
    gauge: VertexGauge | None = None,
) -> GaugeDynamicsAuditResult:
    """Vollstaendiger Baustein-3.1-Audit fuer eine Ladungskonfiguration."""
    q = q or IntChargeConfig(1, 1, -2)
    connection = connection or PlaquetteConnection(
        one_p=0.15, p_pq=0.08, q_pq=0.05, one_q=0.03
    )
    gauge = gauge or VertexGauge(one=0.2, p=-0.4, q=0.7, pq=-0.1)

    rng = np.random.default_rng(seed)
    blocks = random_d_int_blocks(q, rng)
    d_int = build_d_int(**blocks)

    hol = audit_plaquette_holonomy_invariance(q, connection, gauge)
    trace = audit_trace_gauge_invariance(connection, q, d_int, gauge)
    klein = audit_klein_f_asymptotics()

    return GaugeDynamicsAuditResult(
        holonomy_invariant=bool(hol["passed"]),
        max_holonomy_defect=float(hol["max_defect"]),
        trace_gauge_invariant=bool(trace["passed"]),
        max_trace_defect=float(trace["relative_defect"]),
        klein_f_passed=bool(klein["passed"]),
        max_klein_f_error=float(klein["max_error"]),
        charge=q,
        seed=seed,
        details={"holonomy": hol, "trace": trace, "klein_f": klein},
    )
