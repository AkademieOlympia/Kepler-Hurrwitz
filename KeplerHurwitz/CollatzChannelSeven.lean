import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenAttackV210
import KeplerHurwitz.Collatz.ChannelSevenAttackV211
import KeplerHurwitz.Collatz.ChannelSevenAttackV212
import KeplerHurwitz.CollatzProofAttemptV28

namespace KeplerHurwitz

namespace CollatzAttemptV2

namespace CollatzNetDescent

/-!
## Channel `7` local witness classification (`n % 8 = 7`)

Governance pivot from frozen channel `3` (87.5 % = 28/32 at mod 256, c9e2d74).
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
open KeplerHurwitz.Collatz.ChannelSevenAttackV210
open KeplerHurwitz.Collatz.ChannelSevenAttackV211
open KeplerHurwitz.Collatz.ChannelSevenAttackV212

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

/-- Frozen channel-3 coverage reference (c9e2d74, mod 256); no further channel-3 work. -/
def channelThreeFrozenCoverage : String := "28/32"

/-- Channel-3 deep-tail frontier at mod 128 (historical V2.8 parent classes). -/
def channelThreeDeepTailMod128 : List ℕ := [27, 91, 123]

/-- Channel-3 deep-tail frontier at mod 256 (current freeze stand). -/
def channelThreeDeepTailMod256 : List ℕ := [27, 91, 155, 251]

/-- Formally closed channel-7 mod-32 anchor (`k % 4 = 2`, `n = 32j+23`). -/
def channelSevenFormalResidueMod32 : ℕ := 23

/-- All mod-128 channel-7 residues formally closed in Lean. -/
def channelSevenFormalResiduesMod128 : List ℕ := [7, 15, 23, 55, 87, 119]

/-- mod-256 channel-7 residues formally closed in Lean (2-adic lifts of open mod-128 children). -/
def channelSevenFormalResiduesMod256 : List ℕ := [39, 79, 95]

/-- mod-128 residues with partial mod-256 formal closure (not counted in mod-128 fraction). -/
def channelSevenMod128PartialFormalResidues : List ℕ := [39, 79, 95]

/-- mod-128 channel-7 deep-tail residues from numerical scan (`[B]`, not formal). -/
def channelSevenDeepTailResiduesMod128 : List ℕ := [31, 47, 63, 71, 103, 111]

/-- mod-128 channel-7 classes with numerical support only (`[B]`). -/
def channelSevenNumericalResiduesMod128 : List ℕ := [39, 95, 127]

/-- Total mod-128 channel-7 classes. -/
def channelSevenTotalClassesMod128 : ℕ := 16

/-- Formal coverage fraction at mod 128: 6/16 = 3/8. -/
def channelSevenFormalCoverageFraction : ℚ := 6 / 16

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
`[A]` Alias: formal mod-128 class `23` (and siblings `{55,87,119}`) inherit
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
`[A]` Formal mod-128 class `7` (`k % 4 = 0`, `j % 4 = 0`): `t_good = 4`, `t_loc = 7`.
-/
theorem channel_seven_formal_witness_mod128_seven
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 7) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod128_seven hn h7 hmod

/--
`[A]` Formal mod-128 class `15` (`k % 4 = 1`, `j % 4 = 0`): `t_good = 6`, `t_loc = 5`.
-/
theorem channel_seven_formal_witness_mod128_fifteen
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 15) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod128_fifteen hn h7 hmod

/--
`[A]` Formal mod-256 subclass `79` (`k % 4 = 1`, `j % 8 = 2`): `t_good = 6`, `t_loc = 7`.
Mod-128 class `79` is only partially closed — sibling `n ≡ 207 (mod 256)` remains open.
-/
theorem channel_seven_formal_witness_mod256_seventy_nine
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 79) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod256_seventy_nine hn h7 hmod

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
`[A]` Formal mod-256 subclass `95` (`k % 4 = 3`, `j % 8 = 2`): `t_good = 8`, `t_loc = 5`.
Mod-128 class `95` is only partially closed — sibling `n ≡ 223 (mod 256)` remains open.
-/
theorem channel_seven_formal_witness_mod256_ninety_five
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 95) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod256_ninety_five hn h7 hmod

/--
`[A]` Formal mod-256 subclass `39` (`k % 4 = 0`, `j % 8 = 1`): `t_good = 4`, `t_loc = 9`.
Mod-128 class `39` is only partially closed — sibling `n ≡ 167 (mod 256)` remains open.
-/
theorem channel_seven_formal_witness_mod256_thirty_nine
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 39) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod256_thirty_nine hn h7 hmod

/--
`[A]` Formal mod-128 class `55` (`k % 4 = 2`, `j % 4 = 1`): Drei-Schritt-Syracuse
Zertifikat `[1,1,3]` via `ChannelSevenAttackV210`.
-/
theorem channel_seven_formal_witness_mod128_fifty_five
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 55) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod128_fifty_five hn h7 hmod

/--
`[A]` Formal mod-128 class `87` (`k % 4 = 2`, `j % 4 = 2`): Drei-Schritt-Syracuse
Zertifikat `[1,1,4]` via `ChannelSevenAttackV211`.
-/
theorem channel_seven_formal_witness_mod128_eighty_seven
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 87) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod128_eighty_seven hn h7 hmod

/--
`[A]` Formal mod-128 class `119`: Drei-Schritt-Syracuse-Zertifikat `[1,1,3]`
via `ChannelSevenAttackV212`.
-/
theorem channel_seven_formal_witness_mod128_one_nineteen
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 119) :
    LocalWitnessStatementMod8 n :=
  bad_run_net_descent_witness_mod8_channel_seven_mod128_one_nineteen hn h7 hmod

/--
`[A]` Mechanical union of the six mod-128 channel-7 residues that carry an
individually-proved, sorry-free `[A]` witness derivation
(`{7, 15, 23, 55, 87, 119}` — exactly `channelSevenFormalResiduesMod128`).

This is pure case-composition of the six theorems above, not new mathematics:
no additional residue is covered and no claim is made about `k % 4 ≠ 2` classes,
the mod-256 partial classes `{39, 79, 95}`, or the deep-tail `{31, 47, 63, 71, 103, 111}`.
-/
theorem bad_run_net_descent_witness_mod128_channel_seven_formal_union
    {n : Nat}
    (hn : 1 < n)
    (hres :
      n % 128 = 7 ∨ n % 128 = 15 ∨ n % 128 = 23 ∨
        n % 128 = 55 ∨ n % 128 = 87 ∨ n % 128 = 119) :
    LocalWitnessStatementMod8 n := by
  have h7 : n % 8 = 7 := by omega
  rcases hres with h | h | h | h | h | h
  · have hmod : ∃ m, n = 128 * m + 7 := by
      have hdm := Nat.div_add_mod n 128
      rw [h] at hdm
      exact ⟨n / 128, hdm.symm⟩
    exact channel_seven_formal_witness_mod128_seven hn h7 hmod
  · have hmod : ∃ m, n = 128 * m + 15 := by
      have hdm := Nat.div_add_mod n 128
      rw [h] at hdm
      exact ⟨n / 128, hdm.symm⟩
    exact channel_seven_formal_witness_mod128_fifteen hn h7 hmod
  · have hmod32 : ∃ j, n = 32 * j + 23 := by
      have h32 : n % 32 = 23 := by omega
      have hdm := Nat.div_add_mod n 32
      rw [h32] at hdm
      exact ⟨n / 32, hdm.symm⟩
    exact channel_seven_formal_witness_mod128_residue hn h7 hmod32
  · have hmod : ∃ m, n = 128 * m + 55 := by
      have hdm := Nat.div_add_mod n 128
      rw [h] at hdm
      exact ⟨n / 128, hdm.symm⟩
    exact channel_seven_formal_witness_mod128_fifty_five hn h7 hmod
  · have hmod : ∃ m, n = 128 * m + 87 := by
      have hdm := Nat.div_add_mod n 128
      rw [h] at hdm
      exact ⟨n / 128, hdm.symm⟩
    exact channel_seven_formal_witness_mod128_eighty_seven hn h7 hmod
  · have hmod : ∃ m, n = 128 * m + 119 := by
      have hdm := Nat.div_add_mod n 128
      rw [h] at hdm
      exact ⟨n / 128, hdm.symm⟩
    exact channel_seven_formal_witness_mod128_one_nineteen hn h7 hmod

/--
`[A]` Same union, phrased as membership in `channelSevenFormalResiduesMod128`,
lifted to the plain `BadRunNetDescentWitness` (dropping the mod-8 channel tag).
Precise domain: `n % 4 = 3`, `n % 128 ∈ {7, 15, 23, 55, 87, 119}` — exactly the
6 of 16 mod-128 channel-7 classes that are formally closed, no more.
-/
theorem bad_run_net_descent_witness_of_mod4_three_channel_seven_formal_subclass
    {n : Nat}
    (hn : 1 < n)
    (_hmod4 : n % 4 = 3)
    (hres :
      n % 128 = 7 ∨ n % 128 = 15 ∨ n % 128 = 23 ∨
        n % 128 = 55 ∨ n % 128 = 87 ∨ n % 128 = 119) :
    Nonempty (BadRunNetDescentWitness n) :=
  (bad_run_net_descent_witness_mod128_channel_seven_formal_union hn hres).map
    (·.toBadRunNetDescentWitness)

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
  channel_three_frozen : channelThreeFrozenCoverage = "28/32"
  channel_three_deep_tail_mod128 :
    channelThreeDeepTailMod128 = [27, 91, 123]
  channel_three_deep_tail_mod256 :
    channelThreeDeepTailMod256 = [27, 91, 155, 251]
  formal_mod128_residues :
    channelSevenFormalResiduesMod128 = [7, 15, 23, 55, 87, 119]
  formal_mod256_residues :
    channelSevenFormalResiduesMod256 = [39, 79, 95]
  mod128_partial_formal_residues :
    channelSevenMod128PartialFormalResidues = [39, 79, 95]
  formal_coverage_fraction :
    channelSevenFormalCoverageFraction = 6 / 16
  k_mod4_two_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ j, n = 32 * j + 23) →
      LocalWitnessStatementMod8 n
  mod128_seven_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 7) →
      LocalWitnessStatementMod8 n
  mod128_fifteen_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 15) →
      LocalWitnessStatementMod8 n
  mod256_seventy_nine_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 256 * m + 79) →
      LocalWitnessStatementMod8 n
  mod256_ninety_five_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 256 * m + 95) →
      LocalWitnessStatementMod8 n
  mod256_thirty_nine_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 256 * m + 39) →
      LocalWitnessStatementMod8 n
  mod128_fifty_five_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 55) →
      LocalWitnessStatementMod8 n
  mod128_eighty_seven_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 87) →
      LocalWitnessStatementMod8 n
  mod128_one_nineteen_local_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 119) →
      LocalWitnessStatementMod8 n
  T_odd_bad_tail :
    ∀ {n : Nat}, n % 8 = 7 → T_odd n % 4 = 3
  five_step_barrier_k_mod4_two :
    ∀ {j : Nat}, (32 * j + 23) ≤ (collatzStep^[5]) (T_odd (32 * j + 23))

theorem channel_seven_classification_status :
    ChannelSevenClassificationStatus where
  channel_three_frozen := rfl
  channel_three_deep_tail_mod128 := rfl
  channel_three_deep_tail_mod256 := rfl
  formal_mod128_residues := rfl
  formal_mod256_residues := rfl
  mod128_partial_formal_residues := rfl
  formal_coverage_fraction := rfl
  k_mod4_two_local_witness := fun hn h7 hk2 =>
    channel_seven_formal_witness_mod128_residue hn h7 hk2
  mod128_seven_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod128_seven hn h7 hmod
  mod128_fifteen_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod128_fifteen hn h7 hmod
  mod256_seventy_nine_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod256_seventy_nine hn h7 hmod
  mod256_ninety_five_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod256_ninety_five hn h7 hmod
  mod256_thirty_nine_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod256_thirty_nine hn h7 hmod
  mod128_fifty_five_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod128_fifty_five hn h7 hmod
  mod128_eighty_seven_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod128_eighty_seven hn h7 hmod
  mod128_one_nineteen_local_witness := fun hn h7 hmod =>
    channel_seven_formal_witness_mod128_one_nineteen hn h7 hmod
  T_odd_bad_tail := fun h7 => channel_seven_T_odd_mod4_eq_three h7
  five_step_barrier_k_mod4_two := fun {j} =>
    channel_seven_five_step_fails_net_k_mod4_two (j := j)

end ChannelSeven

end CollatzNetDescent

end CollatzAttemptV2

end KeplerHurwitz
