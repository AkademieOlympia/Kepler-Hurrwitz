import KeplerHurwitz.Collatz.Octonion.OddCoreCocycle
import KeplerHurwitz.CollatzNetDescentMod8

/-!
Modul O2 — Witness-Beweiskette für beliebig lange `ν₂ = 1`-Läufe.

Strikte Reihenfolge (kein Zirkelschluss):
1. Definitionen (`Definitions.lean`: `witnessExponent`, `witnessStart`, `closedWitnessValue`)
2. Elementare Startwert-Sätze (ohne Bahnformel)
3. Geschlossene Bahnformel (`witnessStart_iterate_closed_form_add_one`)
4. Valuation (`witnessStart_valuation_one`, …)
5. Existenz + No-Go (`ArbitrarilyLongValuationOneRuns`, `UniformValuationOneRunBound`)

Witness für Länge `L`: `witnessStart (L + 1)` (Randfall `L = 0` leer).
-/

namespace KeplerHurwitz.Collatz.Octonion

open Real
open CollatzAttemptV2 CollatzNetDescentMod8

/-!
### 1. Kritischer Punkt: `ν₂(3n+1) = 1` ⟺ `n ≡ 3 (mod 4)` (ungerade `n`)
-/

theorem nu2_one_iff_mod4_eq_three {n : Nat} (ho : n % 2 = 1) :
    padicValNat 2 (3 * n + 1) = 1 ↔ n % 4 = 3 := by
  constructor
  · intro hν
    by_contra hnot
    have hmod1 : n % 4 = 1 := by omega
    rcases (show n % 8 = 1 ∨ n % 8 = 5 from by omega) with h1 | h5
    · have h2 := nu2_three_mul_add_one_eq_two_of_mod8_eq1 h1
      omega
    · have h3 := nu2_three_mul_add_one_ge_three_of_mod8_eq5 h5
      omega
  · intro hmod
    exact nu2_three_mul_add_one_eq_one_of_mod4_eq_three ho hmod

/-!
### 2. Elementare Startwert-Sätze (ohne Bahnformel)
-/

private lemma two_pow_odd_mod_three (k : Nat) :
    2 ^ (2 * k + 1) % 3 = 2 := by
  induction k with
  | zero => decide
  | succ k ih =>
      rw [show 2 * (k + 1) + 1 = (2 * k + 1) + 2 from by ring, pow_add, Nat.mul_mod, ih]
      decide

private lemma two_pow_odd_mod_six (k : Nat) :
    2 ^ (2 * k + 1) % 6 = 2 := by
  induction k with
  | zero => decide
  | succ k ih =>
      rw [show 2 * (k + 1) + 1 = (2 * k + 1) + 2 from by ring, pow_add, Nat.mul_mod, ih]
      decide

theorem three_not_dvd_two_pow_odd_sub_one (k : Nat) :
    ¬ 3 ∣ 2 ^ (2 * k + 1) - 1 := by
  intro h
  have h0 : (2 ^ (2 * k + 1) - 1) % 3 = 0 := Nat.mod_eq_zero_of_dvd h
  have h1 : 2 ^ (2 * k + 1) % 3 = 2 := two_pow_odd_mod_three k
  have hge : 1 ≤ 2 ^ (2 * k + 1) := Nat.one_le_two_pow
  have h2 : (2 ^ (2 * k + 1) - 1) % 3 = 1 := by omega
  omega

private lemma witnessStart_add_one (L : Nat) :
    witnessStart L + 1 = 2 ^ witnessExponent L := by
  dsimp [witnessStart]
  rw [Nat.sub_add_cancel (Nat.one_le_two_pow (n := witnessExponent L))]

private lemma witnessExp_pow_mod_six (L : Nat) :
    2 ^ witnessExponent L % 6 = 2 := by
  dsimp [witnessExponent]
  exact two_pow_odd_mod_six L

private lemma witnessExponent_pos (L : Nat) : 0 < witnessExponent L := by
  dsimp [witnessExponent]
  omega

