# EABC-Kanal-Partition: maximale globale Abdeckung des Primzahlstroms

**Implementierung:** `src/kepler_hurwitz/eabc_rising_collection.py`  
**Export:** `examples/export_eabc_partition_quadruples.py`  
**Vergleich mit Greedy-Scan:** `examples/export_eabc_partition_comparison.py`

Die EABC-Kanal-Partition ersetzt die lokale Suche nach Rising-Quadrupeln durch eine
kanonische globale Zerlegung des EABC-Primzahlstroms.

---

## 1. Formale Definition

Sei

\[
P_n = (p_1, p_2, \ldots, p_n)
\]

die aufsteigende Liste der ersten \(n\) Primzahlen (\(p_1 = 2\)).

Der **EABC-Strom** \(S_n\) ist die **geordnete Liste** (Teilfolge in Scan-Reihenfolge)
aller Primzahlen aus \(P_n\), deren Restklasse modulo 12 in \(\{1, 5, 7, 11\}\) liegt:

\[
S_n = (q_1, q_2, \ldots, q_m), \quad q_j \in P_n,\;
q_j \equiv 1, 5, 7 \text{ oder } 11 \pmod{12},\;
q_1 < q_2 < \cdots < q_m.
\]

Die Klammern \((\,\cdot\,)\) bezeichnen durchgehend **Listen** (Reihenfolge relevant),
nicht Mengen.

Über die **Kanalabbildung** \(\kappa(q) \in \{E, A, B, C\}\) (Implementierung:
`eabc_channel_from_mod12`) wird jede EABC-Primzahl genau einem Kanal zugeordnet,
gemäß der Konvention

\[
1 \mapsto E,\qquad 5 \mapsto A,\qquad 7 \mapsto B,\qquad 11 \mapsto C.
\]

Für jeden Kanal \(c \in \{E, A, B, C\}\) definieren wir die aufsteigende **Kanalliste**
(geordnete Teilliste von \(S_n\), sortiert nach Primwert):

\[
L_c = (q \in S_n \mid \kappa(q) = c).
\]

Als **Mengen** betrachtet zerfällt der EABC-Strom disjunkt in vier Kanäle:

\[
\{q_1, \ldots, q_m\} = L_E^{\mathrm{set}} \,\dot\cup\, L_A^{\mathrm{set}} \,\dot\cup\, L_B^{\mathrm{set}} \,\dot\cup\, L_C^{\mathrm{set}}.
\]

(Die Listen \(L_c\) sind die aufsteigenden Aufzählungen dieser Mengen; ihre Vereinigung
als Liste ist \(S_n\) selbst.)

Setze

\[
K = \min_{c \in \{E, A, B, C\}} |L_c|.
\]

Dann definieren wir für \(i = 0, \ldots, K-1\) das **synchronisierte EABC-Kanal-Quadrupel**

\[
Q_i = \bigl(L_E[i],\; L_A[i],\; L_B[i],\; L_C[i]\bigr).
\]

Jedes \(Q_i\) ist **EABC-vollständig**: genau eine Primzahl aus jedem Kanal. Die
**Restmenge** besteht aus den nicht verwendeten Surplus-Elementen der längeren Kanäle:

\[
R = \bigcup_{c \in \{E, A, B, C\}} \{\, L_c[j] \mid j \geq K \,\}.
\]

Damit gilt die **disjunkte Zerlegung**

\[
S_n = \left(\dot\bigcup_{i=0}^{K-1} Q_i\right) \,\dot\cup\, R.
\]

Die **Coverage-Ratio** ist

\[
\operatorname{Coverage}_{\mathrm{bucket}} = \frac{4K}{|S_n|} = \frac{|S_n| - |R|}{|S_n|}.
\]

---

## 2. Maximalität

**Satz (Maximalität, kombinatorisch).** Für **jeden** endlichen EABC-Strom \(S_n\) und
**jede** feste Kanalabbildung \(\kappa\) (nicht nur für Primzahlen) gilt: Die maximale
Anzahl paarweise disjunkter EABC-vollständiger Quadrupel ist

\[
K = \min_{c \in \{E, A, B, C\}} |L_c|.
\]

Die synchronisierte Bucket-Konstruktion erreicht genau \(K\) Quadrupel.

**Beweis.** Jedes EABC-vollständige Quadrupel verbraucht in jedem Kanal genau ein Element.
Eine Familie aus \(k\) disjunkten vollständigen Quadrupeln benötigt daher mindestens \(k\)
verschiedene Elemente aus jedem Kanal. Also gilt für jeden Kanal \(c\):

