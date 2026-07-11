import Mathlib
import KeplerHurwitz.CollatzProofAttemptV26
import KeplerHurwitz.CollatzNetDescentMod8

namespace KeplerHurwitz

namespace CollatzAttemptV2

/- V2.7: syntactic net-descent composition is proved; uniform witness existence remains open. -/

namespace CollatzNetDescent

open CollatzBridge
open ProofAttempt

/--
Good-branch local shrink in `collatzStep` form:
three standard steps on `mod 4 = 1` equal `T_v2` and shrink strictly.
-/
theorem good_branch_collatz_local_shrink
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 1) :
    (collatzStep^[3]) n < n := by
  have ho : n % 2 = 1 := by omega
  have htv2 : (collatzStep^[3]) n = T_v2 n :=
    collatz_three_steps_eq_T_v2_mod4_one ho hmod
  rw [htv2]
  unfold T_v2
  simp only [hmod, ite_true]
  exact three_mul_add_one_quarter_lt_of_mod4_eq_one hn hmod

/--
Canonical good-branch shrink step count used by the net-descent interface.
-/
def goodBranchCollatzShrinkSteps : Nat := 3

theorem good_branch_collatz_local_shrink_at_canonical_steps
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 1) :
    (collatzStep^[goodBranchCollatzShrinkSteps]) n < n :=
  good_branch_collatz_local_shrink hn hmod

/--
Witness packaging for V2.6 good-branch entry plus the open net-shrink inequality.
The hard field is `local_shrink`: shrink below the original start value `n`,
not merely below the intermediate `m_good`.
-/
structure BadRunNetDescentWitness (n : Nat) where
  t_good : Nat
  m_good : Nat
  reaches_good : (collatzStep^[t_good]) n = m_good
  good_mod4 : m_good % 4 = 1
  local_shrink_time : Nat
  local_shrink : (collatzStep^[local_shrink_time]) m_good < n

/--
Good-branch entry data from V2.6, without the net-shrink inequality.
-/
structure BadRunGoodBranchEntryWitness (n : Nat) where
  t_good : Nat
  m_good : Nat
  reaches_good : (collatzStep^[t_good]) n = m_good
  good_mod4 : m_good % 4 = 1

def BadRunGoodBranchEntryWitness.ofMod4Three
    {n : Nat}
    (t_good : Nat)
    (m_good : Nat)
    (reaches_good : (collatzStep^[t_good]) n = m_good)
    (good_mod4 : m_good % 4 = 1) :
    BadRunGoodBranchEntryWitness n where
  t_good := t_good
  m_good := m_good
  reaches_good := reaches_good
  good_mod4 := good_mod4

def BadRunNetDescentWitness.ofGoodBranchEntry
    {n : Nat}
    (e : BadRunGoodBranchEntryWitness n)
    (local_shrink_time : Nat)
    (hnet : (collatzStep^[local_shrink_time]) e.m_good < n) :
    BadRunNetDescentWitness n where
  t_good := e.t_good
  m_good := e.m_good
  reaches_good := e.reaches_good
  good_mod4 := e.good_mod4
  local_shrink_time := local_shrink_time
  local_shrink := hnet

/--
`[A]` Composition: good-branch entry plus net shrink below `n` yields genuine descent.
-/
theorem mod4_three_descends_from_net_descent_witness
    {n : Nat}
    (_hmod : n % 4 = 3)
    (w : BadRunNetDescentWitness n) :
    ∃ t, (collatzStep^[t]) n < n := by
  refine ⟨w.local_shrink_time + w.t_good, ?_⟩
  calc
    (collatzStep^[w.local_shrink_time + w.t_good]) n
        = (collatzStep^[w.local_shrink_time]) ((collatzStep^[w.t_good]) n) := by
              rw [Function.iterate_add_apply collatzStep w.local_shrink_time w.t_good n]
    _ = (collatzStep^[w.local_shrink_time]) w.m_good := by rw [w.reaches_good]
    _ < n := w.local_shrink

/--
`[C]` Open net-descent packaging for a single start value:
bad-run chain cost plus good-branch shrink must beat the original `n`.
-/
def BadRunNetDescentCondition (n : Nat) : Prop :=
  Nonempty (BadRunNetDescentWitness n)

/--
`[C]` Uniform net-descent target for the open `mod 4 = 3` Collatz branch.
-/
def BadRunNetDescentStatement : Prop :=
  ∀ {n : Nat}, 1 < n → n % 4 = 3 → Nonempty (BadRunNetDescentWitness n)

