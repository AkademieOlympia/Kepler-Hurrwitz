# Pre119 — Core6 Cylinder Partition (PR #16)

**Epistemic wall:** This document is the **target architecture** of PR #16.
It must not be confused with repository `[A]` status.

## Three-phase project matrix

| Phase | Label | Content |
|-------|-------|---------|
| **PR #15** | **`[A]`** | Algebraic existence & infinite lifting: `∀ e≥4, ∀ k, ApMemberOkFrom e (canonicalBase e) k`. Unique representative mod `2^{e+9}`; infinite contracting fiber `C_e`. |
| **PR #16** | **`[C→A]`** | Combinatorial decomposition & residue density (deductive discharge of PR #15 algebra — **not** external axiom debt). |
| **Follow-up** | **`[C]`** | Global dynamics & orbit feed-in: `C_1 ∪ C_2 ∪ C_3 → ⋃_{e≥4} C_e`. |

## Dreifache Objektklarheit (typenrein in Lean 4)

Three universes — a mathematical `≠` across types is a Lean kernel fatal error:

| Objekt | Symbol | Lean-Typ | Rolle |
|--------|--------|----------|-------|
| Repräsentant | `b_e = canonicalBase e` | `Nat` | ausgezeichneter Start `b_e < 2^{e+9}` |
| Quotientenelement | `[b_e]` | `ZMod (2^(e+9))` | Punkt im Modulraum |
| Urbildfaser | `C_e` | `Set Nat` | unendliche Teilmenge von `ℕ` |

Kernel definitions (PR #16):

```lean
def residueMap (e : Nat) : Nat → ZMod (seedModulus e) :=
  fun n => (n : ZMod (seedModulus e))
def canonicalCylinder (e : Nat) : Set Nat :=
  residueMap e ⁻¹' {residueMap e (canonicalBase e)}
```

## Extensionale Mengengleichheit (nicht Isomorphie)

`canonicalCylinder_eq_ap` is **`Set.ext`-equality in `Set Nat`**, not an
isomorphism of two spaces:

$$
\operatorname{canonicalCylinder}(e)
=
\operatorname{canonicalCylinderAP}(e)
\quad\text{in }\operatorname{Set}\mathbb{N}.
$$

Two syntactic presentations of **exactly the same** subset of `ℕ`.

Bridge architecture:

```
b_e = canonicalBase e : Nat
        │  π_e = residueMap e
        ▼
π_e(b_e) : ZMod (seedModulus e)
        │  π_e ⁻¹' {π_e(b_e)}
        ▼
canonicalCylinder e : Set Nat
        ║  canonicalCylinder_eq_ap  (extensional equality)
        ▼
canonicalCylinderAP e : Set Nat
  {n | ∃ k, n = b_e + k * seedModulus e}
```

### Two uniqueness layers
1. **Representative `b_e`:** unique in `[0, M_e)` — `[A]` in PR #15.
2. **Offset `k`:** for fixed `n ∈ C_e`, unique via Euclidean division
   `n = b_e + k·M_e` (`canonicalCylinderAP_div_eq_index`,
   `existsUnique_index_of_mem_canonicalCylinderAP`).

### Three uniqueness layers (do not conflate)

| Ebene | Aussage | Rolle |
|-------|---------|-------|
| 1. Repräsentanteneindeutigkeit | `∃! b_e < M_e, IsCanonicalSeed e b_e` | Koordinatenursprung in `[0,M_e)` — `[A]` PR #15 |
| 2. Fasergleichheit | `canonicalCylinder e = canonicalCylinderAP e` | `Set.ext` in `Set Nat` — `[C→A]` |
| 3. Indexeindeutigkeit | `n ∈ C_e ⇒ ∃! k, n = b_e + k·M_e` | Offset via `/` without `Nat.sub` — `[C→A]` |

Global coordinates for `n ∈ C_e`:

$$
n \longleftrightarrow (e,k),\qquad n = b_e + k M_e,
$$

with `e` the fiber/tail coordinate, `b_e` the canonical representative, and `k` the
position inside the fiber (`Φ_e : k ↦ b_e + k M_e` = `fiberIndexMap`).

Packaged on the branch (`[C→A]` until CI/merge):
- `fiberIndexMap_injective`
- `range_fiberIndexMap_eq_canonicalCylinderAP` / `…_eq_canonicalCylinder`
- `fiberIndexEquiv : Nat ≃ {n // n ∈ canonicalCylinder e}`  ⇒  `C_e ≃ ℕ`

Local fiber counting uses `Φ_e(k) ≤ N`; the global `1/8` density still needs
disjointness + a common finite modulus across varying `M_e`.

### Kernel-Beweisbarkeit ≠ Repository-Status `[A]`

| | Kernel-Beweisbarkeit | Repository-Status `[A]` |
|--|----------------------|------------------------|
| Ebene | Pure Logik / Lean-Typentheorie | Prozess / Evidence Register |
| Gültigkeit | baut lokal fehlerfrei | CI-grün ∧ Review ∧ Merge |
| Bedeutung | mathematisch korrekt | offizielle Projektevidenz |

### Promotion rule (rigid)
`Candidate on branch ∧ CI green ∧ Review ∧ Merge ⟹ [C→A] → [A]`.

## Theoremstatus ≠ Prozessstatus

| PR | Head | Theoremstatus | Process-Status |
|----|------|---------------|----------------|
| **#15** | `6004d2b` | **`[A]`** eindeutige Koordinate & Lifting `e≥4` | CI grün (Lean/Evidence/QG) · Draft · ungemergt |
| **#16** | `28e6d43` | **`[C→A]`** Faseridentifikation, Partition, Zählung | CI queued · Draft |
| Folge | — | **`[C]`** Zuführung `C_1,C_2,C_3` | Forschungsfront |

## Immunisierung gegen Kategorienfehler

1. **Typen-Kollaps vermieden:** `Nat ≠_Typ ZMod ≠_Typ Set Nat`.
2. **Eindeutigkeits-Kollaps vermieden:** kanonischer Repräsentant `b_e` ≠ einziger Realisierer (`C_e` unendlich).
3. **Scope-Kollaps vermieden:** lokale Faser-/Strukturbeweise ≠ globale Orbit-Zuführung `[C]`.

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
