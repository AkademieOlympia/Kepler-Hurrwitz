import Mathlib
import KeplerHurwitz.CollatzProofAttemptV28

namespace KeplerHurwitz

namespace CollatzAttemptV2

namespace CollatzNetDescent

/-!
## Channel `7` local witness classification (`n % 8 = 7`)

Governance pivot from frozen channel `3` (81.25 % = 13/16 at mod 128).
Channel `7` is the bad-run tail: `T_odd n % 4 = 3`, `eSchalenSprung = 1`.

Methodology:
1. mod 32 classes (`k % 4` within `n = 8k+7`)
2. lift to mod 64 / mod 128 only for still-open children
3. no mod 256 unless a 2-adic bit is documented

Depth labels are governance tags, not uniform bounds.
-/

namespace ChannelSeven

open CollatzNetDescentMod8
open CollatzNetDescentMod8Witness
open CollatzNetDescentV28
open CollatzBridge

/-- Channel-7 residue guard: input Klein class `7` with positive modulus tag. -/
def ChannelSevenResidue (r m : ℕ) : Prop :=
  r % 8 = 7 ∧ 0 < m

/--
Canonical local witness statement — reuses `BadRunNetDescentWitness` semantics
from V2.7 (good-branch entry `t_good`, `m_good`, plus net shrink below `n`).
No alternate witness meaning is introduced here.
-/
abbrev LocalWitnessStatement (n : ℕ) : Prop :=
  Nonempty (BadRunNetDescentWitness n)

/--
Mod-8 channel-7 packaging of the same witness interface.
Target theorem: `bad_run_net_descent_witness_mod8_channel_seven` (`[C]`).
-/
abbrev LocalWitnessStatementMod8 (n : ℕ) : Prop :=
  Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7)

/-- Governance depth tag — not a mathematical upper bound. -/
inductive WitnessDepthLabel
  | closed_short
  | closed_medium
  | closed_deep
  | numerical_only
  | open
  deriving DecidableEq, Repr

/-- Witness provenance tag. -/
inductive WitnessStatusLabel
  | formally_closed
  | numerically_supported
  | open
  | deep_tail
  deriving DecidableEq, Repr

/--
Classification record for adaptive 2-adic lifting tables.
`formallyClosed` marks Lean `[A]` witnesses; numerical rows stay `[B]`.
-/
structure WitnessRecord where
  residue : ℕ
  modulus : ℕ
  tLoc : ℕ
  targetChannel : ℕ
  formallyClosed : Bool
  depthLabel : WitnessDepthLabel
  statusLabel : WitnessStatusLabel
  deriving Repr

/-- Frozen channel-3 coverage reference (V2.8); no further channel-3 work. -/
def channelThreeFrozenCoverage : String := "13/16"

/-- Channel-3 deep-tail frontier at mod 128 (not pursued). -/
def channelThreeDeepTailMod128 : List ℕ := [27, 91, 123]

/-- Formally closed channel-7 mod-32 anchor (`k % 4 = 2`, `n = 32j+23`). -/
def channelSevenFormalResidueMod32 : ℕ := 23

/-- All mod-128 channel-7 residues formally closed in Lean (`k % 4 = 2` ladder). -/
def channelSevenFormalResiduesMod128 : List ℕ := [23, 55, 87, 119]

/-- mod-128 channel-7 deep-tail residues from numerical scan (`[B]`, not formal). -/
def channelSevenDeepTailResiduesMod128 : List ℕ := [31, 47, 63, 71, 103, 111]

/-- mod-128 channel-7 classes with numerical support only (`[B]`). -/
def channelSevenNumericalResiduesMod128 : List ℕ :=
  [7, 15, 39, 79, 95, 127]

/-- Total mod-128 channel-7 classes. -/
def channelSevenTotalClassesMod128 : ℕ := 16

/-- Formal coverage fraction at mod 128: 4/16 = 1/4. -/
def channelSevenFormalCoverageFraction : ℚ := 4 / 16

/--
`[A]` Reduction: channel-7 net-descent witness from good-branch entry plus
`local_shrink_time` beating `n` (same packaging as channel `3`, different entry).
-/
noncomputable def bad_run_net_descent_witness_mod8_channel_seven_of_local_shrink
    {n : Nat}
    (h7 : n % 8 = 7)
    (e : BadRunGoodBranchEntryWitness n)
    (t_loc : Nat)
    (hnet : (collatzStep^[t_loc]) e.m_good < n) :
    BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7 where
  toBadRunNetDescentWitness :=
    BadRunNetDescentWitness.ofGoodBranchEntry e t_loc hnet
  input_mod8 := h7

theorem bad_run_net_descent_witness_mod8_channel_seven_of_local_shrink_nonempty
    {n : Nat}
    (h7 : n % 8 = 7)
    (e : BadRunGoodBranchEntryWitness n)
    (t_loc : Nat)
    (hnet : (collatzStep^[t_loc]) e.m_good < n) :
    LocalWitnessStatementMod8 n :=
  ⟨bad_run_net_descent_witness_mod8_channel_seven_of_local_shrink h7 e t_loc hnet⟩

/--
`[A]` Channel `7` with `k % 4 = 2`: good-branch entry witness at `t_good = 4`.
Reuses closed arithmetic from `CollatzNetDescentMod8`.
-/
noncomputable def channel_seven_good_branch_entry_witness_k_mod4_two
    {n : Nat}
    (_h7 : n % 8 = 7)
    (hk2 : ∃ j, n = 32 * j + 23) :
    BadRunGoodBranchEntryWitness n :=
  let j := Classical.choose hk2
  let hnj := Classical.choose_spec hk2
  BadRunGoodBranchEntryWitness.ofMod4Three 4 (72 * j + 53)
    (by rw [hnj]; exact channel_seven_four_step_value_of_thirty_two_mul_add_twenty_three j)
    (channel_seven_four_step_good_mod4_one_of_thirty_two_mul_add_twenty_three j)

/--
`[A]` Channel `7` with `k % 4 = 2`: local witness at `t_loc = 4` from good branch.
-/
theorem channel_seven_local_witness_k_mod4_two
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hk2 : ∃ j, n = 32 * j + 23) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two hn h7 hk2

/--
`[A]` Alias: formal mod-128 class `23` (and ladder `{55,87,119}`) inherit
`bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two`.
-/
theorem channel_seven_formal_witness_mod128_residue
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hk2 : ∃ j, n = 32 * j + 23) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two hn h7 hk2

/--
`[A]` Channel `7` starts in the bad tail (`T_odd n % 4 = 3`), unlike channel `3`.
-/
theorem channel_seven_T_odd_mod4_eq_three
    {n : Nat} (h7 : n % 8 = 7) :
    T_odd n % 4 = 3 :=
  CollatzNetDescentV28.channel_seven_T_odd_mod4_eq_three h7

/--
`[A]` Channel `7` inherits `eSchalenSprung = 1` from the shared `ν₂(3n+1)=1` chain.
-/
theorem channel_seven_eSchalenSprung_eq_one
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) (h7 : n % 8 = 7) :
    eSchalenSprung n = 1 := by
  have := eSchalenSprung_eq_one_of_mod4_eq_three ho hmod
  simpa using this

/--
`[C]` Uniform channel-7 witness — same open core as
`bad_run_net_descent_witness_mod8_channel_seven_v28` (`sorry` off the formal ladder).
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_uniform
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_v28 hn h7

/--
`[C]` Open channel-7 classes (`k % 4 ≠ 2`): intended via depth-budget consumption
or explicit per-class `t_loc` bounds (numerical table in `docs/exports/`).
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_open_classes
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hk : ∃ k, n = 8 * k + 7 ∧ k % 4 ≠ 2) :
    LocalWitnessStatementMod8 n := by
  exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two hn h7 hk

/-- Status bundle for the channel-7 classification pivot. -/
structure ChannelSevenClassificationStatus : Prop where
  channel_three_frozen : channelThreeFrozenCoverage = "13/16"
  channel_three_deep_tail :
    channelThreeDeepTailMod128 = [27, 91, 123]
  formal_mod128_residues :
    channelSevenFormalResiduesMod128 = [23, 55, 87, 119]
  formal_coverage_fraction :
    channelSevenFormalCoverageFraction = 4 / 16
  k_mod4_two_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ j, n = 32 * j + 23) →
      LocalWitnessStatementMod8 n
  T_odd_bad_tail :
    ∀ {n : Nat}, n % 8 = 7 → T_odd n % 4 = 3
  five_step_barrier_k_mod4_two :
    ∀ {j : Nat}, (32 * j + 23) ≤ (collatzStep^[5]) (T_odd (32 * j + 23))

theorem channel_seven_classification_status :
    ChannelSevenClassificationStatus where
  channel_three_frozen := rfl
  channel_three_deep_tail := rfl
  formal_mod128_residues := rfl
  formal_coverage_fraction := rfl
  k_mod4_two_local_witness := fun hn h7 hk2 =>
    channel_seven_formal_witness_mod128_residue hn h7 hk2
  T_odd_bad_tail := fun h7 => channel_seven_T_odd_mod4_eq_three h7
  five_step_barrier_k_mod4_two := fun {j} =>
    channel_seven_five_step_fails_net_k_mod4_two (j := j)

end ChannelSeven

end CollatzNetDescent

end CollatzAttemptV2

end KeplerHurwitz
