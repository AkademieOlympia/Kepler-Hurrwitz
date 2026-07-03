import Mathlib

namespace KeplerHurwitz

/--
Für ungerade `m` sind modulo `8` genau die Restklassen `1,3,5,7` möglich.
-/
theorem odd_mod8_cases (hm : m % 2 = 1) :
    m % 8 = 1 ∨ m % 8 = 3 ∨ m % 8 = 5 ∨ m % 8 = 7 := by
  omega

theorem three_mul_add_one_mod8_eq4_of_mod8_eq1 (h1 : m % 8 = 1) :
    (3 * m + 1) % 8 = 4 := by
  omega

theorem three_mul_add_one_mod8_eq2_of_mod8_eq3 (h3 : m % 8 = 3) :
    (3 * m + 1) % 8 = 2 := by
  omega

theorem three_mul_add_one_mod8_eq0_of_mod8_eq5 (h5 : m % 8 = 5) :
    (3 * m + 1) % 8 = 0 := by
  omega

theorem three_mul_add_one_mod8_eq6_of_mod8_eq7 (h7 : m % 8 = 7) :
    (3 * m + 1) % 8 = 6 := by
  omega

/--
Kompakte Mod-8-Tabelle für den Collatz-Ungerad-Schritt `3m+1`.
-/
theorem three_mul_add_one_mod8_cases_of_odd (hm : m % 2 = 1) :
    (m % 8 = 1 ∧ (3 * m + 1) % 8 = 4) ∨
    (m % 8 = 3 ∧ (3 * m + 1) % 8 = 2) ∨
    (m % 8 = 5 ∧ (3 * m + 1) % 8 = 0) ∨
    (m % 8 = 7 ∧ (3 * m + 1) % 8 = 6) := by
  rcases odd_mod8_cases hm with h1 | h3 | h5 | h7
  · exact Or.inl ⟨h1, three_mul_add_one_mod8_eq4_of_mod8_eq1 h1⟩
  · exact Or.inr <| Or.inl ⟨h3, three_mul_add_one_mod8_eq2_of_mod8_eq3 h3⟩
  · exact Or.inr <| Or.inr <| Or.inl ⟨h5, three_mul_add_one_mod8_eq0_of_mod8_eq5 h5⟩
  · exact Or.inr <| Or.inr <| Or.inr ⟨h7, three_mul_add_one_mod8_eq6_of_mod8_eq7 h7⟩

end KeplerHurwitz
