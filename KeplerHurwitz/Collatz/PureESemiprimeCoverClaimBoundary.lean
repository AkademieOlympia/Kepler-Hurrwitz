import Mathlib
import KeplerHurwitz.CollatzNormShell
import KeplerHurwitz.CollatzProofAttemptV27
import KeplerHurwitz.Collatz.SemiprimeDesingularization

/-!
# Pure-E Semiprime cover vs Collatz — claim boundary

**Collatz?** **NEIN.** This module does **not** prove Collatz.

## What “reine E-Darstellung” means in this project

Three **non-interchangeable** “E” vocabularies appear in the wider repo:

1. **EABC NormalForm reine E** (`ResidualShape.reineE` / `IsReineEForm`):
   residual factor `r = 1` in `n = 2^α · 3^β · r · e`
   (`KeplerHurwitz/EABC/NormalForm.lean` on main / EABC branches).
   **Not imported on this Collatz worktree** — no Lean wire to V2.7.

2. **Absorptive boolean alphabet** `{E00, E01, Z}`
   (`BooleanRelationAbsorption` / Stein2 wording): finite modular diagnosis.
   Explicitly **not** archimedean `ℕ` descent
   (`SemiprimeDesingularization.Stein2_AbsorptionArchimedeanDescent`).

3. **SemiprimeDesingularization surgery scaffold** (this branch):
   Channel-7 / `71 mod 256` interface with **3× `sorry`**; metaphors only.
   Does **not** produce NormalForm reine-E certificates.

Spoken claim “Semiprime descent → pure E → Collatz” conflates (1)–(3).
None of them currently implies `OddCoreCollatzConjecture` **unconditionally**.

## Logical chain

```
Semiprime surgery / EABC phase (constructive interface only)
    --[open hyp: BoolTraceZeroImpliesLocalShrink]--> BadRunNetDescentWitness
    --[A, V2.7]--> ∃ t, collatzStep^[t] n < n   (= OpenCase, for n ≡ 3 mod 4)
    --[A, WF glue below]--> OddCoreCollatzConjecture   (IF uniform net descent)
```

Gap 2 (local descent → reach-`1`) is **closed** conditionally:
`BadRunNetDescentStatement → OddCoreCollatzConjecture` via `Nat.strong_induction_on`
plus already-proved even / `mod 4 = 1` local shrinks.

Gap 1 (algebra / BoolTrace → witness) remains **open**; only a constructive
interface is provided. Circularity of “pure E cover ⇔ net descent” is unchanged.
-/

namespace KeplerHurwitz.Collatz.PureESemiprimeCoverClaimBoundary

open KeplerHurwitz
open KeplerHurwitz.CollatzAttemptV2
open KeplerHurwitz.CollatzAttemptV2.CollatzNetDescent
open KeplerHurwitz.CollatzAttemptV2.ProofAttempt
open KeplerHurwitz.Collatz.SemiprimeDesingularization

/-! ## Three E-vocabularies (markers, not bridges) -/

/--
**[C]** Marker for EABC NormalForm reine-E shape (residual `r = 1`).

Not formalized on this branch (no `EABC` import). Existence of this Prop as a
name does **not** supply a Collatz witness.
-/
def MereEABCReineEShape (_n : Nat) : Prop :=
  True

/--
`[C]` Marker for boolean absorptive alphabet facts (`E00`/`E01`/`Z`).

Finite modular diagnosis only — same gap as Stein2.
-/
def MereBooleanAbsorptionAlphabetFact (_n : Nat) : Prop :=
  True

/--
`[C]` Marker that Semiprime surgery scaffold data exists for bookkeeping.

Already true via `defaultDesingularizationData`; does not imply Stein1.
-/
def MereSemiprimeSurgeryDataExists : Prop :=
  ∃ _data : SemiprimeDesingularizationData, True

theorem mere_semiprime_surgery_data_exists : MereSemiprimeSurgeryDataExists :=
  ⟨defaultDesingularizationData, trivial⟩

/-! ## Honest dynamical packaging -/

