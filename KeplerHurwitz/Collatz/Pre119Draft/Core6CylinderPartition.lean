import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Ring.GeomSum
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Real.Basic
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Data.ZMod.Basic
import Mathlib.Order.Filter.AtTopBot.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.IntervalCases
import Mathlib.Topology.UniformSpace.Real
import KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
import KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — Core6CylinderPartition (PR #16)

**Closure candidate:** mathematical freeze at Head `3740183` (+ certificate commit).
Only review/CI fixes allowed in this PR thereafter — no natural density, no
reachability, no further orbit dynamics.

**Epistemic wall:**
- Repo-of-record `[A]` stops at PR #15:
  `∀ e ≥ 4, ∀ k, ApMemberOkFrom e (canonicalBase e) k`.
- This file is the **target architecture** of PR #16. Packages below stay
  **`[C→A]`** until CI is green on PR #16 and the stack is merged. Do not read
  them as trunk / PR #15 `[A]` claims.

**Target ladder (status before accepted `[A]` promotion):**

| Paket | Inhalt | Status |
|-------|--------|--------|
| 16a | kanonische Realisierung für `e≥1` | `[C→A]` |
| 16b | Quotientenfaser = AP = Realisierungsfaser | `[C→A]` |
| 16c | Tail-Eindeutigkeit und Disjunktheit | `[C→A]` |
| 16d | Core6-Partition und Drei-Kanal-Komplement | `[C→A]` |
| 16e | Expansion `e≤3` vs Kontraktion `e≥4` | `[C→A]` |
| 16f | endliche Residuen, Inklusion, Kardinalität, Proportion, `Tendsto` | `[C→A]` |
| danach | Zuführung `C_1,C_2,C_3` → kontraktive Familie | `[C]` (separate PR) |

Import entry point: `core6StaticDyadicCertificate`.

Claim wall: relative dyadic density **yes**; natural density **no**;
global Collatz **no**; dynamical feed-in **no**.

No Collatz claim. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition

open Set
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine
open KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra
open KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
open KeplerHurwitz.Collatz.Pre119Draft.ApMemberFromTransfer

/-! ### Package A: type-correct cylinder identification

Three Lean universes (do not collapse):
* `canonicalBase e : Nat` — representative coordinate
* `residueMap e (canonicalBase e) : ZMod (seedModulus e)` — quotient point
* `canonicalCylinder e : Set Nat` — infinite preimage fiber
-/

/-- Residue projection `π_e : ℕ → ℤ/2^{e+9}ℤ`. -/
def residueMap (e : Nat) : Nat → ZMod (seedModulus e) :=
  fun n => (n : ZMod (seedModulus e))

/--
`[C→A]` Type-correct cylinder: preimage of the singleton residue class
`{residueMap e (canonicalBase e)}` under `residueMap e`.
-/
def canonicalCylinder (e : Nat) : Set Nat :=
  residueMap e ⁻¹' {residueMap e (canonicalBase e)}

/-- AP presentation of the same fiber (linked by `canonicalCylinder_eq_ap`). -/
def canonicalCylinderAP (e : Nat) : Set Nat :=
  {n | ∃ k : Nat, n = canonicalBase e + k * seedModulus e}

theorem mem_canonicalCylinder {e n : Nat} :
    n ∈ canonicalCylinder e ↔
      residueMap e n = residueMap e (canonicalBase e) := by
  simp [canonicalCylinder, Set.mem_preimage, Set.mem_singleton_iff]

theorem mem_canonicalCylinderAP {e n : Nat} :
    n ∈ canonicalCylinderAP e ↔
      ∃ k : Nat, n = canonicalBase e + k * seedModulus e :=
  Iff.rfl

/--
`[C→A]` Extensional equality in `Set Nat` (via `Set.ext`): the ZMod-preimage
cylinder and the AP presentation are the **same** subset of `ℕ`, not merely
isomorphic spaces.
-/
theorem canonicalCylinder_eq_ap (e : Nat) :
    canonicalCylinder e = canonicalCylinderAP e := by
  ext n
  constructor
  · intro hn
    have hres : residueMap e n = residueMap e (canonicalBase e) :=
      (mem_canonicalCylinder).1 hn
    have hmod : n ≡ canonicalBase e [MOD seedModulus e] :=
      (ZMod.natCast_eq_natCast_iff _ _ (seedModulus e)).1 hres
    have hbmod : canonicalBase e % seedModulus e = canonicalBase e :=
      Nat.mod_eq_of_lt (canonicalBase_lt e)
    have hnmod : n % seedModulus e = canonicalBase e := by
      have : n % seedModulus e = canonicalBase e % seedModulus e := hmod
      rwa [hbmod] at this
    refine ⟨n / seedModulus e, ?_⟩
    calc
      n = seedModulus e * (n / seedModulus e) + n % seedModulus e :=
        (Nat.div_add_mod n (seedModulus e)).symm
      _ = (n / seedModulus e) * seedModulus e + n % seedModulus e := by ring
      _ = canonicalBase e + (n / seedModulus e) * seedModulus e := by
            rw [hnmod]; ring
  · intro hn
    obtain ⟨k, rfl⟩ := hn
    refine (mem_canonicalCylinder).2 ?_
    change (↑(canonicalBase e + k * seedModulus e) : ZMod (seedModulus e)) =
      ↑(canonicalBase e)
    simp [Nat.cast_add, Nat.cast_mul, CharP.cast_eq_zero]

theorem seedModulus_eq_classPeriod (e : Nat) :
    seedModulus e = classPeriod e := by
  simp [seedModulus, classPeriod, fiberE_sum]
  ring

theorem seedModulus_eq_sum_succ (e : Nat) :
    seedModulus e = 2 ^ ((fiberE e).sum + 1) := by
  simp [seedModulus, fiberE_sum]
  ring

/--
`[C→A]` Index uniqueness for fixed `n` in the AP presentation: Euclidean division
recovers `k` without invoking truncated `Nat.sub`.
Uses `canonicalBase_lt e` from PR #15 internally.
-/
theorem canonicalCylinderAP_div_eq_index {e n k : Nat}
    (hk : n = canonicalBase e + k * seedModulus e) :
    n / seedModulus e = k := by
  have hM : 0 < seedModulus e := seedModulus_pos e
  have hb : canonicalBase e < seedModulus e := canonicalBase_lt e
  have hb0 : canonicalBase e / seedModulus e = 0 := Nat.div_eq_of_lt hb
  calc
    n / seedModulus e
        = (canonicalBase e + k * seedModulus e) / seedModulus e := by rw [hk]
    _ = canonicalBase e / seedModulus e + k :=
          Nat.add_mul_div_right (canonicalBase e) k hM
    _ = 0 + k := by rw [hb0]
    _ = k := by simp

/--
`[C→A]` For each `n` in the AP cylinder there is a unique offset index `k`.
This is bijectivity of `Φ_e : k ↦ b_e + k·M_e` on the element level.
-/
theorem existsUnique_index_of_mem_canonicalCylinderAP {e n : Nat}
    (hn : n ∈ canonicalCylinderAP e) :
    ∃! k : Nat, n = canonicalBase e + k * seedModulus e := by
  obtain ⟨k, hk⟩ := hn
  refine ExistsUnique.intro k hk ?_
  intro k' hk'
  have h1 := canonicalCylinderAP_div_eq_index hk
  have h2 := canonicalCylinderAP_div_eq_index hk'
  omega

/-- Parametrization of the AP cylinder by the fiber index `k`. -/
noncomputable def fiberIndexMap (e k : Nat) : Nat :=
  canonicalBase e + k * seedModulus e

theorem fiberIndexMap_mem (e k : Nat) :
    fiberIndexMap e k ∈ canonicalCylinderAP e :=
  ⟨k, rfl⟩

theorem fiberIndexMap_div (e k : Nat) :
    fiberIndexMap e k / seedModulus e = k :=
  canonicalCylinderAP_div_eq_index rfl

/-- `[C→A]` Left inverse ⇒ injectivity of `Φ_e`. -/
theorem fiberIndexMap_injective (e : Nat) :
    Function.Injective (fiberIndexMap e) := by
  intro k l h
  have hdiv := congrArg (fun n => n / seedModulus e) h
  simpa [fiberIndexMap_div] using hdiv

/-- `[C→A]` Image of `Φ_e` is exactly the AP cylinder. -/
theorem range_fiberIndexMap_eq_canonicalCylinderAP (e : Nat) :
    Set.range (fiberIndexMap e) = canonicalCylinderAP e := by
  ext n
  constructor
  · rintro ⟨k, rfl⟩
    exact fiberIndexMap_mem e k
  · intro hn
    obtain ⟨k, hk⟩ := hn
    exact ⟨k, hk.symm⟩

/-- `[C→A]` Same range equality for the ZMod-preimage cylinder. -/
theorem range_fiberIndexMap_eq_canonicalCylinder (e : Nat) :
    Set.range (fiberIndexMap e) = canonicalCylinder e := by
  rw [range_fiberIndexMap_eq_canonicalCylinderAP, ← canonicalCylinder_eq_ap]

theorem fiberIndexMap_surjective_onto_cylinder (e : Nat) :
    Function.Surjective
      (fun k : Nat => (⟨fiberIndexMap e k,
        by simpa [← canonicalCylinder_eq_ap] using fiberIndexMap_mem e k⟩ :
          {n : Nat // n ∈ canonicalCylinder e})) := by
  intro ⟨n, hn⟩
  have hap : n ∈ canonicalCylinderAP e := by
    rwa [canonicalCylinder_eq_ap] at hn
  obtain ⟨k, hk⟩ := hap
  refine ⟨k, ?_⟩
  apply Subtype.ext
  exact hk.symm

/--
`[C→A]` Type-correct equivalence `ℕ ≃ C_e`:
`toFun = Φ_e`, `invFun = (· / M_e)`.
-/
noncomputable def fiberIndexEquiv (e : Nat) :
    Nat ≃ {n : Nat // n ∈ canonicalCylinder e} where
  toFun k :=
    ⟨fiberIndexMap e k, by simpa [← canonicalCylinder_eq_ap] using fiberIndexMap_mem e k⟩
  invFun n := n.1 / seedModulus e
  left_inv k := fiberIndexMap_div e k
  right_inv := by
    intro ⟨n, hn⟩
    apply Subtype.ext
    have hap : n ∈ canonicalCylinderAP e := by
      rwa [canonicalCylinder_eq_ap] at hn
    obtain ⟨k, hk⟩ := hap
    have hdiv := canonicalCylinderAP_div_eq_index hk
    calc
      fiberIndexMap e (n / seedModulus e)
          = fiberIndexMap e k := by rw [hdiv]
      _ = n := hk.symm

/-- Odd affine quotient on `fiberE e` yields the canonical seed congruence. -/
theorem modEq_of_affineOddQuotient_fiberE {e n : Nat}
    (hAQ : AffineOddQuotient (fiberE e) n) :
    (coeff3 * n + 2347) ≡ 2 ^ (e + 8) [MOD seedModulus e] := by
  obtain ⟨q, hq, heq⟩ := hAQ
  have hsum : (fiberE e).sum = e + 8 := fiberE_sum_eight_add' e
  have hlen : (fiberE e).length = 7 := fiberE_length_seven' e
  have hC : wordC (fiberE e) = 2347 := wordC_fiberE e
  have hcoeff : coeff3 = 3 ^ 7 := coeff3_eq_three_pow
  have heq' : q * 2 ^ (e + 8) = coeff3 * n + 2347 := by
    calc
      q * 2 ^ (e + 8)
          = q * 2 ^ (fiberE e).sum := by rw [hsum]
      _ = 3 ^ (fiberE e).length * n + wordC (fiberE e) := heq
      _ = 3 ^ 7 * n + 2347 := by rw [hlen, hC]
      _ = coeff3 * n + 2347 := by rw [hcoeff]
  obtain ⟨t, ht⟩ := hq
  have hform :
      coeff3 * n + 2347 = 2 ^ (e + 8) + t * seedModulus e := by
    calc
      coeff3 * n + 2347 = q * 2 ^ (e + 8) := heq'.symm
      _ = (2 * t + 1) * 2 ^ (e + 8) := by rw [ht]
      _ = 2 ^ (e + 8) + t * (2 ^ (e + 9)) := by ring
      _ = 2 ^ (e + 8) + t * seedModulus e := by rw [seedModulus]
  have hlt : 2 ^ (e + 8) < seedModulus e :=
    Nat.pow_lt_pow_right (by decide : 1 < 2) (by omega : e + 8 < e + 9)
  change (coeff3 * n + 2347) % seedModulus e = (2 ^ (e + 8)) % seedModulus e
  rw [hform, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hlt]

/-- From a realizing start, recover membership in the unique canonical cylinder. -/
theorem mem_canonicalCylinder_of_realizes {e n : Nat} (_he : 1 ≤ e)
    (h : RealizesWord (fiberE e) n) :
    n ∈ canonicalCylinder e := by
  have hne : fiberE e ≠ [] := by
    rw [fiberE_list]; simp
  have hAQ := affineOddQuotient_of_realizesWord hne h
  have hmod := modEq_of_affineOddQuotient_fiberE hAQ
  let M := seedModulus e
  have hMpos : 0 < M := seedModulus_pos e
  have hnlt : n % M < M := Nat.mod_lt n hMpos
  have hcongr :
      (coeff3 * (n % M) + 2347) ≡ 2 ^ (e + 8) [MOD M] := by
    have hn : (n % M) ≡ n [MOD M] := Nat.mod_modEq n M
    have hmul := hn.mul_left coeff3
    exact (hmul.add_right 2347).trans hmod
  have hseed : IsCanonicalSeed e (n % M) := ⟨hnlt, hcongr⟩
  have huniq : n % M = canonicalBase e := canonicalBase_unique hseed
  have hap : n ∈ canonicalCylinderAP e := by
    refine ⟨n / M, ?_⟩
    calc
      n = M * (n / M) + n % M := (Nat.div_add_mod n M).symm
      _ = (n / M) * M + n % M := by ring
      _ = canonicalBase e + (n / M) * M := by rw [huniq]; ring
      _ = canonicalBase e + (n / M) * seedModulus e := rfl
  exact (canonicalCylinder_eq_ap e ▸ hap)

/-- Canonical cylinder members realize the fiber word (any `e ≥ 1`). -/
theorem realizes_of_mem_canonicalCylinder {e n : Nat} (he : 1 ≤ e)
    (hn : n ∈ canonicalCylinder e) :
    RealizesWord (fiberE e) n := by
  have hap : n ∈ canonicalCylinderAP e := canonicalCylinder_eq_ap e ▸ hn
  obtain ⟨k, rfl⟩ := hap
  have hbase := canonicalBase_realizes_of_one_le he
  have hper : seedModulus e = 2 ^ ((fiberE e).sum + 1) :=
    seedModulus_eq_sum_succ e
  simpa [hper] using
    realizesWord_add_pow (E := fiberE e) (n := canonicalBase e) (k := k) hbase

/--
`[C→A]` Completeness bridge (PR #16 target): the canonical AP is exactly the realization fiber of
`fiberE e` (for every positive tail exponent).
-/
theorem mem_canonicalCylinder_iff_realizes_fiberE {e n : Nat} (he : 1 ≤ e) :
    n ∈ canonicalCylinder e ↔ RealizesWord (fiberE e) n :=
  ⟨realizes_of_mem_canonicalCylinder he,
    mem_canonicalCylinder_of_realizes he⟩

/-! ### Package B: disjointness via unique local valuation -/

theorem realizesWord_append {E F : List Nat} {n : Nat} :
    RealizesWord (E ++ F) n ↔
      RealizesWord E n ∧ RealizesWord F (realizedImage n E) := by
  induction E generalizing n with
  | nil =>
    simp [RealizesWord, realizedImage]
  | cons e es ih =>
    constructor
    · intro h
      obtain ⟨hodd, hval, hrest⟩ := h
      have hrec := (ih (n := nextOdd n)).1 hrest
      refine ⟨⟨hodd, hval, hrec.1⟩, ?_⟩
      simpa [realizedImage] using hrec.2
    · intro ⟨hE, hF⟩
      obtain ⟨hodd, hval, hrest⟩ := hE
      have htail : RealizesWord (es ++ F) (nextOdd n) :=
        (ih (n := nextOdd n)).2 ⟨hrest, by simpa [realizedImage] using hF⟩
      exact ⟨hodd, hval, htail⟩

theorem fiberE_eq_core6_concat (e : Nat) :
    fiberE e = core6 ++ [e] :=
  rfl

theorem valuationStep_eq_of_realizes_singleton {e n : Nat}
    (h : RealizesWord [e] n) :
    valuationStep n = e := by
  obtain ⟨_, hval, _⟩ := h
  exact hval

/--
`[C→A]` The seventh (tail) exponent after a shared Core6 prefix is unique.
-/
theorem tailExponent_unique {e f n : Nat}
    (he : RealizesWord (fiberE e) n)
    (hf : RealizesWord (fiberE f) n) :
    e = f := by
  rw [fiberE_eq_core6_concat] at he hf
  have hE := (realizesWord_append (E := core6) (F := [e])).1 he
  have hF := (realizesWord_append (E := core6) (F := [f])).1 hf
  have hvale := valuationStep_eq_of_realizes_singleton hE.2
  have hvalf := valuationStep_eq_of_realizes_singleton hF.2
  exact hvale.symm.trans hvalf

/--
`[C→A]` Pairwise disjointness of canonical cylinders: a common start cannot realize
two distinct exact seventh valuations after the shared Core6 prefix.
-/
theorem canonicalCylinders_pairwise_disjoint {e f : Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f) (hef : e ≠ f) :
    Disjoint (canonicalCylinder e) (canonicalCylinder f) := by
  refine Set.disjoint_left.2 ?_
  intro n hne hnf
  have hRe : RealizesWord (fiberE e) n :=
    (mem_canonicalCylinder_iff_realizes_fiberE he).1 hne
  have hRf : RealizesWord (fiberE f) n :=
    (mem_canonicalCylinder_iff_realizes_fiberE hf).1 hnf
  exact hef (tailExponent_unique hRe hRf)

/-- Alias matching the PR #16 naming note. -/
theorem canonicalCylinders_disjoint {e f : Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f) (hef : e ≠ f) :
    Disjoint (canonicalCylinder e) (canonicalCylinder f) :=
  canonicalCylinders_pairwise_disjoint he hf hef

/-! ### Package B/C goals: full Core6 partition and small-tail complement -/

/-- Semantic Core6 cylinder: starts that realize the fixed Core6 prefix. -/
def core6Cylinder : Set Nat :=
  {n | RealizesWord core6 n}

theorem mem_core6Cylinder {n : Nat} :
    n ∈ core6Cylinder ↔ RealizesWord core6 n :=
  Iff.rfl

theorem realizedImage_odd_of_ne_nil {E : List Nat} {n : Nat}
    (hne : E ≠ []) (h : RealizesWord E n) :
    Odd (realizedImage n E) := by
  match E, hne with
  | [], hne => exact (hne rfl).elim
  | e :: es, _ => exact realizedImage_odd_of_cons h

theorem valuationStep_pos_of_odd {x : Nat} (hx : Odd x) :
    1 ≤ valuationStep x := by
  have hx1 : x % 2 = 1 := Nat.odd_iff.mp hx
  have heven : Even (3 * x + 1) :=
    Nat.even_iff.mpr (by simp [Nat.add_mod, Nat.mul_mod, hx1])
  have hdvd : 2 ∣ 3 * x + 1 := even_iff_two_dvd.mp heven
  have hne : 3 * x + 1 ≠ 0 := by omega
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have hne0 : padicValNat 2 (3 * x + 1) ≠ 0 :=
    (dvd_iff_padicValNat_ne_zero hne).1 hdvd
  simpa [valuationStep] using Nat.one_le_iff_ne_zero.2 hne0

theorem core6_ne_nil : core6 ≠ [] := by native_decide

/-- Contracting family inside the Core6 cylinder (`e ≥ 4`). -/
def contractingCore6 : Set Nat :=
  ⋃ e : Nat, ⋃ (_ : 4 ≤ e), canonicalCylinder e

/-- The three small (non-contracting / below-margin) Core6 tail channels. -/
def smallTailCore6 : Set Nat :=
  canonicalCylinder 1 ∪ canonicalCylinder 2 ∪ canonicalCylinder 3

/-- Full partition goal: every Core6 realization belongs to a positive-tail cylinder. -/
def Core6PartitionGoal : Prop :=
  core6Cylinder = ⋃ e : Nat, ⋃ (_ : 1 ≤ e), canonicalCylinder e

/-- Complement of the contracting family is exactly the three small tails. -/
def Core6ComplementSmallTailsGoal : Prop :=
  core6Cylinder \ contractingCore6 = smallTailCore6

private theorem mem_contractingCore6 {n : Nat} :
    n ∈ contractingCore6 ↔
      ∃ e : Nat, 4 ≤ e ∧ n ∈ canonicalCylinder e := by
  simp [contractingCore6]

private theorem mem_smallTailCore6 {n : Nat} :
    n ∈ smallTailCore6 ↔
      n ∈ canonicalCylinder 1 ∨ n ∈ canonicalCylinder 2 ∨ n ∈ canonicalCylinder 3 := by
  simp [smallTailCore6, or_assoc]

/--
`[C→A]` Every Core6 realization has a unique positive tail exponent, and belongs to
the corresponding canonical cylinder. Conversely every positive-tail cylinder
lies in the Core6 cylinder.
-/
theorem core6Cylinder_eq_iUnion_tailCylinders :
    core6Cylinder =
      ⋃ e : Nat, ⋃ (_ : 1 ≤ e), canonicalCylinder e := by
  ext n
  constructor
  · intro hn
    have hcore : RealizesWord core6 n := hn
    set x := realizedImage n core6
    have hodd : Odd x := realizedImage_odd_of_ne_nil core6_ne_nil hcore
    set e := valuationStep x
    have he : 1 ≤ e := valuationStep_pos_of_odd hodd
    have hsing : RealizesWord [e] x :=
      ⟨Nat.odd_iff.mp hodd, rfl, trivial⟩
    have hfib : RealizesWord (fiberE e) n := by
      rw [fiberE_eq_core6_concat]
      exact (realizesWord_append (E := core6) (F := [e])).2 ⟨hcore, hsing⟩
    have hmem : n ∈ canonicalCylinder e :=
      mem_canonicalCylinder_of_realizes he hfib
    exact mem_iUnion.2 ⟨e, mem_iUnion.2 ⟨he, hmem⟩⟩
  · intro hn
    rcases mem_iUnion.1 hn with ⟨e, he'⟩
    rcases mem_iUnion.1 he' with ⟨he, hmem⟩
    have hR : RealizesWord (fiberE e) n :=
      realizes_of_mem_canonicalCylinder he hmem
    rw [fiberE_eq_core6_concat] at hR
    exact ((realizesWord_append (E := core6) (F := [e])).1 hR).1

/-
Candidate discharge of partition goal (promotes to [A] only after CI/merge).
-/
theorem core6PartitionGoal : Core6PartitionGoal :=
  core6Cylinder_eq_iUnion_tailCylinders

/--
`[C→A]` The Core6 mass outside the contracting family `e ≥ 4` is exactly the three
small channels `e ∈ {1,2,3}` — not a diffuse remainder.
-/
theorem core6_complement_contracting_eq_smallTails :
    core6Cylinder \ contractingCore6 = smallTailCore6 := by
  ext n
  constructor
  · intro hn
    have hcore : n ∈ core6Cylinder := hn.1
    have hncon : n ∉ contractingCore6 := hn.2
    have hU := (Set.ext_iff.1 core6Cylinder_eq_iUnion_tailCylinders n).1 hcore
    rcases mem_iUnion.1 hU with ⟨e, he'⟩
    rcases mem_iUnion.1 he' with ⟨he, hmem⟩
    have hlt : e < 4 := by
      by_contra hge
      have : 4 ≤ e := Nat.le_of_not_gt hge
      exact hncon (mem_contractingCore6.2 ⟨e, this, hmem⟩)
    interval_cases e
    · exact mem_smallTailCore6.2 (Or.inl hmem)
    · exact mem_smallTailCore6.2 (Or.inr (Or.inl hmem))
    · exact mem_smallTailCore6.2 (Or.inr (Or.inr hmem))
  · intro hn
    refine ⟨?hcore, ?hncon⟩
    · have : n ∈ ⋃ e : Nat, ⋃ (_ : 1 ≤ e), canonicalCylinder e := by
        rcases (mem_smallTailCore6.1 hn) with h1 | h2 | h3
        · exact mem_iUnion.2 ⟨1, mem_iUnion.2 ⟨by decide, h1⟩⟩
        · exact mem_iUnion.2 ⟨2, mem_iUnion.2 ⟨by decide, h2⟩⟩
        · exact mem_iUnion.2 ⟨3, mem_iUnion.2 ⟨by decide, h3⟩⟩
      exact (Set.ext_iff.1 core6Cylinder_eq_iUnion_tailCylinders n).2 this
    · intro hcon
      rcases mem_contractingCore6.1 hcon with ⟨e, he4, hmem_e⟩
      rcases (mem_smallTailCore6.1 hn) with h1 | h2 | h3
      · exact Set.disjoint_left.1
          (canonicalCylinders_pairwise_disjoint (by decide : 1 ≤ 1) (by omega) (by omega))
          h1 hmem_e
      · exact Set.disjoint_left.1
          (canonicalCylinders_pairwise_disjoint (by decide : 1 ≤ 2) (by omega) (by omega))
          h2 hmem_e
      · exact Set.disjoint_left.1
          (canonicalCylinders_pairwise_disjoint (by decide : 1 ≤ 3) (by omega) (by omega))
          h3 hmem_e

theorem core6ComplementSmallTailsGoal : Core6ComplementSmallTailsGoal :=
  core6_complement_contracting_eq_smallTails

/-- Alias matching the PR #16 naming note. -/
theorem core6_diff_contracting_eq_smallTails :
    core6Cylinder \ contractingCore6 =
      canonicalCylinder 1 ∪ canonicalCylinder 2 ∪ canonicalCylinder 3 := by
  simpa [smallTailCore6] using core6_complement_contracting_eq_smallTails

/-- Alias matching the PR #16 naming note. -/
theorem core6Cylinder_eq_iUnion_canonicalCylinders :
    core6Cylinder = ⋃ e : Nat, ⋃ (_ : 1 ≤ e), canonicalCylinder e :=
  core6Cylinder_eq_iUnion_tailCylinders

/-! ### Package D: expanding vs contracting phase boundary -/

private theorem two_pow_lt_three_pow_seven_of_le_three {e : Nat}
    (he1 : 1 ≤ e) (he3 : e ≤ 3) :
    2 ^ (e + 8) < 3 ^ 7 := by
  interval_cases e <;> native_decide

/--
`[C→A]` For tails `e ∈ {1,2,3}`, every realizing start is strictly expanding on the
seven-step Core6++[e] block (`2^{e+8} < 3^7`).
-/
theorem expands_fiberE_of_le_three {e n : Nat}
    (he1 : 1 ≤ e) (he3 : e ≤ 3)
    (hn : RealizesWord (fiberE e) n) :
    n < realizedImage n (fiberE e) := by
  have hmul := realizedImage_mul_pow hn
  have hsum : (fiberE e).sum = e + 8 := fiberE_sum_eight_add' e
  have hlen : (fiberE e).length = 7 := fiberE_length_seven' e
  have hC : wordC (fiberE e) = 2347 := wordC_fiberE e
  have hpow_lt : 2 ^ (e + 8) < 3 ^ 7 :=
    two_pow_lt_three_pow_seven_of_le_three he1 he3
  have hlist : fiberE e = [1, 1, 1, 1, 2, 2, e] := fiberE_list e
  have hn1 : 1 ≤ n := by
    rw [hlist] at hn
    exact one_le_of_realizes_cons hn
  have hstrict :
      3 ^ 7 * n + 2347 > n * 2 ^ (e + 8) := by
    have hmul_lt : n * 2 ^ (e + 8) < n * 3 ^ 7 :=
      Nat.mul_lt_mul_of_pos_left hpow_lt hn1
    have : n * 3 ^ 7 ≤ 3 ^ 7 * n + 2347 := by
      rw [Nat.mul_comm]
      exact Nat.le_add_right _ _
    exact Nat.lt_of_lt_of_le hmul_lt this
  have himg :
      realizedImage n (fiberE e) * 2 ^ (e + 8) =
        3 ^ 7 * n + 2347 := by
    simpa [hsum, hlen, hC] using hmul
  have hpos : 0 < 2 ^ (e + 8) := Nat.pow_pos (by decide : 0 < 2)
  have : realizedImage n (fiberE e) * 2 ^ (e + 8) >
      n * 2 ^ (e + 8) := by
    rwa [himg]
  have hswap :
      2 ^ (e + 8) * realizedImage n (fiberE e) >
        2 ^ (e + 8) * n := by
    simpa [Nat.mul_comm] using this
  exact (Nat.mul_lt_mul_left hpos).mp hswap

/-- Expanding Core6 mass: the three small channels. -/
def expandingCore6 : Set Nat := smallTailCore6

theorem expands_of_mem_smallTail {n : Nat} (hn : n ∈ smallTailCore6) :
    ∃ e : Nat, 1 ≤ e ∧ e ≤ 3 ∧
      RealizesWord (fiberE e) n ∧ n < realizedImage n (fiberE e) := by
  rcases mem_smallTailCore6.1 hn with h1 | h2 | h3
  · refine ⟨1, by decide, by decide, ?_, ?_⟩
    · exact realizes_of_mem_canonicalCylinder (by decide) h1
    · exact expands_fiberE_of_le_three (by decide) (by decide)
        (realizes_of_mem_canonicalCylinder (by decide) h1)
  · refine ⟨2, by decide, by decide, ?_, ?_⟩
    · exact realizes_of_mem_canonicalCylinder (by decide) h2
    · exact expands_fiberE_of_le_three (by decide) (by decide)
        (realizes_of_mem_canonicalCylinder (by decide) h2)
  · refine ⟨3, by decide, by decide, ?_, ?_⟩
    · exact realizes_of_mem_canonicalCylinder (by decide) h3
    · exact expands_fiberE_of_le_three (by decide) (by decide)
        (realizes_of_mem_canonicalCylinder (by decide) h3)

/--
`[C→A]` Structural Core6 phase split:
expanding channels `e=1,2,3` disjointly union the contracting family `e≥4`.
-/
theorem core6Cylinder_eq_expanding_disjoint_union_contracting :
    core6Cylinder = expandingCore6 ∪ contractingCore6 ∧
      Disjoint expandingCore6 contractingCore6 := by
  refine ⟨?heq, ?hdisj⟩
  · have hdiff := core6_complement_contracting_eq_smallTails
    -- A = (A \ B) ∪ B when B ⊆ A
    have hsub : contractingCore6 ⊆ core6Cylinder := by
      intro n hn
      rcases mem_contractingCore6.1 hn with ⟨e, he4, hmem⟩
      have : n ∈ ⋃ e : Nat, ⋃ (_ : 1 ≤ e), canonicalCylinder e :=
        mem_iUnion.2 ⟨e, mem_iUnion.2 ⟨by omega, hmem⟩⟩
      exact (Set.ext_iff.1 core6Cylinder_eq_iUnion_tailCylinders n).2 this
    -- core6 = small ∪ contracting
    ext n
    constructor
    · intro hn
      by_cases hcon : n ∈ contractingCore6
      · exact Or.inr hcon
      · have : n ∈ core6Cylinder \ contractingCore6 := ⟨hn, hcon⟩
        exact Or.inl ((Set.ext_iff.1 hdiff n).1 this)
    · intro hn
      rcases hn with hs | hc
      · exact ((Set.ext_iff.1 hdiff n).2 hs).1
      · exact hsub hc
  · refine Set.disjoint_left.2 ?_
    intro n hs hc
    have hdiff := (Set.ext_iff.1 core6_complement_contracting_eq_smallTails n).2 hs
    exact hdiff.2 hc

/-! ### Package F: finite dyadic residue count at common modulus `Q_m = 2^{m+9}`

16f answers: how many **finite module residues** does the contracting family occupy
at stage `m`? It does **not** ask how large the infinite fiber `C_e` is.

For `Q_m = seedModulus m`, `M_e = seedModulus e`, and `4 ≤ e ≤ m`:

$$
R_{m,e}=\bigl\{[b_e+k M_e]_{Q_m}:0\le k<2^{m-e}\bigr\}.
$$

We represent lifts by their Nat representatives `fiberIndexMap e k` (all `< Q_m`).

Epistemic note: the limit below is a **relative dyadic density** along the modulus
sequence `2^{m+9}`. Calling it ordinary natural density requires a separate bridge
theorem (out of scope for 16f).
-/

/-- Common modulus `Q_m = 2^{m+9}`. -/
abbrev commonModulus (m : Nat) : Nat := seedModulus m

/--
`[C→A]` Step 1 — no premature wraparound:
`k < 2^{m-e}` ⇒ `Φ_e(k) < Q_m`.
-/
theorem fiberIndexMap_lt_commonModulus {m e k : Nat}
    (hem : e ≤ m) (hk : k < 2 ^ (m - e)) :
    fiberIndexMap e k < commonModulus m := by
  have hb : canonicalBase e < seedModulus e := canonicalBase_lt e
  have hpow :
      2 ^ (m - e) * seedModulus e = commonModulus m := by
    simp only [commonModulus, seedModulus]
    rw [← pow_add]
    congr 1
    omega
  have : fiberIndexMap e k + 1 ≤ commonModulus m := by
    calc
      fiberIndexMap e k + 1
          = canonicalBase e + k * seedModulus e + 1 := rfl
      _ ≤ seedModulus e + k * seedModulus e := by
          have := Nat.succ_le_of_lt hb
          omega
      _ ≤ seedModulus e + (2 ^ (m - e) - 1) * seedModulus e := by
          gcongr
          exact Nat.le_pred_of_lt hk
      _ = 2 ^ (m - e) * seedModulus e := by
          have hge : 1 ≤ 2 ^ (m - e) := Nat.one_le_two_pow
          set M := seedModulus e
          change M + (2 ^ (m - e) - 1) * M = 2 ^ (m - e) * M
          calc
            M + (2 ^ (m - e) - 1) * M
                = 1 * M + (2 ^ (m - e) - 1) * M := by rw [Nat.one_mul]
            _ = (1 + (2 ^ (m - e) - 1)) * M := (Nat.add_mul _ _ _).symm
            _ = (2 ^ (m - e) - 1 + 1) * M := by rw [Nat.add_comm]
            _ = 2 ^ (m - e) * M := by rw [Nat.sub_add_cancel hge]
      _ = commonModulus m := hpow
  exact Nat.lt_of_succ_le this

/-- Lifted residue set `R_{m,e}` as Nat representatives in `[0, Q_m)`. -/
noncomputable def fiberResidues (m e : Nat) : Finset Nat :=
  (Finset.range (2 ^ (m - e))).image (fun k => fiberIndexMap e k)

/--
`[C→A]` Step 2 — cardinality of one lifted fiber:
`|R_{m,e}| = 2^{m-e}`.
-/
theorem fiberResidues_card (m e : Nat) :
    (fiberResidues m e).card = 2 ^ (m - e) := by
  rw [fiberResidues, Finset.card_image_of_injective _ (fiberIndexMap_injective e)]
  exact Finset.card_range _

/--
`[C→A]` Step 3 — lifted fibers remain disjoint on the common modulus stage
(via `tailExponent_unique` / cylinder disjointness; equal Nat lifts cannot sit in two
cylinders).
-/
theorem fiberResidues_disjoint {m e f : Nat}
    (he1 : 1 ≤ e) (hf1 : 1 ≤ f) (hef : e ≠ f) :
    Disjoint (fiberResidues m e) (fiberResidues m f) := by
  refine Finset.disjoint_left.2 ?_
  intro n hne hnf
  obtain ⟨k, _, rfl⟩ := Finset.mem_image.1 hne
  obtain ⟨l, _, hl⟩ := Finset.mem_image.1 hnf
  have heq : fiberIndexMap e k = fiberIndexMap f l := hl.symm
  have hme : fiberIndexMap e k ∈ canonicalCylinder e := by
    simpa [← canonicalCylinder_eq_ap] using fiberIndexMap_mem e k
  have hmf : fiberIndexMap e k ∈ canonicalCylinder f := by
    simpa [heq, ← canonicalCylinder_eq_ap] using fiberIndexMap_mem f l
  exact (Set.disjoint_left.1
    (canonicalCylinders_pairwise_disjoint he1 hf1 hef)) hme hmf

/-- Contracting residue union `R_m^{contr} = ⊔_{e=4}^m R_{m,e}`. -/
noncomputable def contractingResidues (m : Nat) : Finset Nat :=
  (Finset.Icc 4 m).biUnion (fun e => fiberResidues m e)

private theorem sum_two_pow_m_sub_e {m : Nat} (hm : 4 ≤ m) :
    ∑ e ∈ Finset.Icc 4 m, 2 ^ (m - e) = 2 ^ (m - 3) - 1 := by
  have hrange :
      ∑ e ∈ Finset.Icc 4 m, 2 ^ (m - e) =
        ∑ i ∈ Finset.range (m - 3), 2 ^ i := by
    refine Finset.sum_bij (fun e _ => m - e) ?_ ?_ ?_ ?_
    · intro e he
      rcases Finset.mem_Icc.1 he with ⟨he4, hem⟩
      have : m - e ≤ m - 4 := Nat.sub_le_sub_left he4 _
      have hlt : m - e < m - 3 := by omega
      exact Finset.mem_range.2 hlt
    · intro a ha b hb h
      rcases Finset.mem_Icc.1 ha with ⟨_, ham⟩
      rcases Finset.mem_Icc.1 hb with ⟨_, hbm⟩
      omega
    · intro i hi
      have hi' : i < m - 3 := Finset.mem_range.1 hi
      refine ⟨m - i, ?_, ?_⟩
      · refine Finset.mem_Icc.2 ⟨?_, Nat.sub_le m i⟩
        have : i ≤ m - 4 := by omega
        omega
      · exact Nat.sub_sub_self (by omega : i ≤ m)
    · intro e _; rfl
  rw [hrange, Nat.geomSum_eq (by decide : 2 ≤ 2)]
  simp

/--
`[C→A]` Step 4 — total contracting residue cardinality:
`|R_m^{contr}| = 2^{m-3} - 1`.
-/
theorem contractingResidues_card {m : Nat} (hm : 4 ≤ m) :
    (contractingResidues m).card = 2 ^ (m - 3) - 1 := by
  rw [contractingResidues, Finset.card_biUnion]
  · simp_rw [fiberResidues_card]
    exact sum_two_pow_m_sub_e hm
  · intro a ha b hb hab
    have ha4 : 4 ≤ a := (Finset.mem_Icc.1 ha).1
    have hb4 : 4 ≤ b := (Finset.mem_Icc.1 hb).1
    exact fiberResidues_disjoint (by omega : 1 ≤ a) (by omega : 1 ≤ b) hab

/--
Core6 prefix half-modulus period: `2^(core6.sum + 1) = 2^9`.
Lifts of this class to `Q_m = 2^{m+9}` form the ambient Core6 residue domain.
-/
def core6SeedModulus : Nat := 2 ^ 9

theorem core6SeedModulus_eq : core6SeedModulus = 2 ^ (core6.sum + 1) := by
  simp [core6SeedModulus, core6_sum]

/--
Representative of the Core6 residue class mod `2^9` (`b_Core6`), taken from any
contracting canonical seed (`canonicalBase 4 % 2^9`).

**Not** `canonicalBase 6` (that is the tail-`e=6` representative).
All Core6 realizers share this class mod `2^9`.
-/
noncomputable def core6LiftBase : Nat :=
  canonicalBase 4 % core6SeedModulus

/-- Documentation alias for `core6LiftBase` (= `b_Core6`). -/
noncomputable abbrev bCore6 : Nat := core6LiftBase

theorem core6LiftBase_lt : core6LiftBase < core6SeedModulus :=
  Nat.mod_lt _ (by decide : 0 < (2 : Nat) ^ 9)

theorem wordC_core6 : wordC core6 = 697 := by native_decide

theorem core6_positive : ∀ a ∈ core6, 1 ≤ a := by
  intro a ha
  have : a ∈ ([1, 1, 1, 1, 2, 2] : List Nat) := by simpa [core6] using ha
  simp at this
  omega

/-- Affine Core6 quotient ⇒ half-modulus congruence mod `2^9`. -/
theorem modEq_of_affineOddQuotient_core6 {n : Nat}
    (hAQ : AffineOddQuotient core6 n) :
    (3 ^ 6 * n + wordC core6) ≡ 2 ^ 8 [MOD core6SeedModulus] := by
  obtain ⟨q, hq, heq⟩ := hAQ
  obtain ⟨t, ht⟩ : ∃ t, q = 2 * t + 1 := by
    refine ⟨q / 2, ?_⟩
    have : q % 2 = 1 := Nat.odd_iff.mp hq
    omega
  have hsum : core6.sum = 8 := core6_sum
  have hlen : core6.length = 6 := core6_length
  have hform :
      3 ^ 6 * n + wordC core6 = 2 ^ 8 + t * core6SeedModulus := by
    calc
      3 ^ 6 * n + wordC core6
          = q * 2 ^ core6.sum := by
            simpa [hsum, hlen, Nat.mul_comm] using heq.symm
      _ = q * 2 ^ 8 := by rw [hsum]
      _ = (2 * t + 1) * 2 ^ 8 := by rw [ht]
      _ = 2 ^ 8 + t * 2 ^ 9 := by ring
      _ = 2 ^ 8 + t * core6SeedModulus := by simp [core6SeedModulus]
  have hlt : 2 ^ 8 < core6SeedModulus := by
    native_decide
  change (3 ^ 6 * n + wordC core6) % core6SeedModulus =
    (2 ^ 8) % core6SeedModulus
  rw [hform, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hlt]

theorem realizes_core6_of_realizes_fiberE {e n : Nat}
    (h : RealizesWord (fiberE e) n) :
    RealizesWord core6 n := by
  rw [fiberE_eq_core6_concat] at h
  exact ((realizesWord_append (E := core6) (F := [e])).1 h).1

theorem modEq_of_realizes_core6 {n : Nat}
    (h : RealizesWord core6 n) :
    (3 ^ 6 * n + wordC core6) ≡ 2 ^ 8 [MOD core6SeedModulus] :=
  modEq_of_affineOddQuotient_core6
    (affineOddQuotient_of_realizesWord core6_ne_nil h)

/-- Any two Core6 realizers are congruent mod `2^9`. -/
theorem realizes_core6_modEq_unique {n₁ n₂ : Nat}
    (h₁ : RealizesWord core6 n₁) (h₂ : RealizesWord core6 n₂) :
    n₁ ≡ n₂ [MOD core6SeedModulus] := by
  have hm₁ := modEq_of_realizes_core6 h₁
  have hm₂ := modEq_of_realizes_core6 h₂
  have hmul :
      3 ^ 6 * n₁ ≡ 3 ^ 6 * n₂ [MOD core6SeedModulus] :=
    Nat.ModEq.add_right_cancel' (wordC core6) (hm₁.trans hm₂.symm)
  have hcop : Nat.Coprime (3 ^ 6) core6SeedModulus := by
    native_decide
  have hcop' : Nat.gcd core6SeedModulus (3 ^ 6) = 1 := by
    simpa [Nat.gcd_comm, Nat.coprime_iff_gcd_eq_one] using hcop
  exact Nat.ModEq.cancel_left_of_coprime hcop' hmul

theorem canonicalBase_modEq_core6LiftBase {e : Nat} (he : 1 ≤ e) :
    canonicalBase e ≡ core6LiftBase [MOD core6SeedModulus] := by
  have heR : RealizesWord core6 (canonicalBase e) :=
    realizes_core6_of_realizes_fiberE (canonicalBase_realizes_of_one_le he)
  have h4R : RealizesWord core6 (canonicalBase 4) :=
    realizes_core6_of_realizes_fiberE (canonicalBase_realizes_of_one_le (by decide))
  have hcong := realizes_core6_modEq_unique heR h4R
  -- core6LiftBase = canonicalBase 4 % 2^9 ≡ canonicalBase 4
  have hbase : canonicalBase 4 ≡ core6LiftBase [MOD core6SeedModulus] := by
    simp only [core6LiftBase]
    exact (Nat.mod_modEq (canonicalBase 4) core6SeedModulus).symm
  exact hcong.trans hbase

theorem fiberIndexMap_modEq_core6LiftBase {e k : Nat} (he : 1 ≤ e) :
    fiberIndexMap e k ≡ core6LiftBase [MOD core6SeedModulus] := by
  have hb := canonicalBase_modEq_core6LiftBase he
  have hdiv : core6SeedModulus ∣ seedModulus e := by
    simp only [core6SeedModulus, seedModulus]
    exact pow_dvd_pow (a := 2) (by omega : 9 ≤ e + 9)
  have hk0 : k * seedModulus e ≡ 0 [MOD core6SeedModulus] :=
    Nat.modEq_zero_iff_dvd.2 (dvd_mul_of_dvd_right hdiv k)
  calc
    fiberIndexMap e k
        = canonicalBase e + k * seedModulus e := rfl
    _ ≡ canonicalBase e + 0 [MOD core6SeedModulus] :=
        Nat.ModEq.add (Nat.ModEq.refl _) hk0
    _ = canonicalBase e := by simp
    _ ≡ core6LiftBase [MOD core6SeedModulus] := hb

/--
`[C→A]` Explicit Core6 residue Finset at stage `m`:

$$
R_m^{\mathrm{Core6}}
=
\{b_{\mathrm{Core6}} + k\cdot 2^9 : 0 \le k < 2^m\}
\subset [0, Q_m).
$$
-/
noncomputable def core6Residues (m : Nat) : Finset Nat :=
  (Finset.range (2 ^ m)).image (fun k => core6LiftBase + k * core6SeedModulus)

theorem mem_core6Residues {m n : Nat} :
    n ∈ core6Residues m ↔
      ∃ k : Nat, k < 2 ^ m ∧ n = core6LiftBase + k * core6SeedModulus := by
  simp [core6Residues, eq_comm]

theorem core6Residues_lt_commonModulus {m n : Nat}
    (hn : n ∈ core6Residues m) :
    n < commonModulus m := by
  obtain ⟨k, hk, rfl⟩ := (mem_core6Residues (m := m) (n := n)).1 hn
  have hb := core6LiftBase_lt
  have hge : 1 ≤ 2 ^ m := Nat.one_le_two_pow
  have : core6LiftBase + k * core6SeedModulus + 1 ≤ commonModulus m := by
    calc
      core6LiftBase + k * core6SeedModulus + 1
          ≤ core6SeedModulus + k * core6SeedModulus := by omega
      _ ≤ core6SeedModulus + (2 ^ m - 1) * core6SeedModulus := by
          gcongr
          exact Nat.le_pred_of_lt hk
      _ = 2 ^ m * core6SeedModulus := by
          set M := core6SeedModulus
          calc
            M + (2 ^ m - 1) * M
                = 1 * M + (2 ^ m - 1) * M := by rw [Nat.one_mul]
            _ = (1 + (2 ^ m - 1)) * M := (Nat.add_mul _ _ _).symm
            _ = (2 ^ m - 1 + 1) * M := by rw [Nat.add_comm]
            _ = 2 ^ m * M := by rw [Nat.sub_add_cancel hge]
      _ = commonModulus m := by
          simp only [commonModulus, seedModulus, core6SeedModulus, ← pow_add]
  exact Nat.lt_of_succ_le this

/-- `[C→A]` `|R_m^{Core6}| = 2^m`. -/
theorem core6Residues_card (m : Nat) :
    (core6Residues m).card = 2 ^ m := by
  rw [core6Residues, Finset.card_image_of_injective]
  · exact Finset.card_range _
  · intro a b h
    have : a * core6SeedModulus = b * core6SeedModulus :=
      Nat.add_left_cancel h
    exact Nat.eq_of_mul_eq_mul_right (by decide : 0 < core6SeedModulus) this

/--
`[C→A]` Every lifted fiber representative at stage `m` lands in `core6Residues`.
-/
theorem fiberIndexMap_mem_core6Residues {m e k : Nat}
    (he1 : 1 ≤ e) (hem : e ≤ m) (hk : k < 2 ^ (m - e)) :
    fiberIndexMap e k ∈ core6Residues m := by
  set n := fiberIndexMap e k
  set M := core6SeedModulus
  have hlt : n < commonModulus m := fiberIndexMap_lt_commonModulus hem hk
  have hmod : n ≡ core6LiftBase [MOD M] := fiberIndexMap_modEq_core6LiftBase he1
  have hnmod : n % M = core6LiftBase := by
    have : n % M = core6LiftBase % M := hmod
    rwa [Nat.mod_eq_of_lt core6LiftBase_lt] at this
  have hQ : commonModulus m = 2 ^ m * M := by
    simp only [commonModulus, seedModulus, M, core6SeedModulus, ← pow_add]
  refine (mem_core6Residues (m := m) (n := n)).2 ⟨n / M, ?_, ?_⟩
  · have : n < M * 2 ^ m := by
      rw [Nat.mul_comm]; rwa [← hQ]
    exact Nat.div_lt_of_lt_mul this
  · calc
      n = M * (n / M) + n % M := (Nat.div_add_mod n M).symm
      _ = (n / M) * M + n % M := by ring
      _ = core6LiftBase + (n / M) * M := by rw [hnmod]; ring

/--
`[C→A]` Semantic occupancy bridge: contracting residues are a sub-Finset of the
Core6 residue domain at stage `m`.
-/
theorem contractingResidues_subset_core6Residues {m : Nat} (_hm : 4 ≤ m) :
    contractingResidues m ⊆ core6Residues m := by
  intro n hn
  obtain ⟨e, he, hmem⟩ := Finset.mem_biUnion.1 hn
  rcases Finset.mem_Icc.1 he with ⟨he4, hem⟩
  obtain ⟨k, hk, rfl⟩ := Finset.mem_image.1 hmem
  exact fiberIndexMap_mem_core6Residues (by omega : 1 ≤ e) hem
    (Finset.mem_range.1 hk)

/-- Alias: architectural budget equals the Finset cardinality. -/
noncomputable def core6ResidueBudget (m : Nat) : Nat := (core6Residues m).card

theorem core6ResidueBudget_eq (m : Nat) :
    core6ResidueBudget m = 2 ^ m := by
  simp [core6ResidueBudget, core6Residues_card]

/--
`[C→A]` Step 5a — exact relative dyadic proportion as a ratio of Finset cards
(cast to `ℚ`; not `Nat` division):

`|R_m^{contr}| / |R_m^{Core6}| = 1/8 - 1/2^m`.
-/
theorem contractingResidues_dyadicProportion {m : Nat} (hm : 4 ≤ m) :
    ((contractingResidues m).card : ℚ) / ((core6Residues m).card : ℚ) =
      (1 : ℚ) / 8 - (1 : ℚ) / (2 ^ m : ℚ) := by
  have hm3 : 3 ≤ m := by omega
  have hcard := contractingResidues_card hm
  have hden := core6Residues_card m
  have hge : 1 ≤ 2 ^ (m - 3) := Nat.one_le_two_pow
  calc
    ((contractingResidues m).card : ℚ) / ((core6Residues m).card : ℚ)
        = ((2 ^ (m - 3) - 1 : Nat) : ℚ) / (2 ^ m : ℚ) := by
          simp [hcard, hden]
    _ = ((2 ^ (m - 3) : Nat) : ℚ) / (2 ^ m : ℚ) - (1 : ℚ) / (2 ^ m : ℚ) := by
        rw [Nat.cast_sub hge, sub_div]
        simp
    _ = (2 : ℚ) ^ (m - 3) / (2 : ℚ) ^ m - (1 : ℚ) / (2 : ℚ) ^ m := by
        norm_cast
    _ = (1 : ℚ) / 8 - (1 : ℚ) / (2 : ℚ) ^ m := by
        have hsplit : (2 : ℚ) ^ m = (2 : ℚ) ^ (m - 3) * (2 : ℚ) ^ 3 := by
          rw [← pow_add, Nat.sub_add_cancel hm3]
        rw [hsplit, pow_three]
        field_simp
        ring

/-- Alias keeping the old budget name in the denominator. -/
theorem contractingResidues_dyadicProportion_budget {m : Nat} (hm : 4 ≤ m) :
    ((contractingResidues m).card : ℚ) / (core6ResidueBudget m : ℚ) =
      (1 : ℚ) / 8 - (1 : ℚ) / (2 ^ m : ℚ) := by
  simpa [core6ResidueBudget] using contractingResidues_dyadicProportion hm

/--
`[C→A]` Step 5b — exact error to `1/8` (implies the dyadic limit `→ 1/8`):

$$
\left|\frac{|R_m^{\mathrm{contr}}|}{|R_m^{\mathrm{Core6}}|}-\frac18\right|=\frac1{2^m}.
$$

This is **relative dyadic density** along `Q_m = 2^{m+9}`, not ordinary natural density.
-/
theorem contractingResidues_dyadicDensity_error {m : Nat} (hm : 4 ≤ m) :
    |((contractingResidues m).card : ℚ) / ((core6Residues m).card : ℚ) -
        (1 : ℚ) / 8| =
      (1 : ℚ) / (2 ^ m : ℚ) := by
  rw [contractingResidues_dyadicProportion hm, sub_sub_cancel_left, abs_neg, abs_of_nonneg]
  exact div_nonneg (by norm_num) (by positivity)

open Filter Topology

/--
`[C→A]` Step 5c — Mathlib topological packaging of the dyadic limit:

`Tendsto (m ↦ |R_m^{contr}| / |R_m^{Core6}|) atTop (𝓝 (1/8))` on `ℝ`.
-/
theorem contractingResidues_tendsto_dyadicDensity :
    Tendsto
      (fun m : Nat =>
        ((contractingResidues (m + 4)).card : ℝ) /
          ((core6Residues (m + 4)).card : ℝ))
      atTop
      (nhds ((1 : ℝ) / 8)) := by
  have hform :
      ∀ m : Nat,
        ((contractingResidues (m + 4)).card : ℝ) /
            ((core6Residues (m + 4)).card : ℝ) =
          (1 : ℝ) / 8 - (1 : ℝ) / (2 ^ (m + 4) : ℝ) := by
    intro m
    have hm : 4 ≤ m + 4 := by omega
    have hq := contractingResidues_dyadicProportion hm
    have hqR :
        (((contractingResidues (m + 4)).card : ℚ) /
            ((core6Residues (m + 4)).card : ℚ) : ℝ) =
          (((1 : ℚ) / 8 - (1 : ℚ) / (2 ^ (m + 4) : ℚ) : ℚ) : ℝ) :=
      by exact_mod_cast hq
    have hcast :
        (((contractingResidues (m + 4)).card : ℚ) /
            ((core6Residues (m + 4)).card : ℚ) : ℝ) =
          ((contractingResidues (m + 4)).card : ℝ) /
            ((core6Residues (m + 4)).card : ℝ) := by
      push_cast; rfl
    have hrhs :
        (((1 : ℚ) / 8 - (1 : ℚ) / (2 ^ (m + 4) : ℚ) : ℚ) : ℝ) =
          (1 : ℝ) / 8 - (1 : ℝ) / (2 ^ (m + 4) : ℝ) := by
      push_cast; rfl
    exact (hcast.symm.trans hqR).trans hrhs
  have hconst : Tendsto (fun _ : Nat => (1 : ℝ) / 8) atTop (nhds ((1 : ℝ) / 8)) :=
    tendsto_const_nhds
  have hvan :
      Tendsto (fun m : Nat => (1 : ℝ) / (2 ^ (m + 4) : ℝ)) atTop (nhds (0 : ℝ)) := by
    have hpow :
        Tendsto (fun m : Nat => ((1 : ℝ) / 2) ^ (m + 4)) atTop (nhds (0 : ℝ)) :=
      (tendsto_pow_atTop_nhds_zero_of_lt_one
          (r := (1 / 2 : ℝ)) (by norm_num) (by norm_num)).comp
        (tendsto_add_atTop_nat 4)
    refine hpow.congr fun m => ?_
    rw [div_pow, one_pow]
  have hdiff :
      Tendsto (fun m : Nat => (1 : ℝ) / 8 - (1 : ℝ) / (2 ^ (m + 4) : ℝ))
        atTop (nhds ((1 : ℝ) / 8)) := by
    simpa using hconst.sub hvan
  exact hdiff.congr fun m => (hform m).symm

/--
`[C→A]` Package goal: contracting family occupies `2^{m-3}-1` residues at stage `m`.
-/
def FiniteDyadicContractingCountGoal : Prop :=
  ∀ m : Nat, 4 ≤ m → (contractingResidues m).card = 2 ^ (m - 3) - 1

theorem finiteDyadicContractingCountGoal : FiniteDyadicContractingCountGoal :=
  fun _ hm => contractingResidues_card hm

/-! ### Closure certificate (no new mathematics)

**Freeze:** Head `3740183` is the mathematical closure candidate for PR #16.
This certificate only bundles already-proved theorems into one import node.
Further PRs must not expand scope here (no natural density, no reachability).
-/

open Filter Topology

/--
`[C→A]` Canonical static Core6 dyadic certificate — single review/import entry point.
Bundles phase split, finite occupancy inclusion, cards, ℚ proportion, and ℝ Tendsto.
-/
structure Core6StaticDyadicCertificate : Prop where
  phasePartition :
    core6Cylinder = expandingCore6 ∪ contractingCore6
  phaseDisjoint :
    Disjoint expandingCore6 contractingCore6
  finiteSubset :
    ∀ m, 4 ≤ m → contractingResidues m ⊆ core6Residues m
  contractingCard :
    ∀ m, 4 ≤ m → (contractingResidues m).card = 2 ^ (m - 3) - 1
  core6Card :
    ∀ m, (core6Residues m).card = 2 ^ m
  dyadicProportion :
    ∀ m, 4 ≤ m →
      ((contractingResidues m).card : ℚ) / ((core6Residues m).card : ℚ) =
        (1 : ℚ) / 8 - (1 : ℚ) / (2 ^ m : ℚ)
  dyadicLimit :
    Tendsto
      (fun m : Nat =>
        ((contractingResidues (m + 4)).card : ℝ) /
          ((core6Residues (m + 4)).card : ℝ))
      atTop
      (nhds ((1 : ℝ) / 8))

/--
`[C→A]` Discharge of `Core6StaticDyadicCertificate` from existing lemmas only.
-/
theorem core6StaticDyadicCertificate : Core6StaticDyadicCertificate where
  phasePartition := (core6Cylinder_eq_expanding_disjoint_union_contracting).1
  phaseDisjoint := (core6Cylinder_eq_expanding_disjoint_union_contracting).2
  finiteSubset := fun _ hm => contractingResidues_subset_core6Residues hm
  contractingCard := fun _ hm => contractingResidues_card hm
  core6Card := core6Residues_card
  dyadicProportion := fun _ hm => contractingResidues_dyadicProportion hm
  dyadicLimit := contractingResidues_tendsto_dyadicDensity

end KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
