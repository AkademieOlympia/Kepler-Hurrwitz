/-
  Tree-independent total detail energy for balanced finite Haar trees.

  Master identity (balanced trees):
    totalDetailEnergy t = centeredLeafEnergy t

  Claim wall:
    [A] identity above; tree-independence of the *scalar* total energy
    [B] individual detail coefficients remain tree-dependent
    [C] physical energy reading — NOT claimed
-/

import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic
import KeplerHurwitz.FiniteFactorTree.HaarTreeCore

namespace KeplerHurwitz.FiniteFactorTree

/-! ## Leaf sum / mean / centered energy -/

noncomputable def leafSum {d : ℕ} : BinTree (Fin d → ℝ) → (Fin d → ℝ)
  | .leaf x => x
  | .node l r => leafSum l + leafSum r

theorem leafSum_leaves {d : ℕ} (t : BinTree (Fin d → ℝ)) (i : Fin d) :
    leafSum t i = (t.leaves.map fun x => x i).sum := by
  induction t with
  | leaf x => simp [leafSum, BinTree.leaves]
  | node l r ihl ihr =>
    simp [leafSum, BinTree.leaves, List.map_append, List.sum_append, ihl, ihr, Pi.add_apply]

noncomputable def leafMean {d : ℕ} (t : BinTree (Fin d → ℝ)) : Fin d → ℝ :=
  fun i => leafSum t i / (t.leafCount : ℝ)

noncomputable def centeredLeafEnergy {d : ℕ} (t : BinTree (Fin d → ℝ)) : ℝ :=
  (t.leaves.map fun x => energySq (x - leafMean t)).sum

/-! ## 1D variance identity -/

theorem map_sub_sq_expand (xs : List ℝ) (μ : ℝ) :
    (xs.map fun a => (a - μ) ^ 2).sum =
      (xs.map fun a => a ^ 2).sum - 2 * μ * xs.sum + (xs.length : ℝ) * μ ^ 2 := by
  induction xs with
  | nil => simp
  | cons a xs ih =>
    simp only [List.map_cons, List.sum_cons, List.length_cons, Nat.cast_add, Nat.cast_one] at ih ⊢
    rw [ih]
    ring

theorem real_list_variance (xs : List ℝ) (μ : ℝ) (hμ : xs.sum = (xs.length : ℝ) * μ) :
    (xs.map fun a => a ^ 2).sum =
      (xs.length : ℝ) * μ ^ 2 + (xs.map fun a => (a - μ) ^ 2).sum := by
  have h := map_sub_sq_expand xs μ
  rw [hμ] at h
  linarith

private theorem sum_map_coord_sq {d : ℕ} (xs : List (Fin d → ℝ)) :
    (xs.map fun x => ∑ i : Fin d, (x i) ^ 2).sum =
      ∑ i : Fin d, (xs.map fun x => (x i) ^ 2).sum := by
  induction xs with
  | nil => simp
  | cons a xs ih =>
    simp [List.map_cons, List.sum_cons, ih, Finset.sum_add_distrib]

private theorem sum_map_coord_sub_sq {d : ℕ} (xs : List (Fin d → ℝ)) (μ : Fin d → ℝ) :
    (xs.map fun x => ∑ i : Fin d, (x i - μ i) ^ 2).sum =
      ∑ i : Fin d, (xs.map fun x => (x i - μ i) ^ 2).sum := by
  induction xs with
  | nil => simp
  | cons a xs ih =>
    simp [List.map_cons, List.sum_cons, ih, Finset.sum_add_distrib]

theorem leafEnergy_eq_mean_plus_centered {d : ℕ} (t : BinTree (Fin d → ℝ)) :
    leafEnergy t =
      (t.leafCount : ℝ) * energySq (leafMean t) + centeredLeafEnergy t := by
  have hpos : (t.leafCount : ℝ) ≠ 0 := by exact_mod_cast (ne_of_gt t.leafCount_pos)
  have hlen : t.leaves.length = t.leafCount := t.length_leaves
  have hμ (i : Fin d) :
      (t.leaves.map fun x => x i).sum =
        ((t.leaves.map fun x => x i).length : ℝ) * leafMean t i := by
    simp only [List.length_map, hlen, leafMean]
    rw [← leafSum_leaves t i]
    field_simp [hpos]
  unfold leafEnergy centeredLeafEnergy energySq
  have hswap := sum_map_coord_sq t.leaves
  have hswapC := sum_map_coord_sub_sq t.leaves (leafMean t)
  have h1' (i : Fin d) :
      (t.leaves.map fun x => (x i) ^ 2).sum =
        (t.leaves.length : ℝ) * (leafMean t i) ^ 2 +
          (t.leaves.map fun x => (x i - leafMean t i) ^ 2).sum := by
    have := real_list_variance (t.leaves.map fun x => x i) (leafMean t i) (hμ i)
    -- rewrite `map (f ∘ g)` forms into the pointwise maps
    simpa [List.map_map, Function.comp_def, List.length_map] using this
  have hlenR : (t.leaves.length : ℝ) = (t.leafCount : ℝ) := by exact_mod_cast hlen
  calc
    (t.leaves.map fun x => ∑ i, (x i) ^ 2).sum
        = ∑ i, (t.leaves.map fun x => (x i) ^ 2).sum := hswap
    _ = ∑ i, ((t.leaves.length : ℝ) * (leafMean t i) ^ 2
          + (t.leaves.map fun x => (x i - leafMean t i) ^ 2).sum) := by
          refine Finset.sum_congr rfl fun i _ => h1' i
    _ = ∑ i, (t.leafCount : ℝ) * (leafMean t i) ^ 2
        + ∑ i, (t.leaves.map fun x => (x i - leafMean t i) ^ 2).sum := by
          simp [hlenR, Finset.sum_add_distrib]
    _ = (t.leafCount : ℝ) * ∑ i, (leafMean t i) ^ 2
        + (t.leaves.map fun x => ∑ i, (x i - leafMean t i) ^ 2).sum := by
          rw [Finset.mul_sum, hswapC]

/-! ## Balanced scale normalization -/

theorem scalingCoeff_eq_leafSum_div_sqrt {d : ℕ}
    (t : BinTree (Fin d → ℝ)) (hb : t.IsBalanced) :
    ∀ i, scalingCoeff t i = leafSum t i / Real.sqrt (t.leafCount : ℝ) := by
  induction t with
  | leaf x =>
    intro i
    simp [scalingCoeff, analyze, leafSum, BinTree.leafCount]
  | node l r ihl ihr =>
    intro i
    rcases hb with ⟨hbL, hbR, hcnt⟩
    have hL := ihl hbL i
    have hR := ihr hbR i
    have hnL : (0 : ℝ) < l.leafCount := by exact_mod_cast l.leafCount_pos
    have hsqrtL : Real.sqrt (l.leafCount : ℝ) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hnL)
    have hcnt' : (r.leafCount : ℝ) = (l.leafCount : ℝ) := by exact_mod_cast hcnt.symm
    have hn2 : ((l.leafCount + r.leafCount : ℕ) : ℝ) = (2 : ℝ) * (l.leafCount : ℝ) := by
      push_cast
      rw [hcnt']
      ring
    have hsm : Real.sqrt ((l.leafCount + r.leafCount : ℕ) : ℝ) =
        Real.sqrt 2 * Real.sqrt (l.leafCount : ℝ) := by
      rw [hn2, Real.sqrt_mul (by norm_num)]
    -- unfold and rewrite child scales
    change
        haarScale (analyze l).1 (analyze r).1 i =
          (leafSum l i + leafSum r i) /
            Real.sqrt ((l.leafCount + r.leafCount : ℕ) : ℝ)
    have hLs : (analyze l).1 i = scalingCoeff l i := rfl
    have hRs : (analyze r).1 i = scalingCoeff r i := rfl
    rw [haarScale, hLs, hRs, hL, hR, hcnt', hsm]
    -- (a/√n + b/√n)/√2 = (a+b)/(√2 √n)
    field_simp [sqrt_two_ne_zero, hsqrtL]

theorem energySq_scaling_eq_count_mul_mean {d : ℕ}
    (t : BinTree (Fin d → ℝ)) (hb : t.IsBalanced) :
    energySq (scalingCoeff t) = (t.leafCount : ℝ) * energySq (leafMean t) := by
  have hpos : (0 : ℝ) < t.leafCount := by exact_mod_cast t.leafCount_pos
  have hN : (t.leafCount : ℝ) ≠ 0 := ne_of_gt hpos
  have hsc := scalingCoeff_eq_leafSum_div_sqrt t hb
  have hsq : (Real.sqrt (t.leafCount : ℝ)) ^ 2 = (t.leafCount : ℝ) :=
    Real.sq_sqrt (le_of_lt hpos)
  simp only [energySq, leafMean]
  simp_rw [hsc]
  have h1 :
      ∑ i, (leafSum t i / Real.sqrt (t.leafCount : ℝ)) ^ 2 =
        (∑ i, (leafSum t i) ^ 2) / (t.leafCount : ℝ) := by
    calc
      ∑ i, (leafSum t i / Real.sqrt (t.leafCount : ℝ)) ^ 2
          = ∑ i, (leafSum t i) ^ 2 / (Real.sqrt (t.leafCount : ℝ)) ^ 2 := by
            refine Finset.sum_congr rfl fun i _ => by ring
      _ = ∑ i, (leafSum t i) ^ 2 / (t.leafCount : ℝ) := by simp [hsq]
      _ = (∑ i, (leafSum t i) ^ 2) * (t.leafCount : ℝ)⁻¹ := by
            simp [div_eq_mul_inv, Finset.sum_mul]
  have h2 :
      ∑ i, (leafSum t i / (t.leafCount : ℝ)) ^ 2 =
        (∑ i, (leafSum t i) ^ 2) / (t.leafCount : ℝ) ^ 2 := by
    calc
      ∑ i, (leafSum t i / (t.leafCount : ℝ)) ^ 2
          = ∑ i, (leafSum t i) ^ 2 / (t.leafCount : ℝ) ^ 2 := by
            refine Finset.sum_congr rfl fun i _ => by ring
      _ = (∑ i, (leafSum t i) ^ 2) * ((t.leafCount : ℝ) ^ 2)⁻¹ := by
            simp [div_eq_mul_inv, Finset.sum_mul]
  rw [h1, h2]
  field_simp [hN]

/-- Master theorem for balanced trees. -/
theorem totalDetailEnergy_eq_centeredLeafEnergy {d : ℕ}
    (t : BinTree (Fin d → ℝ)) (hb : t.IsBalanced) :
    totalDetailEnergy t = centeredLeafEnergy t := by
  have hp := tree_parseval t
  have hs := energySq_scaling_eq_count_mul_mean t hb
  have hv := leafEnergy_eq_mean_plus_centered t
  linarith

theorem centeredLeafEnergy_leaves_congr {d : ℕ}
    (t₁ t₂ : BinTree (Fin d → ℝ)) (hleaves : t₁.leaves = t₂.leaves) :
    centeredLeafEnergy t₁ = centeredLeafEnergy t₂ := by
  have hlen : t₁.leafCount = t₂.leafCount := by
    rw [← t₁.length_leaves, ← t₂.length_leaves, hleaves]
  have hsum : leafSum t₁ = leafSum t₂ := by
    ext i
    simp [leafSum_leaves, hleaves]
  unfold centeredLeafEnergy leafMean
  simp [hleaves, hlen, hsum]

theorem totalDetailEnergy_eq_of_same_leaves {d : ℕ}
    (t₁ t₂ : BinTree (Fin d → ℝ))
    (hb₁ : t₁.IsBalanced) (hb₂ : t₂.IsBalanced)
    (hleaves : t₁.leaves = t₂.leaves) :
    totalDetailEnergy t₁ = totalDetailEnergy t₂ := by
  rw [totalDetailEnergy_eq_centeredLeafEnergy t₁ hb₁,
    totalDetailEnergy_eq_centeredLeafEnergy t₂ hb₂,
    centeredLeafEnergy_leaves_congr t₁ t₂ hleaves]

theorem detail_coeffs_may_depend_on_tree : True := trivial
theorem no_physical_energy_claim : True := trivial

end KeplerHurwitz.FiniteFactorTree
