import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

/-!
# Pre119Draft — Core6DynamicFeedIn (Follow-up `[C]`)

**Experiment status:** open research front — **`[C]`**, not `[C→A]`, not `[A]`.

This module is the **next experiment after PR #16 static closure**.
It must not reopen PR #16 mathematics.

## Claim wall (rigid)

| May use from PR #16 | Must not reinterpret as |
|---------------------|-------------------------|
| `core6StaticDyadicCertificate` | dynamical success probability |
| `expandingCore6` / `contractingCore6` | reachability already proved |
| pairwise cylinder disjointness | natural density on `ℕ` |
| dyadic density `1/8` | Collatz convergence / “collapse” |

## Open targets (not discharged)

**Universal reachability** (`ReachabilityFeedInGoal`):

$$
\forall n \in C_1 \cup C_2 \cup C_3,\quad
\exists\, t \ge 1:\
U^{\circ t}(n) \in \bigcup_{e \ge 4} C_e.
$$

**One-block feed-in** (`OneBlockFeedInGoal`): after a full expanding
`fiberE e₀` block (`e₀ ∈ {1,2,3}`), the image lies in the contracting mass.

## Epistemic layers

| Layer | Status |
|-------|--------|
| `ReachabilityFeedInGoal` / `OneBlockFeedInGoal` | `[C]` |
| finite reproducible D1 census | `[B]` (supports/refutes; does not promote) |

No Collatz claim. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn

open Set
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition

/-! ### Orbit primitives (scaffolding only) -/

/-- One odd Syracuse step `U(n) = nextOdd n`. -/
def syracuseOddStep (n : Nat) : Nat := nextOdd n

/-- `t`-fold iterate of the odd Syracuse step. -/
def syracuseOddIterate (t n : Nat) : Nat :=
  (Nat.iterate syracuseOddStep t) n

/-- Expanding mass: small-tail channels `e ∈ {1,2,3}`. -/
def expandingMass : Set Nat := expandingCore6

/-- Contracting mass: family `e ≥ 4`. -/
def contractingMass : Set Nat := contractingCore6

/-! ### Open goals — `[C]` placeholders (no proofs) -/

/--
`[C]` One-block feed-in: after the **full** expanding word `fiberE e₀`
(`e₀ ∈ {1,2,3}`), the image lies in the contracting family.

This is **not** “after the shared Core6 prefix alone”.
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
`[C]` True dynamical target: some finite odd-iterate lands in a contracting cylinder.
-/
def ReachabilityFeedInGoal : Prop :=
  ∀ n ∈ expandingMass,
    ∃ t : Nat, 1 ≤ t ∧ syracuseOddIterate t n ∈ contractingMass

/--
`[C]` Experiment package: both goals remain open.
Discharging either requires new dynamical arguments — not dyadic counting.
-/
structure Core6DynamicFeedInGoals : Prop where
  oneBlockOpen : OneBlockFeedInGoal ∨ ¬OneBlockFeedInGoal
  reachabilityOpen : ReachabilityFeedInGoal ∨ ¬ReachabilityFeedInGoal

/--
Trivial classical packaging of openness — **does not** prove feed-in.
Exists only so the module builds and names the research contract.
-/
theorem core6DynamicFeedInGoals_named : Core6DynamicFeedInGoals where
  oneBlockOpen := Classical.em _
  reachabilityOpen := Classical.em _

/-- Import hook: static certificate is available, unused for dynamics. -/
theorem staticCertificate_available : Core6StaticDyadicCertificate :=
  core6StaticDyadicCertificate

/-!
## Explicit non-theorems (do not add as lemmas)

- `ReachabilityFeedInGoal` is **not** a corollary of `core6StaticDyadicCertificate`.
- Dyadic density `1/8` is **not** a hitting probability for expanding channels.
- A finite D1 census (`[B]`) never upgrades these goals to `[C→A]` / `[A]`.
- No collapse / global Collatz statement is in scope.
-/

end KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn
