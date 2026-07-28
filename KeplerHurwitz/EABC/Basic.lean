/-
  EABC mod-8 residue classes on odd naturals, sum-of-two-squares bridge,
  and divisibility poset (type synonym — does **not** replace `Nat.le`).

  Naming note:
  * This file uses the classical **mod-8** labels E/A/B/C on odd `n`
    (`n % 8 ∈ {1,5,3,7}`).
  * The project's mass/channel map in `docs/eabc_mass_convention.md` uses
    **mod-12** residues `{1,5,7,11}` via `eabc_channel_from_mod12`.
  * Abstract channels `KeplerHurwitz.EABCChannel` carry no residue law.
  Do not identify the three layers without an explicit bridge lemma.
-/

import Mathlib
import Mathlib.NumberTheory.SumTwoSquares

namespace KeplerHurwitz.EABC

/-!
# Mod-8 EABC classes and divisibility structures
-/

/-- Odd residue classes mod 8 (number-theoretic EABC naming). -/
inductive EABCClass
  | E -- 1 mod 8
  | A -- 5 mod 8
  | B -- 3 mod 8
  | C -- 7 mod 8
  deriving DecidableEq, Repr

/-- `n` in class E. -/
def isE (n : ℕ) : Prop := n % 8 = 1

/-- `n` in class A. -/
def isA (n : ℕ) : Prop := n % 8 = 5

/-- `n` in class B. -/
def isB (n : ℕ) : Prop := n % 8 = 3

/-- `n` in class C. -/
def isC (n : ℕ) : Prop := n % 8 = 7

instance (n : ℕ) : Decidable (isE n) := inferInstanceAs (Decidable (n % 8 = 1))
instance (n : ℕ) : Decidable (isA n) := inferInstanceAs (Decidable (n % 8 = 5))
instance (n : ℕ) : Decidable (isB n) := inferInstanceAs (Decidable (n % 8 = 3))
instance (n : ℕ) : Decidable (isC n) := inferInstanceAs (Decidable (n % 8 = 7))

theorem odd_mod8_eq_one_three_five_or_seven {n : ℕ} (h : Odd n) :
    n % 8 = 1 ∨ n % 8 = 3 ∨ n % 8 = 5 ∨ n % 8 = 7 := by
  have h2 : n % 2 = 1 := Nat.odd_iff.mp h
  have hlt : n % 8 < 8 := Nat.mod_lt _ (by decide)
  interval_cases hmod : n % 8
  · -- 0 even
    omega
  · exact Or.inl rfl
  · omega
  · exact Or.inr (Or.inl rfl)
  · omega
  · exact Or.inr (Or.inr (Or.inl rfl))
  · omega
  · exact Or.inr (Or.inr (Or.inr rfl))

/-- Classify an odd natural by its mod-8 EABC class. -/
def classify (n : ℕ) (_h : Odd n) : EABCClass :=
  match n % 8 with
  | 1 => EABCClass.E
  | 5 => EABCClass.A
  | 3 => EABCClass.B
  | _ => EABCClass.C

theorem classify_isE {n : ℕ} (h : Odd n) (hE : isE n) :
    classify n h = EABCClass.E := by
  unfold classify isE at *
  simp [hE]

theorem classify_isA {n : ℕ} (h : Odd n) (hA : isA n) :
    classify n h = EABCClass.A := by
  unfold classify isA at *
  simp [hA]

theorem classify_isB {n : ℕ} (h : Odd n) (hB : isB n) :
    classify n h = EABCClass.B := by
  unfold classify isB at *
  simp [hB]

theorem classify_isC {n : ℕ} (h : Odd n) (hC : isC n) :
    classify n h = EABCClass.C := by
  unfold classify isC at *
  -- residual match arm for `% 8 = 7`
  simp [hC]

theorem classify_spec {n : ℕ} (h : Odd n) :
    (classify n h = EABCClass.E ∧ isE n) ∨
    (classify n h = EABCClass.A ∧ isA n) ∨
    (classify n h = EABCClass.B ∧ isB n) ∨
    (classify n h = EABCClass.C ∧ isC n) := by
  rcases odd_mod8_eq_one_three_five_or_seven h with h1 | h3 | h5 | h7
  · left; exact ⟨classify_isE h h1, h1⟩
  · right; right; left; exact ⟨classify_isB h h3, h3⟩
  · right; left; exact ⟨classify_isA h h5, h5⟩
  · right; right; right; exact ⟨classify_isC h h7, h7⟩

/-! ## Odd squares land in E; classical sum of two squares -/

/-- Every odd square is ≡ 1 (mod 8), i.e. in class E. -/
theorem odd_sq_isE {x : ℕ} (hx : Odd x) : isE (x ^ 2) := by
  rw [isE, Nat.pow_mod]
  have : x % 8 = 1 ∨ x % 8 = 3 ∨ x % 8 = 5 ∨ x % 8 = 7 :=
    odd_mod8_eq_one_three_five_or_seven hx
  rcases this with h | h | h | h <;> simp [h]

/-- Draft predicate from the structural sketch: both squares in class E.
For odd `x,y` this is automatic (`odd_sq_isE`); the sum is then ≡ 2 (mod 8),
so **no odd prime** satisfies it. Kept for documentation; prefer
`IsSumOfTwoSquares` below for Fermat's theorem. -/
def IsSumOfTwoSquaresInE (n : ℕ) : Prop :=
  ∃ x y : ℕ, isE (x ^ 2) ∧ isE (y ^ 2) ∧ n = x ^ 2 + y ^ 2

