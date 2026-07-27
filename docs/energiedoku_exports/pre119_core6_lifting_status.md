# Pre119 — Core6Lifting

**Tag:** `[A]` finites AP-Lifting · `[C]` unendliches ∀k · **0 sorry** · Collatz unbewiesen

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

`ZMod`-Restklassen helfen bei der Notation `n ≡ base [MOD P]`, ersetzen aber nicht
Realizes/contracts.

## Lean `[A]`

Modul: `Core6Lifting.lean`

| Aussage | Status |
|---------|--------|
| `S`, `period = 2^{e+9}` | `[A]` |
| `ApMemberOk` | Def |
| `lifting_e4..e7_below_2pow21` | `[A]` |
| `family_coverage_e4_to_e7_below_2pow21` | `[A]` |
| `InfiniteApLiftingHypothesis` | Prop **`[C]`** |
| `InfiniteApLiftingClaimed = False` | Marker |

## Architektur

```
isGoodExpSequence (Core6++[e])     [A]  (Wort)
        │
        ▼
ApMemberOk e k  (Realizes + contracts)   [A] für k unter 2^21 (e=4..7)
        │
        ▼
InfiniteApLiftingHypothesis e            [C]  ∀k : ℕ
        │
        ▼
CoverCertified / Collatz                 [C]
```