/--
Honest payload: Semiprime / “pure E” surgery that actually helps Collatz must
deliver a V2.7 net-descent witness for `n`.
-/
structure PureESemiprimeDescent (n : Nat) where
  witness : BadRunNetDescentWitness n

/-- Universal cover hypothesis in the honest packaging. -/
def PureESemiprimeCoverStatement : Prop :=
  ∀ {n : Nat}, 1 < n → n % 4 = 3 → Nonempty (PureESemiprimeDescent n)

/--
`[A]` Circularity exposure: honest pure-E Semiprime cover **is** the open
V2.7 net-descent statement (definitional packaging).
-/
theorem pure_E_semiprime_cover_iff_bad_run_net_descent :
    PureESemiprimeCoverStatement ↔ BadRunNetDescentStatement := by
  constructor
  · intro H n hn hmod
    rcases H hn hmod with ⟨d⟩
    exact ⟨d.witness⟩
  · intro H n hn hmod
    rcases H hn hmod with ⟨w⟩
    exact ⟨⟨w⟩⟩

/--
`[A]` Conditional glue that is true today:
honest cover ⇒ open `mod 4 = 3` descent case (`CollatzAttemptV2OpenCase`).
-/
theorem open_case_of_pure_E_semiprime_cover
    (H : PureESemiprimeCoverStatement) :
    CollatzAttemptV2OpenCase :=
  bad_run_net_descent_implies_collatz_open_case
    (pure_E_semiprime_cover_iff_bad_run_net_descent.mp H)

/-! ## Gap 2 — WF glue: local descent → OddCore / classical Collatz

Standard well-founded induction on `(ℕ, <)`. **No Collatz content:** the hard
arithmetic remains the open uniform witness hypothesis
`BadRunNetDescentStatement`. Even / `mod 4 = 1` local shrinks are already `[A]`.
-/

/-- Strict one-step positivity of `collatzStep` on positive inputs. -/
theorem collatzStep_pos {n : Nat} (hn : 0 < n) : 0 < collatzStep n := by
  unfold collatzStep
  split_ifs with he
  · have h2le : 2 ≤ n := by omega
    exact Nat.div_pos h2le (by decide : 0 < 2)
  · omega

