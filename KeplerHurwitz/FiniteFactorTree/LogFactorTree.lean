/-
  [B1] Finite logarithmic factor tree — instance of Haar trees on `Fin 1 → ℝ`.

  Primary carrier: abstract additive leaf weights `w : ℝ`.
  Analytic instance: `Real.log` on positive naturals (analytic, not pure [A]).

  Claim wall:
    [B1] finite Haar Parseval / tree-independent total detail energy on log-weights
    [A] reused only via `FiniteFactorTree.HaarTree*` (no change to SemiprimeWavelet)
    [C] classical arithmetic MRA / factorization algorithm — NOT claimed
-/

import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic
import KeplerHurwitz.FiniteFactorTree.HaarTreeEnergy

namespace KeplerHurwitz.FiniteFactorTree
namespace LogFactor

/-! ## Scalar embedding into `Fin 1 → ℝ` -/

def toLeaf (w : ℝ) : Fin 1 → ℝ := fun _ => w

theorem energySq_toLeaf (w : ℝ) : energySq (toLeaf w) = w ^ 2 := by
  simp [energySq, toLeaf]

noncomputable def logScale (wa wb : ℝ) : ℝ := (wa + wb) / Real.sqrt 2
noncomputable def logDetail (wa wb : ℝ) : ℝ := (wa - wb) / Real.sqrt 2
noncomputable def logDetailEnergy (wa wb : ℝ) : ℝ := (logDetail wa wb) ^ 2

theorem log_local_parseval (wa wb : ℝ) :
    wa ^ 2 + wb ^ 2 = (logScale wa wb) ^ 2 + (logDetail wa wb) ^ 2 := by
  have h := local_parseval (toLeaf wa) (toLeaf wb)
  simpa [energySq_toLeaf, logScale, logDetail, haarScale, haarDetail, toLeaf, energySq]
    using h

theorem log_reconstruct_left (wa wb : ℝ) :
    (logScale wa wb + logDetail wa wb) / Real.sqrt 2 = wa := by
  have h := reconstruct_left (toLeaf wa) (toLeaf wb)
  simpa [haarScale, haarDetail, logScale, logDetail, toLeaf] using congrFun h ⟨0, by decide⟩

theorem log_reconstruct_right (wa wb : ℝ) :
    (logScale wa wb - logDetail wa wb) / Real.sqrt 2 = wb := by
  have h := reconstruct_right (toLeaf wa) (toLeaf wb)
  simpa [haarScale, haarDetail, logScale, logDetail, toLeaf] using congrFun h ⟨0, by decide⟩

theorem log_detail_swap (wa wb : ℝ) : logDetail wb wa = -logDetail wa wb := by
  unfold logDetail; ring

theorem log_detailEnergy_swap (wa wb : ℝ) :
    logDetailEnergy wb wa = logDetailEnergy wa wb := by
  unfold logDetailEnergy
  rw [log_detail_swap, neg_sq]

theorem log_detailEnergy_eq_zero_iff (wa wb : ℝ) :
    logDetailEnergy wa wb = 0 ↔ wa = wb := by
  unfold logDetailEnergy logDetail
  constructor
  · intro h
    have : (wa - wb) / Real.sqrt 2 = 0 := sq_eq_zero_iff.mp h
    have : wa - wb = 0 := (div_eq_zero_iff.mp this).resolve_right sqrt_two_ne_zero
    exact sub_eq_zero.mp this
  · intro h
    simp [h]

theorem log_detailEnergy_smul (k wa wb : ℝ) :
    logDetailEnergy (k * wa) (k * wb) = k ^ 2 * logDetailEnergy wa wb := by
  unfold logDetailEnergy logDetail
  ring

/-! ### Analytic log instance -/

noncomputable def logWeight (n : ℕ) (_hn : 0 < n) : ℝ := Real.log n

theorem logWeight_mul {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    logWeight (a * b) (Nat.mul_pos ha hb) = logWeight a ha + logWeight b hb := by
  simp [logWeight, Real.log_mul (Nat.cast_ne_zero.mpr (ne_of_gt ha))
    (Nat.cast_ne_zero.mpr (ne_of_gt hb))]

noncomputable def factorDetailEnergy (a b : ℕ) (ha : 0 < a) (hb : 0 < b) : ℝ :=
  logDetailEnergy (logWeight a ha) (logWeight b hb)

theorem factorDetailEnergy_eq_zero_iff_eq {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    factorDetailEnergy a b ha hb = 0 ↔ a = b := by
  constructor
  · intro h
    have hlog : Real.log a = Real.log b := by
      simpa [factorDetailEnergy, logWeight, log_detailEnergy_eq_zero_iff] using h
    have ha' : (0 : ℝ) < a := Nat.cast_pos.mpr ha
    have hb' : (0 : ℝ) < b := Nat.cast_pos.mpr hb
    exact Nat.cast_injective (Real.log_injOn_pos ha' hb' hlog)
  · intro h
    subst h
    simp [factorDetailEnergy, log_detailEnergy_eq_zero_iff]

/-! ### Balanced log trees -/

def mapWeights : BinTree ℝ → BinTree (Fin 1 → ℝ)
  | .leaf w => .leaf (toLeaf w)
  | .node l r => .node (mapWeights l) (mapWeights r)

theorem mapWeights_leafCount (t : BinTree ℝ) :
    (mapWeights t).leafCount = t.leafCount := by
  induction t with
  | leaf _ => rfl
  | node l r ihl ihr => simp [mapWeights, BinTree.leafCount, ihl, ihr]

theorem mapWeights_leaves (t : BinTree ℝ) :
    (mapWeights t).leaves = t.leaves.map toLeaf := by
  induction t with
  | leaf _ => rfl
  | node l r ihl ihr => simp [mapWeights, BinTree.leaves, ihl, ihr]

theorem mapWeights_balanced (t : BinTree ℝ) (hb : t.IsBalanced) :
    (mapWeights t).IsBalanced := by
  induction t with
  | leaf _ => trivial
  | node l r ihl ihr =>
    rcases hb with ⟨hbL, hbR, hcnt⟩
    exact ⟨ihl hbL, ihr hbR, by simp [mapWeights_leafCount, hcnt]⟩

theorem log_tree_totalEnergy (t : BinTree ℝ) (hb : t.IsBalanced) :
    totalDetailEnergy (mapWeights t) = centeredLeafEnergy (mapWeights t) :=
  totalDetailEnergy_eq_centeredLeafEnergy _ (mapWeights_balanced t hb)

theorem log_tree_totalEnergy_independent (t₁ t₂ : BinTree ℝ)
    (hb₁ : t₁.IsBalanced) (hb₂ : t₂.IsBalanced)
    (hleaves : t₁.leaves = t₂.leaves) :
    totalDetailEnergy (mapWeights t₁) = totalDetailEnergy (mapWeights t₂) := by
  apply totalDetailEnergy_eq_of_same_leaves
  · exact mapWeights_balanced t₁ hb₁
  · exact mapWeights_balanced t₂ hb₂
  · simp [mapWeights_leaves, hleaves]

theorem no_factorization_algorithm_claim : True := trivial
theorem abstract_weights_primary_claim : True := trivial

end LogFactor
end KeplerHurwitz.FiniteFactorTree
