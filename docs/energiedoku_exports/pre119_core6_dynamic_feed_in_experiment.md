# Experiment plan — Core6 Dynamic Feed-In `[C]`

**Branch:** `cursor/core6-dynamic-feed-in-4007`  
**Base:** `cursor/core6-cylinder-partition-4007` (PR #16 stack)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn`  
**Status at open:** **`[C]`** (open research — not `[C→A]`)

## Motivation

PR #16 closed the **static** Core6 dyadic occupancy (certificate
`core6StaticDyadicCertificate`). The remaining categorical question is
**dynamical**:

$$
\forall n \in C_1 \cup C_2 \cup C_3,\quad
\exists\, t \ge 1:\ U^{\circ t}(n) \in \bigcup_{e \ge 4} C_e.
$$

## Invariants inherited from PR #16 (may import)

- Phase split `expandingCore6 ⊔ contractingCore6`
- Disjoint cylinders / tail uniqueness
- Finite dyadic density → `1/8` (**relative**, not natural density)

## Forbidden reinterpretations

| Static fact | Illegal dynamical reading |
|-------------|---------------------------|
| `#contr / #Core6 → 1/8` | “expanding starts hit contracting with rate 1/8” |
| `R_m^contr ⊆ R_m^Core6` | “orbits eventually enter contracting fibers” |
| `fiberIndexEquiv` | collapse / Collatz termination |

## Experiment phases (proposed)

| Phase | Content | Exit criterion |
|-------|---------|----------------|
| **D0** | Scaffold + claim wall (this commit) | module builds; goals named |
| **D1** | Diagnostic census: sample expanding starts, track first contracting hit time | `[B]` tables / notebooks only |
| **D2** | Formal one-block image lemmas for `e∈{1,2,3}` (expansion already in 16e) | local Lean lemmas, still `[C]` for feed-in |
| **D3** | Candidate sufficient conditions for feed-in (e.g. after `k` Core6 blocks) | `[C→A]` only if kernel-discharged |
| **D4** | Full `ReachabilityFeedInGoal` | `[A]` only after CI∧review∧merge |

## Success / failure modes

- **Success:** a kernel proof of `ReachabilityFeedInGoal` (or a precise weakening) under the claim wall.
- **Partial success:** proved feed-in on a positive-measure / dyadic subclass of expanding residues — still not natural density unless bridged.
- **Failure / defer:** keep `[C]`; do not smuggle progress into PR #16 registers.

## Definition of Done for this experiment PR (scaffold)

1. Separate branch/PR from PR #16 freeze.  
2. Module builds.  
3. Goals named; no `sorry` discharge of reachability.  
4. Docs + JSON register declare `[C]` and exclusions.  
5. No change to PR #16 mathematical freeze SHAs.