\[
k \leq |L_c|.
\]

Folglich gilt \(k \leq \min_c |L_c| = K\). Da die Bucket-Konstruktion genau \(K\) Quadrupel
erzeugt, ist sie optimal. Der Beweis verwendet nur endliche Mengen und die Kanalabbildung —
keine Primzahl-Eigenschaften. ∎

**Eigenschaften (Zusammenfassung).**

1. **Disjunkt:** \(Q_i \cap Q_j = \emptyset\) für \(i \neq j\).
2. **EABC-vollständig:** jedes \(Q_i\) enthält je genau eine Primzahl aus jedem Kanal.
3. **Maximal:** keine Familie paarweise disjunkter EABC-vollständiger Quadrupel aus \(S_n\)
   kann mehr als \(K\) Elemente haben.
4. **Abdeckung:** \(\bigcup_i Q_i \,\dot\cup\, R = S_n\).

**Evidenzstatus:** Maximalitätssatz **[A]** — rein kombinatorisch, unabhängig von Primzahlen.

**Lean-Formalisation:** `KeplerHurwitz/EABCChannelPartition.lean`
- `IsEABCComplete`, `bucketCapacityFinset`, `EABCChannelLists.bucketCapacity`
- `card_disjoint_eabc_quadruples_le_bucketCapacity` (Maximalitätssatz)
- `greedy_card_le_bucketCapacity` (Greedy-Obergrenze, §3.2)
- `eabcChannelOfMod12` (Python `eabc_channel_from_mod12`: 1/5/7/11 → E/A/B/C)

---

## 3. Allgemeiner Greedy-Satz (Rising-Scan)

### 3.1 Formale Definition

Sei \(S_n = (q_1, \ldots, q_m)\) der EABC-Strom in Scan-Reihenfolge. Die **Arbeitssammlung**
\(C \subseteq S_n\) (Implementierung: \(|C| \leq 4\)) wird initial leer gesetzt. Für jedes
\(q\) in Scan-Reihenfolge:

\[
C \leftarrow \mathrm{Collide}(C, q)
\]

gemäß der **Rising-Kollisionsregel**:

- **Kein Kanalkonflikt:** \(q\) anhängen.
- **Kanalkonflikt** mit \(old \in C\):
  - \(|C| = 1\): \(C \leftarrow \{q\}\).
  - \(old\) **inner** (\(\min C < old < \max C\)): \(old\) entfernen, \(q\) anhängen.
  - \(old\) **äußer** (\(old = \min C\) oder \(old = \max C\)): \(q\) überspringen.

**Reset-Regel:** Ist \(C\) EABC-vollständig (vier verschiedene Kanäle), zeichne
\(Q_k = \mathrm{sort}(C)\) auf und setze \(C \leftarrow \emptyset\).

Sei \(K_{\mathrm{greedy}}(n)\) die Anzahl der so aufgezeichneten Quadrupel. Entsprechend
\(K_{\mathrm{bucket}}(n) = K = \min_c |L_c|\) aus Abschnitt 1.

### 3.2 Satz (Greedy-Obergrenze)

**Satz.** Für jeden endlichen EABC-Strom und feste Kanalabbildung gilt stets

\[
K_{\mathrm{greedy}} \leq K_{\mathrm{bucket}} = \min_c |L_c|.
\]

Gleichheit ist **nicht** garantiert.

**Beweisskizze (Peano-artig).** Nach \(k\) Aufzeichnungen mit Reset wurden \(k\) paarweise
disjunkte EABC-vollständige Quadrupel extrahiert. Jedes solche Quadrupel verbraucht in
Kanal \(c\) genau ein Element aus \(L_c\). Disjunktheit der Quadrupel impliziert
\(k \leq |L_c|\) für alle \(c\), also \(k \leq \min_c |L_c| = K_{\mathrm{bucket}}\).
Der Greedy-Scan liefert genau eine solche Familie der Länge \(K_{\mathrm{greedy}}\). ∎

**Charakterisierung.** Der Greedy-Rising-Scan misst **lokale EABC-Verkettbarkeit** entlang
der Scan-Reihenfolge (Arbeitssammlung mit Kollisions- und Reset-Regel). Die Bucket-Partition
misst **maximale globale EABC-Abdeckbarkeit** ohne Ordnungsbindung innerhalb der Kanäle.

**Effizienzkennzahl:**

\[
\operatorname{GreedyEfficiency}(n) = \frac{K_{\mathrm{greedy}}(n)}{K_{\mathrm{bucket}}(n)}.
\]

**Evidenzstatus:**