private lemma two_pow_pos_mod2_zero {e : Nat} (he : 0 < e) :
    2 ^ e % 2 = 0 := by
  exact Nat.mod_eq_zero_of_dvd ⟨2 ^ (e - 1), by
    rw [← Nat.pow_succ']
    congr 1
    omega⟩

private lemma witnessStart_mod2_eq_one (L : Nat) :
    witnessStart L % 2 = 1 := by
  have hadd := witnessStart_add_one L
  have hpow : 2 ^ witnessExponent L % 2 = 0 :=
    two_pow_pos_mod2_zero (witnessExponent_pos L)
  have hmod : (witnessStart L + 1) % 2 = 0 := by rw [hadd, hpow]
  omega

theorem witnessStart_odd (L : Nat) : Odd (witnessStart L) := by
  rw [Nat.odd_iff]
  exact witnessStart_mod2_eq_one L

private lemma witnessStart_mod6_eq_one (L : Nat) :
    witnessStart L % 6 = 1 := by
  have hadd := witnessStart_add_one L
  have hpow := witnessExp_pow_mod_six L
  have hmod : (witnessStart L + 1) % 6 = 2 := by rw [hadd, hpow]
  omega

theorem witnessStart_coprime_six (L : Nat) : Nat.Coprime (witnessStart L) 6 := by
  rw [Nat.coprime_comm, Nat.coprime_iff_gcd_eq_one]
  rw [Nat.gcd_rec, witnessStart_mod6_eq_one L, Nat.gcd_one_left]

theorem witnessStart_gt_one {L : Nat} (hL : 1 ≤ L) : 1 < witnessStart L := by
  dsimp [witnessStart, witnessExponent]
  have hexp : 2 ≤ 2 * L + 1 := by omega
  have hpow : 4 ≤ 2 ^ (2 * L + 1) :=
    Nat.pow_le_pow_right (by decide : 1 ≤ 2) hexp
  omega

private lemma two_pow_ge_four_mod4_zero {e : Nat} (he : 2 ≤ e) :
    2 ^ e % 4 = 0 := by
  have h4 : 4 ∣ 2 ^ e := by
    refine ⟨2 ^ (e - 2), ?_⟩
    calc 2 ^ e = 2 ^ (e - 2 + 2) := by congr 1; omega
      _ = 2 ^ (e - 2) * 2 ^ 2 := by rw [pow_add]
      _ = 4 * 2 ^ (e - 2) := by rw [show 2 ^ 2 = 4 from by decide, mul_comm]
  exact Nat.mod_eq_zero_of_dvd h4

private lemma mul_pow_two_mod_four {a e : Nat} (he : 2 ≤ e) :
    (a * 2 ^ e) % 4 = 0 := by
  rw [Nat.mul_mod, two_pow_ge_four_mod4_zero he]
  simp

private lemma witnessStart_mod4_eq_three {L : Nat} (hL : 1 ≤ L) :
    witnessStart L % 4 = 3 := by
  have hadd := witnessStart_add_one L
  have hexp : 2 ≤ witnessExponent L := by dsimp [witnessExponent]; omega
  have hpow := two_pow_ge_four_mod4_zero hexp
  have hmod : (witnessStart L + 1) % 4 = 0 := by rw [hadd, hpow]
  omega

private lemma closedWitnessValue_add_one (L j : Nat) :
    closedWitnessValue L j + 1 = 3 ^ j * 2 ^ (witnessExponent L - j) := by
  dsimp [closedWitnessValue]
  have hbase : 0 < 3 ^ j := Nat.pow_pos (by decide : 0 < 3)
  have hexp : 0 < 2 ^ (witnessExponent L - j) := Nat.pow_pos (by decide : 0 < 2)
  have hge : 1 ≤ 3 ^ j * 2 ^ (witnessExponent L - j) := by
    have hpos : 0 < 3 ^ j * 2 ^ (witnessExponent L - j) := Nat.mul_pos hbase hexp
    omega
  rw [Nat.sub_add_cancel hge]

/-!
### 3. Geschlossene Bahnformel (vor Valuation)
-/

theorem witness_index_le_exponent {L j : Nat} (hj : j < witnessExponent L) :
    j < witnessExponent L := hj

theorem closedWitnessValue_positive {L j : Nat} :
    0 < closedWitnessValue L j := by
  sorry

private lemma three_mul_closedWitnessValue_add_one (L j : Nat)
    (hj : j + 1 < witnessExponent L) :
    3 * closedWitnessValue L j + 1 = 2 * (3 ^ (j + 1) * 2 ^ (witnessExponent L - j - 1)) := by
  sorry

private lemma closedWitnessValue_inner_odd (L j : Nat)
    (hj : j + 1 < witnessExponent L) :
    Odd (3 ^ (j + 1) * 2 ^ (witnessExponent L - j - 1) - 1) := by
  sorry

theorem closedWitnessValue_step {L j : Nat} (hj : j + 1 < witnessExponent L) :
    tOdd (closedWitnessValue L j) = closedWitnessValue L (j + 1) := by
  sorry

theorem oddCoreIterate_witnessStart_eq_closed {L j : Nat}
    (hj : j < witnessExponent L) :
    oddCoreIterate j (witnessStart L) = closedWitnessValue L j := by
  sorry

theorem witnessStart_iterate_closed_form_add_one {L j : Nat}
    (hj : j < witnessExponent L) :
    oddCoreIterate j (witnessStart L) + 1 = 3 ^ j * 2 ^ (witnessExponent L - j) := by
  sorry

theorem witnessStart_iterate_closed_form {L j : Nat} (hj : j < witnessExponent L) :
    oddCoreIterate j (witnessStart L) = closedWitnessValue L j := by
  sorry

theorem oddCoreIterate_mersenneOdd_eq {L j : Nat}
    (hj : j < witnessExponent L) :
    oddCoreIterate j (witnessStart L) = closedWitnessValue L j :=
  witnessStart_iterate_closed_form hj

/-!
### 4. Valuation (nach Bahnformel)
-/

theorem witness_remaining_exponent_ge_two {L j : Nat}
    (hL : 1 ≤ L) (hj : j < L) :
    2 ≤ witnessExponent (L + 1) - j := by
  dsimp [witnessExponent]
  omega

theorem witnessStart_valuation_one {L j : Nat} (hL : 1 ≤ L) (hj : j < L) :
    padicValNat 2 (3 * oddCoreIterate j (witnessStart (L + 1)) + 1) = 1 := by
  sorry

theorem consecutive_valuation_one_run_zero (L : Nat) (hL : 1 ≤ L) :
    padicValNat 2 (3 * witnessStart L + 1) = 1 := by
  have ho := witnessStart_mod2_eq_one L
  have hmod := witnessStart_mod4_eq_three hL
  exact nu2_three_mul_add_one_eq_one_of_mod4_eq_three ho hmod

theorem consecutive_valuation_one_run (L j : Nat) (hL : 1 ≤ L) (hj : j < L) :
    padicValNat 2 (3 * oddCoreIterate j (witnessStart L) + 1) = 1 := by
  sorry

/-!
### 5. Existenz + No-Go (getrennte Props)
-/

def ArbitrarilyLongValuationOneRuns : Prop :=
  ∀ L : Nat, ∃ n₀ : Nat, Nat.Coprime n₀ 6 ∧ Odd n₀ ∧
    ∀ j < L, padicValNat 2 (3 * oddCoreIterate j n₀ + 1) = 1

def UniformValuationOneRunBound : Prop :=
  ∃ B : Nat, ∀ n₀ : Nat, Nat.Coprime n₀ 6 → Odd n₀ →
    ∀ j : Nat, B ≤ j → padicValNat 2 (3 * oddCoreIterate j n₀ + 1) ≠ 1

theorem arbitrarily_long_runs_imply_no_uniform_bound
    (harb : ArbitrarilyLongValuationOneRuns) :
    ¬ UniformValuationOneRunBound := by
  intro hunif
  obtain ⟨B, hB⟩ := hunif
  obtain ⟨n₀, hn6, hodd, hrun⟩ := harb (B + 1)
  have hAtB := hrun B (Nat.lt_succ_self B)
  exact hB n₀ hn6 hodd B (Nat.le_refl B) hAtB

theorem arbitrarily_long_valuation_one_runs (L : Nat) :
    ∃ n : Nat, Nat.Coprime n 6 ∧ Odd n ∧
      ∀ j < L, padicValNat 2 (3 * oddCoreIterate j n + 1) = 1 := by
  sorry

theorem arbitrarily_long_valuation_one_runs_prop :
    ArbitrarilyLongValuationOneRuns := by
  intro L
  exact arbitrarily_long_valuation_one_runs L

theorem no_uniform_valuation_one_run_bound :
    ¬ UniformValuationOneRunBound :=
  arbitrarily_long_runs_imply_no_uniform_bound arbitrarily_long_valuation_one_runs_prop

/-!
### No-Go EABC / kompensierte Drift (bestehend, `[A]`)
-/

theorem oddCoreStep_log_ratio_pos_mersenne (L : Nat) (hL : 1 ≤ L) :
    0 < oddCoreStepLogRatio (witnessStart L) := by
  have hn : 0 < witnessStart L :=
    Nat.lt_trans (by decide : 0 < 1) (witnessStart_gt_one hL)
  exact oddCoreStep_log_ratio_pos_of_nu2_one hn (consecutive_valuation_one_run_zero L hL)

def BoundedEabcCorrection (R : ℝ → ℝ) (C : ℝ) : Prop :=
  ∀ Q : ℝ, Q ≠ 0 → |R Q| ≤ C / Q ^ 2

noncomputable def compensatedOddCoreDrift (n : Nat) (R : ℝ → ℝ) (Q : ℝ) : ℝ :=
  oddCoreStepLogRatio n + R Q

private lemma nu2_ten : padicValNat 2 10 = 1 := by
  have hn : 10 ≠ 0 := by decide
  have h2 : 2 ∣ 10 := by decide
  have h4not : ¬4 ∣ 10 := by decide
  have h1le : 1 ≤ padicValNat 2 10 :=
    (padicValNat_dvd_iff_le (p := 2) (a := 10) hn).1 (by simpa using h2)
  have hnot2le : ¬2 ≤ padicValNat 2 10 := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 10) hn).2 (by simpa using h2le))
  omega

