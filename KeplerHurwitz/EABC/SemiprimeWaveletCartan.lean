/-
  Cartan / A₂ bridge for the semiprimal three-channel filterbank.

  Claim wall:
    [A] traceless diagonal embedding; Frobenius / C₂ / I₂ identification with detailEnergy;
        TwinRay sign rules for C₂ (even) and I₃ (odd); C₃ intertwining on the Cartan picture
    [C] physical Cartan–Killing / Lie-algebra dynamics beyond the quadratic-form ID — NOT claimed
-/

import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Tactic
import KeplerHurwitz.EABC.SemiprimeWaveletEnergy
import KeplerHurwitz.EABC.SemiprimeWaveletIntertwining

namespace KeplerHurwitz.EABC
namespace SemiprimeWavelet

/-! ## Traceless diagonal Cartan embedding -/

/-- Spur-free diagonal Cartan image \(D_E^\circ(q)=\mathrm{diag}(P_{\mathrm{aniso}}q)\). -/
noncomputable def cartanDiag (q : Fin 3 → ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  Matrix.diagonal (P_aniso q)

/-- Frobenius squared norm \(\|M\|_F^2=\sum_{i,j}M_{ij}^2\). -/
noncomputable def frobeniusSq (M : Matrix (Fin 3) (Fin 3) ℝ) : ℝ :=
  ∑ i : Fin 3, ∑ j : Fin 3, (M i j) ^ 2

/-- Cartan quadratic \(C_2\) on the diagonal embedding (equals Frobenius energy). -/
noncomputable def C2 (q : Fin 3 → ℝ) : ℝ :=
  frobeniusSq (cartanDiag q)

/-- Quadratic Cartan invariant \(I_2=-\tfrac12 C_2\) (so \(C_2=-2I_2\)). -/
noncomputable def I2 (q : Fin 3 → ℝ) : ℝ :=
  -(1 / 2) * C2 q

/-- Cubic diagonal invariant \(I_3=\prod_i (P_{\mathrm{aniso}}q)_i\) (odd under sign flip). -/
noncomputable def I3 (q : Fin 3 → ℝ) : ℝ :=
  P_aniso q 0 * P_aniso q 1 * P_aniso q 2

theorem cartanDiag_trace_zero (q : Fin 3 → ℝ) :
    (cartanDiag q).trace = 0 := by
  simp [cartanDiag, Matrix.trace_diagonal, sum_P_aniso_eq_zero]

theorem frobeniusSq_cartanDiag (q : Fin 3 → ℝ) :
    frobeniusSq (cartanDiag q) = detailEnergy q := by
  unfold frobeniusSq cartanDiag detailEnergy energySq
  calc
    ∑ i : Fin 3, ∑ j : Fin 3, (Matrix.diagonal (P_aniso q) i j) ^ 2
        = ∑ i : Fin 3, ∑ j : Fin 3, (if i = j then P_aniso q i else 0) ^ 2 := by
          refine Finset.sum_congr rfl fun i _ =>
            Finset.sum_congr rfl fun j _ => by
              simp [Matrix.diagonal_apply]
    _ = ∑ i : Fin 3, (P_aniso q i) ^ 2 := by
          refine Finset.sum_congr rfl fun i _ => ?_
          rw [Finset.sum_eq_single i]
          · simp
          · intro j _ hj
            simp [Ne.symm hj]
          · intro hi
            exact (hi (Finset.mem_univ i)).elim

/-- Detail energy = Frobenius energy of the Cartan diagonal. -/
theorem detailEnergy_eq_frobenius_sq (q : Fin 3 → ℝ) :
    detailEnergy q = frobeniusSq (cartanDiag q) :=
  (frobeniusSq_cartanDiag q).symm

/-- Detail energy = Cartan \(C_2\). -/
theorem detailEnergy_eq_C2 (q : Fin 3 → ℝ) :
    detailEnergy q = C2 q := by
  simp [C2, detailEnergy_eq_frobenius_sq]

theorem surgeryEnergy_eq_C2 (q : Fin 3 → ℝ) :
    surgeryEnergy q = C2 q := by
  rw [surgeryEnergy_eq_detailEnergy, detailEnergy_eq_C2]

theorem C2_eq_neg_two_I2 (q : Fin 3 → ℝ) :
    C2 q = -2 * I2 q := by
  unfold I2
  ring

/-- Master quadratic-form identification chain. -/
theorem wavelet_cartan_energy_chain (q : Fin 3 → ℝ) :
    detailEnergy q = surgeryEnergy q ∧
      surgeryEnergy q = frobeniusSq (cartanDiag q) ∧
      frobeniusSq (cartanDiag q) = C2 q ∧
      C2 q = -2 * I2 q := by
  refine ⟨detailEnergy_eq_surgeryEnergy q, ?_, rfl, C2_eq_neg_two_I2 q⟩
  rw [surgeryEnergy_eq_detailEnergy, detailEnergy_eq_frobenius_sq]

/-! ### TwinRay sign rules -/

theorem P_aniso_neg (q : Fin 3 → ℝ) :
    P_aniso (-q) = -P_aniso q := by
  ext i
  simp [P_aniso_apply, mean, Fin.sum_univ_three]
  ring

theorem twinRay_detail_neg (qAB : Fin 3 → ℝ) :
    P_aniso (-qAB) = -P_aniso qAB :=
  P_aniso_neg qAB

theorem twinRay_detailEnergy_eq (qAB : Fin 3 → ℝ) :
    detailEnergy (-qAB) = detailEnergy qAB :=
  detailEnergy_neg qAB

theorem twinRay_C2_eq (qAB : Fin 3 → ℝ) :
    C2 (-qAB) = C2 qAB := by
  simp [← detailEnergy_eq_C2, detailEnergy_neg]

/-- Lemma 11: cubic invariant flips under TwinRay inversion. -/
theorem twinRay_I3_neg (qAB : Fin 3 → ℝ) :
    I3 (-qAB) = -I3 qAB := by
  unfold I3
  rw [P_aniso_neg]
  simp [Pi.neg_apply]

theorem I3_neg_cartan (q : Fin 3 → ℝ) :
    I3 (-q) = -I3 q :=
  twinRay_I3_neg q

/-! ### C₃ on the Cartan picture -/

theorem cartanDiag_cycle3 (q : Fin 3 → ℝ) :
    cartanDiag (cycle3 q) =
      Matrix.diagonal (cycle3 (P_aniso q)) := by
  simp [cartanDiag, P_aniso_cycle3]

theorem C2_cycle3 (q : Fin 3 → ℝ) :
    C2 (cycle3 q) = C2 q := by
  simp [← detailEnergy_eq_C2, detailEnergy_cycle3]

theorem cycle3_cartan_intertwining (q : Fin 3 → ℝ) :
    intertwiningDefect P_aniso cycle3 cycle3 q = 0 ∧
      C2 (cycle3 q) = C2 q :=
  ⟨cycle3_P_aniso_intertwines q, C2_cycle3 q⟩

/-! ### Master theorem bundle -/

/--
Semiprimaler Dreikanal-Zerlegungssatz (finite claim).

The semiprimal triad carries an exact three-point C₃-equivariant Haar filterbank
whose high-pass energy coincides with the traceless Cartan / A₂ quadratic form.
-/
structure ThreeChannelDecomposition (q : Fin 3 → ℝ) : Prop where
  reconstruction : P_iso q + P_aniso q = q
  vanishingMoment : mean (P_aniso q) = 0
  parseval : energySq q = 3 * (mean q) ^ 2 + detailEnergy q
  surgery : detailEnergy q = surgeryEnergy q
  equivariance : P_aniso (cycle3 q) = cycle3 (P_aniso q)
  cartan : detailEnergy q = C2 q

theorem threeChannelDecomposition (q : Fin 3 → ℝ) :
    ThreeChannelDecomposition q where
  reconstruction := id_eq_P_iso_add_P_aniso q
  vanishingMoment := mean_P_aniso_eq_zero q
  parseval := energySq_eq_three_mean_sq_add_detail q
  surgery := detailEnergy_eq_surgeryEnergy q
  equivariance := P_aniso_cycle3 q
  cartan := detailEnergy_eq_C2 q

/-- Explicit non-claim: no classical wavelet theory on \(\mathbb{N}\). -/
theorem no_nat_wavelet_basis_claim : True := trivial

/-- Explicit non-claim: Cartan identification is algebraic, not a Lie-dynamics theorem. -/
theorem no_lie_dynamics_claim : True := trivial

end SemiprimeWavelet
end KeplerHurwitz.EABC
