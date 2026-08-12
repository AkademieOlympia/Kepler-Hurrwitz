/-
  Klein four-group model of (ℤ/12ℤ)ˣ for the EABC core (coprime to 6).

  CRT picture:
    (ℤ/12ℤ)ˣ ≅ (ℤ/3ℤ)ˣ × (ℤ/4ℤ)ˣ ≅ C₂ × C₂ ≅ V₄

  Channel labelling (mod-12 units):
    1 ↦ E=(0,0),  5 ↦ A=(1,0),  7 ↦ B=(0,1),  11 ↦ C=(1,1)

  Distinct from Collatz mod-8 Klein classes and from `V4Raum` geometry.
  Docs: `docs/eabc_normal_form.md` § V₄.
-/

import Mathlib

namespace KeplerHurwitz.EABC

/-! ## Klein four-group as EABC channel algebra -/

/-- The Klein four-group as EABC channel labels. -/
inductive V4
  | E -- (0,0), class 1 mod 12
  | A -- (1,0), class 5 mod 12
  | B -- (0,1), class 7 mod 12
  | C -- (1,1), class 11 mod 12
  deriving DecidableEq, Repr

/-- Multiplicative law of \(V_4\) (channel product). -/
def V4.mul : V4 → V4 → V4
  | .E, x | x, .E => x
  | .A, .A | .B, .B | .C, .C => .E
  | .A, .B | .B, .A => .C
  | .A, .C | .C, .A => .B
  | .B, .C | .C, .B => .A

instance : Mul V4 := ⟨V4.mul⟩
instance : One V4 := ⟨V4.E⟩
instance : Inv V4 := ⟨id⟩

@[simp] theorem V4.one_eq : (1 : V4) = V4.E := rfl
@[simp] theorem V4.inv_eq (x : V4) : x⁻¹ = x := rfl

theorem V4.mul_comm (x y : V4) : x * y = y * x := by
  cases x <;> cases y <;> rfl

theorem V4.mul_assoc (x y z : V4) : x * y * z = x * (y * z) := by
  cases x <;> cases y <;> cases z <;> rfl

theorem V4.one_mul (x : V4) : (1 : V4) * x = x := by cases x <;> rfl
theorem V4.mul_one (x : V4) : x * (1 : V4) = x := by cases x <;> rfl
theorem V4.inv_mul_cancel (x : V4) : x⁻¹ * x = 1 := by cases x <;> rfl

instance : CommGroup V4 where
  mul := (· * ·)
  mul_assoc := V4.mul_assoc
  one := 1
  one_mul := V4.one_mul
  mul_one := V4.mul_one
  inv := (·⁻¹)
  inv_mul_cancel := V4.inv_mul_cancel
  mul_comm := V4.mul_comm

/-- Every element has order dividing 2. -/
theorem V4.mul_self (x : V4) : x * x = 1 := by cases x <;> rfl

/-- CRT / \(\mathbb F_2^2\) coordinates \((a,b)\). -/
def V4.toF2 (x : V4) : Bool × Bool :=
  match x with
  | .E => (false, false)
  | .A => (true, false)
  | .B => (false, true)
  | .C => (true, true)

def V4.ofF2 : Bool × Bool → V4
  | (false, false) => .E
  | (true, false) => .A
  | (false, true) => .B
  | (true, true) => .C

theorem V4.ofF2_toF2 (x : V4) : V4.ofF2 x.toF2 = x := by cases x <;> rfl

theorem V4.toF2_mul (x y : V4) :
    (x * y).toF2 = (xor x.toF2.1 y.toF2.1, xor x.toF2.2 y.toF2.2) := by
  cases x <;> cases y <;> rfl

/-! ## Projection of units mod 12 -/

theorem odd_of_coprime_six {n : ℕ} (h : Nat.Coprime n 6) : Odd n := by
  rw [Nat.odd_iff]
  by_contra hEven
  have h2 : n % 2 = 0 := Nat.mod_two_ne_one.mp hEven
  have hd : 2 ∣ n := Nat.dvd_iff_mod_eq_zero.mpr h2
  have hgcd : Nat.gcd n 6 = 1 := h
  have : 2 ∣ Nat.gcd n 6 := Nat.dvd_gcd hd (by decide)
  rw [hgcd] at this
  exact absurd this (by decide : ¬ 2 ∣ 1)

