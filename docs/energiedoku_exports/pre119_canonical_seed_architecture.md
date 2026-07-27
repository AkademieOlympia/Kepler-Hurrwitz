# Pre119 — Canonical Seed Architecture (PR #15)

**Governance:** Schichten 1–4 Kern `[A]` ·
Collatz unproved · ClaimsFreeze false · 0 sorry

## Beweisabhängigkeit

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
ModEq → AffineOddQuotient                 [A]  half-modulus bridge
        │
        ▼
RealizesWord ↔ AffineOddQuotient          [A]  Schicht 2 reverse
  (cons-decompose + valuationStep/nextOdd)
        │
        ▼
exists_unique_canonicalBase               [A]  Schicht 3
canonicalBase_{lt,modEq,unique}           [A]
canonicalBase_eq_classBase (e=4..11)      [A]
canonicalBase_affineOddQuotient           [A]
canonicalBase_realizes (e≥4)              [A]
        │
        ▼
infinite_lifting_from_realizing_base      [A]  Schicht 4 (e≥5, beliebiger Seed)
        │
        ▼
canonical_infinite_lifting (e≥8 / e≥5)    [A]  Komposition
```

**Nicht** der Pfad `e → e+1`. Stattdessen:
`e → eindeutige dyadische Klasse → Realisierung → unendliche AP`.

## Zensusrolle

`classBase(4…11)` ist eine **endliche Regression** gegen `canonicalBase`,
nicht der Anfang einer vermuteten unendlichen Wertetabelle.
`canonicalBase_eq_classBase` hält die Gleichheit genau im Zensusfenster fest.

## Module

| Modul | Schicht | Status |
|-------|---------|--------|
| `FiberEWordAlgebra.lean` | 1 | `[A]` `wordC_fiberE`, `fiberE_affine_identity` |
| `AffineOddQuotient.lean` | 2 | `[A]` forward + reverse (`realizesWord_of_affineOddQuotient`) |
| `CanonicalBase.lean` | 3 | `[A]` unique seed, census match, `canonicalBase_realizes` |
| `ApMemberFromTransfer.lean` | 4 | `[A]` margin + seed-independent infinite AP transfer |

## API-Entkopplung

`classBase` bleibt Census-Tabelle. Universelles Lifting hängt an
`ApMemberOkFrom e b k` + realisierendem `b`, nicht am Tabellennamen.
