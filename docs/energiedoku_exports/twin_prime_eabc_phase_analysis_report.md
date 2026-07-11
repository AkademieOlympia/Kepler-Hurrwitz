# EABC/Floquet Phase Distribution for Twin-Prime Candidates
Status: B descriptive phase-distribution analysis.
This report describes the phase distribution of true twin-prime hits across the fixed EABC/Floquet phases among classically sieved CE candidates. It does not claim deterministic phase selection, infinitude of twin primes, or a proof of the twin-prime conjecture.
Any best-performing phase selected after inspecting this dataset is classified as exploratory enrichment [C]. Held-out confirmation would require testing a fixed rule on a disjoint numerical range.

## Evidence classification

| Section | Status |
|---|---|
| Overall distribution 8 phases | [B] |
| Best phase same dataset | [C] exploratory |
| Fixed rule disjoint range | future confirmatory |

## Experiment configuration

- limit: 1000000
- sieve_bound: 97
- channel sequence: E,A,C,B,E,A,C,B (via floquet_step_channel)
- uniformity alpha: 0.05

## Cohort summary

| cohort | candidates | twin hits | hit rate | enrichment vs baseline |
|---|---:|---:|---:|---:|
| all CE candidates | 83333 | 4122 | 0.049464 | 1.000000 |
| small sieve (passed) | 9654 | 4122 | 0.426973 | 8.631966024445827 |

## Overall distribution across 8 phases [B]

Descriptive distribution of true twin-prime hits across fixed floquet_step 0..7 among classically sieved CE candidates, with a chi-square goodness-of-fit test for uniformity across the eight phases.

- chi²: 2.634643
- degrees of freedom: 7
- p-value: 0.916523
- total twin hits (sieved): 4122
- expected hits per phase (uniform null): 515.250
- rejects uniformity (α=0.05): False

### Uniformity diagnostic (descriptive)

- max hit rate across phases: 0.441708
- min hit rate across phases: 0.417711
- spread (max − min): 0.023997
- max enrichment vs overall: 1.034509

Selection rule: No phase selection rule is used in this report; all phases are reported descriptively.

| floquet_step | channel | candidates | twin hits | hit rate | share of hits |
|---:|---|---:|---:|---:|---:|
| 0 | E | 1204 | 516 | 0.428571 | 0.1252 |
| 1 | A | 1218 | 538 | 0.441708 | 0.1305 |
| 2 | C | 1211 | 515 | 0.425268 | 0.1249 |
| 3 | B | 1186 | 498 | 0.419899 | 0.1208 |
| 4 | E | 1197 | 500 | 0.417711 | 0.1213 |
| 5 | A | 1206 | 511 | 0.423715 | 0.1240 |
| 6 | C | 1220 | 532 | 0.436066 | 0.1291 |
| 7 | B | 1212 | 512 | 0.422442 | 0.1242 |

## Exploratory enrichment on same dataset [C]

Post-hoc identification of the floquet phase with highest exploratory enrichment relative to the sieved baseline hit rate. **Exploratory enrichment only** — not a preregistered or held-out confirmation rule.

**Caveat:** Post-hoc scan across 8 fixed floquet phases; not preregistered; Bonferroni or other multiple-testing correction not applied.

| floquet_step | channel | candidates | twin hits | hit rate | enrichment vs sieve |
|---:|---|---:|---:|---:|---:|
| 1 | A | 1218 | 538 | 0.441708 | 1.034509 |

## Held-out confirmation on disjoint range (future)

Held-out confirmation would require preregistering a fixed floquet phase (or rule) and testing it on a numerical range disjoint from this dataset. No such confirmatory test has been run here.

## Quadruplet neighborhood (sieved candidates)

- failed_candidate: 5532
- twin_only: 2769
- near_quadruplet: 1271
- prime_quadruplet: 82
