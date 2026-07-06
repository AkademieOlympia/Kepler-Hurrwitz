# Collatz — analytische Perspektiven (Python & externe Literatur)

**Governance:** Dieses Dokument ergänzt die formale Lean-Evidence Chain
[`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md). Populärwissenschaftliche
Heuristiken und externe Meilensteine sind **`[C]`** bzw. **`[B]`** — sie ersetzen keine
Projekt-Sätze und beweisen Collatz nicht.

**Code:** `src/kepler_hurwitz/collatz_analytics.py` · **Demo:** `examples/run_collatz_analytics.py`  
**Tao-Diagnostics `[B]`:** `src/kepler_hurwitz/tao_collatz_diagnostics.py` · [`collatz_tao_diagnostics.md`](collatz_tao_diagnostics.md)

---

## Drei analytische Perspektiven

### 1. 2-adische Brücke und Paritätsverschiebungen

Collatz-Schritte alternieren zwischen geraden Divisionen (`n ↦ n/2`) und ungeraden
Kicks (`n ↦ 3n+1`). In der Lean-Schicht V2.5 extrahiert `ExactTwoAdicDepthExtractionStatement`
für Startwerte mit `n ≡ 3 (mod 4)` die exakte 2-adische Tiefe über **`padicValNat 2 (n + 1)`** —
das ist der formale Kern hinter „Paritätsbit-Verschiebungen“ in Bad Runs.

| Ebene | Objekt | Status |
|---|---|---|
| Lean V2.5 | `BadRunDepth`, `padicValNat 2 (n+1)` | `[A]` geschlossen |
| Python | `collatz_trajectory`, `collatz_step` | `[B]` empirisch |
| Heuristik | geometrisches Mittel `√3/2 ≈ 0.866` als Kollaps-Intuition | **`[C]` — kein Satz** |

Die oft zitierte Größe `√3/2` fasst im Mittel erwartete Multiplikationsfaktoren über
Paritätswechsel zusammen (ungerade Schritt ~ Faktor 3, gerade ~ Faktor 1/2). Das ist
**Lesesprache**, keine uniforme Abstiegsungleichung. Sie steht **getrennt** vom offenen
V2.7-Kern `Δ_net > 0` (siehe unten).

### 2. Inverser Baum von 1

Statt Vorwärts-Trajektorien kann man den **inversen Collatz-Baum** betrachten: von der
Wurzel `1` aus hat jeder Knoten `x` mindestens den Vorgänger `2x`. Zusätzlich gilt für
`x ≡ 4 (mod 6)` der ungerade Vorgänger `(x−1)/3`.

Python: `inverse_predecessors(x)` in `collatz_analytics.py`.

Diese Graphsicht erklärt, warum „fast alle“ natürlichen Zahlen unter Collatz-Iterationen
kleiner werden können, ohne dass jede einzelne Trajektorie formal kontrolliert ist — sie
liefert jedoch **keinen** Beweis der Collatz-Vermutung.

### 3. Terence Tao (2019) — externer Meilenstein

Terence Tao zeigte 2019, dass **fast alle** (im logarithmischen Dichte-Sinn) Collatz-Trajektorien
irgendwann einen beschränkten Wert erreichen — ein bedeutender, aber **partieller** Fortschritt.

| Aspekt | Tao 2019 | Kepler-Hurwitz V2.7 |
|---|---|---|
| Aussage | fast alle Trajektorien → beschränkter Wert | uniform `BadRunNetDescentWitness` für `n ≡ 3 (mod 4)` |
| Beweisstatus | extern, peer-reviewed | **`[C]` offen** (`bad_run_net_descent_witness_of_mod4_three`) |
| Collatz global | **nicht** bewiesen | **nicht** behauptet |

**Zitat:** Tao, T. (2019). *Almost all orbits of the Collatz map attain almost bounded values.*
arXiv:1909.03562 — https://arxiv.org/abs/1909.03562

> **Wichtig:** Tao beweist **nicht** die Collatz-Vermutung. Das Ergebnis ist externe Literatur
> **`[C]`** und wird im Projekt nur als Kontext referenziert, nicht als eigener Beweisschritt.

---

## Bezug zu V2.7 (Net-Descent) und Python-Diagnostics

Die formale Evidence Chain endet lokal bei:

- **`[A]`:** `mod4_three_descends_from_net_descent_witness` — Witness ⇒ echter Abstieg
- **`[C]` offen:** uniforme Existenz von `BadRunNetDescentWitness` mit **`Δ_net > 0`**

\[
\Delta_{\mathrm{net}}(n) = n - \mathrm{collatzStep}^{[t_{\mathrm{loc}}]}(m_{\mathrm{good}})
\]

Python-Spiegel in `kepler_hurwitz.diagnostics`: `net_descent_margin`, `bad_run_cost`,
`shrink_efficiency`. Die neue Modul-Schicht `collatz_analytics` ergänzt **Trajektorien**
und **Stopping Times** — nützlich für Exploration, aber nicht Teil des Lean-Beweiswegs.

| Werkzeug | Zweck | Governance |
|---|---|---|
| `collatz_trajectory` / `stopping_time` | Vorwärts-Exploration | `[B]` |
| `inverse_predecessors` | Baum von 1 | `[B]` |
| `diagnostics.net_descent_margin` | V2.7-Atlas-Signatur | `[B]` / Lean-Interface |
| Tao 2019 | externe Dichte-Aussage | `[C]` Literatur |
| `√3/2`-Heuristik | intuitive Kollaps-Lesesprache | `[C]` — **kein Theorem** |

---

## Governance: Schichten trennen

| Schicht | Beispiel | Status |
|---|---|---|
| **Formal `[A]`** | `BadRunDepth`, `Mod4ThreeEventuallyMod4OneStatement`, Witness⇒Abstieg | geschlossen in Lean |
| **Offen `[C]`** | `bad_run_net_descent_witness_of_mod4_three`, globale Termination | explizit offen |
| **Empirie `[B]`** | Python-Trajektorien, Stopping-Time-Tabellen | Diagnostik |
| **Populär `[C]`** | Tao „almost all“, `√3/2`-Heuristik | extern / Lesesprache |

Die Collatz-Vermutung wird in diesem Repository **nicht** als bewiesen ausgegeben.

---

## Siehe auch

- [`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md) — lokale Lean-Kette V2.2–V2.7
- [`collatz_v27_net_descent.md`](collatz_v27_net_descent.md) — Net-Descent-Bridge im Detail
- `KeplerHurwitz/CollatzProofAttemptV25.lean` — 2-adische Tiefenextraktion
- `KeplerHurwitz/CollatzProofAttemptV27.lean` — `BadRunNetDescentWitness`, offener Kern
