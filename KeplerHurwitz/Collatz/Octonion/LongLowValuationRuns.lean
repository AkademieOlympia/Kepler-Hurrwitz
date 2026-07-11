import KeplerHurwitz.Collatz.Octonion.OddCoreCocycle

/-!
Modul O2 — Lange `ν₂ = 1`-Läufe und EABC-No-Go.

Status:
- `oddCoreIterate_mersenneOdd_eq`, `consecutive_valuation_one_run`,
  `consecutive_valuation_one_run_zero`, `oddCoreStep_log_ratio_pos_mersenne`: `[C]`
- `no_go_*`: `[A]` für Null-Korrektur / universelle Negation mit `C = 0`
-/

namespace KeplerHurwitz.Collatz.Octonion

open Real

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

/--
`[C]` Geschlossene Form `S^j(2^(L+1)-1) = 2^(L+1-j)·3^j - 1` — arithmetischer Induktionsschritt offen.
-/
theorem oddCoreIterate_mersenneOdd_eq
    (L j : Nat) (hj : j ≤ L) :
    oddCoreIterate j (mersenneOdd L) = 2 ^ (L + 1 - j) * 3 ^ j - 1 := by
  sorry

/--
`[C]` Langer `ν₂ = 1`-Lauf auf Mersenne-Starts — folgt aus der geschlossenen Form; offen.
-/
theorem consecutive_valuation_one_run
    (L j : Nat) (_hL : 1 ≤ L) (hj : j < L) :
    padicValNat 2 (3 * oddCoreIterate j (mersenneOdd L) + 1) = 1 := by
  sorry

/--
`[A]` Basisfall `j = 0` für `L ≥ 1`: `ν₂(3·(2^(L+1)-1)+1) = 1`.
-/
theorem consecutive_valuation_one_run_zero
    (L : Nat) (hL : 1 ≤ L) :
    padicValNat 2 (3 * mersenneOdd L + 1) = 1 := by
  sorry

theorem oddCoreStep_log_ratio_pos_mersenne (L : Nat) (hL : 1 ≤ L) :
    0 < oddCoreStepLogRatio (mersenneOdd L) := by
  sorry

def BoundedEabcCorrection (R : ℝ → ℝ) (C : ℝ) : Prop :=
  ∀ Q : ℝ, Q ≠ 0 → |R Q| ≤ C / Q ^ 2

noncomputable def compensatedOddCoreDrift (n : Nat) (R : ℝ → ℝ) (Q : ℝ) : ℝ :=
  oddCoreStepLogRatio n + R Q

/--
`[A]` No-Go: universelle negative Drift für alle beschränkten `R` mit `C = 0` ist falsch.
-/
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

/--
`[A]` Explizites Null-Korrektur-Gegenbeispiel `n = 3`.
-/
theorem no_go_zero_correction_positive_drift :
    ∃ (n : Nat), 1 < n ∧ n % 2 = 1 ∧
      0 ≤ compensatedOddCoreDrift n (fun _ => 0) ((n : ℝ)) := by
  refine ⟨3, by decide, by decide, ?_⟩
  rw [compensatedOddCoreDrift, add_zero]
  exact le_of_lt (oddCoreStep_log_ratio_pos_of_nu2_one (by decide : 0 < 3) nu2_ten)

end KeplerHurwitz.Collatz.Octonion
