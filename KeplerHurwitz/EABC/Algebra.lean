/-
  Portable eabc quaternion tuple `(e, a, b, c)` over a commutative ring.

  Component labelling (repo Primvierling convention):
      γ = e·1 + a·i + b·j + c·k

  Claim wall:
    * [A] ring operations, conjugation, quadratic norm, Mathlib Quaternion bridge / RingEquiv
    * [A] commutator of pure spatial quaternions stays pure spatial
    * [C] Frenet–Darboux embedding `darboux κ τ = (0,0,κ,τ)` — model interface only
-/

import Mathlib.Algebra.Quaternion
import Mathlib.Tactic.Ring

/-!
# EABC quaternion coordinates over a commutative ring

Four-component carrier `(e, a, b, c)` with Hamilton multiplication, conjugation,
and quadratic norm. Compatible with `Mathlib.Algebra.Quaternion` via `toQuaternion`.
-/

namespace KeplerHurwitz.EABC

/-- The 4-tuple `(e, a, b, c)` over a carrier ring `R`. -/
structure EABCCoord (R : Type*) [CommRing R] where
  e : R
  a : R
  b : R
  c : R
  deriving DecidableEq, Repr

namespace EABCCoord

variable {R : Type*} [CommRing R]

/-- Zero element. -/
def zero : EABCCoord R := ⟨0, 0, 0, 0⟩

/-- Unit (pure `e`-component). -/
def one : EABCCoord R := ⟨1, 0, 0, 0⟩

/-- Componentwise addition. -/
def add (p q : EABCCoord R) : EABCCoord R :=
  ⟨p.e + q.e, p.a + q.a, p.b + q.b, p.c + q.c⟩

/-- Hamilton multiplication in the eabc basis `(1, i, j, k)`. -/
def mul (p q : EABCCoord R) : EABCCoord R :=
  ⟨p.e * q.e - p.a * q.a - p.b * q.b - p.c * q.c,
    p.e * q.a + p.a * q.e + p.b * q.c - p.c * q.b,
    p.e * q.b - p.a * q.c + p.b * q.e + p.c * q.a,
    p.e * q.c + p.a * q.b - p.b * q.a + p.c * q.e⟩

/-- Conjugation: `(e, -a, -b, -c)`. -/
def conj (q : EABCCoord R) : EABCCoord R :=
  ⟨q.e, -q.a, -q.b, -q.c⟩

/-- Componentwise negation. -/
def neg (q : EABCCoord R) : EABCCoord R :=
  ⟨-q.e, -q.a, -q.b, -q.c⟩

/-- Componentwise subtraction. -/
def sub (p q : EABCCoord R) : EABCCoord R :=
  ⟨p.e - q.e, p.a - q.a, p.b - q.b, p.c - q.c⟩

/-- Quadratic (squared) norm: `e² + a² + b² + c²`. -/
def normSq (q : EABCCoord R) : R :=
  q.e * q.e + q.a * q.a + q.b * q.b + q.c * q.c

instance : Zero (EABCCoord R) := ⟨zero⟩
instance : One (EABCCoord R) := ⟨one⟩
instance : Add (EABCCoord R) := ⟨add⟩
instance : Mul (EABCCoord R) := ⟨mul⟩
instance : Neg (EABCCoord R) := ⟨neg⟩
instance : Sub (EABCCoord R) := ⟨sub⟩

@[simp] theorem zero_def : (0 : EABCCoord R) = ⟨0, 0, 0, 0⟩ := rfl
@[simp] theorem one_def : (1 : EABCCoord R) = ⟨1, 0, 0, 0⟩ := rfl
@[simp] theorem add_def (p q : EABCCoord R) :
    p + q = ⟨p.e + q.e, p.a + q.a, p.b + q.b, p.c + q.c⟩ := rfl
@[simp] theorem mul_def (p q : EABCCoord R) :
    p * q =
      ⟨p.e * q.e - p.a * q.a - p.b * q.b - p.c * q.c,
        p.e * q.a + p.a * q.e + p.b * q.c - p.c * q.b,
        p.e * q.b - p.a * q.c + p.b * q.e + p.c * q.a,
        p.e * q.c + p.a * q.b - p.b * q.a + p.c * q.e⟩ := rfl
@[simp] theorem neg_def (q : EABCCoord R) : -q = ⟨-q.e, -q.a, -q.b, -q.c⟩ := rfl
@[simp] theorem sub_def (p q : EABCCoord R) :
    p - q = ⟨p.e - q.e, p.a - q.a, p.b - q.b, p.c - q.c⟩ := rfl

@[simp] theorem conj_def (q : EABCCoord R) : conj q = ⟨q.e, -q.a, -q.b, -q.c⟩ := rfl
@[simp] theorem normSq_def (q : EABCCoord R) :
    normSq q = q.e * q.e + q.a * q.a + q.b * q.b + q.c * q.c := rfl

/-- Extensionality on components. -/
@[ext]
theorem ext {p q : EABCCoord R}
    (he : p.e = q.e) (ha : p.a = q.a) (hb : p.b = q.b) (hc : p.c = q.c) : p = q := by
  cases p; cases q; congr

/-! ## Mathlib Quaternion bridge [A] -/

open Quaternion

/-- Forget to Mathlib `ℍ[R]` with Primvierling order `⟨e, a, b, c⟩`. -/
def toQuaternion (q : EABCCoord R) : ℍ[R] :=
  ⟨q.e, q.a, q.b, q.c⟩

