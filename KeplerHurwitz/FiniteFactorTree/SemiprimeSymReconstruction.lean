/-
  Konsument (3b): Semiprime reconstruction on Sym²(ℕ) via weight-space Haar state.

  Satzkandidat 17 (coded form):
    S ∘ A = id on Sym²(ℕ)
  whenever weights `w : ℕ → ℝ` admit a left inverse on their image.

  Critical claim wall:
    reconstruction of a *coded* unordered pair ≠ factorization of bare `n : ℕ`
    `ArithmeticFactorization := False` (consumed from ClaimWall)

  Channel-level Sym²({A,B,C}) lives in `EABC.SemiprimeReconstruction` (3a).
  This module is the weight / [B1]-style lift.
-/

import Mathlib.Data.Sym.Sym2
import Mathlib.Tactic
import KeplerHurwitz.FiniteFactorTree.ClaimWall
import KeplerHurwitz.FiniteFactorTree.HaarTreeCore
import KeplerHurwitz.EABC.SemiprimeReconstruction

namespace KeplerHurwitz.FiniteFactorTree
namespace SemiprimeSymReconstruction

open ClaimWall

/-! ## Freeze / schema -/

theorem consumes_freeze_status : ClaimWall.Status := ClaimWall.status

theorem does_not_claim_factorization : ¬ ArithmeticFactorization :=
  fun h => nomatch h

/-- Re-export channel-layer non-factorization (3a). -/
theorem channel_layer_no_factorization : ¬ ArithmeticFactorization :=
  EABC.SemiprimeReconstruction.does_not_claim_factorization

def exportSchemaId : String :=
  "semiprime_sym_reconstruction.v1"

abbrev UnorderedNatPair := Sym2 ℕ

/-! ## Haar state on Sym² (scale + absolute detail) -/

/-- Symmetry-invariant leaf state for an unordered weight pair (d = 1).
Proof obligations about nonnegativity live outside the structure. -/
structure SymHaarState where
  scale : ℝ
  absDetail : ℝ

def SymHaarState.IsWellFormed (st : SymHaarState) : Prop :=
  0 ≤ st.absDetail

/-- Encode ordered weights to SymHaarState (swap-invariant). -/
noncomputable def encodeWeights (a b : ℝ) : SymHaarState where
  scale := (a + b) / Real.sqrt 2
  absDetail := |(a - b) / Real.sqrt 2|

theorem encodeWeights_wellFormed (a b : ℝ) :
    (encodeWeights a b).IsWellFormed :=
  abs_nonneg _

theorem encodeWeights_swap (a b : ℝ) :
    encodeWeights a b = encodeWeights b a := by
  simp only [encodeWeights, add_comm a b]
  congr 1
  -- |(a-b)/√2| = |(b-a)/√2|
  have h : a - b = -(b - a) := by ring
  rw [h, neg_div, abs_neg]

/-- Decode SymHaarState to unordered weight pair. -/
noncomputable def decodeWeights (st : SymHaarState) : Sym2 ℝ :=
  s((st.scale + st.absDetail) / Real.sqrt 2,
    (st.scale - st.absDetail) / Real.sqrt 2)

