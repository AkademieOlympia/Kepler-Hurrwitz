import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
import KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftFormalBridgeV216
import KeplerHurwitz.CollatzChannelSeven

/-!
# Kanal-7 V2.17 — Deep-Lift bridge for mod-1024 child `583`

Extends V2.16: when `deepLiftFiber 3 t ≡ 583 (mod 1024)`, the terminal inherits
the new formal witness. This is **not** a closure of full `71 mod 256`.

## j = 3 → residue `71 mod 256` (no formal bridge)

Affine check: `243t + 103 ≡ 71 (mod 256)` has the unique solution
`t ≡ 160 (mod 256)`. So the fiber **does** land on the deep-tail child
`n ≡ 71 (mod 256)`.

However there is **no** `[A]` `LocalWitnessStatementMod8` for the full class
`71 mod 256` (after ten steps from `m_good = 576m+161` the state `729m+206`
branches on the parity of `m`; same non-uniform-`t_loc` obstruction as
`{167,207,223}`). Therefore we do **not** add a V2.16-style inheritance lemma
`deepLiftFiber_j3_*_71_local_witness` — that would be a Schein-Brücke.

What is formal instead: the maximal short-affine child `n ≡ 583 (mod 1024)`
with parameter `t ≡ 672 (mod 1024)`.

## Governance
- `[A]` parameter condition `t % 1024 = 672` (unique solution of
  `243t + 103 ≡ 583 (mod 1024)`).
- Explicit non-claim: `t ≡ 160 (mod 256)` → `deepLiftFiber 3 t ≡ 71 (mod 256)`,
  but no witness inheritance for that landing.
- No global Collatz claim.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenDeepLiftFormalBridgeV217

open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
open KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
open KeplerHurwitz.Collatz.ChannelSevenDeepLiftFormalBridgeV216
open KeplerHurwitz.CollatzAttemptV2.CollatzNetDescent.ChannelSeven

theorem deepLiftFiber_mod1024 (j t : Nat) :
    deepLiftFiber j t % 1024 =
      (243 * (t % 1024) + deepLiftConstant j) % 1024 := by
  unfold deepLiftFiber deepBranchMultiplier
  exact ((Nat.mod_modEq t 1024).symm.mul_left 243).add_right (deepLiftConstant j)

theorem deepLiftFiber_j3_mod1024 (t : Nat) :
    deepLiftFiber 3 t % 1024 = (243 * (t % 1024) + 103) % 1024 := by
  simpa [deepLiftConstant_three] using deepLiftFiber_mod1024 3 t

/--
`[A]` Affine landing only: `t ≡ 160 (mod 256)` ⇒ `deepLiftFiber 3 t ≡ 71 (mod 256)`.
No witness inheritance — full class `71 mod 256` remains open.
-/
theorem deepLiftFiber_j3_lands_mod256_seventy_one (t : Nat)
    (ht : t % 256 = 160) :
    deepLiftFiber 3 t % 256 = 71 := by
  rw [deepLiftFiber_j3_mod256, ht]

/--
Parameter for the V2.17 mod-1024 formal child of deep-tail `71`.
-/
def deepLiftJ3FormalEntryParamsMod1024 : List Nat :=
  [672]

theorem deepLiftFiber_j3_mod1024_five_eighty_three_entry_residue (t : Nat)
    (ht : t % 1024 = 672) :
    deepLiftFiber 3 t % 1024 = 583 := by
  rw [deepLiftFiber_j3_mod1024, ht]

/--
`[A]` Deep-Lift `j = 3` on `t ≡ 672 (mod 1024)` lands in formal class `583`
and inherits the V2.17 witness.
-/
theorem deepLiftFiber_j3_mod1024_five_eighty_three_local_witness (t : Nat)
    (ht : t % 1024 = 672) :
    LocalWitnessStatementMod8 (deepLiftFiber 3 t) := by
  have hn : 1 < deepLiftFiber 3 t := deepLiftFiber_j3_gt_one t
  have hhit := deepLiftFiber_j3_mod1024_five_eighty_three_entry_residue t ht
  exact bad_run_net_descent_witness_channel_seven_formal_extended_union_v217 hn
    (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr hhit)))))))))

/--
`[A]` Vereinigte Deep-Lift-Brücke V2.17: V2.16-Eintritte oder mod-1024-Kind `583`.
-/
theorem deepLiftFiber_j3_formal_extended_entry_local_witness_v217 (t : Nat)
    (ht :
      t % 128 = 16 ∨ t % 128 = 48 ∨ t % 128 = 56 ∨
        t % 128 = 80 ∨ t % 128 = 96 ∨ t % 128 = 112 ∨
          t % 256 = 40 ∨ t % 256 = 64 ∨ t % 256 = 120 ∨
            t % 1024 = 672) :
    LocalWitnessStatementMod8 (deepLiftFiber 3 t) := by
  rcases ht with h | h | h | h | h | h | h | h | h | h
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
  · exact deepLiftFiber_j3_mod1024_five_eighty_three_local_witness t h

/-- Status-Bündel V2.17. -/
structure ChannelSevenDeepLiftFormalBridgeV217Status : Prop where
  extended_coverage_still_mod256 :
    channelSevenFormalExtendedCoverageFraction = 15 / 32
  formal_mod1024_residues :
    channelSevenFormalResiduesMod1024 = [583]
  formal_extended_union_v217 :
    ∀ {n : Nat}, 1 < n →
      (n % 128 = 7 ∨ n % 128 = 15 ∨ n % 128 = 23 ∨
        n % 128 = 55 ∨ n % 128 = 87 ∨ n % 128 = 119 ∨
          n % 256 = 39 ∨ n % 256 = 79 ∨ n % 256 = 95 ∨
            n % 1024 = 583) →
        LocalWitnessStatementMod8 n
  j3_mod1024_entry_witness :
    ∀ t : Nat, t % 1024 = 672 →
      LocalWitnessStatementMod8 (deepLiftFiber 3 t)
  base_v216 : ChannelSevenDeepLiftFormalBridgeV216Status

theorem channel_seven_deep_lift_formal_bridge_v217_status :
    ChannelSevenDeepLiftFormalBridgeV217Status where
  extended_coverage_still_mod256 := rfl
  formal_mod1024_residues := rfl
  formal_extended_union_v217 := fun hn hres =>
    bad_run_net_descent_witness_channel_seven_formal_extended_union_v217 hn hres
  j3_mod1024_entry_witness := deepLiftFiber_j3_mod1024_five_eighty_three_local_witness
  base_v216 := channel_seven_deep_lift_formal_bridge_v216_status

end KeplerHurwitz.Collatz.ChannelSevenDeepLiftFormalBridgeV217
