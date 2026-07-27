# Pre119 — Canonical Seed Architecture (PR #15)

**Governance:** Schicht 1/2-forward/4-transfer `[A]` · Schicht 2-reverse / Schicht 3 `[C]` ·
Collatz unproved · ClaimsFreeze false · 0 sorry

## Beweisabhängigkeit (Zielarchitektur)

```
wordC_fiberE                              [A]  Schicht 1
        │
        ▼
fiberE_affine_identity                    [A]  Schicht 1
        │
        ▼
AffineOddQuotient (forward)               [A]  Schicht 2
        │
        ▼
RealizesWord ↔ AffineOddQuotient          [C]  Schicht 2 reverse
        │
        ▼
exists_unique_canonicalBase               [C]  Schicht 3
        │
        ▼
canonicalBase_realizes                    [C]  Schicht 3
        │
        ▼
infinite_lifting_from_realizing_base      [A]  Schicht 4 (e≥5, beliebiger Seed)
        │
        ▼
canonical_infinite_lifting                [C]  Komposition
```

**Nicht** der Pfad `e → e+1`. Stattdessen:
`e → eindeutige dyadische Klasse → Realisierung → unendliche AP`.

## Module

| Modul | Schicht | Status |
|-------|---------|--------|
| `FiberEWordAlgebra.lean` | 1 | `[A]` `wordC_fiberE`, `fiberE_affine_identity` |
| `AffineOddQuotient.lean` | 2 | `[A]` forward; reverse statement `[C]` |
| `ApMemberFromTransfer.lean` | 4 | `[A]` `margin_fiberE_of_realizes`, `infinite_lifting_from_realizing_base` |
| (pending) CanonicalBase | 3 | Spezifikation `∃!` vor `modInv`-Implementierung |

## API-Entkopplung

`classBase` bleibt Census-Tabelle. Universelles Lifting hängt an
`ApMemberOkFrom e b k` + realisierendem `b`, nicht am Tabellennamen.
