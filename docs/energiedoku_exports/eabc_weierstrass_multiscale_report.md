# EABC Weierstrass Multiscale Report

**Governance:** [C] — numerical hypothesis scaffold only.

**Not claimed:** No proof of log-periodic Weierstrass structure, no DSI theorem, no claim that ABCE/CEAB orientation bias is established beyond descriptive statistics.

## Definition

For canonical primvierlinge with base prime $p \le N$ (H13 orientation rule):

$$B(N) = \mathrm{ABCE}(N) - \mathrm{CEAB}(N).$$

Cumulative series tracks running counts along increasing base primes; spectral probes use $x=\log p$ and detrended $B$.

- **max_n:** 10,000,000
- **scales tested:** [10000, 100000, 1000000, 10000000]
- **primvierlinge counted:** 899

## Scale table

| N | count | ABCE | CEAB | B(N) | ABCE/CEAB | log10 N |
|---:|---:|---:|---:|---:|---:|---:|
| 10,000 | 12 | 6 | 6 | 0 | 1.0000 | 4.0000 |
| 100,000 | 38 | 22 | 16 | 6 | 1.3750 | 5.0000 |
| 1,000,000 | 166 | 84 | 82 | 2 | 1.0244 | 6.0000 |
| 10,000,000 | 899 | 450 | 449 | 1 | 1.0022 | 7.0000 |

## Spectral diagnostics (detrended B along log p)

### FFT peaks (uniform log-grid interpolation)

| freq | power | period in log |
|---:|---:|---:|
| 0.068860 | 2303536.521876 | 14.5221 |
| 0.688604 | 492810.691729 | 1.4522 |
| 0.757465 | 457358.540394 | 1.3202 |
| 0.206581 | 444832.673043 | 4.8407 |
| 1.032906 | 383314.471200 | 0.9681 |

### Lomb–Scargle peaks (uneven log p)

| freq | normalized power | period in log |
|---:|---:|---:|
| 0.275748 | 0.000766 | 3.6265 |
| 0.275243 | 0.000762 | 3.6332 |
| 0.274737 | 0.000759 | 3.6398 |
| 0.274231 | 0.000755 | 3.6466 |
| 0.273725 | 0.000752 | 3.6533 |

### Autocorrelation (first lags)

lags 0–5: 1.000, 0.992, 0.986, 0.979, 0.972, 0.966

### Wavelet (Morlet CWT on uniform log grid)

Dominant log-scale width: 14.505975

### Box-counting dimension of (log p, B) graph

Estimated $\widehat{\dim}_B$: 0.7088

## Preliminary verdict

- **Scale drift:** B(N) moves from 0 at the smallest tested N to 1 at max_n=10,000,000 — bias relaxes toward ABCE/CEAB balance rather than growing as a persistent oscillatory envelope.
- **Autocorrelation:** lag-1 ρ ≈ 0.992 — strongly correlated slow drift, not white noise, but also not evidence of sharp log-periodic oscillation by itself.
- **Lomb–Scargle:** top normalized power ≈ 0.000766 — no dominant log-periodic peak under the current preregistered threshold (informal: ≪ 1).
- **Fractal band:** $\widehat{\dim}_B ≈ 0.709$ — outside the speculative Weierstrass window (1, 2).
- **Wavelet (Morlet):** dominant log-scale width ≈ 14.506 — coarse global scale only; no sharp local multiscale signature isolated.
- **Overall:** `[C]` negative / inconclusive for the Weierstrass multiscale analogy on H13 ABCE/CEAB bias at tested scales. Next step: CEAB-shuffle null on the cumulative series before upgrading beyond placeholder Lean `[C]` markers.

## Interpretation (preliminary)

This report is **descriptive**. Peaks in FFT/Lomb–Scargle or a box dimension between 1 and 2 would only motivate the Weierstrass/EABC analogy — they do not establish it. Compare against shuffle/null models before upgrading beyond `[C]`.

## Notes

- Box dimension 0.709 is outside the speculative fractal band (1,2).
