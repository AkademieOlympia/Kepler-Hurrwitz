---
title: Pure-E Semiprime-Cover vs Collatz — Claim-Grenze
date: 2026-07-21
status: >-
  Claim-boundary note. Collatz not proved. Gap 2 WF glue closed conditionally;
  Gap 1 constructive interface only (BoolTrace→descent open).
governance: >-
  [A] packaging equivalences + WF glue in
  KeplerHurwitz/Collatz/PureESemiprimeCoverClaimBoundary.lean.
  [C] SemiprimeDesingularization scaffold (3× sorry); BoolTraceZeroImpliesLocalShrink;
  EABC NormalForm reine-E not wired on this Collatz worktree.
not_claimed:
  - Collatz bewiesen
  - IsReineEForm ⇒ BadRunNetDescentWitness
  - Boolean absorption / BoolTrace=0 ⇒ archimedischer Abstieg
  - Semiprime surgery ⇒ Stein1 / full 71 mod 256 cover
  - Zirkularität „pure E cover ⇔ net descent“ aufgelöst
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

## 2. Zwei Lücken — Status nach konstruktivem Fahrplan

| Lücke | Inhalt | Lean-Status |
|---|---|---|
| **Gap 2** | lokaler Abstieg unter `n` → `OddCoreCollatzConjecture` | **geschlossen** (bedingt): `net_descent_cover_implies_oddCoreCollatz` via `Nat.strong_induction_on` + even/`mod4=1`-Shrinks `[A]` |
| **Gap 1** | EABC/Semiprime/BoolTrace → `BadRunNetDescentWitness` | **offen**; nur konstruktives Interface (`eabcToWitness`, `PhaseLengthCertificate`, `BoolTraceZeroImpliesLocalShrink` als Hypothese) |

### Gap 2 (WF-Glue) — was bewiesen ist

Unter der offenen Hypothese `BadRunNetDescentStatement`:

1. für jedes `n > 1` existiert `t` mit `collatzStep^[t] n < n`
   (even / `≡1 mod 4` schon `[A]`; `≡3 mod 4` aus dem Cover);
2. starke Induktion über `(ℕ,<)` liefert `ClassicalCollatzConjecture`;
3. Äquivalenz ⇒ `OddCoreCollatzConjecture`.

Theorem-Namen:

* `exists_strict_collatz_descent_of_net_descent`
* `classicalCollatz_of_local_strict_descent`
* `net_descent_cover_implies_oddCoreCollatz`
* `collatz_of_pure_E_semiprime_cover` (ohne opake `Hterm`-Hypothese)

Das beweist **nicht** den Antezedens. Collatz bleibt offen.

### Gap 1 (konstruktives Interface) — was bewusst *nicht* bewiesen ist

* `PhaseLengthCertificate` / `t_loc_of_phase_depth` — Buchhaltung ohne EABC-Import
* `BoolTraceZeroImpliesLocalShrink` — **named open hypothesis**
* `eabcToWitness` — bedingt: `Hbt` + Entry + Phase ⇒ Witness
* `bad_run_net_descent_of_eabc_constructive_cover` — bedingt Cover⇒NetDescent
* Stein1 / Stein2 / surgery⇒Stein1 in `SemiprimeDesingularization.lean` bleiben **3× sorry**

Kein Fake-`exact` für BoolTrace⇒Abstieg.

---

## 3. Was **würde** reichen (unverändert hart)

> Für jedes `n > 1` mit `n ≡ 3 (mod 4)` existiert ein
> `BadRunNetDescentWitness n`
> (oder BoolTrace-Hypothese + Phasen-Cover, die ihn liefern).

Dann folgt Odd-Core **via Gap-2-Glue**, und via
`oddCoreCollatz_implies_classicalCollatz` die klassische Form.

Lean-Name der ehrlichen Cover-Hypothese:
`PureESemiprimeCoverStatement`.

---

## 4. Zirkularität — **nicht** magisch aufgelöst

`PureESemiprimeCoverStatement ↔ BadRunNetDescentStatement` ist weiterhin `[A]`.

Gap 2 schließt nur den Induktionsschritt „lokaler Abstieg → Reach-`1`“.
Gap 1 (woher der uniforme Witness kommt) bleibt der offene V2.7-Kern.
Ein Shape-only „reine E“ ohne dynamisches `t_loc` ist weiterhin nicht schwächer
als dieser Kern (`MereReineEShapeImpliesWitness` ⇔ NetDescent beim Platzhalter).

---

## 5. Claim-Wand

\[
\boxed{
\text{reine E (Shape/Absorption/Scaffold)}
\nRightarrow
\text{BadRunNetDescentWitness}
\quad;\quad
\text{BadRunNetDescentStatement}
\Rightarrow_{\mathrm{[A,\,WF]}}
\text{OddCoreCollatz}
\quad\text{(Antezedens offen)}
}
\]

**Collatz?** **NEIN.**
