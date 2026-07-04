#!/usr/bin/env sage
# -*- coding: utf-8 -*-
"""
[B] Toy Layer — algebraisch-topologischer Kontrollkern fuer Bockstein-Braiding.

Status [B]: internes Sage-Toy-Modell auf Z_N x Z_N. Keine physikalischen Claims.

Referenz: Hsin & Chen, arXiv:2607.02280 (adjacent case p+q=d-1, Bockstein-Response).
Sicherer Claim: phase(W_N) in mu_N, d.h. phase(W_N)^N = 1 — nicht pauschal W_N^N = I
als Operatoridentitaet behaupten (W_N kann zentral-skalar sein, ohne dass W_N = zeta^k I
fuer k != 0 numerisch als Identitaet formuliert wird).

Feldtheorie-Kontext (extern, [A]): (2 pi i / N) integral A_{d-p} cup beta_N B_{d-q}.

Ausfuehrung:
    sage scripts/bockstein_braiding_symbolic.sage
"""

from sage.all import *


def root_of_unity(n):
    """[B] Primitive N-te Einheitswurzel zeta = exp(2 pi i / N) im Zyclotomischen Koerper."""
    K = CyclotomicField(n)
    return K.gen()


def phase_mod_N(phase, n, tol=1e-10):
    """
    [B] Exponent k mod N mit phase ~ zeta^k, falls phase nahe der N-ten Einheitswurzelgruppe liegt.
    Gibt None zurueck, wenn kein k gefunden wird.
    """
    zeta = root_of_unity(n)
    best_k = None
    best_dist = Infinity
    for k in range(n):
        dist = abs(phase - zeta**k)
        if dist < best_dist:
            best_dist = dist
            best_k = k
    return Integer(best_k) if best_dist < tol else None


def heisenberg_matrices(n, flux=1):
    """Magnetische Translationsalgebra: XY = zeta^flux YX."""
    K = CyclotomicField(n)
    zeta = K.gen()
    twist = zeta**flux
    MS = MatrixSpace(K, n, n)
    I = MS.identity_matrix()
    X = MS([[1 if j == (i - 1) % n else 0 for j in range(n)] for i in range(n)])
    Y = MS.diagonal_matrix([twist**k for k in range(n)])
    return MS, X, Y, zeta, twist, I


def commutator_element(X, Y):
    """C(X,Y) = Y^{-1} X^{-1} Y X (Gruppenelement bzw. Matrix)."""
    return Y.inverse() * X.inverse() * Y * X


def W_N_element(X, Y, n):
    """W_N(X,Y) = (Y^{-1} X^{-1})^N (Y X)^N."""
    return (Y**(-1) * X**(-1))**n * (Y * X)**n


def is_central_scalar(M, I, tol=1e-12):
    """Prueft M = lambda I; liefert (True, lambda) oder (False, None)."""
    if M != M.parent()(M[0, 0]) * I:
        return False, None
    return True, M[0, 0]


def commutator_phase(n, flux=1, tol=1e-12):
    """
    [B] Zentrale Phase von C(X,Y) = Y^{-1} X^{-1} Y X in der Heisenberg-Probe.
    Erwartung: C = zeta^{flux} I (Plaquette-Kommutator dual zu XY X^{-1} Y^{-1} = zeta^{-flux} I).
    """
    _MS, X, Y, zeta, _twist, I = heisenberg_matrices(n, flux=flux)
    C = commutator_element(X, Y)
    central, phase = is_central_scalar(C, I, tol=tol)
    if not central:
        return None
    return phase


def compare_commutator_vs_w_n(n, flux=1, tol=1e-12):
    """
    [B] Vergleicht C(X,Y) und W_N(X,Y): beide Phasen und Exponenten mod N ausgeben.
    Kein Claim W_N^N = I; nur phase(W_N) in mu_N pruefen (via verify_quantization).
    """
    _MS, X, Y, zeta, _twist, I = heisenberg_matrices(n, flux=flux)
    C = commutator_element(X, Y)
    W = W_N_element(X, Y, n)
    c_central, c_phase = is_central_scalar(C, I, tol=tol)
    w_central, w_phase = is_central_scalar(W, I, tol=tol)
    return {
        "N": n,
        "flux": flux,
        "C_central": c_central,
        "C_phase": c_phase,
        "C_exponent_mod_N": phase_mod_N(c_phase, n, tol=tol) if c_phase is not None else None,
        "W_central": w_central,
        "W_phase": w_phase,
        "W_exponent_mod_N": phase_mod_N(w_phase, n, tol=tol) if w_phase is not None else None,
        "expected_C_exponent": Integer(flux % n),
    }


def torus_staircase_path(n):
    """
    [B] Zwei alternierende Treppenpfade auf Z_N x Z_N (YX vs XY) plus diagonale Bockstein-Treppe.

    path_YX: pro Schritt X dann Y, (a,b) -> (a+1,b) -> (a+1,b+1).
    path_XY: pro Schritt Y dann X, (a,b) -> (a,b+1) -> (a+1,b+1).
    vertices/edges: diagonale Treppe (m,m) -> (m+1,m+1) mod N.
    """
    path_yx = []
    path_xy = []
    a, b = 0, 0
    for _step in range(n):
        p0 = (Integer(a % n), Integer(b % n))
        p1 = (Integer((a + 1) % n), Integer(b % n))
        p2 = (Integer((a + 1) % n), Integer((b + 1) % n))
        path_yx.append((p0, p1, p2))
        a, b = a + 1, b + 1
    a, b = 0, 0
    for _step in range(n):
        p0 = (Integer(a % n), Integer(b % n))
        p1 = (Integer(a % n), Integer((b + 1) % n))
        p2 = (Integer((a + 1) % n), Integer((b + 1) % n))
        path_xy.append((p0, p1, p2))
        a, b = a + 1, b + 1
    vertices = [(Integer(m % n), Integer(m % n)) for m in range(n)]
    edges = [(vertices[m], vertices[(m + 1) % n]) for m in range(n)]
    return {"path_YX": path_yx, "path_XY": path_xy, "vertices": vertices, "edges": edges}


def local_square_cocycle(p, q, a_spec, n):
    """
    [B] Toy-2-Kozykel auf einer Plaquette (P,Q): K(P,Q) mod N.

    Homogenes a (int): K = a*(P+Q) mod N.
    Callable a_spec(P,Q): K = a_spec(P,Q) mod N.
    """
    if callable(a_spec):
        return Integer(a_spec(p, q) % n)
    return Integer((a_spec * (p + q)) % n)


def bockstein_torus_sum(a_spec, n):
    """[B] Summe des Toy-Kozyklus entlang der Bockstein-Treppe sum_{m=0}^{N-1} K(m,m) mod N."""
    return Integer(
        sum(local_square_cocycle(m, m, a_spec, n) for m in range(n)) % n
    )


def bockstein_torus_phase(a_spec, n):
    """[B] Quantisierte Torsionsphase zeta^{bockstein_torus_sum} in mu_N."""
    k = bockstein_torus_sum(a_spec, n)
    zeta = root_of_unity(n)
    return zeta**k, k


def verify_quantization(n, flux=1, tol=1e-12):
    """
    [B] Defensiver Check: phase(W_N) liegt in mu_N, d.h. phase(W_N)^N = 1.

    Explizit NICHT als mathematischer Hauptclaim: W_N^N = I als Operatoridentitaet.
    (Numerisch kann W^N = I gelten, wenn W_N zentral-skalar ist — das ist eine
    Folgerung fuer Skalare, kein allgemeiner Operator-Claim.)
    """
    _MS, X, Y, zeta, _twist, I = heisenberg_matrices(n, flux=flux)
    W = W_N_element(X, Y, n)
    central, phase = is_central_scalar(W, I, tol=tol)
    phase_power_n_is_one = False
    w_power_n_is_identity = False
    if phase is not None:
        phase_power_n_is_one = abs(phase**n - 1) < tol
    if central:
        w_power_n_is_identity = W**n == I
    exp_mod = phase_mod_N(phase, n, tol=tol) if phase is not None else None
    return {
        "N": n,
        "flux": flux,
        "W_central_scalar": central,
        "phase_W_N": phase,
        "phase_exponent_mod_N": exp_mod,
        "phase_power_N_is_one": phase_power_n_is_one,
        "W_power_N_is_I_numerical": w_power_n_is_identity,
        "quantization_ok": central and phase_power_n_is_one,
    }


