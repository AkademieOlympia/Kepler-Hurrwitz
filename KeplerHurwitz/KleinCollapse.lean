import Mathlib
import KeplerHurwitz.CollatzNormShell
import KeplerHurwitz.OddCore
import KeplerHurwitz.SchalenDynamik

namespace KeplerHurwitz

/--
Die vier ungeraden Restklassen modulo `8` bilden die
Klein-Viererklassen-Sicht auf ungerade Kerne.
-/
def IsKleinFourClass (m : Nat) : Prop :=
  m % 8 = 1 ∨ m % 8 = 3 ∨ m % 8 = 5 ∨ m % 8 = 7

theorem isKleinFourClass_of_odd (hm : m % 2 = 1) :
    IsKleinFourClass m := by
  simpa [IsKleinFourClass] using odd_mod8_cases hm

theorem collapse_reaches_klein_four_class
    {n : Nat} (d : OddCoreDecomposition n) :
    IsKleinFourClass d.m := by
  exact isKleinFourClass_of_odd d.hm_odd

theorem collapse_iterate_reaches_klein_core
    {n : Nat} (d : OddCoreDecomposition n) :
    Nat.iterate collatzStep d.k n = d.m ∧ IsKleinFourClass d.m := by
  exact ⟨collatz_iterate_of_decomposition d, collapse_reaches_klein_four_class d⟩

/--
Nähere Wirkung der Collapse-Annahme:
Nach Retraktion auf den ungeraden Kern fällt jeder Fall in genau einen der
vier Mod-8-Kanäle und damit in die bekannte Schalenkanal-Typisierung.
-/
theorem collapse_effect_channel_cases
    {n : Nat} (d : OddCoreDecomposition n) :
    (d.m % 8 = 1 ∧ eSchalenSprung d.m = 2) ∨
    (d.m % 8 = 3 ∧ eSchalenSprung d.m = 1) ∨
    (d.m % 8 = 5 ∧ 3 ≤ eSchalenSprung d.m) ∨
    (d.m % 8 = 7 ∧ eSchalenSprung d.m = 1) := by
  exact eSchalenSprung_channel_cases_of_odd d.hm_odd

end KeplerHurwitz
