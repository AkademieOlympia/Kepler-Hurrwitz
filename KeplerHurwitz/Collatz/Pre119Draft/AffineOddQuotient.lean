import Mathlib
import KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra

set_option linter.dupNamespace false
set_option linter.style.nativeDecide false

/-!
# Pre119Draft — AffineOddQuotient (PR #15, Schicht 2)

Odd affine quotient + reverse reconstruction of exact local valuations.

ClaimsFreeze false. 0 sorry. No Collatz claim.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient

open KeplerHurwitz
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine

/-- Exact odd quotient form of the affine Syracuse word identity. -/
def AffineOddQuotient (E : List Nat) (n : Nat) : Prop :=
  ∃ q : Nat, Odd q ∧ q * 2 ^ E.sum = 3 ^ E.length * n + wordC E

theorem realizedImage_odd_of_cons {e : Nat} {es : List Nat} {n : Nat}
    (h : RealizesWord (e :: es) n) :
    Odd (realizedImage n (e :: es)) := by
  induction es generalizing n e with
  | nil =>
    obtain ⟨_hodd, _hval, _⟩ := h
    have hpos : 0 < 3 * n + 1 := by omega
    simpa [realizedImage, nextOdd] using oddCore_odd_of_pos hpos
  | cons e' es' ih =>
    obtain ⟨_hodd, _hval, hrest⟩ := h
    simpa [realizedImage] using ih (e := e') (n := nextOdd n) hrest

/-- `[A]` Forward: realizing nonempty words yield an odd affine quotient. -/
theorem affineOddQuotient_of_realizesWord {E : List Nat} {n : Nat}
    (hne : E ≠ []) (h : RealizesWord E n) :
    AffineOddQuotient E n := by
  match E, hne with
  | [], hne => exact (hne rfl).elim
  | e :: es, _ =>
    refine ⟨realizedImage n (e :: es), realizedImage_odd_of_cons h, ?_⟩
    simpa using realizedImage_mul_pow h

/-! ### Half-modulus ModEq ⇒ odd quotient -/

/--
`[A]` Generic bridge: `A ≡ 2^S (mod 2^{S+1})` yields an odd exact quotient by `2^S`.
-/
theorem affineOddQuotient_of_half_modulus_modEq {S A : Nat}
    (h : A ≡ 2 ^ S [MOD 2 ^ (S + 1)]) :
    ∃ q : Nat, Odd q ∧ q * 2 ^ S = A := by
  have hmod : A % 2 ^ (S + 1) = 2 ^ S := by
    have : (2 ^ S) % 2 ^ (S + 1) = 2 ^ S :=
      Nat.mod_eq_of_lt (Nat.pow_lt_pow_right (by decide : 1 < 2) (by omega : S < S + 1))
    simpa [Nat.ModEq, this] using h
  have hdecomp : 2 ^ (S + 1) * (A / 2 ^ (S + 1)) + A % 2 ^ (S + 1) = A :=
    Nat.div_add_mod A (2 ^ (S + 1))
  rw [hmod] at hdecomp
  have hpow : 2 ^ (S + 1) = 2 * 2 ^ S := by rw [pow_succ, Nat.mul_comm]
  refine ⟨2 * (A / 2 ^ (S + 1)) + 1, odd_two_mul_add_one _, ?_⟩
  calc
    (2 * (A / 2 ^ (S + 1)) + 1) * 2 ^ S
        = 2 * (A / 2 ^ (S + 1)) * 2 ^ S + 2 ^ S := by ring
    _ = (A / 2 ^ (S + 1)) * (2 * 2 ^ S) + 2 ^ S := by ring
    _ = (A / 2 ^ (S + 1)) * 2 ^ (S + 1) + 2 ^ S := by rw [← hpow]
    _ = 2 ^ (S + 1) * (A / 2 ^ (S + 1)) + 2 ^ S := by ring
    _ = A := hdecomp

/-! ### padic / nextOdd reconstruction -/

private theorem padicValNat_two_pow' (e : Nat) : padicValNat 2 (2 ^ e) = e := by
  induction e with
  | zero => simp
  | succ e ih =>
    rw [pow_succ]
    have hpow : 2 ^ e ≠ 0 := pow_ne_zero e (by decide : (2 : Nat) ≠ 0)
    have h2 : (2 : Nat) ≠ 0 := by decide
    rw [padicValNat.mul (p := 2) hpow h2, ih]
    simp

theorem valuationStep_eq_of_two_pow_mul_odd {n e m : Nat}
    (h : 3 * n + 1 = 2 ^ e * m) (hm : Odd m) :
    valuationStep n = e := by
  have hm0 : m ≠ 0 := by
    intro h0
    exact (by decide : ¬ Odd (0 : Nat)) (h0 ▸ hm)
  have hpow0 : 2 ^ e ≠ 0 := pow_ne_zero e (by decide : (2 : Nat) ≠ 0)
  have hnot : ¬ 2 ∣ m := Odd.not_two_dvd_nat hm
  have : padicValNat 2 (3 * n + 1) = e := by
    rw [h, padicValNat.mul (p := 2) hpow0 hm0, padicValNat_two_pow',
      padicValNat.eq_zero_of_not_dvd hnot]
    omega
  simpa [valuationStep] using this

theorem nextOdd_eq_of_two_pow_mul_odd {n e m : Nat}
    (h : 3 * n + 1 = 2 ^ e * m) (hm : Odd m) :
    nextOdd n = m := by
  have hv := valuationStep_eq_of_two_pow_mul_odd h hm
  rw [nextOdd_eq_div_of_val hv, h,
    Nat.mul_div_cancel_left _ (Nat.pow_pos (by decide : 0 < 2))]

/-! ### wordC parity -/

theorem odd_pow_three (k : Nat) : Odd (3 ^ k) := by
  induction k with
  | zero => decide
  | succ k ih =>
    rw [pow_succ]
    exact Odd.mul ih (by decide : Odd (3 : Nat))

theorem wordC_odd_of_pos {E : List Nat}
    (hne : E ≠ []) (hpos : ∀ a ∈ E, 1 ≤ a) :
    Odd (wordC E) := by
  match E, hne with
  | [], hne => exact (hne rfl).elim
  | e :: es, _ =>
    have he : 1 ≤ e := hpos e (by simp)
    have heven : Even (2 ^ e * wordC es) :=
      Even.mul_right
        ((Nat.even_pow' (by omega : e ≠ 0)).2 (by decide : Even (2 : Nat))) _
    exact (odd_pow_three es.length).add_even heven

/-! ### Cons decomposition -/

theorem affineOddQuotient_cons_form {e : Nat} {es : List Nat} {n q : Nat}
    (heq : q * 2 ^ (e :: es).sum = 3 ^ (e :: es).length * n + wordC (e :: es)) :
    q * 2 ^ (e + es.sum) =
      3 ^ es.length * (3 * n + 1) + 2 ^ e * wordC es := by
  have hsum : (e :: es).sum = e + es.sum := by simp [List.sum_cons]
  have hlen : (e :: es).length = es.length + 1 := by simp
  have hw : wordC (e :: es) = 3 ^ es.length + 2 ^ e * wordC es := wordC_cons e es
  calc
    q * 2 ^ (e + es.sum)
        = q * 2 ^ (e :: es).sum := by rw [hsum]
    _ = 3 ^ (e :: es).length * n + wordC (e :: es) := heq
    _ = 3 ^ (es.length + 1) * n + (3 ^ es.length + 2 ^ e * wordC es) := by
          rw [hlen, hw]
    _ = 3 ^ es.length * (3 * n + 1) + 2 ^ e * wordC es := by ring

/--
`[A]` Cons-decomposition of an odd affine quotient into an exact local Syracuse
step and a tail quotient.
-/
theorem affineOddQuotient_cons_decompose {e : Nat} {es : List Nat} {n : Nat}
    (_he : 1 ≤ e) (hpos : ∀ a ∈ es, 1 ≤ a)
    (hAQ : AffineOddQuotient (e :: es) n) :
    ∃ m : Nat,
      Odd m ∧
        3 * n + 1 = 2 ^ e * m ∧
          AffineOddQuotient es m := by
  obtain ⟨q, hq, heq⟩ := hAQ
  have hform := affineOddQuotient_cons_form heq
  have hpow : 2 ^ (e + es.sum) = 2 ^ e * 2 ^ es.sum := Nat.pow_add 2 e es.sum
  have hle : 2 ^ e * wordC es ≤ q * 2 ^ (e + es.sum) := by
    calc
      2 ^ e * wordC es
          ≤ 3 ^ es.length * (3 * n + 1) + 2 ^ e * wordC es :=
            Nat.le_add_left _ _
      _ = q * 2 ^ (e + es.sum) := hform.symm
  have hX :
      3 ^ es.length * (3 * n + 1) =
        q * 2 ^ (e + es.sum) - 2 ^ e * wordC es :=
    Nat.eq_sub_of_add_eq hform.symm
  have hle' : wordC es ≤ q * 2 ^ es.sum := by
    have : 2 ^ e * wordC es ≤ 2 ^ e * (q * 2 ^ es.sum) := by
      calc
        2 ^ e * wordC es ≤ q * 2 ^ (e + es.sum) := hle
        _ = q * (2 ^ e * 2 ^ es.sum) := by rw [hpow]
        _ = 2 ^ e * (q * 2 ^ es.sum) := by ac_rfl
    exact Nat.le_of_mul_le_mul_left this (Nat.pow_pos (by decide : 0 < 2))
  have hfactor :
      3 ^ es.length * (3 * n + 1) =
        2 ^ e * (q * 2 ^ es.sum - wordC es) := by
    calc
      3 ^ es.length * (3 * n + 1)
          = q * 2 ^ (e + es.sum) - 2 ^ e * wordC es := hX
      _ = q * (2 ^ e * 2 ^ es.sum) - 2 ^ e * wordC es := by rw [hpow]
      _ = 2 ^ e * (q * 2 ^ es.sum) - 2 ^ e * wordC es := by
            congr 1; ac_rfl
      _ = 2 ^ e * (q * 2 ^ es.sum - wordC es) :=
            (Nat.mul_sub_left_distrib (2 ^ e) _ _).symm
  have hdvd : 2 ^ e ∣ 3 ^ es.length * (3 * n + 1) := ⟨_, hfactor⟩
  have hcop : Nat.Coprime (2 ^ e) (3 ^ es.length) :=
    Nat.Coprime.pow e es.length (by decide : Nat.Coprime 2 3)
  have hm_dvd : 2 ^ e ∣ 3 * n + 1 := hcop.dvd_of_dvd_mul_left hdvd
  obtain ⟨m, hm_eq⟩ := hm_dvd
  have htail_eq : q * 2 ^ es.sum = 3 ^ es.length * m + wordC es := by
    have hmul :
        2 ^ e * (3 ^ es.length * m) =
          2 ^ e * (q * 2 ^ es.sum - wordC es) := by
      calc
        2 ^ e * (3 ^ es.length * m)
            = 3 ^ es.length * (2 ^ e * m) := by ac_rfl
        _ = 3 ^ es.length * (3 * n + 1) := by rw [← hm_eq]
        _ = 2 ^ e * (q * 2 ^ es.sum - wordC es) := hfactor
    have hcancel :=
      Nat.eq_of_mul_eq_mul_left (Nat.pow_pos (by decide : 0 < 2)) hmul
    exact Nat.eq_add_of_sub_eq hle' hcancel.symm
  have hm_odd : Odd m := by
    by_cases hnil : es = []
    · subst hnil
      have : q = m := by simpa [List.sum_nil, wordC_nil] using htail_eq
      rwa [← this]
    · obtain ⟨e', es', rfl⟩ := List.exists_cons_of_ne_nil hnil
      have hsumpos : 0 < (e' :: es').sum := by
        have he' : 1 ≤ e' := hpos e' (by simp)
        simp [List.sum_cons]
        omega
      have hC : Odd (wordC (e' :: es')) :=
        wordC_odd_of_pos (List.cons_ne_nil _ _) fun a ha => hpos a ha
      have hLHS : Even (q * 2 ^ (e' :: es').sum) :=
        Even.mul_left
          ((Nat.even_pow' (ne_of_gt hsumpos)).2 (by decide : Even (2 : Nat))) _
      have hRHS : Even (3 ^ (e' :: es').length * m + wordC (e' :: es')) := by
        rw [← htail_eq]; exact hLHS
      rcases Nat.even_or_odd m with hm_even | hm_odd
      · have hEvenMul : Even (3 ^ (e' :: es').length * m) := hm_even.mul_left _
        have hOddSum : Odd (3 ^ (e' :: es').length * m + wordC (e' :: es')) :=
          hEvenMul.add_odd hC
        exact absurd hRHS (Nat.not_even_iff_odd.mpr hOddSum)
      · exact hm_odd
  exact ⟨m, hm_odd, hm_eq, ⟨q, hq, htail_eq⟩⟩

/-- Oddness of the start from a positive-head affine quotient. -/
theorem odd_of_affineOddQuotient_cons {e : Nat} {es : List Nat} {n : Nat}
    (he : 1 ≤ e) (hpos : ∀ a ∈ (e :: es), 1 ≤ a)
    (hAQ : AffineOddQuotient (e :: es) n) :
    Odd n := by
  obtain ⟨q, hq, heq⟩ := hAQ
  have hsumpos : 0 < (e :: es).sum := by
    simp [List.sum_cons]
    omega
  have hC : Odd (wordC (e :: es)) := wordC_odd_of_pos (List.cons_ne_nil _ _) hpos
  have hLHS : Even (q * 2 ^ (e :: es).sum) :=
    Even.mul_left
      ((Nat.even_pow' (ne_of_gt hsumpos)).2 (by decide : Even (2 : Nat))) _
  have hRHS : Even (3 ^ (e :: es).length * n + wordC (e :: es)) := by
    rw [← heq]; exact hLHS
  have h3 : Odd (3 ^ (e :: es).length) := odd_pow_three _
  rcases Nat.even_or_odd n with hn_even | hn_odd
  · have hEvenMul : Even (3 ^ (e :: es).length * n) := hn_even.mul_left _
    have hOddSum : Odd (3 ^ (e :: es).length * n + wordC (e :: es)) :=
      hEvenMul.add_odd hC
    exact absurd hRHS (Nat.not_even_iff_odd.mpr hOddSum)
  · exact hn_odd

/--
`[A]` Reverse direction: an odd affine quotient with positive exponents
reconstructs `RealizesWord`.
-/
theorem realizesWord_of_affineOddQuotient {E : List Nat} {n : Nat}
    (hpos : ∀ a ∈ E, 1 ≤ a) (hAQ : AffineOddQuotient E n) :
    RealizesWord E n := by
  induction E generalizing n with
  | nil =>
    trivial
  | cons e es ih =>
    have he : 1 ≤ e := hpos e (by simp)
    have hpos' : ∀ a ∈ es, 1 ≤ a := fun a ha => hpos a (List.mem_cons_of_mem _ ha)
    obtain ⟨m, hm_odd, hm_eq, htail⟩ :=
      affineOddQuotient_cons_decompose he hpos' hAQ
    have hodd := odd_of_affineOddQuotient_cons he hpos hAQ
    have hval := valuationStep_eq_of_two_pow_mul_odd hm_eq hm_odd
    have hnext := nextOdd_eq_of_two_pow_mul_odd hm_eq hm_odd
    refine ⟨Nat.odd_iff.mp hodd, hval, ?_⟩
    rw [hnext]
    exact ih hpos' htail

/-- `[A]` Biconditional for nonempty positive words. -/
theorem realizesWord_iff_affineOddQuotient {E : List Nat} {n : Nat}
    (hne : E ≠ []) (hpos : ∀ a ∈ E, 1 ≤ a) :
    RealizesWord E n ↔ AffineOddQuotient E n :=
  ⟨affineOddQuotient_of_realizesWord hne,
    realizesWord_of_affineOddQuotient hpos⟩

end KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient
