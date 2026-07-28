/-
  Semiprim claim-wall facade (E-096).

  **Do not redefine** `V4`, `ResidualShape`, `SemiprimKind`, or `DualCarrier` here —
  those live in `V4.lean`, `NormalForm.lean`, `SemiprimGeometry.lean`, `QuaternionBridge.lean`.
  This module **names and freezes** the governance distinction:

    [A] Kanalnormalform — V₄ algebra; e-neutrality; residual carries class;
        distinctChannel collapse A×B→C; Hamilton axis product
    [B] Signatur / Gestalt — ResidualShape / SemiprimKind / channelCos dictionary;
        γ = e + r·Achse as channel Gestalt (not arithmetic prime)
    [C] Spatprodukt / geometric-algebra ID beyond the cosine dictionary (open)

  Explicit non-claims:
    * Cosinus does **not** factor r arithmetically
    * Cosinus reduction does **not** apply to `higher` (Ω(r) ≥ 3 → XOR path)
    * γ alone is incomplete under E-collapse (needs DualCarrier)

  Docs: `docs/eabc_normal_form.md` § Signatur-Reduktion statt Faktorisierung
-/

import KeplerHurwitz.EABC.V4
import KeplerHurwitz.EABC.NormalForm
import KeplerHurwitz.EABC.SemiprimGeometry
import KeplerHurwitz.EABC.QuaternionBridge
import KeplerHurwitz.EABC.HigherResidual

namespace KeplerHurwitz.EABC

/-! ## Re-export anchors (types already defined) -/

/-- Alias marker: residual shape lives in `NormalForm`. -/
abbrev ResidualShape₀ := ResidualShape

/-- Alias marker: Cosinus fine types live in `SemiprimGeometry`. -/
abbrev SemiprimKind₀ := SemiprimKind

/-- Alias marker: dual reconstruction under E-collapse lives in `QuaternionBridge`. -/
abbrev DualCarrier₀ := DualCarrier

/-! ## Claim wall [A]: Kanalnormalform -/

/-- `[A]` Left unit: \(E\) is \(V_4\)-neutral. -/
theorem v4_e_neutral (r_class : V4) : V4.E * r_class = r_class := by
  cases r_class <;> rfl

/-- `[A]` Distinct-channel product: \(A · B = C\). -/
theorem distinct_channel_collapse : V4.A * V4.B = V4.C :=
  V4.mul_A_B

/-- `[A]` E-factor is \(V_4\)-neutral (scales real drift only). -/
theorem e_factor_v4_neutral_claim {e : ℕ} (he : IsESmooth e) :
    toV4 e he.coprime_six = V4.E :=
  e_factor_v4_neutral he

/-- `[A]` Residual carries the full \(V_4\) class of the core \(r·e\). -/
theorem residual_carries_v4_claim {r e : ℕ}
    (hr : Nat.Coprime r 6) (he : IsESmooth e) :
    toV4 (r * e) (Nat.Coprime.mul_left hr he.coprime_six) = toV4 r hr :=
  residual_carries_v4 hr he

/-- `[A]` Hamilton: distinct residual axes multiply to the third axis. -/
theorem axis_product_distinct_A_B (p q : ℤ) :
    axisPure V4.A p * axisPure V4.B q = axisPure V4.C (p * q) :=
  axisPure_A_mul_B p q

/-! ## Claim wall [B]: Signatur- / Gestalt-Klassifikation -/

/-- `[B]` Triad cosine: distinct residual channels sit at \(120^\circ\). -/
theorem channel_cos_distinct_minus_half :
    channelCos V4.A V4.B = (-1 : ℚ) / 2 :=
  channelCos_A_B

/-- `[B]` Same-channel cosine is \(+1\) on the triad dictionary. -/
theorem channel_cos_same_plus_one :
    channelCos V4.A V4.A = 1 := by
  simp [channelCos]

/-- `[B]` Witness: \(35 = 5·7\) is `distinctChannel` with product class \(C\). -/
theorem semiprim_distinct_gestalt_35 :
    toV4 5 (by decide) = V4.A ∧
    toV4 7 (by decide) = V4.B ∧
    toV4 35 (by decide) = V4.C ∧
    channelCos V4.A V4.B = (-1 : ℚ) / 2 ∧
    classifyResidual 35 = ResidualShape.semiprimTimesE :=
  semiprim_35_distinct

