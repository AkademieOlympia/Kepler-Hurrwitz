import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.CollatzProofAttemptV27
import KeplerHurwitz.Nu2Bounds

/-!
# Kanal-7 V2.15 — Ebene B: Dynamik nach `S⁵ = 243t + c_j`

Governance: `[A]` für algebraische Brücken; `[C]` für dynamischen Deszent und Witness-Assembly.

\[
\boxed{\text{2-adische Struktur} \;\neq\; \text{dynamischer Deszent}}
\]

Ebene B beginnt, wenn die V2.14-Terminalform `243t + c_j` feststeht und die
Fortsetzung unter `syracuseOddStep` (= `oddCoreStep`) untersucht wird.

**Nicht behauptet:** globale Collatz-Terminierung, Kanal-7-Schließung, ε₀-Rang.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenDynamicsV215

open KeplerHurwitz
open KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215
open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
open KeplerHurwitz.Collatz.ChannelSevenAttackV213
open KeplerHurwitz.Collatz.Octonion

abbrev syracuseOddStep (n : Nat) : Nat :=
  oddCoreStep n

/-!
## H6 — Normalisierte Faser `243t + c_j`
-/

/-- Affine Terminalfamilie nach exakter Lift-Schale `j`: `243t + c_j`. -/
def deepLiftFiber (j t : Nat) : Nat :=
  deepBranchMultiplier * t + deepLiftConstant j

/-- H7-A-Alias: explizite affine Form `243t + c_j` (aligniert mit `deepLiftFiber`). -/
def deepLiftAffine (j t : Nat) : Nat :=
  243 * t + deepLiftConstant j

theorem deepLiftAffine_eq (j t : Nat) :
    deepLiftAffine j t = deepLiftFiber j t := by
  unfold deepLiftAffine deepLiftFiber deepBranchMultiplier
  rfl

/-- Lift-Parameter `r = ρ_j + 2^j · t` in `243r + 95`. -/
def deepBranchParam (j t : Nat) : Nat :=
  deepLiftResidue j + deepLiftModulus j * t

theorem deepLiftFiber_eq (j t : Nat) :
    deepLiftFiber j t = 243 * t + deepLiftConstant j := by
  unfold deepLiftFiber deepBranchMultiplier
  rfl

theorem deepBranchParam_eq (j t : Nat) :
    deepBranchParam j t = deepLiftResidue j + deepLiftModulus j * t := by
  rfl

theorem deepBranchPoly_deepBranchParam (j t : Nat) :
    deepBranchPoly (deepBranchParam j t) =
      deepLiftModulus j * (deepBranchMultiplier * t + deepLiftConstant j) := by
  simpa [deepBranchParam] using deepLift_affine_factorization j t

theorem deepLiftFiber_residue_mod_three (j t : Nat) :
    deepLiftFiber j t % 3 = deepLiftConstant j % 3 := by
  unfold deepLiftFiber deepBranchMultiplier
  simp [Nat.mul_mod, show 243 % 3 = 0 from by decide, Nat.zero_mod, Nat.add_mod]

theorem deepLiftFiber_odd_of_exactVal (j t : Nat)
    (heq : padicValNat 2 (deepBranchPoly (deepBranchParam j t)) = j) :
    Odd (deepLiftFiber j t) := by
  rw [deepLiftFiber_eq]
  exact odd_of_exact_padicVal j t (by simpa [deepBranchParam_eq] using heq)

theorem deepLiftFiber_t_zero (j : Nat) :
    deepLiftFiber j 0 = deepLiftConstant j := by
  simp [deepLiftFiber, deepBranchMultiplier]

theorem deepLiftFiber_t_zero_one : deepLiftFiber 1 0 = 169 := by decide
theorem deepLiftFiber_t_zero_two : deepLiftFiber 2 0 = 206 := by decide
theorem deepLiftFiber_t_zero_three : deepLiftFiber 3 0 = 103 := by decide
theorem deepLiftFiber_t_zero_four : deepLiftFiber 4 0 = 173 := by decide
theorem deepLiftFiber_t_zero_five : deepLiftFiber 5 0 = 208 := by decide

private theorem deepBranchParam_three_eq (t : Nat) :
    deepBranchParam 3 t = 3 + 8 * t := by
  unfold deepBranchParam
  rw [deepLiftResidue_three, deepLiftModulus]
  ring

private theorem deepBranchPoly_param_three_eq (t : Nat) :
    deepBranchPoly (deepBranchParam 3 t) = 8 * (103 + 243 * t) := by
  rw [deepBranchParam_three_eq]
  unfold deepBranchPoly deepBranchMultiplier deepBranchConstant
  ring

private theorem deepBranchPoly_param_three_exactVal (t : Nat) (ht : t % 2 = 0) :
    padicValNat 2 (deepBranchPoly (deepBranchParam 3 t)) = 3 := by
  rw [deepBranchPoly_param_three_eq]
  have hne : 103 + 243 * t ≠ 0 := by omega
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  rw [padicValNat.mul (by decide : (8 : Nat) ≠ 0) hne, padicValNat_eight]
  have hodd : (103 + 243 * t) % 2 = 1 := by omega
  have h0 : padicValNat 2 (103 + 243 * t) = 0 := by
    rw [padicValNat.eq_zero_of_not_dvd]
    intro h2
    have := Nat.dvd_iff_mod_eq_zero.mp h2
    omega
  omega

private theorem oddCore_deepBranchPoly_param_three (t : Nat) (ht : t % 2 = 0) :
    oddCore (deepBranchPoly (deepBranchParam 3 t)) = 103 + 243 * t := by
  rw [deepBranchPoly_param_three_eq]
  have hodd : Odd (103 + 243 * t) := by
    have h1 : (103 + 243 * t) % 2 = 1 := by omega
    exact Nat.odd_iff.mpr h1
  exact (oddCore_two_pow_mul 3 (103 + 243 * t) hodd)

/--
V2.13-Zweig `k ≡ 1 (mod 4)` bei exakter Schale `j = 3` und geradem `t`:
`S⁵(512·(3+8t)+199) = 243t + 103`.
-/
theorem channelSeven71_step5_deepLiftFiber_j3_even_t (t : Nat) (ht : t % 2 = 0) :
    syracuseOddStep^[5] (channelSeven71Fiber (4 * (deepBranchParam 3 t) + 1)) =
      deepLiftFiber 3 t := by
  set r := deepBranchParam 3 t
  have hr : r = 3 + 8 * t := deepBranchParam_three_eq t
  have hpoly := deepBranchPoly_param_three_eq t
  have hkick :
      3 * (162 * (4 * r + 1) + 91) + 1 = 2 ^ 3 * deepBranchPoly r := by
    rw [hr, deepBranchPoly_eq, channelSeven71_step5_certificate_mod4_one]
  have hnu_inner : padicValNat 2 (deepBranchPoly r) = 3 :=
    deepBranchPoly_param_three_exactVal t ht
  have hnu_kick : padicValNat 2 (3 * (162 * (4 * r + 1) + 91) + 1) = 6 := by
    rw [hkick]
    have hne : deepBranchPoly r ≠ 0 := deepBranchPoly_ne_zero r
    haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
    rw [padicValNat.mul (by decide : (2 ^ 3 : Nat) ≠ 0) hne, padicValNat.prime_pow, hnu_inner]
  have hnu_pow : padicValNat 2 (2 ^ 3 * deepBranchPoly r) = 6 := by
    have hne : deepBranchPoly r ≠ 0 := deepBranchPoly_ne_zero r
    haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
    rw [padicValNat.mul (by decide : (2 ^ 3 : Nat) ≠ 0) hne, padicValNat.prime_pow, hnu_inner]
  rw [syracuseOdd_iterate_five_channelSeven71_mod4_one, hkick, hnu_pow]
  have hdiv : 2 ^ 3 * deepBranchPoly r / 2 ^ 6 = 103 + 243 * t := by
    rw [hpoly]
    rw [show 2 ^ 3 * (8 * (103 + 243 * t)) = 2 ^ 6 * (103 + 243 * t) from by ring]
    exact Nat.mul_div_cancel_left _ (by decide : 0 < 2 ^ 6)
  rw [hdiv, deepLiftFiber_eq, deepLiftConstant_three, Nat.add_comm]

