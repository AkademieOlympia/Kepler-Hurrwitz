# Twin-Prime EABC Structured Controls (Stage 2)

**Status:** B/C structured feature test

**Not claimed:** No proof of twin primes and no deterministic prediction

**Primary question:** Do E-033 orientation-duality and Dumas-gap features add signal beyond residue-class and small-sieve baselines?

## Stage-1 interpretation

The stage-1 enrichment is explained by CE residue preference and is not yet evidence for Floquet-specific predictive power.

| stratum | hit rate |
|---|---:|
| CE | 0.6111111111111112 |
| AB | 0.603448275862069 |
| CE vs AB enrichment | 1.0126984126984129 |

## E-033 signed dual reference (baseline_cyclic)

- chi_phase 0: signed_dual_pair_match=True
- chi_phase 1: signed_dual_pair_match=True
- chi_phase 2: signed_dual_pair_match=True
- chi_phase 3: signed_dual_pair_match=True

## Orientation dual feature (within stratum)

### CE

- feature constant in stratum: True
- positive hit rate: 0.6111111111111112
- negative hit rate: None
- enrichment vs stratum baseline: 1.0
- enrichment positive vs negative: None

### AB

- feature constant in stratum: True
- positive hit rate: 0.603448275862069
- negative hit rate: None
- enrichment vs stratum baseline: 1.0
- enrichment positive vs negative: None

## Right-wing Dumas feature (leakage-safe: n+6, n+8 only)

### CE

- positive hit rate: 0.6
- negative hit rate: 0.6219512195121951
- enrichment vs stratum baseline: 0.9818181818181817
- enrichment positive vs negative: 0.9647058823529412

### AB

- positive hit rate: 0.6219512195121951
- negative hit rate: 0.5869565217391305
- enrichment vs stratum baseline: 1.0306620209059234
- enrichment positive vs negative: 1.059620596205962

## Null models

Controls: residue-stratified null model, phase-shift null model, randomized labels within residue class

- randomized labels (CE): orientation_dual=1.0, right_wing=0.9613636363636363
- randomized labels (AB): orientation_dual=1.0, right_wing=1.0710801393728224

## Stage-2 conclusion (descriptive)

The current structured-control test finds no evidence that the tested E-033 orientation-duality or Dumas right-wing features add predictive signal beyond residue-class and small-sieve baselines in this range.

With the baseline_cyclic E-033 reference, orientation_dual_score is constant within each residue stratum; it cannot add discriminative signal beyond residue class.
No feature in this run shows stable enrichment that survives residue-stratified label permutation; this is a null result for structured EABC signal beyond mod-12 class.
