import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Tactic.IntervalCases
import KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn
import KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
import KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase

set_option linter.style.nativeDecide false
set_option autoImplicit false

/-!
# Pre119Draft — Core6DynamicD3 (Follow-up after D2b freeze)

**Base:** PR #17 / `Core6DynamicFeedIn` (D2b frozen at `18e8747`).
**This module** starts D3.0–D3.1 algebraic structure; D3.3–D4 remain `[C]`.

Must not reopen PR #16 static math or the frozen D2b package.
No Collatz claim. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3

open Set
open KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
open KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

open KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn

/-! ### D3.0 — semantic one-block trichotomy -/

/-- Starts whose one-block image lands back in an expanding Core6 channel. -/
def oneBlockExpandingReturnSet (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∈ expandingCore6}

/-- Starts whose one-block image leaves the entire Core6 cylinder. -/
def oneBlockOffCore6Set (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∉ core6Cylinder}

/--
`[C→A]` After one full `fiberE e₀` block, every start in `C_{e₀}` falls into
exactly one of: contracting hit / expanding return / off-Core6 exit.
-/
theorem canonicalCylinder_eq_oneBlock_trichotomy {e₀ : Nat} (_he₀ : 1 ≤ e₀) :
    canonicalCylinder e₀ =
      oneBlockFeedInSet e₀ ∪
        oneBlockExpandingReturnSet e₀ ∪
          oneBlockOffCore6Set e₀ := by
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have hcore_eq : core6Cylinder = expandingCore6 ∪ contractingCore6 := hphase.1
  ext n
  constructor
  · intro hnC
    set img := realizedImage n (fiberE e₀)
    by_cases hcon : img ∈ contractingCore6
    · left; left
      exact ⟨hnC, by simpa [contractingMass] using hcon⟩
    · by_cases hexp : img ∈ expandingCore6
      · left; right
        exact ⟨hnC, hexp⟩
      · right
        refine ⟨hnC, ?_⟩
        intro hcore
        have : img ∈ expandingCore6 ∪ contractingCore6 := by
          rwa [← hcore_eq]
        exact Or.elim this hexp hcon
  · intro hn
    exact hn.elim (fun h => h.elim (fun hF => hF.1) (fun hE => hE.1))
      (fun hO => hO.1)

theorem oneBlockFeedIn_disjoint_expandingReturn (e₀ : Nat) :
    Disjoint (oneBlockFeedInSet e₀) (oneBlockExpandingReturnSet e₀) := by
  refine disjoint_left.2 ?_
  intro n hF hE
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have himgF : realizedImage n (fiberE e₀) ∈ contractingCore6 := by
    simpa [contractingMass] using hF.2
  exact (disjoint_left.1 hphase.2) hE.2 himgF

theorem oneBlockFeedIn_disjoint_offCore6 (e₀ : Nat) :
    Disjoint (oneBlockFeedInSet e₀) (oneBlockOffCore6Set e₀) := by
  refine disjoint_left.2 ?_
  intro n hF hO
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have himg : realizedImage n (fiberE e₀) ∈ contractingCore6 := by
    simpa [contractingMass] using hF.2
  have hcore : realizedImage n (fiberE e₀) ∈ core6Cylinder := by
    rw [hphase.1]; exact Or.inr himg
  exact hO.2 hcore

theorem oneBlockExpandingReturn_disjoint_offCore6 (e₀ : Nat) :
    Disjoint (oneBlockExpandingReturnSet e₀) (oneBlockOffCore6Set e₀) := by
  refine disjoint_left.2 ?_
  intro n hE hO
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have hcore : realizedImage n (fiberE e₀) ∈ core6Cylinder := by
    rw [hphase.1]; exact Or.inl hE.2
  exact hO.2 hcore

/-- Expanding return is the union of progressions into `C_1,C_2,C_3`. -/
theorem oneBlockExpandingReturnSet_eq_iUnion_progressions {e₀ : Nat}
    (he₀ : 1 ≤ e₀) :
    oneBlockExpandingReturnSet e₀ =
      ⋃ f : Nat, ⋃ (_ : 1 ≤ f ∧ f ≤ 3), oneBlockTargetProgression e₀ f := by
  ext n
  constructor
  · intro hn
    obtain ⟨hnC, himg⟩ := hn
    have himg' :
        realizedImage n (fiberE e₀) ∈ canonicalCylinder 1 ∨
          realizedImage n (fiberE e₀) ∈ canonicalCylinder 2 ∨
            realizedImage n (fiberE e₀) ∈ canonicalCylinder 3 := by
      simpa [expandingCore6, smallTailCore6, or_assoc] using himg
    rcases himg' with h1 | h2 | h3
    · exact mem_iUnion.2
        ⟨1, mem_iUnion.2 ⟨⟨by decide, by decide⟩,
          (mem_oneBlockTargetProgression_iff he₀ (by decide)).2 ⟨hnC, h1⟩⟩⟩
    · exact mem_iUnion.2
        ⟨2, mem_iUnion.2 ⟨⟨by decide, by decide⟩,
          (mem_oneBlockTargetProgression_iff he₀ (by decide)).2 ⟨hnC, h2⟩⟩⟩
    · exact mem_iUnion.2
        ⟨3, mem_iUnion.2 ⟨⟨by decide, by decide⟩,
          (mem_oneBlockTargetProgression_iff he₀ (by decide)).2 ⟨hnC, h3⟩⟩⟩
  · intro hn
    obtain ⟨f, hf'⟩ := mem_iUnion.1 hn
    obtain ⟨hfg, hP⟩ := mem_iUnion.1 hf'
    obtain ⟨hf1, hf3⟩ := hfg
    have hmem := (mem_oneBlockTargetProgression_iff he₀ hf1).1 hP
    refine ⟨hmem.1, ?_⟩
    have himg : realizedImage n (fiberE e₀) ∈ canonicalCylinder f := hmem.2
    have : f = 1 ∨ f = 2 ∨ f = 3 := by omega
    rcases this with rfl | rfl | rfl
    · exact Or.inl (Or.inl himg)
    · exact Or.inl (Or.inr himg)
    · exact Or.inr himg

/-- Witness: `31` exits Core6 after one block (`image = 137`). -/
theorem mem_oneBlockOffCore6Set_one_31 : 31 ∈ oneBlockOffCore6Set 1 := by
  refine ⟨mem_canonicalCylinder_one_31, ?_⟩
  intro hcore
  have : RealizesWord core6 137 := by
    change 137 ∈ core6Cylinder
    simpa [realizedImage_fiberE_one_31] using hcore
  exact not_realizes_core6_137 this

theorem oneBlockOffCore6Set_one_nonempty : (oneBlockOffCore6Set 1).Nonempty :=
  ⟨31, mem_oneBlockOffCore6Set_one_31⟩

/-! ### D3.1 — affine target-index transport -/

theorem exists_unique_oneBlockTargetBaseIndex {e₀ f : Nat}
    (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    ∃! j : Nat,
      fiberIndexMap f j =
        realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) := by
  set img :=
    realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀)
  have himgC : img ∈ canonicalCylinder f :=
    (fiberIndexImage_mem_target_iff_index_modEq he₀ hf).2 (Nat.ModEq.refl _)
  obtain ⟨j, hj⟩ := exists_fiberIndex_of_mem_cylinder himgC
  refine ExistsUnique.intro j hj.symm ?_
  intro j' hj'
  exact fiberIndexMap_injective f (hj'.trans hj)

/--
Unique target index `λ(e₀,f)` of the canonical one-block landing
`Φ_{e₀}(κ(e₀,f)) ↦ Φ_f(λ)`.
-/
noncomputable def oneBlockTargetBaseIndex
    (e₀ f : Nat) (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) : Nat :=
  Classical.choose (ExistsUnique.exists (exists_unique_oneBlockTargetBaseIndex he₀ hf))

theorem oneBlockTargetBaseIndex_spec {e₀ f : Nat}
    (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) =
      realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) :=
  Classical.choose_spec
    (ExistsUnique.exists (exists_unique_oneBlockTargetBaseIndex he₀ hf))

theorem fiberIndexMap_add (e j t : Nat) :
    fiberIndexMap e (j + t) = fiberIndexMap e j + t * seedModulus e := by
  simp [fiberIndexMap]; ring

theorem oneBlock_step_scale (f : Nat) :
    (4374 : Nat) * oneBlockIndexModulus f = coeff3 * seedModulus f := by
  have h4374 : (4374 : Nat) = 2 * coeff3 := by
    simp only [coeff3_eq_three_pow]; native_decide
  rw [h4374, seedModulus_eq_two_mul_indexModulus f]
  ring

