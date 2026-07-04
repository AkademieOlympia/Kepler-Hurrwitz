"""Numerische W_N-Zyklen und Bockstein-Braiding auf Z_N x Z_N (Hsin & Chen).

[B] Toy Layer — algebraisch-topologischer Kontrollkern, keine physikalischen Claims.
Defensiver Hauptcheck: phase(W_N) in mu_N, d.h. phase(W_N)^N = 1 (wenn W_N zentral-skalar).
Nicht pauschal W_N^N = I als allgemeine Operatoridentitaet behaupten.
Siehe docs/bockstein_braiding_layer.md.
"""

from __future__ import annotations

import cmath
from dataclasses import dataclass
from collections.abc import Callable
from typing import Sequence

FluxSpec = int | Callable[[int, int], int]

try:
    import numpy as np
except ImportError:  # pragma: no cover
    np = None  # type: ignore[assignment]

TorusElement = tuple[int, int]


def torus_mul(a: TorusElement, b: TorusElement, n: int) -> TorusElement:
    return ((a[0] + b[0]) % n, (a[1] + b[1]) % n)


def torus_pow(element: TorusElement, exponent: int, n: int) -> TorusElement:
    return ((exponent * element[0]) % n, (exponent * element[1]) % n)


def torus_inv(element: TorusElement, n: int) -> TorusElement:
    return ((-element[0]) % n, (-element[1]) % n)


def w_n_torus(x: TorusElement, y: TorusElement, n: int) -> TorusElement:
    """W_N(X,Y) = (Y^{-1} X^{-1})^N (Y X)^N im kommutativen Torus Z_N x Z_N."""
    y_inv_x_inv = torus_mul(torus_inv(y, n), torus_inv(x, n), n)
    yx = torus_mul(y, x, n)
    return torus_mul(torus_pow(y_inv_x_inv, n, n), torus_pow(yx, n, n), n)


def heisenberg_matrices(n: int, flux: int = 1):
    """
    Magnetische Translationsalgebra: X = Shift, Y = Phasenoperator,
    XY X^{-1} Y^{-1} = zeta^{-flux} I mit zeta = exp(2 pi i / N).
    """
    if np is None:
        raise ImportError("numpy is required for heisenberg_matrices")
    zeta = cmath.exp(2j * cmath.pi / n)
    twist = zeta**flux
    x = np.zeros((n, n), dtype=np.complex128)
    y = np.zeros((n, n), dtype=np.complex128)
    for k in range(n):
        x[(k + 1) % n, k] = 1.0
        y[k, k] = twist**k
    identity = np.eye(n, dtype=np.complex128)
    return x, y, zeta, twist, identity


def w_n_matrix(x, y, n: int):
    """W_N(X,Y) = (Y^{-1} X^{-1})^N (Y X)^N fuer NxN-Matrizen."""
    if np is None:
        raise ImportError("numpy is required for w_n_matrix")
    y_inv_x_inv = np.linalg.matrix_power(y.conj().T @ x.conj().T, n)
    yx = np.linalg.matrix_power(y @ x, n)
    return y_inv_x_inv @ yx


def is_central_scalar(matrix, identity, tol: float = 1e-10) -> tuple[bool, complex | None]:
    """Prueft, ob matrix = lambda I (skalar-zentral)."""
    if np is None:
        raise ImportError("numpy is required for is_central_scalar")
    off_diag = matrix - np.diag(np.diag(matrix))
    if np.max(np.abs(off_diag)) > tol:
        return False, None
    diag = np.diag(matrix)
    if np.max(np.abs(diag - diag[0])) > tol:
        return False, None
    return True, complex(diag[0])


def matrices_allclose(a, b, tol: float = 1e-10) -> bool:
    if np is None:
        raise ImportError("numpy is required for matrices_allclose")
    return bool(np.allclose(a, b, atol=tol, rtol=tol))


def a_pq_default(p: int, q: int, n: int) -> int:
    """Standardprobe fuer raeumlich variierendes a(P,Q) = (P + 2Q) mod N."""
    return (p + 2 * q) % n


def k_plaquette(p: int, q: int, a: int, n: int) -> int:
    """Lokale Kommutatordichte K(P,Q;a) auf Z_N x Z_N (homogenes Modell)."""
    return (a * (p + q)) % n


def k_plaquette_variable(p: int, q: int, a_spec: FluxSpec, n: int) -> int:
    """
    Lokale Kommutatordichte K(P,Q) mit homogenem a (int) oder a(P,Q) (Callable).

    Homogen: K(P,Q;a) = a*(P+Q) mod N.
    Variabel: K(P,Q) = a(P,Q) mod N.
    """
    if callable(a_spec):
        return a_spec(p, q) % n
    return k_plaquette(p, q, a_spec, n)


