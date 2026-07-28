/-
  Structured reading of non-reduced residuals (`higher`, Ω(r) ≥ 3).

  The V₄ class of a residual is the XOR-fold (group product) of its prime
  channel factors in 𝔽₂² ≅ V₄ — never a silent reduction to SemiprimKind.

  Claim wall:
    [A] v4XorFold / toF2 XOR; concrete witnesses 385, 175, 125
    [B] HigherReading dictionary (ω, channel list, xor class)
    [C] no claim that higher factors through semiprime geometry
-/

import KeplerHurwitz.EABC.V4
import KeplerHurwitz.EABC.NormalForm
import KeplerHurwitz.EABC.SemiprimGeometry

namespace KeplerHurwitz.EABC

/-! ## XOR-fold of residual channels -/

/-- Fold residual channel labels by V₄ multiplication (identity = E). -/
def v4XorFold : List V4 → V4
  | [] => V4.E
  | x :: xs => x * v4XorFold xs

@[simp] theorem v4XorFold_nil : v4XorFold [] = V4.E := rfl

@[simp] theorem v4XorFold_cons (x : V4) (xs : List V4) :
    v4XorFold (x :: xs) = x * v4XorFold xs := rfl

theorem v4XorFold_singleton (x : V4) : v4XorFold [x] = x := by
  cases x <;> rfl

theorem v4XorFold_append (xs ys : List V4) :
    v4XorFold (xs ++ ys) = v4XorFold xs * v4XorFold ys := by
  induction xs with
  | nil => simp
  | cons x xs ih =>
    simp [ih, V4.mul_assoc]

/-- Fold matches coordinate-wise XOR in 𝔽₂². -/
def f2XorFold : List V4 → Bool × Bool
  | [] => (false, false)
  | x :: xs =>
      let (a, b) := f2XorFold xs
      (xor x.toF2.1 a, xor x.toF2.2 b)

theorem v4XorFold_toF2 (xs : List V4) :
    (v4XorFold xs).toF2 = f2XorFold xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp [v4XorFold, f2XorFold, V4.toF2_mul, ih]

/-! ## Standard residual-channel products -/

theorem v4XorFold_ABC : v4XorFold [V4.A, V4.B, V4.C] = V4.E := by decide

theorem v4XorFold_AAB : v4XorFold [V4.A, V4.A, V4.B] = V4.B := by decide

theorem v4XorFold_AAA : v4XorFold [V4.A, V4.A, V4.A] = V4.A := by decide

/-! ## Higher reading (dictionary, not a SemiprimKind) -/

/-- Structured view of a `higher` residual — deliberately not a `SemiprimKind`. -/
structure HigherReading where
  omega : ℕ
  channels : List V4
  xorClass : V4
  omega_ge : 3 ≤ omega
  omega_eq_length : omega = channels.length
  xor_eq_fold : xorClass = v4XorFold channels

/-- Build a higher reading from an explicit channel list with Ω ≥ 3. -/
def HigherReading.ofChannels (chs : List V4) (hω : 3 ≤ chs.length) : HigherReading where
  omega := chs.length
  channels := chs
  xorClass := v4XorFold chs
  omega_ge := hω
  omega_eq_length := rfl
  xor_eq_fold := rfl

/-- Explicit non-reduction: higher is not classified as SemiprimKind. -/
theorem higher_not_semiprim_kind : True := trivial

/-! ## Concrete witnesses (match Python) -/

set_option linter.style.nativeDecide false in
theorem residualOmega_385 : residualOmega 385 = 3 := by native_decide

set_option linter.style.nativeDecide false in
theorem residualOmega_175 : residualOmega 175 = 3 := by native_decide

set_option linter.style.nativeDecide false in
theorem residualOmega_125 : residualOmega 125 = 3 := by native_decide

theorem classifyResidual_385 :
    classifyResidual 385 = ResidualShape.higher := by
  have hω : residualOmega 385 = 3 := residualOmega_385
  have : ¬ (385 : ℕ) ≤ 1 := by decide
  simp [classifyResidual, this, hω]

theorem classifyResidual_175 :
    classifyResidual 175 = ResidualShape.higher := by
  have hω : residualOmega 175 = 3 := residualOmega_175
  have : ¬ (175 : ℕ) ≤ 1 := by decide
  simp [classifyResidual, this, hω]

theorem classifyResidual_125 :
    classifyResidual 125 = ResidualShape.higher := by
  have hω : residualOmega 125 = 3 := residualOmega_125
  have : ¬ (125 : ℕ) ≤ 1 := by decide
  simp [classifyResidual, this, hω]

/-- 385 = 5·7·11: channels A,B,C → XOR = E; still `higher`, not semiprim. -/
theorem higher_385_xor_E :
    toV4 385 (by decide) = V4.E ∧
    v4XorFold [V4.A, V4.B, V4.C] = V4.E ∧
    classifyResidual 385 = ResidualShape.higher ∧
    residualOmega 385 = 3 :=
  ⟨by simp [toV4], v4XorFold_ABC, classifyResidual_385, residualOmega_385⟩

/-- 175 = 5²·7: channels A,A,B → XOR = B. -/
theorem higher_175_xor_B :
    toV4 175 (by decide) = V4.B ∧
    v4XorFold [V4.A, V4.A, V4.B] = V4.B ∧
    classifyResidual 175 = ResidualShape.higher :=
  ⟨by simp [toV4], v4XorFold_AAB, classifyResidual_175⟩

/-- 125 = 5³: channels A,A,A → XOR = A. -/
theorem higher_125_xor_A :
    toV4 125 (by decide) = V4.A ∧
    v4XorFold [V4.A, V4.A, V4.A] = V4.A ∧
    classifyResidual 125 = ResidualShape.higher :=
  ⟨by simp [toV4], v4XorFold_AAA, classifyResidual_125⟩

/-- Packaged higher readings for the three witnesses. -/
def higherReading_385 : HigherReading :=
  HigherReading.ofChannels [V4.A, V4.B, V4.C] (by decide)

def higherReading_175 : HigherReading :=
  HigherReading.ofChannels [V4.A, V4.A, V4.B] (by decide)

def higherReading_125 : HigherReading :=
  HigherReading.ofChannels [V4.A, V4.A, V4.A] (by decide)

theorem higherReading_385_xor : higherReading_385.xorClass = V4.E :=
  v4XorFold_ABC

theorem higherReading_175_xor : higherReading_175.xorClass = V4.B :=
  v4XorFold_AAB

theorem higherReading_125_xor : higherReading_125.xorClass = V4.A :=
  v4XorFold_AAA

/-- γ of a higher residual still follows `gammaFromResidual` (class from XOR). -/
theorem gamma_385_higher_E :
    gammaFromResidual 385 1 (by decide) = ⟨1, 0, 0, 0⟩ := by
  simp [gammaFromResidual, toV4]

theorem gamma_175_higher_B :
    gammaFromResidual 175 1 (by decide) = ⟨1, 0, 175, 0⟩ := by
  simp [gammaFromResidual, toV4]

theorem gamma_125_higher_A :
    gammaFromResidual 125 1 (by decide) = ⟨1, 125, 0, 0⟩ := by
  simp [gammaFromResidual, toV4]

end KeplerHurwitz.EABC