/-- Recover from Mathlib `ℍ[R]`. -/
def ofQuaternion (q : ℍ[R]) : EABCCoord R :=
  ⟨q.re, q.imI, q.imJ, q.imK⟩

@[simp] theorem toQuaternion_ofQuaternion (q : ℍ[R]) :
    toQuaternion (ofQuaternion q) = q := by
  cases q; rfl

@[simp] theorem ofQuaternion_toQuaternion (q : EABCCoord R) :
    ofQuaternion (toQuaternion q) = q := by
  cases q; rfl

theorem toQuaternion_zero : toQuaternion (0 : EABCCoord R) = 0 := by
  apply Quaternion.ext <;> simp [toQuaternion]

theorem toQuaternion_one : toQuaternion (1 : EABCCoord R) = 1 := by
  apply Quaternion.ext <;> simp [toQuaternion]

theorem toQuaternion_add (p q : EABCCoord R) :
    toQuaternion (p + q) = toQuaternion p + toQuaternion q := by
  apply Quaternion.ext <;> simp [toQuaternion]

theorem toQuaternion_mul (p q : EABCCoord R) :
    toQuaternion (p * q) = toQuaternion p * toQuaternion q := by
  apply Quaternion.ext <;> simp [toQuaternion]

theorem toQuaternion_conj (q : EABCCoord R) :
    toQuaternion (conj q) = star (toQuaternion q) := by
  apply Quaternion.ext <;> simp [toQuaternion, conj]

theorem normSq_eq_Quaternion_normSq (q : EABCCoord R) :
    normSq q = Quaternion.normSq (toQuaternion q) := by
  simp [normSq, toQuaternion, Quaternion.normSq_def', sq]

/-- Multiplicativity of the quadratic norm (Euler's four-square identity) [A].

Proved by transfer to Mathlib `Quaternion.normSq` (itself multiplicative).
A direct `ring` expansion of the four-square identity is equivalent but heavier. -/
theorem normSq_mul (p q : EABCCoord R) :
    normSq (p * q) = normSq p * normSq q := by
  rw [normSq_eq_Quaternion_normSq, normSq_eq_Quaternion_normSq p, normSq_eq_Quaternion_normSq q,
    toQuaternion_mul, map_mul]

/-! ## Ring isomorphism to Mathlib quaternions [A] -/

/-- Formal ring isomorphism `EABCCoord R ≃+* ℍ[R]`. -/
def toQuaternionEquiv : EABCCoord R ≃+* ℍ[R] where
  toFun := toQuaternion
  invFun := ofQuaternion
  left_inv := ofQuaternion_toQuaternion
  right_inv := toQuaternion_ofQuaternion
  map_mul' := toQuaternion_mul
  map_add' := toQuaternion_add

@[simp] theorem toQuaternionEquiv_apply (q : EABCCoord R) :
    toQuaternionEquiv q = toQuaternion q := rfl

@[simp] theorem toQuaternionEquiv_symm_apply (q : ℍ[R]) :
    toQuaternionEquiv.symm q = ofQuaternion q := rfl

/-! ## Frenet–Darboux interface [C] -/

/--
Pure spatial quaternion `(0, 0, κ, τ)` from curvature `κ` and torsion `τ`.

Governance **[C]**: model embedding of a Frenet–Darboux angular-velocity vector
`ω = κ·j + τ·k` into the eabc carrier — not a differential-geometry theorem.
-/
def darboux (κ τ : R) : EABCCoord R :=
  ⟨0, 0, κ, τ⟩

@[simp] theorem darboux_def (κ τ : R) : darboux κ τ = ⟨0, 0, κ, τ⟩ := rfl

/-- Conjugation of `darboux κ τ` negates the spatial components. -/
theorem conj_darboux (κ τ : R) :
    conj (darboux κ τ) = ⟨0, 0, -κ, -τ⟩ := by
  simp [conj, darboux]

/-- Squared norm of the Darboux quaternion is `κ² + τ²`. -/
theorem normSq_darboux (κ τ : R) :
    normSq (darboux κ τ) = κ * κ + τ * τ := by
  simp [normSq, darboux]

/-- Darboux vector is pure spatial. -/
theorem darboux_pure_imag (κ τ : R) : (darboux κ τ).e = 0 := by
  simp [darboux]

/-! ## Lie bracket / commutator [A], Frenet use [C] -/

/-- Lie bracket `[p, q] = p q - q p`. -/
def commutator (p q : EABCCoord R) : EABCCoord R :=
  p * q - q * p

@[simp] theorem commutator_def (p q : EABCCoord R) :
    commutator p q = p * q - q * p := rfl

/--
Commutator of two pure spatial quaternions stays pure spatial
(3D cross product of the vector parts) [A].
-/
theorem commutator_pure_imag (p q : EABCCoord R)
    (hp : p.e = 0) (hq : q.e = 0) :
    (commutator p q).e = 0 := by
  simp [commutator, hp, hq, sub_eq_add_neg]
  ring

/--
Commutator of a Darboux angular-velocity quaternion with a pure spatial `v`
stays pure spatial — algebraic core of Frenet–Darboux evolution `[C]`.
-/
theorem commutator_darboux_pure_imag (κ τ : R) (v : EABCCoord R) (hv : v.e = 0) :
    (commutator (darboux κ τ) v).e = 0 :=
  commutator_pure_imag _ _ (darboux_pure_imag κ τ) hv

end EABCCoord

end KeplerHurwitz.EABC