/-- Anker `t = 0`: `S⁵(1735) = 103` auf der `j = 3`-Schale. -/
theorem channelSeven71_step5_deepLiftFiber_j3_t_zero :
    syracuseOddStep^[5] (channelSeven71Fiber 13) = 103 := by
  have h13 : 4 * (deepBranchParam 3 0) + 1 = 13 := by
    unfold deepBranchParam; rw [deepLiftResidue_three, deepLiftModulus]; decide
  rw [← h13]
  simpa [deepLiftFiber_t_zero_three] using
    channelSeven71_step5_deepLiftFiber_j3_even_t 0 (by decide)

/-!
## H6b — Step 6 auf Schale `j = 3`: `m = 243t + 103` mit geradem `t`

H4-Seitenbedingung: Terminalfamilie ist ungerade genau wenn `t` gerade ist.
Parameterisierung `t = 2u` liefert `m = 486u + 103` und `3m+1 = 2(729u+155)`.
-/

/-- H4: `243t + 103` ist ungerade genau für gerades `t` (exakte Schale `j = 3`). -/
theorem deepLiftFiber_j3_odd_iff_t_even (t : Nat) :
    Odd (deepLiftFiber 3 t) ↔ t % 2 = 0 := by
  rw [deepLiftFiber_eq, deepLiftConstant_three, Nat.odd_iff]
  omega

theorem deepLiftFiber_j3_reparam_even (u : Nat) :
    deepLiftFiber 3 (2 * u) = 486 * u + 103 := by
  rw [deepLiftFiber_eq, deepLiftConstant_three]
  ring

theorem deepLiftFiber_j3_step6_certificate (u : Nat) :
    3 * (486 * u + 103) + 1 = 2 * (729 * u + 155) := by
  ring

theorem deepLiftFiber_j3_step6_quotient_parity (u : Nat) :
    (729 * u + 155) % 2 = (u + 1) % 2 := by
  omega

theorem deepLiftFiber_j3_step6_quotient_odd_u_even (u : Nat) (hu : u % 2 = 0) :
    Odd (729 * u + 155) := by
  have h1 : (729 * u + 155) % 2 = 1 := by omega
  exact Nat.odd_iff.mpr h1

theorem deepLiftFiber_j3_step6_quotient_even_u_odd (u : Nat) (hu : u % 2 = 1) :
    (729 * u + 155) % 2 = 0 := by
  omega

theorem deepLiftFiber_j3_step6_mod8_u_even (u : Nat) (hu : u % 2 = 0) :
    (486 * u + 103) % 8 = 3 ∨ (486 * u + 103) % 8 = 7 := by
  omega

theorem deepLiftFiber_j3_step6_mod8_u_odd (u : Nat) (hu : u % 2 = 1) :
    (486 * u + 103) % 8 = 1 ∨ (486 * u + 103) % 8 = 5 := by
  omega

theorem deepLiftFiber_j3_step6_nu2_eq_one_u_even (u : Nat) (hu : u % 2 = 0) :
    padicValNat 2 (3 * (486 * u + 103) + 1) = 1 := by
  rcases deepLiftFiber_j3_step6_mod8_u_even u hu with h3 | h7
  · exact nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3
  · exact nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem deepLiftFiber_j3_step6_nu2_u_odd (u : Nat) (hu : u % 2 = 1) :
    padicValNat 2 (3 * (486 * u + 103) + 1) = 2 ∨
      3 ≤ padicValNat 2 (3 * (486 * u + 103) + 1) := by
  rcases deepLiftFiber_j3_step6_mod8_u_odd u hu with h1 | h5
  · exact Or.inl (nu2_three_mul_add_one_eq_two_of_mod8_eq1 h1)
  · exact Or.inr (nu2_three_mul_add_one_ge_three_of_mod8_eq5 h5)

theorem syracuseOdd_deepLiftFiber_j3_step6_u_even (u : Nat) (hu : u % 2 = 0) :
    syracuseOddStep (deepLiftFiber 3 (2 * u)) = 729 * u + 155 := by
  rw [deepLiftFiber_j3_reparam_even]
  exact oddCoreStep_eq_of_two_pow_mul_odd
    (deepLiftFiber_j3_step6_certificate u)
    (deepLiftFiber_j3_step6_quotient_odd_u_even u hu)
    (deepLiftFiber_j3_step6_nu2_eq_one_u_even u hu)

theorem syracuseOdd_deepLiftFiber_j3_step6_u_odd (u : Nat) (_hu : u % 2 = 1) :
    syracuseOddStep (deepLiftFiber 3 (2 * u)) =
      (3 * (486 * u + 103) + 1) /
        2 ^ padicValNat 2 (3 * (486 * u + 103) + 1) := by
  rw [deepLiftFiber_j3_reparam_even, syracuseOddStep, oddCoreStep_eq_div_padicVal]

theorem syracuseOdd_deepLiftFiber_j3_step6 (t : Nat) (_ht : t % 2 = 0) :
    let u := t / 2
    t = 2 * u ∧
      (u % 2 = 0 → syracuseOddStep (deepLiftFiber 3 t) = 729 * u + 155) ∧
        (u % 2 = 1 →
          syracuseOddStep (deepLiftFiber 3 t) =
            (3 * (486 * u + 103) + 1) /
              2 ^ padicValNat 2 (3 * (486 * u + 103) + 1)) := by
  set u := t / 2
  have hu : t = 2 * u := by omega
  refine ⟨hu, ?_, ?_⟩
  · intro h0
    rw [show deepLiftFiber 3 t = deepLiftFiber 3 (2 * u) from by rw [hu]]
    exact syracuseOdd_deepLiftFiber_j3_step6_u_even u h0
  · intro h1
    rw [show deepLiftFiber 3 t = deepLiftFiber 3 (2 * u) from by rw [hu]]
    exact syracuseOdd_deepLiftFiber_j3_step6_u_odd u h1

theorem syracuseOdd_deepLiftFiber_j3_step6_anchor :
    syracuseOddStep (deepLiftFiber 3 0) = 155 := by
  simpa using syracuseOdd_deepLiftFiber_j3_step6_u_even 0 (by decide)

/-- Step-6-Ziel `729u+155` modulo `128` am Anker `u = 0` (dynamischer mod-128-Eintritt: `[C]`). -/
theorem deepLiftFiber_j3_step6_mod128_anchor :
    (729 * 0 + 155) % 128 = 27 := by decide

/-!
## H7-A — mod-128 affine Brücke (`[A]`, importiert)

Siehe `ChannelSevenAffineMod128V215` — sorry-frei.

Governance:
\[
\boxed{\text{Zielfaser algebraisch parametrisiert} \neq \text{Zielfaser dynamisch erreicht}}
\]

Dynamische Erreichbarkeit kontrollierter Fasern: `ChannelSevenDynamicsHypothesesV215` (`[C]`).
-/

theorem deepLiftFiberZMod_eq (j t : ℕ) :
    deepLiftFiberZMod j (t : mod128) = (deepLiftFiber j t : mod128) := by
  dsimp [deepLiftFiberZMod, deepLiftFiber, deepLiftAffineZMod, deepLiftAffine,
    deepLiftConstantZMod, deepBranchMultiplier]
  push_cast
  ring

