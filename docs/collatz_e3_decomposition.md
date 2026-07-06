# Collatz — kanonische e³-Zerlegung (`n = e * a`)

**Governance:** Algebraische Identität **`[A]`** (Lean) · Python-Diagnostic **`[B]`** · Collatz-Bridge / Physik-Analogie **`[C]`** (spekulativ, offen)

**Lean:** `KeplerHurwitz/E3Decomposition.lean` (Lemma 1 + Lemma 2)  
**Python:** `src/kepler_hurwitz/e3_decomposition.py`  
**Tests:** `tests/test_e3_decomposition.py`

---

## Mathematischer Kern

Für positive natürliche Zahlen `e`, `a` und `n = e * a`:

| Symbol | Definition |
|---|---|
| `q` | `a / e²` (Ganzzahldivision) |
| `r` | `a % e²` |
| Identität | `n = q * e³ + r * e` |

**Beispiel:** `a = 17`, `e = 3` → `n = 51 = 1 * 27 + 8 * 3`.

Die Identität folgt allein aus `a = q * e² + r` und ist in Lean als `e3_decomposition_identity` geschlossen.

---

## Governance-Ebenen

| Ebene | Inhalt | Status |
|---|---|---|
| **`[A]`** | `e3_decomposition_identity`: für alle `e > 0`, `a` gilt `e * a = (a/e²)*e³ + (a%e²)*e` | geschlossen in Lean |
| **`[B]`** | `analyze_e3_decomposition`, `verify_abc_split`, Trajektorien-Stichproben | empirisch, kein Beweis |
| **`[C]`** | Collatz-Bridge unter Spezialfaktorisierung; Fine-Structure-Analogie für `q*e³` / `b*c*e` | **offen / spekulativ / Lesesprache** |

---

## Wirkung auf Collatz-Behauptungen

**Kurzantwort:** Die e³-Zerlegung **stärkt den Collatz-Beweisstatus nicht** und **ersetzt weder `oddCore` noch Syracuse-Schritte**.

### Was die Identität leistet

- Reine **Divisionsalgebra** auf dem Faktor `a` relativ zu `e²`.
- Nützlich als **Notations- und Diagnostikschicht**, wenn `n` bereits als `e * a` gegeben ist (EABC-Kanal × Begleitfaktor).

### Was sie nicht leistet

- Kein uniformer Abstieg entlang Collatz-Iterationen.
- Kein Ersatz für `oddCore`-Zerlegung `n = 2^k * m` oder mod-4/mod-8-V2.7-Witnesses.
- Kein neuer Lean-Pfad zu `collatz_converges` oder `BadRunNetDescentWitness`.

### Collatz-Bridge `[C]` (spekulativ)

Eine Collatz-Relevanz entstünde **nur**, wenn Syracuse-Startwerte `n` systematisch als `n = e * a` mit

- `e` in einem festen **Primkanal** (EABC/E-Schalen-Sprache), und
- `a` „prime“ im projektinternen Sinn

faktorisierbar wären. In der Praxis:

- Syracuse-`n` sind **ungerade** und selten in dieser kanonischen Prim×Prime-Form.
- Die Zerlegung ist **faktorisierungsabhängig**, nicht collatz-invariant.
- Selbst bei passender Faktorisierung liefert `q`, `r` nur Restinformation modulo `e²`, ohne direkten Bezug zu `3n+1` oder `ν₂(3n+1)`.

