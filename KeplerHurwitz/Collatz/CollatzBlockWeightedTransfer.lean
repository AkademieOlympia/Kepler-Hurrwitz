/-
Copyright (c) 2026 Kepler-Hurrwitz contributors.
Block weighted transfer M_{w,m} vs M_w^m.

M_{w,m} aggregates weight-m walks on V_L that additionally survive the
Clog filter at word length L+m. Hence M_{w,m} ≠ M_w^m in general.

Numeric freeze (C=8,L=8): docs/exports/h7_block_transfer_L8_C8p0_summary.json
* even m (2,4,5): ρ(M_{w,m})=0 after filter (nilpotent)
* odd m (1,3,6): ρ>1 but strictly below ρ(M_w)^m

Epistemics: interface; concrete Fin-n certificates from Python export; not Collatz proof.
-/

import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic

namespace KeplerHurwitz.Collatz.BlockWeightedTransfer

open Matrix

def IsSubinvariantCertificate {n : Nat}
    (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (θ : Rat) : Prop :=
  (∀ i, 0 < v i) ∧ 0 < θ ∧ ∀ i, (M.mulVec v) i ≤ θ * v i

def HasContractiveDoob {n : Nat} (M : Matrix (Fin n) (Fin n) Rat) : Prop :=
  ∃ v : Fin n → Rat, ∃ θ : Rat, θ < 1 ∧ IsSubinvariantCertificate M v θ

/-- Block-gap goal on a concrete block matrix. -/
abbrev BlockGapCertificate {n : Nat} (MwBlock : Matrix (Fin n) (Fin n) Rat) : Prop :=
  HasContractiveDoob MwBlock

/--
Program: some block length m admits a contractive subinvariant certificate.
Numeric evidence: m=2 already has ρ=0 (nilpotent) for C=8,L=8.
-/
def BlockGapProgram : Prop :=
  ∃ n : Nat, ∃ MwBlock : Matrix (Fin n) (Fin n) Rat, BlockGapCertificate MwBlock

end KeplerHurwitz.Collatz.BlockWeightedTransfer