theorem deepLiftAffineZMod_eq (j t : ℕ) :
    deepLiftAffineZMod j (t : mod128) = (deepLiftAffine j t : mod128) := by
  dsimp [deepLiftAffineZMod, deepLiftAffine, deepLiftConstantZMod, deepBranchMultiplier]
  push_cast
  ring

theorem deepLiftFiber_modEq128_iff (j t a : ℕ) :
    Nat.ModEq 128 (deepLiftFiber j t) a ↔
      Nat.ModEq 128 t (entryParameterMod128 j (a : mod128)).val := by
  constructor
  · intro h
    have hz : (deepLiftFiber j t : mod128) = (a : mod128) :=
      (ZMod.natCast_eq_natCast_iff _ _ 128).mpr h
    have huniq := deepLiftFiber_entry_unique j (a : mod128) (t : mod128)
      (by simpa [deepLiftFiberZMod_eq] using hz)
    have hv : t % 128 = (entryParameterMod128 j (a : mod128)).val := by
      simpa [ZMod.val_natCast] using congrArg ZMod.val huniq
    rw [Nat.ModEq, hv, Nat.mod_eq_of_lt (ZMod.val_lt (entryParameterMod128 j (a : mod128)))]
  · intro h
    have ht : (t : mod128) = entryParameterMod128 j (a : mod128) := by
      simpa [ZMod.natCast_val] using (ZMod.natCast_eq_natCast_iff _ _ 128).mpr h
    have heq : (deepLiftFiber j t : mod128) = (a : mod128) := by
      rw [← deepLiftFiberZMod_eq, ht]
      show deepLiftAffineZMod j (entryParameterMod128 j (a : mod128)) = (a : mod128)
      exact deepLiftFiber_entry_spec j (a : mod128)
    exact (ZMod.natCast_eq_natCast_iff _ _ 128).mp heq

theorem deepLiftFiber_mod128_parameter (j a : ℕ) :
    (deepLiftFiber j (entryParameterMod128 j (a : mod128)).val) % 128 = a % 128 :=
  (deepLiftFiber_modEq128_iff j (entryParameterMod128 j (a : mod128)).val a).mpr
    (Nat.ModEq.refl _)

abbrev deepLiftAffine_modEq128_iff := deepLiftFiber_modEq128_iff
abbrev deepLiftAffine_mod128_parameter := deepLiftFiber_mod128_parameter

/-!
## V2.15 Status-Bündel (`[A]` sorry-frei; `[C]` in `ChannelSevenDynamicsHypothesesV215`)
-/

structure ChannelSevenDynamicsV215Scaffold : Prop where
  fiber_definitions :
    (∀ j t : Nat, deepLiftFiber j t = 243 * t + deepLiftConstant j) ∧
      (∀ j t : Nat, deepLiftAffine j t = 243 * t + deepLiftConstant j) ∧
        (∀ j t : Nat, deepBranchParam j t = deepLiftResidue j + deepLiftModulus j * t)
  mod_three_invariant :
    ∀ j t : Nat, deepLiftFiber j t % 3 = deepLiftConstant j % 3
  j3_step5_bridge :
    ∀ t : Nat, t % 2 = 0 →
      syracuseOddStep^[5] (channelSeven71Fiber (4 * (deepBranchParam 3 t) + 1)) =
        deepLiftFiber 3 t
  j3_step6_shell :
    ∀ t : Nat, Odd (deepLiftFiber 3 t) ↔ t % 2 = 0
  j3_step6_kick :
    ∀ u : Nat, u % 2 = 0 →
      syracuseOddStep (deepLiftFiber 3 (2 * u)) = 729 * u + 155
  j3_step6_nu2 :
    ∀ u : Nat, u % 2 = 0 → padicValNat 2 (3 * (486 * u + 103) + 1) = 1
  j3_step6_nu2_odd :
    ∀ u : Nat, u % 2 = 1 →
      padicValNat 2 (3 * (486 * u + 103) + 1) = 2 ∨
        3 ≤ padicValNat 2 (3 * (486 * u + 103) + 1)
  anchor_t_zero :
    syracuseOddStep^[5] (channelSeven71Fiber 13) = 103
  anchor_step6 :
    syracuseOddStep (deepLiftFiber 3 0) = 155
  t_zero_values :
    deepLiftFiber 1 0 = 169 ∧
      deepLiftFiber 2 0 = 206 ∧
        deepLiftFiber 3 0 = 103 ∧
          deepLiftFiber 4 0 = 173 ∧
            deepLiftFiber 5 0 = 208
  level_a_import :
    ChannelSevenDeepLiftScaffold
  h7_mod128_inverse :
    (243 : mod128) * 59 = 1 ∧
      (59 : mod128) * 243 = 1
  h7_entry_spec :
    ∀ (j : ℕ) (a : mod128),
      deepLiftFiberZMod j (entryParameterMod128 j a) = a
  h7_permutation :
    ∀ (j : ℕ), Function.Bijective (deepLiftFiberPermutation j)
  h7_entry_unique :
    ∀ (j : ℕ) (a t : mod128),
      deepLiftFiberZMod j t = a → t = entryParameterMod128 j a
  h7_has_unique_parameter_type :
    ∀ (j : ℕ) (a : mod128), ∃! t : mod128, deepLiftFiberZMod j t = a
  h7_modEq128_iff :
    ∀ (j t a : ℕ), Nat.ModEq 128 (deepLiftFiber j t) a ↔
      Nat.ModEq 128 t (entryParameterMod128 j (a : mod128)).val
  h7_mod128_parameter :
    ∀ (j a : ℕ),
      (deepLiftFiber j (entryParameterMod128 j (a : mod128)).val) % 128 = a % 128

theorem channel_seven_dynamics_v215_scaffold : ChannelSevenDynamicsV215Scaffold where
  fiber_definitions := ⟨deepLiftFiber_eq, deepLiftAffine_eq, deepBranchParam_eq⟩
  mod_three_invariant := deepLiftFiber_residue_mod_three
  j3_step5_bridge := channelSeven71_step5_deepLiftFiber_j3_even_t
  j3_step6_shell := deepLiftFiber_j3_odd_iff_t_even
  j3_step6_kick := syracuseOdd_deepLiftFiber_j3_step6_u_even
  j3_step6_nu2 := deepLiftFiber_j3_step6_nu2_eq_one_u_even
  j3_step6_nu2_odd := deepLiftFiber_j3_step6_nu2_u_odd
  anchor_t_zero := channelSeven71_step5_deepLiftFiber_j3_t_zero
  anchor_step6 := syracuseOdd_deepLiftFiber_j3_step6_anchor
  t_zero_values := ⟨
    deepLiftFiber_t_zero_one, deepLiftFiber_t_zero_two, deepLiftFiber_t_zero_three,
    deepLiftFiber_t_zero_four, deepLiftFiber_t_zero_five⟩
  level_a_import := channel_seven_deep_lift_scaffold
  h7_mod128_inverse := ⟨coeff243_mul_59_mod128, coeff59_mul_243_mod128⟩
  h7_entry_spec := deepLiftFiber_entry_spec
  h7_permutation := fun j => (deepLiftFiberPermutation j).bijective
  h7_entry_unique := deepLiftFiber_entry_unique
  h7_has_unique_parameter_type := deepLiftFiber_has_unique_parameter_type
  h7_modEq128_iff := deepLiftFiber_modEq128_iff
  h7_mod128_parameter := deepLiftFiber_mod128_parameter

end KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
