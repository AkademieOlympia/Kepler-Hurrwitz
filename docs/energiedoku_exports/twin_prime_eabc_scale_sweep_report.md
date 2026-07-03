# Twin-Prime EABC Scale Sweep (E-051 Robustness)

This scale sweep tests whether the negative E-051 structured-control result remains stable across larger numerical ranges and sieve bounds. It does not introduce new features and does not claim predictive power.

The scale sweep confirms that the negative E-051 structured-control result is robust across the tested limits and sieve bounds. Isolated positive deviations are not scale-stable under the preregistered decision rule.

**Status:** B scale robustness check

**Not claimed:** No proof of twin primes, no deterministic prediction, and no optimized predictor.

**Primary question:** Does the negative structured-control result remain stable across larger limits and sieve bounds?

**Inherits from:** E-051 structured controls for twin-prime EABC analysis

**Decision rule:** A feature is considered scale-stable only if its observed enrichment exceeds the residue-stratified null enrichment at all tested limits for the same sieve_bound, with the same direction of effect.

**Warning:** This sweep is descriptive and does not establish predictive power. Any candidate rule suggested by the sweep must be tested on a disjoint held-out range.

## Sweep grid

- tested_limits: [10000, 100000, 1000000]
- tested_sieve_bounds: [97, 997]

## Stage-1 interpretation (inherited)

The stage-1 enrichment is explained by CE residue preference and is not yet evidence for Floquet-specific predictive power.

## Sweep rows

| limit | B | candidates | sieved | baseline | CE | AB | CE/AB | orient Δnull | wing≥1 Δnull | wing=2 Δnull |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 10000 | 97 | 1666 | 204 | 1.000000 | 1.000000 | 1.000000 | 1.000000 | 0.0 | 0.0 | 0.0 |
| 10000 | 997 | 1666 | 204 | 1.000000 | 1.000000 | 1.000000 | 1.000000 | 0.0 | 0.0 | 0.0 |
| 100000 | 97 | 16666 | 1858 | 0.658235 | 0.665591 | 0.650862 | 1.022630 | 0.0 | 0.056296723899984746 | -0.09014539579967684 |
| 100000 | 997 | 16666 | 1223 | 1.000000 | 1.000000 | 1.000000 | 1.000000 | 0.0 | 0.0 | 0.0 |
| 1000000 | 97 | 166666 | 19303 | 0.423147 | 0.426973 | 0.419318 | 1.018256 | 0.0 | 0.013368638054981619 | 0.13084479639235846 |
| 1000000 | 997 | 166666 | 8168 | 1.000000 | 1.000000 | 1.000000 | 1.000000 | 0.0 | 0.0 | 0.0 |

## Stage-2 signal summary

- **orientation_dual:** not scale-stable; deltas=0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000
- **right_wing_prime_count_ge_1:** not scale-stable; deltas=0.0000, 0.0000, 0.0563, 0.0000, 0.0134, 0.0000
- **right_wing_prime_count_eq_2:** not scale-stable; deltas=0.0000, 0.0000, -0.0901, 0.0000, 0.1308, 0.0000

## Overall conclusion

The negative E-051 structured-control result remains stable across tested limits and sieve bounds: no feature consistently exceeds residue-stratified null enrichment.