theorem not_mod3_zero_of_coprime_six {n : ℕ} (h : Nat.Coprime n 6) : n % 3 ≠ 0 := by
  intro h0
  have hd : 3 ∣ n := Nat.dvd_iff_mod_eq_zero.mpr h0
  have hgcd : Nat.gcd n 6 = 1 := h
  have : 3 ∣ Nat.gcd n 6 := Nat.dvd_gcd hd (by decide)
  rw [hgcd] at this
  exact absurd this (by decide : ¬ 3 ∣ 1)

/-- Units mod 12 are exactly the four residues \(\{1,5,7,11\}\). -/
theorem coprime_six_mod12 {n : ℕ} (h : Nat.Coprime n 6) :
    n % 12 = 1 ∨ n % 12 = 5 ∨ n % 12 = 7 ∨ n % 12 = 11 := by
  have h2 : n % 2 = 1 := Nat.odd_iff.mp (odd_of_coprime_six h)
  have h3 : n % 3 ≠ 0 := not_mod3_zero_of_coprime_six h
  have h2' : (n % 12) % 2 = n % 2 := Nat.mod_mod_of_dvd n (by decide : 2 ∣ 12)
  have h3' : (n % 12) % 3 = n % 3 := Nat.mod_mod_of_dvd n (by decide : 3 ∣ 12)
  have hlt : n % 12 < 12 := Nat.mod_lt n (by decide)
  interval_cases r : n % 12
  · -- 0 even
    have : n % 2 = 0 := by simpa [r] using h2'.symm
    omega
  · exact Or.inl rfl
  · have : n % 2 = 0 := by simpa [r] using h2'.symm
    omega
  · -- 3
    have : n % 3 = 0 := by simpa [r] using h3'.symm
    exact (h3 this).elim
  · have : n % 2 = 0 := by simpa [r] using h2'.symm
    omega
  · exact Or.inr (Or.inl rfl)
  · have : n % 2 = 0 := by simpa [r] using h2'.symm
    omega
  · exact Or.inr (Or.inr (Or.inl rfl))
  · have : n % 2 = 0 := by simpa [r] using h2'.symm
    omega
  · -- 9
    have : n % 3 = 0 := by simpa [r] using h3'.symm
    exact (h3 this).elim
  · have : n % 2 = 0 := by simpa [r] using h2'.symm
    omega
  · exact Or.inr (Or.inr (Or.inr rfl))

/-- Project a number coprime to 6 onto \(V_4\) via its residue mod 12. -/
def toV4 (n : ℕ) (_h : Nat.Coprime n 6) : V4 :=
  match n % 12 with
  | 1 => V4.E
  | 5 => V4.A
  | 7 => V4.B
  | _ => V4.C

theorem toV4_one : toV4 1 (by decide) = V4.E := rfl

theorem toV4_of_mod12_one {n : ℕ} (h : Nat.Coprime n 6) (h1 : n % 12 = 1) :
    toV4 n h = V4.E := by simp [toV4, h1]

theorem toV4_of_mod12_five {n : ℕ} (h : Nat.Coprime n 6) (h5 : n % 12 = 5) :
    toV4 n h = V4.A := by simp [toV4, h5]

theorem toV4_of_mod12_seven {n : ℕ} (h : Nat.Coprime n 6) (h7 : n % 12 = 7) :
    toV4 n h = V4.B := by simp [toV4, h7]

theorem toV4_of_mod12_eleven {n : ℕ} (h : Nat.Coprime n 6) (h11 : n % 12 = 11) :
    toV4 n h = V4.C := by simp [toV4, h11]

theorem toV4_eq_of_mod12 {n : ℕ} (h : Nat.Coprime n 6) :
    (n % 12 = 1 ∧ toV4 n h = V4.E) ∨
    (n % 12 = 5 ∧ toV4 n h = V4.A) ∨
    (n % 12 = 7 ∧ toV4 n h = V4.B) ∨
    (n % 12 = 11 ∧ toV4 n h = V4.C) := by
  rcases coprime_six_mod12 h with h1 | h5 | h7 | h11
  · left; exact ⟨h1, toV4_of_mod12_one h h1⟩
  · right; left; exact ⟨h5, toV4_of_mod12_five h h5⟩
  · right; right; left; exact ⟨h7, toV4_of_mod12_seven h h7⟩
  · right; right; right; exact ⟨h11, toV4_of_mod12_eleven h h11⟩