def staircase_holonomy_mod_n(a_spec: FluxSpec, n: int) -> int:
    """
    Bockstein-Treppe (Hsin-Chen, Gl. 76): sum_{m=0}^{N-1} K(m,m) entlang (dX+dY).
    """
    return sum(k_plaquette_variable(m, m, a_spec, n) for m in range(n)) % n


def grid_holonomy_mod_n(a_spec: FluxSpec, n: int) -> int:
    """Summe aller Plaquette-Beitraege K(P,Q) ueber das N x N-Gitter, mod N."""
    return sum(
        k_plaquette_variable(p, q, a_spec, n) for p in range(n) for q in range(n)
    ) % n


def effective_flux_mod_n(a_spec: FluxSpec, n: int) -> int:
    """
    Effektiver Flux-Exponent fuer das homogene W_N-Vergleichsmodell.

    Homogenes a: der Parameter a selbst.
    Variabel: Bockstein-Treppen-Holonomie mod N.
    """
    if callable(a_spec):
        return staircase_holonomy_mod_n(a_spec, n)
    return a_spec % n


def w_n_phase_exponent_mod_n(n: int, flux: int, tol: float = 1e-10) -> int | None:
    """Exponent k mit W_N-Phase = zeta^k, falls W_N zentral-skalar."""
    x, y, zeta, _twist, identity = heisenberg_matrices(n, flux=flux % n)
    w = w_n_matrix(x, y, n)
    central, phase = is_central_scalar(w, identity, tol=tol)
    if not central or phase is None:
        return None
    best_k = 0
    best_dist = float("inf")
    for k in range(n):
        dist = abs(phase - zeta**k)
        if dist < best_dist:
            best_dist = dist
            best_k = k
    return best_k if best_dist < tol else None


def _phase_power_n_is_one(phase: complex | None, n: int, tol: float = 1e-10) -> bool:
    """Defensiver Check: phase(W_N) in mu_N, d.h. phase^N ≈ 1."""
    if phase is None:
        return False
    return abs(phase**n - 1.0) < tol


@dataclass(frozen=True)
class GroupRingVerification:
    n: int
    w_is_one: bool
    w_power_n_is_one: bool
    linearity: tuple[tuple[int, bool], ...]


@dataclass(frozen=True)
class HeisenbergVerification:
    n: int
    flux: int
    plaquette_commutator_ok: bool
    w_central: bool
    w_phase: complex | None
    phase_power_n_is_one: bool
    w_power_n_is_one: bool
    linearity: tuple[tuple[int, bool], ...]


@dataclass(frozen=True)
class Lattice2DDemo:
    n: int
    a: int
    flux: int
    k_sum_mod_n: int
    w_phase: complex | None
    phase_power_n_is_one: bool
    w_power_n_is_one: bool
    linearity_flux: bool


@dataclass(frozen=True)
class VariableFluxDemo:
    n: int
    staircase_holonomy_mod_n: int
    grid_holonomy_mod_n: int
    effective_flux: int
    w_phase: complex | None
    w_phase_exponent_mod_n: int | None
    phase_power_n_is_one: bool
    w_power_n_is_one: bool
    linearity_flux: bool
    hsin_chen_staircase_matches_w: bool


def verify_group_ring(n: int, alphas: Sequence[int] = (2, 3)) -> GroupRingVerification:
    """Im kommutativen Gruppenring ist W_N trivial (= 1)."""
    x = (1, 0)
    y = (0, 1)
    w = w_n_torus(x, y, n)
    one = (0, 0)
    lin = []
    for alpha in alphas:
        if alpha >= n:
            continue
        x_alpha = torus_pow(x, alpha, n)
        w_alpha = w_n_torus(x_alpha, y, n)
        w_pow = torus_pow(w, alpha, n)
        lin.append((alpha, w_alpha == w_pow))
    return GroupRingVerification(
        n=n,
        w_is_one=w == one,
        w_power_n_is_one=torus_pow(w, n, n) == one,
        linearity=tuple(lin),
    )


def verify_heisenberg(
    n: int,
    flux: int = 1,
    alphas: Sequence[int] = (2, 3),
    tol: float = 1e-10,
) -> HeisenbergVerification:
    """Nicht-kommutativer Torus: W_N zentral; phase(W_N) in mu_N; Linearitaet.

    w_power_n_is_one prueft numerisch W^N = I fuer die zentral-skalar Probe
    (Folgerung fuer Skalare), nicht als allgemeiner Operator-Claim formuliert.
    """
    x, y, _zeta, twist, identity = heisenberg_matrices(n, flux=flux)
    comm = x @ y @ np.linalg.inv(x) @ np.linalg.inv(y)
    ok_comm = matrices_allclose(comm, (twist.conjugate()) * identity, tol=tol)

    w = w_n_matrix(x, y, n)
    central, phase = is_central_scalar(w, identity, tol=tol)
    phase_ok = _phase_power_n_is_one(phase, n, tol=tol)
    np_ok = matrices_allclose(np.linalg.matrix_power(w, n), identity, tol=tol)

    lin = []
    for alpha in alphas:
        if alpha >= n:
            continue
        w_base = w_n_matrix(x, y, n)
        x_alpha = np.linalg.matrix_power(x, alpha)
        w_alpha = w_n_matrix(x_alpha, y, n)
        w_pow = np.linalg.matrix_power(w_base, alpha)
        lin.append((alpha, matrices_allclose(w_alpha, w_pow, tol=tol)))

    return HeisenbergVerification(
        n=n,
        flux=flux,
        plaquette_commutator_ok=ok_comm,
        w_central=central,
        w_phase=phase,
        phase_power_n_is_one=phase_ok,
        w_power_n_is_one=np_ok,
        linearity=tuple(lin),
    )


def lattice_2d_demo(
    n: int,
    a: int = 1,
    flux: int | None = None,
    tol: float = 1e-10,
) -> Lattice2DDemo:
    """2D-Plaquetten-Gitter: K(P,Q;a)-Summe und W_N-Holonomie."""
    if flux is None:
        flux = a
    x, y, _zeta, _twist, identity = heisenberg_matrices(n, flux=flux)

    k_sum = sum(k_plaquette(p, q, a, n) for p in range(n) for q in range(n))
    k_sum_mod = k_sum % n

    w = w_n_matrix(x, y, n)
    _central, phase = is_central_scalar(w, identity, tol=tol)

    x2, y2, _, _, _ = heisenberg_matrices(n, flux=2 * flux)
    w_a2 = w_n_matrix(x2, y2, n)
    _central2, phase_a2 = is_central_scalar(w_a2, identity, tol=tol)

    lin_flux = False
    if phase is not None and phase_a2 is not None:
        lin_flux = abs(phase_a2 - phase**2) < tol

    return Lattice2DDemo(
        n=n,
        a=a,
        flux=flux,
        k_sum_mod_n=k_sum_mod,
        w_phase=phase,
        phase_power_n_is_one=_phase_power_n_is_one(phase, n, tol=tol),
        w_power_n_is_one=matrices_allclose(np.linalg.matrix_power(w, n), identity, tol=tol),
        linearity_flux=lin_flux,
    )


def lattice_2d_variable_demo(
    n: int,
    a_spec: FluxSpec,
    tol: float = 1e-10,
) -> VariableFluxDemo:
    """
    2D-Gitter mit raeumlich variierendem a(P,Q): Vergleich lokaler Treppe vs. globales W_N.

    Die Bockstein-Treppe (Summe entlang m*(dX+dY)) ist die relevante lokale Holonomie
    im Hsin-Chen-Muster; die volle Gitter-Summe kann trotz nontrivialer Statistik
    mod N verschwinden (Fluss-Kompensation).
    """
    stair = staircase_holonomy_mod_n(a_spec, n)
    grid = grid_holonomy_mod_n(a_spec, n)
    eff_flux = effective_flux_mod_n(a_spec, n)

    x, y, _zeta, _twist, identity = heisenberg_matrices(n, flux=eff_flux)
    w = w_n_matrix(x, y, n)
    _central, phase = is_central_scalar(w, identity, tol=tol)
    w_exp = w_n_phase_exponent_mod_n(n, eff_flux, tol=tol)

    x2, y2, _, _, _ = heisenberg_matrices(n, flux=(2 * eff_flux) % n)
    w_a2 = w_n_matrix(x2, y2, n)
    _central2, phase_a2 = is_central_scalar(w_a2, identity, tol=tol)

    lin_flux = False
    if phase is not None and phase_a2 is not None:
        lin_flux = abs(phase_a2 - phase**2) < tol

    matches_w = w_exp is not None and stair == w_exp

    return VariableFluxDemo(
        n=n,
        staircase_holonomy_mod_n=stair,
        grid_holonomy_mod_n=grid,
        effective_flux=eff_flux,
        w_phase=phase,
        w_phase_exponent_mod_n=w_exp,
        phase_power_n_is_one=_phase_power_n_is_one(phase, n, tol=tol),
        w_power_n_is_one=matrices_allclose(np.linalg.matrix_power(w, n), identity, tol=tol),
        linearity_flux=lin_flux,
        hsin_chen_staircase_matches_w=matches_w,
    )
