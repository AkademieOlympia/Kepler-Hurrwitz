import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
import KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
import KeplerHurwitz.CollatzChannelSeven

/-!
# Kanal-7 V2.16 — Deep-Lift → formale Witness-Union

Glue: wenn die affine Terminalfaser `deepLiftFiber j t = 243t + c_j` in einer
bereits formal geschlossenen Restklasse landet, erbt sie den
`LocalWitnessStatementMod8` aus `CollatzChannelSeven`.

## Governance
- `[A]` Fallunterscheidung über bewiesene Restklassen-Unions; keine neuen
  `t_loc`-Zertifikate, kein Deep-Tail-Claim.
- Dynamischer Eintritt „irgendein `ℓ` führt in die Zielfaser“ bleibt `[C]`
  (`ChannelSevenDynamicsHypothesesV215`).
- Kein globaler Collatz-Beweis.

## Domäne (ehrlich)
- Volle mod-128-Klassen `{7,15,23,55,87,119}`: Parameterbedingung `t % 128`.
- Partielle mod-256-Klassen `{39,79,95}`: feinere Bedingung `t % 256`
  (Geschwister `{167,207,223}` bleiben offen).
-/

namespace KeplerHurwitz.Collatz.ChannelSevenDeepLiftFormalBridgeV216

open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
open KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
open KeplerHurwitz.CollatzAttemptV2.CollatzNetDescent.ChannelSeven

/-! ## Affine Reduktion mod 128 / 256 -/

theorem deepLiftFiber_mod128 (j t : Nat) :
    deepLiftFiber j t % 128 =
      (243 * (t % 128) + deepLiftConstant j) % 128 := by
  unfold deepLiftFiber deepBranchMultiplier
  exact ((Nat.mod_modEq t 128).symm.mul_left 243).add_right (deepLiftConstant j)

theorem deepLiftFiber_mod256 (j t : Nat) :
    deepLiftFiber j t % 256 =
      (243 * (t % 256) + deepLiftConstant j) % 256 := by
  unfold deepLiftFiber deepBranchMultiplier
  exact ((Nat.mod_modEq t 256).symm.mul_left 243).add_right (deepLiftConstant j)

theorem deepLiftFiber_j3_mod128 (t : Nat) :
    deepLiftFiber 3 t % 128 = (243 * (t % 128) + 103) % 128 := by
  simpa [deepLiftConstant_three] using deepLiftFiber_mod128 3 t

theorem deepLiftFiber_j3_mod256 (t : Nat) :
    deepLiftFiber 3 t % 256 = (243 * (t % 256) + 103) % 256 := by
  simpa [deepLiftConstant_three] using deepLiftFiber_mod256 3 t

theorem deepLiftFiber_j3_gt_one (t : Nat) : 1 < deepLiftFiber 3 t := by
  simp [deepLiftFiber_eq, deepLiftConstant_three]

/-! ## j = 3: volle formale Eintrittsparameter mod 128 -/

/--
Parameter `t mod 128`, für die `deepLiftFiber 3 t` in einer *voll* geschlossenen
mod-128-Klasse landet (nicht nur partiell mod 256).
-/
def deepLiftJ3FullFormalEntryParamsMod128 : List Nat :=
  [16, 48, 56, 80, 96, 112]

theorem deepLiftJ3FullFormalEntryParamsMod128_eq :
    deepLiftJ3FullFormalEntryParamsMod128 = [16, 48, 56, 80, 96, 112] :=
  rfl

/--
`[A]` Explizite Treffer der sechs vollen formalen Klassen für Schale `j = 3`.
-/
theorem deepLiftFiber_j3_full_formal_entry_residue (t : Nat)
    (ht :
      t % 128 = 16 ∨ t % 128 = 48 ∨ t % 128 = 56 ∨
        t % 128 = 80 ∨ t % 128 = 96 ∨ t % 128 = 112) :
    deepLiftFiber 3 t % 128 = 23 ∨
      deepLiftFiber 3 t % 128 = 119 ∨
        deepLiftFiber 3 t % 128 = 15 ∨
          deepLiftFiber 3 t % 128 = 87 ∨
            deepLiftFiber 3 t % 128 = 7 ∨
              deepLiftFiber 3 t % 128 = 55 := by
  rw [deepLiftFiber_j3_mod128]
  rcases ht with h | h | h | h | h | h
  · rw [h]; decide
  · rw [h]; decide
  · rw [h]; decide
  · rw [h]; decide
  · rw [h]; decide
  · rw [h]; decide

