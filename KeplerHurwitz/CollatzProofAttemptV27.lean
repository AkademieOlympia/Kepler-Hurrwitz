import Mathlib
import KeplerHurwitz.CollatzProofAttemptV26

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

end CollatzNetDescent

namespace ProofAttempt

open CollatzNetDescent
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
`[C]` Open mathematical core: from V2.6 good-branch entry, extract a full
net-descent witness. Requires the isolated inequality
`(collatzStep^[local_shrink_time]) m_good < n`.
-/
theorem bad_run_net_descent_witness_of_mod4_three
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 3) :
    Nonempty (BadRunNetDescentWitness n) := by
  sorry

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
