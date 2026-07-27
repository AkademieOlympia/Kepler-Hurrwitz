# Bertrand–Syracuse Prime Trichotomy (standalone)

**Branch:** `cursor/bertrand-syracuse-trichotomy-4007`  
**Module:** `KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy`  
**Preprint:** `docs/manuscripts/bertrand_syracuse_prime_trichotomy.tex`

## Claim wall

| Layer | Status |
|-------|--------|
| Residue ↔ valuation (`n≡3 (mod 4)` ↔ `v₂(3n+1)=1`) | `[A]` candidate |
| Interior landing `n < T(n) < 2n` | `[A]` candidate |
| Order-theoretic prime trichotomy (disjoint + exhaustive) | `[A]` candidate |
| Landing singleton / empty characterisation | `[A]` candidate |
| Bertrand non-emptiness of the spectrum | `[A]` candidate (Mathlib Bertrand) |
| Global Collatz / orbit termination | **not claimed** |
| EABC “resonance” interpretation | interpretive only; not required |

## Terminology

Primary: **orbit-determined partition point** `T(n)`.  
Optional gloss: local resonance point (EABC). Avoid as primary preprint term.

## Build

```bash
lake build KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy
rg -n -P '(^|[^A-Za-z0-9_/`])(sorry|admit)([^A-Za-z0-9_]|$)' \
  KeplerHurwitz/Collatz/BertrandSyracuseTrichotomy.lean
```

## Non-goals

No Dumas holography. No affine transport theorem. No Pre119 Core6 residual dynamics.
This note is intentionally detachable from the larger programme.