**Fazit:** Die e³-Lemma-Schicht ist **orthogonal** zur bestehenden Collatz-Evidence-Chain ([`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md), [`collatz_analytical_perspectives.md`](collatz_analytical_perspectives.md)).

---

## Bezug zu Klein V4 / Prim-Gitter

| Objekt | e³-Zerlegung | Collatz / Klein |
|---|---|---|
| `oddCore`, mod-8-Klassen `{1,3,5,7}` | unabhängig | `[A]`/`[B]` in `OddCore`, `KleinCollapse` |
| `eSchalenSprung` | anderer `e`-Begriff (2-adische Tiefe nach `3m+1`) | `[A]` in `SchalenDynamik` |
| Primvierling / EABC-Kanal `e` | mögliche **Lesesprache** für Kanal `e` in `n=e*a` | **`[C]`** — keine etablierte Syracuse-Kopplung |

Es gibt **keinen** bestehenden Lean-Satz, der die e³-Zerlegung mit `reachable_collapse_klein_channel_cases` oder Tao-Diagnostics verknüpft. Eine Brücke wäre ein separates, explizit als `[C]` markiertes Forschungsprogramm.

---

## Lean-Sätze (Referenz)

| Name | Aussage |
|---|---|
| `e3Decompose` | `(a / e², a % e²)` |
| `e3_decomposition_identity` | `0 < e → e * a = (a/e²)*e³ + (a%e²)*e` |
| `E3Decomposition` | Struktur mit Feldern `q`, `r`, `hdecomp` |
| `e3DecompositionOfPos` | Konstruktor unter `0 < e` |

---

## Lemma 2 — Produktzerlegung des Restkanals (`r = b * c`)

**Aus Lemma 1:** `n = e * a`, `a = q * e² + r` mit `q = a / e²`, `r = a % e²`, `0 ≤ r < e²`.

**Wenn zusätzlich** `r = b * c` für natürliche `b`, `c`:

| Form | Ausdruck |
|---|---|
| Zerlegung | `n = q * e³ + b * c * e` |
| Schranke | `b * c < e²` (aus `r < e²`) |

**Beispiel:** `a = 17`, `e = 3` → `q = 1`, `r = 8 = 2 * 4` (oder `1 * 8`) → `n = 51 = 1 * 27 + 2 * 4 * 3`.

### Beweisskizze `[A]`

1. Aus Lemma 1: `e * a = q * e³ + r * e`.
2. Setze `r = b * c`: `e * a = q * e³ + b * c * e`. ∎
3. Schranke: `r < e²` und `r = b * c` ⇒ `b * c < e²`. ∎

```
Lemma 1:  n = e*a = q*e³ + r*e     (r = a % e²)
Lemma 2:  r = b*c  ──►  n = q*e³ + b*c*e     (b*c < e²)
          │                    │
          │                    └── Störterm / Restkanal-Produkt
          └── q*e³ = Hauptterm (modulo e² auf a)
```

### Lean-Sätze (Lemma 2)

| Name | Aussage |
|---|---|
| `e3_product_decomposition` | `a = q*e² + r`, `r = b*c` → `e*a = q*e³ + b*c*e` |
| `e3_product_bound` | `r = b*c`, `r < e²` → `b*c < e²` |
| `E3ProductSplit` | Struktur mit `q`, `b`, `c`, Identität und Schranke |
| `e3ProductSplitOfPos` | Konstruktor unter `0 < e` und `a % e² = b*c` |

### Python-Diagnostic `[B]`

| Funktion | Rolle |
|---|---|
| `abc_split_decomposition` | Liefert Split-Form `n = q*e³ + b*c*e` |
| `verify_abc_split` | Prüft `r = b*c`, gibt `n`, `q`, Validität zurück |
| `analyze_e3_with_product_split` | Lemma 1 + Lemma 2 mit `case_type` |

---

## Physikalische Analogie — Fine Structure / Hyperfine `[C]`

> **Governance (verbindlich):** Dies ist **Lesesprache / heuristic bridge `[C]`** — **keine** Physik-Identität, **kein** Collatz-Beweis, **kein** EABC-Physik-Claim. Es gelten die Repo-Grenzen aus [`physical_reference_analogies.md`](reports/physical_reference_analogies.md) (E-076) und [`meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md).

| Leseterm | e³-Split | Analogie (nur `[C]`) |
|---|---|---|
| Hauptniveau | `q * e³` | Hauptterm / ungestörte Stufe |
| Störterm | `b * c * e` | Feinstruktur- / Hyperfein-Aufspaltung des Restkanals |

**EN governance box:** Fine-structure / hyperfine splitting is an **interpretive resonance anchor only**. It does **not** identify EABC with QED spectroscopy, does **not** prove Syracuse quantization, and does **not** imply Collatz termination.

**Explizit nicht behauptet:**

- Keine Identifikation `q*e³` ↔ Spektrallinie oder QED-Niveau
- Keine Collatz-Termination oder Syracuse-Quantisierung aus `b*c`
- Kein Upgrade zu `[A]`/`[B]` ohne operationalisierte Metrik und Nullmodell
- Produkt-Split auf `r` ist **faktorisierungsabhängig** — nicht collatz-invariant

---

## Wirkung auf Collatz-Behauptungen (Lemma 2)

**Kurzantwort:** Lemma 2 **ändert nichts** am Collatz-Beweisstatus — weder Lemma 1 noch die Produktzerlegung `r = b * c` liefern Abstieg, Invarianz oder einen Lean-Pfad zu `collatz_converges`.

Zusätzlich zu den Lemma-1-Einschränkungen:

- Die Wahl `(b, c)` mit `b * c = r` ist **nicht eindeutig** (z. B. `8 = 2*4 = 1*8 = 8*1`).
- Kein Bezug zu `3n+1`, `ν₂(3n+1)` oder mod-8-Witnesses.
- Die Fine-Structure-Analogie bleibt **`[C]`** und darf nicht als physikalische oder beweistechnische Stütze gelesen werden.

**Fazit Lemma 2:** Orthogonale Notations-/Diagnostikschicht — **null Collatz-Konsequenz**.
