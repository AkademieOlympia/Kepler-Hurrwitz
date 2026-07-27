import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Data.ZMod.Basic
import KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
import KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
import KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra
import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — Core6DynamicFeedIn (Follow-up `[C]` / partial `[C→A]`)

**Experiment status:**
- `ReachabilityFeedInGoal` — open **`[C]`**
- `OneBlockFeedInGoal` — **universally false**;
  Lean discharge `¬ OneBlockFeedInGoal` is `[C→A]`
- D2b.1 affine block map `q + 4374 k` — `[C→A]`
- D2b.2 target congruence packaging — `[C→A]`
- D2b.3 unique index class for `2187·κ ≡ halfDiff` — `[C→A]`
- D2b.4 `∅ ⊂ oneBlockFeedInSet 1 ⊂ C_1` — `[C→A]`
- D1 full representative census — **`[B]`** only

This module must not reopen PR #16 static mathematics.

## Claim wall (rigid)

| May use from PR #16 | Must not reinterpret as |
|---------------------|-------------------------|
| `core6StaticDyadicCertificate` | dynamical success probability |
| `expandingCore6` / `contractingCore6` | reachability already proved |
| pairwise cylinder disjointness | natural density on `ℕ` |
| dyadic density `1/8` | Collatz convergence / “collapse” |

## Epistemic layers

| Object | Status |
|--------|--------|
| D1 representative census | `[B]` |
| `OneBlockFeedInGoal` (universal) | formally refuted; Lean `¬` is `[C→A]` |
| `realizedImage_fiberIndexMap` | D2b.1 `[C→A]` |
| `oneBlockFeedInSet` | D2b.1–.4 partial `[C→A]` |
| full disjoint-union decomposition | D2b.5 open |
| `ReachabilityFeedInGoal` | `[C]` open |

`[B]` may support or falsify a `[C]` hypothesis; it never yields `[A]` by itself.
`¬ OneBlockFeedInGoal` does **not** imply `¬ ReachabilityFeedInGoal`.

No Collatz claim. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn

open Set
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine
open KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
open KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition

/-! ### Orbit primitives -/

/-- One odd Syracuse step `U(n) = nextOdd n`. -/
def syracuseOddStep (n : Nat) : Nat := nextOdd n

/-- `t`-fold iterate of the odd Syracuse step. -/
def syracuseOddIterate (t n : Nat) : Nat :=
  (Nat.iterate syracuseOddStep t) n

/-- Expanding mass: small-tail channels `e ∈ {1,2,3}`. -/
def expandingMass : Set Nat := expandingCore6

/-- Contracting mass: family `e ≥ 4`. -/
def contractingMass : Set Nat := contractingCore6

/-! ### One-block feed-in: universal claim (false) and characterization set -/

/--
Universal one-block feed-in (too strong). After the **full** expanding word
`fiberE e₀` (`e₀ ∈ {1,2,3}`), the image would always lie in the contracting family.

This is **not** “after the shared Core6 prefix alone”.
Falsified by the witness `31 ∈ C_1` with image `137 ∉ contractingMass`.
-/
def OneBlockFeedInGoal : Prop :=
  ∀ e₀ : Nat, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ canonicalCylinder e₀,
      realizedImage n (fiberE e₀) ∈ contractingMass

/-- Equivalent packaging via an explicit target tail `e ≥ 4`. -/
def OneBlockFeedInGoal_existsTail : Prop :=
  ∀ e₀ : Nat, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ canonicalCylinder e₀,
      ∃ e : Nat, 4 ≤ e ∧
        realizedImage n (fiberE e₀) ∈ canonicalCylinder e

/--
D2b characterization set: those starts in `C_{e₀}` that **do** one-block feed-in.
Replaces the false universal claim.
-/
def oneBlockFeedInSet (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∈ contractingMass}

/--
`[C]` True dynamical target: some finite odd-iterate lands in a contracting cylinder.
-/
def ReachabilityFeedInGoal : Prop :=
  ∀ n ∈ expandingMass,
    ∃ t : Nat, 1 ≤ t ∧ syracuseOddIterate t n ∈ contractingMass

