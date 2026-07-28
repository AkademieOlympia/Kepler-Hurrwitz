/-
  Detail / surgery energy of the semiprimal three-channel filterbank.

  Claim wall:
    [A] Parseval split; surgeryEnergy = detailEnergy; C₃ invariance; Lipschitz control
    [C] physical energy interpretation — NOT claimed (quadratic form identification only)
-/

import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic
import KeplerHurwitz.EABC.SemiprimeWaveletCore

namespace KeplerHurwitz.EABC
namespace SemiprimeWavelet

/-! ## Energies -/

/-- Squared Euclidean energy \(\|q\|^2=\sum_i q_i^2\). -/
noncomputable def energySq (q : Fin 3 → ℝ) : ℝ :=
  ∑ i : Fin 3, (q i) ^ 2

/-- Wavelet detail energy \(\|P_{\mathrm{aniso}}q\|^2\). -/
noncomputable def detailEnergy (q : Fin 3 → ℝ) : ℝ :=
  energySq (P_aniso q)

/-- Surgery energy
\(E_{\mathrm{surg}}(q)=\frac13\bigl((q_0-q_1)^2+(q_1-q_2)^2+(q_2-q_0)^2\bigr)\). -/
noncomputable def surgeryEnergy (q : Fin 3 → ℝ) : ℝ :=
  ((q 0 - q 1) ^ 2 + (q 1 - q 2) ^ 2 + (q 2 - q 0) ^ 2) / 3

theorem detailEnergy_nonneg (q : Fin 3 → ℝ) : 0 ≤ detailEnergy q := by
  unfold detailEnergy energySq
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem surgeryEnergy_nonneg (q : Fin 3 → ℝ) : 0 ≤ surgeryEnergy q := by
  unfold surgeryEnergy
  apply div_nonneg _ (by norm_num : (0 : ℝ) ≤ 3)
  have h01 := sq_nonneg (q 0 - q 1)
  have h12 := sq_nonneg (q 1 - q 2)
  have h20 := sq_nonneg (q 2 - q 0)
  linarith

/-! ### Orthogonality / Parseval -/

/-- Satz 5: isotropic and detail channels are orthogonal. -/
theorem inner_P_iso_P_aniso (q : Fin 3 → ℝ) :
    ∑ i : Fin 3, P_iso q i * P_aniso q i = 0 := by
  have h := sum_P_aniso_eq_zero q
  simp only [P_iso_apply]
  calc
    ∑ i : Fin 3, mean q * P_aniso q i
        = mean q * ∑ i : Fin 3, P_aniso q i := by
          rw [Finset.mul_sum]
    _ = mean q * 0 := by rw [h]
    _ = 0 := by ring

/-- Parseval via explicit Fin-3 expansion. -/
theorem energySq_eq_iso_add_detail (q : Fin 3 → ℝ) :
    energySq q = energySq (P_iso q) + detailEnergy q := by
  have horth := inner_P_iso_P_aniso q
  unfold detailEnergy energySq
  -- Expand all three coordinates using reconstruction.
  have h0 := congrFun (id_eq_P_iso_add_P_aniso q) 0
  have h1 := congrFun (id_eq_P_iso_add_P_aniso q) 1
  have h2 := congrFun (id_eq_P_iso_add_P_aniso q) 2
  simp only [Fin.sum_univ_three] at horth ⊢
  -- q_i = iso_i + aniso_i
  simp only [P_iso_apply] at h0 h1 h2 horth ⊢
  -- Goal: q0²+q1²+q2² = 3μ² + (q0-μ)²+(q1-μ)²+(q2-μ)²
  -- Use P_aniso_apply
  simp only [P_aniso_apply] at horth ⊢
  -- After simp, iso components are mean q
  -- Reconstruct from h0,h1,h2: q i = mean + (q i - mean)
  clear h0 h1 h2
  -- Direct ring identity:
  -- ∑ q_i² = ∑ (μ + (q_i-μ))² = 3μ² + ∑(q_i-μ)² + 2μ∑(q_i-μ)
  -- and ∑(q_i-μ)=0
  have hsum := sum_P_aniso_eq_zero q
  simp only [P_aniso_apply, Fin.sum_univ_three] at hsum
  ring_nf
  nlinarith [sq_nonneg (q 0 - mean q), sq_nonneg (q 1 - mean q),
    sq_nonneg (q 2 - mean q), hsum, horth]

theorem energySq_P_iso (q : Fin 3 → ℝ) :
    energySq (P_iso q) = 3 * (mean q) ^ 2 := by
  simp [energySq, P_iso_apply]

/-- Boxed Parseval form: \(\|q\|^2=3\mu(q)^2+\|P_{\mathrm{aniso}}q\|^2\). -/
theorem energySq_eq_three_mean_sq_add_detail (q : Fin 3 → ℝ) :
    energySq q = 3 * (mean q) ^ 2 + detailEnergy q := by
  rw [energySq_eq_iso_add_detail, energySq_P_iso]

/-! ### Surgery = detail -/

private theorem cyclic_diff_sq_eq_three_detail (q : Fin 3 → ℝ) :
    (q 0 - q 1) ^ 2 + (q 1 - q 2) ^ 2 + (q 2 - q 0) ^ 2 =
      3 * ((q 0 - mean q) ^ 2 + (q 1 - mean q) ^ 2 + (q 2 - mean q) ^ 2) := by
  have hμ : mean q = (q 0 + q 1 + q 2) / 3 := by
    simp [mean, Fin.sum_univ_three]
  rw [hμ]
  ring

