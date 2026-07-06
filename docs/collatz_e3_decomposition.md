# Collatz — kanonische e³-Zerlegung (`n = e * a`)

**Governance:** Algebraische Identität **`[A]`** (Lean) · Python-Diagnostic **`[B]`** · Collatz-Bridge **`[C]`** (spekulativ, offen)

**Lean:** `KeplerHurwitz/E3Decomposition.lean`  
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
| **`[B]`** | `analyze_e3_decomposition`, Trajektorien-Stichproben, Restklassen-Histogramme | empirisch, kein Beweis |
| **`[C]`** | Brücke zu Collatz nur unter Spezialfaktorisierung `n = e * a` mit EABC-Kanal `e` und „Prime“-Faktor `a` | **offen / spekulativ** |

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