/--
`[A]` Deep-Lift-Schale `j = 3` auf voll-formalem Eintrittsparameter erbt den
mod-128-Witness. Kein Claim für andere `t` und kein dynamischer `ℓ`-Eintritt.
-/
theorem deepLiftFiber_j3_full_formal_entry_local_witness (t : Nat)
    (ht :
      t % 128 = 16 ∨ t % 128 = 48 ∨ t % 128 = 56 ∨
        t % 128 = 80 ∨ t % 128 = 96 ∨ t % 128 = 112) :
    LocalWitnessStatementMod8 (deepLiftFiber 3 t) := by
  have hn : 1 < deepLiftFiber 3 t := deepLiftFiber_j3_gt_one t
  have hhit := deepLiftFiber_j3_full_formal_entry_residue t ht
  have hres :
      deepLiftFiber 3 t % 128 = 7 ∨ deepLiftFiber 3 t % 128 = 15 ∨
        deepLiftFiber 3 t % 128 = 23 ∨ deepLiftFiber 3 t % 128 = 55 ∨
          deepLiftFiber 3 t % 128 = 87 ∨ deepLiftFiber 3 t % 128 = 119 := by
    rcases hhit with h | h | h | h | h | h
    · exact Or.inr (Or.inr (Or.inl h))
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr h))))
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h))))
    · exact Or.inl h
    · exact Or.inr (Or.inr (Or.inr (Or.inl h)))
  exact bad_run_net_descent_witness_mod128_channel_seven_formal_union hn hres

/-! ## j = 3: partielle mod-256-Eintrittsparameter -/

/--
Feinere Parameter für die drei partiellen mod-256-Unterklassen.
`t % 128` allein reicht nicht: `t ↦ t+128` wechselt das Geschwister-Bit.
-/
def deepLiftJ3PartialFormalEntryParamsMod256 : List Nat :=
  [40, 64, 120]

theorem deepLiftFiber_j3_partial_formal_entry_residue (t : Nat)
    (ht : t % 256 = 40 ∨ t % 256 = 64 ∨ t % 256 = 120) :
    deepLiftFiber 3 t % 256 = 95 ∨
      deepLiftFiber 3 t % 256 = 39 ∨
        deepLiftFiber 3 t % 256 = 79 := by
  rw [deepLiftFiber_j3_mod256]
  rcases ht with h | h | h
  · rw [h]; decide
  · rw [h]; decide
  · rw [h]; decide

/--
`[A]` Deep-Lift `j = 3` auf partiell-formalem mod-256-Eintritt erbt den
mod-256-Teilzeugen. Geschwister `t ≡ 40+128, 64+128, 120+128 (mod 256)` bleiben offen.
-/
theorem deepLiftFiber_j3_partial_formal_entry_local_witness (t : Nat)
    (ht : t % 256 = 40 ∨ t % 256 = 64 ∨ t % 256 = 120) :
    LocalWitnessStatementMod8 (deepLiftFiber 3 t) := by
  have hn : 1 < deepLiftFiber 3 t := deepLiftFiber_j3_gt_one t
  have hhit := deepLiftFiber_j3_partial_formal_entry_residue t ht
  have hres :
      deepLiftFiber 3 t % 256 = 39 ∨
        deepLiftFiber 3 t % 256 = 79 ∨
          deepLiftFiber 3 t % 256 = 95 := by
    rcases hhit with h | h | h
    · exact Or.inr (Or.inr h)
    · exact Or.inl h
    · exact Or.inr (Or.inl h)
  exact bad_run_net_descent_witness_mod256_channel_seven_partial_union hn hres