/--
`[C]` Alias: uniform witness existence is the open net-descent core.
-/
abbrev BadRunNetDescentWitnessExists : Prop := BadRunNetDescentStatement

theorem mod4_three_eventually_descends_of_net_descent
    (h : BadRunNetDescentStatement) :
    Mod4ThreeEventuallyDescendsStatement := by
  intro n hn hmod
  rcases h hn hmod with ⟨w⟩
  exact mod4_three_descends_from_net_descent_witness hmod w

/--
`[A]` Net-descent witnesses imply the V2 open case (`CollatzAttemptV2OpenCase`).
-/
theorem bad_run_net_descent_implies_collatz_open_case
    (h : BadRunNetDescentStatement) :
    CollatzAttemptV2OpenCase :=
  mod4_three_eventually_descends_of_net_descent h

/--
`[A]` Net-descent witnesses close the open `mod 4 = 3` descent target.
-/
def CollatzOpenCaseFromNetDescentStatement : Prop :=
  BadRunNetDescentStatement → Mod4ThreeEventuallyDescendsStatement

theorem collatz_open_case_from_net_descent_proved :
    CollatzOpenCaseFromNetDescentStatement := by
  intro h
  exact mod4_three_eventually_descends_of_net_descent h

/--
`[A]` Reduction: the open global descent target is equivalent to net-descent
witness existence (forward direction proved; converse is the same open core).
-/
def Mod4ThreeNetDescentReductionStatement : Prop :=
  Mod4ThreeEventuallyDescendsStatement ↔ BadRunNetDescentStatement

theorem mod4_three_net_descent_reduction_forward
    (h : BadRunNetDescentStatement) :
    Mod4ThreeEventuallyDescendsStatement :=
  mod4_three_eventually_descends_of_net_descent h

namespace CollatzNetDescentMod8Witness

open CollatzNetDescent
open CollatzNetDescentMod8
open CollatzBridge
open ExitClasses

/-!
Mod-8 stratified packaging for `BadRunNetDescentWitness`.

Skeleton map (see `docs/collatz_v27_net_descent.md`):
- `[A]` channel split + `ν₂(3n+1)=1` micro-lemmas live in `CollatzNetDescentMod8.lean`
- `[C]` per-channel uniform witness existence (`sorry` below)
- `[A]` assembly: channel witnesses imply `bad_run_net_descent_witness_of_mod4_three`
-/

/--
Net-descent witness tagged by the mod-8 input channel (`3` or `7`).
-/
structure BadRunNetDescentWitnessMod8 (n : Nat) (ch : Mod4ThreeInputChannel) extends
    BadRunNetDescentWitness n where
  input_mod8 :
    match ch with
    | Mod4ThreeInputChannel.ch3 => n % 8 = 3
    | Mod4ThreeInputChannel.ch7 => n % 8 = 7

def BadRunNetDescentWitnessMod8.toWitness
    {n : Nat} {ch : Mod4ThreeInputChannel}
    (w : BadRunNetDescentWitnessMod8 n ch) :
    BadRunNetDescentWitness n :=
  w.toBadRunNetDescentWitness

/--
`[A]` Channel `3`: two `collatzStep`s reach the minimal good-branch odd `T_odd n`.
-/
theorem channel_three_minimal_good_branch_reach
    {n : Nat} (h8 : n % 8 = 3) :
    (collatzStep^[2]) n = T_odd n ∧ T_odd n % 4 = 1 := by
  have ho : n % 2 = 1 := by omega
  exact ⟨collatz_two_steps_eq_T_odd ho, channel_three_T_odd_mod4_eq_one h8⟩

/--
`[A]` Channel `3`: V2.6 good-branch entry witness at the minimal time `t_good = 2`.
-/
noncomputable def channel_three_good_branch_entry_witness
    {n : Nat} (h8 : n % 8 = 3) :
    BadRunGoodBranchEntryWitness n :=
  BadRunGoodBranchEntryWitness.ofMod4Three 2 (T_odd n)
    (collatz_two_steps_eq_T_odd (by omega : n % 2 = 1))
    (channel_three_T_odd_mod4_eq_one h8)

/--
`[A]` Channel `3`: three `collatzStep`s on `T_odd n` equal the canonical good-branch shrink.
-/
theorem collatz_three_steps_at_channel_three_T_odd
    {n : Nat} (h8 : n % 8 = 3) :
    (collatzStep^[3]) (T_odd n) = (3 * T_odd n + 1) / 4 := by
  have hgood := channel_three_T_odd_mod4_eq_one h8
  have ho : (T_odd n) % 2 = 1 := by omega
  rw [collatz_three_steps_eq_T_v2_mod4_one ho hgood]
  simp [T_v2, hgood]

