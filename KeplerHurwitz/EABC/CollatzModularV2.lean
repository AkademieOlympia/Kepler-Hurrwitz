/-
  Modular first-step valuations from congruence classes mod 16.

  Algebraic filter behind the Python cylinder / V₄ correlation scan:
  residue mod 16 already forces the first accelerated Syracuse exponent ν₂(3κ+1).

  Claim wall:
    [A] κ ≡ 15 (mod 16) ⇒ ν₂(3κ+1) = 1
    [A] κ ≡ 5  (mod 16) ⇒ ν₂(3κ+1) ≥ 4
    [A] CRT with gcd(κ,6)=1: class 5 ⇒ mod-12 ∈ {1,5}; class 15 ⇒ {7,11}
    [A under H] class 15 ⇒ half-step ascent; class 5 ⇒ immediate descent
    [A] class 7 ⇒ ν₂=1; half-step images 15→{7,15}, 7→{3,11}
    [A] m mod 2 split: 15→7/15; 7→11/3; 3→5/13; 11→1/9
    [A under H] classes 3,7,11,15 ⇒ half-step ascent
    [A] finite AP half-counts (Even/Odd quot) — exact 50/50 on length 2M
    [A] complete odd-mod-16 ν₂ table: 1,9=2; 13=3; 5≥4; {3,7,11,15}=1
    [A under H] v≥2 ∧ κ>1 ⇒ core descent; unified dispatcher API
    [C] / NON-CLAIM: no multi-step density / measure dominance; no Collatz proof

  Docs: docs/eabc_collatz_audit_grid.md §5.5–5.11
-/

import Mathlib
import KeplerHurwitz.EABC.CollatzTwoStep

namespace KeplerHurwitz.EABC
namespace CollatzModularV2

open CollatzSyracuseNorm
open CollatzTwoStep

/-! ## First-step ν₂ from mod-16 cylinders [A] -/

/--
`[A]` κ ≡ 15 (mod 16): `3κ+1` is divisible by 2 but not by 4,
hence the first accelerated step has exact valuation `ν₂ = 1`.
-/
theorem two_dvd_not_four_of_mod16_fifteen {κ : ℕ} (h : κ % 16 = 15) :
    2 ∣ 3 * κ + 1 ∧ ¬4 ∣ 3 * κ + 1 := by
  constructor <;> omega

/--
`[A]` κ ≡ 15 (mod 16) ⇒ `padicValNat 2 (3κ+1) = 1`.
-/
theorem mod16_fifteen_v2_eq_one {κ : ℕ} (h : κ % 16 = 15) :
    padicValNat 2 (3 * κ + 1) = 1 := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h2dvd : 2 ∣ 3 * κ + 1 := by omega
  have h4not : ¬4 ∣ 3 * κ + 1 := by omega
  have h1le : 1 ≤ padicValNat 2 (3 * κ + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h2dvd)
  have hnot2le : ¬2 ≤ padicValNat 2 (3 * κ + 1) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).2 (by simpa using h2le))
  omega

/--
`[A]` κ ≡ 5 (mod 16): `3κ+1` is divisible by `16 = 2⁴`.
-/
theorem sixteen_dvd_three_mul_add_one_of_mod16_five {κ : ℕ} (h : κ % 16 = 5) :
    16 ∣ 3 * κ + 1 := by
  omega

/--
`[A]` κ ≡ 5 (mod 16) ⇒ `padicValNat 2 (3κ+1) ≥ 4`.
-/
theorem mod16_five_v2_ge_four {κ : ℕ} (h : κ % 16 = 5) :
    4 ≤ padicValNat 2 (3 * κ + 1) := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h16dvd : 16 ∣ 3 * κ + 1 := sixteen_dvd_three_mul_add_one_of_mod16_five h
  exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h16dvd)

/-! ## CRT filter: mod-16 cylinder ∩ (ℤ/6ℤ)× → mod-12 channel class [A] -/

private theorem mod48_of_mod16_five {κ : ℕ} (h : κ % 16 = 5) :
    κ % 48 = 5 ∨ κ % 48 = 21 ∨ κ % 48 = 37 := by
  have hmod : (κ % 48) % 16 = 5 := by
    rw [Nat.mod_mod_of_dvd κ (by decide : 16 ∣ 48)]
    exact h
  have hlt : κ % 48 < 48 := Nat.mod_lt κ (by decide)
  interval_cases κ % 48 <;> simp_all

private theorem mod48_of_mod16_fifteen {κ : ℕ} (h : κ % 16 = 15) :
    κ % 48 = 15 ∨ κ % 48 = 31 ∨ κ % 48 = 47 := by
  have hmod : (κ % 48) % 16 = 15 := by
    rw [Nat.mod_mod_of_dvd κ (by decide : 16 ∣ 48)]
    exact h
  have hlt : κ % 48 < 48 := Nat.mod_lt κ (by decide)
  interval_cases κ % 48 <;> simp_all

private theorem three_dvd_of_mod48_eq_21 {κ : ℕ} (h : κ % 48 = 21) : 3 ∣ κ := by
  have : κ % 3 = 0 := by
    have h' : (κ % 48) % 3 = 0 := by simp [h]
    rwa [Nat.mod_mod_of_dvd κ (by decide : 3 ∣ 48)] at h'
  exact Nat.dvd_iff_mod_eq_zero.mpr this

private theorem three_dvd_of_mod48_eq_15 {κ : ℕ} (h : κ % 48 = 15) : 3 ∣ κ := by
  have : κ % 3 = 0 := by
    have h' : (κ % 48) % 3 = 0 := by simp [h]
    rwa [Nat.mod_mod_of_dvd κ (by decide : 3 ∣ 48)] at h'
  exact Nat.dvd_iff_mod_eq_zero.mpr this

private theorem gcd_ne_one_of_three_dvd {κ : ℕ} (h : 3 ∣ κ) : Nat.gcd κ 6 ≠ 1 := by
  intro hg
  have : 3 ∣ Nat.gcd κ 6 := Nat.dvd_gcd h (by decide)
  rw [hg] at this
  exact absurd this (by decide)

/--
`[A]` κ ≡ 5 (mod 16) and `gcd(κ,6)=1` ⇒ κ ≡ 1 or 5 (mod 12)
(i.e. V₄ channels E or A).
-/
theorem mod16_five_mod12_is_one_or_five {κ : ℕ}
    (h16 : κ % 16 = 5) (h6 : Nat.gcd κ 6 = 1) :
    κ % 12 = 1 ∨ κ % 12 = 5 := by
  rcases mod48_of_mod16_five h16 with h | h | h
  · right
    calc
      κ % 12 = (κ % 48) % 12 := (Nat.mod_mod_of_dvd κ (by decide : 12 ∣ 48)).symm
      _ = 5 := by simp [h]
  · exact (gcd_ne_one_of_three_dvd (three_dvd_of_mod48_eq_21 h) h6).elim
  · left
    calc
      κ % 12 = (κ % 48) % 12 := (Nat.mod_mod_of_dvd κ (by decide : 12 ∣ 48)).symm
      _ = 1 := by simp [h]

/--
`[A]` κ ≡ 15 (mod 16) and `gcd(κ,6)=1` ⇒ κ ≡ 7 or 11 (mod 12)
(i.e. V₄ channels B or C).
-/
theorem mod16_fifteen_mod12_is_seven_or_eleven {κ : ℕ}
    (h16 : κ % 16 = 15) (h6 : Nat.gcd κ 6 = 1) :
    κ % 12 = 7 ∨ κ % 12 = 11 := by
  rcases mod48_of_mod16_fifteen h16 with h | h | h
  · exact (gcd_ne_one_of_three_dvd (three_dvd_of_mod48_eq_15 h) h6).elim
  · left
    calc
      κ % 12 = (κ % 48) % 12 := (Nat.mod_mod_of_dvd κ (by decide : 12 ∣ 48)).symm
      _ = 7 := by simp [h]
  · right
    calc
      κ % 12 = (κ % 48) % 12 := (Nat.mod_mod_of_dvd κ (by decide : 12 ∣ 48)).symm
      _ = 11 := by simp [h]

/-! ## First step → core ascent / descent under H [A under H] -/

private theorem not_two_dvd_of_coprime_six {n : ℕ} (h : Nat.Coprime n 6) : ¬2 ∣ n := by
  intro hd
  have : 2 ∣ Nat.gcd n 6 := Nat.dvd_gcd hd (by decide)
  have hg : Nat.gcd n 6 = 1 := h
  rw [hg] at this
  exact absurd this (by decide)

theorem odd_of_embeddable {κ : ℕ} (h : OddCoreEmbeddable κ) : Odd κ := by
  have h2 : ¬2 ∣ κ := not_two_dvd_of_coprime_six h
  exact Nat.odd_iff.mpr (by
    have : κ % 2 ≠ 0 := fun h0 => h2 (Nat.dvd_iff_mod_eq_zero.mpr h0)
    omega)

