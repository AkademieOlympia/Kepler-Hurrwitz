# Twin-Prime EABC/Floquet Governance Summary

**Register chain:** `E-049` → `E-051` → `E-052`  
**Status:** closed experimental line (negative control outcome)  
**Last updated:** 2026-07-03

## Core statement

The twin-prime EABC/Floquet experiments currently provide no evidence for predictive signal beyond residue-class and small-sieve controls. The negative result is documented as a governance success: a plausible hypothesis was tested against fair null models and not overstated.

**Technical summary:** No tested EABC/Floquet or Dumas feature consistently exceeds the residue-stratified null model.

## What is not claimed

- No proof of twin-prime infinitude or the twin-prime conjecture
- No deterministic prediction of individual twin pairs `(n, n+2)`
- No EABC/Floquet-specific predictive power beyond classical residue structure and small-prime sieving
- No upgrade of exploratory post-hoc phase enrichment to a confirmatory selector rule

## Experiment chain

### E-049 — Phase distribution analysis `[B]`

**Commit:** `fc546c6`  
**Register:** `E-049`  
**Report:** [`twin_prime_eabc_phase_analysis_report.md`](../energiedoku_exports/twin_prime_eabc_phase_analysis_report.md)

CE twin candidates (`n ≡ 11 mod 12`) were annotated by fixed EABC/Floquet phase via `candidate_index mod 8` and compared against a small-sieve baseline.

| Metric | Result |
|---|---|
| Range | `X = 10^6`, sieve bound `B = 97` |
| Sieved candidates | 9,654 |
| Twin hits | 4,122 |
| χ² uniformity (8 phases) | 2.63, `p = 0.917` — uniformity **not** rejected |
| Max phase spread | 0.024 hit-rate spread across phases |
| Exploratory best phase | Step 1 (channel A), enrichment ≈ 1.03 — **`[C]` post-hoc only** |

**Conclusion:** True twin hits are compatible with uniform distribution across the eight fixed Floquet phases. Any best-phase selection on the same dataset remains exploratory and would require held-out confirmation on a disjoint range.

---

### E-051 — Structured controls `[B]` (negative control result)

**Commit:** `36fba0c`  
**Register:** `E-051`  
**Report:** [`twin_prime_eabc_structured_controls_report.md`](../energiedoku_exports/twin_prime_eabc_structured_controls_report.md)

Residue-stratified CE/AB controls tested whether E-033 orientation-duality and leakage-safe Dumas right-wing features (`n+6`, `n+8`) add signal beyond mod-12 class and small-sieve baselines.

| Finding | Result |
|---|---|
| Stage-1 lift | Explained by CE vs AB residue preference (CE/AB enrichment ≈ 1.01 at `X = 10^4`) |
| E-033 `orientation_dual` | Non-discriminative under `baseline_cyclic` (constant within strata) |
| Dumas right-wing | No stable enrichment vs residue-stratified null models |
| Randomized / phase-shift nulls | No Floquet-specific signal beyond residue structure |

**Conclusion:** Apparent stage-1 enrichment is residue-driven, not Floquet-specific. Structured EABC/Dumas features do not add predictive signal beyond residue-class controls in the tested range.

---

### E-052 — Scale robustness check `[B]`

**Commit:** `9f4cac0`  
**Register:** `E-052` (depends on `E-051`)  
**Report:** [`twin_prime_eabc_scale_sweep_report.md`](../energiedoku_exports/twin_prime_eabc_scale_sweep_report.md)

E-051 diagnostics were repeated over a 6-cell grid:

- **Limits:** `10^4`, `10^5`, `10^6`
- **Sieve bounds:** `97`, `997`
- **No new features** — reuse of E-051 metrics only

| Feature | Scale-stability under preregistered rule |
|---|---|
| `orientation_dual` | Δ vs null = 0 at all cells (non-discriminative reference) |
| `right_wing ≥ 1` | Isolated positive deltas (max ≈ +0.056); **not** scale-stable |
| `right_wing = 2` | Mixed sign; **not** scale-stable |

**Conclusion:** The negative E-051 structured-control result remains stable across tested limits and sieve bounds. Isolated positive deviations are not scale-stable under the preregistered decision rule.

## Decision rule (E-052)

A feature is considered scale-stable only if its observed enrichment exceeds the residue-stratified null enrichment at **all** tested limits for the same sieve bound, with the same direction of effect.

This sweep is descriptive and does not establish predictive power. Any candidate rule suggested by the sweep must be tested on a disjoint held-out range.

## Reproducibility

```bash
python examples/run_twin_prime_eabc_phase_analysis.py
python examples/run_twin_prime_eabc_structured_controls.py
python examples/run_twin_prime_eabc_scale_sweep.py
python -m pytest tests/test_twin_prime_eabc_phase_analysis.py \
                 tests/test_twin_prime_eabc_structured_controls.py \
                 tests/test_twin_prime_eabc_scale_sweep.py -q
```

## Line status

This twin-prime EABC/Floquet experimental line is **closed** as a negative control finding. Further work (sheet splits, non-baseline E-033 scenarios, held-out tests) should be treated as a **new** preregistered line, not an extension of the current predictor narrative.
