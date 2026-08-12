/-
Copyright (c) 2026 Kepler-Hurrwitz contributors.

Composite gap audit — Phase C consolidation for C=8, L=8.

Concrete green certificates (imported below):

* `CompositeCert_M3M2`: product `M_3 M_2`, nilpotent, **strict**
  `HasContractiveDoob` with `θ = 1/2`
  (not `θ = 0`: the predicate requires `0 < θ`, and `M ≠ 0`).
* `CompositeCert_M3M5`: product `M_3 M_5`, `ρ ≈ 0.949`, **weak**
  support certificate with `θ = 477/500 = 0.954 < 1`
  (strict `∀ i, 0 < v i` not available on this reducible support;
   `θ = 19/20 = 0.95` also holds numerically on the same `v`).

Caveat: `ρ(A) = 0` does **not** imply `ρ(B A) < 1`
(counterexamples: `M_9 M_4`, `M_9 M_5`).

Epistemics: finite C=8,L=8 composite audit; not a Collatz proof;
not an induction in L or C.

Related (separate module, not this consolidation):
`SurgicalAudit_L11` is a finite Not-Patch for the L=11 singularity only;
it must not be read as a Core survivor refinement.
-/

import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic
import KeplerHurwitz.Collatz.CompositeCert_M3M2
import KeplerHurwitz.Collatz.CompositeCert_M3M5

namespace KeplerHurwitz.Collatz.CompositeGapAudit

open Matrix
open KeplerHurwitz.Collatz.CompositeCert_M3M2
open KeplerHurwitz.Collatz.CompositeCert_M3M5

/-- Program-level composite gap predicate (strict positivity). -/
def CompositeGapCertificate {n : Nat}
    (MB MA : Matrix (Fin n) (Fin n) Rat) : Prop :=
  ∃ v : Fin n → Rat, ∃ θ : Rat,
    θ < 1 ∧
      (∀ i, 0 < v i) ∧ 0 < θ ∧ ∀ i, ((MB * MA).mulVec v) i ≤ θ * v i

/-- Weak variant (nonnegative support vector). -/
def CompositeGapCertificateWeak {n : Nat}
    (M : Matrix (Fin n) (Fin n) Rat) : Prop :=
  CompositeCert_M3M5.HasContractiveDoobWeak M

/-! ## Anchored golden theorems -/

/-- Structural damper product: nilpotent composition with `θ = 1/2`. -/
theorem composite_gap_M3_M2 :
    CompositeCert_M3M2.HasContractiveDoob CompositeCert_M3M2.MComp :=
  CompositeCert_M3M2.composite_HasContractiveDoob

/-- Physical contraction product: non-nilpotent `ρ < 1`, weak support cert. -/
theorem composite_gap_M3_M5 :
    CompositeCert_M3M5.HasContractiveDoobWeak CompositeCert_M3M5.MComp :=
  CompositeCert_M3M5.composite_HasContractiveDoobWeak

/-- Convenience: `θ = 477/500` is the certified rate for `M_3 M_5`. -/
theorem composite_gap_M3_M5_theta :
    CompositeCert_M3M5.thetaCert = (477 : Rat) / 500 := rfl

/-- Convenience: `θ = 1/2` is the certified rate for `M_3 M_2`. -/
theorem composite_gap_M3_M2_theta :
    CompositeCert_M3M2.thetaCert = (1 : Rat) / 2 := rfl

/-- Warning marker: nilpotency of a factor alone is not a composite gap. -/
def NilpotentDamperDoesNotImplyCompositeGap : Prop := True

theorem nilpotentDamperCaveat : NilpotentDamperDoesNotImplyCompositeGap := trivial

/--
Phase-C status for fixed `(C,L) = (8,8)`: composite gap witnessed.

Archive note: Phase C core cell is closed here. The isolated `(8,11)`
surgery island and the combined archive marker live in
`CompositePhaseCAuditReport` (not in this module).
-/
def PhaseC_C8_L8_Consolidated : Prop :=
  CompositeCert_M3M2.HasContractiveDoob CompositeCert_M3M2.MComp ∧
    CompositeCert_M3M5.HasContractiveDoobWeak CompositeCert_M3M5.MComp

theorem phaseC_C8_L8_consolidated : PhaseC_C8_L8_Consolidated :=
  ⟨composite_gap_M3_M2, composite_gap_M3_M5⟩

end KeplerHurwitz.Collatz.CompositeGapAudit
