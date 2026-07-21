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
None of them currently implies `OddCoreCollatzConjecture`.

## Logical chain that would be needed

```
Semiprime surgery (dynamical, for each odd n ≡ 3 mod 4)
    --[missing]--> BadRunNetDescentWitness n
    --[A, V2.7]--> ∃ t, collatzStep^[t] n < n   (= OpenCase)
    --[missing]--> OddCoreCollatzConjecture / ClassicalCollatzConjecture
```

Side paths that do **not** close the gap:

* NormalForm `IsReineEForm` ↛ witness / descent
  (`CollatzBridge.lipschitzUnit_as_normal_form_witness_marker` is `[C]` True).
* Bool-absorption / `BoolTrace` ↛ archimedean descent (Stein2 open).
* Surgery data package existence ↛ Stein1 (see `surgery_implies_stein1_iff` below:
  the Prop is definitionally vacuous on the antecedent).

## Honest `PureESemiprimeDescent`

If “pure E Semiprime descent” is to imply Collatz machinery, it must carry a
**dynamical** payload: a `BadRunNetDescentWitness`. Mere residual shape is
insufficient. With that packaging, a universal cover hypothesis is
*definitionally* `BadRunNetDescentStatement` — the open V2.7 core, not a
weaker algebraic fact.
-/

namespace KeplerHurwitz.Collatz.PureESemiprimeCoverClaimBoundary

open KeplerHurwitz
open KeplerHurwitz.CollatzAttemptV2
open KeplerHurwitz.CollatzAttemptV2.CollatzNetDescent
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

/--
Conditional target the user asked for.

**Honest reading:** `H` is equivalent to `BadRunNetDescentStatement`.
`Hterm` is still an **open** bridge (see
`block_descent_uniform_implies_termination` / well-founded descent to `1`).
There is **no** 0-`sorry` theorem
`BadRunNetDescentStatement → OddCoreCollatzConjecture` in this repo yet.
-/
theorem collatz_of_pure_E_semiprime_cover
    (H : PureESemiprimeCoverStatement)
    (Hterm : BadRunNetDescentStatement → OddCoreCollatzConjecture) :
    OddCoreCollatzConjecture :=
  Hterm (pure_E_semiprime_cover_iff_bad_run_net_descent.mp H)

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

/-! ## Status bundle (closed glue only; 0 sorry) -/

/--
Closed claim-boundary facts (**0 `sorry`** in this module).
Open OddCore glue lives in `Collatz/Octonion/Termination.lean`
(`block_descent_uniform_implies_termination`,
`octonionic_termination_implies_oddCoreCollatz` — both `sorry`).
Open Semiprime surgery: `SemiprimeDesingularization.lean` (3× `sorry`).
-/
structure PureESemiprimeCoverClaimBoundaryStatus : Prop where
  cover_iff_net_descent :
    PureESemiprimeCoverStatement ↔ BadRunNetDescentStatement
  open_case_from_cover :
    PureESemiprimeCoverStatement → CollatzAttemptV2OpenCase
  surgery_reduction_vacuous_antecedent :
    SemiprimeSurgeryImpliesStein1 ↔ Stein1_DeepTailFiberEntry
  mere_shape_arrow_iff_net_descent :
    MereReineEShapeImpliesWitness ↔ BadRunNetDescentStatement

theorem pure_E_semiprime_cover_claim_boundary_status :
    PureESemiprimeCoverClaimBoundaryStatus where
  cover_iff_net_descent := pure_E_semiprime_cover_iff_bad_run_net_descent
  open_case_from_cover := open_case_of_pure_E_semiprime_cover
  surgery_reduction_vacuous_antecedent := surgery_implies_stein1_iff_stein1
  mere_shape_arrow_iff_net_descent :=
    mere_reine_E_shape_implies_witness_iff_net_descent

end KeplerHurwitz.Collatz.PureESemiprimeCoverClaimBoundary
