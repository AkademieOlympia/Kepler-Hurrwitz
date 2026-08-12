/-
  30-block color involution for EABC candidate quadruples.

  Math:
    x |-> x+30  ==>  x ≡ x+6 (mod 12)
    τ = (E B)(A C) on V4-channels {E,A,B,C} ≅ (Z/12Z)^×
    Target [A]:  Π(Q+30) = τ(Π(Q))  (coordinatewise)

  Epistemic split (see energiedoku note):
    [A]  color law / involution / coordinatewise Π-shift  — proved here
    [B]  |R_16|=14, |B_16|=10 on the finite K=16 lattice — audit only
    [C-H10] stabilization K→∞, nontrivial D_Π, asymptotic channel diffs — open

  Π is an order observable on a 4-config (classification triple
  (Φ_lattice, r, Π)); it is **not** a fifth algebraic EABC object.
-/

import KeplerHurwitz.EABC.V4

namespace KeplerHurwitz.EABC

/-! ## Color involution τ = (E B)(A C) -/

/--
Color involution induced by a 30-block shift (`30 ≡ 6 (mod 12)`):
`E ↔ B`, `A ↔ C`.
-/
def colorTau : V4 → V4
  | .E => .B
  | .B => .E
  | .A => .C
  | .C => .A

@[simp] theorem colorTau_E : colorTau V4.E = V4.B := rfl
@[simp] theorem colorTau_A : colorTau V4.A = V4.C := rfl
@[simp] theorem colorTau_B : colorTau V4.B = V4.E := rfl
@[simp] theorem colorTau_C : colorTau V4.C = V4.A := rfl

/-- τ is an involution. -/
theorem colorTau_involutive (x : V4) : colorTau (colorTau x) = x := by
  cases x <;> rfl

theorem colorTau_bijective : Function.Bijective colorTau :=
  Function.Involutive.bijective colorTau_involutive

/-! ## Residue arithmetic: +30 ≡ +6 (mod 12) -/

theorem add_thirty_mod12 (n : ℕ) : (n + 30) % 12 = (n + 6) % 12 := by
  have h : n + 30 = (n + 6) + 2 * 12 := by omega
  rw [h, Nat.add_mul_mod_self_right]

/-- Adding `30 = 5·6` preserves coprimality to 6. -/
theorem coprime_six_add_thirty {n : ℕ} (h : Nat.Coprime n 6) :
    Nat.Coprime (n + 30) 6 := by
  have hEq : n + 30 = n + 5 * 6 := by omega
  rw [Nat.coprime_iff_gcd_eq_one] at h ⊢
  rw [hEq, Nat.gcd_add_mul_right_left, h]

/--
[A] Single-coordinate color law: shifting by 30 applies τ on `V₄`.
-/
theorem toV4_add_thirty {n : ℕ} (h : Nat.Coprime n 6) :
    toV4 (n + 30) (coprime_six_add_thirty h) = colorTau (toV4 n h) := by
  rcases toV4_eq_of_mod12 h with ⟨h1, _hE⟩ | ⟨h5, _hA⟩ | ⟨h7, _hB⟩ | ⟨h11, _hC⟩
  · have hmod : (n + 30) % 12 = 7 := by
      rw [add_thirty_mod12, Nat.add_mod, h1]
    simp [toV4, h1, hmod, colorTau]
  · have hmod : (n + 30) % 12 = 11 := by
      rw [add_thirty_mod12, Nat.add_mod, h5]
    simp [toV4, h5, hmod, colorTau]
  · have hmod : (n + 30) % 12 = 1 := by
      rw [add_thirty_mod12, Nat.add_mod, h7]
    simp [toV4, h7, hmod, colorTau]
  · have hmod : (n + 30) % 12 = 5 := by
      rw [add_thirty_mod12, Nat.add_mod, h11]
    simp [toV4, h11, hmod, colorTau]

/-! ## Classification word Π(Q) as 4-tuple of channels -/

/-- Color word / permutation observable Π on a 4-config. -/
abbrev ColorWord := V4 × V4 × V4 × V4

/-- Coordinatewise color involution on words. -/
def colorTauWord : ColorWord → ColorWord
  | (w₁, w₂, w₃, w₄) => (colorTau w₁, colorTau w₂, colorTau w₃, colorTau w₄)

theorem colorTauWord_involutive (w : ColorWord) :
    colorTauWord (colorTauWord w) = w := by
  rcases w with ⟨w₁, w₂, w₃, w₄⟩
  simp [colorTauWord, colorTau_involutive]

/--
Π(Q) for Q = (x₁,x₂,x₃,x₄) with each coordinate coprime to 6.
Order observable on the 4-config — not a fifth algebraic EABC object.
-/
def permutationOf (x₁ x₂ x₃ x₄ : ℕ)
    (h₁ : Nat.Coprime x₁ 6) (h₂ : Nat.Coprime x₂ 6)
    (h₃ : Nat.Coprime x₃ 6) (h₄ : Nat.Coprime x₄ 6) : ColorWord :=
  (toV4 x₁ h₁, toV4 x₂ h₂, toV4 x₃ h₃, toV4 x₄ h₄)

/-- Coordinatewise +30 shift. -/
def shift30Quad (x₁ x₂ x₃ x₄ : ℕ) : ℕ × ℕ × ℕ × ℕ :=
  (x₁ + 30, x₂ + 30, x₃ + 30, x₄ + 30)

/--
[A] Target theorem: `permutation_of(Q+30) = τ(permutation_of(Q))`
(coordinatewise 30-block shift).
-/
theorem permutationOf_shift30
    (x₁ x₂ x₃ x₄ : ℕ)
    (h₁ : Nat.Coprime x₁ 6) (h₂ : Nat.Coprime x₂ 6)
    (h₃ : Nat.Coprime x₃ 6) (h₄ : Nat.Coprime x₄ 6) :
    permutationOf (x₁ + 30) (x₂ + 30) (x₃ + 30) (x₄ + 30)
        (coprime_six_add_thirty h₁) (coprime_six_add_thirty h₂)
        (coprime_six_add_thirty h₃) (coprime_six_add_thirty h₄) =
      colorTauWord (permutationOf x₁ x₂ x₃ x₄ h₁ h₂ h₃ h₄) := by
  unfold permutationOf colorTauWord
  rw [toV4_add_thirty h₁, toV4_add_thirty h₂, toV4_add_thirty h₃, toV4_add_thirty h₄]

/-!
## [B] Finite K=16 lattice notes (not universal)

The Python audit (`eabc_candidate_quad_index.py`) enumerates the K=16
residue patterns in one 30-block and finds |R_16|=14 realizable /
|B_16|=10 blocked color words. That is a **finite lattice finding**.

Do **not** promote `|R|=14` to all K, nor claim D_Π-density / Collatz.
Closure `τ(R)=R`, `τ(B)=B` on that finite image follows from
`permutationOf_shift30` once R/B are defined as pattern images;
the cardinality count remains `[B]` audit tooling.

[C-H10] open: stabilization K→∞, nontrivial D_Π, asymptotic channel differences.
-/

/-- Witness: CEAB on (11,13,17,19) flips to ABCE after +30. -/
example :
    let Q := permutationOf 11 13 17 19 (by decide) (by decide) (by decide) (by decide)
    let Q' := permutationOf 41 43 47 49 (by decide) (by decide) (by decide) (by decide)
    Q = (V4.C, V4.E, V4.A, V4.B) ∧
      Q' = colorTauWord Q ∧
      Q' = (V4.A, V4.B, V4.C, V4.E) := by
  native_decide

end KeplerHurwitz.EABC
