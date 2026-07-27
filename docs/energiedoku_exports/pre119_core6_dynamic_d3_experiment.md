# Experiment plan — Core6 Dynamic D3 (after D2b freeze)

**Branch:** `cursor/core6-dynamic-d3-4007`  
**Base:** `cursor/core6-dynamic-feed-in-4007` (PR #17, D2b frozen at `18e8747`)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3`

## Scope

Algebraic D3.0–D3.2 closed for fixed finite paths. Universal dynamical goals remain `[C]`.

| Phase | Content | Status |
|-------|---------|--------|
| D3.0 | one-block trichotomy + expanding-return APs | `[C→A]` |
| D3.1 | affine target-index transport (`+2187 r`) | `[C→A]` |
| D3.2 | fixed-path AP equivalence (general lists) | `[C→A]` |
| D3.3 | `BlockBoundaryFeedInGoal` | defined; open `[C]` |
| D3.4 | `OffCore6ReentryGoal` | defined; open `[C]` |
| D4 | `ReachabilityFeedInGoal` | still `[C]` |

## D3.2 delivered

### Engine
- `RealizesChannelPath`, `channelPathIndexModulus` / `Class` / `Map` / `Progression`
- Length-2 recovery of D2b progressions
- Hop step + residual congruence (`coeff3 = 2187` unit)

### Closure (iterated dyadic lifting, not classical CRT)
1. `channelPathIndexClass_lt` — `κ(p) < M(p)`
2. `channelPathResidual_iff` — `λ+2187·r ≡ κ_rest ↔ r ≡ ρ`
3. `realizesChannelPath_fiberIndex_iff` — general index characterization
4. `realizesChannelPath_eq_progression` — realizers = path AP

For every nonempty valid fixed path `e₀::rest`:
`{n | RealizesChannelPath (e₀::rest) n} = channelPathProgression (e₀::rest)`.

Constructed modulus is canonical and working; minimality is a separate claim.

## Quantifier boundary

| Level | Statement | Status |
|-------|-----------|--------|
| Fixed path | realizers = one AP | `[C→A]` |
| Block boundary | every expanding start has some finite block path | `[C]` |
| Reachability | some odd iterate hits contracting mass | `[C]` |

`BlockBoundaryFeedInGoal → ReachabilityFeedInGoal` is proved; the goals themselves are open.

## Non-goals

No universal reachability. No Collatz claim. D2b package untouched.
