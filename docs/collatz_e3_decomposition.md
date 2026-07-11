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

---

## Lemma 3 — Kommutativer Multiplet-Split (`[b,c] = 0`, `S_±`)

**Voraussetzung:** `r = b * c` (Lemma 2) und gleiche Parität `(b + c) % 2 = 0` (Nat-Ring: `[b,c] = bc - cb = 0`).

Symmetrisierte Operatoren:

| Symbol | Definition |
|---|---|
| `S_+` | `(b + c) / 2` |
| `S_-` | `|b - c| / 2` |

**Identitäten `[A]`:**

- `b * c = S_+² - S_-²`
- `a = q * e² + S_+² - S_-²`
- `n = q * e³ + S_+² * e - S_-² * e`

**Beispiel:** `a = 17`, `e = 3`, `b = 2`, `c = 4` → `S_+ = 3`, `S_- = 1` → `8 = 9 - 1` → `n = 51 = 27 + 27 - 3`.

### Lean-Sätze (Lemma 3)

| Name | Aussage |
|---|---|
| `e3SPlus` / `e3SMinus` | symmetrische Operatoren |
| `e3_commutative_product_split` | gleiche Parität → `b*c = S_+² - S_-²` |
| `e3_symmetric_rest_decomposition` | `r = b*c` → `r = S_+² - S_-²` |
| `e3_multiplet_identity` | `n = q*e³ + S_+²*e - S_-²*e` |
| `E3CommutativeMultiplet` | Struktur mit `sPlus`, `sMinus`, Beweisen |

### Python-Diagnostic `[B]`

| Funktion | Rolle |
|---|---|
| `commutation_check` | `[b,c]` im Nat-Ring (immer 0 für Int) |
| `symmetric_operators` | `(S_+, S_-)` mit Paritätsguard |
| `analyze_e3_commutative_multiplet` | Lemma 1–3 + Multiplet-Identität |

**Diagnostischer Nutzen:** Statt abstraktem `r` können Profile `(S_+², S_-²)` mitführen. `S_-² → 0` bedeutet `b = c` (perfektes Quadrat im Restkanal) — nur **`[B]`** Resonanzsignal, kein Beweis.

---

## Physikalische Analogie — Zeeman / Stark / Quaternion `[C]`

> **Governance (verbindlich):** Zeeman-/Stark-Aufspaltung und Quaternion-Kollinearität sind **Lesesprache `[C]`** — **keine** Physik-Identität, **kein** Collatz-Beweis, **kein** EABC-Physik-Claim.

| Leseterm | Multiplet-Split | Analogie (nur `[C]`) |
|---|---|---|
| `q * e³` | ungestörtes Niveau | Hauptterm / Vakuumniveau |
| `+ S_+² * e` | parallele Kopplung | angehobener Bindungszustand |
| `- S_-² * e` | antiparallele Kopplung | Absenkungsterm / Defekt |

**Quaternion `[C]`:** `[b,c] = bc - cb = 2·(v_b × v_c)` — Null-Kommutator ⇒ kollineare Vektorteile (maximale Kohärenz). Das ist **interpretive bridge**, nicht operationalisierte Quaternionen-Embedding im Lean-Kern.

**EN governance box:** Zeeman/Stark multiplet language is an **interpretive resonance anchor only**. It does **not** identify EABC with atomic spectroscopy, does **not** prove Syracuse quantization, and does **not** imply Collatz termination.

---

## Wirkung auf Collatz-Behauptungen (Lemma 3)

**Kurzantwort:** Lemma 3 **ändert nichts** am Collatz-Beweisstatus. Die Aufspaltung ist eine wohldefinierte, hochsymmetrische Eigenschaft der Darstellung `n = e * a` bei faktorisiertem Rest — sie erzwingt **keine** Trajektorien-Termination.

**Fazit Lemma 3:** Orthogonale Notations-/Diagnostikschicht — **null Collatz-Konsequenz**; optional **`[B]`** Profilmetrik `(S_+², S_-²)`.

---

## Spektral-Diagnostic — ungerade e-Potenzen `[B]`

Für Lemma-2-Split `n = q * e³ + b * c * e` bilden die Koeffizienten der **ungeraden** e-Potenzen den Vektor `(q, b*c, 1)`. Die Rang-1-Gram-Matrix `outer(t, t)` hat sortierte Eigenwerte `[0, 0, q² + (b*c)² + 1]` und Anisotropie-Lücke `λ_max - λ_min`.

| Funktion | Rolle |
|---|---|
| `e3_spectral_diagnostic` | Eigenwerte, `anisotropy_gap`, Split-Validierung |

**Beispiel:** `a = 17`, `e = 3`, `b = 2`, `c = 4` → `n = 51`, Koeffizienten `(1, 8, 1)` → `anisotropy_gap = 66`.

**Governance:** Reine **[B]**-Profilmetrik auf der algebraischen Split-Form — **kein** EABC-Tensor-Claim, **kein** Collatz-Beweis, **kein** Ersatz für `oddCore`/Syracuse.

---

## E³ ↔ EABC Anisotropie-Vergleich `[B]`

Für festes `n = e * a` mit gültigem Lemma-2-Split vergleicht `compare_e3_eabc_anisotropy` die e³-Koeffizienten mit dem EABC-Rang-1-Defektmodell aus [`eabc_renormalisierungsprogramm.md`](energiedoku_exports/eabc_renormalisierungsprogramm.md).

### Brückenkonvention (explizit, nicht Äquivalenz-Claim)

| Schritt | Konvention |
|---|---|
| Defektrichtung | `v = normalize(q, b*c, 1)` aus ungeraden e-Potenz-Koeffizienten |
| Defektgewicht | `w_p` aus EABC-Kanal des Faktors `e` (`e % 12 ∈ {1,5,7,11}`) |
| Tensor | `M_eff = 24 I_3 + w_p v v^T` (gleiche Normalisierung auf beiden Seiten) |
| Eigenwerte | aufsteigend sortiert: `[24, 24, 24 + w_p]` |
| Anisotropie | `Δ(M) = λ_max - λ_min = w_p` |
| Retraktion `R*_EABC` | Entfernt Rang-1-Defekt → `Δ = 0` |

**Nicht behauptet:** Die rohe Gram-Anisotropie `‖(q, b*c, 1)‖²` ist **nicht** gleich EABC-`Δ`; nur das gebrückte `24 I_3 + w_p v v^T`-Modell wird verglichen. Kein Claim zu `prime_norm_full_restoration` oder Collatz.

### Beispiele

| `n` | `e` | Status | Grund |
|---|---|---|---|
| `65` | `5` | `pass` | `w_p = 5`, `Δ = 5`, Retraktion `Δ = 0` |
| `60` | `5` | `pass` | `a = 12`, `r = 12 = 3 * 4` |
| `51` | `3` | `skip` | `e = 3` hat keinen EABC-Kanal |

| Funktion | Rolle |
|---|---|
| `compare_e3_eabc_anisotropy` | Vergleichsdiagnostik mit `comparison.status` |
| `eabc_defect_tensor` / `eabc_retract_defect` | Minimaler `M_eff` / `R*_EABC`-Hook |
| `eabc_tensor_spectral_summary` | Eigenwerte, Spur, Frobenius-Norm, Defektrang |
