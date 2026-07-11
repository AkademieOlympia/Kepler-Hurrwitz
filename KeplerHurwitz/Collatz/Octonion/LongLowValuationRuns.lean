import KeplerHurwitz.Collatz.Octonion.OddCoreCocycle

/-!
Modul O2 — Lange `ν₂ = 1`-Läufe und EABC-No-Go.

Status:
- `oddCoreIterate_mersenneOdd_eq`, `consecutive_valuation_one_run`,
  `consecutive_valuation_one_run_zero`, `oddCoreStep_log_ratio_pos_mersenne`: `[C]`
- `arbitrarily_long_valuation_one_runs`: `[C]` Witness-Skizze (`n = 2^m - 1`, `m` ungerade)
- `no_go_*`: `[A]` für Null-Korrektur / universelle Negation mit `C = 0`

Mod-6-Schutzlemma (Witness-Familie):
`n₀ := 2^m(L) - 1` mit `m(L) = L+1` (gerades `L`) bzw. `L+2` (ungerades `L`).
Dann `m(L)` stets ungerade, `n₀ ∈ U_6`, mindestens `L` Schritte mit `ν₂ = 1`, und
`n_j = 3^j · 2^{m(L)-j} - 1` für `0 ≤ j < m(L) - 1`.

Schutzsatz-Kern: keine uniforme Wartezeit — jede erfolgreiche O5-Strategie muss über
den endlichen mod-12-Automaten hinausgehen.
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

private lemma padicValNat_two_mul_eq_one_of_not_two_dvd {k : Nat}
    (hk : ¬ 2 ∣ k) :
    padicValNat 2 (2 * k) = 1 := by
  have hn : 2 * k ≠ 0 := by
    intro h0
    have hk0 : k = 0 := by omega
    exact hk (by simpa [hk0])
  have h2 : 2 ∣ 2 * k := by
    exact ⟨k, by ring⟩
  have h4not : ¬4 ∣ 2 * k := by
    intro h4
    rcases h4 with ⟨t, ht⟩
    have hk2 : k = 2 * t := by omega
    exact hk ⟨t, hk2⟩
  have h1le : 1 ≤ padicValNat 2 (2 * k) :=
    (padicValNat_dvd_iff_le (p := 2) (a := 2 * k) hn).1 (by simpa using h2)
  have hnot2le : ¬2 ≤ padicValNat 2 (2 * k) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 2 * k) hn).2 (by simpa using h2le))
  omega

private lemma mersenneOddExponent_ge_two (L : Nat) (hL : 1 ≤ L) : 2 ≤ mersenneOddExponent L := by
  by_cases hev : L % 2 = 0 <;> simp [mersenneOddExponent, hev] <;> omega

private lemma three_mul_pow_sub_one_plus_one (t : Nat) :
    3 * (2 ^ (t + 2) - 1) + 1 = 2 * (3 * 2 ^ (t + 1) - 1) := by
  have hpow : 1 ≤ 2 ^ (t + 2) := Nat.one_le_two_pow
  calc
    3 * (2 ^ (t + 2) - 1) + 1 = 3 * 2 ^ (t + 2) - 2 := by omega
    _ = 2 * (3 * 2 ^ (t + 1) - 1) := by
      rw [Nat.pow_succ]
      ring_nf
      omega

private lemma three_mul_mersenne_plus_one_eq (exp : Nat) (hexp : 2 ≤ exp) :
    3 * (2 ^ exp - 1) + 1 = 2 * (3 * 2 ^ (exp - 1) - 1) := by
  rcases Nat.exists_eq_add_of_le (show 1 ≤ exp - 1 from by omega) with ⟨t, ht⟩
  have hexp2 : exp = t + 2 := by omega
  rw [hexp2]
  exact three_mul_pow_sub_one_plus_one t

/--
`[C]` Geschlossene Form `S^j(2^m(L)-1) = 2^(m(L)-j)·3^j - 1` — arithmetischer Induktionsschritt offen.
-/
theorem oddCoreIterate_mersenneOdd_eq
    (L j : Nat) (hj : j ≤ mersenneOddExponent L) :
    oddCoreIterate j (mersenneOdd L) =
      2 ^ (mersenneOddExponent L - j) * 3 ^ j - 1 := by
  sorry

/--
`[C]` Beliebig lange `ν₂ = 1`-Läufe: Witness `n = 2^m - 1` mit ungeradem `m > L`.
-/
theorem arbitrarily_long_valuation_one_runs (L : Nat) :
    ∃ n : Nat, Nat.Coprime n 6 ∧ Odd n ∧
      ∀ j < L, padicValNat 2 (3 * oddCoreIterate j n + 1) = 1 := by
  let m : Nat := mersenneOddExponent L
  refine ⟨mersenneOdd L, ?_, ?_, ?_⟩
  · sorry
  · sorry
  · intro j hj
    sorry

