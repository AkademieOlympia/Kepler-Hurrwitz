import Mathlib
import KeplerHurwitz.CollatzProofAttemptV27

namespace KeplerHurwitz

namespace CollatzAttemptV2

namespace CollatzNetDescent

open CollatzBridge
open ProofAttempt

/-!
## Net-descent diagnostics (Python mirror)

Aligns with `kepler_hurwitz.diagnostics`:
`net_descent_margin`, `bad_run_cost`, `shrink_efficiency`.

Governance: `[B]` definitional bridge only; witness existence stays `[C]`.
-/

/-- Atlas primary signature: Δ_net = n − collatzStep^[t_loc] m_good (as `Int`). -/
def netDescentMargin (n t_loc m_good : Nat) : Int :=
  (n : Int) - ((collatzStep^[t_loc]) m_good : Int)

/-- Bad-run cost C_bad = t_good (steps until mod 4 = 1). -/
def badRunCost (t_good : Nat) : Nat := t_good

/-- Shrink efficiency η = Δ_net / (C_bad + 1) as `Rat`. -/
def shrinkEfficiency (net_margin : Int) (t_good : Nat) : Rat :=
  (net_margin : Rat) / ((t_good + 1 : Nat) : Rat)

theorem netDescentMargin_eq (n t_loc m_good : Nat) :
    netDescentMargin n t_loc m_good =
      (n : Int) - ((collatzStep^[t_loc]) m_good : Int) := rfl

theorem badRunCost_eq (t_good : Nat) : badRunCost t_good = t_good := rfl

theorem netDescentMargin_pos_iff_local_shrink
    (n t_loc m_good : Nat) :
    0 < netDescentMargin n t_loc m_good ↔ (collatzStep^[t_loc]) m_good < n := by
  constructor
  · intro h
    have := Int.sub_pos.mp h
    exact_mod_cast this
  · intro h
    have := Int.ofNat_lt.mpr h
    exact Int.sub_pos.mpr this

/--
Packaging: positive net margin from V2.6 good-branch entry yields a full witness.
-/
def bad_run_net_descent_witness_of_margin
    {n : Nat}
    (e : BadRunGoodBranchEntryWitness n)
    (t_loc : Nat)
    (hmargin : 0 < netDescentMargin n t_loc e.m_good) :
    BadRunNetDescentWitness n :=
  BadRunNetDescentWitness.ofGoodBranchEntry e t_loc
    ((netDescentMargin_pos_iff_local_shrink n t_loc e.m_good).mp hmargin)

/--
`[C]` Uniform positive margin after V2.6 good-branch entry.
Equivalent to `BadRunNetDescentStatement` (same open core, margin formulation).
-/
def BadRunNetDescentViaMarginStatement : Prop :=
  ∀ {n : Nat}, 1 < n → n % 4 = 3 →
    ∃ t_loc m_good t_good,
      (collatzStep^[t_good]) n = m_good ∧
      m_good % 4 = 1 ∧
      0 < netDescentMargin n t_loc m_good

theorem bad_run_net_descent_via_margin_of_statement
    (h : BadRunNetDescentViaMarginStatement) :
    BadRunNetDescentStatement := by
  intro n hn hmod
  rcases h hn hmod with ⟨t_loc, m_good, t_good, hreach, hgood, hmargin⟩
  exact
    ⟨bad_run_net_descent_witness_of_margin
      (BadRunGoodBranchEntryWitness.ofMod4Three t_good m_good hreach hgood)
      t_loc hmargin⟩

theorem bad_run_net_descent_statement_of_via_margin
    (h : BadRunNetDescentStatement) :
    BadRunNetDescentViaMarginStatement := by
  intro n hn hmod
  rcases h hn hmod with ⟨w⟩
  refine ⟨w.local_shrink_time, w.m_good, w.t_good, w.reaches_good, w.good_mod4, ?_⟩
  exact (netDescentMargin_pos_iff_local_shrink n w.local_shrink_time w.m_good).mpr w.local_shrink

theorem bad_run_net_descent_via_margin_iff :
    BadRunNetDescentViaMarginStatement ↔ BadRunNetDescentStatement :=
  ⟨bad_run_net_descent_via_margin_of_statement, bad_run_net_descent_statement_of_via_margin⟩

/--
Witness existence implies strictly positive shrink efficiency when net margin is positive.
-/
theorem shrinkEfficiency_pos_of_witness
    {n : Nat}
    (w : BadRunNetDescentWitness n)
    (hpos : 0 < netDescentMargin n w.local_shrink_time w.m_good) :
    0 < shrinkEfficiency (netDescentMargin n w.local_shrink_time w.m_good) w.t_good := by
  unfold shrinkEfficiency
  exact div_pos (by exact_mod_cast hpos) (by positivity)

end CollatzNetDescent
end CollatzAttemptV2

end KeplerHurwitz
