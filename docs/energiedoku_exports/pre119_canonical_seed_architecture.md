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
infinite_lifting_from_realizing_base      [A]  Schicht 4 (e≥5, uniform)
infinite_lifting_canonicalBase (e≥5)      [A]
apMemberOkFrom_canonicalBase_e4           [A]  separate instance
infinite_lifting_canonicalBase_ge_four    [A]  union ⇒ ∀ e≥4
        │
        ▼
canonical_infinite_lifting (e≥8)          [A]  Komposition
```

**Nicht** der Pfad `e → e+1`. Stattdessen:
`e → eindeutige dyadische Klasse → Realisierung → unendliche AP`.

## Präzision: `e = 4` ist kein Korollar von `e ≥ 5`

Bewiesen uniform: `∀ e ≥ 5, ∀ k, ApMemberOkFrom e (canonicalBase e) k`.
Der Fall `e = 4` bleibt eine **separate** `[A]`-Instanz (Margin `2347 < 6687·1909`)
und wird erst durch `infinite_lifting_canonicalBase_ge_four` mit der
uniformen Familie zur geschlossenen Aussage `∀ e ≥ 4` vereinigt.

Instanzen `e ∈ {5,…,9}` sind Korollare der uniformen Familie; `e = 4` nicht.

## Präzision: mathematisch bestimmt ≠ ausführbar

`canonicalBase` ist `noncomputable` via `Classical.choose`.

| Ebene | Status |
|-------|--------|
| mathematisch | Seed eindeutig und vollständig durch `e` bestimmt |
| beweistheoretisch | keine Zensus-/Suchschuld mehr |
| computational | Lean wertet `canonicalBase 100` nicht zu einer Ziffer aus |

„Deterministisch aus der Arithmetik erzeugt“ gilt im **mathematischen** Sinn.
Eine berechenbare API (`modInv`-Formel + `canonicalBaseComputed_eq_canonicalBase`)
ist orthogonal zur Lifting-Beweisschuld (Folgearbeit, nicht PR #15).

## Zensusrolle

`classBase(4…11)` ist eine **endliche Regression** gegen `canonicalBase`,
nicht der Anfang einer vermuteten unendlichen Wertetabelle.
`canonicalBase_eq_classBase` hält die Gleichheit genau im Zensusfenster fest.

## Coverage (exakte dyadische Antwort)

Sei `C_e = { canonicalBase(e) + k·2^{e+9} : k ∈ ℕ }` (eine Restklasse,
da `classPeriod e = 2^{e+9}`). Für `e ≠ f` sind `C_e` und `C_f` disjunkt
(verschiedene exakte siebte Bewertungen nach demselben Core6-Präfix).

| Aussage | Wert |
|---------|------|
| `d(C_e)` | `2^{-(e+9)}` |
| `d(⋃_{e≥5} C_e)` | `∑_{e≥5} 2^{-(e+9)} = 1/8192` |
| relativ unter Ungeraden | `(1/8192)/(1/2) = 1/4096` |
| Core6-Zylinder-Dichte | `2^{-9} = 1/512` |
| Anteil `e≥5` im Core6-Zylinder | `(1/8192)/(1/512) = 1/16` |
| Anteil `e≥4` im Core6-Zylinder | `(1/4096)/(1/512) = 1/8` |

Endlich-dyadisch: für `5 ≤ e ≤ m` enthält die Vereinigung modulo `2^{m+9}` genau
`∑_{e=5}^{m} 2^{m-e} = 2^{m-4}-1` Restklassenpunkte, also Dichte
`1/8192 - 1/2^{m+9}`.

**Forschungsfront nach Lifting-Abschluss (PR #16):** nicht diffuse Coverage,
sondern (i) Vollständigkeitsbrücke `RealizesWord ↔ C_e`, (ii) Disjunktheit über
Bewertungs-Eindeutigkeit, (iii) Partition `C_Core6 = ⊔_{e≥1} C_e`, (iv) Komplement
der kontraktiven Familie **exakt** `e∈{1,2,3}` (Anteil `7/8`). Endliche dyadische
Zählung liefert danach `1/8` als Korollar. Offene Front: Zuführung der drei
kleinen Kanäle `Core6++[1|2|3]`.

## Module

| Modul | Schicht | Status |
|-------|---------|--------|
| `FiberEWordAlgebra.lean` | 1 | `[A]` `wordC_fiberE`, `fiberE_affine_identity` |
| `AffineOddQuotient.lean` | 2 | `[A]` forward + reverse |
| `CanonicalBase.lean` | 3 | `[A]` unique seed, realizes, `∀ e≥4` lifting (union) |
| `ApMemberFromTransfer.lean` | 4 | `[A]` margin (`e≥5`) + seed-independent transfer |

## API-Entkopplung

`classBase` bleibt Census-Tabelle. Universelles Lifting hängt an
`ApMemberOkFrom e b k` + realisierendem `b`, nicht am Tabellennamen.
