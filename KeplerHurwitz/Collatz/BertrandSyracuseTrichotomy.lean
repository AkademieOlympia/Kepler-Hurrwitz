import Mathlib.Data.Nat.ModEq
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Card
import Mathlib.NumberTheory.Bertrand
import Mathlib.NumberTheory.Padics.PadicVal.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Bertrand–Syracuse prime trichotomy

Standalone finite classification: for `n > 1` with `n ≡ 3 (mod 4)`
(equivalently odd `n` with `v₂(3n+1) = 1`), the odd Syracuse successor
`T(n) = (3n+1)/2` lies strictly inside `(n, 2n]` and therefore induces a
canonical partition of the primes in the Bertrand interval `(n, 2n]`.

Terminology: `T(n)` is the **orbit-determined partition point** of the window
`(n, 2n]`. In the broader EABC programme this may be regarded as a local
resonance point; that interpretive language is not required for the theorem.

Layers carefully distinguished:
1. Interior landing of `T(n)` (dynamical/arithmetic inequality).
2. Order-theoretic trichotomy of the prime spectrum (linear order).
3. Bertrand non-emptiness of the classified spectrum.

This module makes **no Collatz claim**. ClaimsFreeze false.
-/

set_option autoImplicit false

namespace KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy

open Set Nat

private instance fact_prime_two : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩

/-- Odd Syracuse successor under `v₂(3n+1) = 1`. -/
def syracuseT (n : Nat) : Nat := (3 * n + 1) / 2

/-- Primes in the Bertrand interval `(n, 2n]`. -/
def bertrandPrimeSpectrum (n : Nat) : Set Nat :=
  {p | Nat.Prime p ∧ n < p ∧ p ≤ 2 * n}

/-- Primes strictly left of the orbit-determined partition point. -/
def primesLeft (n : Nat) : Set Nat :=
  {p | Nat.Prime p ∧ n < p ∧ p < syracuseT n}

/-- Landing class: singleton iff `T(n)` is prime, else empty. -/
def primesLanding (n : Nat) : Set Nat :=
  {p | Nat.Prime p ∧ p = syracuseT n}

/-- Primes strictly right of `T(n)` inside `(n, 2n]`. -/
def primesRight (n : Nat) : Set Nat :=
  {p | Nat.Prime p ∧ syracuseT n < p ∧ p ≤ 2 * n}

/-! ### Residue ↔ valuation -/

private theorem n_eq_four_mul_add_three {n : Nat} (hmod : n ≡ 3 [MOD 4]) :
    n = 4 * (n / 4) + 3 := by
  have hn4 : n % 4 = 3 := by simpa [Nat.ModEq] using hmod
  have := Nat.div_add_mod n 4
  omega

theorem padicValNat_eq_one_of_modEq_three
    {n : Nat} (hmod : n ≡ 3 [MOD 4]) :
    padicValNat 2 (3 * n + 1) = 1 := by
  have hn := n_eq_four_mul_add_three hmod
  set k := n / 4 with hk
  have hprod : 3 * n + 1 = 2 * (6 * k + 5) := by
    rw [hn, hk]; ring
  have hE : Even (6 * k) := ⟨3 * k, by ring⟩
  have hodd : Odd (6 * k + 5) := hE.add_odd ⟨2, rfl⟩
  have hne0 : 6 * k + 5 ≠ 0 := by omega
  have hmul :
      padicValNat 2 (2 * (6 * k + 5)) =
        padicValNat 2 2 + padicValNat 2 (6 * k + 5) :=
    padicValNat.mul (p := 2) (by decide : (2 : Nat) ≠ 0) hne0
  have h2 : padicValNat 2 2 = 1 := padicValNat_self (p := 2)
  have hm : padicValNat 2 (6 * k + 5) = 0 :=
    padicValNat.eq_zero_of_not_dvd hodd.not_two_dvd_nat
  calc
    padicValNat 2 (3 * n + 1)
        = padicValNat 2 (2 * (6 * k + 5)) := by rw [hprod]
    _ = 1 + 0 := by rw [hmul, h2, hm]
    _ = 1 := rfl

theorem odd_of_modEq_three {n : Nat} (hmod : n ≡ 3 [MOD 4]) : Odd n := by
  have hn4 : n % 4 = 3 := by simpa [Nat.ModEq] using hmod
  exact Nat.odd_iff.2 (by omega)

theorem modEq_three_of_odd_and_padicValNat_eq_one
    {n : Nat} (hodd : Odd n) (hv : padicValNat 2 (3 * n + 1) = 1) :
    n ≡ 3 [MOD 4] := by
  have hodd2 : n % 2 = 1 := Nat.odd_iff.mp hodd
  have hmod4 : n % 4 = 1 ∨ n % 4 = 3 := by
    have := Nat.mod_lt n (by decide : 0 < 4)
    omega
  rcases hmod4 with h1 | h3
  · set k := n / 4 with hk
    have hn : n = 4 * k + 1 := by
      have := Nat.div_add_mod n 4
      omega
    have hprod : 3 * n + 1 = 2 ^ 2 * (3 * k + 1) := by
      rw [hn, hk]; ring
    have hpow : 2 ^ 2 ∣ 3 * n + 1 := ⟨3 * k + 1, hprod⟩
    have hge : 2 ≤ padicValNat 2 (3 * n + 1) :=
      (padicValNat_dvd_iff_le (a := 3 * n + 1) (Nat.succ_ne_zero _)).1 hpow
    omega
  · simpa [Nat.ModEq] using h3

