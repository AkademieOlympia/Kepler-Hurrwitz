/-
  Semiprime residual refinement via V₄ channel algebra and channel-triad cosine.

  Representation scope:
    Every n = 2^α·3^β·r·e  (axis-smooth × residual-smooth × E-smooth).
    "Reduced" means Ω(r) ≤ 2 (reineE / primTimesE / semiprimTimesE).
    `higher` (Ω(r) ≥ 3) is an allowed non-reduced residue — not every n is reduced.

  SemiprimTimesE splits by V₄:
    * square / sameChannel  → product class E  (γ-collapse)
    * distinctChannel       → product = third residual channel

  Channel triad cosine dictionary [B]:
    residual channels A,B,C modelled as a 120°-triad:
      cos(x,x) = 1,   cos(x,y) = -1/2 for x ≠ y in {A,B,C}.
    This is *not* the Hamilton {i,j,k}-inner product (there cos = 0).

  Claim wall:
    [A] V₄ products; axisPure multiplication for distinct residual axes
    [B] channelCos dictionary; naming of SemiprimKind
    [C] physical Spatprodukt / geometric-algebra identification beyond the dictionary
-/

import Mathlib.Data.Rat.Defs
import KeplerHurwitz.EABC.V4
import KeplerHurwitz.EABC.NormalForm
import KeplerHurwitz.EABC.QuaternionBridge

open Quaternion

namespace KeplerHurwitz.EABC

/-! ## Semiprime kind (V₄-aware) -/

/-- Fine types inside `semiprimTimesE` (Ω(r) = 2). -/
inductive SemiprimKind
  | square
    -- r = p²
  | sameChannel
    -- r = p·q with p ≠ q but toV4 p = toV4 q  → product class E
  | distinctChannel
    -- r = p·q with toV4 p ≠ toV4 q           → product = third channel
  deriving DecidableEq, Repr

/-- Axis-smooth factor \(2^\alpha 3^\beta\) (Hamming-{2,3}-smooth). -/
def IsAxisSmooth (m : ℕ) : Prop :=
  ∀ p : ℕ, p.Prime → p ∣ m → p = 2 ∨ p = 3