- \(K_{\mathrm{greedy}} \leq K_{\mathrm{bucket}}\): **[A]** (kombinatorische Obergrenze,
  unabhängig von der konkreten Scan-Regel — jede disjunkte Familie unterliegt dem
  Maximalitätssatz).
- Konkrete Werte \(K_{\mathrm{greedy}}(n)\), \(\operatorname{GreedyEfficiency}(n)\):
  **[B+]** (reproduzierbarer Export, abhängig von Scan-Regel und \(n\)).

---

## 4. Eindeutigkeit und Kanonizität

Die maximale Anzahl vollständiger EABC-Kanal-Quadrupel ist eindeutig durch

\[
K = \min\bigl(|L_E|, |L_A|, |L_B|, |L_C|\bigr)
\]

bestimmt.

Die **konkrete synchronisierte Partition** ist **kanonisch**, weil innerhalb jedes Kanals
die aufsteigende Primzahlordnung verwendet wird. **Andere maximale Partitionen** können
durch Permutationen innerhalb der Kanäle entstehen; die maximale Anzahl \(K\) bleibt
jedoch unverändert.

---

## 5. Zwei verschiedene Viererbegriffe

### A. Klassische Primzahl-Quadruplets

Arithmetisch enge Muster der Form \((p, p+2, p+6, p+8)\), z. B. \((101, 103, 107, 109)\).
Diese Vierer sind extrem lokal strukturiert.

### B. EABC-Kanal-Quadrupel (Channel-Bucket)

Vierer der Form \((L_E[i], L_A[i], L_B[i], L_C[i])\). Sie müssen **nicht** nahe beieinander
liegen und sind **nicht** notwendig von der Form \((p, p+2, p+6, p+8)\). Ihre Struktur ist
nicht „enger Primzahlabstand“, sondern: **ein Element aus jedem EABC-Kanal**.

Die Konstruktion beweist **nicht**, dass Primzahlen in klassischen Primzahl-Quadruplets
liegen. Sie zeigt vielmehr, wie viele EABC-Klassen-Primzahlen in disjunkte EABC-vollständige
Kanalvierer zerlegt werden können.

Allgemein gilt für die Bucket-Abdeckung

\[
\operatorname{Coverage}(n) = \frac{4\,K_{\mathrm{bucket}}(n)}{|S_n|} = \frac{|S_n| - |R|}{|S_n|}.
\]

Für **\(n = 2000\)** ist \(\operatorname{Coverage}(2000) \approx 97{,}3\,\%\) (1944 von 1998
EABC-Primzahlen). Für **beliebiges \(n\)** folgt daraus **keine** Aussage der Form „fast alle“ —
nur die explizite Ratio \(\operatorname{Coverage}(n)\).

---

## 6. Referenzwert \(n = 2000\)

Da alle Primzahlen größer als 3 in den EABC-Restklassen liegen, fallen bei \(n = 2000\) nur
\(2\) und \(3\) heraus: \(|S_n| = 1998\).

| Größe | Wert |
|---|---|
| EABC-Strom \(m = \|S_n\|\) | 1998 |
| Bucket-Quadrupel \(K_{\mathrm{bucket}}\) | 486 |
| Verwendete Primzahlen \(4K_{\mathrm{bucket}}\) | 1944 |
| Restmenge \(\|R\|\) | 54 |
| \(\operatorname{Coverage}_{\mathrm{bucket}}\) | \(1944/1998 \approx 97{,}3\,\%\) |
| Greedy-Quadrupel \(K_{\mathrm{greedy}}\) | 310 |
| \(\operatorname{GreedyEfficiency} = K_{\mathrm{greedy}}/K_{\mathrm{bucket}}\) | \(\approx 63{,}8\,\%\) |
| \(\operatorname{GreedyLoss} = 1 - K_{\mathrm{greedy}}/K_{\mathrm{bucket}}\) | \(\approx 36{,}2\,\%\) |
| Differenz \(K_{\mathrm{bucket}} - K_{\mathrm{greedy}}\) | +176 |

**Evidenzstatus [B+]:** Die Tabellenwerte für \(n = 2000\) sind **reproduzierbare
Referenzwerte** aus dem Export (`export_eabc_partition_quadruples.py`,
`export_eabc_partition_comparison.py`). Sie illustrieren den Greedy-Satz
(\(K_{\mathrm{greedy}} = 310 < K_{\mathrm{bucket}} = 486\)), sind aber **kein**
allgemeiner Beweis für beliebiges \(n\).

CSV-Exporte:

- Quadrupel: `docs/energiedoku_exports/eabc_partition_quadruples_2000.csv`
- Vergleich: `docs/energiedoku_exports/eabc_partition_comparison_2000.csv`

---

## 7. Methodische Einordnung

| Konzept | Evidenz | Bedeutung |
|---|---|---|
| \(K_{\mathrm{bucket}} = \min_c |L_c|\) | **[A]** | kombinatorische Obergrenze, primzahl-unabhängig |
| \(K_{\mathrm{greedy}} \leq K_{\mathrm{bucket}}\) | **[A]** | Greedy-Satz (Abschnitt 3) |
| \(\operatorname{Coverage}(n) = 4K/|S_n|\) | **[A]** | aus \(K_{\mathrm{bucket}}\) und \(|S_n|\) |
| Werte für \(n = 2000\) (486, 310, 97,3 %) | **[B+]** | reproduzierbarer Export |

Die Channel-Bucket-Partition misst **globale EABC-Abdeckbarkeit**. Der Greedy-Rising-Scan
misst **lokale EABC-Verkettbarkeit** entlang der Scan-Reihenfolge (Abschnitt 3).

| Kennzahl (\(n = 2000\)) | Bedeutung |
|---|---|
| \(K_{\mathrm{bucket}} = 486\) | maximale Anzahl disjunkter vollständiger EABC-Kanal-Quadrupel |
| \(K_{\mathrm{greedy}} = 310\) | Anzahl der durch die Rising-Regel gefundenen Quadrupel |
| \(486 - 310 = 176\) | Verlust durch lokale Ordnungsbindung |
| \(\operatorname{GreedyEfficiency} \approx 63{,}8\,\%\) | \(K_{\mathrm{greedy}}/K_{\mathrm{bucket}}\) |

Bei \(n = 2000\) ist die hohe Bucket-Coverage (\(\approx 97{,}3\,\%\)) plausibel, weil die
vier mod-12-Restklassen unter Primzahlen \(> 3\) relativ ausgeglichen sind — der konkrete
Prozentwert bleibt ein **[B+]**-Kontrollwert, keine universelle „fast alle“-Aussage.

---

## 8. Einzeiler

**Greedy misst lokale Verkettbarkeit; Bucket misst maximale globale EABC-Abdeckbarkeit.**

---

## 9. Aufstiegskette mit Überlappung (Greedy-Arbeitssammlung)

**Implementierung:** `collect_eabc_rising_with_trace`, `summarize_rising_overlap_chain` in
`eabc_rising_collection.py`  
**Export:** `examples/export_eabc_rising_overlap_stats.py`

### 9.1 Zwei Ebenen der Überlappung

Der Greedy-Scan unterscheidet strikt zwei Ebenen:

1. **Arbeitssammlung (working collection)** — die sortierte Menge \(C_t \subseteq S_n\)
   mit \(|C_t| \leq 4\), die beim Durchlauf der EABC-Primzahlen wächst oder per
   *inner replacement* ein Familienmitglied (gleicher Kanal) ersetzt.
2. **Aufgezeichnete Vierlinge** — Momentaufnahmen, wenn \(C_t\) EABC-vollständig ist
   (vier verschiedene Kanäle), gefolgt von **Reset** \(C \leftarrow \emptyset\).

Die **Überlappung** sitzt auf Ebene 1: aufeinanderfolgende Sammlungszustände teilen typischerweise
1–3 Primzahlen. Die **aufgezeichneten** 310 Vierlinge bei \(n = 2000\) sind dagegen
**paarweise disjunkt** (keine gemeinsame Primzahl zwischen zwei Aufzeichnungen).

### 9.2 Formale Definition: Aufstiegskette

Sei \((q_1, q_2, \ldots)\) der EABC-Strom in Scan-Reihenfolge. Die **Aufstiegskette** ist
\((C_0, C_1, \ldots, C_T)\) mit \(C_0 = \emptyset\) und für jedes neue \(q\):

\[
C' = \mathrm{Collide}(C, q)
\]

gemäß der Rising-Kollisionsregel (äußere Kollision → überspringen; innere Kollision →
Familienmitglied ersetzen; sonst anhängen). Der **Überlappungsschritt** ist

\[
o_t = |C_{t-1} \cap C_t| \in \{0, 1, 2, 3\}.
\]

Typische Übergänge beim Aufbau eines Vierlings (\(n = 2000\)):

| \((|C_{t-1}|, |C_t|, o_t)\) | Häufigkeit |
|---|---|
| \((1, 2, 1)\) | 310 |
| \((2, 3, 2)\) | 310 |
| \((3, 4, 3)\) | 310 |
| \((3, 3, 3)\) | 317 (inneres Ersetzen) |
| \((3, 3, 2)\) | 241 |
| \((2, 2, 2)\) | 159 |