/-! ### `[C→A]` Formal refutation of universal one-block feed-in

Witness: `e₀ = 1`, `n = 31` (= `canonicalBase 1`),
`realizedImage 31 (fiberE 1) = 137 ∉ contractingMass`.
-/

theorem realizes_fiberE_one_31 : RealizesWord (fiberE 1) 31 := by
  native_decide

theorem mem_canonicalCylinder_one_31 : 31 ∈ canonicalCylinder 1 :=
  mem_canonicalCylinder_of_realizes (by decide : 1 ≤ 1) realizes_fiberE_one_31

theorem realizedImage_fiberE_one_31 :
    realizedImage 31 (fiberE 1) = 137 := by
  native_decide

theorem not_realizes_core6_137 : ¬ RealizesWord core6 137 := by
  native_decide

theorem not_mem_contractingMass_137 : 137 ∉ contractingMass := by
  intro h
  have hU : 137 ∈ ⋃ e : Nat, ⋃ (_ : 4 ≤ e), canonicalCylinder e := by
    simpa [contractingMass, contractingCore6] using h
  obtain ⟨e, he'⟩ := mem_iUnion.1 hU
  obtain ⟨he4, hmem⟩ := mem_iUnion.1 he'
  have hR : RealizesWord (fiberE e) 137 :=
    realizes_of_mem_canonicalCylinder (by omega : 1 ≤ e) hmem
  exact not_realizes_core6_137 (realizes_core6_of_realizes_fiberE hR)

/--
`[C→A]` Universal one-block feed-in is false.
Finite witness; no reachability content.
-/
theorem not_oneBlockFeedInGoal : ¬ OneBlockFeedInGoal := by
  intro h
  have himg : realizedImage 31 (fiberE 1) ∈ contractingMass :=
    h 1 (by decide) (by decide) 31 mem_canonicalCylinder_one_31
  rw [realizedImage_fiberE_one_31] at himg
  exact not_mem_contractingMass_137 himg

/-- Alias matching the D2a naming in the experiment plan. -/
theorem oneBlockFeedInGoal_refuted : ¬ OneBlockFeedInGoal :=
  not_oneBlockFeedInGoal

/-! ### D2b — structure of `oneBlockFeedInSet` -/

theorem mem_oneBlockFeedInSet_iff {e₀ n : Nat} :
    n ∈ oneBlockFeedInSet e₀ ↔
      n ∈ canonicalCylinder e₀ ∧
        realizedImage n (fiberE e₀) ∈ contractingMass :=
  Iff.rfl

theorem oneBlockFeedInSet_subset_canonicalCylinder (e₀ : Nat) :
    oneBlockFeedInSet e₀ ⊆ canonicalCylinder e₀ :=
  fun _ hn => hn.1

/-- Universal one-block ⇔ characterization sets fill their cylinders. -/
theorem OneBlockFeedInGoal_iff_sets :
    OneBlockFeedInGoal ↔
      ∀ e₀ : Nat, 1 ≤ e₀ → e₀ ≤ 3 →
        oneBlockFeedInSet e₀ = canonicalCylinder e₀ := by
  constructor
  · intro h e₀ he₁ he₃
    ext n
    exact ⟨fun hn => hn.1, fun hn => ⟨hn, h e₀ he₁ he₃ n hn⟩⟩
  · intro h e₀ he₁ he₃ n hn
    exact ((h e₀ he₁ he₃ ▸ hn) : n ∈ oneBlockFeedInSet e₀).2

/-- Witness `31 ∈ C_1` fails one-block feed-in. -/
theorem not_mem_oneBlockFeedInSet_one_31 : 31 ∉ oneBlockFeedInSet 1 := by
  intro h
  have himg : realizedImage 31 (fiberE 1) ∈ contractingMass := h.2
  rw [realizedImage_fiberE_one_31] at himg
  exact not_mem_contractingMass_137 himg

