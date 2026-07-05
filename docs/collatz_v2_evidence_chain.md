# Collatz-V2 — lokale Evidence Chain

**Quelle:** `KeplerHurwitz/CollatzProofAttemptV2.lean` … `CollatzProofAttemptV27.lean`  
**V2.7-Dossier:** [`collatz_v27_net_descent.md`](collatz_v27_net_descent.md) (Net-Descent-Bridge, Governance `[A]`/`[C]`)  
**Register-Verweis:** `EVIDENCE_REGISTER.md` (Collatz-Kern, unabhaengig von Musketiere-Spur)

Diese Kette dokumentiert den **lokalen** Beweisstand des Collatz-V2-Versuchs (ungerader Kern `T_odd`,
mod-4-Fallzerlegung). Sie ist von der Musketiere-Evidence Chain **E-046 → E-048 → E-032 → E-026**
getrennt.

---

## Lokale Evidence Chain

| Schritt | Statement / Satz | Rolle | Status |
|---|---|---|---|
| 1 | `CollatzAttemptV2Mod4EqOneShrink` | Good-Branch — mod 4 = 1 ⇒ strikter lokaler Shrink | `[A]` geschlossen |
| 2 | `ExactTwoAdicDepthExtractionStatement` | 2-adische Tiefenextraktion fuer mod 4 = 3 | `[A]` geschlossen |
| 3 | `BadRunDepthExtractionStatement` | Bad-Run-Tiefe aus Extraktion | `[A]` geschlossen |
| 4 | `BadBranchEventuallyLocalShrinkStatement` | Endlicher lokaler Shrink nach Bad-Branch | `[A]` geschlossen |
| 5 | `CollatzProofAttemptStatus` | Buendel der vier geschlossenen lokalen Ziele | `[A]` geschlossen |
| 6 | `Mod4ThreeEventuallyMod4OneStatement` | mod 4 = 3 ⇒ endliche `collatzStep`-Iteration erreicht mod 4 = 1 | `[A]` geschlossen (V2.6) |
| 7a | `mod4_three_descends_from_net_descent_witness` | Syntaktische Net-Descent-Komposition: Witness ⇒ echter Abstieg unter `n` | **`[A]` geschlossen (V2.7, 0 sorry)** |
| 7b | `bad_run_net_descent_witness_of_mod4_three` | Uniforme Existenz von `BadRunNetDescentWitness` fuer `mod 4 = 3` | **`[C]` offen (V2.7, sorry)** |
| 8 | `BadRunNetDescentStatement` | Fuer jedes `n ≡ 3 (mod 4)`, `n > 1`: Net-Descent-Zeuge existiert | **`[C]` offen** |
| 9 | `Mod4ThreeEventuallyDescendsStatement` | Echter `collatzStep`-Abstieg unter Startwert fuer `mod 4 = 3` | **`[C]` offen**, reduziert auf Schritt 8 |
| 10 | `CollatzGlobalTerminationStatement` | Globale Collatz-Termination | **offen** |

---

## Schritt 2: `ExactTwoAdicDepthExtractionStatement` — `[A]` geschlossen

**Beweisweg:** `CollatzProofAttemptV25.lean`

1. `n % 4 = 3` ⇒ `4 ∣ n + 1` ⇒ `2 ≤ padicValNat 2 (n + 1)` (`two_le_padicValNat_two_of_mod4_eq_three`)
2. `padicValNat 2 (n + 1)` liefert exakte 2-adische Tiefe (`exact_two_adic_depth_of_padicValNat_succ`)
3. Damit `exact_two_adic_depth_extraction_statement_holds : ExactTwoAdicDepthExtractionStatement`

Die Extraktion laeuft vollstaendig ueber **`padicValNat 2 (n + 1)`** — kein offenes arithmetisches Subziel
in dieser Schicht.

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV25`

---

## Schritt 6: `Mod4ThreeEventuallyMod4OneStatement` — `[A]` geschlossen

**Beweisweg:** `CollatzProofAttemptV26.lean`

1. `T_odd = oddKick` und `collatz_two_steps_eq_T_odd` — Bruecke `T_odd` ↔ zwei `collatzStep`
2. `bad_run_depth_extraction_statement_holds` (V2.5) liefert `BadRunDepth d n` fuer mod 4 = 3
3. `collatz_eventually_mod4_one_of_bad_run_depth` — strukturelle Rekursion ueber Tiefe `d`
4. `mod4_three_eventually_mod4_one : Mod4ThreeEventuallyMod4OneStatement`

**Interface [C] (offen, V2.7-Praezisierung):** `CollatzOpenCaseFromLocalShrinkStatement` — aus lokalem Shrink
(V2.5) + Good-Branch-Eintritt (V2.6) folgt **noch nicht** globaler Abstieg. Praezise Reduktion auf
`BadRunNetDescentStatement` (Schritt 8).

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV26`

---

## Schritt 7: Net-Descent Bridge — gemischt `[A]` / `[C]` (V2.7)