theorem no_go_not_all_negative_compensated_drift :
    ¬ ∀ (R : ℝ → ℝ), BoundedEabcCorrection R 0 →
      ∀ (n : Nat), 1 < n → n % 2 = 1 →
        compensatedOddCoreDrift n R ((n : ℝ)) < 0 := by
  intro hall
  have hpos :=
    oddCoreStep_log_ratio_pos_of_nu2_one (by decide : 0 < 3) nu2_ten
  have hR0 : BoundedEabcCorrection (fun _ => 0) 0 := by
    intro Q hQ
    simp
  have h := hall (fun _ => 0) hR0 3 (by decide) (by decide)
  rw [compensatedOddCoreDrift, add_zero] at h
  exact not_lt.mpr (le_of_lt hpos) h

theorem no_go_zero_correction_positive_drift :
    ∃ (n : Nat), 1 < n ∧ n % 2 = 1 ∧
      0 ≤ compensatedOddCoreDrift n (fun _ => 0) ((n : ℝ)) := by
  refine ⟨3, by decide, by decide, ?_⟩
  rw [compensatedOddCoreDrift, add_zero]
  exact le_of_lt (oddCoreStep_log_ratio_pos_of_nu2_one (by decide : 0 < 3) nu2_ten)

end KeplerHurwitz.Collatz.Octonion
