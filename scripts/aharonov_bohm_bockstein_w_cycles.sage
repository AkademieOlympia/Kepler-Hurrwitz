#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
Symbolische W_N-Zyklen fuer Aharonov-Bohm / Bockstein-Braiding auf Z_N x Z_N.

[B] Toy Layer — kein physikalischer Claim. Defensiv: phase(W_N) in mu_N,
d.h. phase(W_N)^N = 1; nicht pauschal W_N^N = I als Operatoridentitaet.
Siehe docs/bockstein_braiding_layer.md und scripts/bockstein_braiding_symbolic.sage.

Geschlossene unitaere Sequenz:
    W_N(X, Y) = (Y^{-1} X^{-1})^N (Y X)^N

Modi:
    verify      Standard: Gruppenring + Heisenberg-Torus, N-Potenz, Linearitaet
    group_ring  Nur Z[A,B]/(A^N-1, B^N-1)
    heisenberg  Magnetische Translationsalgebra (HV = zeta VH)
    lattice_2d  2D-Gitter mit lokaler Kommutatordichte K(P,Q;a)

Ausfuehrung:
    sage scripts/aharonov_bohm_bockstein_w_cycles.sage
    sage scripts/aharonov_bohm_bockstein_w_cycles.sage lattice_2d
"""

from sage.all import *
import sys


def torus_group_ring(N, base=ZZ):
    """Gruppenring Z[A,B]/(A^N-1, B^N-1) ~ Z[Z_N x Z_N]."""
    G = AbelianGroup([N, N])
    R = G.algebra(base)
    A = R.monomial(G.gens()[0])
    B = R.monomial(G.gens()[1])
    return R, A, B


def W_N_element(X, Y, N):
    """W_N(X,Y) = (Y^{-1} X^{-1})^N (Y X)^N."""
    return (Y**(-1) * X**(-1))**N * (Y * X)**N


def heisenberg_matrices(N, flux=1):
    """
    Magnetische Translationsalgebra auf Z_N:
    X = horizontaler Shift, Y = Phasenoperator mit XY = zeta^flux YX.
    """
    K = CyclotomicField(N)
    zeta = K.gen()
    twist = zeta**flux
    MS = MatrixSpace(K, N, N)
    I = MS.identity_matrix()
    X = MS([[1 if j == (i - 1) % N else 0 for j in range(N)] for i in range(N)])
    Y = MS.diagonal_matrix([twist**k for k in range(N)])
    return MS, X, Y, zeta, twist, I


def is_central_scalar(M, I, tol=1e-12):
    """Prueft, ob M = lambda I (skalar-zentral)."""
    if M != M.parent()(M[0, 0]) * I:
        return False, None
    return True, M[0, 0]


def verify_group_ring(N, alphas=(2, 3)):
    """Im kommutativen Gruppenring ist W_N trivial (= 1)."""
    R, A, B = torus_group_ring(N)
    one = R.one()
    W = W_N_element(A, B, N)
    lin = []
    for alpha in alphas:
        if alpha >= N:
            continue
        Wa = W_N_element(A**alpha, B, N)
        lin.append((alpha, Wa == W**alpha))
    return {
        "N": N,
        "W": W,
        "W_is_one": W == one,
        "W_power_N_is_one": W**N == one,
        "linearity": lin,
    }


def verify_heisenberg(N, flux=1, alphas=(2, 3), tol=1e-12):
    """Nicht-kommutativer Torus: W_N zentral; phase(W_N) in mu_N; Linearitaet.

    Hauptcheck: phase(W_N)^N = 1. W_power_N_is_one ist nur numerischer Skalar-Folgecheck.
    """
    MS, X, Y, zeta, twist, I = heisenberg_matrices(N, flux=flux)
    # Kommutator einer Plaquette: XY X^{-1} Y^{-1} = twist^{-1} I
    comm = X * Y * X.inverse() * Y.inverse()
    holonomy = twist**(-1)
    ok_comm = comm == holonomy * I

    W = W_N_element(X, Y, N)
    central, phase = is_central_scalar(W, I)
    phase_power_n_is_one = phase is not None and abs(phase**N - 1) < tol
    w_power_n_is_identity = central and W**N == I

    lin = []
    for alpha in alphas:
        if alpha >= N:
            continue
        W_base = W_N_element(X, Y, N)
        W_alpha = W_N_element(X**alpha, Y, N)
        lin.append((alpha, W_alpha == W_base**alpha))

    return {
        "N": N,
        "flux": flux,
        "plaquette_commutator_ok": ok_comm,
        "plaquette_holonomy": holonomy,
        "W_central": central,
        "W_phase": phase,
        "phase_power_N_is_one": phase_power_n_is_one,
        "W_power_N_is_one": w_power_n_is_identity,
        "quantization_ok": central and phase_power_n_is_one,
        "linearity": lin,
    }


def K_plaquette(P, Q, a, N):
    """
    Lokale Kommutatordichte K(P,Q;a) auf Z_N x Z_N (homogenes Modell).

    Fuer Bockstein-Braiding mit Parameter a: jede Plaquette traegt denselben
    Flux-Exponenten a; raeumliche Variation ist hier P+Q mod N als Probe.
    """
    return Integer((a * (P + Q)) % N)


def K_plaquette_variable(P, Q, a_spec, N):
    """K(P,Q) mit homogenem a (int) oder raeumlich variierendem a(P,Q) (Callable)."""
    if callable(a_spec):
        return Integer(a_spec(P, Q) % N)
    return K_plaquette(P, Q, a_spec, N)


def a_PQ_default(P, Q, N):
    """Standardprobe a(P,Q) = (P + 2Q) mod N."""
    return Integer((P + 2 * Q) % N)


def staircase_holonomy_mod_N(a_spec, N):
    """Bockstein-Treppe: sum_{m=0}^{N-1} K(m,m) mod N (Hsin-Chen, Gl. 76)."""
    return Integer(sum(K_plaquette_variable(m, m, a_spec, N) for m in range(N)) % N)


def grid_holonomy_mod_N(a_spec, N):
    """Summe aller Plaquette-Beitraege mod N."""
    return Integer(
        sum(K_plaquette_variable(P, Q, a_spec, N) for P in range(N) for Q in range(N)) % N
    )


def lattice_2d_variable_demo(N, a_spec, tol=1e-12):
    """Vergleich Bockstein-Treppe vs. Gitter-Summe vs. globales W_N."""
    stair = staircase_holonomy_mod_N(a_spec, N)
    grid = grid_holonomy_mod_N(a_spec, N)
    eff_flux = Integer(a_spec if not callable(a_spec) else stair)

    MS, X, Y, zeta, twist, I = heisenberg_matrices(N, flux=int(eff_flux))
    W = W_N_element(X, Y, N)
    central, phase = is_central_scalar(W, I)
    phase_power_n_is_one = phase is not None and abs(phase**N - 1) < tol
    w_power_n_is_identity = central and W**N == I

    W_a2 = W_N_element(*heisenberg_matrices(N, flux=int(2 * eff_flux % N))[1:3], N)
    _, phase_a2 = is_central_scalar(W_a2, I)

    return {
        "N": N,
        "staircase_holonomy_mod_N": stair,
        "grid_holonomy_mod_N": grid,
        "effective_flux": eff_flux,
        "W_phase": phase,
        "W_central": central,
        "phase_power_N_is_one": phase_power_n_is_one,
        "W_power_N_is_one": w_power_n_is_identity,
        "quantization_ok": central and phase_power_n_is_one,
        "linearity_flux": phase_a2 == phase**2 if phase is not None else False,
    }


def lattice_2d_demo(N, a=1, flux=None, tol=1e-12):
    """
    2D-Gitter: Summe der lokalen K(P,Q;a) ueber ein N x N Plaquetten-Gitter.

    Die effektive Holonomie eines contractible W_N-Zyklus wird mit der
    magnetischen Translationsalgebra verglichen.
    """
    if flux is None:
        flux = a
    MS, X, Y, zeta, twist, I = heisenberg_matrices(N, flux=flux)

    K_sum = sum(K_plaquette(P, Q, a, N) for P in range(N) for Q in range(N))
    K_sum_mod = K_sum % N

    W = W_N_element(X, Y, N)
    central, phase = is_central_scalar(W, I)
    phase_power_n_is_one = phase is not None and abs(phase**N - 1) < tol
    w_power_n_is_identity = central and W**N == I

    # Erwartete zentrale Phase: zeta^{N * flux} = 1; Linearitaet in a testen
    W_a2 = W_N_element(
        *heisenberg_matrices(N, flux=2 * flux)[1:3],
        N,
    )
    _, phase_a2 = is_central_scalar(W_a2, I)

    return {
        "N": N,
        "a": a,
        "flux": flux,
        "K_sum_mod_N": K_sum_mod,
        "sample_K": [(P, Q, K_plaquette(P, Q, a, N)) for P in range(min(N, 3)) for Q in range(min(N, 3))],
        "W_phase": phase,
        "W_central": central,
        "phase_power_N_is_one": phase_power_n_is_one,
        "W_power_N_is_one": w_power_n_is_identity,
        "quantization_ok": central and phase_power_n_is_one,
        "double_flux_phase": phase_a2,
        "linearity_flux": phase_a2 == phase**2 if phase is not None else False,
    }


def print_group_ring(results):
    print("=== Gruppenring Z[A,B]/(A^N-1, B^N-1) ===")
    for r in results:
        print(
            f"N={r['N']}: W=1? {r['W_is_one']}, "
            f"W^N=1? {r['W_power_N_is_one']}, "
            f"Linearitaet {r['linearity']}"
        )


def print_heisenberg(results):
    print("=== Heisenberg-Torus (XY = zeta^flux YX) ===")
    for r in results:
        print(
            f"N={r['N']}, flux={r['flux']}: "
            f"Plaquette-Comm OK? {r['plaquette_commutator_ok']}, "
            f"Holonomie={r['plaquette_holonomy']}, "
            f"W zentral? {r['W_central']}, W-Phase={r['W_phase']}, "
            f"phase(W_N) in mu_N? {r['phase_power_N_is_one']}, "
            f"(numerisch W^N=I: {r['W_power_N_is_one']}), "
            f"Linearitaet {r['linearity']}"
        )


def print_lattice_2d(results):
    print("=== 2D-Gitter: lokale K(P,Q;a) ===")
    for r in results:
        print(f"N={r['N']}, a={r['a']}, flux={r['flux']}:")
        print(f"  sum_PQ K mod N = {r['K_sum_mod_N']}")
        print(f"  Stichprobe K(P,Q;a): {r['sample_K']}")
        print(
            f"  W-Phase={r['W_phase']}, phase(W_N) in mu_N? {r['phase_power_N_is_one']}, "
            f"(numerisch W^N=I: {r['W_power_N_is_one']}), "
            f"2*flux-Linearitaet? {r['linearity_flux']}"
        )


def run_verify(ns=(2, 3, 4, 5)):
    gr = [verify_group_ring(N) for N in ns]
    hs = [verify_heisenberg(N, flux=1) for N in ns]
    print_group_ring(gr)
    print()
    print_heisenberg(hs)
    all_ok = all(
        r.get("quantization_ok", r["W_power_N_is_one"])
        and all(x[1] for x in r["linearity"])
        for r in hs
    ) and all(
        r["W_power_N_is_one"] and all(x[1] for x in r["linearity"])
        for r in gr
    )
    print()
    print(f"Alle Checks bestanden: {all_ok}")
    return all_ok


def run_group_ring(ns=(2, 3, 4, 5, 7)):
    print_group_ring([verify_group_ring(N) for N in ns])


def run_heisenberg(ns=(2, 3, 4, 5, 7)):
    print_heisenberg([verify_heisenberg(N, flux=1) for N in ns])


def run_lattice_2d():
    results = []
    for N in [3, 4, 5]:
        for a in [1, 2]:
            if a >= N:
                continue
            results.append(lattice_2d_demo(N, a=a))
    print_lattice_2d(results)


def print_lattice_2d_variable(results):
    print("=== 2D-Gitter: variabler Flux a(P,Q) ===")
    for r in results:
        print(
            f"N={r['N']}: Treppe={r['staircase_holonomy_mod_N']}, "
            f"Gitter={r['grid_holonomy_mod_N']}, flux={r['effective_flux']}, "
            f"W-Phase={r['W_phase']}, phase(W_N) in mu_N? {r['phase_power_N_is_one']}, "
            f"(numerisch W^N=I: {r['W_power_N_is_one']})"
        )


def run_lattice_2d_variable():
    results = []
    for N in [3, 4, 5]:
        results.append(lattice_2d_variable_demo(N, a_spec=lambda P, Q, N=N: a_PQ_default(P, Q, N)))
    print_lattice_2d_variable(results)


def main():
    mode = "verify"
    if len(sys.argv) > 1:
        mode = sys.argv[1].strip().lower()

    if mode == "verify":
        ok = run_verify()
        if not ok:
            raise SystemExit(1)
    elif mode == "group_ring":
        run_group_ring()
    elif mode == "heisenberg":
        run_heisenberg()
    elif mode == "lattice_2d":
        run_lattice_2d()
    elif mode == "lattice_2d_variable":
        run_lattice_2d_variable()
    else:
        print("Unbekannter Modus. Nutze: verify | group_ring | heisenberg | lattice_2d | lattice_2d_variable")
        raise SystemExit(2)


if __name__ == "__main__":
    main()
