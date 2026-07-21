---
title: Semiprime-Chirurgie — Fahrplan Kanal-7 / 71 mod 256
date: 2026-07-21
status: >-
  Exploratory scaffold. Stein1/Stein2 still open. Surgery is a proposed
  reduction, not a proof. No Collatz closure.
governance: >-
  [C] research plan + Python probe + Lean interface stubs with sorry.
  Metaphors (Perelman / curvature / torsion) are not [A].
  Semiprime24Bridge / Tensorchirurgie / Typentrennung E_Δ≠E_vol are NOT
  attributed to PR #8.
not_claimed:
  - Collatz bewiesen
  - Full Deep-Tail class 71 mod 256 closed
  - DeepLiftFiber dynamic entry for all 71 mod 256
  - BoolTrace(P)=0 ⇒ archimedischer Abstieg
  - Universal cover / desingularization proved
  - PR #8 as Semiprime24Bridge / Tensorchirurgie proof
---

# Semiprime-Chirurgie — Fahrplan Kanal 7 (2026-07-21)

**Branch:** `pr/11-collatz-v27-net-descent`  
**Typ:** #Energiedoku — exploratory scaffold  
**Collatz?** **NEIN**

---

## 1. Zielreduktion (offen)

Zwei Lean-Lücken als Angriffspunkte der vorgeschlagenen „Semiprime Surgery“
(EABC-Desingularisierung — **Metapher / [C]**, kein Theorem):

| Stein | Inhalt | Status |
|---|---|---|
| **Stein1** | Channel-7 Deep-Tail / `DeepLiftFiber`-Eintritt für volle Klasse `n ≡ 71 (mod 256)` | **offen** — nur Kind `583 mod 1024` formal (V2.17) |
| **Stein2** | Absorption / `BoolTrace →` archimedischer Abstieg | **offen** — endliche Bool-Diagnose ≠ ℕ-Deszent |

Surgery ist eine **vorgeschlagene Reduktion**, kein Beweis.

---

## 2. Was bereits existiert (nicht neu erfinden)

| Asset | Rolle |
|---|---|
| `ChannelSevenDeepLiftV214` / Python `deep_lift_hensel_diagnostic` | Affine Faser `243t + c_j` |
| `ChannelSevenDeepLiftFormalBridgeV217` | Landing `t≡160 → 71 mod 256` (ohne Witness); formal `t≡672 → 583` |
| `ChannelSevenDynamicsHypothesesV215` | `DeepLiftFiberState`, Entry-Hypothesen mit `sorry` |
| `CollatzProofAttemptV27` | `BadRunNetDescentWitness` |
| H7 witness matrix | Kontrollierte Residuen `{39,79,95,103}` mod 128 |
| PR #8 | Nur Energiedoku-/Primvierling-Exports — **nicht** Typentrennung / Tensorchirurgie |

---

## 3. Scaffold dieses Commits

| Pfad | Inhalt |
|---|---|
| `src/kepler_hurwitz/semiprime_surgery_71_probe.py` | Probe: Landing, Kinder mod 1024, **provisorische** Surgery-Matrix `[C]` |
| `examples/run_semiprime_surgery_71_probe.py` | Runner → JSON-Export |
| `docs/exports/semiprime_surgery_71_mod256_probe.json` | Export |
| `KeplerHurwitz/Collatz/SemiprimeDesingularization.lean` | Lean-Interface + **3× `sorry`**; **nicht** in `Core` verdrahtet |

### Computed vs. provisional

**Computed** (bestehende Definitionen):

- `c_3 = 103`, `deepLiftFiber(3,160) ≡ 71 (mod 256)`, `deepLiftFiber(3,672) ≡ 583 (mod 1024)`
- Kinder `{71,327,583,839}` mod 1024
- H7-Witness-Matrix, kurze Orbit-Galerie

**Provisional `[C]`** (neu als Diagnose, klar gelabelt):

- Transfer-/Cut-Matrix auf den vier Kindern unter odd Syracuse
- Cut-Kandidaten = Wrap-Proxy (Bild ≥ 1024) oder Verbleib in non-formal deep-tail

---

## 4. Nächster konkreter Check (nach Scaffold)

1. Für Kind `839` und `327`: numerische `t_loc`-Suche analog V2.17 (`583`), ob ein weiteres kurz-affines Kind mit uniformem Witness existiert.
2. Vergleich der provisorischen Cut-Kanten mit `h7_mod256_separation_scan` / Step-6/7-Branching — nur Konsistenz `[B]`, kein Closure-Claim.
3. Erst danach: evtl. Lean-Lemma für ein weiteres mod-1024/2048-Kind (wie `583`), **ohne** Schein-Brücke für volle `71 mod 256`.

---

## 5. Claim-Wand (kurz)

\[
\boxed{
\text{Scaffold} \neq \text{Stein1/Stein2 geschlossen}
\neq \text{Collatz}
}
\]