Das ist die **Reihe mit Überlappung**: kein Sprung von Vierling zu Vierling in der
Aufzeichnungsliste, sondern die lokale Verkettung innerhalb der Arbeitssammlung.

### 9.3 Disjunkte Extraktion (Reset-Regel)

**Regel (implementiert):** Sobald \(C_t\) EABC-vollständig ist, zeichne
\(Q_k = \mathrm{sort}(C_t)\) auf und setze \(C \leftarrow \emptyset\).

Das ist genau `collect_eabc_rising_quadruples`. Die Familie \(\{Q_1, \ldots, Q_{310}\}\) ist
paarweise disjunkt. Eine **maximale disjunkte Teilfolge** (greedy links-nach-rechts) liefert
dieselben 310 Elemente — keine Reduktion möglich.

### 9.4 Variante ohne Reset (Vierling-zu-Vierling-Überlappung)

Ohne Reset nach der Aufzeichnung entsteht eine lange Kette von 1995 Vierlingen, bei der
aufeinanderfolgende Einträge **3 oder 4 gemeinsame Primzahlen** teilen. Jeder Vierling
überlappt mit fast allen anderen; die größte disjunkte Teilfolge hat Länge **1**. Diese Variante
eignet sich **nicht** zur Extraktion weiterer disjunkter Vierlinge — im Gegensatz zur
Bucket-Partition (\(K_{\mathrm{bucket}} = 486\)).

### 9.5 Zahlenvergleich (\(n = 2000\))

| Größe | Wert |
|---|---|
| Übergänge in der Arbeitssammlung (\(|S_n|\)) | 1998 |
| Aufzeichnungen mit Reset \(K_{\mathrm{greedy}}\) | 310 |
| Aufzeichnungen ohne Reset | 1995 |
| Maximale disjunkte Teilfolge (mit Reset) | 310 |
| Maximale disjunkte Teilfolge (ohne Reset) | 1 |
| Bucket-maximal disjunkt \(K_{\mathrm{bucket}}\) | 486 |
| Aufgezeichnete Vierlinge paarweise disjunkt? | ja |

**Schlusspassage (minimal korrigiert).** Die Nutzerintuition trifft die **Arbeitssammlung**:
dort entsteht eine Aufstiegskette mit typisch 1–3-facher Überlappung pro Schritt. Die
**aufgezeichneten** Vierlinge nach Reset sind paarweise disjunkt und bereits die maximale
disjunkte Extraktion entlang dieser Aufzeichnungsliste — aber combinatorisch gilt stets
\(K_{\mathrm{greedy}} \leq K_{\mathrm{bucket}}\) (**[A]**), mit möglicher strikter Ungleichheit
(wie bei \(n = 2000\): \(310 < 486\), **[B+]**).

> **Kombinatorischer Kern (allgemein, unabhängig von Primzahlen):**
> \[
> K_{\mathrm{bucket}} = \min_{c \in \{E,A,B,C\}} |L_c|, \qquad
> K_{\mathrm{greedy}} \leq K_{\mathrm{bucket}}, \qquad
> \operatorname{Coverage}(n) = \frac{4\,K_{\mathrm{bucket}}(n)}{|S_n|}.
> \]
> Gleichheit \(K_{\mathrm{greedy}} = K_{\mathrm{bucket}}\) ist nicht garantiert.
> Konkrete Effizienz \(\operatorname{GreedyEfficiency}(n)\) ist ein **[B+]**-Exportwert.

Der mathematische Kern der EABC-Kanal-Partition ist elementar im besten Sinne: endlich, vollständig beweisbar und unabhängig von heuristischen Primzahlannahmen. Gerade deshalb eignet sich die Bucket-Maximalität als robuster Referenzanker für den Vergleich mit lokalen Greedy- oder Rising-Verfahren.

---

<!--
Commit-Begleittext (nicht committen, sofern nicht explizit gewünscht):

Formalize EABC channel-bucket partition in Lean

- add KeplerHurwitz/EABCChannelPartition.lean with combinatorial core [A]
- prove card_disjoint_eabc_quadruples_le_bucketCapacity (K = min_c |L_c|)
- prove greedy_card_le_bucketCapacity (K_greedy ≤ K_bucket)
- align eabcChannelOfMod12 with Python eabc_channel_from_mod12
- document Lean theorem names in docs/eabc_partition.md §2
-->
