# Pre119 — Core6 Cylinder Partition (PR #16)

**Epistemic wall:** This document is the **target architecture** of PR #16.
It must not be confused with repository `[A]` status.

## Three-phase project matrix

| Phase | Label | Content |
|-------|-------|---------|
| **PR #15** | **`[A]`** | Algebraic existence & infinite lifting: `∀ e≥4, ∀ k, ApMemberOkFrom e (canonicalBase e) k`. Unique representative mod `2^{e+9}`; infinite contracting fiber `C_e`. |
| **PR #16** | **`[C→A]`** | Combinatorial decomposition & residue density (deductive discharge of PR #15 algebra — **not** external axiom debt). |
| **Follow-up** | **`[C]`** | Global dynamics & orbit feed-in: `C_1 ∪ C_2 ∪ C_3 → ⋃_{e≥4} C_e`. |

## Representative vs fiber (do not conflate)

Quotient-space interface between PR #15 and PR #16:

$$
C_e \;\longleftrightarrow\; [b_e] \in \mathbb{N}/2^{e+9}\mathbb{N},
\qquad b_e = \operatorname{canonicalBase}(e).
$$

* **Infinite fiber:** every `x ∈ C_e` realizes `fiberE e` — infinitely many realizers.
* **Unique representative below the modulus:**
  `∃! b < 2^{e+9}, IsCanonicalSeed e b` (and that `b` realizes the word).
  Uniqueness is of the **canonical residue representative**, not of the whole fiber.

## Five-stage governance cascade

| Stufe | Inhalt | Status |
|-------|--------|--------|
| 1 | Eindeutige Koordinate `b_e ∈ [0, 2^{e+9})` | **`[A]` PR #15 (CI green)** |
| 2 | Faseridentifikation `n ∈ C_e ↔ RealizesWord (fiberE e) n` | **`[C→A]` PR #16a/b candidate** |
| 3 | Disjunkte Partition `C_Core6 = (C_1⊔C_2⊔C_3) ⊔ ⊔_{e≥4} C_e` | **`[C→A]` PR #16c/d** |
| 4 | Endliche Zählung → Dichten `1/8` vs `7/8` | **`[C→A]` PR #16e/f** |
| 5 | Globale Zuführung `C_1∪C_2∪C_3 → ⋃_{e≥4} C_e` | **`[C]` Folgeprogramm** |

Promotion rule: after PR #16 CI is green and merge/review accepts a package,
that package moves from `[C→A]` into repo-of-record `[A]`. Until then the
bridge Algebra → Mengenlehre remains formally prepared, not yet promoted.

## Methodical meaning of `[C→A]` in PR #16

`[C→A]` here is **not** unpaid empirical/external hypothesis debt.
It marks a **purely constructive Lean discharge goal**:

* 16a–16e are intended as deductive consequences of algebra already under `[A]` in PR #15.
* They wait only for formal kernel discharge — not for new census data or axioms.
* Package status rises from `[C→A]` to `[A]` only after that package (through 16f for density) closes under CI-green merge.

## PR #16 target ladder — all `[C→A]` until promotion

| Paket | Inhalt | Status |
|-------|--------|--------|
| 16a | `canonicalBase_realizes_of_one_le` (`∀ e≥1`, kanonischer Repräsentant) | `[C→A]` |
| 16b | Faseridentifikation: `C_e = {n \| RealizesWord (fiberE e) n}` | `[C→A]` |
| 16c | Tail-Eindeutigkeit ∧ Disjunktheit | `[C→A]` |
| 16d | Partition `C_Core6 = ⊔_{e≥1} C_e` und Komplement `C_1 ⊔ C_2 ⊔ C_3` | `[C→A]` |
| 16e | Strikte Dichotomie: Expansion `e≤3` vs Kontraktion `e≥4` | `[C→A]` |
| 16f | Endlich-kombinatorische Abzählung mod `2^{m+9}` → Dichten `1/8` : `7/8` | `[C→A]` |
| danach | Zuführung der drei Expansionskanäle | `[C]` |

Candidate Lean may appear on `cursor/core6-cylinder-partition-4007` / PR #16.
It is **not** part of the PR #15 `[A]` claim surface.

## Sharpenings

1. Target for `e≥1` is realization at `canonicalBase e` (canonical representative), not bare `∃ b`.
2. Hard dichotomy: no conserving channel; `e=4` is already strictly contracting.
3. Density is a late reading of finite residue counts mod `2^{m+9}` — not a foundation.
   The deep open step after 16f is dynamical feed-in.
