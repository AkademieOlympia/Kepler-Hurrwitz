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

/--
Fall `m % 8 = 5` mit exakter Faktorisierung `3m+1 = 8·q` und ungeradem `q`:
dann ist `ν₂(3m+1) = 3` exakt.
-/
theorem nu2_three_mul_add_one_eq_three_of_mod8_eq5_quotient_odd
    {m q : Nat}
    (h5 : m % 8 = 5)
    (hfactor : 3 * m + 1 = 8 * q)
    (hodd : Odd q) :
    padicValNat 2 (3 * m + 1) = 3 := by
  have hn : 3 * m + 1 ≠ 0 := by omega
  have h8dvd : 8 ∣ 3 * m + 1 := by rw [hfactor]; exact dvd_mul_right 8 q
  have h16not : ¬16 ∣ 3 * m + 1 := by
    intro h16
    rcases h16 with ⟨t, ht⟩
    rw [hfactor] at ht
    have hq_even : 2 ∣ q := by omega
    exact hodd.not_two_dvd_nat hq_even
  have h3le : 3 ≤ padicValNat 2 (3 * m + 1) :=
    nu2_three_mul_add_one_ge_three_of_mod8_eq5 h5
  have hnot4le : ¬4 ≤ padicValNat 2 (3 * m + 1) := by
    intro h4le
    exact h16not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).2 (by simpa using h4le))
  omega

/--
Fall `m % 8 = 5` mit exakter Faktorisierung `3m+1 = 16·q` und ungeradem `q`:
dann ist `ν₂(3m+1) = 4` exakt.
-/
theorem nu2_three_mul_add_one_eq_four_of_mod8_eq5_quotient_odd
    {m q : Nat}
    (h5 : m % 8 = 5)
    (hfactor : 3 * m + 1 = 16 * q)
    (hodd : Odd q) :
    padicValNat 2 (3 * m + 1) = 4 := by
  have hn : 3 * m + 1 ≠ 0 := by omega
  have h16dvd : 16 ∣ 3 * m + 1 := by rw [hfactor]; exact dvd_mul_right 16 q
  have h32not : ¬32 ∣ 3 * m + 1 := by
    intro h32
    rcases h32 with ⟨t, ht⟩
    rw [hfactor] at ht
    have hq_even : 2 ∣ q := by omega
    exact hodd.not_two_dvd_nat hq_even
  have h4le : 4 ≤ padicValNat 2 (3 * m + 1) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).1 (by simpa using h16dvd)
  have hge_three : 3 ≤ padicValNat 2 (3 * m + 1) :=
    nu2_three_mul_add_one_ge_three_of_mod8_eq5 h5
  have hnot5le : ¬5 ≤ padicValNat 2 (3 * m + 1) := by
    intro h5le
    exact h32not ((padicValNat_dvd_iff_le (p := 2) (a := 3 * m + 1) hn).2 (by simpa using h5le))
  omega

end KeplerHurwitz