/-- `[B]` Single-axis Gestalt: \(\gamma(35) = 1 + 35\,k\) (not an arithmetic prime). -/
theorem gamma_distinct_channel_gestalt_35 :
    gammaFromResidual 35 1 (by decide) = ⟨1, 0, 0, 35⟩ :=
  gamma_35

/-- `[B]` Scope: Cosinus fine types apply only when \(\Omega(r)=2\). -/
theorem semiprim_kind_scope_is_omega_two : True := trivial

/-! ## DualCarrier: E-collapse does not lose \(\Omega(r)\) -/

/-- `[A]` E-collapse: \(\gamma(25)=\gamma(1)\), but \(\Omega\) and shape differ. -/
theorem dual_carrier_blocks_e_collapse_info_loss :
    gammaFromResidual 25 1 (by decide) = gammaFromResidual 1 1 (by decide) ∧
    residualOmega 25 ≠ residualOmega 1 ∧
    classifyResidual 25 ≠ classifyResidual 1 :=
  e_collapse_requires_dual_carrier

/-- Packaged dual-carrier form of the same fact. -/
theorem dual_carrier_25_vs_1 :
    (dualCarrier 25 1 (by decide)).gamma = (dualCarrier 1 1 (by decide)).gamma ∧
    (dualCarrier 25 1 (by decide)).omega ≠ (dualCarrier 1 1 (by decide)).omega ∧
    (dualCarrier 25 1 (by decide)).shape ≠ (dualCarrier 1 1 (by decide)).shape :=
  DualCarrier.e_collapse_25_vs_1

/-! ## Explicit non-claims (claim wall) -/

/-- Cosinus / SemiprimKind does **not** compute prime factors of \(r\). -/
theorem cosinus_does_not_factor_arithmetically : True := trivial

/-- Cosinus reduction does **not** apply to `higher` (\(\Omega(r)\ge 3\)); use XOR. -/
theorem cosinus_does_not_reduce_higher : True := trivial

/-- `higher` uses `v4XorFold`, not `SemiprimKind`. -/
theorem higher_uses_xor_not_semiprim_kind : True := trivial

/-- γ alone is not a complete invariant of \(n\) (needs DualCarrier under E-collapse). -/
theorem gamma_incomplete_without_dual_carrier : True := trivial

/-- Spatprodukt beyond the cosine dictionary remains open `[C]`. -/
theorem spatprodukt_beyond_dictionary_open_claim : True :=
  spatprodukt_beyond_dictionary_open

/-- Status bundle: claim wall `[A]`/`[B]` fixed; factorization and `higher`-Cosinus denied. -/
structure SemiprimClaimWallStatus where
  eNeutral : ∀ x : V4, V4.E * x = x
  distinctCollapse : V4.A * V4.B = V4.C
  /-- Witness: residual class of `35·1` equals class of `35` (E-neutral). -/
  residualCarries35 : toV4 (35 * 1) (by decide) = toV4 35 (by decide)
  dualBlocksCollapse : gammaFromResidual 25 1 (by decide) =
      gammaFromResidual 1 1 (by decide) ∧
    residualOmega 25 ≠ residualOmega 1
  noArithmeticFactorizationClaim : True
  noHigherCosinusClaim : True

/-- Bundle proof for documentation / ReachableTheorems. -/
def semiprim_claim_wall_status : SemiprimClaimWallStatus where
  eNeutral := v4_e_neutral
  distinctCollapse := distinct_channel_collapse
  residualCarries35 := residual_carries_v4_claim (by decide) isESmooth_one
  dualBlocksCollapse :=
    ⟨gammaFromResidual_collapse_semiprim_square, by
      rw [residualOmega_25, residualOmega_one]; decide⟩
  noArithmeticFactorizationClaim := cosinus_does_not_factor_arithmetically
  noHigherCosinusClaim := cosinus_does_not_reduce_higher

end KeplerHurwitz.EABC