private theorem decode_encode_weights (a b : ℝ) :
    decodeWeights (encodeWeights a b) = s(a, b) := by
  have hsqrt : Real.sqrt 2 ≠ 0 := sqrt_two_ne_zero
  have hsq : (Real.sqrt 2) ^ 2 = (2 : ℝ) := sq_sqrt_two
  by_cases h : b ≤ a
  · have hd :
        |(a - b) / Real.sqrt 2| = (a - b) / Real.sqrt 2 := by
      refine abs_of_nonneg (div_nonneg ?_ ?_)
      · exact sub_nonneg.mpr h
      · exact le_of_lt (Real.sqrt_pos.mpr (by norm_num))
    have ha : ((a + b) / Real.sqrt 2 + (a - b) / Real.sqrt 2) / Real.sqrt 2 = a := by
      field_simp [hsqrt]
      rw [hsq]
      ring
    have hb : ((a + b) / Real.sqrt 2 - (a - b) / Real.sqrt 2) / Real.sqrt 2 = b := by
      field_simp [hsqrt]
      rw [hsq]
      ring
    simp [decodeWeights, encodeWeights, hd, ha, hb]
  · have h' : a ≤ b := le_of_not_ge h
    have hd :
        |(a - b) / Real.sqrt 2| = (b - a) / Real.sqrt 2 := by
      have hpos : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
      calc
        |(a - b) / Real.sqrt 2|
            = |a - b| / Real.sqrt 2 := by
              rw [abs_div, abs_of_pos hpos]
        _ = |b - a| / Real.sqrt 2 := by rw [abs_sub_comm]
        _ = (b - a) / Real.sqrt 2 := by
              rw [abs_of_nonneg (sub_nonneg.mpr h')]
    have hb : ((a + b) / Real.sqrt 2 + (b - a) / Real.sqrt 2) / Real.sqrt 2 = b := by
      field_simp [hsqrt]
      rw [hsq]
      ring
    have ha : ((a + b) / Real.sqrt 2 - (b - a) / Real.sqrt 2) / Real.sqrt 2 = a := by
      field_simp [hsqrt]
      rw [hsq]
      ring
    -- decode yields s(b,a) = s(a,b)
    simp [decodeWeights, encodeWeights, hd, ha, hb, Sym2.eq_swap]

/-- Encode unordered weight pair via Sym2.lift. -/
noncomputable def encodeWeightPair : Sym2 ℝ → SymHaarState :=
  Sym2.lift ⟨encodeWeights, encodeWeights_swap⟩

theorem encodeWeightPair_mk (a b : ℝ) :
    encodeWeightPair s(a, b) = encodeWeights a b :=
  rfl

theorem decode_encode_weightPair (pair : Sym2 ℝ) :
    decodeWeights (encodeWeightPair pair) = pair := by
  refine Sym2.inductionOn pair fun a b => ?_
  simpa [encodeWeightPair_mk] using decode_encode_weights a b

/-! ## Lift to Sym²(ℕ) via coded weights with left inverse -/

/-- Analyze: unordered naturals → SymHaarState via weight map `w`. -/
noncomputable def analyze (w : ℕ → ℝ) : UnorderedNatPair → SymHaarState :=
  fun pair => encodeWeightPair (Sym2.map w pair)

/-- Synthesize: SymHaarState → unordered naturals via left inverse on weight image. -/
noncomputable def synthesize (w_inv : ℝ → ℕ) (st : SymHaarState) : UnorderedNatPair :=
  Sym2.map w_inv (decodeWeights st)

/--
Satzkandidat 17: `synthesize ∘ analyze = id` on Sym²(ℕ)
for any weight coding that is left-invertible on its image.

This is **not** a factorization algorithm for bare `n`.
-/
theorem reconstruction_sym2_identity
    (w : ℕ → ℝ) (w_inv : ℝ → ℕ)
    (h_inv : ∀ p : ℕ, w_inv (w p) = p)
    (pair : UnorderedNatPair) :
    synthesize w_inv (analyze w pair) = pair := by
  refine Sym2.inductionOn pair fun p q => ?_
  have henc : analyze w s(p, q) = encodeWeights (w p) (w q) := by
    simp [analyze, encodeWeightPair_mk, Sym2.map_mk]
  have hdec : decodeWeights (analyze w s(p, q)) = s(w p, w q) := by
    rw [henc, decode_encode_weights]
  simp [synthesize, hdec, Sym2.map_mk, h_inv]

theorem analyze_swap_invariant (w : ℕ → ℝ) (p q : ℕ) :
    analyze w s(p, q) = analyze w s(q, p) := by
  simp [analyze, Sym2.eq_swap]

/-! ## Detail energy is a Sym² function -/

noncomputable def detailEnergyState (st : SymHaarState) : ℝ :=
  st.absDetail ^ 2

theorem detailEnergy_encode_swap (a b : ℝ) :
    detailEnergyState (encodeWeights a b) =
      detailEnergyState (encodeWeights b a) := by
  simp [detailEnergyState, encodeWeights_swap]

/-! ## Audit markers -/

structure SymReconstructionAudit where
  pair : UnorderedNatPair
  state : SymHaarState
  recovered : UnorderedNatPair
  exact : recovered = pair
  freezeAnchor : String := "ClaimWall.status"

noncomputable def runSymAudit
    (w : ℕ → ℝ) (w_inv : ℝ → ℕ)
    (h_inv : ∀ p, w_inv (w p) = p)
    (pair : UnorderedNatPair) : SymReconstructionAudit where
  pair := pair
  state := analyze w pair
  recovered := synthesize w_inv (analyze w pair)
  exact := reconstruction_sym2_identity w w_inv h_inv pair

/-! ## Non-claims -/

theorem reconstruction_is_not_factorization : True := trivial
theorem reconstruction_no_complexity_claim : True := trivial
theorem reconstruction_requires_coded_weights : True := trivial
theorem reconstruction_does_not_modify_freeze : True := trivial

end SemiprimeSymReconstruction
end KeplerHurwitz.FiniteFactorTree