theorem oneBlockFeedInSet_one_ne_canonicalCylinder :
    oneBlockFeedInSet 1 ≠ canonicalCylinder 1 := by
  intro h
  exact not_mem_oneBlockFeedInSet_one_31 (h ▸ mem_canonicalCylinder_one_31)

/--
`[C→A]` For `e₀ = 1`, the characterization set is a **proper** subset of `C_1`.
-/
theorem oneBlockFeedInSet_one_ssubset_canonicalCylinder :
    oneBlockFeedInSet 1 ⊂ canonicalCylinder 1 :=
  (oneBlockFeedInSet_subset_canonicalCylinder 1).ssubset_of_ne
    oneBlockFeedInSet_one_ne_canonicalCylinder

/-! ### D2b.1 — affine block image on the fiber index

`Φ_{e₀}(k) = canonicalBase e₀ + k · 2^{e₀+9}` maps under the full seven-step word to
`q_{e₀} + 2 · 3^7 · k = q_{e₀} + 4374 · k`.
-/

/-- Block image of the canonical seed: `q_{e₀}`. -/
noncomputable def oneBlockBaseImage (e₀ : Nat) : Nat :=
  realizedImage (canonicalBase e₀) (fiberE e₀)

theorem realizes_fiberIndexMap {e₀ k : Nat} (he₀ : 1 ≤ e₀) :
    RealizesWord (fiberE e₀) (fiberIndexMap e₀ k) :=
  realizes_of_mem_canonicalCylinder he₀
    (by simpa [← canonicalCylinder_eq_ap] using fiberIndexMap_mem e₀ k)

/--
`[C→A]` Affine one-block map on fiber indices.
-/
theorem realizedImage_fiberIndexMap {e₀ : Nat} (he₀ : 1 ≤ e₀) (k : Nat) :
    realizedImage (fiberIndexMap e₀ k) (fiberE e₀) =
      oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k := by
  have hΦ := realizes_fiberIndexMap (e₀ := e₀) (k := k) he₀
  have hb := canonicalBase_realizes_of_one_le he₀
  have hidΦ := fiberE_affine_identity hΦ
  have hidb := fiberE_affine_identity hb
  have hpow : (2 : Nat) ^ (e₀ + 9) = 2 * 2 ^ (e₀ + 8) := by
    rw [show e₀ + 9 = (e₀ + 8) + 1 from by omega, pow_succ, Nat.mul_comm]
  have hrhs :
      realizedImage (fiberIndexMap e₀ k) (fiberE e₀) * 2 ^ (e₀ + 8) =
        (oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k) * 2 ^ (e₀ + 8) := by
    calc
      realizedImage (fiberIndexMap e₀ k) (fiberE e₀) * 2 ^ (e₀ + 8)
          = 3 ^ 7 * fiberIndexMap e₀ k + 2347 := hidΦ
      _ = 3 ^ 7 * (canonicalBase e₀ + k * seedModulus e₀) + 2347 := by
            simp [fiberIndexMap]
      _ = 3 ^ 7 * canonicalBase e₀ + 2347 + 3 ^ 7 * k * seedModulus e₀ := by
            ring
      _ = oneBlockBaseImage e₀ * 2 ^ (e₀ + 8) + 3 ^ 7 * k * 2 ^ (e₀ + 9) := by
            simp only [oneBlockBaseImage, seedModulus, hidb]
      _ = oneBlockBaseImage e₀ * 2 ^ (e₀ + 8) +
            3 ^ 7 * k * (2 * 2 ^ (e₀ + 8)) := by
            rw [hpow]
      _ = (oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k) * 2 ^ (e₀ + 8) := by
            ring
  have hpos : 0 < 2 ^ (e₀ + 8) := Nat.pow_pos (by decide : 0 < 2)
  exact Nat.eq_of_mul_eq_mul_right hpos hrhs

theorem realizedImage_fiberIndexMap_coeff {e₀ : Nat} (he₀ : 1 ≤ e₀) (k : Nat) :
    realizedImage (fiberIndexMap e₀ k) (fiberE e₀) =
      oneBlockBaseImage e₀ + 4374 * k := by
  have h := realizedImage_fiberIndexMap he₀ k
  have h4374 : (4374 : Nat) = 2 * 3 ^ 7 := by native_decide
  simpa [h4374] using h

/-! ### D2b.2 — target cylinder as a congruence on the affine image -/

theorem mem_canonicalCylinder_iff_modEq {e n : Nat} :
    n ∈ canonicalCylinder e ↔ n ≡ canonicalBase e [MOD seedModulus e] := by
  constructor
  · intro hn
    have hap : n ∈ canonicalCylinderAP e := by
      rwa [← canonicalCylinder_eq_ap]
    obtain ⟨k, rfl⟩ := hap
    change canonicalBase e + k * seedModulus e ≡ canonicalBase e [MOD seedModulus e]
    rw [Nat.ModEq]
    simp
  · intro hmod
    rw [canonicalCylinder_eq_ap]
    refine ⟨n / seedModulus e, ?_⟩
    have hb : canonicalBase e < seedModulus e := canonicalBase_lt e
    have hbmod : canonicalBase e % seedModulus e = canonicalBase e :=
      Nat.mod_eq_of_lt hb
    have hnmod : n % seedModulus e = canonicalBase e := by
      have : n % seedModulus e = canonicalBase e % seedModulus e := hmod
      rwa [hbmod] at this
    calc
      n = seedModulus e * (n / seedModulus e) + n % seedModulus e :=
        (Nat.div_add_mod n (seedModulus e)).symm
      _ = (n / seedModulus e) * seedModulus e + n % seedModulus e := by ring
      _ = canonicalBase e + (n / seedModulus e) * seedModulus e := by
            rw [hnmod]; ring

theorem mem_canonicalCylinder_oneBlockImage_iff {e₀ f k : Nat} (_he₀ : 1 ≤ e₀) :
    oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k ∈ canonicalCylinder f ↔
      oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k ≡ canonicalBase f [MOD seedModulus f] :=
  mem_canonicalCylinder_iff_modEq

theorem mem_canonicalCylinder_fiberIndexImage_iff {e₀ f k : Nat}
    (he₀ : 1 ≤ e₀) :
    realizedImage (fiberIndexMap e₀ k) (fiberE e₀) ∈ canonicalCylinder f ↔
      oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k ≡ canonicalBase f [MOD seedModulus f] := by
  rw [realizedImage_fiberIndexMap he₀ k]
  exact mem_canonicalCylinder_oneBlockImage_iff he₀

/-! ### D2b.3 — unique index class solving `2187 · κ ≡ halfDiff (mod 2^{f+8})` -/

/-- Index modulus for target fiber `f`: `2^{f+8}`. -/
def oneBlockIndexModulus (f : Nat) : Nat := 2 ^ (f + 8)

theorem oneBlockIndexModulus_pos (f : Nat) : 0 < oneBlockIndexModulus f :=
  Nat.pow_pos (by decide : 0 < 2)

theorem seedModulus_eq_two_mul_indexModulus (f : Nat) :
    seedModulus f = 2 * oneBlockIndexModulus f := by
  simp only [seedModulus, oneBlockIndexModulus]
  rw [show f + 9 = (f + 8) + 1 from by omega, pow_succ, Nat.mul_comm]

instance oneBlockIndexModulus.instNeZero (f : Nat) :
    NeZero (oneBlockIndexModulus f) :=
  ⟨Nat.pos_iff_ne_zero.mp (oneBlockIndexModulus_pos f)⟩

theorem odd_oneBlockBaseImage {e₀ : Nat} (he₀ : 1 ≤ e₀) :
    Odd (oneBlockBaseImage e₀) := by
  have hb := canonicalBase_realizes_of_one_le he₀
  have hne : fiberE e₀ ≠ [] := by
    rw [fiberE_list]; simp
  exact realizedImage_odd_of_ne_nil hne hb

theorem odd_canonicalBase_of_one_le {e : Nat} (he : 1 ≤ e) :
    Odd (canonicalBase e) := by
  have hb := canonicalBase_realizes_of_one_le he
  have hlist : fiberE e = [1, 1, 1, 1, 2, 2, e] := fiberE_list e
  rw [hlist] at hb
  obtain ⟨hodd, _, _⟩ := hb
  exact Nat.odd_iff.mpr hodd

