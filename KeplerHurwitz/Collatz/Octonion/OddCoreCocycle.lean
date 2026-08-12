import KeplerHurwitz.Collatz.Octonion.Definitions

/-!
Modul O1 — Odd-Core-Log-Cocycle `[A]`.

`log(S(n)/n) = log 3 - ν₂(3n+1)·log 2 + log(1 + 1/(3n))`
und die k-Schritt-Orbit-Cocycle-Identität.
-/

namespace KeplerHurwitz.Collatz.Octonion

noncomputable section

open Real

private lemma oddCoreIterate_pos {k n : Nat} (hn : 0 < n) : 0 < oddCoreIterate k n := by
  induction k with
  | zero => exact hn
  | succ k _ =>
      rw [show oddCoreIterate (k + 1) n = oddCoreStep (oddCoreIterate k n) from by
        simp [oddCoreIterate, Function.iterate_succ_apply']]
      exact oddCoreStep_pos _

/--
`[A]` Ein-Schritt-Log-Identität:
`log(S(n)/n) = log 3 - ν₂(3n+1)·log 2 + log(1 + 1/(3n))`.
-/
theorem oddCoreStep_log_ratio
    {n : Nat} (hn : 0 < n) :
    oddCoreStepLogRatio n =
      Real.log 3 - (padicValNat 2 (3 * n + 1) : ℝ) * Real.log 2 +
        Real.log (1 + 1 / (3 * n : ℝ)) := by
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  have hk : 0 < (2 ^ padicValNat 2 (3 * n + 1) : ℝ) := by positivity
  rw [oddCoreStepLogRatio, oddCoreStep_div_eq n hn]
  have hsplit :
      (3 * n + 1 : ℝ) / ((2 ^ padicValNat 2 (3 * n + 1) : ℝ) * n) =
        (3 : ℝ) / (2 ^ padicValNat 2 (3 * n + 1) : ℝ) * (1 + 1 / (3 * n : ℝ)) := by
    field_simp
  rw [hsplit, Real.log_mul (by positivity) (by positivity)]
  rw [Real.log_div (by norm_num : (3 : ℝ) ≠ 0) (ne_of_gt hk), Real.log_pow]

/--
`[A]` k-Schritt-Orbit-Cocycle:
`log(S^k(n)/n) = Σ_{j<k} log(S(S^j n)/S^j n)`.
-/
theorem oddCoreIterate_log_cocycle
    (k : Nat) {n : Nat} (hn : 0 < n) :
    oddCoreIterate_log_ratio k n =
      (Finset.range k).sum fun j =>
        oddCoreStepLogRatio (oddCoreIterate j n) := by
  induction k with
  | zero =>
      simp [oddCoreIterate_log_ratio, oddCoreIterate, oddCoreStepLogRatio]
  | succ k ih =>
      have hiter_pos : 0 < oddCoreIterate k n :=
        oddCoreIterate_pos hn
      have hsplit :
          Real.log ((oddCoreStep (oddCoreIterate k n) : ℝ) / n) =
            oddCoreStepLogRatio (oddCoreIterate k n) +
              oddCoreIterate_log_ratio k n := by
        rw [oddCoreStepLogRatio, oddCoreIterate_log_ratio]
        have hn0 : 0 < (n : ℝ) := by exact_mod_cast hn
        have hk0 : 0 < (oddCoreIterate k n : ℝ) := by exact_mod_cast hiter_pos
        have hs0 : 0 < (oddCoreStep (oddCoreIterate k n) : ℝ) := by exact_mod_cast oddCoreStep_pos _
        rw [← Real.log_mul (ne_of_gt (div_pos hs0 hk0)) (ne_of_gt (div_pos hk0 hn0))]
        field_simp [hn0.ne', hk0.ne']
      rw [oddCoreIterate_log_ratio]
      rw [show oddCoreIterate (k + 1) n = oddCoreStep (oddCoreIterate k n) from by
        simp [oddCoreIterate, Function.iterate_succ_apply']]
      rw [hsplit, ih, Finset.sum_range_succ]
      ac_rfl

/--
`[A]` Strikter Abstieg auf Odd-Core-Ebene entspricht negativem Log-Verhältnis.
-/
theorem oddCoreIterate_lt_iff_negative_log_ratio
    {k n : Nat} (hn : 0 < n) :
    oddCoreIterate k n < n ↔ oddCoreIterate_log_ratio k n < 0 := by
  have hn0 : 0 < (n : ℝ) := by exact_mod_cast hn
  have hiter_pos : 0 < oddCoreIterate k n :=
    oddCoreIterate_pos hn
  have hk0 : 0 < (oddCoreIterate k n : ℝ) := by exact_mod_cast hiter_pos
  rw [← Nat.cast_lt (α := ℝ), oddCoreIterate_log_ratio,
    Real.log_neg_iff (div_pos hk0 hn0), div_lt_one hn0]

theorem oddCoreStep_log_ratio_pos_of_nu2_one
    {n : Nat} (hn : 0 < n) (hν : padicValNat 2 (3 * n + 1) = 1) :
    0 < oddCoreStepLogRatio n := by
  rw [oddCoreStepLogRatio, oddCoreStep_div_eq n hn]
  rw [show padicValNat 2 (3 * n + 1) = 1 from hν]
  simp only [pow_one]
  have hratio : 1 < (3 * n + 1 : ℝ) / (2 * n) := by
    rw [one_lt_div (by positivity)]
    exact_mod_cast (show 2 * n < 3 * n + 1 by omega)
  exact Real.log_pos hratio

end

end KeplerHurwitz.Collatz.Octonion
