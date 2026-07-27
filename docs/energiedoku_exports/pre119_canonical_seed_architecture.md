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

## Präzision: Repräsentant vs. Faser

* **Unendliche Faser:** jedes `x ∈ C_e` realisiert `fiberE e` — unendlich viele Realisierer.
* **Eindeutigkeit im Modul:** `∃! b < 2^{e+9}, IsCanonicalSeed e b`
  (kanonischer Repräsentant unterhalb der Modulschranke), nicht Eindeutigkeit der ganzen Faser.

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

## Coverage (documented expectations — not Lean partition theorems in PR #15)

Sei `C_e = { canonicalBase(e) + k·2^{e+9} : k ∈ ℕ }` (eine Restklasse,
da `classPeriod e = 2^{e+9}`). Erwartete Dichten:

| Aussage | Wert |
|---------|------|
| `d(C_e)` | `2^{-(e+9)}` |
| `d(⋃_{e≥5} C_e)` | `1/8192` |
| Anteil `e≥4` im Core6-Zylinder | `1/8` |

## Dreiphasige Projektmatrix

| Phase | Label | Inhalt |
|-------|-------|--------|
| **PR #15** | **`[A]`** | Algebraische Existenz & unendliches Lifting (`e≥4`) |
| **PR #16** | **`[C→A]`** | Kombinatorische Zerlegung & Restklassen-Dichte (deduktive Lean-Schuld der PR-#15-Algebra; **keine** externe Axiomen-/Datenschuld) |
| **Folge** | **`[C]`** | Globale Dynamik: Zuführung `C_1∪C_2∪C_3 → ⋃_{e≥4} C_e` |

**PR #16 Leiter (sämtlich `[C→A]` bis Promotion):** 16a–16f
(Realisierung `e≥1` → Faseridentifikation → Disjunktheit → Partition/Komplement
→ Dichotomie Expansion/Kontraktion → endliche Abzählung). Dichte ist spätere
Ablesung. **Nicht** mit dem Repo-`[A]`-Status von PR #15 verwechseln.

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
