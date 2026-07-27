# Pre119 — Core6Lifting

**Tag:** `[A]` finites + unendliches AP-Lifting für e=4..7 · **0 sorry** · Collatz unbewiesen

## Antwort auf die Skizze

Den Frame **nicht** wörtlich übernehmen. Zwei Korrekturen:

1. **`isGood` gilt nur für Valuation-Wörter**, nicht für Zahlen `n`.
2. **`Core6 ++ [e]` ist eine Liste**, kein `ℕ` — man addiert nicht `k · P` darauf.

Korrektes Lifting:

\[
\mathrm{ApMemberOk}(e,k)
:\iff
\mathrm{RealizesWord}(E(e), n_k)
\land
\mathrm{realizedImage}(n_k,E(e)) < n_k,
\quad
n_k=\mathrm{base}(e)+k\cdot 2^{S(e)+1}.
\]

## Lean `[A]`

Module: `Core6Lifting.lean`, `FiberWordAffine.lean`, `Core6InfiniteLifting.lean`

| Aussage | Status |
|---------|--------|
| `S`, `period = 2^{e+9}` | `[A]` |
| `ApMemberOk` | Def |
| `lifting_e4..e7_below_2pow21` | `[A]` |
| `family_coverage_e4_to_e7_below_2pow21` | `[A]` |
| `valuation_nextOdd_add_pow` / `realizesWord_add_pow` | `[A]` |
| `realizedImage_mul_pow` / `contracts_of_wordC_lt` | `[A]` |
| `InfiniteApLiftingHypothesis e` für `e=4..7` | `[A]` (entladen) |
| `InfiniteApLiftingHypothesis 8` | `[A]` Integrationsprobe (Seed+Margin, gleicher Kern) |
| `InfiniteApLiftingHypothesis 9` | `[A]` Minimalprobe (Folge-PR; gleicher Kern) |
| `InfiniteApLiftingHypothesis` für konkretes `e≥10` | `[C]` (nächste Instanz) |
| `InfiniteApLiftingHypothesis_forall_e_ge_8` / `liftExponent` | `[C]` uniformes / rekursives Ziel |
| Packaging / Zylinder-API | zurückgestellt zugunsten Exponent-Extension |

## Architektur

```
isGoodExpSequence (Core6++[e])     [A]  (Wort)
        │
        ▼
ApMemberOk e k  (Realizes + contracts)
        │  finite: Core6Lifting [A] unter 2^21
        │  infinite e=4..7: Core6InfiniteLifting [A]
        │  probe e=8: gleiche API, nur konkrete Daten [A]
        │    via FiberWordAffine (mod-2^{S+1} + wordC)
        ▼
∀ e≥8 / Packaging / CoverCertified / Collatz   [C]
```
