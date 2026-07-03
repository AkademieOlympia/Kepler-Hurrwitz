import Mathlib
import KeplerHurwitz.CollatzNormShell
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.ResidueFilters

namespace KeplerHurwitz

/--
Uebergang auf der ungeraden Kern-Ebene:
`m ↦ oddCore (3*m + 1)`.
-/
def oddCoreStep (m : Nat) : Nat := oddCore (3 * m + 1)

theorem oddCoreStep_odd (m : Nat) : Odd (oddCoreStep m) := by
  unfold oddCoreStep
  exact oddCore_odd_of_pos (by omega)

theorem oddCoreStep_pos (m : Nat) : 0 < oddCoreStep m := by
  exact (oddCoreStep_odd m).pos

theorem oddCoreStep_mod2_eq_one (m : Nat) : oddCoreStep m % 2 = 1 := by
  exact Nat.odd_iff.mp (oddCoreStep_odd m)

/--
Normschalen-Retraktion nach einem ungeraden Start:
Von `m` (ungerade) erreicht die Collatz-Iteration den naechsten ungeraden Kern.
-/
theorem oddCoreStep_reached_by_collatz (hm : m % 2 = 1) :
    ∃ t, Nat.iterate collatzStep t m = oddCoreStep m := by
  simpa [oddCoreStep] using odd_kick_reaches_oddCore hm

/--
Der Mod-8-Eingangsfall fuer ungerade Kerne bleibt erhalten als Filter-Interface.
-/
theorem oddCore_input_mod8_cases (hm : m % 2 = 1) :
    m % 8 = 1 ∨ m % 8 = 3 ∨ m % 8 = 5 ∨ m % 8 = 7 := by
  exact odd_mod8_cases hm

/--
Mod-8-Tabelle fuer den ungeraden Kick `3*m+1` als Bruecke zur Filterlogik.
-/
theorem oddCore_kick_mod8_table (hm : m % 2 = 1) :
    (m % 8 = 1 ∧ (3 * m + 1) % 8 = 4) ∨
    (m % 8 = 3 ∧ (3 * m + 1) % 8 = 2) ∨
    (m % 8 = 5 ∧ (3 * m + 1) % 8 = 0) ∨
    (m % 8 = 7 ∧ (3 * m + 1) % 8 = 6) := by
  exact three_mul_add_one_mod8_cases_of_odd hm

/--
Im Fall `m % 8 = 3` ist der naechste ungerade Kern exakt `(3*m+1)/2`.
-/
theorem oddCoreStep_eq_div2_of_mod8_eq3 (h3 : m % 8 = 3) :
    oddCoreStep m = (3 * m + 1) / 2 := by
  have h2dvd : 2 ∣ 3 * m + 1 := by omega
  have h4not : ¬4 ∣ 3 * m + 1 := by omega
  have hquot_odd : Odd ((3 * m + 1) / 2) := by
    refine Nat.not_even_iff_odd.mp ?_
    intro hEven
    have h2q : 2 ∣ (3 * m + 1) / 2 := Even.two_dvd hEven
    apply h4not
    rcases h2q with ⟨k, hk⟩
    refine ⟨k, ?_⟩
    calc
      3 * m + 1 = 2 * ((3 * m + 1) / 2) := by
          simpa [Nat.mul_comm] using (Nat.mul_div_cancel' h2dvd).symm
      _ = 2 * (2 * k) := by simp [hk]
      _ = 4 * k := by ring
  have hn2 : 3 * m + 1 = 2 * ((3 * m + 1) / 2) := by
    simpa [Nat.mul_comm] using (Nat.mul_div_cancel' h2dvd).symm
  unfold oddCoreStep
  calc
    oddCore (3 * m + 1) = oddCore (2 * ((3 * m + 1) / 2)) := by
      exact congrArg oddCore hn2
    _ = (3 * m + 1) / 2 := by
          simpa [pow_one] using oddCore_two_pow_mul 1 ((3 * m + 1) / 2) hquot_odd

/--
Im Fall `m % 8 = 7` ist der naechste ungerade Kern exakt `(3*m+1)/2`.
-/
theorem oddCoreStep_eq_div2_of_mod8_eq7 (h7 : m % 8 = 7) :
    oddCoreStep m = (3 * m + 1) / 2 := by
  have h2dvd : 2 ∣ 3 * m + 1 := by omega
  have h4not : ¬4 ∣ 3 * m + 1 := by omega
  have hquot_odd : Odd ((3 * m + 1) / 2) := by
    refine Nat.not_even_iff_odd.mp ?_
    intro hEven
    have h2q : 2 ∣ (3 * m + 1) / 2 := Even.two_dvd hEven
    apply h4not
    rcases h2q with ⟨k, hk⟩
    refine ⟨k, ?_⟩
    calc
      3 * m + 1 = 2 * ((3 * m + 1) / 2) := by
          simpa [Nat.mul_comm] using (Nat.mul_div_cancel' h2dvd).symm
      _ = 2 * (2 * k) := by simp [hk]
      _ = 4 * k := by ring
  have hn2 : 3 * m + 1 = 2 * ((3 * m + 1) / 2) := by
    simpa [Nat.mul_comm] using (Nat.mul_div_cancel' h2dvd).symm
  unfold oddCoreStep
  calc
    oddCore (3 * m + 1) = oddCore (2 * ((3 * m + 1) / 2)) := by
      exact congrArg oddCore hn2
    _ = (3 * m + 1) / 2 := by
          simpa [pow_one] using oddCore_two_pow_mul 1 ((3 * m + 1) / 2) hquot_odd

end KeplerHurwitz