/--
`[C]` Langer `ν₂ = 1`-Lauf auf Mersenne-Starts — folgt aus der geschlossenen Form; offen.
-/
theorem consecutive_valuation_one_run
    (L j : Nat) (_hL : 1 ≤ L) (hj : j < L) :
    padicValNat 2 (3 * oddCoreIterate j (mersenneOdd L) + 1) = 1 := by
  sorry

/--
`[A]` Basisfall `j = 0` für `L ≥ 1`: `ν₂(3·(2^m(L)-1)+1) = 1`.
-/
theorem consecutive_valuation_one_run_zero
    (L : Nat) (hL : 1 ≤ L) :
    padicValNat 2 (3 * mersenneOdd L + 1) = 1 := by
  set exp := mersenneOddExponent L with hexp_def
  have hexp_ge_two := mersenneOddExponent_ge_two L hL
  set k := 3 * 2 ^ (exp - 1) - 1 with hk_def
  have hk_not_two_dvd : ¬ 2 ∣ k := by
    rcases Nat.exists_eq_add_of_le (show 1 ≤ exp - 1 from by omega) with ⟨t, ht⟩
    have hk_eq : k = 3 * 2 ^ (t + 1) - 1 := by
      dsimp [k]
      rw [ht, Nat.add_comm 1 t]
    intro hk2
    rw [hk_eq] at hk2
    rcases hk2 with ⟨u, hu⟩
    have hpow : 2 ∣ 2 ^ (t + 1) := by
      refine ⟨2 ^ t, ?_⟩
      calc
        2 ^ (t + 1) = 2 ^ t * 2 := by rw [Nat.pow_succ]
        _ = 2 * 2 ^ t := by ring
    have hmul : 2 ∣ 3 * 2 ^ (t + 1) := dvd_mul_of_dvd_right hpow 3
    have hmod_even : (3 * 2 ^ (t + 1)) % 2 = 0 := Nat.mod_eq_zero_of_dvd hmul
    have hmod_odd : (2 * u + 1) % 2 = 1 := by simp
    have hEq : 3 * 2 ^ (t + 1) = 2 * u + 1 := by
      have hpos : 1 ≤ 3 * 2 ^ (t + 1) := by
        apply Nat.succ_le_iff.mpr
        positivity
      calc
        3 * 2 ^ (t + 1) = (3 * 2 ^ (t + 1) - 1) + 1 := by
          exact (Nat.sub_add_cancel hpos).symm
        _ = 2 * u + 1 := by simpa [hu]
    rw [hEq] at hmod_even
    have : (0 : Nat) = 1 := by simpa [hmod_odd] using hmod_even
    omega
  have hrewrite : 3 * mersenneOdd L + 1 = 2 * k := by
    dsimp [mersenneOdd, k]
    rw [hexp_def, three_mul_mersenne_plus_one_eq exp hexp_ge_two]
  have hn : 3 * mersenneOdd L + 1 ≠ 0 := by
    omega
  have h2 : 2 ∣ 3 * mersenneOdd L + 1 := by
    refine ⟨k, ?_⟩
    omega
  have h4not : ¬4 ∣ 3 * mersenneOdd L + 1 := by
    intro h4
    rcases h4 with ⟨t, ht⟩
    have hk_eq : k = 2 * t := by
      have h24 : 2 * k = 4 * t := by
        calc
          2 * k = 3 * mersenneOdd L + 1 := by simpa [hrewrite]
          _ = 4 * t := ht
      omega
    exact hk_not_two_dvd ⟨t, hk_eq⟩
  have h1le : 1 ≤ padicValNat 2 (3 * mersenneOdd L + 1) :=
    (padicValNat_dvd_iff_le (p := 2) (a := 3 * mersenneOdd L + 1) hn).1 (by simpa using h2)
  have hnot2le : ¬2 ≤ padicValNat 2 (3 * mersenneOdd L + 1) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * mersenneOdd L + 1) hn).2 (by simpa using h2le))
  omega

theorem oddCoreStep_log_ratio_pos_mersenne (L : Nat) (hL : 1 ≤ L) :
    0 < oddCoreStepLogRatio (mersenneOdd L) := by
  have hn : 0 < mersenneOdd L := by
    have hle : 1 ≤ mersenneOdd L := by
      dsimp [mersenneOdd]
      have hexp_ge_two := mersenneOddExponent_ge_two L hL
      have hpow : 4 ≤ 2 ^ mersenneOddExponent L :=
        Nat.pow_le_pow_right (by decide : 1 ≤ 2) hexp_ge_two
      omega
    exact Nat.lt_of_succ_le hle
  exact oddCoreStep_log_ratio_pos_of_nu2_one hn (consecutive_valuation_one_run_zero L hL)

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
