---
title: Pure-E Semiprime-Cover vs Collatz — Claim-Grenze
date: 2026-07-21
status: >-
  Claim-boundary note. Collatz not proved. Even-branch oddCoreSyracuse bug fixed.
  Abstract netDescent⇒termination [A] in CollatzChirurgeryBridge.
  Gap 1 EABC/BoolTrace bridge still [C].
governance: >-
  [A] CollatzChirurgeryBridge (OddCoreDynamics / FuelSearch /
  AbstractDescentTermination) + thin PureESemiprimeCoverClaimBoundary.
  [C] AbsorbingTraceCertificate / BoolTraceZeroImpliesLocalShrink;
  SemiprimeDesingularization scaffold (3× sorry); EABC NormalForm not wired.
not_claimed:
  - Collatz bewiesen
  - IsReineEForm ⇒ BadRunNetDescentWitness
  - Boolean absorption / BoolTrace=0 ⇒ archimedischer Abstieg
  - Semiprime surgery ⇒ Stein1 / full 71 mod 256 cover
  - T(even) < even unter oddCoreSyracuse
  - Zirkularität „pure E cover ⇔ net descent“ aufgelöst
---

# Pure-E Semiprime-Cover vs Collatz — Claim-Grenze (2026-07-21)

**Branch:** `pr/11-collatz-v27-net-descent`  
**Typ:** #Energiedoku — claim boundary  
**Collatz?** **NEIN**

---

## 0. Architektur-Reparatur (Even-Domain)

`oddCoreSyracuse = oddCore(3n+1)` ist für **ungerade** Eingaben gedacht.
Für gerades `k>0` ist `3k+1` ungerade ⇒ `ν₂=0` ⇒ `T(k)=3k+1>k` (Beispiel `T(2)=7`).

| Route | Gerade Zustände | Ungerade Zustände |
|---|---|---|
| V2.7 / `collatzStep` Gap-2 | Halbierung `collatz_even_step_lt` / oddPart-Strip | Cover + good-branch |
| Odd-Core Syracuse | **nicht** mit `T` behandeln | `OddNetDescentStatement` |

Modul: `KeplerHurwitz/Collatz/CollatzChirurgeryBridge.lean`
(Blöcke: OddCoreDynamics, FuelSearch, AbstractDescentTermination, EabcBridgeBoundary).

---

## 1. Was meint „reine E-Darstellung“?

| Lesart | Ort | Dynamischer Collatz-Gehalt |
|---|---|---|
| EABC NormalForm `reineE` / `IsReineEForm` (`r = 1`) | `KeplerHurwitz/EABC/NormalForm.lean` (main/EABC; **nicht** in diesem Worktree) | keiner — Algebra / Residuum-Shape |
| Absorptionsalphabet `{E00, E01, Z}` | BooleanRelationAbsorption / Stein2-Wording | endlich modular; **≠** ℕ-Abstieg |
| Semiprime-Chirurgie-Scaffold | `Collatz/SemiprimeDesingularization.lean` | Interface + **3× sorry**; keine reine-E-Zertifikate |

Die gesprochene Kette „Semiprime-Abstieg → reine E → Collatz“ vermengt diese Lesarten.

---

## 2. Zwei Lücken — Status

| Lücke | Inhalt | Lean-Status |
|---|---|---|
| **Gap 2** | lokaler Abstieg → Reach-`1` / OddCore | **`[A]`** bedingt: `descent_implies_reaches_one` + `net_descent_cover_implies_oddCoreCollatz` |
| **Gap 1** | EABC/Semiprime/BoolTrace → Abstiegszeuge | **`[C]` offen**; `AbsorbingTraceCertificate` / `BoolTraceZeroImpliesLocalShrink` |

### Gap 2 — was bewiesen ist `[A]`

* `oddCoreSyracuseIter_add` — Iterationskomposition
* `descent_implies_reaches_one` / `netDescent_implies_termination` — abstrakt
* `odd_descent_implies_reaches_one` — Odd-only Variant A
* `findWitnessWithFuel_sound` / `_complete` — Brennweitensuche
* `descent_exists_to_witness` / `pack_net_descent_witness` — **nur** Verpackung (kein BoolTrace)
* `net_descent_cover_implies_oddCoreCollatz` — V2.7 Cover ⇒ OddCore (even via `collatzStep`)

### Gap 1 — bewusst *nicht* bewiesen `[C]`

\[
\boxed{\operatorname{BoolTrace}(P)=0 \Longrightarrow \exists t:\ T^t(n)<n}
\]

Named: `AbsorbingTraceCertificate` / `BoolTraceZeroImpliesLocalShrink`.
Kein Fake-`exact`. Stein1/Stein2 bleiben 3× `sorry`.

---

## 3. Was **würde** reichen (unverändert hart)

> Für jedes relevante `n>1` existiert ein archimedischer Net-Descent
> (`BadRunNetDescentWitness` bzw. `OddNetDescentStatement`).

Dann folgt Odd-Core via Gap-2-Glue. Der Antezedens bleibt offen.

---

## 4. Zirkularität — **nicht** magisch aufgelöst

`PureESemiprimeCoverStatement ↔ BadRunNetDescentStatement` ist weiterhin `[A]`.
Gap 2 schließt nur „lokaler Abstieg → Reach-`1`“.
Gap 1 bleibt der offene V2.7-/EABC-Kern.

---

## 5. Claim-Wand

\[
\boxed{
\text{reine E (Shape/Absorption/Scaffold)}
\nRightarrow
\text{Net-Descent-Zeuge}
\quad;\quad
\text{NetDescent}
\Rightarrow_{\mathrm{[A]}}
\text{Termination}
\quad\text{(Antezedens offen)}
}
\]

**Collatz?** **NEIN.**
