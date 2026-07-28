/-
  Finite orthonormal Haar analysis on binary trees over `Fin d → ℝ`.

  Concrete analysis space \(V=\mathrm{Fin}\,d\to\mathbb R\) (stands in for an
  abstract real inner-product space):
    [B1] d = 1,  [B2] d = 2.

  Type chain (see `ClaimWall.lean`):
    ℕ → arithmetic leaf/state → V → scale/detail coefficients.

  Claim wall:
    [A] local perfect reconstruction and Parseval; tree Parseval
    [B] balanced-tree energy independence in `HaarTreeEnergy`
    [C] classical MRA on ℕ / rationality of coeffs / factorization algo — NOT claimed

  Does **not** modify `EABC.SemiprimeWavelet` ([A] triad kernel).
-/

import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic

namespace KeplerHurwitz.FiniteFactorTree

/-! ## Euclidean energy -/

noncomputable def energySq {d : ℕ} (v : Fin d → ℝ) : ℝ :=
  ∑ i : Fin d, (v i) ^ 2

theorem energySq_nonneg {d : ℕ} (v : Fin d → ℝ) : 0 ≤ energySq v :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem energySq_neg {d : ℕ} (v : Fin d → ℝ) : energySq (-v) = energySq v := by
  simp [energySq, Pi.neg_apply]

/-! ## Local Haar pair filter -/

theorem sq_sqrt_two : (Real.sqrt 2) ^ 2 = (2 : ℝ) :=
  Real.sq_sqrt (by norm_num)

theorem sqrt_two_ne_zero : Real.sqrt 2 ≠ 0 :=
  ne_of_gt (Real.sqrt_pos.mpr (by norm_num : (0 : ℝ) < 2))

noncomputable def haarScale {d : ℕ} (x y : Fin d → ℝ) : Fin d → ℝ :=
  fun i => (x i + y i) / Real.sqrt 2

noncomputable def haarDetail {d : ℕ} (x y : Fin d → ℝ) : Fin d → ℝ :=
  fun i => (x i - y i) / Real.sqrt 2

private theorem div_sqrt_two_sq (a : ℝ) :
    (a / Real.sqrt 2) ^ 2 = a ^ 2 / 2 := by
  rw [div_pow, sq_sqrt_two]

theorem reconstruct_left {d : ℕ} (x y : Fin d → ℝ) :
    (fun i => (haarScale x y i + haarDetail x y i) / Real.sqrt 2) = x := by
  ext i
  simp only [haarScale, haarDetail]
  have h := sq_sqrt_two
  field_simp [sqrt_two_ne_zero]
  rw [h]
  ring

theorem reconstruct_right {d : ℕ} (x y : Fin d → ℝ) :
    (fun i => (haarScale x y i - haarDetail x y i) / Real.sqrt 2) = y := by
  ext i
  simp only [haarScale, haarDetail]
  have h := sq_sqrt_two
  field_simp [sqrt_two_ne_zero]
  rw [h]
  ring

noncomputable def synthesizePair {d : ℕ} (s detail : Fin d → ℝ) :
    (Fin d → ℝ) × (Fin d → ℝ) :=
  ((fun i => (s i + detail i) / Real.sqrt 2),
    (fun i => (s i - detail i) / Real.sqrt 2))

theorem local_perfect_reconstruction {d : ℕ} (x y : Fin d → ℝ) :
    (synthesizePair (haarScale x y) (haarDetail x y)).1 = x ∧
      (synthesizePair (haarScale x y) (haarDetail x y)).2 = y :=
  ⟨reconstruct_left x y, reconstruct_right x y⟩

theorem local_parseval {d : ℕ} (x y : Fin d → ℝ) :
    energySq x + energySq y = energySq (haarScale x y) + energySq (haarDetail x y) := by
  unfold energySq haarScale haarDetail
  have hterm (i : Fin d) :
      (x i) ^ 2 + (y i) ^ 2 =
        ((x i + y i) / Real.sqrt 2) ^ 2 + ((x i - y i) / Real.sqrt 2) ^ 2 := by
    rw [div_sqrt_two_sq, div_sqrt_two_sq]
    ring
  calc
    ∑ i, (x i) ^ 2 + ∑ i, (y i) ^ 2
        = ∑ i, ((x i) ^ 2 + (y i) ^ 2) := by
          simp [Finset.sum_add_distrib]
    _ = ∑ i, (((x i + y i) / Real.sqrt 2) ^ 2 + ((x i - y i) / Real.sqrt 2) ^ 2) := by
          refine Finset.sum_congr rfl fun i _ => hterm i
    _ = ∑ i, ((x i + y i) / Real.sqrt 2) ^ 2
        + ∑ i, ((x i - y i) / Real.sqrt 2) ^ 2 := by
          simp [Finset.sum_add_distrib]

