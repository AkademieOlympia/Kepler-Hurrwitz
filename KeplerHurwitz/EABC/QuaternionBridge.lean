/-
  Bridge: EABC / V₄ normal form ↔ Lipschitz quaternions ℍ[ℤ].

  Component labelling (repo Primvierling convention):
      γ = e·1 + a·i + b·j + c·k
    so `Quaternion` fields are ⟨re, imI, imJ, imK⟩ = ⟨e, a, b, c⟩.

  Roles:
    * V₄ / mod-12 units  — channel algebra of the EABC core
    * ℍ[ℤ]               — Lipschitz order (integer quaternions)
    * DualCarrier        — γ together with Ω(r) / ResidualShape
    * Hurwitz order      — mentioned in docs only (½-lattice); not claimed here

  Claim wall:
    * [A] Hamilton laws via Mathlib; multiplicative normSq; CEAB norm invariance
    * [A] axis embedding; gammaFromResidual; E-collapse; dual carriers
    * [C] full Dedekind / Φ : Primvierling → Hurwitz ideal embedding (open)
-/

import Mathlib.Algebra.Quaternion
import KeplerHurwitz.EABC.Algebra
import KeplerHurwitz.EABC.V4
import KeplerHurwitz.EABC.NormalForm

open Quaternion

namespace KeplerHurwitz.EABC

/-! ## Lipschitz quaternions with EABC axis labels -/

/-- Lipschitz quaternion over ℤ (integer quaternions). -/
abbrev Lipschitz := ℍ[ℤ]

/-- Build `γ = e + a i + b j + c k` from Primvierling-ordered `(a,b,c,e)`. -/
def ofPrimvierlingComponents (a b c e : ℤ) : Lipschitz :=
  ⟨e, a, b, c⟩

/-- Portable `EABCCoord` carrier for the same Primvierling components. -/
def ofPrimvierlingEABCCoord (a b c e : ℤ) : EABCCoord ℤ :=
  ⟨e, a, b, c⟩

theorem toQuaternion_ofPrimvierlingEABCCoord (a b c e : ℤ) :
    EABCCoord.toQuaternion (ofPrimvierlingEABCCoord a b c e) =
      ofPrimvierlingComponents a b c e := rfl

/-- Natural-component variant (casts to ℤ). -/
def ofNatComponents (a b c e : ℕ) : Lipschitz :=
  ofPrimvierlingComponents a b c e

/-- Pure channel axis: only one EABC component nonzero. -/
def axisPure : V4 → ℤ → Lipschitz
  | .E, x => ⟨x, 0, 0, 0⟩
  | .A, x => ⟨0, x, 0, 0⟩
  | .B, x => ⟨0, 0, x, 0⟩
  | .C, x => ⟨0, 0, 0, x⟩