/-- Iterates of `collatzStep` stay positive. -/
theorem collatzStep_iterate_pos {n t : Nat} (hn : 0 < n) :
    0 < (collatzStep^[t]) n := by
  induction t with
  | zero =>
      simpa using hn
  | succ t ih =>
      rw [Function.iterate_succ_apply']
      exact collatzStep_pos ih

/--
`[A]` Local strict descent for **all** `n > 1`, assuming the open `mod 4 = 3`
net-descent cover. Glues:
* even: `collatz_even_step_lt`
* odd `≡ 1 (mod 4)`: `good_branch_collatz_local_shrink`
* odd `≡ 3 (mod 4)`: `BadRunNetDescentStatement`
-/
theorem exists_strict_collatz_descent_of_net_descent
    (h : BadRunNetDescentStatement) {n : Nat} (hn : 1 < n) :
    ∃ t, (collatzStep^[t]) n < n := by
  by_cases he : n % 2 = 0
  · exact ⟨1, by
      simpa using collatz_even_step_lt (by omega : 0 < n) he⟩
  · have hmod : n % 4 = 1 ∨ n % 4 = 3 := by omega
    rcases hmod with h1 | h3
    · exact ⟨goodBranchCollatzShrinkSteps,
        good_branch_collatz_local_shrink_at_canonical_steps hn h1⟩
    · rcases h hn h3 with ⟨w⟩
      exact mod4_three_descends_from_net_descent_witness h3 w

/--
`[A]` Uniform local-descent packaging of the previous lemma.
-/
def LocalStrictCollatzDescentStatement : Prop :=
  ∀ {n : Nat}, 1 < n → ∃ t, (collatzStep^[t]) n < n

theorem local_strict_descent_of_net_descent
    (h : BadRunNetDescentStatement) :
    LocalStrictCollatzDescentStatement :=
  fun {_n} hn => exists_strict_collatz_descent_of_net_descent h hn

/--
`[A]` Gap-2 core: local strict descent on all `n > 1` ⇒ classical Collatz,
via `Nat.strong_induction_on` (well-founded `<` on `ℕ`).
-/
theorem classicalCollatz_of_local_strict_descent
    (hdesc : LocalStrictCollatzDescentStatement) :
    ClassicalCollatzConjecture := by
  intro n hn
  have hreach : ∀ m : Nat, 0 < m → ∃ k, (collatzStep^[k]) m = 1 := by
    intro m
    induction m using Nat.strong_induction_on with
    | h m ih =>
      intro hm
      by_cases h1 : m = 1
      · exact ⟨0, by simp [h1]⟩
      · have hm_gt : 1 < m := by omega
        rcases hdesc hm_gt with ⟨t, ht⟩
        have hmt : 0 < (collatzStep^[t]) m := collatzStep_iterate_pos hm
        rcases ih ((collatzStep^[t]) m) ht hmt with ⟨k, hk⟩
        refine ⟨k + t, ?_⟩
        rw [Function.iterate_add_apply, hk]
  exact hreach n hn

/--
`[A]` Gap-2 target shape: uniform local descent ⇒ `OddCoreCollatzConjecture`.
-/
theorem oddCoreCollatz_of_local_strict_descent
    (hdesc : LocalStrictCollatzDescentStatement) :
    OddCoreCollatzConjecture :=
  classicalCollatz_iff_oddCoreCollatz.mp
    (classicalCollatz_of_local_strict_descent hdesc)

/--
`[A]` **Proved** WF bridge (replaces the former opaque `Hterm` hypothesis):

`BadRunNetDescentStatement → OddCoreCollatzConjecture`.

Does **not** prove the antecedent. Collatz remains open.
-/
theorem net_descent_cover_implies_oddCoreCollatz
    (h : BadRunNetDescentStatement) :
    OddCoreCollatzConjecture :=
  oddCoreCollatz_of_local_strict_descent (local_strict_descent_of_net_descent h)

/-- Alias matching the Acc / well-founded reading in the constructive Fahrplan. -/
theorem bad_run_net_descent_implies_oddCoreCollatz
    (h : BadRunNetDescentStatement) :
    OddCoreCollatzConjecture :=
  net_descent_cover_implies_oddCoreCollatz h

/--
Conditional target: honest pure-E cover ⇒ OddCore, using the **proved** WF glue.

Still **conditional** on the open cover / net-descent hypothesis.
**Collatz?** **NEIN.**
-/
theorem collatz_of_pure_E_semiprime_cover
    (H : PureESemiprimeCoverStatement) :
    OddCoreCollatzConjecture :=
  net_descent_cover_implies_oddCoreCollatz
    (pure_E_semiprime_cover_iff_bad_run_net_descent.mp H)

/--
`[C]` Named missing arrow: NormalForm reine-E shape ⇒ net-descent witness.

With the placeholder `MereEABCReineEShape := True` (no EABC import here), this
Prop is definitionally the open core `BadRunNetDescentStatement`. That is the
circularity: a shape-only “pure E” reading is not weaker than Collatz’s open
case unless the shape predicate carries dynamical content.
**Not asserted** as a theorem (would be `sorry` = open V2.7 core).
-/
def MereReineEShapeImpliesWitness : Prop :=
  ∀ {n : Nat}, 1 < n → n % 4 = 3 → MereEABCReineEShape n →
    Nonempty (BadRunNetDescentWitness n)

/--
`[A]` With the placeholder shape `True`, MereReineE→witness **is** net descent.
-/
theorem mere_reine_E_shape_implies_witness_iff_net_descent :
    MereReineEShapeImpliesWitness ↔ BadRunNetDescentStatement := by
  constructor
  · intro H n hn hmod
    exact H hn hmod trivial
  · intro H n hn hmod _
    exact H hn hmod

/-! ## Gap 1 — constructive eabc→witness **interface** (no fake cover)

EABC NormalForm is **not** imported on this worktree. We therefore take an
explicit phase-depth / `t_loc` certificate instead of pretending EABC supplies
one. The arithmetic arrow
`BoolTrace = 0 → local net shrink` remains a **named open hypothesis**.
-/

/--
Bookkeeping certificate: intended EABC / Semiprime phase depth for `n`.

Not computed from NormalForm here (no EABC import). Carries only `phase_depth`.
-/
structure PhaseLengthCertificate (n : Nat) where
  phase_depth : Nat

/-- Deterministic `t_loc` recipe from a phase depth (Fahrplan: `2 * depth + 1`). -/
def t_loc_of_phase_depth (phase_depth : Nat) : Nat :=
  2 * phase_depth + 1

/--
`[C]` **Open** arithmetic hypothesis (Gap 1): BoolTrace-zero / absorption at the
given phase depth implies archimedean net shrink after `t_loc_of_phase_depth`.

Not proved. Not the same as Stein2’s residue-restricted packaging, but the same
epistemic slot: finite boolean diagnosis ↛ `ℕ` descent without this arrow.
-/
def BoolTraceZeroImpliesLocalShrink : Prop :=
  ∀ {n : Nat} (_hn : 1 < n) (_hmod : n % 4 = 3)
    (e : BadRunGoodBranchEntryWitness n) (phase_depth : Nat),
    (collatzStep^[t_loc_of_phase_depth phase_depth]) e.m_good < n

/--
Constructive witness recipe: good-branch entry + explicit phase depth + proved
local shrink at the recipe `t_loc`. This is the dynamical payload a real EABC
bridge would have to emit.
-/
structure ConstructiveWitnessRecipe (n : Nat) where
  entry : BadRunGoodBranchEntryWitness n
  phase : PhaseLengthCertificate n
  local_shrink :
    (collatzStep^[t_loc_of_phase_depth phase.phase_depth]) entry.m_good < n

/-- `[A]` Recipe ⇒ V2.7 witness (definitional packing). -/
def ConstructiveWitnessRecipe.toWitness {n : Nat}
    (r : ConstructiveWitnessRecipe n) :
    BadRunNetDescentWitness n :=
  BadRunNetDescentWitness.ofGoodBranchEntry r.entry
    (t_loc_of_phase_depth r.phase.phase_depth) r.local_shrink

/--
`[A]` Conditional constructive generator matching the Fahrplan name `eabcToWitness`.

Requires the open `BoolTraceZeroImpliesLocalShrink` hypothesis — does **not**
claim that hypothesis.
-/
def eabcToWitness
    (Hbt : BoolTraceZeroImpliesLocalShrink)
    {n : Nat} (hn : 1 < n) (hmod : n % 4 = 3)
    (e : BadRunGoodBranchEntryWitness n)
    (c : PhaseLengthCertificate n) :
    BadRunNetDescentWitness n :=
  BadRunNetDescentWitness.ofGoodBranchEntry e
    (t_loc_of_phase_depth c.phase_depth) (Hbt hn hmod e c.phase_depth)

/--
`[A]` IF BoolTrace-local-shrink hyp AND a phase-depth cover,
THEN the open V2.7 net-descent statement.

Uses V2.6 noncomputable good-branch entry (`bad_run_good_branch_entry_of_mod4_three`).
Still does **not** prove either hypothesis.
-/
theorem bad_run_net_descent_of_eabc_constructive_cover
    (Hbt : BoolTraceZeroImpliesLocalShrink)
    (Hphase : ∀ {n : Nat}, 1 < n → n % 4 = 3 →
      Nonempty (PhaseLengthCertificate n)) :
    BadRunNetDescentStatement := by
  intro n hn hmod
  let e := bad_run_good_branch_entry_of_mod4_three hmod
  rcases Hphase hn hmod with ⟨c⟩
  exact ⟨eabcToWitness Hbt hn hmod e c⟩

/--
`[A]` Same conditional cover packaged through `ConstructiveWitnessRecipe`.
-/
theorem bad_run_net_descent_of_constructive_recipe_cover
    (Hcover : ∀ {n : Nat}, 1 < n → n % 4 = 3 →
      Nonempty (ConstructiveWitnessRecipe n)) :
    BadRunNetDescentStatement := by
  intro n hn hmod
  rcases Hcover hn hmod with ⟨r⟩
  exact ⟨r.toWitness⟩

/--
`[A]` Full conditional chain advertised by the Fahrplan:

BoolTrace hyp + phase cover ⇒ OddCore, via Gap-1 interface + Gap-2 WF glue.

Antecedents remain open. **Collatz?** **NEIN.**
-/
theorem oddCoreCollatz_of_eabc_constructive_cover
    (Hbt : BoolTraceZeroImpliesLocalShrink)
    (Hphase : ∀ {n : Nat}, 1 < n → n % 4 = 3 →
      Nonempty (PhaseLengthCertificate n)) :
    OddCoreCollatzConjecture :=
  net_descent_cover_implies_oddCoreCollatz
    (bad_run_net_descent_of_eabc_constructive_cover Hbt Hphase)

/-! ## Semiprime surgery packaging is vacuous on the antecedent -/

/--
`[A]` Ruthless exposure: `SemiprimeSurgeryImpliesStein1` is
`(∃ data, True) → Stein1`, and data exists, so the named reduction equals Stein1.
-/
theorem surgery_implies_stein1_iff_stein1 :
    SemiprimeSurgeryImpliesStein1 ↔ Stein1_DeepTailFiberEntry := by
  constructor
  · intro h
    exact h mere_semiprime_surgery_data_exists
  · intro h _
    exact h

/--
`[C]` Stein1 itself is a **special case** of net-descent existence on
`n ≡ 71 (mod 256)`, not a NormalForm reine-E fact.
-/
theorem stein1_is_special_case_of_net_descent_shape :
    Stein1_DeepTailFiberEntry =
      ∀ n : Nat, 1 < n → n % 256 = deepTailResidueMod256 →
        Nonempty (BadRunNetDescentWitness n) :=
  rfl

/-! ## Status bundle -/

/--
Claim-boundary status.

* Gap 2 WF glue: **closed** (`net_descent_cover_implies_oddCoreCollatz`, 0 `sorry`).
* Gap 1: constructive interface only; `BoolTraceZeroImpliesLocalShrink` open.
* Semiprime surgery: still 3× `sorry` in `SemiprimeDesingularization.lean`.
* Octonion O6 path (`block_descent_uniform_implies_termination`,
  `octonionic_termination_implies_oddCoreCollatz`) remains separate/`sorry`.
-/
structure PureESemiprimeCoverClaimBoundaryStatus : Prop where
  cover_iff_net_descent :
    PureESemiprimeCoverStatement ↔ BadRunNetDescentStatement
  open_case_from_cover :
    PureESemiprimeCoverStatement → CollatzAttemptV2OpenCase
  net_descent_implies_oddCore :
    BadRunNetDescentStatement → OddCoreCollatzConjecture
  cover_implies_oddCore :
    PureESemiprimeCoverStatement → OddCoreCollatzConjecture
  surgery_reduction_vacuous_antecedent :
    SemiprimeSurgeryImpliesStein1 ↔ Stein1_DeepTailFiberEntry
  mere_shape_arrow_iff_net_descent :
    MereReineEShapeImpliesWitness ↔ BadRunNetDescentStatement

theorem pure_E_semiprime_cover_claim_boundary_status :
    PureESemiprimeCoverClaimBoundaryStatus where
  cover_iff_net_descent := pure_E_semiprime_cover_iff_bad_run_net_descent
  open_case_from_cover := open_case_of_pure_E_semiprime_cover
  net_descent_implies_oddCore := net_descent_cover_implies_oddCoreCollatz
  cover_implies_oddCore := collatz_of_pure_E_semiprime_cover
  surgery_reduction_vacuous_antecedent := surgery_implies_stein1_iff_stein1
  mere_shape_arrow_iff_net_descent :=
    mere_reine_E_shape_implies_witness_iff_net_descent

end KeplerHurwitz.Collatz.PureESemiprimeCoverClaimBoundary