> Ausführliche Doku: [`collatz_v27_net_descent.md`](collatz_v27_net_descent.md)

**Modul:** `CollatzProofAttemptV27.lean` — **gemischt**:

- **`[A]`:** syntaktische Net-Descent-Komposition (`mod4_three_descends_from_net_descent_witness`) — ohne `sorry`
- **`[C]`:** Existenz `BadRunNetDescentWitness` (`bad_run_net_descent_witness_of_mod4_three`) — offen

V2.7 beweist die syntaktische Netto-Abstiegsbrücke: Ein `BadRunNetDescentWitness n` impliziert einen echten Collatz-Abstieg unter den Startwert `n`. Offen bleibt die uniforme Existenz solcher Witnesses für alle `n > 1` mit `n % 4 = 3`. Diese Existenz ist als `[C]` markiert und wird nicht als globaler Collatz-Beweis ausgegeben.

**Beweisweg (`[A]`):**

1. `good_branch_collatz_local_shrink` — drei `collatzStep` auf `mod 4 = 1` entsprechen `T_v2`-Shrink
2. `BadRunNetDescentWitness` buendelt V2.6-Eintritt (`t_good`, `m_good`, `good_mod4`) plus Netto-Ungleichung `local_shrink`
3. `mod4_three_descends_from_net_descent_witness` — Komposition `t = local_shrink_time + t_good`
4. `collatz_open_case_from_net_descent_proved` — **wenn** Zeugen existieren, folgt Abstieg

**Semantik vs. Beweis:** Im Kompositionssatz `mod4_three_descends_from_net_descent_witness` sind `n % 4 = 3` (`_hmod`) und `good_mod4` im Witness semantisch gebunden (Startwert im `mod 4 = 3`-Zweig, Good-Branch-Ziel), werden im Beweis aber nicht gebraucht — ok.

**Offener Kern (`[C]`):** `bad_run_net_descent_witness_of_mod4_three` — die quantitative Ungleichung

\[
m_{\mathrm{good}} = \mathrm{collatzStep}^{[t_{\mathrm{good}}]}(n),
\qquad m_{\mathrm{good}} \equiv 1 \pmod 4
\]

\[
\Delta_{\mathrm{net}}(n) = n - \mathrm{collatzStep}^{[t_{\mathrm{loc}}]}(m_{\mathrm{good}})
\]

Offen: uniform $\Delta_{\mathrm{net}} > 0$ für $n \equiv 3 \pmod 4$. Äquivalent: $\exists t_{\mathrm{loc}}$ mit
$\mathrm{collatzStep}^{[t_{\mathrm{loc}}]} m_{\mathrm{good}} < n$. Python-Diagnostics:
`kepler_hurwitz.diagnostics.net_descent_margin`, `bad_run_cost`, `shrink_efficiency`.

Lokaler Good-Branch-Shrink `(collatzStep^[3]) m_good < m_good` ist bewiesen; die **Netto**-Bedingung
(Bad-Run-Kosten $C_{\mathrm{bad}}=t_{\mathrm{good}}$ vs. Shrink) bleibt der nächste Angriffspunkt für `mod 4 = 3`.

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV27`

---

## Governance-Boxen (V2.7)

| Ebene | Aussage | Status |
|---|---|---|
| `[A]` | `good_branch_collatz_local_shrink` | geschlossen |
| `[A]` | `mod4_three_descends_from_net_descent_witness` | geschlossen |
| `[A]` | `BadRunNetDescentStatement` → `Mod4ThreeEventuallyDescendsStatement` | geschlossen |
| `[A]` | `BadRunNetDescentStatement` → `CollatzAttemptV2OpenCase` | geschlossen |
| `[A]` | V2.6: `mod4=3` → eventually `mod4=1` | geschlossen |
| `[C]` | `bad_run_net_descent_witness_of_mod4_three` | offen |
| `[C]` | uniforme Existenz von `BadRunNetDescentWitness` | offen |
| `[C]` | Converse „Abstieg ⇒ Witness" | offen |
| offen | globale Collatz-Termination | nicht behauptet |

> **V2.7 Kurzfassung**
>
> - Witness ⇒ Abstieg is `[A]` proved
> - `n ≡ 3 (mod 4)` ⇒ ∃ `BadRunNetDescentWitness n` is `[C]` open core

---

## Offene globale Schicht

Lokale Odd-Tail-Shrink, Tiefenextraktion und Good-Branch-Eintritt (V2.6) sind geschlossen. Die syntaktische
Net-Descent-Komposition (V2.7 `[A]`) ist ohne `sorry` bewiesen. Der verbleibende Kern fuer den offenen
`mod 4 = 3`-Zweig ist **`bad_run_net_descent_witness_of_mod4_three`**: die quantitative Ungleichung
`(collatzStep^[t_local]) m_good < n`. Globaler Collatz-Beweis bleibt offen (`CollatzGlobalTerminationStatement`);
die echte Collatz-Vermutung wird nicht behauptet.