theorem even_sub_of_odd_odd {a b : Nat} (ha : Odd a) (hb : Odd b) :
    Even ((a : ℤ) - (b : ℤ)) := by
  rw [Int.even_sub, Int.even_coe_nat, Int.even_coe_nat]
  refine iff_of_false ?_ ?_
  · exact Nat.not_even_iff_odd.mpr ha
  · exact Nat.not_even_iff_odd.mpr hb

/-- Half-difference `(b_f - q_{e₀})/2` as an integer. -/
noncomputable def oneBlockTargetHalfDiff (e₀ f : Nat) : ℤ :=
  ((canonicalBase f : ℤ) - (oneBlockBaseImage e₀ : ℤ)) / 2

theorem oneBlockTargetHalfDiff_mul_two {e₀ f : Nat}
    (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    2 * oneBlockTargetHalfDiff e₀ f =
      (canonicalBase f : ℤ) - (oneBlockBaseImage e₀ : ℤ) := by
  have heven :=
    even_sub_of_odd_odd (odd_canonicalBase_of_one_le hf) (odd_oneBlockBaseImage he₀)
  have h := Int.ediv_mul_cancel_of_dvd (even_iff_two_dvd.mp heven)
  -- `h : ((b-q)/2) * 2 = b - q`
  simpa [oneBlockTargetHalfDiff, mul_comm] using h

theorem coeff3_coprime_oneBlockIndexModulus (f : Nat) :
    Nat.Coprime coeff3 (oneBlockIndexModulus f) := by
  have h : Nat.Coprime coeff3 2 := by native_decide
  simpa [oneBlockIndexModulus] using
    (Nat.coprime_pow_right_iff (by omega : 0 < f + 8) coeff3 2).2 h

private theorem isUnit_coeff3_index (f : Nat) :
    IsUnit ((coeff3 : ZMod (oneBlockIndexModulus f))) :=
  (ZMod.isUnit_iff_coprime coeff3 (oneBlockIndexModulus f)).2
    (coeff3_coprime_oneBlockIndexModulus f)

/-- Unit of `3^7` in `ZMod 2^{f+8}`. -/
noncomputable def coeff3Unit (f : Nat) : (ZMod (oneBlockIndexModulus f))ˣ :=
  (isUnit_coeff3_index f).unit

theorem coeff3Unit_coe (f : Nat) :
    (coeff3Unit f : ZMod (oneBlockIndexModulus f)) = coeff3 :=
  IsUnit.unit_spec (isUnit_coeff3_index f)

/--
Canonical index class `κ(e₀,f)`: unique residue mod `2^{f+8}` solving
`2187 · κ ≡ (b_f - q_{e₀})/2`.
-/
noncomputable def oneBlockIndexClass (e₀ f : Nat) : Nat :=
  ((↑(coeff3Unit f)⁻¹ : ZMod (oneBlockIndexModulus f)) *
      (oneBlockTargetHalfDiff e₀ f : ZMod (oneBlockIndexModulus f))).val

theorem oneBlockIndexClass_lt (e₀ f : Nat) :
    oneBlockIndexClass e₀ f < oneBlockIndexModulus f :=
  ZMod.val_lt _

/--
`[C→A]` The residue `κ(e₀,f)` solves `coeff3 · κ = halfDiff` in `ZMod 2^{f+8}`.
-/
theorem oneBlockIndexClass_spec (e₀ f : Nat) :
    (coeff3 : ZMod (oneBlockIndexModulus f)) *
        (oneBlockIndexClass e₀ f : ZMod (oneBlockIndexModulus f)) =
      (oneBlockTargetHalfDiff e₀ f : ZMod (oneBlockIndexModulus f)) := by
  simp only [oneBlockIndexClass]
  rw [ZMod.natCast_zmod_val, ← coeff3Unit_coe f, ← mul_assoc, Units.mul_inv, one_mul]

theorem eq_oneBlockIndexClass_of_mul_eq {e₀ f k : Nat}
    (hk :
      (coeff3 : ZMod (oneBlockIndexModulus f)) * (k : ZMod (oneBlockIndexModulus f)) =
        (oneBlockTargetHalfDiff e₀ f : ZMod (oneBlockIndexModulus f))) :
    k ≡ oneBlockIndexClass e₀ f [MOD oneBlockIndexModulus f] := by
  have : (k : ZMod (oneBlockIndexModulus f)) =
      (oneBlockIndexClass e₀ f : ZMod (oneBlockIndexModulus f)) := by
    have hmul :=
      congrArg (fun z : ZMod (oneBlockIndexModulus f) =>
        (↑(coeff3Unit f)⁻¹ : ZMod (oneBlockIndexModulus f)) * z) hk
    have hsimp :
        (↑(coeff3Unit f)⁻¹ : ZMod (oneBlockIndexModulus f)) *
            ((coeff3 : ZMod (oneBlockIndexModulus f)) *
              (k : ZMod (oneBlockIndexModulus f))) =
          (k : ZMod (oneBlockIndexModulus f)) := by
      rw [← coeff3Unit_coe f, ← mul_assoc, Units.inv_mul, one_mul]
    rw [hsimp] at hmul
    simpa [oneBlockIndexClass, ZMod.natCast_zmod_val] using hmul
  exact (ZMod.natCast_eq_natCast_iff _ _ _).1 this

/--
`[C→A]` Unique index class for the reduced one-block congruence.
-/
theorem existsUnique_oneBlockIndexClass_modEq {e₀ f : Nat}
    (_he₀ : 1 ≤ e₀) (_hf : 1 ≤ f) :
    ∃! κ : Nat, κ < oneBlockIndexModulus f ∧
      (coeff3 : ZMod (oneBlockIndexModulus f)) * (κ : ZMod (oneBlockIndexModulus f)) =
        (oneBlockTargetHalfDiff e₀ f : ZMod (oneBlockIndexModulus f)) := by
  refine ExistsUnique.intro (oneBlockIndexClass e₀ f)
    ⟨oneBlockIndexClass_lt e₀ f, oneBlockIndexClass_spec e₀ f⟩ ?_
  intro κ' ⟨hκ'lt, hκ'spec⟩
  have hmod := eq_oneBlockIndexClass_of_mul_eq (e₀ := e₀) (f := f) hκ'spec
  have : κ' % oneBlockIndexModulus f =
      oneBlockIndexClass e₀ f % oneBlockIndexModulus f := hmod
  rwa [Nat.mod_eq_of_lt hκ'lt, Nat.mod_eq_of_lt (oneBlockIndexClass_lt e₀ f)] at this

/-! ### D2b.4 — positive witness `1246239 ∈ oneBlockFeedInSet 1` -/

theorem canonicalBase_one : canonicalBase 1 = 31 :=
  (canonicalBase_unique ⟨by decide, by native_decide⟩).symm

theorem oneBlockBaseImage_one : oneBlockBaseImage 1 = 137 := by
  simp only [oneBlockBaseImage, canonicalBase_one]
  exact realizedImage_fiberE_one_31

theorem fiberIndexMap_one_1217 : fiberIndexMap 1 1217 = 1246239 := by
  simp only [fiberIndexMap, canonicalBase_one, seedModulus]
  native_decide

theorem realizedImage_fiberIndexMap_one_1217 :
    realizedImage (fiberIndexMap 1 1217) (fiberE 1) = 5323295 := by
  rw [realizedImage_fiberIndexMap (by decide : 1 ≤ 1) 1217, oneBlockBaseImage_one]
  native_decide

theorem realizedImage_one_1246239 :
    realizedImage 1246239 (fiberE 1) = 5323295 := by
  simpa [fiberIndexMap_one_1217] using realizedImage_fiberIndexMap_one_1217

theorem realizes_fiberE_four_5323295 : RealizesWord (fiberE 4) 5323295 := by
  native_decide

theorem mem_canonicalCylinder_four_5323295 : 5323295 ∈ canonicalCylinder 4 :=
  (mem_canonicalCylinder_iff_realizes_fiberE (by decide : 1 ≤ 4)).2
    realizes_fiberE_four_5323295

theorem mem_contractingMass_5323295 : 5323295 ∈ contractingMass := by
  change 5323295 ∈ ⋃ e : Nat, ⋃ (_ : 4 ≤ e), canonicalCylinder e
  exact mem_iUnion.2 ⟨4, mem_iUnion.2 ⟨by decide, mem_canonicalCylinder_four_5323295⟩⟩

/--
`[C→A]` Positive one-block witness for `e₀ = 1`, target `f = 4`:
`k = 1217`, `n = Φ_1(1217) = 1246239`, image `5323295 ∈ C_4`.
-/
theorem mem_oneBlockFeedInSet_one_1246239 :
    1246239 ∈ oneBlockFeedInSet 1 := by
  refine ⟨?_, ?_⟩
  · simpa [← fiberIndexMap_one_1217, ← canonicalCylinder_eq_ap] using
      fiberIndexMap_mem 1 1217
  · simpa [realizedImage_one_1246239] using mem_contractingMass_5323295

theorem oneBlockFeedInSet_one_nonempty : (oneBlockFeedInSet 1).Nonempty :=
  ⟨1246239, mem_oneBlockFeedInSet_one_1246239⟩

/--
`[C→A]` Strict sandwich for `e₀ = 1`:
`∅ ⊂ oneBlockFeedInSet 1 ⊂ C_1`.
-/
theorem oneBlockFeedInSet_one_sandwich :
    (∅ : Set Nat) ⊂ oneBlockFeedInSet 1 ∧
      oneBlockFeedInSet 1 ⊂ canonicalCylinder 1 :=
  ⟨(Set.empty_ssubset).2 oneBlockFeedInSet_one_nonempty,
    oneBlockFeedInSet_one_ssubset_canonicalCylinder⟩

/-! ### Experiment package -/

/--
Experiment package after D1 / D2a / D2b.1–.4:
- one-block universal claim is refuted;
- affine index formula is available;
- `∅ ⊂ oneBlockFeedInSet 1 ⊂ C_1`;
- reachability remains classically open.
-/
structure Core6DynamicFeedInGoals : Prop where
  oneBlockRefuted : ¬ OneBlockFeedInGoal
  affineBlockMap : ∀ e₀ : Nat, 1 ≤ e₀ → ∀ k : Nat,
    realizedImage (fiberIndexMap e₀ k) (fiberE e₀) =
      oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k
  oneBlockSetSandwich_e1 :
    (∅ : Set Nat) ⊂ oneBlockFeedInSet 1 ∧
      oneBlockFeedInSet 1 ⊂ canonicalCylinder 1
  reachabilityOpen : ReachabilityFeedInGoal ∨ ¬ReachabilityFeedInGoal

theorem core6DynamicFeedInGoals_named : Core6DynamicFeedInGoals where
  oneBlockRefuted := not_oneBlockFeedInGoal
  affineBlockMap := fun _e₀ he₀ k => realizedImage_fiberIndexMap he₀ k
  oneBlockSetSandwich_e1 := oneBlockFeedInSet_one_sandwich
  reachabilityOpen := Classical.em _

/-- Import hook: static certificate is available, unused for dynamics. -/
theorem staticCertificate_available : Core6StaticDyadicCertificate :=
  core6StaticDyadicCertificate

/-!
## Explicit non-theorems

- `ReachabilityFeedInGoal` is **not** a corollary of `core6StaticDyadicCertificate`.
- Dyadic density `1/8` is **not** a hitting probability for expanding channels.
- A finite D1 census (`[B]`) never upgrades reachability to `[A]`.
- `¬ OneBlockFeedInGoal` does **not** imply `¬ ReachabilityFeedInGoal`.
- The full disjoint-union decomposition of `oneBlockFeedInSet` (D2b.5) is not yet discharged.
- No collapse / global Collatz statement is in scope.
-/

end KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn
