# Bertrand–Syracuse Prime Trichotomy (standalone)

**Branch:** `cursor/bertrand-syracuse-trichotomy-4007`  
**Module:** `KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy`  
**Preprint:** `docs/manuscripts/bertrand_syracuse_prime_trichotomy.tex`  
**Status:** **PREPRINT-READY** after linguistic decoupling from the larger programme  
(primary title: *A Lean 4 Formalization of a Bertrand–Syracuse Prime Trichotomy*)

## Four layers (keep separate)

1. Interior landing of `T(n)` — `n < T(n) < 2n`
2. Order-theoretic trichotomy — disjoint exhaustive partition of `ℙ ∩ (n,2n]`
3. Bertrand non-emptiness — independent existence layer (Mathlib)
4. Interpretive dynamical meaning — optional; not required for [A]

## Claim wall

| Layer | Status |
|-------|--------|
| Residue ↔ valuation (`n≡3 (mod 4)` ↔ `v₂(3n+1)=1`) | `[A]` |
| Interior landing `n < T(n) < 2n` | `[A]` |
| Order-theoretic prime trichotomy (disjoint + exhaustive) | `[A]` |
| Landing singleton / empty / `#≤1` characterisation | `[A]` |
| Bertrand non-emptiness + landing-empty / unique-landing corollaries | `[A]` (Mathlib Bertrand) |
| Global Collatz / orbit termination | **not claimed** |
| Dumas holography / affine transport | **out of scope** (separate bridges) |
| EABC “resonance” interpretation | interpretive gloss only; primary term is **orbit-determined partition point** |

## Terminology

Primary: **orbit-determined partition point** / distinguished dynamical landing point `T(n)`.  
Optional gloss: local resonance point (EABC). Never primary preprint term.

## Build / reproducibility

```bash
lake build KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy
rg -n -P '(^|[^A-Za-z0-9_/`])(sorry|admit)([^A-Za-z0-9_]|$)' \
  KeplerHurwitz/Collatz/BertrandSyracuseTrichotomy.lean
```

Lean 4.31.0 / Mathlib `v4.31.0`. Certificate: `bertrandSyracuseTrichotomyCertificate`.

## Non-goals

No Dumas holography. No affine transport theorem (`3^7=2187` alone is not a transport principle). No Pre119 Core6 residual dynamics.  
This note is intentionally detachable and re-importable as a formal brick.
