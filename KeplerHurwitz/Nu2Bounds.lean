import Mathlib
import KeplerHurwitz.ResidueFilters

namespace KeplerHurwitz

/--
Fall `m % 8 = 3`: dann ist `ν₂(3m+1) = 1`.
-/
theorem nu2_three_mul_add_one_eq_one_of_mod8_eq3 (h3 : m % 8 = 3) :
    padicValNat 2 (3 * m + 1) = 1 := by
  have hn : 3 * m + 1 ≠ 0 := by omega
  have h2dvd : 2 ∣ 3 * m + 1 := by omega
  have h4not : ¬4 ∣ 3 * m + 1 := by omega
  have h1le : 1 ≤ padicValNat 2 (3 * m + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).1 (by simpa using h2dvd)
  have hnot2le : ¬2 ≤ padicValNat 2 (3 * m + 1) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).2 (by simpa using h2le))
  omega

/--
Fall `m % 8 = 7`: dann ist `ν₂(3m+1) = 1`.
-/
theorem nu2_three_mul_add_one_eq_one_of_mod8_eq7 (h7 : m % 8 = 7) :
    padicValNat 2 (3 * m + 1) = 1 := by
  have hn : 3 * m + 1 ≠ 0 := by omega
  have h2dvd : 2 ∣ 3 * m + 1 := by omega
  have h4not : ¬4 ∣ 3 * m + 1 := by omega
  have h1le : 1 ≤ padicValNat 2 (3 * m + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).1 (by simpa using h2dvd)
  have hnot2le : ¬2 ≤ padicValNat 2 (3 * m + 1) := by
    intro h2le
    exact h4not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).2 (by simpa using h2le))
  omega

/--
Fall `m % 8 = 1`: dann ist `ν₂(3m+1) = 2`.
-/
theorem nu2_three_mul_add_one_eq_two_of_mod8_eq1 (h1 : m % 8 = 1) :
    padicValNat 2 (3 * m + 1) = 2 := by
  have hn : 3 * m + 1 ≠ 0 := by omega
  have h4dvd : 4 ∣ 3 * m + 1 := by omega
  have h8not : ¬8 ∣ 3 * m + 1 := by omega
  have h2le : 2 ≤ padicValNat 2 (3 * m + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).1 (by simpa using h4dvd)
  have hnot3le : ¬3 ≤ padicValNat 2 (3 * m + 1) := by
    intro h3le
    exact h8not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).2 (by simpa using h3le))
  omega

/--
Fall `m % 8 = 5`: dann ist `ν₂(3m+1) ≥ 3`.
-/
theorem nu2_three_mul_add_one_ge_three_of_mod8_eq5 (h5 : m % 8 = 5) :
    3 ≤ padicValNat 2 (3 * m + 1) := by
  have hn : 3 * m + 1 ≠ 0 := by omega
  have h8dvd : 8 ∣ 3 * m + 1 := by omega
  exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).1 (by simpa using h8dvd)

end KeplerHurwitz
