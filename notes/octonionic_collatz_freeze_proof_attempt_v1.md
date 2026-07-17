# Oktonionischer Collatz-Freeze-Beweisversuch v1

**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Datum:** 2026-07-17  
**Bezug:** E-098 [`docs/theory/octonionic_hurwitz_jet_phase_transition.md`](../docs/theory/octonionic_hurwitz_jet_phase_transition.md) (Richtigstellung)

---

## Governance-Box

```
Einfrierung im nicht-assoziativen Raum
  = algebraische Lock-in-Struktur (Hurwitz / Fano / Assoziator)
  ≠ Collatz-Beweis

Assoziator-Defekt ≠ dynamischer Net-Descent
Kristallisationspfad ≠ Hurwitz-Prim-Zündung (E-098)
Keine Astrophysik, keine Identität Primzahlen = Jets

Endliche Restklassen-Invariante von collatzOctEmbed
  ≠ Net-Descent, ≠ BadRunNetDescentWitness
```

---

## Was „Einfrierung“ algebraisch bedeutet

| Schritt | Inhalt | Status |
|---|---|---|
| Hurwitz-Lock-in | ganzzahlige Koordinaten mit gerader Summe (Integer-Zweig) | `[A]` Definition |
| Fano-Ambient | Multiplikation über sieben gerichtete Linien; Nicht-Assoziativität | `[A]` |
| Kontrollierter Bracket | `[X_disk, X_base, X_disk] = 0` auf dem Zustand | `[A]` in `FreezePredicate` |
| Kristallisations-Lesart | diskreter Lock-in als Lesesprache für Kanalwahl | `[C]` nur Interpretation |

**`FreezePredicate(x)`** (Lean):

1. `IsIntegerHurwitz x` — gerade Koordinatensumme  
2. `associator (triadDisk x) (triadBase x) (triadDisk x) = 0`

Das ist **kein** Ersatz für `BadRunNetDescentWitness` und **schließt nicht**
`bad_run_net_descent_witness_of_mod4_three`.

---

## Embed-Map und Odd-Core

**`collatzOctEmbed n`** (Lean + Python `collatz_oct_embed`):

\[
n\cdot e_0 + \Big\lfloor\frac{n \bmod 8}{2}\Big\rfloor\cdot e_1 + (n \bmod 12)\cdot e_2 + \chi_7\cdot e_7
\]

mit \(\chi_7 = 1\) genau für Kanal-7 (`n ≡ 7 (mod 8)`).

**`oddCoreStep n`** = `oddCore(3n+1)` (Syracuse-Odd-Schritt; Python: `odd_core_step`).

---

## Endliche Restklassen-Invariante `[A]`

### Bewiesen (Hauptaussage)

Für ungerade `n`:

```text
diskAxisParity (collatzOctEmbed n)
  = diskAxisParity (collatzOctEmbed (oddCoreStep n))
```

mit `diskAxisParity x := x₂ % 2` (Triaden-Disk / `e₂`-Parität).

Beide Seiten sind `1`: ungerade `n` ⇒ `n mod 12` ungerade, und `oddCoreStep` erhält Ungeradheit.

Lean: `diskAxisParity_collatzOctEmbed_oddCoreStep`.

### Zusatz `[A]`

| Aussage | Lean |
|---|---|
| `e₀ + e₂` gerade für ungerade `n` (⇒ Parität invariant, beide `0`) | `e0_add_e2_parity_collatzOctEmbed_oddCoreStep` |
| Auf Kanal-7: `triadBaseParity` invariant unter `oddCoreStep` (beide `0`) | `triadBaseParity_collatzOctEmbed_channelSeven_oddCoreStep` |

### Gescheiterte Kandidaten (ehrlich)

| Kandidat | Befund |
|---|---|
| Parität der **vollen** Koordinatensumme | **nicht** invariant (z. B. `3→5`, `7→11`) |
| Jet-/χ₇-Parität, Kanal-7-Rest selbst | **nicht** invariant |
| Hurwitz-Gitter-Mitgliedschaft unter Odd-Core | **nicht** erhalten (~50 % der ungeraden Stationen) |
| Assoziator-Norm auf skaliertem `(e₁,e₂,e₇)` | **nicht** invariant |
| `FreezePredicate` ⇔ Kanal-7 | nur Korrelation `[B]`, keine Identität |
| Nichtkonstante Funktion von `n mod m` (m≤48) für *alle* ungeraden `n` | Transitionsgraph zusammenhängend ⇒ nur Konstanten |

Die Disk-Parität ist endlichwertig und wahr, aber auf allen ungeraden Stationen konstant `1`. Das ist ein echter Lock-in der Embed-Triade, **kein** dynamischer Abstieg.

