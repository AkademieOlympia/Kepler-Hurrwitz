import Mathlib
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.ResidueFilters

namespace KeplerHurwitz

/--
Die e-Schalenfunktion misst die Tiefe des 2-adischen Schalensprungs
nach dem ungeraden Collatz-Kick `3*m+1`.
-/
def eSchalenSprung (m : Nat) : Nat :=
  padicValNat 2 (3 * m + 1)

theorem eSchalenSprung_eq_one_of_mod8_eq3 (h3 : m % 8 = 3) :
    eSchalenSprung m = 1 := by
  simpa [eSchalenSprung] using nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3

theorem eSchalenSprung_eq_one_of_mod8_eq7 (h7 : m % 8 = 7) :
    eSchalenSprung m = 1 := by
  simpa [eSchalenSprung] using nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem eSchalenSprung_eq_two_of_mod8_eq1 (h1 : m % 8 = 1) :
    eSchalenSprung m = 2 := by
  simpa [eSchalenSprung] using nu2_three_mul_add_one_eq_two_of_mod8_eq1 h1

theorem eSchalenSprung_ge_three_of_mod8_eq5 (h5 : m % 8 = 5) :
    3 ≤ eSchalenSprung m := by
  simpa [eSchalenSprung] using nu2_three_mul_add_one_ge_three_of_mod8_eq5 h5

/--
Klassifikation der Schalenkanäle für ungerade Eingänge.
-/
theorem eSchalenSprung_channel_cases_of_odd (hm : m % 2 = 1) :
    (m % 8 = 1 ∧ eSchalenSprung m = 2) ∨
    (m % 8 = 3 ∧ eSchalenSprung m = 1) ∨
    (m % 8 = 5 ∧ 3 ≤ eSchalenSprung m) ∨
    (m % 8 = 7 ∧ eSchalenSprung m = 1) := by
  rcases odd_mod8_cases hm with h1 | h3 | h5 | h7
  · exact Or.inl ⟨h1, eSchalenSprung_eq_two_of_mod8_eq1 h1⟩
  · exact Or.inr <| Or.inl ⟨h3, eSchalenSprung_eq_one_of_mod8_eq3 h3⟩
  · exact Or.inr <| Or.inr <| Or.inl ⟨h5, eSchalenSprung_ge_three_of_mod8_eq5 h5⟩
  · exact Or.inr <| Or.inr <| Or.inr ⟨h7, eSchalenSprung_eq_one_of_mod8_eq7 h7⟩

end KeplerHurwitz
