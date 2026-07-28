/-
  Conditional norm relation under explicit Syracuse hypotheses.

  Claim wall:
    [A] under named algebraic hypotheses H, `normSq` relations on
        `embedOddCore` / EABCCoord products via `normSq_mul`
    [A] schematic certificate: `post = pre * factor` ⇒ norm multiplicativity
    [B] audit-grid witnesses (7→11, 19→29, 11→17)
    [C] / [OFFEN · NON-CLAIM] H is not proved for all odd trajectories;
        Syracuse→global descent remains open (no Collatz proof)

  Docs: docs/eabc_collatz_audit_grid.md · Bridge: CollatzBridge.lean
-/

import KeplerHurwitz.EABC.CollatzBridge

namespace KeplerHurwitz.EABC
namespace CollatzSyracuseNorm

open EABCCoord
open CollatzBridge

/-! ## Explicit hypotheses H -/

/--
**[C]** Odd core is embeddable on the mod-12 \(V_4\) axis
(`Nat.Coprime κ 6`), matching `embedOddCore`.
-/
abbrev OddCoreEmbeddable (κ : ℕ) : Prop :=
  Nat.Coprime κ 6

/--
Accelerated Syracuse / odd-core step hypothesis:
\((3\kappa+1)=\kappa'\cdot 2^v\) with both cores embeddable and \(v\ge 1\).

This is the algebraic content of one accelerated Collatz half-step on odd cores.
It does **not** assert that every trajectory satisfies descent.
-/
structure SyracuseNormHypothesis (κ κ' : ℕ) (v : ℕ) : Prop where
  embeddable_pre : OddCoreEmbeddable κ
  embeddable_post : OddCoreEmbeddable κ'
  /-- Exact accelerated step: \(3\kappa+1 = \kappa' \cdot 2^v\). -/
  step_exact : 3 * κ + 1 = κ' * 2 ^ v
  v_pos : 0 < v

/--
B/C-channel half-step (`v = 1`): \(\kappa' = (3\kappa+1)/2\).
Special case of `SyracuseNormHypothesis` used by the audit grid.
-/
structure SyracuseHalfStepHypothesis (κ κ' : ℕ) : Prop where
  embeddable_pre : OddCoreEmbeddable κ
  embeddable_post : OddCoreEmbeddable κ'
  half_step : κ' = (3 * κ + 1) / 2
  even_step : Even (3 * κ + 1)

/-- Half-step hypotheses are accelerated hypotheses with `v = 1`. -/
theorem toSyracuseNormHypothesis_of_half
    {κ κ' : ℕ} (H : SyracuseHalfStepHypothesis κ κ') :
    SyracuseNormHypothesis κ κ' 1 where
  embeddable_pre := H.embeddable_pre
  embeddable_post := H.embeddable_post
  step_exact := by
    have h2 : 2 ∣ 3 * κ + 1 := H.even_step.two_dvd
    have : κ' * 2 = 3 * κ + 1 := by
      rw [H.half_step, Nat.div_mul_cancel h2]
    simpa [pow_one] using this.symm
  v_pos := Nat.one_pos

/-! ## Schematic mul-certificate [A] -/

/--
Schematic factorization hypothesis:
post-step embedding equals pre-step embedding times an EABC factor.
-/
def SyracuseEmbedFactors (pre post factor : EABCCoord ℤ) : Prop :=
  post = pre * factor

/--
**[A under H_mul]** If the step embeddings factor in `EABCCoord`, then
`normSq post = normSq pre * normSq factor`.
-/
theorem normSq_of_syracuseEmbedFactors
    {pre post factor : EABCCoord ℤ}
    (h : SyracuseEmbedFactors pre post factor) :
    normSq post = normSq pre * normSq factor := by
  unfold SyracuseEmbedFactors at h
  rw [h, EABCCoord.normSq_mul]

/-- Conjugation preserves squared norm. -/
theorem normSq_conj (q : EABCCoord ℤ) : normSq (conj q) = normSq q := by
  simp [normSq, conj]

/--
**[A under H_unit]** Multiplication by a Lipschitz unit preserves `normSq`.
-/
theorem normSq_mul_isLipschitzUnit
    (q u : EABCCoord ℤ) (hu : IsLipschitzUnit u) :
    normSq (q * u) = normSq q := by
  have h1 : normSq u = 1 := hu
  rw [EABCCoord.normSq_mul, h1, mul_one]

/--
Self-conjugate axis identity: `embed(κ) * conj(embed(κ))` is the pure-E
scalar of squared core (always true for any embeddable odd core).
-/
theorem embedOddCore_mul_conj (κ : ℕ) (h : OddCoreEmbeddable κ) :
    embedOddCore κ h * conj (embedOddCore κ h) =
      axisPureCoord .E ((κ : ℤ) ^ 2) := by
  -- Pure-axis × conjugate expands to `(κ², 0, 0, 0)` on every \(V_4\) channel.
  have hch := toV4_eq_of_mod12 h
  rcases hch with ⟨h1, hE⟩ | ⟨h5, hA⟩ | ⟨h7, hB⟩ | ⟨h11, hC⟩
  · simp [embedOddCore, axisPureCoord, conj, hE, sq]
  · simp [embedOddCore, axisPureCoord, conj, hA, sq]
  · simp [embedOddCore, axisPureCoord, conj, hB, sq]
  · simp [embedOddCore, axisPureCoord, conj, hC, sq]

theorem syracuseEmbedFactors_embed_mul_conj (κ : ℕ) (h : OddCoreEmbeddable κ) :
    SyracuseEmbedFactors
      (embedOddCore κ h)
      (axisPureCoord .E ((κ : ℤ) ^ 2))
      (conj (embedOddCore κ h)) :=
  (embedOddCore_mul_conj κ h).symm ▸ rfl

/-! ## Conditional norm relation under Syracuse H [A under H] -/

/--
**[A under H]** Under an accelerated Syracuse hypothesis, squared norms of the
axis embeddings are exactly the squared odd cores.
-/
theorem normSq_embed_of_syracuseNormHypothesis
    {κ κ' v : ℕ} (H : SyracuseNormHypothesis κ κ' v) :
    normSq (embedOddCore κ H.embeddable_pre) = (κ : ℤ) ^ 2 ∧
      normSq (embedOddCore κ' H.embeddable_post) = (κ' : ℤ) ^ 2 :=
  ⟨normSq_embedOddCore κ H.embeddable_pre,
    normSq_embedOddCore κ' H.embeddable_post⟩

/--
**[A under H]** Cross-norm identity: the ratio of embedding norms is the
ratio of squared cores (cleared of denominators).
-/
theorem normSq_cross_of_syracuseNormHypothesis
    {κ κ' v : ℕ} (H : SyracuseNormHypothesis κ κ' v) :
    normSq (embedOddCore κ' H.embeddable_post) * (κ : ℤ) ^ 2 =
      normSq (embedOddCore κ H.embeddable_pre) * (κ' : ℤ) ^ 2 := by
  rcases normSq_embed_of_syracuseNormHypothesis H with ⟨hκ, hκ'⟩
  rw [hκ, hκ', mul_comm]

/--
**[A under H]** Express the post-step embedding norm via the exact step
identity `3κ+1 = κ'·2^v` (still only algebraic — no descent).
-/
theorem normSq_post_eq_coreSq_of_syracuseNormHypothesis
    {κ κ' v : ℕ} (H : SyracuseNormHypothesis κ κ' v) :
    normSq (embedOddCore κ' H.embeddable_post) = (κ' : ℤ) ^ 2 :=
  (normSq_embed_of_syracuseNormHypothesis H).2

/--
**[A under H_half]** Half-step form: post-norm equals `((3κ+1)/2)²`.
-/
theorem normSq_embed_of_syracuseHalfStep
    {κ κ' : ℕ} (H : SyracuseHalfStepHypothesis κ κ') :
    normSq (embedOddCore κ' H.embeddable_post) =
      (((3 * κ + 1) / 2 : ℕ) : ℤ) ^ 2 := by
  have hκ' := normSq_embedOddCore κ' H.embeddable_post
  rw [hκ', H.half_step]

/--
Descent predicate on embeddings (strict drop of `normSq`).
Stated for clarity; **not** proved for arbitrary odd trajectories.
-/
def SyracuseNormDescent (κ κ' : ℕ)
    (hκ : OddCoreEmbeddable κ) (hκ' : OddCoreEmbeddable κ') : Prop :=
  normSq (embedOddCore κ' hκ') < normSq (embedOddCore κ hκ)

/-- Equivalent core comparison (via `normSq_embedOddCore`). -/
theorem syracuseNormDescent_iff_core_lt
    {κ κ' : ℕ} (hκ : OddCoreEmbeddable κ) (hκ' : OddCoreEmbeddable κ') :
    SyracuseNormDescent κ κ' hκ hκ' ↔ (κ' : ℤ) ^ 2 < (κ : ℤ) ^ 2 := by
  unfold SyracuseNormDescent
  rw [normSq_embedOddCore, normSq_embedOddCore]

/-! ## Audit-grid witnesses [B]/[A] -/

theorem syracuseHalfStep_7_11 : SyracuseHalfStepHypothesis 7 11 where
  embeddable_pre := by decide
  embeddable_post := by decide
  half_step := syracuse_witness_7_to_11
  even_step := by decide

theorem syracuseHalfStep_19_29 : SyracuseHalfStepHypothesis 19 29 where
  embeddable_pre := by decide
  embeddable_post := by decide
  half_step := syracuse_witness_19_to_29
  even_step := by decide

theorem syracuseHalfStep_11_17 : SyracuseHalfStepHypothesis 11 17 where
  embeddable_pre := by decide
  embeddable_post := by decide
  half_step := syracuse_witness_11_to_17
  even_step := by decide

theorem syracuseNormHypothesis_7_11 :
    SyracuseNormHypothesis 7 11 1 :=
  toSyracuseNormHypothesis_of_half syracuseHalfStep_7_11

theorem syracuseNormHypothesis_19_29 :
    SyracuseNormHypothesis 19 29 1 :=
  toSyracuseNormHypothesis_of_half syracuseHalfStep_19_29

theorem syracuseNormHypothesis_11_17 :
    SyracuseNormHypothesis 11 17 1 :=
  toSyracuseNormHypothesis_of_half syracuseHalfStep_11_17

/-- Witness 7→11: post-norm is `11²`, pre-norm is `7²`. -/
theorem normSq_witness_7_11 :
    normSq (embedOddCore 7 (by decide)) = (7 : ℤ) ^ 2 ∧
      normSq (embedOddCore 11 (by decide)) = (11 : ℤ) ^ 2 :=
  normSq_embed_of_syracuseNormHypothesis syracuseNormHypothesis_7_11

theorem normSq_witness_19_29 :
    normSq (embedOddCore 19 (by decide)) = (19 : ℤ) ^ 2 ∧
      normSq (embedOddCore 29 (by decide)) = (29 : ℤ) ^ 2 :=
  normSq_embed_of_syracuseNormHypothesis syracuseNormHypothesis_19_29

theorem normSq_witness_11_17 :
    normSq (embedOddCore 11 (by decide)) = (11 : ℤ) ^ 2 ∧
      normSq (embedOddCore 17 (by decide)) = (17 : ℤ) ^ 2 :=
  normSq_embed_of_syracuseNormHypothesis syracuseNormHypothesis_11_17

/--
Cross-factor certificate for the pair `(7,11)`:
`embed(11) * conj(embed(7)) = axisPureCoord A (7·11)`.

Instantiates `SyracuseEmbedFactors` for an audit-grid Syracuse pair.
-/
theorem embed_cross_factor_7_11 :
    embedOddCore 11 (by decide) * conj (embedOddCore 7 (by decide)) =
      axisPureCoord .A (7 * 11) := by
  simp [embedOddCore, toV4, axisPureCoord, conj]

theorem syracuseEmbedFactors_cross_7_11 :
    SyracuseEmbedFactors
      (embedOddCore 11 (by decide))
      (axisPureCoord .A (7 * 11))
      (conj (embedOddCore 7 (by decide))) :=
  embed_cross_factor_7_11.symm ▸ rfl

theorem normSq_cross_factor_7_11 :
    normSq (axisPureCoord .A (7 * 11)) =
      normSq (embedOddCore 11 (by decide)) *
        normSq (conj (embedOddCore 7 (by decide))) :=
  normSq_of_syracuseEmbedFactors syracuseEmbedFactors_cross_7_11

/-- Cross-factor for `(19,29)`: lands on pure-C with signed product. -/
theorem embed_cross_factor_19_29 :
    embedOddCore 29 (by decide) * conj (embedOddCore 19 (by decide)) =
      axisPureCoord .C (-(19 * 29 : ℤ)) := by
  simp [embedOddCore, toV4, axisPureCoord, conj]

theorem syracuseEmbedFactors_cross_19_29 :
    SyracuseEmbedFactors
      (embedOddCore 29 (by decide))
      (axisPureCoord .C (-(19 * 29 : ℤ)))
      (conj (embedOddCore 19 (by decide))) :=
  embed_cross_factor_19_29.symm ▸ rfl

theorem normSq_cross_factor_19_29 :
    normSq (axisPureCoord .C (-(19 * 29 : ℤ))) =
      normSq (embedOddCore 29 (by decide)) *
        normSq (conj (embedOddCore 19 (by decide))) :=
  normSq_of_syracuseEmbedFactors syracuseEmbedFactors_cross_19_29

/-- Cross-factor for `(11,17)`: lands on pure-B. -/
theorem embed_cross_factor_11_17 :
    embedOddCore 17 (by decide) * conj (embedOddCore 11 (by decide)) =
      axisPureCoord .B (11 * 17) := by
  simp [embedOddCore, toV4, axisPureCoord, conj]

theorem syracuseEmbedFactors_cross_11_17 :
    SyracuseEmbedFactors
      (embedOddCore 17 (by decide))
      (axisPureCoord .B (11 * 17))
      (conj (embedOddCore 11 (by decide))) :=
  embed_cross_factor_11_17.symm ▸ rfl

theorem normSq_cross_factor_11_17 :
    normSq (axisPureCoord .B (11 * 17)) =
      normSq (embedOddCore 17 (by decide)) *
        normSq (conj (embedOddCore 11 (by decide))) :=
  normSq_of_syracuseEmbedFactors syracuseEmbedFactors_cross_11_17

/--
These audit witnesses are **ascents** on `normSq` (7→11, 19→29, 11→17).
Descent is therefore not automatic from a single B/C half-step.
-/
theorem witness_7_11_is_ascent :
    ¬ SyracuseNormDescent 7 11 (by decide) (by decide) := by
  rw [syracuseNormDescent_iff_core_lt]
  norm_num

theorem witness_19_29_is_ascent :
    ¬ SyracuseNormDescent 19 29 (by decide) (by decide) := by
  rw [syracuseNormDescent_iff_core_lt]
  norm_num

theorem witness_11_17_is_ascent :
    ¬ SyracuseNormDescent 11 17 (by decide) (by decide) := by
  rw [syracuseNormDescent_iff_core_lt]
  norm_num

/-! ## Explicit non-claims [OFFEN · NON-CLAIM] -/

/--
**[OFFEN / NON-CLAIM]** The hypothesis `SyracuseNormHypothesis` (or half-step H)
is **not** proved for every odd core along every Collatz/Syracuse trajectory,
nor is global eventual descent of `normSq ∘ embedOddCore`.

What would close the gap (still open):
1. for every odd embeddable `κ > 1`, a finite accelerated segment reaching a
   core `κ'` with `SyracuseNormDescent κ κ' …`, and
2. exclusion of divergent / exotic cycles.

This module only makes that gap precise: H ⇒ norm relation on embeddings.
-/
theorem syracuse_global_descent_not_claimed : True := trivial

/-- This module does not prove the Collatz conjecture. -/
theorem collatz_not_proved_by_syracuse_norm : True := trivial

end CollatzSyracuseNorm
end KeplerHurwitz.EABC
