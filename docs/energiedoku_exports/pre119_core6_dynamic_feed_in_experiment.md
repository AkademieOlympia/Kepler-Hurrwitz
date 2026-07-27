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

## Lean open goals (D0 corrected)

| Goal | Meaning | Status |
|------|---------|--------|
| `OneBlockFeedInGoal` | after full `fiberE e₀` (`e₀∈{1,2,3}`), image ∈ contracting mass | `[C]` |
| `ReachabilityFeedInGoal` | some odd-iterate `t≥1` lands in contracting mass | `[C]` |

`OneBlockFeedInGoal` is **not** “after Core6 prefix alone”.

## Claim wall

| Static fact (PR #16) | Illegal dynamical reading |
|----------------------|---------------------------|
| `#contr / #Core6 → 1/8` | hitting probability for expanding starts |
| `R_m^contr ⊆ R_m^Core6` | orbits eventually enter contracting fibers |
| `fiberIndexEquiv` | collapse / Collatz termination |

## D1 — full dyadic census `[B]` (not a sample)

For stage `m ≥ 3`, enumerate **all** expanding residues at `Q_m = 2^{m+9}`:

$$
n=\Phi_{e_0}(k)=b_{e_0}+k\cdot 2^{e_0+9},\qquad
e_0\in\{1,2,3\},\qquad
0\le k<2^{m-e_0}.
$$

Expected start count: \(2^{m-1}+2^{m-2}+2^{m-3}\).

For each start, compute

$$
\tau_T(n)=\min\{t\in\{1,\ldots,T\}:U^{\circ t}(n)\in\mathrm{contractingMass}\}
$$

or mark **censored at horizon `T`** if empty. Censoring ≠ counterexample.

### Required fields

| Field | Meaning |
|-------|---------|
| `stage_m` | dyadic stage |
| `source_e` | `e₀ ∈ {1,2,3}` |
| `source_k` | index in `Φ_{e₀}` |
| `start_n` | concrete start |
| `hit` | contracting mass reached by `T`? |
| `first_hit_t` | minimal hit time |
| `target_e` | hit tail `e≥4` |
| `censored_at` | `T` if no hit |
| `valuation_trace` | observed `ν₂(3n+1)` along the search |
| `one_block_hit` | image after full `fiberE e₀` already contracting? |
| `one_block_target_e` | tail after one block (if hit) |

### Script

```bash
PYTHONPATH=. python scripts/core6_dynamic_feed_in_d1_census.py --m 8 --T 64 \
  --jsonl /tmp/d1.jsonl --summary /tmp/d1_summary.json
```

Built-in sanity checks: source-fiber membership, unique starts, verified hits,
minimal hit time, reproducible `param_hash`.

### Epistemic status of D1

$$
\boxed{
\begin{array}{rcl}
\text{Reachability / OneBlock goals} &:& [C],\\
\text{finite reproducible census} &:& [B].
\end{array}}
$$

Even 100% hits for all tested `m ≤ m_max` only proves the property on the
finite set `S_{m_max}`, not the universal Lean statements.

## Experiment ladder

| Phase | Content | Exit |
|-------|---------|------|
| **D0** | definitions, claim wall, open goals | module builds |
| **D1** | full dyadic census `[B]` | reproducible tables + sanity OK |
| **D2** | exact image formulas for `C_1,C_2,C_3` | Lean lemmas (feed-in still `[C]`) |
| **D3** | sufficient feed-in conditions | possible `[C→A]` fragments |
| **D4** | universal reachability | `[A]` only after CI∧review∧merge |

## Definition of Done (scaffold / D1-spec)

1. Separate branch/PR from PR #16 freeze.  
2. `OneBlockFeedInGoal` matches the measured one-block event.  
3. D1 script enumerates full stages (not random samples).  
4. Docs + JSON declare `[C]` goals vs `[B]` census.  
5. No change to PR #16 mathematical freeze SHAs.