/--
`[A under H]` κ ≡ 15 (mod 16) forces the accelerated step to be a half-step
(`v = 1`) and, for `κ > 0`, a strict core ascent `κ < κ'`.
-/
theorem mod16_fifteen_normHyp_ascent
    {κ κ' v : ℕ} (h16 : κ % 16 = 15)
    (H : SyracuseNormHypothesis κ κ' v) (hκ : 0 < κ) :
    v = 1 ∧ κ < κ' := by
  have ⟨_, h4not⟩ := two_dvd_not_four_of_mod16_fifteen h16
  have hv1 : v = 1 := by
    have hvpos := H.v_pos
    have hExact := H.step_exact
    obtain ⟨v', rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hvpos)
    cases v' with
    | zero => rfl
    | succ v'' =>
      -- v = v'' + 2 ≥ 2, so 4 ∣ 2^v
      have h4pow : 4 ∣ (2 : ℕ) ^ (v'' + 2) := ⟨(2 : ℕ) ^ v'', by ring⟩
      have h4mul : 4 ∣ κ' * 2 ^ (v'' + 2) := dvd_mul_of_dvd_right h4pow κ'
      have h4step : 4 ∣ 3 * κ + 1 := by simpa [hExact] using h4mul
      exact (h4not h4step).elim
  refine ⟨hv1, ?_⟩
  have H1 : SyracuseNormHypothesis κ κ' 1 := by simpa [hv1] using H
  exact half_step_intermediate_ascent (toHalfStep_of_normHyp_v1 H1) hκ

/--
`[A under H]` κ ≡ 5 (mod 16) forces `v ≥ 4` and immediate core descent `κ' < κ`
(for `κ > 0`).
-/
theorem mod16_five_normHyp_descent
    {κ κ' v : ℕ} (h16 : κ % 16 = 5)
    (H : SyracuseNormHypothesis κ κ' v) (hκ : 0 < κ) :
    4 ≤ v ∧ κ' < κ := by
  have hExact := H.step_exact
  have hv : 4 ≤ v := by
    have h16dvd := sixteen_dvd_three_mul_add_one_of_mod16_five h16
    have hdiv : 16 ∣ κ' * 2 ^ v := by simpa [hExact] using h16dvd
    have hodd : Odd κ' := odd_of_embeddable H.embeddable_post
    have hc2 : Nat.Coprime κ' 2 := Odd.coprime_two_right hodd
    have hc16 : Nat.Coprime κ' 16 := by
      have : Nat.Coprime κ' (2 ^ 4) :=
        (Nat.coprime_pow_right_iff (by decide : 0 < (4 : ℕ)) κ' 2).mpr hc2
      simpa using this
    have h16pow : 16 ∣ 2 ^ v :=
      Nat.Coprime.dvd_of_dvd_mul_left (Nat.coprime_comm.mp hc16) hdiv
    have hpow : (2 : ℕ) ^ 4 ∣ (2 : ℕ) ^ v := by simpa using h16pow
    exact (Nat.pow_dvd_pow_iff_le_right (by decide : 1 < (2 : ℕ))).1 hpow
  refine ⟨hv, ?_⟩
  have hbound : 3 * κ + 1 < κ * 2 ^ v := by
    have hpow : 16 ≤ 2 ^ v := by
      have : (2 : ℕ) ^ 4 ≤ (2 : ℕ) ^ v :=
        Nat.pow_le_pow_right (by decide : 0 < (2 : ℕ)) hv
      simpa using this
    have h16 : 3 * κ + 1 < κ * 16 := by omega
    exact lt_of_lt_of_le h16 (Nat.mul_le_mul_left κ hpow)
  have : κ' * 2 ^ v < κ * 2 ^ v := by simpa [hExact] using hbound
  exact Nat.lt_of_mul_lt_mul_right this


/-! ## Half-step prison {7,15} — valuations and images [A] -/

/--
`[A]` κ ≡ 7 (mod 16): `3κ+1` is divisible by 2 but not by 4.
-/
theorem two_dvd_not_four_of_mod16_seven {κ : ℕ} (h : κ % 16 = 7) :
    2 ∣ 3 * κ + 1 ∧ ¬4 ∣ 3 * κ + 1 := by
  constructor <;> omega

/--
`[A]` κ ≡ 7 (mod 16) ⇒ `padicValNat 2 (3κ+1) = 1`.
-/
theorem mod16_seven_v2_eq_one {κ : ℕ} (h : κ % 16 = 7) :
    padicValNat 2 (3 * κ + 1) = 1 := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h2dvd : 2 ∣ 3 * κ + 1 := by omega
  have h4not : ¬4 ∣ 3 * κ + 1 := by omega
  have h1le : 1 ≤ padicValNat 2 (3 * κ + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h2dvd)
  have hnot2le : ¬2 ≤ padicValNat 2 (3 * κ + 1) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).2 (by simpa using h2le))
  omega

/--
`[A]` After the forced half-step from κ ≡ 15 (mod 16), the image residue is
`7` or `15` (the {7,15}-prison).
-/
theorem mod16_fifteen_half_image {κ : ℕ} (h : κ % 16 = 15) :
    ((3 * κ + 1) / 2) % 16 = 7 ∨ ((3 * κ + 1) / 2) % 16 = 15 := by
  omega

/--
`[A]` After the forced half-step from κ ≡ 7 (mod 16), the image residue is
`3` or `11`.
-/
theorem mod16_seven_half_image {κ : ℕ} (h : κ % 16 = 7) :
    ((3 * κ + 1) / 2) % 16 = 3 ∨ ((3 * κ + 1) / 2) % 16 = 11 := by
  omega

/--
`[A under H]` κ ≡ 7 (mod 16) forces half-step ascent `v = 1` and `κ < κ'`.
-/
theorem mod16_seven_normHyp_ascent
    {κ κ' v : ℕ} (h16 : κ % 16 = 7)
    (H : SyracuseNormHypothesis κ κ' v) (hκ : 0 < κ) :
    v = 1 ∧ κ < κ' := by
  have ⟨_, h4not⟩ := two_dvd_not_four_of_mod16_seven h16
  have hv1 : v = 1 := by
    have hvpos := H.v_pos
    have hExact := H.step_exact
    obtain ⟨v', rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hvpos)
    cases v' with
    | zero => rfl
    | succ v'' =>
      have h4pow : 4 ∣ (2 : ℕ) ^ (v'' + 2) := ⟨(2 : ℕ) ^ v'', by ring⟩
      have h4mul : 4 ∣ κ' * 2 ^ (v'' + 2) := dvd_mul_of_dvd_right h4pow κ'
      have h4step : 4 ∣ 3 * κ + 1 := by simpa [hExact] using h4mul
      exact (h4not h4step).elim
  refine ⟨hv1, ?_⟩
  have H1 : SyracuseNormHypothesis κ κ' 1 := by simpa [hv1] using H
  exact half_step_intermediate_ascent (toHalfStep_of_normHyp_v1 H1) hκ

/--
`[A under H]` Image of a class-15 accelerated step lands in the {7,15}-prison.
-/
theorem mod16_fifteen_normHyp_image
    {κ κ' v : ℕ} (h16 : κ % 16 = 15)
    (H : SyracuseNormHypothesis κ κ' v) :
    v = 1 ∧ (κ' % 16 = 7 ∨ κ' % 16 = 15) := by
  have ⟨hv1, _⟩ :=
    mod16_fifteen_normHyp_ascent h16 H (by
      have : OddCoreEmbeddable κ := H.embeddable_pre
      -- κ coprime to 6 ⇒ κ ≠ 0
      exact Nat.pos_of_ne_zero (fun h0 => by
        have : Nat.gcd κ 6 = 1 := this
        simp [h0] at this))
  refine ⟨hv1, ?_⟩
  have H1 : SyracuseNormHypothesis κ κ' 1 := by simpa [hv1] using H
  have hκ' : κ' = (3 * κ + 1) / 2 := (toHalfStep_of_normHyp_v1 H1).half_step
  have him := mod16_fifteen_half_image h16
  simpa [hκ'] using him

/--
`[A under H]` Image of a class-7 accelerated step lands in {3,11}.
-/
theorem mod16_seven_normHyp_image
    {κ κ' v : ℕ} (h16 : κ % 16 = 7)
    (H : SyracuseNormHypothesis κ κ' v) :
    v = 1 ∧ (κ' % 16 = 3 ∨ κ' % 16 = 11) := by
  have ⟨hv1, _⟩ :=
    mod16_seven_normHyp_ascent h16 H (by
      exact Nat.pos_of_ne_zero (fun h0 => by
        have : Nat.gcd κ 6 = 1 := H.embeddable_pre
        simp [h0] at this))
  refine ⟨hv1, ?_⟩
  have H1 : SyracuseNormHypothesis κ κ' 1 := by simpa [hv1] using H
  have hκ' : κ' = (3 * κ + 1) / 2 := (toHalfStep_of_normHyp_v1 H1).half_step
  have him := mod16_seven_half_image h16
  simpa [hκ'] using him


/-! ## Exact `m mod 2` half-step split on prison APs [A] -/

/--
`[A]` κ ≡ 15 (mod 16) and `Even (κ / 16)` ⇒ half-step lands in residue 7.
Writing κ = 16m+15 with m even: `((3κ+1)/2) ≡ 7 (mod 16)`.
-/
theorem mod16_fifteen_half_image_of_even_quot {κ : ℕ}
    (h : κ % 16 = 15) (heven : Even (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 7 := by
  have hm : (κ / 16) % 2 = 0 := Nat.even_iff.mp heven
  omega

/--
`[A]` κ ≡ 15 (mod 16) and `Odd (κ / 16)` ⇒ half-step lands in residue 15
(prison self-loop).
-/
theorem mod16_fifteen_half_image_of_odd_quot {κ : ℕ}
    (h : κ % 16 = 15) (hodd : Odd (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 15 := by
  have hm : (κ / 16) % 2 = 1 := Nat.odd_iff.mp hodd
  omega

/--
`[A]` Exact branch: half-step from class 15 hits 7 iff the quotient `κ / 16` is even.
-/
theorem mod16_fifteen_half_image_iff_even_quot {κ : ℕ} (h : κ % 16 = 15) :
    ((3 * κ + 1) / 2) % 16 = 7 ↔ Even (κ / 16) := by
  constructor
  · intro h7
    by_contra hne
    have hodd : Odd (κ / 16) := Nat.not_even_iff_odd.mp hne
    have h15 := mod16_fifteen_half_image_of_odd_quot h hodd
    omega
  · intro heven
    exact mod16_fifteen_half_image_of_even_quot h heven

/--
`[A]` κ ≡ 7 (mod 16) and `Even (κ / 16)` ⇒ half-step lands in residue 11.
-/
theorem mod16_seven_half_image_of_even_quot {κ : ℕ}
    (h : κ % 16 = 7) (heven : Even (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 11 := by
  have hm : (κ / 16) % 2 = 0 := Nat.even_iff.mp heven
  omega

/--
`[A]` κ ≡ 7 (mod 16) and `Odd (κ / 16)` ⇒ half-step lands in residue 3.
-/
theorem mod16_seven_half_image_of_odd_quot {κ : ℕ}
    (h : κ % 16 = 7) (hodd : Odd (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 3 := by
  have hm : (κ / 16) % 2 = 1 := Nat.odd_iff.mp hodd
  omega

/--
`[A]` Exact branch: half-step from class 7 hits 11 iff the quotient `κ / 16` is even.
-/
theorem mod16_seven_half_image_iff_even_quot {κ : ℕ} (h : κ % 16 = 7) :
    ((3 * κ + 1) / 2) % 16 = 11 ↔ Even (κ / 16) := by
  constructor
  · intro h11
    by_contra hne
    have hodd : Odd (κ / 16) := Nat.not_even_iff_odd.mp hne
    have h3 := mod16_seven_half_image_of_odd_quot h hodd
    omega
  · intro heven
    exact mod16_seven_half_image_of_even_quot h heven


/-! ## Exit channels {3,11} — valuations, images, `m mod 2` split [A] -/

/-- `[A]` κ ≡ 3 (mod 16): half-step valuation (`2 ∣` but not `4 ∣`). -/
theorem two_dvd_not_four_of_mod16_three {κ : ℕ} (h : κ % 16 = 3) :
    2 ∣ 3 * κ + 1 ∧ ¬4 ∣ 3 * κ + 1 := by
  constructor <;> omega

/-- `[A]` κ ≡ 3 (mod 16) ⇒ `padicValNat 2 (3κ+1) = 1`. -/
theorem mod16_three_v2_eq_one {κ : ℕ} (h : κ % 16 = 3) :
    padicValNat 2 (3 * κ + 1) = 1 := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h2dvd : 2 ∣ 3 * κ + 1 := by omega
  have h4not : ¬4 ∣ 3 * κ + 1 := by omega
  have h1le : 1 ≤ padicValNat 2 (3 * κ + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h2dvd)
  have hnot2le : ¬2 ≤ padicValNat 2 (3 * κ + 1) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).2 (by simpa using h2le))
  omega

/-- `[A]` κ ≡ 11 (mod 16): half-step valuation. -/
theorem two_dvd_not_four_of_mod16_eleven {κ : ℕ} (h : κ % 16 = 11) :
    2 ∣ 3 * κ + 1 ∧ ¬4 ∣ 3 * κ + 1 := by
  constructor <;> omega

/-- `[A]` κ ≡ 11 (mod 16) ⇒ `padicValNat 2 (3κ+1) = 1`. -/
theorem mod16_eleven_v2_eq_one {κ : ℕ} (h : κ % 16 = 11) :
    padicValNat 2 (3 * κ + 1) = 1 := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h2dvd : 2 ∣ 3 * κ + 1 := by omega
  have h4not : ¬4 ∣ 3 * κ + 1 := by omega
  have h1le : 1 ≤ padicValNat 2 (3 * κ + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h2dvd)
  have hnot2le : ¬2 ≤ padicValNat 2 (3 * κ + 1) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).2 (by simpa using h2le))
  omega

/-- `[A]` Half-step image set from class 3: {5,13}. -/
theorem mod16_three_half_image {κ : ℕ} (h : κ % 16 = 3) :
    ((3 * κ + 1) / 2) % 16 = 5 ∨ ((3 * κ + 1) / 2) % 16 = 13 := by
  omega

/-- `[A]` Half-step image set from class 11: {1,9}. -/
theorem mod16_eleven_half_image {κ : ℕ} (h : κ % 16 = 11) :
    ((3 * κ + 1) / 2) % 16 = 1 ∨ ((3 * κ + 1) / 2) % 16 = 9 := by
  omega

theorem mod16_three_half_image_of_even_quot {κ : ℕ}
    (h : κ % 16 = 3) (heven : Even (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 5 := by
  have hm : (κ / 16) % 2 = 0 := Nat.even_iff.mp heven
  omega

theorem mod16_three_half_image_of_odd_quot {κ : ℕ}
    (h : κ % 16 = 3) (hodd : Odd (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 13 := by
  have hm : (κ / 16) % 2 = 1 := Nat.odd_iff.mp hodd
  omega

theorem mod16_three_half_image_iff_even_quot {κ : ℕ} (h : κ % 16 = 3) :
    ((3 * κ + 1) / 2) % 16 = 5 ↔ Even (κ / 16) := by
  constructor
  · intro h5
    by_contra hne
    have hodd : Odd (κ / 16) := Nat.not_even_iff_odd.mp hne
    have := mod16_three_half_image_of_odd_quot h hodd
    omega
  · intro heven
    exact mod16_three_half_image_of_even_quot h heven

theorem mod16_eleven_half_image_of_even_quot {κ : ℕ}
    (h : κ % 16 = 11) (heven : Even (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 1 := by
  have hm : (κ / 16) % 2 = 0 := Nat.even_iff.mp heven
  omega

theorem mod16_eleven_half_image_of_odd_quot {κ : ℕ}
    (h : κ % 16 = 11) (hodd : Odd (κ / 16)) :
    ((3 * κ + 1) / 2) % 16 = 9 := by
  have hm : (κ / 16) % 2 = 1 := Nat.odd_iff.mp hodd
  omega

theorem mod16_eleven_half_image_iff_even_quot {κ : ℕ} (h : κ % 16 = 11) :
    ((3 * κ + 1) / 2) % 16 = 1 ↔ Even (κ / 16) := by
  constructor
  · intro h1
    by_contra hne
    have hodd : Odd (κ / 16) := Nat.not_even_iff_odd.mp hne
    have := mod16_eleven_half_image_of_odd_quot h hodd
    omega
  · intro heven
    exact mod16_eleven_half_image_of_even_quot h heven

/-- Shared half-step ascent proof from `2 ∣` / `¬4 ∣`. -/
private theorem half_ascent_of_two_not_four
    {κ κ' v : ℕ} (h4not : ¬4 ∣ 3 * κ + 1)
    (H : SyracuseNormHypothesis κ κ' v) (hκ : 0 < κ) :
    v = 1 ∧ κ < κ' := by
  have hv1 : v = 1 := by
    have hvpos := H.v_pos
    have hExact := H.step_exact
    obtain ⟨v', rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hvpos)
    cases v' with
    | zero => rfl
    | succ v'' =>
      have h4pow : 4 ∣ (2 : ℕ) ^ (v'' + 2) := ⟨(2 : ℕ) ^ v'', by ring⟩
      have h4mul : 4 ∣ κ' * 2 ^ (v'' + 2) := dvd_mul_of_dvd_right h4pow κ'
      have h4step : 4 ∣ 3 * κ + 1 := by simpa [hExact] using h4mul
      exact (h4not h4step).elim
  refine ⟨hv1, ?_⟩
  have H1 : SyracuseNormHypothesis κ κ' 1 := by simpa [hv1] using H
  exact half_step_intermediate_ascent (toHalfStep_of_normHyp_v1 H1) hκ

/-- `[A under H]` κ ≡ 3 (mod 16) ⇒ half-step ascent. -/
theorem mod16_three_normHyp_ascent
    {κ κ' v : ℕ} (h16 : κ % 16 = 3)
    (H : SyracuseNormHypothesis κ κ' v) (hκ : 0 < κ) :
    v = 1 ∧ κ < κ' :=
  half_ascent_of_two_not_four (two_dvd_not_four_of_mod16_three h16).2 H hκ

/-- `[A under H]` κ ≡ 11 (mod 16) ⇒ half-step ascent. -/
theorem mod16_eleven_normHyp_ascent
    {κ κ' v : ℕ} (h16 : κ % 16 = 11)
    (H : SyracuseNormHypothesis κ κ' v) (hκ : 0 < κ) :
    v = 1 ∧ κ < κ' :=
  half_ascent_of_two_not_four (two_dvd_not_four_of_mod16_eleven h16).2 H hκ

/-- `[A under H]` Image of class 3 lands in {5,13}. -/
theorem mod16_three_normHyp_image
    {κ κ' v : ℕ} (h16 : κ % 16 = 3)
    (H : SyracuseNormHypothesis κ κ' v) :
    v = 1 ∧ (κ' % 16 = 5 ∨ κ' % 16 = 13) := by
  have ⟨hv1, _⟩ := mod16_three_normHyp_ascent h16 H (by
    exact Nat.pos_of_ne_zero (fun h0 => by
      have : Nat.gcd κ 6 = 1 := H.embeddable_pre
      simp [h0] at this))
  refine ⟨hv1, ?_⟩
  have H1 : SyracuseNormHypothesis κ κ' 1 := by simpa [hv1] using H
  have hκ' : κ' = (3 * κ + 1) / 2 := (toHalfStep_of_normHyp_v1 H1).half_step
  simpa [hκ'] using mod16_three_half_image h16

/-- `[A under H]` Image of class 11 lands in {1,9}. -/
theorem mod16_eleven_normHyp_image
    {κ κ' v : ℕ} (h16 : κ % 16 = 11)
    (H : SyracuseNormHypothesis κ κ' v) :
    v = 1 ∧ (κ' % 16 = 1 ∨ κ' % 16 = 9) := by
  have ⟨hv1, _⟩ := mod16_eleven_normHyp_ascent h16 H (by
    exact Nat.pos_of_ne_zero (fun h0 => by
      have : Nat.gcd κ 6 = 1 := H.embeddable_pre
      simp [h0] at this))
  refine ⟨hv1, ?_⟩
  have H1 : SyracuseNormHypothesis κ κ' 1 := by simpa [hv1] using H
  have hκ' : κ' = (3 * κ + 1) / 2 := (toHalfStep_of_normHyp_v1 H1).half_step
  simpa [hκ'] using mod16_eleven_half_image h16

/-! ## Exact finite 50/50 counts on APs [A] (not asymptotic measure) -/

/-- Exactly half of `{0,…,2M-1}` is even. -/
theorem card_even_in_range_two_mul (M : ℕ) :
    ((Finset.range (2 * M)).filter fun n => Even n).card = M := by
  classical
  have hset :
      (Finset.range (2 * M)).filter (fun n => Even n) =
        (Finset.range M).image (fun i => 2 * i) := by
    ext n
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_image]
    constructor
    · intro ⟨hn, he⟩
      have hm : n % 2 = 0 := Nat.even_iff.mp he
      refine ⟨n / 2, by omega, ?_⟩
      exact Nat.mul_div_cancel' (Nat.dvd_iff_mod_eq_zero.mpr hm)
    · rintro ⟨k, hk, hkn⟩
      rw [← hkn]
      exact ⟨by omega, even_two_mul k⟩
  rw [hset, Finset.card_image_of_injective _ (fun a b hab => by omega)]
  exact Finset.card_range M

/--
`[A]` Among the first `2M` indices m of the AP `16m+15`, exactly `M` map to residue 7
(the even-quotient branch). Exact finite half-count — not a global density theorem.
-/
theorem fifteen_AP_image7_card (M : ℕ) :
    ((Finset.range (2 * M)).filter fun m =>
        ((3 * (16 * m + 15) + 1) / 2) % 16 = 7).card = M := by
  classical
  have hEq :
      ((Finset.range (2 * M)).filter fun m =>
          ((3 * (16 * m + 15) + 1) / 2) % 16 = 7) =
        (Finset.range (2 * M)).filter fun m => Even m := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_range, and_congr_right_iff]
    intro hm
    have h16 : (16 * m + 15) % 16 = 15 := by omega
    have hquot : (16 * m + 15) / 16 = m := by omega
    -- iff with Even ((16m+15)/16) = Even m
    constructor
    · intro h7
      have : Even ((16 * m + 15) / 16) := (mod16_fifteen_half_image_iff_even_quot h16).1 h7
      simpa [hquot] using this
    · intro he
      have : Even ((16 * m + 15) / 16) := by simpa [hquot] using he
      exact (mod16_fifteen_half_image_iff_even_quot h16).2 this
  rw [hEq, card_even_in_range_two_mul]

/-- Same half-count for the class-7 AP mapping to residue 11. -/
theorem seven_AP_image11_card (M : ℕ) :
    ((Finset.range (2 * M)).filter fun m =>
        ((3 * (16 * m + 7) + 1) / 2) % 16 = 11).card = M := by
  classical
  have hEq :
      ((Finset.range (2 * M)).filter fun m =>
          ((3 * (16 * m + 7) + 1) / 2) % 16 = 11) =
        (Finset.range (2 * M)).filter fun m => Even m := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_range, and_congr_right_iff]
    intro hm
    have h16 : (16 * m + 7) % 16 = 7 := by omega
    have hquot : (16 * m + 7) / 16 = m := by omega
    constructor
    · intro h11
      have : Even ((16 * m + 7) / 16) := (mod16_seven_half_image_iff_even_quot h16).1 h11
      simpa [hquot] using this
    · intro he
      have : Even ((16 * m + 7) / 16) := by simpa [hquot] using he
      exact (mod16_seven_half_image_iff_even_quot h16).2 this
  rw [hEq, card_even_in_range_two_mul]

/-- Half-count for exit channel 3 → 5. -/
theorem three_AP_image5_card (M : ℕ) :
    ((Finset.range (2 * M)).filter fun m =>
        ((3 * (16 * m + 3) + 1) / 2) % 16 = 5).card = M := by
  classical
  have hEq :
      ((Finset.range (2 * M)).filter fun m =>
          ((3 * (16 * m + 3) + 1) / 2) % 16 = 5) =
        (Finset.range (2 * M)).filter fun m => Even m := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_range, and_congr_right_iff]
    intro hm
    have h16 : (16 * m + 3) % 16 = 3 := by omega
    have hquot : (16 * m + 3) / 16 = m := by omega
    constructor
    · intro h5
      have : Even ((16 * m + 3) / 16) := (mod16_three_half_image_iff_even_quot h16).1 h5
      simpa [hquot] using this
    · intro he
      have : Even ((16 * m + 3) / 16) := by simpa [hquot] using he
      exact (mod16_three_half_image_iff_even_quot h16).2 this
  rw [hEq, card_even_in_range_two_mul]

/-- Half-count for exit channel 11 → 1. -/
theorem eleven_AP_image1_card (M : ℕ) :
    ((Finset.range (2 * M)).filter fun m =>
        ((3 * (16 * m + 11) + 1) / 2) % 16 = 1).card = M := by
  classical
  have hEq :
      ((Finset.range (2 * M)).filter fun m =>
          ((3 * (16 * m + 11) + 1) / 2) % 16 = 1) =
        (Finset.range (2 * M)).filter fun m => Even m := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_range, and_congr_right_iff]
    intro hm
    have h16 : (16 * m + 11) % 16 = 11 := by omega
    have hquot : (16 * m + 11) / 16 = m := by omega
    constructor
    · intro h1
      have : Even ((16 * m + 11) / 16) := (mod16_eleven_half_image_iff_even_quot h16).1 h1
      simpa [hquot] using this
    · intro he
      have : Even ((16 * m + 11) / 16) := by simpa [hquot] using he
      exact (mod16_eleven_half_image_iff_even_quot h16).2 this
  rw [hEq, card_even_in_range_two_mul]


/-! ## Remaining odd residues 1, 9, 13 — exact ν₂ [A] -/

/-- `[A]` κ ≡ 1 (mod 16) ⇒ `padicValNat 2 (3κ+1) = 2`. -/
theorem mod16_one_v2_eq_two {κ : ℕ} (h : κ % 16 = 1) :
    padicValNat 2 (3 * κ + 1) = 2 := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h4dvd : 4 ∣ 3 * κ + 1 := by omega
  have h8not : ¬8 ∣ 3 * κ + 1 := by omega
  have h2le : 2 ≤ padicValNat 2 (3 * κ + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h4dvd)
  have hnot3le : ¬3 ≤ padicValNat 2 (3 * κ + 1) := by
    intro h3le
    exact h8not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).2 (by simpa using h3le))
  omega

/-- `[A]` κ ≡ 9 (mod 16) ⇒ `padicValNat 2 (3κ+1) = 2`. -/
theorem mod16_nine_v2_eq_two {κ : ℕ} (h : κ % 16 = 9) :
    padicValNat 2 (3 * κ + 1) = 2 := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h4dvd : 4 ∣ 3 * κ + 1 := by omega
  have h8not : ¬8 ∣ 3 * κ + 1 := by omega
  have h2le : 2 ≤ padicValNat 2 (3 * κ + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h4dvd)
  have hnot3le : ¬3 ≤ padicValNat 2 (3 * κ + 1) := by
    intro h3le
    exact h8not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).2 (by simpa using h3le))
  omega

/-- `[A]` κ ≡ 13 (mod 16) ⇒ `padicValNat 2 (3κ+1) = 3`. -/
theorem mod16_thirteen_v2_eq_three {κ : ℕ} (h : κ % 16 = 13) :
    padicValNat 2 (3 * κ + 1) = 3 := by
  have hn : 3 * κ + 1 ≠ 0 := by omega
  have h8dvd : 8 ∣ 3 * κ + 1 := by omega
  have h16not : ¬16 ∣ 3 * κ + 1 := by omega
  have h3le : 3 ≤ padicValNat 2 (3 * κ + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).1 (by simpa using h8dvd)
  have hnot4le : ¬4 ≤ padicValNat 2 (3 * κ + 1) := by
    intro h4le
    exact h16not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * κ + 1) hn).2 (by simpa using h4le))
  omega

/-! ## Usable API: valuation table + descent under H [A] -/

/--
Lower bound on the first accelerated valuation forced by an odd residue mod 16.

* `1,9 ↦ 2`
* `3,7,11,15 ↦ 1`
* `13 ↦ 3`
* `5 ↦ 4`
-/
def mod16OddV2LowerBound : ℕ → ℕ
  | 1 | 9 => 2
  | 3 | 7 | 11 | 15 => 1
  | 5 => 4
  | 13 => 3
  | _ => 0

/--
`[A under H]` If the accelerated step has `v ≥ 2` and `κ > 1`, then the core descends.
-/
theorem normHyp_descent_of_v_ge_two
    {κ κ' v : ℕ} (H : SyracuseNormHypothesis κ κ' v)
    (hv : 2 ≤ v) (hκ : 1 < κ) :
    κ' < κ := by
  have hExact := H.step_exact
  have hpow : 4 ≤ 2 ^ v := by
    have : (2 : ℕ) ^ 2 ≤ (2 : ℕ) ^ v :=
      Nat.pow_le_pow_right (by decide : 0 < (2 : ℕ)) hv
    simpa using this
  have hbound : 3 * κ + 1 < κ * 2 ^ v := by
    have : 3 * κ + 1 < κ * 4 := by omega
    exact lt_of_lt_of_le this (Nat.mul_le_mul_left κ hpow)
  have : κ' * 2 ^ v < κ * 2 ^ v := by simpa [hExact] using hbound
  exact Nat.lt_of_mul_lt_mul_right this

/-- Recover exact `v = a` from `2^a ∣ 3κ+1` and `¬2^(a+1) ∣ 3κ+1` under H. -/
private theorem v_eq_from_pow_dvd_bounds
    {κ κ' v a : ℕ} (H : SyracuseNormHypothesis κ κ' v)
    (hLo : 2 ^ a ∣ 3 * κ + 1) (hHi : ¬2 ^ (a + 1) ∣ 3 * κ + 1)
    (ha : 0 < a) :
    v = a := by
  have hExact := H.step_exact
  have hκ'odd : Odd κ' := odd_of_embeddable H.embeddable_post
  have hc2 : Nat.Coprime κ' 2 := Odd.coprime_two_right hκ'odd
  have hv_ge : a ≤ v := by
    have hdiv : 2 ^ a ∣ κ' * 2 ^ v := by simpa [hExact] using hLo
    have hc : Nat.Coprime κ' (2 ^ a) :=
      (Nat.coprime_pow_right_iff ha κ' 2).mpr hc2
    have hpow : 2 ^ a ∣ 2 ^ v :=
      Nat.Coprime.dvd_of_dvd_mul_left (Nat.coprime_comm.mp hc) hdiv
    exact (Nat.pow_dvd_pow_iff_le_right (by decide : 1 < (2 : ℕ))).1 hpow
  have hv_lt : v < a + 1 := by
    by_contra hge
    push Not at hge
    have : a + 1 ≤ v := by omega
    have hpow : 2 ^ (a + 1) ∣ 2 ^ v :=
      (Nat.pow_dvd_pow_iff_le_right (by decide : 1 < (2 : ℕ))).2 this
    have : 2 ^ (a + 1) ∣ κ' * 2 ^ v := dvd_mul_of_dvd_right hpow κ'
    have : 2 ^ (a + 1) ∣ 3 * κ + 1 := by simpa [hExact] using this
    exact hHi this
  omega

/-- `[A under H]` κ ≡ 1 ⇒ `v = 2`; if `κ > 1` then descent. -/
theorem mod16_one_normHyp_step
    {κ κ' v : ℕ} (h16 : κ % 16 = 1)
    (H : SyracuseNormHypothesis κ κ' v) :
    v = 2 ∧ (1 < κ → κ' < κ) := by
  have hv : v = 2 :=
    v_eq_from_pow_dvd_bounds H
      (by omega : 2 ^ 2 ∣ 3 * κ + 1)
      (by omega : ¬2 ^ (2 + 1) ∣ 3 * κ + 1)
      (by decide)
  refine ⟨hv, fun hκ =>
    normHyp_descent_of_v_ge_two (by simpa [hv] using H) (by decide) hκ⟩

/-- `[A under H]` κ ≡ 9 ⇒ `v = 2`; if `κ > 1` then descent. -/
theorem mod16_nine_normHyp_step
    {κ κ' v : ℕ} (h16 : κ % 16 = 9)
    (H : SyracuseNormHypothesis κ κ' v) :
    v = 2 ∧ (1 < κ → κ' < κ) := by
  have hv : v = 2 :=
    v_eq_from_pow_dvd_bounds H
      (by omega : 2 ^ 2 ∣ 3 * κ + 1)
      (by omega : ¬2 ^ (2 + 1) ∣ 3 * κ + 1)
      (by decide)
  refine ⟨hv, fun hκ =>
    normHyp_descent_of_v_ge_two (by simpa [hv] using H) (by decide) hκ⟩

/-- `[A under H]` κ ≡ 13 ⇒ `v = 3` and descent for `κ > 0`. -/
theorem mod16_thirteen_normHyp_step
    {κ κ' v : ℕ} (h16 : κ % 16 = 13)
    (H : SyracuseNormHypothesis κ κ' v) (hκ : 0 < κ) :
    v = 3 ∧ κ' < κ := by
  have hv : v = 3 :=
    v_eq_from_pow_dvd_bounds H
      (by omega : 2 ^ 3 ∣ 3 * κ + 1)
      (by omega : ¬2 ^ (3 + 1) ∣ 3 * κ + 1)
      (by decide)
  refine ⟨hv, ?_⟩
  have hExact := H.step_exact
  -- rewrite with v=3
  have hExact3 : 3 * κ + 1 = κ' * 2 ^ 3 := by simpa [hv] using hExact
  have hbound : 3 * κ + 1 < κ * 2 ^ 3 := by omega
  have : κ' * 2 ^ 3 < κ * 2 ^ 3 := by simpa [hExact3] using hbound
  exact Nat.lt_of_mul_lt_mul_right this

/--
`[A]` Dispatcher: for odd κ,
`mod16OddV2LowerBound (κ % 16) ≤ ν₂(3κ+1)`.
-/
theorem mod16_odd_v2_ge_lowerBound {κ : ℕ} (hodd : Odd κ) :
    mod16OddV2LowerBound (κ % 16) ≤ padicValNat 2 (3 * κ + 1) := by
  have hrmod : κ % 16 % 2 = 1 := by
    have : κ % 2 = 1 := Nat.odd_iff.mp hodd
    omega
  match hr : κ % 16 with
  | 1 =>
    have h : κ % 16 = 1 := by omega
    simpa [mod16OddV2LowerBound, hr, mod16_one_v2_eq_two h]
  | 3 =>
    have h : κ % 16 = 3 := by omega
    simpa [mod16OddV2LowerBound, hr, mod16_three_v2_eq_one h]
  | 5 =>
    have h : κ % 16 = 5 := by omega
    simpa [mod16OddV2LowerBound, hr] using mod16_five_v2_ge_four h
  | 7 =>
    have h : κ % 16 = 7 := by omega
    simpa [mod16OddV2LowerBound, hr, mod16_seven_v2_eq_one h]
  | 9 =>
    have h : κ % 16 = 9 := by omega
    simpa [mod16OddV2LowerBound, hr, mod16_nine_v2_eq_two h]
  | 11 =>
    have h : κ % 16 = 11 := by omega
    simpa [mod16OddV2LowerBound, hr, mod16_eleven_v2_eq_one h]
  | 13 =>
    have h : κ % 16 = 13 := by omega
    simpa [mod16OddV2LowerBound, hr, mod16_thirteen_v2_eq_three h]
  | 15 =>
    have h : κ % 16 = 15 := by omega
    simpa [mod16OddV2LowerBound, hr, mod16_fifteen_v2_eq_one h]
  | 0 | 2 | 4 | 6 | 8 | 10 | 12 | 14 =>
    omega
  | n + 16 =>
    have : κ % 16 < 16 := Nat.mod_lt κ (by decide)
    omega

/--
`[A under H]` Master step classifier by `κ % 16` (odd embeddable cores).

Returns the forced valuation together with ascent/descent polarity:
* residues in `{3,7,11,15}`: `v=1` and ascent (`κ < κ'`) for `κ > 0`
* residues `1,9`: `v=2` and descent for `κ > 1`
* residue `13`: `v=3` and descent for `κ > 0`
* residue `5`: `v ≥ 4` and descent for `κ > 0`
-/
theorem mod16_normHyp_firstStep
    {κ κ' v : ℕ} (H : SyracuseNormHypothesis κ κ' v) (hκpos : 0 < κ) :
    (κ % 16 = 3 ∨ κ % 16 = 7 ∨ κ % 16 = 11 ∨ κ % 16 = 15) ∧ v = 1 ∧ κ < κ'
      ∨
    (κ % 16 = 1 ∨ κ % 16 = 9) ∧ v = 2 ∧ (1 < κ → κ' < κ)
      ∨
    κ % 16 = 13 ∧ v = 3 ∧ κ' < κ
      ∨
    κ % 16 = 5 ∧ 4 ≤ v ∧ κ' < κ := by
  have hodd : Odd κ := odd_of_embeddable H.embeddable_pre
  have hrmod : κ % 16 % 2 = 1 := by
    have : κ % 2 = 1 := Nat.odd_iff.mp hodd
    omega
  match hr : κ % 16 with
  | 3 =>
    have ⟨hv, hasc⟩ := mod16_three_normHyp_ascent (by omega) H hκpos
    exact Or.inl ⟨Or.inl rfl, hv, hasc⟩
  | 7 =>
    have ⟨hv, hasc⟩ := mod16_seven_normHyp_ascent (by omega) H hκpos
    exact Or.inl ⟨Or.inr (Or.inl rfl), hv, hasc⟩
  | 11 =>
    have ⟨hv, hasc⟩ := mod16_eleven_normHyp_ascent (by omega) H hκpos
    exact Or.inl ⟨Or.inr (Or.inr (Or.inl rfl)), hv, hasc⟩
  | 15 =>
    have ⟨hv, hasc⟩ := mod16_fifteen_normHyp_ascent (by omega) H hκpos
    exact Or.inl ⟨Or.inr (Or.inr (Or.inr rfl)), hv, hasc⟩
  | 1 =>
    have ⟨hv, hdesc⟩ := mod16_one_normHyp_step (by omega) H
    exact Or.inr (Or.inl ⟨Or.inl rfl, hv, hdesc⟩)
  | 9 =>
    have ⟨hv, hdesc⟩ := mod16_nine_normHyp_step (by omega) H
    exact Or.inr (Or.inl ⟨Or.inr rfl, hv, hdesc⟩)
  | 13 =>
    have ⟨hv, hdesc⟩ := mod16_thirteen_normHyp_step (by omega) H hκpos
    exact Or.inr (Or.inr (Or.inl ⟨rfl, hv, hdesc⟩))
  | 5 =>
    have ⟨hv, hdesc⟩ := mod16_five_normHyp_descent (by omega) H hκpos
    exact Or.inr (Or.inr (Or.inr ⟨rfl, hv, hdesc⟩))
  | 0 | 2 | 4 | 6 | 8 | 10 | 12 | 14 =>
    omega
  | n + 16 =>
    have : κ % 16 < 16 := Nat.mod_lt κ (by decide)
    omega

/-! ## NON-CLAIM marker -/

/-- **NON-CLAIM:** multi-step cylinder-tree measure dominance is not formalized here. -/
theorem cylinder_tree_measure_dominance_not_claimed : True := trivial

end CollatzModularV2
end KeplerHurwitz.EABC