def demo_compare_commutator_vs_w_n(n=4, flux=1, tol=1e-12):
    """[B] Demo: Plaquette-Kommutator vs. W_N-Holonomie fuer festes N und flux."""
    cmp_result = compare_commutator_vs_w_n(n, flux=flux, tol=tol)
    c_phase = commutator_phase(n, flux=flux, tol=tol)
    quant = verify_quantization(n, flux=flux, tol=tol)
    return {
        "compare": cmp_result,
        "commutator_phase": c_phase,
        "quantization": quant,
    }


def demo_staircase_n4():
    """Staircase-Demo N=4: Pfad, Toy-Kozykel, Phase vs. W_N-Vergleich."""
    n = 4
    a_spec = lambda P, Q: Integer((P + 2 * Q) % n)
    path = torus_staircase_path(n)
    k_sum = bockstein_torus_sum(a_spec, n)
    phase, _k = bockstein_torus_phase(a_spec, n)
    cmp_result = compare_commutator_vs_w_n(n, flux=int(k_sum))
    quant = verify_quantization(n, flux=int(k_sum))
    return {
        "path": path,
        "bockstein_sum_mod_N": k_sum,
        "bockstein_phase": phase,
        "commutator_vs_W": cmp_result,
        "quantization": quant,
    }


def print_verify_results(results):
    for r in results:
        print(
            f"N={r['N']}, flux={r['flux']}: "
            f"phase(W_N) in mu_N? {r['phase_power_N_is_one']}, "
            f"exp mod N={r['phase_exponent_mod_N']}, "
            f"(numerisch W^N=I: {r['W_power_N_is_I_numerical']})"
        )


def print_compare_demo(demo):
    print("=== [B] Demo 2/3: compare_commutator_vs_w_n N=4, flux=1 ===")
    c = demo["compare"]
    print(
        f"C(X,Y): central={c['C_central']}, phase={c['C_phase']}, exp mod N={c['C_exponent_mod_N']} "
        f"(erwartet {c['expected_C_exponent']})"
    )
    print(
        f"W_N(X,Y): central={c['W_central']}, phase={c['W_phase']}, exp mod N={c['W_exponent_mod_N']}"
    )
    print(f"commutator_phase() = {demo['commutator_phase']}")
    q = demo["quantization"]
    print(
        f"verify_quantization OK? {q['quantization_ok']} "
        f"(phase^N=1: {q['phase_power_N_is_one']}, "
        f"numerisch W^N=I: {q['W_power_N_is_I_numerical']})"
    )


def print_staircase_demo(demo):
    print("=== [B] Demo 3/3: Bockstein-Treppe N=4 (Toy-Kozykel) ===")
    path = demo["path"]
    print(f"YX-Treppe (3 Plaquettes): {path['path_YX'][:2]} ...")
    print(f"XY-Treppe (3 Plaquettes): {path['path_XY'][:2]} ...")
    print(f"Diagonale Ecken: {path['vertices']}")
    print(f"sum K(m,m) mod N = {demo['bockstein_sum_mod_N']}")
    print(f"bockstein_torus_phase = {demo['bockstein_phase']}")
    c = demo["commutator_vs_W"]
    print(
        f"C(X,Y): phase={c['C_phase']}, exp mod N={c['C_exponent_mod_N']}; "
        f"W_N(X,Y): phase={c['W_phase']}, exp mod N={c['W_exponent_mod_N']} "
        f"(flux={c['flux']})"
    )
    q = demo["quantization"]
    print(
        f"verify_quantization OK? {q['quantization_ok']} "
        f"(phase^N=1: {q['phase_power_N_is_one']})"
    )


def main():
    ns = (2, 3, 4, 5)
    print("=== [B] Demo 1/3: verify_quantization — phase(W_N)^N = 1 (nicht Operator-Claim W^N=I) ===")
    results = [verify_quantization(n, flux=1) for n in ns]
    print_verify_results(results)
    all_ok = all(r["quantization_ok"] for r in results)
    print(f"Alle Quantization-Checks: {all_ok}")
    print()
    cmp_demo = demo_compare_commutator_vs_w_n(n=4, flux=1)
    print_compare_demo(cmp_demo)
    print()
    demo = demo_staircase_n4()
    print_staircase_demo(demo)
    if (
        not all_ok
        or not cmp_demo["quantization"]["quantization_ok"]
        or not demo["quantization"]["quantization_ok"]
    ):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