/--
`[A]` Vereinigte Deep-Lift-Brücke für Schale `j = 3`: voll-formal mod 128 oder
partiell-formal mod 256.
-/
theorem deepLiftFiber_j3_formal_extended_entry_local_witness (t : Nat)
    (ht :
      t % 128 = 16 ∨ t % 128 = 48 ∨ t % 128 = 56 ∨
        t % 128 = 80 ∨ t % 128 = 96 ∨ t % 128 = 112 ∨
          t % 256 = 40 ∨ t % 256 = 64 ∨ t % 256 = 120) :
    LocalWitnessStatementMod8 (deepLiftFiber 3 t) := by
  rcases ht with h | h | h | h | h | h | h | h | h
  · exact deepLiftFiber_j3_full_formal_entry_local_witness t (Or.inl h)
  · exact deepLiftFiber_j3_full_formal_entry_local_witness t
      (Or.inr (Or.inl h))
  · exact deepLiftFiber_j3_full_formal_entry_local_witness t
      (Or.inr (Or.inr (Or.inl h)))
  · exact deepLiftFiber_j3_full_formal_entry_local_witness t
      (Or.inr (Or.inr (Or.inr (Or.inl h))))
  · exact deepLiftFiber_j3_full_formal_entry_local_witness t
      (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h)))))
  · exact deepLiftFiber_j3_full_formal_entry_local_witness t
      (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr h)))))
  · exact deepLiftFiber_j3_partial_formal_entry_local_witness t (Or.inl h)
  · exact deepLiftFiber_j3_partial_formal_entry_local_witness t
      (Or.inr (Or.inl h))
  · exact deepLiftFiber_j3_partial_formal_entry_local_witness t
      (Or.inr (Or.inr h))

/-- Status-Bündel V2.16: erweiterte Union + Deep-Lift-Brücke `[A]`. -/
structure ChannelSevenDeepLiftFormalBridgeV216Status : Prop where
  extended_coverage :
    channelSevenFormalExtendedCoverageFraction = 15 / 32
  mod256_partial_union :
    ∀ {n : Nat}, 1 < n →
      (n % 256 = 39 ∨ n % 256 = 79 ∨ n % 256 = 95) →
        LocalWitnessStatementMod8 n
  formal_extended_union :
    ∀ {n : Nat}, 1 < n →
      (n % 128 = 7 ∨ n % 128 = 15 ∨ n % 128 = 23 ∨
        n % 128 = 55 ∨ n % 128 = 87 ∨ n % 128 = 119 ∨
          n % 256 = 39 ∨ n % 256 = 79 ∨ n % 256 = 95) →
        LocalWitnessStatementMod8 n
  j3_full_entry_witness :
    ∀ t : Nat,
      (t % 128 = 16 ∨ t % 128 = 48 ∨ t % 128 = 56 ∨
        t % 128 = 80 ∨ t % 128 = 96 ∨ t % 128 = 112) →
        LocalWitnessStatementMod8 (deepLiftFiber 3 t)
  j3_partial_entry_witness :
    ∀ t : Nat,
      (t % 256 = 40 ∨ t % 256 = 64 ∨ t % 256 = 120) →
        LocalWitnessStatementMod8 (deepLiftFiber 3 t)

theorem channel_seven_deep_lift_formal_bridge_v216_status :
    ChannelSevenDeepLiftFormalBridgeV216Status where
  extended_coverage := rfl
  mod256_partial_union := fun hn hres =>
    bad_run_net_descent_witness_mod256_channel_seven_partial_union hn hres
  formal_extended_union := fun hn hres =>
    bad_run_net_descent_witness_channel_seven_formal_extended_union hn hres
  j3_full_entry_witness := deepLiftFiber_j3_full_formal_entry_local_witness
  j3_partial_entry_witness := deepLiftFiber_j3_partial_formal_entry_local_witness

end KeplerHurwitz.Collatz.ChannelSevenDeepLiftFormalBridgeV216
