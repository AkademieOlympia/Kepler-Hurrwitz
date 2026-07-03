import Mathlib
import KeplerHurwitz.CollatzNormShell

namespace KeplerHurwitz

/--
Neuer Collatz-Beweisversuch (Phase V2):
Fallanalyse auf ungeraden Startwerten modulo `4`.
-/
def CollatzAttemptV2Mod4EqOneShrink : Prop :=
  ∀ n > 1, n % 4 = 1 → (3 * n + 1) / 4 < n

/--
Kernlemma des neuen Beweisversuchs:
Im Restklassenfall `n ≡ 1 (mod 4)` sinkt der ungerade Kern nach `3n+1` strikt.
-/
theorem three_mul_add_one_quarter_lt_of_mod4_eq_one
    (hn : 1 < n) (hmod : n % 4 = 1) :
    (3 * n + 1) / 4 < n := by
  let k := n / 4
  have hk : n = 4 * k + 1 := by
    calc
      n = n % 4 + 4 * (n / 4) := by
            simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
              (Nat.mod_add_div n 4).symm
      _ = 1 + 4 * (n / 4) := by simp [hmod]
      _ = 4 * k + 1 := by simp [k, Nat.add_comm]
  have hk_pos : 1 ≤ k := by
    omega
  calc
    (3 * n + 1) / 4
        = (3 * (4 * k + 1) + 1) / 4 := by simp [hk]
    _ = 3 * k + 1 := by omega
    _ < 4 * k + 1 := by omega
    _ = n := by simp [hk]

theorem collatz_attempt_v2_case_mod4_eq_one : CollatzAttemptV2Mod4EqOneShrink := by
  intro n hn hmod
  exact three_mul_add_one_quarter_lt_of_mod4_eq_one hn hmod

/--
Offener Zweig des V2-Versuchs auf Form der Existenz eines Abstiegsschritts.
-/
def CollatzAttemptV2OpenCase : Prop :=
  ∀ n > 1, n % 4 = 3 → ∃ t, Nat.iterate collatzStep t n < n

namespace CollatzAttemptV2

/--
Beschleunigter ungerader Schritt.
-/
def T_odd (n : Nat) : Nat :=
  (3 * n + 1) / 2

/--
Grobe V2-Stueckdefinition:
- `n ≡ 1 (mod 4)`: lokaler Shrink
- `n ≡ 3 (mod 4)`: ungerader Beschleunigungsschritt
- sonst: Halbierung
-/
def T_v2 (n : Nat) : Nat :=
  if n % 4 = 1 then
    (3 * n + 1) / 4
  else if n % 4 = 3 then
    T_odd n
  else
    n / 2

theorem exists_eq_four_mul_add_three_of_mod4_eq_three
    {n : Nat} (hmod : n % 4 = 3) :
    ∃ k, n = 4 * k + 3 := by
  refine ⟨n / 4, ?_⟩
  calc
    n = n % 4 + 4 * (n / 4) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n 4).symm
    _ = 3 + 4 * (n / 4) := by simp [hmod]
    _ = 4 * (n / 4) + 3 := by omega

theorem T_odd_of_four_mul_add_three (k : Nat) :
    T_odd (4 * k + 3) = 6 * k + 5 := by
  unfold T_odd
  omega

theorem mod4_eq_three_step_is_odd
    {n : Nat}
    (hmod : n % 4 = 3) :
    T_odd n % 2 = 1 := by
  rcases exists_eq_four_mul_add_three_of_mod4_eq_three hmod with ⟨k, rfl⟩
  rw [T_odd_of_four_mul_add_three]
  omega

theorem mod4_eq_three_next_split
    {n : Nat}
    (hmod : n % 4 = 3) :
    T_odd n % 4 = 1 ∨ T_odd n % 4 = 3 := by
  rcases exists_eq_four_mul_add_three_of_mod4_eq_three hmod with ⟨k, rfl⟩
  rw [T_odd_of_four_mul_add_three]
  omega

theorem one_lt_T_odd_of_one_lt_and_mod4_eq_three
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 3) :
    1 < T_odd n := by
  rcases exists_eq_four_mul_add_three_of_mod4_eq_three hmod with ⟨k, rfl⟩
  rw [T_odd_of_four_mul_add_three]
  omega

theorem mod4_eq_three_then_good_or_open
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 3) :
    (T_odd n % 4 = 1 ∧ (3 * T_odd n + 1) / 4 < T_odd n)
      ∨
    T_odd n % 4 = 3 := by
  rcases mod4_eq_three_next_split hmod with h1 | h3
  · left
    refine ⟨h1, ?_⟩
    exact three_mul_add_one_quarter_lt_of_mod4_eq_one
      (n := T_odd n)
      (one_lt_T_odd_of_one_lt_and_mod4_eq_three hn hmod)
      h1
  · exact Or.inr h3

theorem exists_eq_eight_mul_add_three_of_mod8_eq_three
    {n : Nat} (hmod : n % 8 = 3) :
    ∃ k, n = 8 * k + 3 := by
  refine ⟨n / 8, ?_⟩
  calc
    n = n % 8 + 8 * (n / 8) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n 8).symm
    _ = 3 + 8 * (n / 8) := by simp [hmod]
    _ = 8 * (n / 8) + 3 := by omega

theorem exists_eq_eight_mul_add_seven_of_mod8_eq_seven
    {n : Nat} (hmod : n % 8 = 7) :
    ∃ k, n = 8 * k + 7 := by
  refine ⟨n / 8, ?_⟩
  calc
    n = n % 8 + 8 * (n / 8) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n 8).symm
    _ = 7 + 8 * (n / 8) := by simp [hmod]
    _ = 8 * (n / 8) + 7 := by omega

theorem T_odd_of_eight_mul_add_three (k : Nat) :
    T_odd (8 * k + 3) = 12 * k + 5 := by
  calc
    T_odd (8 * k + 3)
        = T_odd (4 * (2 * k) + 3) := by ring_nf
    _ = 6 * (2 * k) + 5 := by rw [T_odd_of_four_mul_add_three]
    _ = 12 * k + 5 := by ring_nf

theorem T_odd_of_eight_mul_add_seven (k : Nat) :
    T_odd (8 * k + 7) = 12 * k + 11 := by
  calc
    T_odd (8 * k + 7)
        = T_odd (4 * (2 * k + 1) + 3) := by ring_nf
    _ = 6 * (2 * k + 1) + 5 := by rw [T_odd_of_four_mul_add_three]
    _ = 12 * k + 11 := by ring_nf

theorem T_odd_mod4_eq_one_of_mod8_eq_three
    {n : Nat}
    (hmod : n % 8 = 3) :
    T_odd n % 4 = 1 := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three hmod with ⟨k, rfl⟩
  rw [T_odd_of_eight_mul_add_three]
  omega

theorem T_odd_mod4_eq_three_of_mod8_eq_seven
    {n : Nat}
    (hmod : n % 8 = 7) :
    T_odd n % 4 = 3 := by
  rcases exists_eq_eight_mul_add_seven_of_mod8_eq_seven hmod with ⟨k, rfl⟩
  rw [T_odd_of_eight_mul_add_seven]
  omega

end CollatzAttemptV2

end KeplerHurwitz
