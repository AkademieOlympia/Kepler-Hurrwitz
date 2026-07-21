---
title: EABC §5.22 — Arithmetischer Relations-Klassifikator Φ_k
date: 2026-07-21
status: >-
  Python-[B]-Audit k∈[10,14] abgeschlossen; naive stated-Φ auf G_k^cut widerlegt;
  refined Φ hält; Lean Labels/Packaging grün; kein Collatz.
governance: >-
  [A] Labels/Packaging + Absorption-Reuse; [B] F_k/Fokus-Audit;
  [C] Drift §5.21 und ∀k Cut-Klassifikation offen.
---

# §5.22 \(\Phi_k\): Energiedoku-Export (2026-07-21)

**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku — Audit-Archiv  
**Collatz?** **NEIN**

## Artefakte

| Schicht | Pfad |
|---|---|
| Theorie | [`../eabc_collatz_audit_grid.md`](../eabc_collatz_audit_grid.md) §5.22 |
| Python | `src/kepler_hurwitz/eabc_relation_classifier_phi_k.py` |
| Runner | `examples/run_relation_classifier_phi_k_audit.py` |
| JSON | [`../exports/relation_classifier_phi_k_focus_cycles_k10_14.json`](../exports/relation_classifier_phi_k_focus_cycles_k10_14.json) |
| Lean | `KeplerHurwitz/EABC/SyracuseRelationClassifierPhi.lean` |
| Tests | `tests/test_eabc_relation_classifier_phi_k.py` |

## Audit-Kernbefunde

1. **Naive \(\Phi_k^{\mathrm{stated}}\)** (\(v=1\Rightarrow E_{01}\) auf Cut) **hält nicht**: wrap-freie \(v=1\)-Kanten haben Lift-Matrix \(E_{00}\).
2. **Refined \(\Phi_k^{\mathrm{ref}}\)** (Wrap-Bit) trifft alle \(F_k\)-Kanten im geprüften Fenster.
3. **Fokus-Zyklen** \((10,26),(11,25),(12,7),(12,6)\): Wort \(\sim_{\mathrm{cyc}} E_{00}^{\ell-1}E_{01}\), BoolTrace\(=0\), je genau eine Wrap-Kante; **nicht** in \(G_k^{\mathrm{cut}}\).
4. **\(G_k^{\mathrm{cut}}\)** für \(k\in[10,14]\): azyklisch; alle Cut-Kanten \(E_{00}\).
5. **§5.21 Drift \(D_m\)**: nur definiert/dokumentiert — Open Non-Claim Boundary `[C]`.
6. **§5.19/§5.20**: Absorption wiederverwendet (`BooleanRelationAbsorption` / `FocusCycleUnitDefect`), nicht dupliziert.

## Status-Tafel (ehrlich)

| § | Status |
|---|---|
| 5.19 / 5.20 | frozen `[A]`/`[B]` |
| 5.21 | frozen `[C]` Open Non-Claim (Bilanz + Drift-Definition) |
| 5.22 | audit `[B]` + Labels `[A]`; naive stated **nicht** verifiziert |
| 5.23 | stub / next |
