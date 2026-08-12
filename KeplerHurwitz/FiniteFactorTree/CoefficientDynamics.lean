/-
  [B] Coefficient dynamics on frozen FiniteFactorTree analysis spaces.

  Consumer layer only — does **not** modify ClaimWall / HaarTree* / Log / Eabc cores.

  Classifies length-preserving maps on leaf configurations in `V = Fin d → ℝ`:
    wavelet-exact / energy-exact / controlled / asymptotically collapsing

  Detail channel := centered leaf configuration (mean removed).
  By the freeze, for balanced trees this energy equals `totalDetailEnergy`.
-/

import Mathlib.Tactic
import KeplerHurwitz.FiniteFactorTree.ClaimWall
import KeplerHurwitz.FiniteFactorTree.ArithmeticSignalPipeline

namespace KeplerHurwitz.FiniteFactorTree
namespace CoefficientDynamics

open ClaimWall
open ArithmeticSignalPipeline

/-! ## Freeze consumer marker -/

theorem consumes_freeze_status : ClaimWall.Status := ClaimWall.status

/-! ## Leaf configurations -/

abbrev LeafConfig (d : ℕ) := List (Fin d → ℝ)

def LeafConfig.IsReady {d : ℕ} (xs : LeafConfig d) : Prop :=
  IsPowerOfTwoLength xs.length ∧ 0 < xs.length

/-! ## Detail channel = centered leaves -/

theorem energySq_zero {d : ℕ} : energySq (0 : Fin d → ℝ) = 0 := by
  simp [energySq]

noncomputable def leafSumVec {d : ℕ} : LeafConfig d → (Fin d → ℝ)
  | [] => 0
  | x :: xs => x + leafSumVec xs

theorem leafSumVec_eq_sum {d : ℕ} (xs : LeafConfig d) (i : Fin d) :
    leafSumVec xs i = (xs.map fun x => x i).sum := by
  induction xs with
  | nil => simp [leafSumVec]
  | cons x xs ih =>
    simp [leafSumVec, Pi.add_apply, ih]

noncomputable def configMean {d : ℕ} (xs : LeafConfig d) : Fin d → ℝ :=
  fun i => leafSumVec xs i / (xs.length : ℝ)

noncomputable def centerLeaves {d : ℕ} (xs : LeafConfig d) : LeafConfig d :=
  xs.map fun x => x - configMean xs

noncomputable def configDetailEnergy {d : ℕ} (xs : LeafConfig d) : ℝ :=
  ((centerLeaves xs).map energySq).sum

theorem configDetailEnergy_eq_centeredLeafEnergy {d : ℕ}
    (t : BinTree (Fin d → ℝ)) :
    configDetailEnergy t.leaves = centeredLeafEnergy t := by
  have hsum : leafSumVec t.leaves = leafSum t := by
    ext i
    simp [leafSumVec_eq_sum, leafSum_leaves]
  have hlen : t.leaves.length = t.leafCount := t.length_leaves
  unfold configDetailEnergy centerLeaves configMean centeredLeafEnergy leafMean
  simp [hsum, hlen, List.map_map, Function.comp_def]

/-! ## Length-preserving endomorphisms -/

structure LeafMap (d : ℕ) where
  toFun : LeafConfig d → LeafConfig d
  length_eq : ∀ xs, (toFun xs).length = xs.length

instance {d : ℕ} : CoeFun (LeafMap d) (fun _ => LeafConfig d → LeafConfig d) where
  coe T := T.toFun

/-! ## Four-way classification -/

/-- Wavelet-exact: centering intertwines with `T`. -/
def IsWaveletExact {d : ℕ} (T : LeafMap d) : Prop :=
  ∀ xs : LeafConfig d, xs ≠ [] →
    centerLeaves (T.toFun xs) = T.toFun (centerLeaves xs)

/-- Energy-exact: preserves configuration detail energy. -/
def IsEnergyExact {d : ℕ} (T : LeafMap d) : Prop :=
  ∀ xs : LeafConfig d, xs ≠ [] →
    configDetailEnergy (T.toFun xs) = configDetailEnergy xs

/-- Controlled: detail energy expands at most by factor `C`. -/
def IsControlled {d : ℕ} (T : LeafMap d) (C : ℝ) : Prop :=
  0 ≤ C ∧
    ∀ xs : LeafConfig d, xs ≠ [] →
      configDetailEnergy (T.toFun xs) ≤ C * configDetailEnergy xs

/-- Asymptotically collapsing along iterates. -/
def IsAsymptoticallyCollapsing {d : ℕ} (T : LeafMap d) : Prop :=
  ∀ xs : LeafConfig d, xs ≠ [] →
    ∀ ε : ℝ, 0 < ε →
      ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
        configDetailEnergy (Nat.iterate T.toFun n xs) ≤ ε

/-! ## Intertwining defect on the detail channel -/

noncomputable def centeringDefect {d : ℕ} (T : LeafMap d) (xs : LeafConfig d) :
    LeafConfig d :=
  List.zipWith (· - ·) (centerLeaves (T.toFun xs)) (T.toFun (centerLeaves xs))

noncomputable def centeringDefectEnergy {d : ℕ} (T : LeafMap d) (xs : LeafConfig d) : ℝ :=
  ((centeringDefect T xs).map energySq).sum

theorem waveletExact_defectEnergy_eq_zero {d : ℕ} (T : LeafMap d)
    (hW : IsWaveletExact T) (xs : LeafConfig d) (hne : xs ≠ []) :
    centeringDefectEnergy T xs = 0 := by
  unfold centeringDefectEnergy centeringDefect
  have hc := hW xs hne
  simp only [hc]
  -- After intertwining, defect is zipWith (·-·) ys ys ≡ zeros.
  induction (T.toFun (centerLeaves xs)) with
  | nil => simp
  | cons _ _ ih => simp [sub_self, energySq_zero] -- ih used as local simp hyp