theorem IsSumOfTwoSquaresInE.mod8_eq_two {n : ℕ}
    (h : IsSumOfTwoSquaresInE n) : n % 8 = 2 := by
  obtain ⟨x, y, hx, hy, rfl⟩ := h
  have hx' : x ^ 2 % 8 = 1 := hx
  have hy' : y ^ 2 % 8 = 1 := hy
  omega

/-- Classical sum of two squares (no E-restriction on the summands). -/
def IsSumOfTwoSquares (n : ℕ) : Prop :=
  ∃ x y : ℕ, n = x ^ 2 + y ^ 2

/-- Odd `n`: class E or A ⇔ `n ≡ 1 (mod 4)`. -/
theorem isE_or_isA_iff_mod4_eq_one {n : ℕ} (hodd : Odd n) :
    (isE n ∨ isA n) ↔ n % 4 = 1 := by
  have h8 := odd_mod8_eq_one_three_five_or_seven hodd
  constructor
  · intro h
    rcases h with h | h <;> simp [isE, isA] at h <;> omega
  · intro h
    rcases h8 with h1 | h3 | h5 | h7
    · left; exact h1
    · have : n % 4 = 3 := by omega
      omega
    · right; exact h5
    · have : n % 4 = 3 := by omega
      omega

theorem sq_mod_four (a : ℕ) : a ^ 2 % 4 = 0 ∨ a ^ 2 % 4 = 1 := by
  have h : a % 4 = 0 ∨ a % 4 = 1 ∨ a % 4 = 2 ∨ a % 4 = 3 := by omega
  rw [Nat.pow_mod]
  rcases h with h | h | h | h <;> simp [h]

theorem not_mod4_eq_three_of_sum_two_squares {n a b : ℕ}
    (h : n = a ^ 2 + b ^ 2) : n % 4 ≠ 3 := by
  have ha := sq_mod_four a
  have hb := sq_mod_four b
  omega

/-- Fermat (Christmas): an odd prime is a sum of two squares iff it lies in
mod-8 class E or A (equivalently `p ≡ 1 (mod 4)`). -/
theorem odd_prime_sum_of_two_squares_iff_EA {p : ℕ} [Fact p.Prime]
    (hp2 : p ≠ 2) :
    IsSumOfTwoSquares p ↔ (isE p ∨ isA p) := by
  have hp : p.Prime := Fact.out
  have hodd : Odd p := Nat.Prime.odd_of_ne_two hp hp2
  constructor
  · intro ⟨x, y, hxy⟩
    have h4 : p % 4 ≠ 3 := not_mod4_eq_three_of_sum_two_squares hxy
    have : p % 4 = 1 := by
      have : p % 4 = 1 ∨ p % 4 = 3 := by
        have := Nat.odd_iff.mp hodd
        omega
      omega
    exact (isE_or_isA_iff_mod4_eq_one hodd).2 this
  · intro hEA
    have h4 : p % 4 = 1 := (isE_or_isA_iff_mod4_eq_one hodd).1 hEA
    have hne : p % 4 ≠ 3 := by omega
    obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq (p := p) hne
    exact ⟨a, b, hab.symm⟩

/-- Alias matching the structural draft name (corrected statement). -/
theorem sum_of_squares_restricted {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) :
    IsSumOfTwoSquares p ↔ (isE p ∨ isA p) :=
  odd_prime_sum_of_two_squares_iff_EA hp2

/-! ## Divisibility poset (type synonym — safe for Dilworth/antichain work) -/

/-- `ℕ` with the divisibility order `a ≤ b ↔ a ∣ b`.
Kept as a **structure** so this does not replace the standard order on `ℕ`. -/
structure DvdNat where
  toNat : ℕ

namespace DvdNat

instance instPartialOrder : PartialOrder DvdNat where
  le a b := a.toNat ∣ b.toNat
  le_refl _ := Nat.dvd_refl _
  le_trans _ _ _ := Nat.dvd_trans
  le_antisymm a b h₁ h₂ := by
    cases a; cases b
    exact congrArg DvdNat.mk (Nat.dvd_antisymm h₁ h₂)

@[simp] theorem le_iff_dvd (a b : DvdNat) : a ≤ b ↔ a.toNat ∣ b.toNat := Iff.rfl

end DvdNat

/-- Antichain in the divisibility poset (on ordinary `ℕ`). -/
def IsEABCAntichain (S : Set ℕ) : Prop :=
  ∀ ⦃x⦄, x ∈ S → ∀ ⦃y⦄, y ∈ S → x ≠ y → ¬x ∣ y

theorem IsEABCAntichain.pair {S : Set ℕ} (h : IsEABCAntichain S)
    {x y : ℕ} (hx : x ∈ S) (hy : y ∈ S) (hne : x ≠ y) : ¬x ∣ y :=
  h hx hy hne

/-- Singleton sets are antichains. -/
theorem singleton_antichain (n : ℕ) : IsEABCAntichain ({n} : Set ℕ) := by
  intro x hx y hy hne
  simp at hx hy
  exact (hne (hx.trans hy.symm)).elim

end KeplerHurwitz.EABC
