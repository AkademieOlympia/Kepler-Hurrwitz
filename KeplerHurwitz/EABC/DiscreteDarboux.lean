/-
  Lipschitz units over ℤ and discrete Frenet–Darboux step on EABCCoord ℤ.

  Claim wall:
    * [A] Lipschitz units (`normSq = 1`), left/right inverse via conjugation
    * [A] norm identity for the discrete Darboux step
    * [C] `discreteDarboux` / `stepDarboux` as Frenet model interface
      (not a differential-geometry theorem)
-/

import Mathlib.Algebra.Quaternion
import Mathlib.Tactic.Ring
import KeplerHurwitz.EABC.Algebra

/-!
# Lipschitz units and discrete Frenet–Darboux

Integer-quaternion units (`normSq = 1`) and a discrete angular-velocity step
`q ↦ q + (q · ω) · h` with `ω = κ·j + τ·k`.
-/

namespace KeplerHurwitz.EABC
namespace EABCCoord

open Quaternion

/-! ## Lipschitz units over ℤ [A] -/

/-- A Lipschitz unit is an integer quaternion of squared norm `1`. -/
def IsLipschitzUnit (q : EABCCoord ℤ) : Prop :=
  normSq q = 1

/-- Right inverse: `q * conj q = 1` for Lipschitz units.

Transfer: Mathlib `Quaternion.self_mul_star : a * star a = ↑(normSq a)`. -/
theorem mul_conj_of_isLipschitzUnit (q : EABCCoord ℤ) (h : IsLipschitzUnit q) :
    q * conj q = 1 := by
  refine (RingEquiv.injective (toQuaternionEquiv (R := ℤ))) ?_
  rw [toQuaternionEquiv_apply, toQuaternionEquiv_apply]
  rw [toQuaternion_mul, toQuaternion_conj, Quaternion.self_mul_star,
    ← normSq_eq_Quaternion_normSq, h, Quaternion.coe_one, toQuaternion_one]

/-- Left inverse: `conj q * q = 1` for Lipschitz units. -/
theorem conj_mul_of_isLipschitzUnit (q : EABCCoord ℤ) (h : IsLipschitzUnit q) :
    conj q * q = 1 := by
  refine (RingEquiv.injective (toQuaternionEquiv (R := ℤ))) ?_
  rw [toQuaternionEquiv_apply, toQuaternionEquiv_apply]
  rw [toQuaternion_mul, toQuaternion_conj, Quaternion.star_mul_self,
    ← normSq_eq_Quaternion_normSq, h, Quaternion.coe_one, toQuaternion_one]

/-! ## Discrete Frenet–Darboux on ℤ⁴ [C] model / [A] norm identity -/

/--
Pure spatial Darboux quaternion `(0, 0, κ, τ)`.

Governance **[C]**: same carrier as `darboux`; Frenet model interface only.
-/
abbrev discreteDarboux (κ τ : ℤ) : EABCCoord ℤ :=
  darboux κ τ

/-- Scalar embedding `h ↦ (h, 0, 0, 0)`. -/
def scalar (h : ℤ) : EABCCoord ℤ :=
  ⟨h, 0, 0, 0⟩

@[simp] theorem scalar_def (h : ℤ) : scalar h = ⟨h, 0, 0, 0⟩ := rfl

theorem toQuaternion_scalar (h : ℤ) :
    toQuaternion (scalar h) = (h : ℍ[ℤ]) := by
  apply Quaternion.ext <;> rfl

/--
Discrete Frenet–Darboux step:
`q ↦ q + (q * discreteDarboux κ τ) * ⟨h, 0, 0, 0⟩`.

Governance **[C]**: discrete angular-velocity update model, not a continuum theorem.
-/
def stepDarboux (q : EABCCoord ℤ) (κ τ h : ℤ) : EABCCoord ℤ :=
  q + (q * discreteDarboux κ τ) * scalar h

/-- Factorization `q + (q * d) * s = q * (1 + d * s)` via Mathlib transfer. -/
theorem stepDarboux_eq_mul (q : EABCCoord ℤ) (κ τ h : ℤ) :
    stepDarboux q κ τ h =
      q * (1 + discreteDarboux κ τ * scalar h) := by
  refine (RingEquiv.injective (toQuaternionEquiv (R := ℤ))) ?_
  rw [toQuaternionEquiv_apply, toQuaternionEquiv_apply]
  -- LHS
  rw [stepDarboux, toQuaternion_add, toQuaternion_mul, toQuaternion_mul,
    toQuaternion_scalar]
  -- RHS
  rw [toQuaternion_mul, toQuaternion_add, toQuaternion_one, toQuaternion_mul,
    toQuaternion_scalar]
  -- Mathlib: Q + (Q * D) * ↑h = Q * (1 + D * ↑h)
  set Q := toQuaternion q
  set D := toQuaternion (discreteDarboux κ τ)
  set H := (h : ℍ[ℤ])
  change Q + (Q * D) * H = Q * (1 + D * H)
  calc
    Q + (Q * D) * H = Q * 1 + Q * (D * H) := by
      rw [mul_one, mul_assoc]
    _ = Q * (1 + D * H) := (mul_add Q 1 (D * H)).symm

/-- Norm of the scalar step factor `1 + discreteDarboux κ τ * scalar h`. -/
theorem normSq_one_add_darboux_scalar (κ τ h : ℤ) :
    normSq (1 + discreteDarboux κ τ * scalar h) =
      1 + h * h * (κ * κ + τ * τ) := by
  simp [normSq, discreteDarboux, darboux, scalar, one_def, add_def, mul_def]
  ring

/--
Squared-norm evolution of the discrete Darboux step [A]:
`‖stepDarboux q κ τ h‖² = ‖q‖² · (1 + h²(κ² + τ²))`.
-/
theorem normSq_stepDarboux (q : EABCCoord ℤ) (κ τ h : ℤ) :
    normSq (stepDarboux q κ τ h) =
      normSq q * (1 + h * h * (κ * κ + τ * τ)) := by
  rw [stepDarboux_eq_mul, normSq_mul, normSq_one_add_darboux_scalar]

end EABCCoord
end KeplerHurwitz.EABC
