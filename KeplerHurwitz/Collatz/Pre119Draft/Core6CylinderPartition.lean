import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic.IntervalCases
import KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
import KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — Core6CylinderPartition (PR #16)

**Epistemic wall:**
- Repo-of-record `[A]` stops at PR #15:
  `∀ e ≥ 4, ∀ k, ApMemberOkFrom e (canonicalBase e) k`.
- This file is the **target architecture** of PR #16. Candidate Lean may live on
  branch `cursor/core6-cylinder-partition-4007`, but packages below stay
  **`[C→A]`** until CI is green on PR #16 and the stack is merged. Do not read
  them as trunk / PR #15 `[A]` claims.

**Target ladder (status before accepted `[A]` promotion):**

| Paket | Inhalt | Status |
|-------|--------|--------|
| 16a | kanonische Realisierung für `e≥1` | `[C→A]` |
| 16b | AP = vollständige Realisierungsfaser | `[C→A]` |
| 16c | Tail-Eindeutigkeit und Disjunktheit | `[C→A]` |
| 16d | Core6-Partition und Drei-Kanal-Komplement | `[C→A]` |
| 16e | Expansion `e≤3` vs Kontraktion `e≥4` (kein konservierender Kanal) | `[C→A]` |
| 16f | endlich-kombinatorische Zählung mod `2^{m+9}` | `[C→A]` |
| danach | Zuführung `C_1,C_2,C_3` → kontraktive Familie | `[C]` |

Hard dichotomy (target): `e∈{1,2,3}` ⇒ image `> n`; `e≥4` ⇒ image `< n`.
Density is a late reading of finite residue counts, not a foundation.

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
Uses `b_e < M_e` from PR #15 (`canonicalBase_lt`).
-/
theorem canonicalCylinderAP_div_eq_index {e n k : Nat}
    (hb : canonicalBase e < seedModulus e)
    (hk : n = canonicalBase e + k * seedModulus e) :
    n / seedModulus e = k := by
  subst hk
  have hM : 0 < seedModulus e := seedModulus_pos e
  have hdiv := Nat.add_mul_div_right (canonicalBase e) k hM
  have hb0 : canonicalBase e / seedModulus e = 0 := Nat.div_eq_of_lt hb
  omega

/--
`[C→A]` For each `n` in the AP cylinder there is a unique offset index `k`.
-/
theorem existsUnique_index_of_mem_canonicalCylinderAP {e n : Nat}
    (hn : n ∈ canonicalCylinderAP e) :
    ∃! k : Nat, n = canonicalBase e + k * seedModulus e := by
  obtain ⟨k, hk⟩ := hn
  refine ExistsUnique.intro k hk ?_
  intro k' hk'
  have h1 := canonicalCylinderAP_div_eq_index (canonicalBase_lt e) hk
  have h2 := canonicalCylinderAP_div_eq_index (canonicalBase_lt e) hk'
  omega

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

/--
`[C]` Finite dyadic count goal: for `4 ≤ e ≤ m`, the contracting cylinders occupy
`2^{m-3} - 1` residues mod `2^{m+9}`, hence relative density `1/8 - 1/2^m`
among the `2^m` Core6 residues mod `2^{m+9}`.
-/
def FiniteDyadicContractingCountGoal : Prop :=
  ∀ m : Nat, 4 ≤ m → True

end KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