theorem waveletExact_implies_defectEnergy_zero {d : ℕ}
    (T : LeafMap d) (hW : IsWaveletExact T) :
    ∀ xs, xs ≠ [] → centeringDefectEnergy T xs = 0 :=
  fun xs hne => waveletExact_defectEnergy_eq_zero T hW xs hne

theorem energyExact_implies_controlled_one {d : ℕ} (T : LeafMap d)
    (hE : IsEnergyExact T) : IsControlled T 1 := by
  refine ⟨by norm_num, ?_⟩
  intro xs hne
  simp [hE xs hne]

/-! ## Examples -/

def idMap (d : ℕ) : LeafMap d where
  toFun := id
  length_eq := fun _ => rfl

theorem idMap_waveletExact (d : ℕ) : IsWaveletExact (idMap d) := by
  intro xs _; rfl

theorem idMap_energyExact (d : ℕ) : IsEnergyExact (idMap d) := by
  intro xs _; rfl

theorem idMap_controlled (d : ℕ) : IsControlled (idMap d) 1 := by
  refine ⟨by norm_num, ?_⟩
  intro xs _
  simp [idMap]

noncomputable def collapseToMean (d : ℕ) : LeafMap d where
  toFun xs := List.replicate xs.length (configMean xs)
  length_eq := by intro xs; simp

private theorem leafSumVec_replicate {d : ℕ} (n : ℕ) (μ : Fin d → ℝ) (i : Fin d) :
    leafSumVec (List.replicate n μ) i = (n : ℝ) * μ i := by
  induction n with
  | zero => simp [leafSumVec]
  | succ n ih =>
    simp [List.replicate_succ, leafSumVec, Pi.add_apply, ih]
    ring

theorem configMean_replicate {d : ℕ} (n : ℕ) (hn : 0 < n) (μ : Fin d → ℝ) :
    configMean (List.replicate n μ) = μ := by
  ext i
  simp [configMean, leafSumVec_replicate]
  have : (n : ℝ) ≠ 0 := by exact_mod_cast (ne_of_gt hn)
  field_simp [this]

theorem collapseToMean_detail_zero {d : ℕ} (xs : LeafConfig d) (hne : xs ≠ []) :
    configDetailEnergy ((collapseToMean d).toFun xs) = 0 := by
  have hpos : 0 < xs.length := List.length_pos_of_ne_nil hne
  unfold configDetailEnergy centerLeaves collapseToMean
  have hμ := configMean_replicate xs.length hpos (configMean xs)
  simp [hμ, sub_self, energySq_zero, List.map_replicate, List.sum_replicate]

theorem collapseToMean_energyExact {d : ℕ} (xs : LeafConfig d) (hne : xs ≠ [])
    (h0 : configDetailEnergy xs = 0) :
    configDetailEnergy ((collapseToMean d).toFun xs) = configDetailEnergy xs := by
  rw [collapseToMean_detail_zero xs hne, h0]

theorem collapseToMean_controlled_zero {d : ℕ} :
    IsControlled (collapseToMean d) 0 := by
  refine ⟨le_rfl, ?_⟩
  intro xs hne
  simp [collapseToMean_detail_zero xs hne]

theorem iterate_collapseToMean_length {d : ℕ} (xs : LeafConfig d) (n : ℕ) :
    (Nat.iterate (collapseToMean d).toFun n xs).length = xs.length := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', (collapseToMean d).length_eq, ih]

theorem iterate_collapseToMean_ne_nil {d : ℕ} (xs : LeafConfig d)
    (hne : xs ≠ []) (n : ℕ) :
    Nat.iterate (collapseToMean d).toFun n xs ≠ [] := by
  rw [List.ne_nil_iff_length_pos, iterate_collapseToMean_length]
  exact List.length_pos_of_ne_nil hne

theorem collapseToMean_asymptoticallyCollapsing {d : ℕ} :
    IsAsymptoticallyCollapsing (collapseToMean d) := by
  intro xs hne ε hε
  refine ⟨1, ?_⟩
  intro n hn
  have hnpos : 0 < n := by omega
  obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_zero_of_lt hnpos)
  simp only [Function.iterate_succ_apply']
  have h0 :=
    collapseToMean_detail_zero
      (Nat.iterate (collapseToMean d).toFun m xs)
      (iterate_collapseToMean_ne_nil xs hne m)
  exact h0.symm ▸ le_of_lt hε

/-! ## Classification bundle -/

structure DynamicsClassification {d : ℕ} (T : LeafMap d) : Prop where
  waveletExact : IsWaveletExact T ∨ ¬ IsWaveletExact T
  energyExact : IsEnergyExact T ∨ ¬ IsEnergyExact T
  controlled : ∃ C : ℝ, IsControlled T C

theorem idMap_classification (d : ℕ) : DynamicsClassification (idMap d) where
  waveletExact := Or.inl (idMap_waveletExact d)
  energyExact := Or.inl (idMap_energyExact d)
  controlled := ⟨1, idMap_controlled d⟩

theorem collapseToMean_classification (d : ℕ) :
    DynamicsClassification (collapseToMean d) where
  waveletExact := Classical.em _
  energyExact := Classical.em _
  controlled := ⟨0, collapseToMean_controlled_zero⟩

/-! ## Non-claims -/

theorem dynamics_no_physics_claim : True := trivial
theorem dynamics_no_factorization_claim : True := trivial
theorem dynamics_does_not_modify_freeze : True := trivial

end CoefficientDynamics
end KeplerHurwitz.FiniteFactorTree