/-- Satz 6: surgery energy equals wavelet detail energy. -/
theorem detailEnergy_eq_surgeryEnergy (q : Fin 3 → ℝ) :
    detailEnergy q = surgeryEnergy q := by
  unfold detailEnergy energySq surgeryEnergy
  simp only [P_aniso_apply, Fin.sum_univ_three]
  have h := cyclic_diff_sq_eq_three_detail q
  linarith

theorem surgeryEnergy_eq_detailEnergy (q : Fin 3 → ℝ) :
    surgeryEnergy q = detailEnergy q :=
  (detailEnergy_eq_surgeryEnergy q).symm

/-- Detail energy vanishes iff the state is constant. -/
theorem detailEnergy_eq_zero_iff_constant (q : Fin 3 → ℝ) :
    detailEnergy q = 0 ↔ ∀ i j : Fin 3, q i = q j := by
  constructor
  · intro h
    have hsum : ∑ i : Fin 3, (P_aniso q i) ^ 2 = 0 := by
      simpa [detailEnergy, energySq] using h
    have hP : P_aniso q = 0 := by
      ext i
      have hterms :=
        (Finset.sum_eq_zero_iff_of_nonneg
          (fun _ _ => sq_nonneg (P_aniso q _))).1 hsum
      exact sq_eq_zero_iff.mp (hterms i (Finset.mem_univ i))
    exact (P_aniso_eq_zero_iff_constant q).1 hP
  · intro h
    have hP := (P_aniso_eq_zero_iff_constant q).2 h
    simp [detailEnergy, energySq, hP]

/-! ### C₃ and sign invariance -/

theorem detailEnergy_cycle3 (q : Fin 3 → ℝ) :
    detailEnergy (cycle3 q) = detailEnergy q := by
  unfold detailEnergy energySq
  rw [P_aniso_cycle3]
  simp [cycle3, Fin.sum_univ_three]
  ring

theorem surgeryEnergy_cycle3 (q : Fin 3 → ℝ) :
    surgeryEnergy (cycle3 q) = surgeryEnergy q := by
  rw [← detailEnergy_eq_surgeryEnergy, detailEnergy_cycle3, detailEnergy_eq_surgeryEnergy]

/-- Lemma 10: TwinRay energy invariance under \(q\mapsto -q\). -/
theorem detailEnergy_neg (q : Fin 3 → ℝ) :
    detailEnergy (-q) = detailEnergy q := by
  unfold detailEnergy energySq
  have hP : P_aniso (-q) = -P_aniso q := by
    ext i
    simp [P_aniso_apply, mean, Fin.sum_univ_three]
    ring
  simp [hP, Pi.neg_apply]

theorem surgeryEnergy_neg (q : Fin 3 → ℝ) :
    surgeryEnergy (-q) = surgeryEnergy q := by
  rw [← detailEnergy_eq_surgeryEnergy, detailEnergy_neg, detailEnergy_eq_surgeryEnergy]

/-! ### Two-channel coordinate form (basis-dependent) -/

/-- Satz 7: \(E_{\mathrm{surg}}=\tfrac12(q_0-q_1)^2+\tfrac16(q_0+q_1-2q_2)^2\). -/
theorem surgeryEnergy_two_channel (q : Fin 3 → ℝ) :
    surgeryEnergy q =
      (1 / 2) * (q 0 - q 1) ^ 2 + (1 / 6) * (q 0 + q 1 - 2 * q 2) ^ 2 := by
  unfold surgeryEnergy
  ring

/-! ### Stability -/

/-- Euclidean distance squared between triad states. -/
noncomputable def distSq (q r : Fin 3 → ℝ) : ℝ :=
  energySq (q - r)

theorem P_aniso_sub (q r : Fin 3 → ℝ) :
    P_aniso (q - r) = P_aniso q - P_aniso r := by
  ext i
  simp [P_aniso_apply, mean, Fin.sum_univ_three, Pi.sub_apply]
  ring

/-- Satz 18 (squared form): detail energy of a difference is dominated by total energy. -/
theorem detailEnergy_sub_le_energySq (q r : Fin 3 → ℝ) :
    detailEnergy (q - r) ≤ energySq (q - r) := by
  have h := energySq_eq_three_mean_sq_add_detail (q - r)
  have hμ : 0 ≤ 3 * (mean (q - r)) ^ 2 := by
    nlinarith [sq_nonneg (mean (q - r))]
  linarith

/-- Deviation identity used by the asymptotic collapse criterion. -/
theorem aniso_eq_deviation_from_collapse (q : Fin 3 → ℝ) :
    P_aniso q = q - collapse (mean q) := by
  simp [P_aniso, P_iso]

/-- Satz 19: detail energy vanishes iff the state equals its isotropic collapse. -/
theorem detailEnergy_eq_zero_iff_eq_collapse (q : Fin 3 → ℝ) :
    detailEnergy q = 0 ↔ q = collapse (mean q) := by
  constructor
  · intro h
    have hc := (detailEnergy_eq_zero_iff_constant q).1 h
    have hP := (P_aniso_eq_zero_iff_constant q).2 hc
    calc
      q = P_iso q + P_aniso q := (id_eq_P_iso_add_P_aniso q).symm
      _ = collapse (mean q) + 0 := by simp [P_iso, hP]
      _ = collapse (mean q) := by simp
  · intro h
    rw [h, detailEnergy, energySq]
    have hP : P_aniso (collapse (mean q)) = 0 := P_aniso_constant (mean q)
    simp [hP]

/-! ### Explicit non-claims -/

/-- Identification of quadratic forms is algebraic, not a physical energy theorem. -/
theorem no_physical_energy_claim : True := trivial

end SemiprimeWavelet
end KeplerHurwitz.EABC
