# DH-QPID Prototype Report (E-061 / E-062)

Bounded DH-QPID prototype for Cardoso-Machiavelo orders. Does not prove EABC structure or PID globally.

## Summary

| Order | p max | Candidates | α-pool | β-pool | EUC ok | DH ok | DH fail | Rescues | max ‖α‖² |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| H17 | 13 | 3192 | 620 | 624 | 3192 | 3192 | 0 | 0 | 20 |
| H713 | 11 | 2816 | 424 | 624 | 2816 | 2816 | 0 | 0 | 6 |

## Interpretation

- **Rescue** means `EUC(ρ)=0` and `DH(ρ)=1` in the bounded search.
- Open DH failures are **not** counterexamples — search window may be too small.
- **E-062** tracks `alpha_norm_sq` as arithmetical correction energy, not physics.

## E-063 (future)

Stratify α/δ profiles by residue classes `1,5,7,11 mod 12` — not yet implemented.

## Example rescue (H17, if present)

- (none in current bounded window)
