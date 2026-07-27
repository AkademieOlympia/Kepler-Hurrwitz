# Pre119 — Core6 Cylinder Partition (PR #16)

**Epistemic wall:** This document is the **target architecture** of PR #16.
It must not be confused with repository `[A]` status.

## Three-phase project matrix

| Phase | Label | Nature | Content |
|-------|-------|--------|---------|
| **PR #15** | **`[A]`** | Algebraic | Existence & infinite lifting: `∀ e≥4, ∀ k, ApMemberOkFrom e (canonicalBase e) k`. Unique `b_e < M_e`; infinite contracting fiber `C_e`. |
| **PR #16** | **`[C→A]`** | **Static / combinatorial** | Disjointness, Core6 partition, finite residue count in `ZMod (2^{m+9})` → densities `1/8` vs `7/8`. Deductive discharge of PR #15 algebra — **not** external axiom debt, **not** orbit dynamics. |
| **Follow-up** | **`[C]`** | **Dynamic / trajectorial** | Orbit feed-in / reachability: `C_1 ∪ C_2 ∪ C_3 → ⋃_{e≥4} C_e`. |

### Static vs dynamic (do not conflate)

| | **PR #16 `[C→A]`** | **Follow-up `[C]`** |
|--|--------------------|---------------------|
| Nature | static / combinatorial | dynamic / trajectorial |
| Object | disjointness & state-space decomposition | orbit flow & feed-in |
| Math | residue count in `ZMod (2^{m+9})` | preimage iteration / reachability |
| Claim | `C_e ∩ C_f = ∅` ∧ `∑ δ(C_e) → 1/8` | `C_1 ∪ C_2 ∪ C_3 → ⋃_{e≥4} C_e` |

Why density sits in PR #16: embedding fibers with periods `2^{e+9}` into a common
module `ℤ/2^{m+9}ℤ` is a **purely deductive** consequence of already-proved
congruences. For fixed `m ≥ 4`, each fiber `C_e` (`4 ≤ e ≤ m`) contributes
exactly `2^{m-e}` disjoint residues; summing

$$
\sum_{e=4}^{m} 2^{m-e} = 2^{m-3} - 1
$$

against Core6 modulus size `2^m` yields the limit density `(2^{m-3}-1)/2^m → 1/8`.
No external dynamics required — finite combinatorics in Lean (package **16f**).

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

Packaged on the branch (`[C→A]` until CI/merge); feat `0e26b12`, tip `377c104`:
- `fiberIndexMap_injective`
- `range_fiberIndexMap_eq_canonicalCylinderAP` / `…_eq_canonicalCylinder`
- **`fiberIndexEquiv : Nat ≃ {n // n ∈ canonicalCylinder e}`**  ⇒  `C_e ≃ ℕ`

Type-correct chain (inverses proved separately — no circular kernel deps):

$$
\mathbb{N} \xrightarrow{\Phi_e} \{n : \mathbb{N} \mid n \in C_e\} \subset \mathbb{N}.
$$

### Local coordinate vs inter-fiber density (both PR #16; different tools)

| | Local (`Φ_e` / `fiberIndexEquiv`) | Inter-fiber (`16c`–`16f`) |
|--|----------------------------------|---------------------------|
| Domain | one fiber `C_e` | `⋃_{e≥4} C_e` inside Core6 |
| Period | fixed `M_e = 2^{e+9}` | common `ZMod (2^{m+9})` |
| Tool | `C_e ≃ ℕ` | disjointness ∧ residue sum `∑ 2^{m-e}` |
| Delivers | index bound `Φ_e(k) ≤ N` | densities `1/8` vs `7/8` |

`Φ_e` does **not** replace joint residue counting; both are static/combinatorial
and in-scope for PR #16. Dynamical feed-in remains Follow-up `[C]`.

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
| **#15** | `6004d2b` | **`[A]`** lokale Faser-Existenz & Lifting | CI grün (Lean/Evidence/QG) · Draft · ungemergt |
| **#16** | `377c104` | **`[C→A]`** Inter-Faser-Zerlegung & kombinatorische Dichte | CI queued · Draft · mergeable |
| Folge | — | **`[C]`** dynamische Zuführung / Orbit-Trajektorien | Forschungsfront |

## Immunisierung gegen Kategorienfehler

1. **Typen-Kollaps vermieden:** `Nat ≠_Typ ZMod ≠_Typ Set Nat`.
2. **Eindeutigkeits-Kollaps vermieden:** kanonischer Repräsentant `b_e` ≠ einziger Realisierer (`C_e` unendlich).
3. **Scope-Kollaps vermieden:** lokale Faserstruktur ≠ Inter-Faser-Dichte ≠ Orbit-Zuführung `[C]`.
4. **Statik/Dynamik-Kollaps vermieden:** PR #16 residue combinatorics ≠ Follow-up reachability.

## Final governance cascade (head `377c104`)

| Stufe | Inhalt | Status |
|-------|--------|--------|
| 1 | Eindeutige Koordinate `b_e ∈ [0, 2^{e+9})` & Lifting | **`[A]` PR #15** |
| 2 | Lokale Äquivalenz `ℕ ≃ {n \| n ∈ C_e}` via `fiberIndexEquiv` | **`[C→A]` packaged; promote after CI** |
| 3 | Disjunktheit `e ≠ f ⇒ C_e ∩ C_f = ∅` | **`[C→A]` PR #16c** |
| 4 | Core6-Partition `(C_1⊔C_2⊔C_3) ⊔ ⊔_{e≥4} C_e` | **`[C→A]` PR #16d** |
| 5 | Endliche Modul-Zählung `∑_{e=4}^m 2^{m-e} = 2^{m-3}-1` → Dichten `1/8` : `7/8` | **`[C→A]` PR #16f** |
| 6 | Dynamische Zuführung `C_1∪C_2∪C_3 → ⋃_{e≥4} C_e` | **`[C]` Folgeprogramm** |

Promotion rule: after PR #16 CI is green and merge/review accepts a package,
that package moves from `[C→A]` into repo-of-record `[A]`. Until then the
bridge Algebra → Mengenlehre remains formally prepared, not yet promoted.

## Methodical meaning of `[C→A]` in PR #16

`[C→A]` here is **not** unpaid empirical/external hypothesis debt.
It marks a **purely constructive Lean discharge goal**:

* 16a–16f are intended as deductive consequences of algebra already under `[A]` in PR #15
  (static combinatorics through residue density; **not** dynamical feed-in).
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
