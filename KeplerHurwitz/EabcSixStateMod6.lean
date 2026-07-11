import Mathlib

namespace KeplerHurwitz

/-!
## EABC six-state — mod-6 Primachsen [A]

Minimale mod-6-Restklassen-Fakten fuer die 6k±1-Primachsen-Zuordnung
(`1 → a`, `5 → bc` in Python `eabc_six_state_prime_axes.py`).

Defensiv: keine Quaternion- oder QEC-Lesesprache; nur Restklassen-Praedikate.
-/

/--
Mod-6-Restklasse einer natuerlichen Zahl.
-/
def mod6State (n : ℕ) : ℕ :=
  n % 6

/--
Praedikat fuer die a-Primachse (Restklasse 1 mod 6).
-/
def IsPrimeAxisA (n : ℕ) : Prop :=
  n % 6 = 1

/--
Praedikat fuer die bc-Primachse (Restklasse 5 mod 6).
-/
def IsPrimeAxisBC (n : ℕ) : Prop :=
  n % 6 = 5

/--
Jede Primzahl `p > 3` liegt in genau einer der beiden Primachsen-Restklassen mod 6.
-/
theorem prime_gt_three_mod_six (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p) :
    p % 6 = 1 ∨ p % 6 = 5 := by
  have h2 : p ≠ 2 := ne_of_gt (by omega : 2 < p)
  have hodd : p % 2 = 1 := (Nat.Prime.mod_two_eq_one_iff_ne_two hp).2 h2
  have hmod3ne0 : p % 3 ≠ 0 := by
    intro h
    have hdiv : 3 ∣ p := Nat.dvd_iff_mod_eq_zero.mpr h
    rcases (Nat.dvd_prime hp).mp hdiv with h1 | hp3eq
    · omega
    · omega
  have hmod3lt : p % 3 < 3 := Nat.mod_lt p (by omega : 0 < 3)
  have hmod3 : p % 3 = 1 ∨ p % 3 = 2 := by
    interval_cases h : p % 3 <;> simp_all
  rcases hmod3 with h3 | h3
  · exact Or.inl (by omega)
  · exact Or.inr (by omega)

theorem IsPrimeAxisA_iff_mod6 (n : ℕ) :
    IsPrimeAxisA n ↔ n % 6 = 1 := Iff.rfl

theorem IsPrimeAxisBC_iff_mod6 (n : ℕ) :
    IsPrimeAxisBC n ↔ n % 6 = 5 := Iff.rfl

theorem prime_gt_three_is_prime_axis (p : ℕ) (hp : Nat.Prime p) (hp3 : 3 < p) :
    IsPrimeAxisA p ∨ IsPrimeAxisBC p := by
  rcases prime_gt_three_mod_six p hp hp3 with h | h
  · exact Or.inl h
  · exact Or.inr h

end KeplerHurwitz