/-- For odd `n`: `v₂(3n+1) = 1 ↔ n ≡ 3 (mod 4)`. -/
theorem padicValNat_two_three_n_succ_eq_one_iff
    {n : Nat} (hodd : Odd n) :
    padicValNat 2 (3 * n + 1) = 1 ↔ n ≡ 3 [MOD 4] :=
  ⟨modEq_three_of_odd_and_padicValNat_eq_one hodd,
    padicValNat_eq_one_of_modEq_three⟩

/-! ### Interior landing lemma -/

theorem syracuseT_mul_two
    {n : Nat} (hmod : n ≡ 3 [MOD 4]) :
    2 * syracuseT n = 3 * n + 1 := by
  have hv := padicValNat_eq_one_of_modEq_three hmod
  have hdiv : 2 ∣ 3 * n + 1 :=
    (dvd_iff_padicValNat_ne_zero (p := 2) (n := 3 * n + 1)
      (Nat.succ_ne_zero _)).2 (by omega)
  obtain ⟨m, hm⟩ := hdiv
  have : syracuseT n = m := by
    simp [syracuseT, hm, Nat.mul_div_right _ (by decide : 0 < 2)]
  omega

/-- Interior landing lemma: `n < T(n) < 2n`. -/
theorem syracuseT_mem_interior
    {n : Nat} (hn : 1 < n) (hmod : n ≡ 3 [MOD 4]) :
    n < syracuseT n ∧ syracuseT n < 2 * n := by
  have h2T := syracuseT_mul_two hmod
  constructor
  · have : 2 * n < 2 * syracuseT n := by rw [h2T]; omega
    omega
  · have : 2 * syracuseT n < 4 * n := by rw [h2T]; omega
    omega

theorem syracuseT_le_two_mul
    {n : Nat} (hn : 1 < n) (hmod : n ≡ 3 [MOD 4]) :
    syracuseT n ≤ 2 * n :=
  Nat.le_of_lt (syracuseT_mem_interior hn hmod).2

/-! ### Order-theoretic prime trichotomy -/

theorem disjoint_primesLeft_primesLanding (n : Nat) :
    Disjoint (primesLeft n) (primesLanding n) := by
  refine disjoint_left.2 ?_
  intro x hxL hxM
  exact (lt_irrefl x) (by simpa [hxM.2] using hxL.2.2)

theorem disjoint_primesLeft_primesRight (n : Nat) :
    Disjoint (primesLeft n) (primesRight n) := by
  refine disjoint_left.2 ?_
  intro x hxL hxR
  exact lt_asymm hxL.2.2 hxR.2.1

theorem disjoint_primesLanding_primesRight (n : Nat) :
    Disjoint (primesLanding n) (primesRight n) := by
  refine disjoint_left.2 ?_
  intro x hxM hxR
  exact (lt_irrefl (syracuseT n)) (by simpa [hxM.2] using hxR.2.1)

/--
Order-theoretic exhaustion: every Bertrand-window prime lies left of, at, or
right of the orbit-determined partition point.
-/
theorem bertrandPrimeSpectrum_eq_union
    {n : Nat} (hn : 1 < n) (hmod : n ≡ 3 [MOD 4]) :
    bertrandPrimeSpectrum n =
      primesLeft n ∪ primesLanding n ∪ primesRight n := by
  obtain ⟨hTn, hTlt⟩ := syracuseT_mem_interior hn hmod
  have hT2 : syracuseT n ≤ 2 * n := Nat.le_of_lt hTlt
  ext p
  constructor
  · intro hp
    rcases lt_trichotomy p (syracuseT n) with hlt | heq | hgt
    · exact Or.inl (Or.inl ⟨hp.1, hp.2.1, hlt⟩)
    · exact Or.inl (Or.inr ⟨hp.1, heq⟩)
    · exact Or.inr ⟨hp.1, hgt, hp.2.2⟩
  · intro hp
    rcases hp with (hL | hM) | hR
    · exact ⟨hL.1, hL.2.1, le_trans (Nat.le_of_lt hL.2.2) hT2⟩
    · exact ⟨hM.1, by simpa [hM.2] using hTn, by simpa [hM.2] using hT2⟩
    · exact ⟨hR.1, lt_trans hTn hR.2.1, hR.2.2⟩