theorem haarDetail_swap {d : ℕ} (x y : Fin d → ℝ) :
    haarDetail y x = -haarDetail x y := by
  ext i
  simp [haarDetail]
  ring

theorem haarScale_swap {d : ℕ} (x y : Fin d → ℝ) :
    haarScale y x = haarScale x y := by
  ext i
  simp [haarScale]
  ring

theorem energySq_haarDetail_swap {d : ℕ} (x y : Fin d → ℝ) :
    energySq (haarDetail y x) = energySq (haarDetail x y) := by
  rw [haarDetail_swap, energySq_neg]

/-! ## Binary trees -/

inductive BinTree (α : Type*) where
  | leaf : α → BinTree α
  | node : BinTree α → BinTree α → BinTree α

def BinTree.leafCount {α : Type*} : BinTree α → ℕ
  | leaf _ => 1
  | node l r => l.leafCount + r.leafCount

theorem BinTree.leafCount_pos {α : Type*} (t : BinTree α) : 0 < t.leafCount := by
  induction t with
  | leaf _ => simp [BinTree.leafCount]
  | node l r ihl ihr =>
    simp [BinTree.leafCount]
    omega

def BinTree.leaves {α : Type*} : BinTree α → List α
  | leaf x => [x]
  | node l r => l.leaves ++ r.leaves

theorem BinTree.length_leaves {α : Type*} (t : BinTree α) :
    t.leaves.length = t.leafCount := by
  induction t with
  | leaf _ => rfl
  | node l r ihl ihr =>
    simp [BinTree.leaves, BinTree.leafCount, ihl, ihr]

/-- Balanced: every internal node has equal leaf counts on both children. -/
def BinTree.IsBalanced {α : Type*} : BinTree α → Prop
  | leaf _ => True
  | node l r => l.IsBalanced ∧ r.IsBalanced ∧ l.leafCount = r.leafCount

noncomputable def analyze {d : ℕ} :
    BinTree (Fin d → ℝ) → (Fin d → ℝ) × List (Fin d → ℝ)
  | .leaf x => (x, [])
  | .node l r =>
    let pL := analyze l
    let pR := analyze r
    (haarScale pL.1 pR.1, haarDetail pL.1 pR.1 :: (pL.2 ++ pR.2))

noncomputable def scalingCoeff {d : ℕ} (t : BinTree (Fin d → ℝ)) : Fin d → ℝ :=
  (analyze t).1

noncomputable def detailCoeffs {d : ℕ} (t : BinTree (Fin d → ℝ)) : List (Fin d → ℝ) :=
  (analyze t).2

noncomputable def leafEnergy {d : ℕ} (t : BinTree (Fin d → ℝ)) : ℝ :=
  (t.leaves.map energySq).sum

noncomputable def totalDetailEnergy {d : ℕ} (t : BinTree (Fin d → ℝ)) : ℝ :=
  (detailCoeffs t).map energySq |>.sum

theorem tree_parseval {d : ℕ} (t : BinTree (Fin d → ℝ)) :
    leafEnergy t = energySq (scalingCoeff t) + totalDetailEnergy t := by
  induction t with
  | leaf x =>
    simp [leafEnergy, BinTree.leaves, scalingCoeff, detailCoeffs, analyze, totalDetailEnergy]
  | node l r ihl ihr =>
    simp only [leafEnergy, BinTree.leaves, List.map_append, List.sum_append,
      scalingCoeff, detailCoeffs, analyze, totalDetailEnergy] at ihl ihr ⊢
    have hloc := local_parseval (analyze l).1 (analyze r).1
    simp [List.map_cons, List.sum_cons] at *
    linarith

theorem no_classical_mra_claim : True := trivial

end KeplerHurwitz.FiniteFactorTree
