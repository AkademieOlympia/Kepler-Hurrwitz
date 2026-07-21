---
title: Pure-E Semiprime-Cover vs Collatz — Claim-Grenze
date: 2026-07-21
status: >-
  Claim-boundary note. Collatz not proved. Formalizes that an honest
  “pure E Semiprime cover” is definitionally BadRunNetDescentStatement.
governance: >-
  [A] packaging equivalences in
  KeplerHurwitz/Collatz/PureESemiprimeCoverClaimBoundary.lean.
  [C] SemiprimeDesingularization scaffold (3× sorry); O6 OddCore glue (sorry);
  EABC NormalForm reine-E not wired on this Collatz worktree.
not_claimed:
  - Collatz bewiesen
  - IsReineEForm ⇒ BadRunNetDescentWitness
  - Boolean absorption ⇒ archimedischer Abstieg
  - Semiprime surgery ⇒ Stein1 / full 71 mod 256 cover
---

# Pure-E Semiprime-Cover vs Collatz — Claim-Grenze (2026-07-21)

**Branch:** `pr/11-collatz-v27-net-descent`  
**Typ:** #Energiedoku — claim boundary  
**Collatz?** **NEIN**

---

## 1. Was meint „reine E-Darstellung“?

| Lesart | Ort | Dynamischer Collatz-Gehalt |
|---|---|---|
| EABC NormalForm `reineE` / `IsReineEForm` (`r = 1`) | `KeplerHurwitz/EABC/NormalForm.lean` (main/EABC; **nicht** in diesem Worktree) | keiner — Algebra / Residuum-Shape |
| Absorptionsalphabet `{E00, E01, Z}` | BooleanRelationAbsorption / Stein2-Wording | endlich modular; **≠** ℕ-Abstieg |
| Semiprime-Chirurgie-Scaffold | `Collatz/SemiprimeDesingularization.lean` | Interface + **3× sorry**; keine reine-E-Zertifikate |

Die gesprochene Kette „Semiprime-Abstieg → reine E → Collatz“ vermengt diese Lesarten.

---

## 2. Was **würde** reichen?

Präzise hinreichende Hypothese (ehrliche Verpackung):

> Für jedes `n > 1` mit `n ≡ 3 (mod 4)` existiert ein
> `BadRunNetDescentWitness n`
> **und** es gibt eine bewiesene Brücke
> `BadRunNetDescentStatement → OddCoreCollatzConjecture`
> (well-founded / Termination bis `1`).

Dann folgt Odd-Core-Collatz, und via
`oddCoreCollatz_implies_classicalCollatz` die klassische Form.

Lean-Name der ehrlichen Cover-Hypothese:
`PureESemiprimeCoverStatement`
(`KeplerHurwitz/Collatz/PureESemiprimeCoverClaimBoundary.lean`).

---

## 3. Was fehlt (fehlende Pfeile)

```
Semiprime surgery / „reine E“
    --[fehlt]--> BadRunNetDescentWitness          (Stein1/2, NormalForm-Brücke)
BadRunNetDescentStatement
    --[A, V2.7]--> CollatzAttemptV2OpenCase         (∃ t, step^t n < n)
CollatzAttemptV2OpenCase
    --[fehlt]--> OddCoreCollatzConjecture           (O6: 2× sorry)
```

Konkrete Zitationen:

| Fehlender Pfeil | Datei / Theorem |
|---|---|
| Surgery ⇒ Deep-Tail-Witness (`71 mod 256`) | `stein1_deep_tail_fiber_entry` (`sorry`) |
| Absorption ⇒ archimedischer Abstieg | `stein2_absorption_archimedean_descent` (`sorry`) |
| Surgery-Daten ⇒ Stein1 | `semiprime_surgery_implies_stein1` (`sorry`); Antezedens ist vacuous (`surgery_implies_stein1_iff_stein1`) |
| Net-Descent ⇒ oktonionische Termination | `block_descent_uniform_implies_termination` (`sorry`) |
| Oktonionische Termination ⇒ OddCore | `octonionic_termination_implies_oddCoreCollatz` (`sorry`) |
| NormalForm reine E ⇒ Witness | nicht formalisiert; Prop `MereReineEShapeImpliesWitness` ⇔ offener Kern (Platzhalter) |

---

## 4. Zirkularität

`PureESemiprimeCoverStatement ↔ BadRunNetDescentStatement` ist `[A]` bewiesen.
Eine „reine E“-Cover-Hypothese, die wirklich Collatz speist, **ist** der offene
V2.7-Kern — keine schwächere NormalForm-Aussage.

Shape-only (`MereEABCReineEShape := True` als Platzhalter ohne EABC-Import)
macht `MereReineEShapeImpliesWitness` ebenfalls äquivalent zum offenen Kern.

---

## 5. Claim-Wand

\[
\boxed{
\text{reine E (Shape/Absorption/Scaffold)}
\nRightarrow
\text{BadRunNetDescentWitness}
\nRightarrow
\text{OddCoreCollatz}
\nRightarrow
\text{Collatz}
}
\]

Closed today: Witness ⇒ OpenCase (V2.7). Open: uniform Witness + OpenCase ⇒ Reach-`1`.
