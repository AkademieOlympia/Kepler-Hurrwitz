/-
  [B2] Finite EABC residue tree — Haar instance on character vectors in `Fin 2 → ℝ`.

  Uses the certified isomorphism \(V_4\cong C_2\times C_2\) from `EABC.V4`.
  Characters land in `{\pm1}^2 ⊂ ℝ²`.

  Claim wall:
    [B2] residue Haar filterbank; discrete detail energies in {0,2,4}; tree energy ID
    [A] V₄ algebra / exponent-2 facts from `EABC.V4`
    No-go: product vs quotient channels coincide on \(U_{12}\)
    [C] physical residue “wavelet” — NOT claimed
-/

import Mathlib.Tactic
import KeplerHurwitz.EABC.V4
import KeplerHurwitz.FiniteFactorTree.HaarTreeEnergy

namespace KeplerHurwitz.FiniteFactorTree
namespace EabcResidue

open KeplerHurwitz.EABC

/-! ## Character embedding \(\chi:V_4\to\{\pm1\}^2\) -/

def bitChar : Bool → ℝ
  | false => 1
  | true => -1

theorem bitChar_mul (x y : Bool) :
    bitChar (xor x y) = bitChar x * bitChar y := by
  cases x <;> cases y <;> simp [bitChar]

def residueSignal (x : V4) : Fin 2 → ℝ
  | ⟨0, _⟩ => bitChar x.toF2.1
  | ⟨1, _⟩ => bitChar x.toF2.2

theorem residueSignal_normSq (x : V4) : energySq (residueSignal x) = 2 := by
  cases x <;> simp [energySq, residueSignal, bitChar, V4.toF2] <;> norm_num

private theorem bitChar_inj {x y : Bool} (h : bitChar x = bitChar y) : x = y := by
  cases x <;> cases y <;> try rfl
  · exact absurd h (by simp [bitChar]; norm_num)
  · exact absurd h (by simp [bitChar]; norm_num)

theorem residueSignal_inj : Function.Injective residueSignal := by
  intro x y hxy
  have h0 : x.toF2.1 = y.toF2.1 :=
    bitChar_inj (by simpa [residueSignal] using congrFun hxy (0 : Fin 2))
  have h1 : x.toF2.2 = y.toF2.2 :=
    bitChar_inj (by simpa [residueSignal] using congrFun hxy (1 : Fin 2))
  have ht : x.toF2 = y.toF2 := Prod.ext h0 h1
  calc
    x = V4.ofF2 x.toF2 := (V4.ofF2_toF2 x).symm
    _ = V4.ofF2 y.toF2 := by rw [ht]
    _ = y := V4.ofF2_toF2 y

/-! ## No-go: product = quotient on exponent-2 group -/

/-- No-go Lemma B2.1: on \(V_4\) (exponent 2), \(r_L r_R^{-1}=r_L r_R\). -/
theorem product_eq_relative_quotient (rL rR : V4) :
    rL * rR⁻¹ = rL * rR := by
  simp [V4.inv_eq]

theorem low_eq_naive_detail (rL rR : V4) :
    rL * rR = rL * rR⁻¹ :=
  (product_eq_relative_quotient rL rR).symm

theorem no_go_product_quotient_not_independent : True := trivial

/-! ## Character-space Haar filterbank -/

noncomputable def residueScale (rL rR : V4) : Fin 2 → ℝ :=
  haarScale (residueSignal rL) (residueSignal rR)

noncomputable def residueDetail (rL rR : V4) : Fin 2 → ℝ :=
  haarDetail (residueSignal rL) (residueSignal rR)

noncomputable def residueDetailEnergy (rL rR : V4) : ℝ :=
  energySq (residueDetail rL rR)

theorem residue_perfect_reconstruction (rL rR : V4) :
    (synthesizePair (residueScale rL rR) (residueDetail rL rR)).1 = residueSignal rL ∧
      (synthesizePair (residueScale rL rR) (residueDetail rL rR)).2 = residueSignal rR :=
  local_perfect_reconstruction _ _

theorem residue_local_parseval (rL rR : V4) :
    energySq (residueSignal rL) + energySq (residueSignal rR) =
      energySq (residueScale rL rR) + residueDetailEnergy rL rR := by
  simpa [residueScale, residueDetail, residueDetailEnergy] using
    local_parseval (residueSignal rL) (residueSignal rR)

theorem residue_detail_swap (rL rR : V4) :
    residueDetail rR rL = -residueDetail rL rR :=
  haarDetail_swap _ _

theorem residue_detailEnergy_swap (rL rR : V4) :
    residueDetailEnergy rR rL = residueDetailEnergy rL rR := by
  unfold residueDetailEnergy
  rw [residue_detail_swap, energySq_neg]

theorem residueDetailEnergy_eq_half_diff_sq (rL rR : V4) :
    residueDetailEnergy rL rR =
      (1 / 2) * energySq (residueSignal rL - residueSignal rR) := by
  unfold residueDetailEnergy residueDetail haarDetail energySq
  simp only [Pi.sub_apply, Fin.sum_univ_two]
  have h2 := sq_sqrt_two
  simp only [div_pow, h2]
  ring

