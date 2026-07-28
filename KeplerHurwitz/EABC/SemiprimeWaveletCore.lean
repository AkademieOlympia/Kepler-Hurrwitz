/-
  Semiprimal three-channel Haar filterbank on a C₃-orbit (Fin 3).

  Claim wall:
    [A] finite orthogonal mean/detail split on ℝ³; projector algebra; C₃ intertwining
    [C] classical wavelet MRA on ℕ / ℓ²(ℕ) basis / factorization algorithm — NOT claimed

  Docs: user exposition „Semiprimaler Dreikanal-Zerlegungssatz“;
        related audit `docs/eabc_interval_wavelet.md` (interval Haar remains Python-[B]).
-/

import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace KeplerHurwitz.EABC
namespace SemiprimeWavelet

/-! ## Elementary wavelet kernel on `Fin 3 → ℝ` -/

/-- Arithmetic mean \(\mu(q)=(q_0+q_1+q_2)/3\). -/
noncomputable def mean (q : Fin 3 → ℝ) : ℝ :=
  (∑ i : Fin 3, q i) / 3

/-- Collapse a scalar into the isotropic triad \(\mu(1,1,1)\). -/
def collapse (μ : ℝ) : Fin 3 → ℝ :=
  fun _ => μ

/-- Low-pass / isotropic projector \(P_{\mathrm{iso}}=\mathrm{collapse}\circ\mathrm{mean}\). -/
noncomputable def P_iso (q : Fin 3 → ℝ) : Fin 3 → ℝ :=
  collapse (mean q)

/-- High-pass / anisotropic projector \(P_{\mathrm{aniso}}=\mathrm{id}-P_{\mathrm{iso}}\). -/
noncomputable def P_aniso (q : Fin 3 → ℝ) : Fin 3 → ℝ :=
  q - P_iso q

/-- C₃ cycle on the triad: \(R(q_0,q_1,q_2)=(q_1,q_2,q_0)\). -/
def cycle3 (q : Fin 3 → ℝ) : Fin 3 → ℝ :=
  fun i => q (i + 1)

/-! ### Basic identities -/

@[simp] theorem collapse_apply (μ : ℝ) (i : Fin 3) : collapse μ i = μ := rfl

@[simp] theorem P_iso_apply (q : Fin 3 → ℝ) (i : Fin 3) :
    P_iso q i = mean q :=
  rfl

theorem P_aniso_apply (q : Fin 3 → ℝ) (i : Fin 3) :
    P_aniso q i = q i - mean q := by
  simp [P_aniso]

/-- Lemma 1: perfect reconstruction
`id = collapse ∘ mean + P_aniso`. -/
theorem mean_collapse_add_aniso (q : Fin 3 → ℝ) :
    collapse (mean q) + P_aniso q = q := by
  ext i
  simp [P_aniso, P_iso]

/-- Operator form of perfect reconstruction. -/
theorem id_eq_P_iso_add_P_aniso (q : Fin 3 → ℝ) :
    P_iso q + P_aniso q = q :=
  mean_collapse_add_aniso q

private theorem sum_mean_mul_three (q : Fin 3 → ℝ) :
    ∑ _i : Fin 3, mean q = 3 * mean q := by
  simp

/-- Lemma 2: vanishing moment of the detail channel. -/
theorem mean_P_aniso_eq_zero (q : Fin 3 → ℝ) :
    mean (P_aniso q) = 0 := by
  unfold mean
  have h :
      ∑ i : Fin 3, P_aniso q i = ∑ i : Fin 3, q i - ∑ i : Fin 3, mean q := by
    simp [P_aniso_apply, Finset.sum_sub_distrib]
  rw [h, sum_mean_mul_three, mean]
  ring

/-- Equivalent vanishing-moment form: detail is orthogonal to \((1,1,1)\). -/
theorem sum_P_aniso_eq_zero (q : Fin 3 → ℝ) :
    ∑ i : Fin 3, P_aniso q i = 0 := by
  have h := mean_P_aniso_eq_zero q
  unfold mean at h
  have h3 : (3 : ℝ) ≠ 0 := by norm_num
  exact (div_eq_zero_iff.mp h).resolve_right h3

/-- Lemma 3 (⇒): constants have vanishing detail. -/
theorem P_aniso_constant (c : ℝ) :
    P_aniso (fun _ : Fin 3 => c) = 0 := by
  ext i
  simp [P_aniso_apply, mean]

/-- Lemma 3 (⇔): detail vanishes iff the triad is constant. -/
theorem P_aniso_eq_zero_iff_constant (q : Fin 3 → ℝ) :
    P_aniso q = 0 ↔ ∀ i j : Fin 3, q i = q j := by
  constructor
  · intro h i j
    have hi := congrFun h i
    have hj := congrFun h j
    simp [P_aniso_apply] at hi hj
    linarith
  · intro h
    have hq : q = fun _ => q 0 := by
      ext j
      exact h j 0
    rw [hq]
    exact P_aniso_constant (q 0)

/-! ### Complementary projectors -/

theorem P_iso_idempotent (q : Fin 3 → ℝ) :
    P_iso (P_iso q) = P_iso q := by
  ext i
  simp [P_iso, mean, collapse, Fin.sum_univ_three]

theorem P_aniso_idempotent (q : Fin 3 → ℝ) :
    P_aniso (P_aniso q) = P_aniso q := by
  ext i
  have hμ := mean_P_aniso_eq_zero q
  simp [P_aniso_apply, hμ]

theorem P_iso_comp_P_aniso_eq_zero (q : Fin 3 → ℝ) :
    P_iso (P_aniso q) = 0 := by
  ext i
  simp [P_iso, mean_P_aniso_eq_zero]

theorem P_aniso_comp_P_iso_eq_zero (q : Fin 3 → ℝ) :
    P_aniso (P_iso q) = 0 := by
  simp only [P_iso]
  exact P_aniso_constant (mean q)

/-! ### C₃ equivariance of the filterbank -/

theorem mean_cycle3 (q : Fin 3 → ℝ) :
    mean (cycle3 q) = mean q := by
  simp [mean, cycle3, Fin.sum_univ_three]
  ring

theorem P_iso_cycle3 (q : Fin 3 → ℝ) :
    P_iso (cycle3 q) = cycle3 (P_iso q) := by
  ext i
  simp [P_iso, mean_cycle3, cycle3, collapse]

/-- Satz 8: high-pass intertwines the C₃ cycle. -/
theorem P_aniso_cycle3 (q : Fin 3 → ℝ) :
    P_aniso (cycle3 q) = cycle3 (P_aniso q) := by
  ext i
  simp [P_aniso, P_iso, cycle3, mean_cycle3]

/-! ### Isotropic / detail subspaces -/

/-- Isotropic line \(V_{\mathrm{iso}}=\mathrm{span}\{(1,1,1)\}\). -/
def IsIsotropic (q : Fin 3 → ℝ) : Prop :=
  ∃ c : ℝ, q = collapse c

/-- Detail plane \(V_{\mathrm{det}}=\{x:x_0+x_1+x_2=0\}\). -/
def IsDetail (q : Fin 3 → ℝ) : Prop :=
  ∑ i : Fin 3, q i = 0

theorem P_iso_isIsotropic (q : Fin 3 → ℝ) : IsIsotropic (P_iso q) :=
  ⟨mean q, rfl⟩

theorem P_aniso_isDetail (q : Fin 3 → ℝ) : IsDetail (P_aniso q) :=
  sum_P_aniso_eq_zero q

/-- Direct-sum reconstruction: every state is isotropic plus detail. -/
theorem direct_sum_reconstruction (q : Fin 3 → ℝ) :
    IsIsotropic (P_iso q) ∧ IsDetail (P_aniso q) ∧ P_iso q + P_aniso q = q :=
  ⟨P_iso_isIsotropic q, P_aniso_isDetail q, id_eq_P_iso_add_P_aniso q⟩

/-! ### Explicit claim wall -/

/-- `[A]` Finite three-point Haar filterbank with perfect reconstruction. -/
theorem finite_haar_filterbank_claim (q : Fin 3 → ℝ) :
    P_iso q + P_aniso q = q ∧ mean (P_aniso q) = 0 :=
  ⟨id_eq_P_iso_add_P_aniso q, mean_P_aniso_eq_zero q⟩

/-- Non-claim: no classical MRA / wavelet basis of \(\ell^2(\mathbb{N})\). -/
theorem no_classical_mra_on_nat_claim : True := trivial

/-- Non-claim: no efficient factorization algorithm from wavelet coefficients. -/
theorem no_factorization_algorithm_claim : True := trivial

end SemiprimeWavelet
end KeplerHurwitz.EABC