/--
`[A]` Channel `3`: canonical three-step local shrink below `T_odd n` (not yet below `n`).
-/
theorem channel_three_collatz_local_shrink_at_T_odd
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3) :
    (collatzStep^[3]) (T_odd n) < T_odd n := by
  have hgood := channel_three_T_odd_mod4_eq_one h8
  have ho : (T_odd n) % 2 = 1 := by omega
  have hlt : 1 < T_odd n := one_lt_T_odd_of_mod8_eq_three hn h8
  rw [collatz_three_steps_eq_T_v2_mod4_one ho hgood]
  simp [T_v2, hgood]
  exact three_mul_add_one_quarter_lt_of_mod4_eq_one hlt hgood

/--
`[A]` Channel `3`: canonical three-step shrink does **not** yet beat the start value.
Quantitative gap `k+1` when `n = 8k+3` (see `three_step_shrink_gt_start_of_mod8_eq_three`).
-/
theorem channel_three_canonical_local_shrink_fails_net
    {n : Nat} (h8 : n % 8 = 3) :
    n ≤ (collatzStep^[3]) (T_odd n) := by
  have hgt := three_step_shrink_gt_start_of_mod8_eq_three h8
  rw [collatz_three_steps_at_channel_three_T_odd h8]
  exact le_of_lt hgt

/--
`[A]` Reduction: channel-`3` net-descent witness from any `local_shrink_time` beating `n`.
-/
noncomputable def bad_run_net_descent_witness_mod8_channel_three_of_local_shrink
    {n : Nat} (h8 : n % 8 = 3)
    (t_loc : Nat)
    (hnet : (collatzStep^[t_loc]) (T_odd n) < n) :
    BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3 where
  toBadRunNetDescentWitness :=
    BadRunNetDescentWitness.ofGoodBranchEntry
      (channel_three_good_branch_entry_witness h8) t_loc hnet
  input_mod8 := h8

theorem bad_run_net_descent_witness_mod8_channel_three_of_local_shrink_nonempty
    {n : Nat} (h8 : n % 8 = 3)
    (t_loc : Nat)
    (hnet : (collatzStep^[t_loc]) (T_odd n) < n) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) :=
  ⟨bad_run_net_descent_witness_mod8_channel_three_of_local_shrink h8 t_loc hnet⟩

/--
`[C]` Open core — input channel `n % 8 = 3` (good-branch entry at `T_odd n % 4 = 1`).
Partial progress: minimal entry and canonical shrink are `[A]`; uniform `t_loc` with
`(collatzStep^[t_loc]) (T_odd n) < n` remains open (canonical `t_loc = 3` fails by `k+1`).
Intended proof: 2-adic budget contradiction for bad runs without net descent.
-/
theorem bad_run_net_descent_witness_mod8_channel_three
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  sorry

/--
`[C]` Open core — input channel `n % 8 = 7` (bad-run tail at `T_odd n % 4 = 3`).
Intended proof: deeper bad-run chain; same 2-adic contradiction template.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 7) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  sorry

/--
`[A]` Assemble mod-8 channel witnesses into a plain net-descent witness.
-/
def bad_run_net_descent_witness_of_mod8_channel
    {n : Nat} {ch : Mod4ThreeInputChannel}
    (w : BadRunNetDescentWitnessMod8 n ch) :
    BadRunNetDescentWitness n :=
  w.toWitness

/--
`[C]` Uniform mod-8 stratified witness target (equivalent to `BadRunNetDescentStatement`).
-/
def BadRunNetDescentStatementMod8 : Prop :=
  ∀ {n : Nat}, 1 < n → n % 4 = 3 →
    (n % 8 = 3 →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3)) ∧
    (n % 8 = 7 →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7))

theorem bad_run_net_descent_statement_mod8_of_plain
    (h : BadRunNetDescentStatement) :
    BadRunNetDescentStatementMod8 := by
  intro n hn hmod
  constructor
  · intro h8
    rcases h hn hmod with ⟨w⟩
    exact ⟨⟨w, h8⟩⟩
  · intro h8
    rcases h hn hmod with ⟨w⟩
    exact ⟨⟨w, h8⟩⟩

theorem bad_run_net_descent_statement_of_mod8
    (h : BadRunNetDescentStatementMod8) :
    BadRunNetDescentStatement := by
  intro n hn hmod
  have ho : n % 2 = 1 := by omega
  rcases mod4_eq_three_implies_mod8_three_or_seven ho hmod with h3 | h7
  · rcases h hn hmod with ⟨hw3, _⟩
    rcases hw3 h3 with ⟨w⟩
    exact ⟨bad_run_net_descent_witness_of_mod8_channel w⟩
  · rcases h hn hmod with ⟨_, hw7⟩
    rcases hw7 h7 with ⟨w⟩
    exact ⟨bad_run_net_descent_witness_of_mod8_channel w⟩

end CollatzNetDescentMod8Witness

end CollatzNetDescent

namespace ProofAttempt

open CollatzNetDescent
open CollatzNetDescentMod8Witness
open CollatzNetDescentMod8
open CollatzBridge

/--
`[A]` From V2.6: every `mod 4 = 3` state eventually reaches the good branch.
This supplies `t_good` and `m_good`; the net-shrink field remains open.
-/
noncomputable def bad_run_good_branch_entry_of_mod4_three
    {n : Nat}
    (hmod : n % 4 = 3) :
    BadRunGoodBranchEntryWitness n := by
  classical
  let t_good := Classical.choose (mod4_three_eventually_mod4_one hmod)
  have ht_good := Classical.choose_spec (mod4_three_eventually_mod4_one hmod)
  exact BadRunGoodBranchEntryWitness.ofMod4Three t_good ((collatzStep^[t_good]) n) rfl ht_good

/--
`[C]` Open mathematical core: mod-8 stratified channel witnesses (see
`CollatzNetDescentMod8Witness`). Requires per-channel 2-adic / net-margin closure.
-/
theorem bad_run_net_descent_witness_of_mod4_three
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 3) :
    Nonempty (BadRunNetDescentWitness n) := by
  have ho : n % 2 = 1 := by omega
  rcases mod4_eq_three_implies_mod8_three_or_seven ho hmod with h3 | h7
  · rcases bad_run_net_descent_witness_mod8_channel_three hn h3 with ⟨w⟩
    exact ⟨bad_run_net_descent_witness_of_mod8_channel w⟩
  · rcases bad_run_net_descent_witness_mod8_channel_seven hn h7 with ⟨w⟩
    exact ⟨bad_run_net_descent_witness_of_mod8_channel w⟩

/--
`[C]` Uniform witness existence — same open core as `BadRunNetDescentStatement`.
-/
theorem bad_run_net_descent_witness_exists : BadRunNetDescentWitnessExists := by
  intro n hn hmod
  exact bad_run_net_descent_witness_of_mod4_three hn hmod

/--
`[C]` Still open: local odd-tail shrink (V2.5) plus good-branch entry (V2.6)
do not yet imply global `collatzStep` descent without the net-shrink inequality.
Precise reduction target: `BadRunNetDescentStatement`.
-/
def CollatzOpenCaseFromLocalShrinkStillOpen : Prop :=
  CollatzOpenCaseFromLocalShrinkStatement

/--
`[C]` Converse of the net-descent reduction (same open core, other direction).
-/
theorem mod4_three_net_descent_reduction_converse
    (h : Mod4ThreeEventuallyDescendsStatement) :
    BadRunNetDescentStatement := by
  sorry

theorem mod4_three_net_descent_reduction
    (hconv : Mod4ThreeEventuallyDescendsStatement → BadRunNetDescentStatement) :
    Mod4ThreeNetDescentReductionStatement := by
  constructor
  · exact hconv
  · exact mod4_three_eventually_descends_of_net_descent

/--
Extended proof-attempt status: V2.6 bridge plus net-descent composition layer.
Global termination remains open.
-/
structure CollatzProofAttemptStatusV27 : Prop where
  base_v26 : CollatzProofAttemptStatusV26
  collatz_open_case_from_net_descent : CollatzOpenCaseFromNetDescentStatement
  good_branch_collatz_local_shrink :
    ∀ {n : Nat}, 1 < n → n % 4 = 1 → (collatzStep^[3]) n < n

theorem collatz_proof_attempt_status_v27 : CollatzProofAttemptStatusV27 where
  base_v26 := collatz_proof_attempt_status_v26
  collatz_open_case_from_net_descent := collatz_open_case_from_net_descent_proved
  good_branch_collatz_local_shrink := fun hn hmod =>
    good_branch_collatz_local_shrink hn hmod

end ProofAttempt
end CollatzAttemptV2

end KeplerHurwitz