/-- Residue multiplication matches \(V_4\) multiplication. -/
theorem toV4_mul {a b : ℕ} (ha : Nat.Coprime a 6) (hb : Nat.Coprime b 6) :
    toV4 (a * b) (Nat.Coprime.mul_left ha hb) = toV4 a ha * toV4 b hb := by
  rcases toV4_eq_of_mod12 ha with ⟨ha1, haE⟩ | ⟨ha5, haA⟩ | ⟨ha7, haB⟩ | ⟨ha11, haC⟩
  · rcases toV4_eq_of_mod12 hb with ⟨hb1, hbE⟩ | ⟨hb5, hbA⟩ | ⟨hb7, hbB⟩ | ⟨hb11, hbC⟩
    · have hmod : (a * b) % 12 = 1 := by simp [Nat.mul_mod, ha1, hb1]
      rw [haE, hbE, toV4_of_mod12_one _ hmod]; rfl
    · have hmod : (a * b) % 12 = 5 := by simp [Nat.mul_mod, ha1, hb5]
      rw [haE, hbA, toV4_of_mod12_five _ hmod]; rfl
    · have hmod : (a * b) % 12 = 7 := by simp [Nat.mul_mod, ha1, hb7]
      rw [haE, hbB, toV4_of_mod12_seven _ hmod]; rfl
    · have hmod : (a * b) % 12 = 11 := by simp [Nat.mul_mod, ha1, hb11]
      rw [haE, hbC, toV4_of_mod12_eleven _ hmod]; rfl
  · rcases toV4_eq_of_mod12 hb with ⟨hb1, hbE⟩ | ⟨hb5, hbA⟩ | ⟨hb7, hbB⟩ | ⟨hb11, hbC⟩
    · have hmod : (a * b) % 12 = 5 := by simp [Nat.mul_mod, ha5, hb1]
      rw [haA, hbE, toV4_of_mod12_five _ hmod]; rfl
    · have hmod : (a * b) % 12 = 1 := by simp [Nat.mul_mod, ha5, hb5]
      rw [haA, hbA, toV4_of_mod12_one _ hmod]; rfl
    · have hmod : (a * b) % 12 = 11 := by simp [Nat.mul_mod, ha5, hb7]
      rw [haA, hbB, toV4_of_mod12_eleven _ hmod]; rfl
    · have hmod : (a * b) % 12 = 7 := by simp [Nat.mul_mod, ha5, hb11]
      rw [haA, hbC, toV4_of_mod12_seven _ hmod]; rfl
  · rcases toV4_eq_of_mod12 hb with ⟨hb1, hbE⟩ | ⟨hb5, hbA⟩ | ⟨hb7, hbB⟩ | ⟨hb11, hbC⟩
    · have hmod : (a * b) % 12 = 7 := by simp [Nat.mul_mod, ha7, hb1]
      rw [haB, hbE, toV4_of_mod12_seven _ hmod]; rfl
    · have hmod : (a * b) % 12 = 11 := by simp [Nat.mul_mod, ha7, hb5]
      rw [haB, hbA, toV4_of_mod12_eleven _ hmod]; rfl
    · have hmod : (a * b) % 12 = 1 := by simp [Nat.mul_mod, ha7, hb7]
      rw [haB, hbB, toV4_of_mod12_one _ hmod]; rfl
    · have hmod : (a * b) % 12 = 5 := by simp [Nat.mul_mod, ha7, hb11]
      rw [haB, hbC, toV4_of_mod12_five _ hmod]; rfl
  · rcases toV4_eq_of_mod12 hb with ⟨hb1, hbE⟩ | ⟨hb5, hbA⟩ | ⟨hb7, hbB⟩ | ⟨hb11, hbC⟩
    · have hmod : (a * b) % 12 = 11 := by simp [Nat.mul_mod, ha11, hb1]
      rw [haC, hbE, toV4_of_mod12_eleven _ hmod]; rfl
    · have hmod : (a * b) % 12 = 7 := by simp [Nat.mul_mod, ha11, hb5]
      rw [haC, hbA, toV4_of_mod12_seven _ hmod]; rfl
    · have hmod : (a * b) % 12 = 5 := by simp [Nat.mul_mod, ha11, hb7]
      rw [haC, hbB, toV4_of_mod12_five _ hmod]; rfl
    · have hmod : (a * b) % 12 = 1 := by simp [Nat.mul_mod, ha11, hb11]
      rw [haC, hbC, toV4_of_mod12_one _ hmod]; rfl

end KeplerHurwitz.EABC