/-- CEAB component shift `(a,b,c,e) ↦ (c,e,a,b)`. -/
def shiftCEABComponents (a b c e : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (c, e, a, b)

/-! ## Algebraic laws (star / norm) -/

/-- Norm squared matches the repo `quatNorm` formula. -/
theorem normSq_ofPrimvierlingComponents (a b c e : ℤ) :
    normSq (ofPrimvierlingComponents a b c e) = a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 := by
  simp [ofPrimvierlingComponents, normSq_def', sq, add_comm, add_left_comm, add_assoc]

theorem normSq_ofNatComponents (a b c e : ℕ) :
    normSq (ofNatComponents a b c e) =
      ((a : ℤ) ^ 2 + (b : ℤ) ^ 2 + (c : ℤ) ^ 2 + (e : ℤ) ^ 2) := by
  simpa [ofNatComponents] using normSq_ofPrimvierlingComponents a b c e

/-- Multiplicativity of the quaternion norm (Mathlib monoid-hom). -/
theorem normSq_mul (x y : Lipschitz) : normSq (x * y) = normSq x * normSq y :=
  map_mul normSq x y

/-- Conjugation is an anti-homomorphism. -/
theorem star_mul_anti (x y : Lipschitz) : star (x * y) = star y * star x :=
  star_mul x y

/-- Self-product with conjugate recovers the (real) norm. -/
theorem mul_star_eq_normSq (x : Lipschitz) : x * star x = normSq x :=
  Quaternion.self_mul_star x

/-- Basis element `i` as Lipschitz quaternion. -/
def I : Lipschitz := ⟨0, 1, 0, 0⟩
def J : Lipschitz := ⟨0, 0, 1, 0⟩
def K : Lipschitz := ⟨0, 0, 0, 1⟩

private theorem quat_ext {x y : Lipschitz}
    (hre : x.re = y.re) (hi : x.imI = y.imI) (hj : x.imJ = y.imJ) (hk : x.imK = y.imK) :
    x = y := QuaternionAlgebra.ext hre hi hj hk

theorem I_mul_I : I * I = -1 := by
  apply quat_ext <;> simp [I]
theorem J_mul_J : J * J = -1 := by
  apply quat_ext <;> simp [J]
theorem K_mul_K : K * K = -1 := by
  apply quat_ext <;> simp [K]
theorem I_mul_J : I * J = K := by
  apply quat_ext <;> simp [I, J, K]
theorem J_mul_I : J * I = -K := by
  apply quat_ext <;> simp [I, J, K]
theorem I_mul_J_mul_K : I * J * K = -1 := by
  apply quat_ext <;> simp [I, J, K]

/-! ## Pure-axis embedding and V₄ -/

theorem normSq_axisPure (ch : V4) (x : ℤ) :
    normSq (axisPure ch x) = x ^ 2 := by
  cases ch <;> simp [axisPure, normSq_def', sq]

/-- A channel prime on its V₄-axis has quaternion norm `p²`. -/
theorem normSq_axisPure_nat (ch : V4) (p : ℕ) :
    normSq (axisPure ch p) = (p : ℤ) ^ 2 := by
  simpa using normSq_axisPure ch p

/-- The V₄ class of a unit mod 12 selects the pure-axis embedding. -/
theorem axisPure_toV4_consistent {p : ℕ} (h : Nat.Coprime p 6) :
    axisPure (toV4 p h) p =
      match p % 12 with
      | 1 => axisPure .E p
      | 5 => axisPure .A p
      | 7 => axisPure .B p
      | _ => axisPure .C p := by
  rcases toV4_eq_of_mod12 h with ⟨h1, hE⟩ | ⟨h5, hA⟩ | ⟨h7, hB⟩ | ⟨h11, hC⟩
  · simp [hE, h1, axisPure]
  · simp [hA, h5, axisPure]
  · simp [hB, h7, axisPure]
  · simp [hC, h11, axisPure]

/-! ## CEAB symmetry preserves quaternion norm -/

theorem normSq_shiftCEAB (a b c e : ℤ) :
    let (a', b', c', e') := shiftCEABComponents a b c e
    normSq (ofPrimvierlingComponents a' b' c' e') =
      normSq (ofPrimvierlingComponents a b c e) := by
  simp [shiftCEABComponents, normSq_ofPrimvierlingComponents]
  ring

/-! ## Canonical γ from residual × E-factor -/

/-- Embed `(r, eFactor)` as `γ = eFactor + (r on axis of toV4 r)`.

When `toV4 r = E`, the residual sits on the real line only via collapse:
imaginary parts vanish (so `r = 25 ≡ 1` yields the same γ as `r = 1` up to `eFactor`). -/
def gammaFromResidual (r eFactor : ℕ) (hr : Nat.Coprime r 6) : Lipschitz :=
  match toV4 r hr with
  | .E => ⟨(eFactor : ℤ), 0, 0, 0⟩
  | .A => ⟨(eFactor : ℤ), (r : ℤ), 0, 0⟩
  | .B => ⟨(eFactor : ℤ), 0, (r : ℤ), 0⟩
  | .C => ⟨(eFactor : ℤ), 0, 0, (r : ℤ)⟩

/-- γ of a core normal form (residual carries V₄; E-factor is real drift). -/
def gammaOfCore {κ : ℕ} (nf : CoreNormalForm κ) : Lipschitz :=
  gammaFromResidual nf.residual nf.eFactor (IsResidualSmooth.coprime_six nf.residual_smooth)

theorem gammaFromResidual_E {eFactor : ℕ} :
    gammaFromResidual 1 eFactor (by decide) = ⟨(eFactor : ℤ), 0, 0, 0⟩ := by
  simp [gammaFromResidual, toV4]

theorem gammaFromResidual_A {eFactor : ℕ} :
    gammaFromResidual 5 eFactor (by decide) = ⟨(eFactor : ℤ), 5, 0, 0⟩ := by
  simp [gammaFromResidual, toV4]

theorem gammaFromResidual_B {eFactor : ℕ} :
    gammaFromResidual 7 eFactor (by decide) = ⟨(eFactor : ℤ), 0, 7, 0⟩ := by
  simp [gammaFromResidual, toV4]

theorem gammaFromResidual_C {eFactor : ℕ} :
    gammaFromResidual 11 eFactor (by decide) = ⟨(eFactor : ℤ), 0, 0, 11⟩ := by
  simp [gammaFromResidual, toV4]

/-! ## E-collapse: `[r]_{V₄} = E` erases imaginary residual mass -/

/-- If the residual is V₄-neutral, γ is purely real with drift `eFactor`. -/
theorem gammaFromResidual_of_toV4_E {r eFactor : ℕ} (hr : Nat.Coprime r 6)
    (hE : toV4 r hr = V4.E) :
    gammaFromResidual r eFactor hr = ⟨(eFactor : ℤ), 0, 0, 0⟩ := by
  simp [gammaFromResidual, hE]

/-- Under E-collapse, γ depends only on the E-factor (residual magnitude lost). -/
theorem gammaFromResidual_eq_of_toV4_E {r eFactor : ℕ} (hr : Nat.Coprime r 6)
    (hE : toV4 r hr = V4.E) :
    gammaFromResidual r eFactor hr = gammaFromResidual 1 eFactor (by decide) := by
  rw [gammaFromResidual_of_toV4_E hr hE, gammaFromResidual_E]

theorem toV4_25 : toV4 25 (by decide) = V4.E := by simp [toV4]
theorem toV4_49 : toV4 49 (by decide) = V4.E := by simp [toV4]

theorem gammaFromResidual_collapse_semiprim_square :
    gammaFromResidual 25 1 (by decide) = gammaFromResidual 1 1 (by decide) :=
  gammaFromResidual_eq_of_toV4_E (by decide) toV4_25

theorem gammaFromResidual_collapse_49 :
    gammaFromResidual 49 1 (by decide) = gammaFromResidual 1 1 (by decide) :=
  gammaFromResidual_eq_of_toV4_E (by decide) toV4_49

/-! ## Dual carriers: γ alone is not a complete invariant -/

/-- Symbiotic information pair for a residual × E-factor:
* `gamma` — geometric orientation + scalar E-drift in ℍ[ℤ]
* `omega` / `shape` — topological residual complexity (survives E-collapse) -/
structure DualCarrier (r eFactor : ℕ) (hr : Nat.Coprime r 6) where
  gamma : Lipschitz
  omega : ℕ
  shape : ResidualShape

/-- Canonical dual carrier for `(r, eFactor)`. -/
def dualCarrier (r eFactor : ℕ) (hr : Nat.Coprime r 6) : DualCarrier r eFactor hr where
  gamma := gammaFromResidual r eFactor hr
  omega := residualOmega r
  shape := classifyResidual r

/-- Build the dual carrier from a core normal form. -/
def DualCarrier.ofCore {κ : ℕ} (nf : CoreNormalForm κ) :
    DualCarrier nf.residual nf.eFactor (IsResidualSmooth.coprime_six nf.residual_smooth) :=
  dualCarrier nf.residual nf.eFactor (IsResidualSmooth.coprime_six nf.residual_smooth)

/-- E-collapse witness: γ(25)=γ(1), but Ω and Shape separate them.
Hence γ must be read together with `(Ω(r), r)`. -/
theorem e_collapse_requires_dual_carrier :
    gammaFromResidual 25 1 (by decide) = gammaFromResidual 1 1 (by decide) ∧
    residualOmega 25 ≠ residualOmega 1 ∧
    classifyResidual 25 ≠ classifyResidual 1 := by
  refine ⟨gammaFromResidual_collapse_semiprim_square, ?_, ?_⟩
  · rw [residualOmega_25, residualOmega_one]; decide
  · rw [classifyResidual_25, classifyResidual_one]; decide

/-- Same statement packaged as dual carriers. -/
theorem DualCarrier.e_collapse_25_vs_1 :
    (dualCarrier 25 1 (by decide)).gamma = (dualCarrier 1 1 (by decide)).gamma ∧
    (dualCarrier 25 1 (by decide)).omega ≠ (dualCarrier 1 1 (by decide)).omega ∧
    (dualCarrier 25 1 (by decide)).shape ≠ (dualCarrier 1 1 (by decide)).shape :=
  e_collapse_requires_dual_carrier

/-! ## Catalog: selected n ≤ 100 (matches Python export) -/

/-- n = 65 = 5·13 → r=5 (A), e=13 → γ = 13 + 5 i. -/
theorem gamma_65 : gammaFromResidual 5 13 (by decide) = ⟨13, 5, 0, 0⟩ := by
  simp [gammaFromResidual, toV4]

/-- n = 35 = 5·7 → r=35 ≡ 11 (C) → γ = 1 + 35 k. -/
theorem gamma_35 : gammaFromResidual 35 1 (by decide) = ⟨1, 0, 0, 35⟩ := by
  simp [gammaFromResidual, toV4]

/-- n = 74 = 2·37 → r=1, e=37 (37 ≡ 1 mod 12) → γ = 37. -/
theorem gamma_74_e_factor : gammaFromResidual 1 37 (by decide) = ⟨37, 0, 0, 0⟩ :=
  gammaFromResidual_E

/-- n = 13 pure channel-E → γ = 13. -/
theorem gamma_13 : gammaFromResidual 1 13 (by decide) = ⟨13, 0, 0, 0⟩ :=
  gammaFromResidual_E

/-- n = 55 = 5·11 → r=55 ≡ 7 (B) → γ = 1 + 55 j. -/
theorem gamma_55 : gammaFromResidual 55 1 (by decide) = ⟨1, 0, 55, 0⟩ := by
  simp [gammaFromResidual, toV4]

/-- n = 77 = 7·11 → r=77 ≡ 5 (A) → γ = 1 + 77 i. -/
theorem gamma_77 : gammaFromResidual 77 1 (by decide) = ⟨1, 77, 0, 0⟩ := by
  simp [gammaFromResidual, toV4]

/-- n = 85 = 5·17 → same channel A → E-collapse γ = 1. -/
theorem gamma_85 : gammaFromResidual 85 1 (by decide) = ⟨1, 0, 0, 0⟩ := by
  simp [gammaFromResidual, toV4]

/-- n = 91 = 7·13 → r=7 (B), e=13 → γ = 13 + 7 j. -/
theorem gamma_91 : gammaFromResidual 7 13 (by decide) = ⟨13, 0, 7, 0⟩ := by
  simp [gammaFromResidual, toV4]

/-- n = 95 = 5·19 → r=95 ≡ 11 (C) → γ = 1 + 95 k. -/
theorem gamma_95 : gammaFromResidual 95 1 (by decide) = ⟨1, 0, 0, 95⟩ := by
  simp [gammaFromResidual, toV4]

/-! ## Normal-form roles ↔ quaternion reading (dictionary) -/

/-- Interpretive dictionary: residual/V₄ → imaginary axis; E-factor → real drift. -/
def roleDictionary : True := trivial

/-- Explicit non-claim: this module does not construct Dedekind Φ. -/
theorem phi_embedding_not_constructed : True := trivial

/-- Explicit non-claim: γ is not a complete reconstruction of n. -/
theorem gamma_not_complete_invariant : True := trivial

end KeplerHurwitz.EABC