---

## Schichten `[A]` / `[B]` / `[C]`

### `[A]` Lean — `KeplerHurwitz/Collatz/Octonion/FreezeProofAttemptV1.lean`

Bewiesen u. a.:

- `associator_eq_zero_iff_associates`
- `zero_isIntegerHurwitz`, `isIntegerHurwitz_add`
- `fano_line_e1_e2_e3_associator_eq_zero` (Fano-Linie assoziativ)
- `fano_witness_e2_e3_e4_associator_ne_zero` und `…_normSq = 4`
- `freeze_zero`
- `diskAxisParity_collatzOctEmbed_oddCoreStep` (**Hauptinvariante**)
- `e0_add_e2_parity_collatzOctEmbed_oddCoreStep`
- `triadBaseParity_collatzOctEmbed_channelSeven_oddCoreStep` (scoped)

### `[B]`/`[C]` Python — `src/kepler_hurwitz/octonionic_collatz_freeze_diagnostic.py`

- Heuristische Embed-Map `collatz_oct_embed` (mit Lean-Anker `collatzOctEmbed`)
- Freeze-Indikatoren + **Odd-Core-Invarianten-Scan** (`scan_odd_core_invariants`)
- Export: `docs/exports/octonionic_collatz_freeze_diagnostic_v1.json`

### `[C]` Hypothesen (nur `Prop`, **kein** `sorry`-Fake-Theorem)

- `FreezeImpliesChannelSevenHypothesis`
- `FreezeImpliesBadRunNetDescentHypothesis`
- `OddCoreEventuallyFreezesHypothesis`
- Bundel `FreezeCollatzBridgeHypotheses` mit `freezeBridgeHypothesesClaimed = false`

---

## Explizit nicht geschlossen

- `bad_run_net_descent_witness_of_mod4_three` bleibt `[C]` offen (V2.7)
- Kein Claim „Freeze ⇒ Collatz-Terminierung“
- Kein Upgrade von E-098 zu Physik/SDSS
- Die Disk-Paritäts-Invariante **upgradet nicht** zu Net-Descent

---

## Suchprogramm Phase A / B / C (bindend)

**Entscheidung:** Keine nichtkonstante Invariante durch Unterklassen-Cherry-Picking erzwingen. Ist der Funktionsgraph von \(T\) auf einem endlichen Raum schwach zusammenhängend (ein Attraktorzyklus + Basin), existiert **keine** nichtkonstante Invariante \(J\circ T=J\).

| Phase | Ziel | Status |
|---|---|---|
| **A** | Nackte Graphentopologie von `oddCoreStep` auf endlichen Odd-Restklassen — keine geometrischen Schranken, keine Fano-Strukturen a priori | Scanner + Export |
| **B** | Kandidaten-Observablen: exakte Invarianz vs. zyklische Kovarianz \(J(Tx)=\sigma(J(x))\), \(\sigma^k=\mathrm{id}\), \(\sigma\neq\mathrm{id}\) | Quotienten-Audit |
| **C** | Erst nach Phase-A-Befund: Fano-/Charakter-Hypothesen nur auf Räumen mit `weak_components_count > 1` oder als echte Kovarianz | ausstehend |

**Disk-Parität konstant `1`:** Symptom von Zusammenhang (triviale Invariante), kein differenzieller Lock-in. Auf schwach zusammenhängenden Räumen ist das erwartete Kollabieren jeder nichtkonstanten Projektion.

Implementierung: `src/kepler_hurwitz/graph_analyzer.py`, Scan `examples/run_oddcore_function_graph_scan.py`, Export `docs/exports/oddcore_function_graph_phase_a.json`. Satzschema D: [`docs/theory/bh_c11_scale_invariance_homogeneity.md`](../docs/theory/bh_c11_scale_invariance_homogeneity.md) §5.5.

---

## Nächste konkrete Lean-Ziele

1. **Nach Phase A:** Nur wenn `weak_components_count > 1` (oder echte Kovarianz \(\sigma\neq\mathrm{id}\)): nichtkonstante endlichwertige Invariante / Kovariante formalisieren — keine Cherry-Pick-Unterklasse
2. Halbganzzahliger Hurwitz-Coset in `IsIntegerHurwitz` / `IsHurwitz` vereinheitlichen
3. Optional: Brücke zu `OctCollatzState.octDirection` (O3), sobald Fano-Rotation O4 existiert

---

## Build / Test

```bash
lake build KeplerHurwitz.Collatz.Octonion.FreezeProofAttemptV1
PYTHONPATH=src pytest tests/test_octonionic_collatz_freeze_diagnostic.py -q
```
