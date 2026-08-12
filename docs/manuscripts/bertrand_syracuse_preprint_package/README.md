# Preprint Package — Bertrand–Syracuse Prime Trichotomy

**Seal:** `PREPRINT-READY · FORMAL CORE SEALED`  
**Commit:** `f5df496abea7bbd6f8ad78c0ad1b9d62e16b7de9` (package commit may supersede; see `git rev-parse HEAD`)  
**Title:** *A Lean 4 Formalization of a Bertrand–Syracuse Prime Trichotomy*  
**PR:** https://github.com/AkademieOlympia/Kepler-Hurrwitz/pull/20

This directory is the **reproducible submission surface**. It does not duplicate mathematics;
it binds manuscript, formal core, version pins, build steps, and non-claims into one package.

## Package inventory

| Role | Path |
|------|------|
| Manuscript (PDF source) | [`../bertrand_syracuse_prime_trichotomy.tex`](../bertrand_syracuse_prime_trichotomy.tex) |
| Lean module (formal core) | [`../../../KeplerHurwitz/Collatz/BertrandSyracuseTrichotomy.lean`](../../../KeplerHurwitz/Collatz/BertrandSyracuseTrichotomy.lean) |
| Status / claim wall | [`../../energiedoku_exports/bertrand_syracuse_prime_trichotomy.md`](../../energiedoku_exports/bertrand_syracuse_prime_trichotomy.md) |
| Reproduce script | [`./reproduce.sh`](./reproduce.sh) |
| Machine-readable manifest | [`./MANIFEST.json`](./MANIFEST.json) |
| Lean toolchain pin | [`../../../lean-toolchain`](../../../lean-toolchain) → `leanprover/lean4:v4.31.0` |
| Mathlib pin | [`../../../lakefile.toml`](../../../lakefile.toml) → `rev = "v4.31.0"` |
| Resolved deps | [`../../../lake-manifest.json`](../../../lake-manifest.json) (mathlib `inputRev`: `v4.31.0`) |

## Four sealed layers (do not conflate)

1. **Interior landing** — `n < T(n) < 2n` under `n ≡ 3 (mod 4)`.
2. **Order-theoretic trichotomy** — disjoint exhaustive partition of `ℙ ∩ (n,2n]`.
3. **Bertrand non-emptiness** — independent existence (Mathlib Bertrand).
4. **Interpretation** — optional gloss only; primary term is *orbit-determined partition point*.

## Non-claims (package contract)

The package **does not** claim:

- global Collatz / Syracuse termination;
- monotone descent, stopping-time bounds, or cylinder coverings;
- that left/right prime occupancy forces global orbit structure;
- Dumas holography or an affine-transport theorem;
- that “resonance” is a required mathematical primitive.

A schema-level equivalence “totality ⇔ Collatz” elsewhere is a characterisation of reach, not a proof that totality holds. It is **out of scope** here.

## Build instructions

From the repository root:

```bash
# 1) Formal core
lake build KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy

# 2) Placeholder audit (module only; ignore Mathlib)
./docs/manuscripts/bertrand_syracuse_preprint_package/reproduce.sh

# 3) Manuscript PDF (optional; needs pdflatex)
pdflatex -interaction=nonstopmode -output-directory=/tmp \
  docs/manuscripts/bertrand_syracuse_prime_trichotomy.tex
```

Expected: Lean build success; `0 sorry` / `0 admit` in the module; PDF builds without error.

## Principal Lean names

- `padicValNat_two_three_n_succ_eq_one_iff`
- `syracuseT_mem_interior`
- `bertrandPrimeSpectrum_eq_union`
- `landing_eq_singleton_iff_prime`
- `landing_ncard_le_one`
- `bertrandPrimeSpectrum_nonempty`
- `left_or_right_of_landing_empty`
- `unique_prime_is_landing`
- `bertrandSyracuseTrichotomyCertificate`

## Citation sketch

> T. Hofbauer. *A Lean 4 Formalization of a Bertrand–Syracuse Prime Trichotomy*.
> Kepler–Hurwitz formalization note, 28 July 2026.
> Module `KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy`, Lean 4.31.0 / Mathlib v4.31.0.
