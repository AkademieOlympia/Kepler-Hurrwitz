# Bockstein-Braiding Layer — Evidenzstatus [A]/[B]/[C]

Algebraisch-topologischer Kontrolllayer fuer W_N-Holonomie und Bockstein-Treppen auf
`Z_N x Z_N`. Kein physikalisches Implementierungsmodell; defensiv formulierte Checks.

**The layer is not a physical implementation and does not establish a physical claim.**

## [A] External mathematical input

**Quelle:** Hsin, P.-S.; Chen, Y.-A., *Bockstein braiding statistics*,
[arXiv:2607.02280](https://arxiv.org/abs/2607.02280) (2. Juli 2026), Kurzform `[HsinChen2026]`.

- **W_N-Zyklus:** `W_N(X,Y) = (Y^{-1} X^{-1})^N (Y X)^N` als geschlossene Holonomie
  in nicht-kommutativen Torus-Modellen (magnetische Translationsalgebra).
- **Adjacent case:** benachbarte Dimensionen mit `p + q = d - 1`, aequivalent
  `d = p + q + 1` (Bockstein-Response zwischen Formengrad `p` und `q`).
- **Bockstein-Response:** lokale Plaquette-Phasen summieren sich entlang einer
  diagonalen Treppe `(m,m)` auf dem `N x N`-Gitter; globale Gitter-Summe kann
  kompensieren, waehrend die Treppe mod `N` nontrivial bleibt (vgl. Gl. 76 im Paper).
- **Feldtheorie-Kontext (extern):** Torsionsphase
  `(2 pi i / N) integral A_{d-p} cup beta_N B_{d-q}` —
  hier nur als mathematische Referenz, nicht als physikalische Behauptung im Repo.

**Defensiver Claim im Projekt:** Wenn `W_N` zentral-skalar ist mit `phase(W_N) = zeta^k`,
dann `phase(W_N) in mu_N`, also `phase(W_N)^N = 1`. Nicht pauschal `W_N^N = I` als
allgemeine Operatoridentitaet formulieren.

## [B] Internal toy implementation

Status **[B]**: internes Toy-Modell, keine physikalischen Claims.

| Artefakt | Rolle |
|----------|-------|
| `scripts/bockstein_braiding_symbolic.sage` | Sage-Kontrollkern: `root_of_unity`, `phase_mod_N`, `commutator_phase`, `compare_commutator_vs_w_n`, `torus_staircase_path` (YX/XY + Diagonale), Toy-Kozykel |
| `src/kepler_hurwitz/bockstein_braiding.py` | Numerisches Python-Pendant (Heisenberg-Matrizen, Plaquette-Dichte `K(P,Q;a)`, Treppe vs. Gitter) |
| `scripts/aharonov_bohm_bockstein_w_cycles.sage` | Erweiterter Sage-Lauf (Gruppenring, Heisenberg, 2D-Gitter) |

**Toy-Kozykel** (`local_square_cocycle` / `bockstein_torus_sum` / `bockstein_torus_phase`):

- Lokale Dichte `K(P,Q) mod N` auf Plaquettes,
- Summe entlang der Bockstein-Treppe `sum_{m=0}^{N-1} K(m,m)`,
- quantisierte Phase `zeta^k` mit `k` mod `N`.

**Check `verify_quantization`:** prueft `phase(W_N)^N = 1` (Mitgliedschaft in `mu_N`),
nicht den Operator-Claim `W_N^N = I` als Hauptbehauptung.

## [C] EABC interpretation (Hypotheseninterface)

Status **[C]**: Hypothesen-/Interpretationsschicht — **explizit ohne physikalischen Claim**.

Arbeitshypothese fuer Anschluss ans EABC-Programm:

1. **Lokale Ausloeschung:** Summe der lokalen Plaquette-Beitraege ueber das volle
   `N x N`-Gitter kann mod `N` verschwinden (Fluss-Kompensation).
2. **Globaler Torsionsrest:** Die Bockstein-Treppe `(m,m)` traegt einen mod-`N`-Rest,
   der mit dem effektiven Flux-Exponenten von `W_N` vergleichbar ist (Toy-Check in
   `lattice_2d_variable_demo`, z.B. `N=4`, `a(P,Q)=(P+2Q) mod N`: Treppe `2`, Gitter `0`).
3. **Renorm-Invariant:** Der Torsionsrest ist ein diskretes, quantisiertes Objekt in
   `mu_N` — potenzieller Anker fuer renormierungstheoretische Invarianten in der
   EABC-Signatur-Schicht, ohne Behauptung einer konkreten QFT-Realisierung.

Diese [C]-Schicht ist ein **Hypotheseninterface** zwischen externer Mathematik [A] und
internem Toy-Code [B]. Sie begruendet keine experimentelle oder Feldtheorie-Vorhersage.

## Verweise im Repo

- Related Work: `docs/related-work.md` (Abschnitt 7)
- Literatur: `docs/literaturliste.md` (`[HsinChen2026]`)
- Tests: `tests/test_bockstein_braiding.py`