theorem isAxisSmooth_pow23 (α β : ℕ) : IsAxisSmooth (2 ^ α * 3 ^ β) := by
  intro p hp hdiv
  rcases (Nat.Prime.dvd_mul hp).mp hdiv with h2 | h3
  · left
    have : p ∣ 2 := hp.dvd_of_dvd_pow h2
    exact (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp this
  · right
    have : p ∣ 3 := hp.dvd_of_dvd_pow h3
    exact (Nat.prime_dvd_prime_iff_eq hp Nat.prime_three).mp this

/-- Scope marker: unique writing n = axis · r · e always; reduced only if Ω(r) ≤ 2. -/
theorem normal_form_representation_scope : True := trivial

/-! ## Channel triad cosine [B dictionary] -/

/-- Cosine on the residual triad {A,B,C} (and E as neutral).
Distinct residual channels sit at 120°: cos = -1/2. -/
def channelCos : V4 → V4 → ℚ
  | .E, _ | _, .E => 1
  | x, y => if x = y then 1 else (-1 : ℚ) / 2

theorem channelCos_self_residual (x : V4) (hx : x ≠ V4.E) : channelCos x x = 1 := by
  cases x <;> simp_all [channelCos]

theorem channelCos_distinct_residual {x y : V4}
    (hx : x ≠ V4.E) (hy : y ≠ V4.E) (hne : x ≠ y) :
    channelCos x y = (-1 : ℚ) / 2 := by
  cases x <;> cases y <;> simp_all [channelCos]

theorem channelCos_A_B : channelCos V4.A V4.B = (-1 : ℚ) / 2 := by
  simp [channelCos]

theorem channelCos_B_C : channelCos V4.B V4.C = (-1 : ℚ) / 2 := by
  simp [channelCos]

theorem channelCos_C_A : channelCos V4.C V4.A = (-1 : ℚ) / 2 := by
  simp [channelCos]

/-! ## V₄ product geometry for distinct residual channels -/

theorem V4.mul_A_B : V4.A * V4.B = V4.C := rfl
theorem V4.mul_B_C : V4.B * V4.C = V4.A := rfl
theorem V4.mul_C_A : V4.C * V4.A = V4.B := rfl
theorem V4.mul_A_A : V4.A * V4.A = V4.E := rfl

/-- Distinct residual channels multiply to the third (complements the cos = -1/2 dictionary). -/
theorem V4.mul_distinct_residual {x y : V4}
    (hx : x ≠ V4.E) (hy : y ≠ V4.E) (hne : x ≠ y) :
    x * y ≠ V4.E := by
  revert hx hy hne
  cases x <;> cases y <;> decide

/-! ## Quaternion axis product (Hamilton, orthogonal — cos = 0) -/

private theorem quat_ext' {x y : Lipschitz}
    (hre : x.re = y.re) (hi : x.imI = y.imI) (hj : x.imJ = y.imJ) (hk : x.imK = y.imK) :
    x = y := QuaternionAlgebra.ext hre hi hj hk

/-- Distinct residual axes: A×B → C with magnitude product (Hamilton). -/
theorem axisPure_A_mul_B (p q : ℤ) :
    axisPure V4.A p * axisPure V4.B q = axisPure V4.C (p * q) := by
  apply quat_ext' <;> simp [axisPure]

theorem axisPure_B_mul_C (p q : ℤ) :
    axisPure V4.B p * axisPure V4.C q = axisPure V4.A (p * q) := by
  apply quat_ext' <;> simp [axisPure]

theorem axisPure_C_mul_A (p q : ℤ) :
    axisPure V4.C p * axisPure V4.A q = axisPure V4.B (p * q) := by
  apply quat_ext' <;> simp [axisPure]

/-- Same residual axis squares to a negative real (Hamilton); V₄ class collapses to E. -/
theorem axisPure_A_mul_A (p : ℤ) :
    axisPure V4.A p * axisPure V4.A p = ⟨-(p * p), 0, 0, 0⟩ := by
  apply quat_ext' <;> simp [axisPure]

/-! ## Concrete semiprime witnesses (match Python / CSV) -/

/-- 35 = 5·7: distinct channels A×B → C; triad cos(A,B) = -1/2. -/
theorem semiprim_35_distinct :
    toV4 5 (by decide) = V4.A ∧
    toV4 7 (by decide) = V4.B ∧
    toV4 35 (by decide) = V4.C ∧
    channelCos V4.A V4.B = (-1 : ℚ) / 2 ∧
    classifyResidual 35 = ResidualShape.semiprimTimesE :=
  ⟨by simp [toV4], by simp [toV4], by simp [toV4], channelCos_A_B, classifyResidual_35⟩

/-- 25 = 5²: same channel → E-collapse (cos = +1 on the triad dictionary). -/
theorem semiprim_25_square_collapse :
    toV4 25 (by decide) = V4.E ∧
    channelCos V4.A V4.A = 1 ∧
    classifyResidual 25 = ResidualShape.semiprimTimesE :=
  ⟨toV4_25, by simp [channelCos], classifyResidual_25⟩

/-- 85 = 5·17: both channel A → product class E (sameChannel, not square). -/
theorem semiprim_85_same_channel :
    toV4 5 (by decide) = V4.A ∧
    toV4 17 (by decide) = V4.A ∧
    toV4 85 (by decide) = V4.E ∧
    channelCos V4.A V4.A = 1 := by
  refine ⟨by simp [toV4], by simp [toV4], by simp [toV4], by simp [channelCos]⟩

/-- Explicit non-claim: channelCos is not the Hamilton inner product of i,j,k. -/
theorem channelCos_not_hamilton_inner_product : True := trivial

/-- Explicit non-claim: Spatprodukt beyond the cosine dictionary is open [C]. -/
theorem spatprodukt_beyond_dictionary_open : True := trivial

end KeplerHurwitz.EABC