theorem landing_eq_singleton_iff_prime (n : Nat) :
    primesLanding n = {syracuseT n} ↔ Nat.Prime (syracuseT n) := by
  constructor
  · intro h
    have : syracuseT n ∈ primesLanding n := by
      rw [h]; simp
    exact this.1
  · intro hp
    ext p
    constructor
    · intro hpL
      exact hpL.2
    · rintro rfl
      exact ⟨hp, rfl⟩

theorem landing_eq_empty_iff_not_prime (n : Nat) :
    primesLanding n = ∅ ↔ ¬ Nat.Prime (syracuseT n) := by
  constructor
  · intro h hp
    have : syracuseT n ∈ primesLanding n := ⟨hp, rfl⟩
    rw [h] at this
    exact this
  · intro hnp
    ext p
    constructor
    · intro hpL
      exact hnp (hpL.2 ▸ hpL.1)
    · intro hpEmpty
      exact False.elim hpEmpty

theorem primesLanding_subsingleton (n : Nat) :
    (primesLanding n).Subsingleton := by
  intro a ha b hb
  exact ha.2.trans hb.2.symm

theorem landing_ncard_le_one (n : Nat) :
    (primesLanding n).ncard ≤ 1 := by
  rw [ncard_le_one_iff (primesLanding_subsingleton n).finite]
  intro a b ha hb
  exact (primesLanding_subsingleton n) ha hb

/-! ### Bertrand non-emptiness (separate layer) -/

theorem bertrandPrimeSpectrum_nonempty
    {n : Nat} (hn : 1 < n) :
    (bertrandPrimeSpectrum n).Nonempty := by
  obtain ⟨p, hp, hnp, hp2⟩ :=
    Nat.exists_prime_lt_and_le_two_mul n (by omega)
  exact ⟨p, hp, hnp, hp2⟩

theorem union_nonempty_of_bertrand
    {n : Nat} (hn : 1 < n) (hmod : n ≡ 3 [MOD 4]) :
    (primesLeft n ∪ primesLanding n ∪ primesRight n).Nonempty := by
  rw [← bertrandPrimeSpectrum_eq_union hn hmod]
  exact bertrandPrimeSpectrum_nonempty hn

theorem left_or_right_of_landing_empty
    {n : Nat} (hn : 1 < n) (hmod : n ≡ 3 [MOD 4])
    (hM : primesLanding n = ∅) :
    (primesLeft n).Nonempty ∨ (primesRight n).Nonempty := by
  obtain ⟨p, hp⟩ := union_nonempty_of_bertrand hn hmod
  have hp' : p ∈ primesLeft n ∪ primesRight n := by
    simpa [hM] using hp
  exact hp'.elim (fun h => Or.inl ⟨p, h⟩) (fun h => Or.inr ⟨p, h⟩)

/-! ### Package certificate -/

structure BertrandSyracuseTrichotomyCertificate : Prop where
  val_iff_mod :
    ∀ n : Nat, Odd n →
      (padicValNat 2 (3 * n + 1) = 1 ↔ n ≡ 3 [MOD 4])
  interior :
    ∀ n : Nat, 1 < n → n ≡ 3 [MOD 4] →
      n < syracuseT n ∧ syracuseT n < 2 * n
  spectrum_union :
    ∀ n : Nat, 1 < n → n ≡ 3 [MOD 4] →
      bertrandPrimeSpectrum n =
        primesLeft n ∪ primesLanding n ∪ primesRight n
  disjoint_LM : ∀ n, Disjoint (primesLeft n) (primesLanding n)
  disjoint_LR : ∀ n, Disjoint (primesLeft n) (primesRight n)
  disjoint_MR : ∀ n, Disjoint (primesLanding n) (primesRight n)
  landing_singleton :
    ∀ n : Nat, primesLanding n = {syracuseT n} ↔ Nat.Prime (syracuseT n)
  landing_card : ∀ n, (primesLanding n).ncard ≤ 1
  spectrum_nonempty :
    ∀ n : Nat, 1 < n → (bertrandPrimeSpectrum n).Nonempty

theorem bertrandSyracuseTrichotomyCertificate :
    BertrandSyracuseTrichotomyCertificate where
  val_iff_mod := fun _ h => padicValNat_two_three_n_succ_eq_one_iff h
  interior := fun _ hn hmod => syracuseT_mem_interior hn hmod
  spectrum_union := fun _ hn hmod => bertrandPrimeSpectrum_eq_union hn hmod
  disjoint_LM := disjoint_primesLeft_primesLanding
  disjoint_LR := disjoint_primesLeft_primesRight
  disjoint_MR := disjoint_primesLanding_primesRight
  landing_singleton := landing_eq_singleton_iff_prime
  landing_card := landing_ncard_le_one
  spectrum_nonempty := fun _ hn => bertrandPrimeSpectrum_nonempty hn

/-!
## Explicit non-claims

- No statement that Collatz orbits terminate.
- No monotone global descent or stopping-time bound.
- No claim that left/right prime occupancy forces orbit structure.
- No EABC resonance interpretation required for the theorems above.
-/

end KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy
