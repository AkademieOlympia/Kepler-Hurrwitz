# DH-QPID Prototype Report (E-061 / E-062)

**E-061:** Bounded DH Search and Rescue-Witness Protocol — documents the search protocol and DH witness structure; does not overclaim rescue cases.

Bounded DH-QPID prototype for Cardoso-Machiavelo orders. Does not prove EABC structure or PID globally.

## Summary

| Order | p max | Candidates | α-pool | β-pool | EUC ok | DH ok | DH fail | Rescues | max ‖α‖² |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| H17 | 13 | 3192 | 620 | 624 | 3192 | 3192 | 0 | 0 | 20 |
| H713 | 11 | 2816 | 424 | 624 | 2816 | 2816 | 0 | 0 | 6 |

## Interpretation

- **Rescue** means `EUC(ρ)=0` and `DH(ρ)=1` in the bounded search.
- **Current bounded window:** H17 and H713 show **0** true rescue cases (all candidates pass EUC and DH).
- Manual DH witness for `p=2`, `δ=(0,-1,-1,-1)` with `N(αρ−β)=1/2` is verified in tests, but **not** a non-Euclidean rescue here because EUC already succeeds with rest norm `1/4`.
- Open DH failures are **not** counterexamples — search window may be too small.
- **E-062** tracks `alpha_norm_sq` as arithmetical correction energy, not physics.

## E-063 (future)

Stratify α/δ profiles by residue classes `1,5,7,11 mod 12` — not yet implemented.

## Example rescue (H17, if present)

- (none in current bounded window)
