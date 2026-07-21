/-
  Arithmetic relation classifier Φ_k (§5.22 bridge).

  [A] Φ_k labels; stated/refined classifiers; E01/E00 matrix packaging;
      reuse of unit-defect BoolTrace from BooleanRelationAbsorption.
  [B] Python audit: refined Φ matches F_k lift matrices; focus words;
      lift ν₂-invariance / T-identity checked numerically (full padic
      formalization of wrap-free miss left as follow-up).
  [C] no Collatz; naive stated Φ (v=1⇒E01 on G_k^cut) fails [B];
      §5.21 Drift open.

  Docs: docs/eabc_collatz_audit_grid.md §5.22
-/

import Mathlib
import KeplerHurwitz.EABC.BooleanRelationAbsorption

namespace KeplerHurwitz.EABC
namespace SyracuseRelationClassifierPhi

open BooleanRelationAbsorption

/-! ## Labels and classifiers -/

inductive PhiLabel where
  | E01
  | E00
  | Z
  deriving DecidableEq, Repr

/-- Valuation-only sketch Φ_k^stated (research proposal). -/
def phiKStated (k v : ℕ) : PhiLabel :=
  if v = 1 then
    .E01
  else if decide (2 ≤ v) && decide (v < k) then
    .E00
  else
    .Z

/-- Wrap-aware refined classifier (Python `phi_k_refined`). -/
def phiKRefined (k v : ℕ) (wraps : Bool) : PhiLabel :=
  if decide (k ≤ v) then
    .Z
  else if wraps && decide (v = 1) then
    .E01
  else if !wraps && decide (1 ≤ v) && decide (v < k) then
    .E00
  else
    .Z

theorem phiKStated_one (k : ℕ) : phiKStated k 1 = .E01 := by
  simp [phiKStated]

theorem phiKStated_ge_two_lt (k v : ℕ) (h2 : 2 ≤ v) (hlt : v < k) :
    phiKStated k v = .E00 := by
  have hne : v ≠ 1 := by omega
  simp [phiKStated, hne, h2, hlt]

theorem phiKStated_loss (k v : ℕ) (hle : k ≤ v) (hne1 : v ≠ 1) :
    phiKStated k v = .Z := by
  unfold phiKStated
  have hvlt : ¬ v < k := not_lt.2 hle
  simp [hne1, hvlt]

theorem phiKRefined_wrap_one (k : ℕ) (_hk : 1 < k) :
    phiKRefined k 1 true = .E01 := by
  have : ¬k ≤ 1 := by omega
  simp [phiKRefined, this]

theorem phiKRefined_cut_regular (k v : ℕ) (h1 : 1 ≤ v) (hlt : v < k) :
    phiKRefined k v false = .E00 := by
  have : ¬k ≤ v := by omega
  simp [phiKRefined, this, h1, hlt]

/-! ## Matrix packaging (alphabet shapes) -/

def labelMatrix : PhiLabel → BoolMat2
  | .E01 => BoolMat2.E01
  | .E00 => BoolMat2.E00
  | .Z => BoolMat2.zeroRel

theorem labelMatrix_E01 : labelMatrix .E01 = BoolMat2.E01 := rfl
theorem labelMatrix_E00 : labelMatrix .E00 = BoolMat2.E00 := rfl
theorem labelMatrix_Z : labelMatrix .Z = BoolMat2.zeroRel := rfl

/--
Stated classifier: ν₂ = 1 maps to the E01 matrix shape.
(Graph match of this label on wrap-free cut edges fails [B]; wrap edges match.)
-/
theorem stated_v1_E01_shape (k : ℕ) :
    phiKStated k 1 = .E01 ∧ labelMatrix .E01 = BoolMat2.E01 :=
  ⟨phiKStated_one k, labelMatrix_E01⟩

/-- Stated classifier: 2 ≤ ν₂ < k maps to the E00 matrix shape. -/
theorem stated_v_ge2_E00_shape {k v : ℕ} (h2 : 2 ≤ v) (hlt : v < k) :
    phiKStated k v = .E00 ∧ labelMatrix .E00 = BoolMat2.E00 :=
  ⟨phiKStated_ge_two_lt k v h2 hlt, labelMatrix_E00⟩

/--
Refined wrap-free classifier: 1 ≤ ν₂ < k maps to E00
(matches all audited G_k^cut edges [B]).
-/
theorem refined_cut_E00_shape {k v : ℕ} (h1 : 1 ≤ v) (hlt : v < k) :
    phiKRefined k v false = .E00 ∧ labelMatrix .E00 = BoolMat2.E00 :=
  ⟨phiKRefined_cut_regular k v h1 hlt, labelMatrix_E00⟩

/-- Refined wrap ∧ ν₂=1 maps to E01 (matches audited wrap edges [B]). -/
theorem refined_wrap_E01_shape (k : ℕ) (hk : 1 < k) :
    phiKRefined k 1 true = .E01 ∧ labelMatrix .E01 = BoolMat2.E01 :=
  ⟨phiKRefined_wrap_one k hk, labelMatrix_E01⟩

/-! ## ν₂ / T definitions (for documentation + follow-up padic lemmas) -/

/-- ν₂(3u+1). -/
def nu2_3u1 (u : ℕ) : ℕ := padicValNat 2 (3 * u + 1)

/-- Accelerated odd Syracuse image T(u) = (3u+1)/2^{ν₂(3u+1)}. -/
def oddSyracuseT (u : ℕ) : ℕ := (3 * u + 1) / 2 ^ nu2_3u1 u

theorem three_mul_add_one_ne_zero (u : ℕ) : 3 * u + 1 ≠ 0 := by omega

theorem oddSyracuseT_mul_pow (u : ℕ) :
    oddSyracuseT u * 2 ^ nu2_3u1 u = 3 * u + 1 := by
  have hne := three_mul_add_one_ne_zero u
  have hdiv : 2 ^ nu2_3u1 u ∣ 3 * u + 1 :=
    (padicValNat_dvd_iff_le (p := 2) (a := 3 * u + 1) hne).2 le_rfl
  simpa [oddSyracuseT, nu2_3u1] using Nat.div_mul_cancel hdiv

/-- Concrete smoke: ν₂(3·1+1)=ν₂(4)=2. -/
theorem nu2_3u1_one : nu2_3u1 1 = 2 := by
  native_decide

/-- Concrete smoke: ν₂(3·3+1)=ν₂(10)=1. -/
theorem nu2_3u1_three : nu2_3u1 3 = 1 := by
  native_decide

/-- Concrete smoke: T(1)=1. -/
theorem oddSyracuseT_one : oddSyracuseT 1 = 1 := by
  native_decide

/-- Concrete lift identity at (u,k)=(1,4): T(1+16)=T(1)+3·2^{4-2}. -/
theorem lift_T_add_example_u1_k4 :
    oddSyracuseT (1 + 2 ^ 4) = oddSyracuseT 1 + 3 * 2 ^ (4 - nu2_3u1 1) := by
  native_decide

/-- Concrete lift ν₂-invariance at (u,k)=(3,5). -/
theorem lift_nu2_example_u3_k5 :
    nu2_3u1 (3 + 2 ^ 5) = nu2_3u1 3 := by
  native_decide

/-! ## Absorption bridge (reuse §5.19/§5.20, do not duplicate) -/

/--
If a cycle word matches the unit-defect pattern, BoolTrace vanishes.
Reuse of `unitDefect_boolTrace_false` — no new absorption algebra here.
-/
theorem unitDefect_word_boolTrace_false {ℓ : ℕ} (j : Fin ℓ) :
    (listProduct (unitDefectList ℓ j)).trace = false :=
  unitDefect_boolTrace_false j

/-- E01 ⊙ E00 = Z — local absorption kernel (already in §5.19). -/
theorem E01_E00_absorbs_bridge : BoolMat2.E01.mul BoolMat2.E00 = BoolMat2.zeroRel :=
  BoolMat2.E01_mul_E00

end SyracuseRelationClassifierPhi
end KeplerHurwitz.EABC