theorem residue_detailEnergy_eq_zero_iff (rL rR : V4) :
    residueDetailEnergy rL rR = 0 ↔ rL = rR := by
  constructor
  · intro h
    have hE : energySq (residueSignal rL - residueSignal rR) = 0 := by
      have hx := residueDetailEnergy_eq_half_diff_sq rL rR
      nlinarith [energySq_nonneg (residueSignal rL - residueSignal rR), hx.symm ▸ h]
    have hsum : ∑ i, (residueSignal rL i - residueSignal rR i) ^ 2 = 0 := by
      simpa [energySq, Pi.sub_apply] using hE
    have hsig : residueSignal rL = residueSignal rR := by
      ext i
      have hi :=
        (Finset.sum_eq_zero_iff_of_nonneg
          (fun _ _ => sq_nonneg (residueSignal rL _ - residueSignal rR _))).1 hsum
          i (Finset.mem_univ i)
      exact sub_eq_zero.mp (sq_eq_zero_iff.mp hi)
    exact residueSignal_inj hsig
  · intro h
    subst h
    simp [residueDetailEnergy, residueDetail, haarDetail, energySq]

private theorem char_diff_sq (x y : Bool) :
    (bitChar x - bitChar y) ^ 2 = if x = y then (0 : ℝ) else 4 := by
  cases x <;> cases y <;> simp [bitChar] <;> norm_num

theorem residue_detailEnergy_values (rL rR : V4) :
    residueDetailEnergy rL rR = 0 ∨
      residueDetailEnergy rL rR = 2 ∨
      residueDetailEnergy rL rR = 4 := by
  have h := residueDetailEnergy_eq_half_diff_sq rL rR
  have hbits :
      energySq (residueSignal rL - residueSignal rR) =
        (bitChar rL.toF2.1 - bitChar rR.toF2.1) ^ 2 +
          (bitChar rL.toF2.2 - bitChar rR.toF2.2) ^ 2 := by
    simp [energySq, residueSignal, Pi.sub_apply, Fin.sum_univ_two]
  rw [h, hbits, char_diff_sq, char_diff_sq]
  -- four bit-comparison cases via decidable equality
  cases Decidable.em (rL.toF2.1 = rR.toF2.1) with
  | inl h1 =>
    cases Decidable.em (rL.toF2.2 = rR.toF2.2) with
    | inl h2 => simp [h1, h2]
    | inr h2 => simp [h1, h2]; norm_num
  | inr h1 =>
    cases Decidable.em (rL.toF2.2 = rR.toF2.2) with
    | inl h2 => simp [h1, h2]; norm_num
    | inr h2 => simp [h1, h2]; norm_num

/-! ### Balanced residue trees -/

def mapResidue : BinTree V4 → BinTree (Fin 2 → ℝ)
  | .leaf x => .leaf (residueSignal x)
  | .node l r => .node (mapResidue l) (mapResidue r)

theorem mapResidue_leafCount (t : BinTree V4) :
    (mapResidue t).leafCount = t.leafCount := by
  induction t with
  | leaf _ => rfl
  | node l r ihl ihr => simp [mapResidue, BinTree.leafCount, ihl, ihr]

theorem mapResidue_leaves (t : BinTree V4) :
    (mapResidue t).leaves = t.leaves.map residueSignal := by
  induction t with
  | leaf _ => rfl
  | node l r ihl ihr => simp [mapResidue, BinTree.leaves, ihl, ihr]

theorem mapResidue_balanced (t : BinTree V4) (hb : t.IsBalanced) :
    (mapResidue t).IsBalanced := by
  induction t with
  | leaf _ => trivial
  | node l r ihl ihr =>
    rcases hb with ⟨hbL, hbR, hcnt⟩
    exact ⟨ihl hbL, ihr hbR, by simp [mapResidue_leafCount, hcnt]⟩

theorem residue_tree_totalEnergy (t : BinTree V4) (hb : t.IsBalanced) :
    totalDetailEnergy (mapResidue t) = centeredLeafEnergy (mapResidue t) :=
  totalDetailEnergy_eq_centeredLeafEnergy _ (mapResidue_balanced t hb)

theorem residue_tree_totalEnergy_independent (t₁ t₂ : BinTree V4)
    (hb₁ : t₁.IsBalanced) (hb₂ : t₂.IsBalanced)
    (hleaves : t₁.leaves = t₂.leaves) :
    totalDetailEnergy (mapResidue t₁) = totalDetailEnergy (mapResidue t₂) := by
  apply totalDetailEnergy_eq_of_same_leaves
  · exact mapResidue_balanced t₁ hb₁
  · exact mapResidue_balanced t₂ hb₂
  · simp [mapResidue_leaves, hleaves]

theorem four_leaf_energy_eight (x1 x2 x3 x4 : V4) :
    leafEnergy
      (BinTree.node
        (BinTree.node (.leaf (residueSignal x1)) (.leaf (residueSignal x2)))
        (BinTree.node (.leaf (residueSignal x3)) (.leaf (residueSignal x4)))) = 8 := by
  simp [leafEnergy, BinTree.leaves, residueSignal_normSq]
  norm_num

theorem no_physical_residue_wavelet_claim : True := trivial

end EabcResidue
end KeplerHurwitz.FiniteFactorTree