/--
`[C→A]` Affine target-index transport:
source index `κ + r·2^{f+8}` maps to target index `λ + 2187·r`.
-/
theorem oneBlock_targetIndex_affine {e₀ f r : Nat}
    (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    realizedImage
        (fiberIndexMap e₀
          (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
        (fiberE e₀) =
      fiberIndexMap f
        (oneBlockTargetBaseIndex e₀ f he₀ hf + coeff3 * r) := by
  have hbase := oneBlockTargetBaseIndex_spec he₀ hf
  have himg :=
    realizedImage_fiberIndexMap_coeff he₀
      (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f)
  have himg0 :=
    realizedImage_fiberIndexMap_coeff he₀ (oneBlockIndexClass e₀ f)
  have hsum :
      realizedImage
          (fiberIndexMap e₀
            (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
          (fiberE e₀) =
        realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) +
          4374 * r * oneBlockIndexModulus f := by
    rw [himg, himg0]; ring
  have hscale := oneBlock_step_scale f
  calc
    realizedImage
        (fiberIndexMap e₀
          (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
        (fiberE e₀)
        = realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) +
            4374 * r * oneBlockIndexModulus f := hsum
    _ = fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) +
            r * (4374 * oneBlockIndexModulus f) := by
          rw [hbase]; ring
    _ = fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) +
            r * (coeff3 * seedModulus f) := by rw [hscale]
    _ = fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) +
            (coeff3 * r) * seedModulus f := by ring
    _ = fiberIndexMap f
          (oneBlockTargetBaseIndex e₀ f he₀ hf + coeff3 * r) := by
          symm; exact fiberIndexMap_add _ _ _

/-! ### Open D3/D4 dynamical goals (definitions only) -/

/--
`[C]` Hits contracting mass at a complete block boundary (`t = 7r`).
-/
def BlockBoundaryFeedInGoal : Prop :=
  ∀ n ∈ expandingMass,
    ∃ r : Nat, 1 ≤ r ∧
      syracuseOddIterate (7 * r) n ∈ contractingMass

/--
`[C]` After exiting Core6 in one block, some later odd iterate re-enters Core6.
-/
def OffCore6ReentryGoal : Prop :=
  ∀ e₀ : Nat, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ oneBlockOffCore6Set e₀,
      ∃ s : Nat, 1 ≤ s ∧
        syracuseOddIterate s (realizedImage n (fiberE e₀)) ∈ core6Cylinder

theorem blockBoundaryFeedIn_implies_reachability :
    BlockBoundaryFeedInGoal → ReachabilityFeedInGoal := by
  intro h n hn
  obtain ⟨r, hr, himg⟩ := h n hn
  exact ⟨7 * r, by omega, himg⟩

/-! ### D3 algebraic package -/

structure Core6DynamicD3AlgebraGoals : Prop where
  trichotomy : ∀ e₀ : Nat, 1 ≤ e₀ →
    canonicalCylinder e₀ =
      oneBlockFeedInSet e₀ ∪
        oneBlockExpandingReturnSet e₀ ∪
          oneBlockOffCore6Set e₀
  expandingReturnProgressions : ∀ e₀ : Nat, 1 ≤ e₀ →
    oneBlockExpandingReturnSet e₀ =
      ⋃ f : Nat, ⋃ (_ : 1 ≤ f ∧ f ≤ 3), oneBlockTargetProgression e₀ f
  targetIndexAffine :
    ∀ e₀ f r : Nat, ∀ he₀ : 1 ≤ e₀, ∀ hf : 1 ≤ f,
      realizedImage
          (fiberIndexMap e₀
            (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
          (fiberE e₀) =
        fiberIndexMap f
          (oneBlockTargetBaseIndex e₀ f he₀ hf + coeff3 * r)
  offCore6Witness : 31 ∈ oneBlockOffCore6Set 1
  blockBoundaryImpliesReachability :
    BlockBoundaryFeedInGoal → ReachabilityFeedInGoal

theorem core6DynamicD3AlgebraGoals_named : Core6DynamicD3AlgebraGoals where
  trichotomy := fun _ he => canonicalCylinder_eq_oneBlock_trichotomy he
  expandingReturnProgressions := fun _ he =>
    oneBlockExpandingReturnSet_eq_iUnion_progressions he
  targetIndexAffine := fun _ _ _ he₀ hf => oneBlock_targetIndex_affine he₀ hf
  offCore6Witness := mem_oneBlockOffCore6Set_one_31
  blockBoundaryImpliesReachability := blockBoundaryFeedIn_implies_reachability

/-!
## Explicit non-theorems

- `BlockBoundaryFeedInGoal` / `OffCore6ReentryGoal` are not discharged.
- `ReachabilityFeedInGoal` remains `[C]`.
- No Collatz / collapse statement.
-/

end KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3
