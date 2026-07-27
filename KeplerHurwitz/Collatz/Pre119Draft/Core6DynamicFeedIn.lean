import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — Core6DynamicFeedIn (Follow-up `[C]` / partial `[C→A]`)

**Experiment status:**
- `ReachabilityFeedInGoal` — open **`[C]`**
- `OneBlockFeedInGoal` — **universally false**;
  Lean discharge `¬ OneBlockFeedInGoal` is `[C→A]`
- D1 full representative census — **`[B]`** only

This module must not reopen PR #16 static mathematics.

## Claim wall (rigid)

| May use from PR #16 | Must not reinterpret as |
|---------------------|-------------------------|
| `core6StaticDyadicCertificate` | dynamical success probability |
| `expandingCore6` / `contractingCore6` | reachability already proved |
| pairwise cylinder disjointness | natural density on `ℕ` |
| dyadic density `1/8` | Collatz convergence / “collapse” |

## Epistemic layers

| Object | Status |
|--------|--------|
| D1 representative census | `[B]` |
| `OneBlockFeedInGoal` (universal) | empirically falsified; Lean `¬` is `[C→A]` |
| `ReachabilityFeedInGoal` | `[C]` open |
| finite observed hits | `[B]` existence only |

`[B]` may support or falsify a `[C]` hypothesis; it never yields `[A]` by itself.

No Collatz claim. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn

open Set
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition

/-! ### Orbit primitives -/

/-- One odd Syracuse step `U(n) = nextOdd n`. -/
def syracuseOddStep (n : Nat) : Nat := nextOdd n

/-- `t`-fold iterate of the odd Syracuse step. -/
def syracuseOddIterate (t n : Nat) : Nat :=
  (Nat.iterate syracuseOddStep t) n

/-- Expanding mass: small-tail channels `e ∈ {1,2,3}`. -/
def expandingMass : Set Nat := expandingCore6

/-- Contracting mass: family `e ≥ 4`. -/
def contractingMass : Set Nat := contractingCore6

/-! ### One-block feed-in: universal claim (false) and characterization set -/

/--
Universal one-block feed-in (too strong). After the **full** expanding word
`fiberE e₀` (`e₀ ∈ {1,2,3}`), the image would always lie in the contracting family.

This is **not** “after the shared Core6 prefix alone”.
Falsified by the witness `31 ∈ C_1` with image `137 ∉ contractingMass`.
-/
def OneBlockFeedInGoal : Prop :=
  ∀ e₀ : Nat, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ canonicalCylinder e₀,
      realizedImage n (fiberE e₀) ∈ contractingMass

/-- Equivalent packaging via an explicit target tail `e ≥ 4`. -/
def OneBlockFeedInGoal_existsTail : Prop :=
  ∀ e₀ : Nat, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ canonicalCylinder e₀,
      ∃ e : Nat, 4 ≤ e ∧
        realizedImage n (fiberE e₀) ∈ canonicalCylinder e

/--
D2b characterization set: those starts in `C_{e₀}` that **do** one-block feed-in.
Replaces the false universal claim.
-/
def oneBlockFeedInSet (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∈ contractingMass}

/--
`[C]` True dynamical target: some finite odd-iterate lands in a contracting cylinder.
-/
def ReachabilityFeedInGoal : Prop :=
  ∀ n ∈ expandingMass,
    ∃ t : Nat, 1 ≤ t ∧ syracuseOddIterate t n ∈ contractingMass

/-! ### `[C→A]` Formal refutation of universal one-block feed-in

Witness: `e₀ = 1`, `n = 31` (= `canonicalBase 1`),
`realizedImage 31 (fiberE 1) = 137 ∉ contractingMass`.
-/

theorem realizes_fiberE_one_31 : RealizesWord (fiberE 1) 31 := by
  native_decide

theorem mem_canonicalCylinder_one_31 : 31 ∈ canonicalCylinder 1 :=
  mem_canonicalCylinder_of_realizes (by decide : 1 ≤ 1) realizes_fiberE_one_31

theorem realizedImage_fiberE_one_31 :
    realizedImage 31 (fiberE 1) = 137 := by
  native_decide

theorem not_realizes_core6_137 : ¬ RealizesWord core6 137 := by
  native_decide

theorem not_mem_contractingMass_137 : 137 ∉ contractingMass := by
  intro h
  have hU : 137 ∈ ⋃ e : Nat, ⋃ (_ : 4 ≤ e), canonicalCylinder e := by
    simpa [contractingMass, contractingCore6] using h
  obtain ⟨e, he'⟩ := mem_iUnion.1 hU
  obtain ⟨he4, hmem⟩ := mem_iUnion.1 he'
  have hR : RealizesWord (fiberE e) 137 :=
    realizes_of_mem_canonicalCylinder (by omega : 1 ≤ e) hmem
  exact not_realizes_core6_137 (realizes_core6_of_realizes_fiberE hR)

/--
`[C→A]` Universal one-block feed-in is false.
Finite witness; no reachability content.
-/
theorem not_oneBlockFeedInGoal : ¬ OneBlockFeedInGoal := by
  intro h
  have himg : realizedImage 31 (fiberE 1) ∈ contractingMass :=
    h 1 (by decide) (by decide) 31 mem_canonicalCylinder_one_31
  rw [realizedImage_fiberE_one_31] at himg
  exact not_mem_contractingMass_137 himg

/-- Alias matching the D2a naming in the experiment plan. -/
theorem oneBlockFeedInGoal_refuted : ¬ OneBlockFeedInGoal :=
  not_oneBlockFeedInGoal

/-! ### Experiment package -/

/--
Experiment package after D1/D2a:
- one-block universal claim is refuted;
- reachability remains classically open (not discharged).
-/
structure Core6DynamicFeedInGoals : Prop where
  oneBlockRefuted : ¬ OneBlockFeedInGoal
  reachabilityOpen : ReachabilityFeedInGoal ∨ ¬ReachabilityFeedInGoal

theorem core6DynamicFeedInGoals_named : Core6DynamicFeedInGoals where
  oneBlockRefuted := not_oneBlockFeedInGoal
  reachabilityOpen := Classical.em _

/-- Import hook: static certificate is available, unused for dynamics. -/
theorem staticCertificate_available : Core6StaticDyadicCertificate :=
  core6StaticDyadicCertificate

/-!
## Explicit non-theorems

- `ReachabilityFeedInGoal` is **not** a corollary of `core6StaticDyadicCertificate`.
- Dyadic density `1/8` is **not** a hitting probability for expanding channels.
- A finite D1 census (`[B]`) never upgrades reachability to `[A]`.
- `¬ OneBlockFeedInGoal` does **not** imply `¬ ReachabilityFeedInGoal`.
- No collapse / global Collatz statement is in scope.
-/

end KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn
