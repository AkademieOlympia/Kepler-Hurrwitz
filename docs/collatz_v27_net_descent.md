# Collatz V2.7 — Net-Descent-Bridge

**Quelle:** `KeplerHurwitz/CollatzProofAttemptV27.lean`  
**Kette:** [`docs/collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md) (Schritte 7–10)  
**Register:** Collatz-Kern (unabhängig von Musketiere-Spur)

---

## Governance-Kern

| Tag | Aussage | Status |
|---|---|---|
| **`[A]`** | `BadRunNetDescentWitness n` ⇒ \(\exists t,\ \mathrm{collatzStep}^{[t]} n < n\) | geschlossen (0 `sorry`) |
| **`[C]`** | \(n \equiv 3 \pmod 4,\ n > 1\) ⇒ \(\exists\) `BadRunNetDescentWitness n` | offen (`sorry`) |
| offen | globale Collatz-Termination (`CollatzGlobalTerminationStatement`) | nicht behauptet |

> **V2.7 Kurzfassung**
>
> - Witness ⇒ Abstieg ist **`[A]`** bewiesen.
> - \(n \equiv 3 \pmod 4\) ⇒ \(\exists\) `BadRunNetDescentWitness n` ist der **`[C]`**-Kern.
> - Die echte Collatz-Vermutung wird **nicht** als bewiesen ausgegeben.

---

## Zeugenstruktur

V2.7 führt `BadRunNetDescentWitness` ein: V2.6-Good-Branch-Eintritt plus die **Netto**-Ungleichung unter dem Startwert \(n\).

```lean
structure BadRunNetDescentWitness (n : Nat) where
  t_good : Nat
  m_good : Nat
  reaches_good : (collatzStep^[t_good]) n = m_good
  good_mod4 : m_good % 4 = 1
  local_shrink_time : Nat
  local_shrink : (collatzStep^[local_shrink_time]) m_good < n
```

- **`t_good`, `m_good`, `good_mod4`:** aus V2.6 — jeder `mod 4 = 3`-Zustand erreicht eventually `mod 4 = 1`.
- **`local_shrink`:** die harte Bedingung — Shrink **unter \(n\)**, nicht nur unter `m_good`.

---

## Was V2.7 ohne `sorry` beweist (`[A]`)

**Satz:** `mod4_three_descends_from_net_descent_witness`

\[
\text{BadRunNetDescentWitness}\ n \ \Longrightarrow\ \exists t,\ \mathrm{collatzStep}^{[t]} n < n
\]

**Beweisidee:** Komposition \(t = \texttt{local\_shrink\_time} + \texttt{t\_good}\):

\[
\mathrm{collatzStep}^{[t]} n
  = \mathrm{collatzStep}^{[\texttt{local\_shrink\_time}]} m_{\mathrm{good}}
  < n
\]

Weitere geschlossene Reduktionen (ebenfalls **`[A]`**):

| Satz | Rolle |
|---|---|
| `good_branch_collatz_local_shrink` | drei `collatzStep` auf `mod 4 = 1` ⇒ strikter lokaler Shrink |
| `collatz_open_case_from_net_descent_proved` | Zeugen ⇒ `Mod4ThreeEventuallyDescendsStatement` |
| `bad_run_net_descent_implies_collatz_open_case` | Zeugen ⇒ `CollatzAttemptV2OpenCase` |
| `collatz_proof_attempt_status_v27` | Status-Bündel inkl. Net-Descent-Kompositionsschicht |

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV27`

---

## Mod-8-Stratifizierung (Witness-Skeleton)

**Modul:** `KeplerHurwitz/CollatzNetDescentMod8.lean`  
**Witness-Packaging:** `CollatzProofAttemptV27.lean` → Namespace `CollatzNetDescentMod8Witness`

Für `n ≡ 3 (mod 4)` mit `n = 4k+3`: `3n+1 = 2(6k+5)`, also **`ν₂(3n+1) = 1`** exakt. Der erste Syracuse-ungerade-Schritt ist `T_odd n = 6k+5`.

| Eingang `n % 8` | `[A]` Mikro-Lemma | nächster ungerader `T_odd n % 8` | Witness-Kanal |
|---|---|---|---|
| `3` | `nu2_three_mul_add_one_eq_one_of_mod4_eq_three` | `1` oder `5` | `bad_run_net_descent_witness_mod8_channel_three` **`[C]`** |
| `7` | (dieselbe ν₂=1-Kette) | `3` oder `7` | `bad_run_net_descent_witness_mod8_channel_seven` **`[C]`** |

**Beweisachse (Zielbild, nicht behauptet):** Bad Run ohne Netto-Abstieg → inkompatible 2-adische Tiefenbudgets entlang der Tail-Kette → Widerspruch. Die mod-8-Kanäle trennen den Good-Branch-Einstieg (`% 8 = 3` ⇒ `T_odd % 4 = 1`) vom Bad-Run-Tail (`% 8 = 7` ⇒ `T_odd % 4 = 3`).

### Kanal `3` — partieller Fortschritt (`[A]`)

Für `n = 8k+3`:

| Größe | Formel |
|---|---|
| `T_odd n` | `12k+5` (strikt über `n`, `T_odd_gt_of_mod8_eq_three`) |
| Minimaler Good-Branch-Eintritt | `t_good = 2`, `m_good = T_odd n` (`channel_three_good_branch_entry_witness`) |
| Kanonischer 3-Schritt-Shrink | `(collatzStep^[3]) (T_odd n) = 9k+4` |
| Netto-Lücke bei `t_loc = 3` | `(collatzStep^[3]) (T_odd n) - n = k+1 > 0` — **kein** sofortiger Netto-Abstieg |

**`[A]` Reduktion:** `bad_run_net_descent_witness_mod8_channel_three_of_local_shrink` — sobald ein uniformes `t_loc` mit `(collatzStep^[t_loc]) (T_odd n) < n` verfügbar ist, folgt der volle Witness. Offen bleibt die Existenz eines **uniformen** solchen `t_loc` (kanonisch `3` reicht nicht).

### Skeleton-Map `[A]` vs `[C]`

| Name | Status |
|---|---|
| `mod4_eq_three_implies_mod8_three_or_seven` | **`[A]`** |
| `nu2_three_mul_add_one_eq_one_of_mod4_eq_three` | **`[A]`** |
| `eSchalenSprung_eq_one_of_mod4_eq_three` | **`[A]`** |
| `T_odd_eq_oddCoreStep_of_mod4_eq_three` | **`[A]`** |
| `first_syracuse_mod8_subcases_of_mod4_eq_three` | **`[A]`** |
| `T_odd_mod8_one_or_five_of_mod8_eq_three` | **`[A]`** |
| `T_odd_mod8_three_or_seven_of_mod8_eq_seven` | **`[A]`** |
| `T_odd_gt_of_mod8_eq_three` | **`[A]`** |
| `three_step_shrink_value_of_mod8_eq_three` | **`[A]`** |
| `three_step_shrink_gt_start_of_mod8_eq_three` | **`[A]`** |
| `channel_three_T_odd_mod4_eq_one` | **`[A]`** |
| `BadRunNetDescentWitnessMod8` | **`[A]`** Struktur |
| `channel_three_good_branch_entry_witness` | **`[A]`** minimal `t_good = 2` |
| `channel_three_collatz_local_shrink_at_T_odd` | **`[A]`** shrink `< T_odd n`, not `< n` |
| `channel_three_canonical_local_shrink_fails_net` | **`[A]`** kanonischer 3-Schritt-Shrink `≥ n` |
| `bad_run_net_descent_witness_mod8_channel_three_of_local_shrink` | **`[A]`** Reduktion auf `t_loc` |
| `bad_run_net_descent_witness_of_mod8_channel` | **`[A]`** Assembly |
| `bad_run_net_descent_statement_mod8_of_plain` / `_of_mod8` | **`[A]`** Äquivalenz-Reduktion |
| `bad_run_net_descent_witness_mod8_channel_three` | **`[C]`** (`sorry`) |
| `bad_run_net_descent_witness_mod8_channel_seven` | **`[C]`** (`sorry`) |
| `bad_run_net_descent_witness_of_mod4_three` | **`[C]`** (mod-8-Fallzerlegung, Kanal-`sorry`) |
| `mod4_three_net_descent_reduction_converse` | **`[C]`** (`sorry`) |

**Build:** `lake build KeplerHurwitz.CollatzNetDescentMod8`

---

## Offener Kern (`[C]`)

**Satz:** `bad_run_net_descent_witness_of_mod4_three` — uniforme Existenz von `BadRunNetDescentWitness` für alle \(n > 1\) mit \(n \equiv 3 \pmod 4\).

V2.6 liefert Good-Branch-Eintritt (`t_good`, `m_good`, `m_good % 4 = 1`). V2.5 liefert lokalen Good-Branch-Shrink:

\[
\mathrm{collatzStep}^{[3]} m_{\mathrm{good}} < m_{\mathrm{good}}
\]

**Das ist nur lokaler Good-Branch-Shrink.** Offen bleibt die **Netto**-Bedingung:

\[
\exists t_{\mathrm{local}},\ \mathrm{collatzStep}^{[t_{\mathrm{local}}]} m_{\mathrm{good}} < n
\]

wobei \(m_{\mathrm{good}} = \mathrm{collatzStep}^{[t_{\mathrm{good}}]} n\).

| Ungleichung | Status | Bedeutung |
|---|---|---|
| \(\mathrm{collatzStep}^{[3]} m_{\mathrm{good}} < m_{\mathrm{good}}\) | **`[A]`** | lokaler Shrink im Good-Branch |
| \(\mathrm{collatzStep}^{[t_{\mathrm{local}}]} m_{\mathrm{good}} < n\) | **`[C]`** | Bad-Run-Kosten vs. Shrink — Netto-Abstieg |

**Nächster Angriffspunkt:** quantitative Abschätzung \(m_{\mathrm{good}}\) vs. \(n\) — wie groß darf der Bad-Run-Aufschlag sein, damit der Good-Branch-Shrink den Startwert unterläuft?

Weitere offene Schichten:

| Statement | Status |
|---|---|
| `bad_run_net_descent_witness_of_mod4_three` | **`[C]`** (`sorry`) |
| `BadRunNetDescentStatement` (uniform) | **`[C]`** |
| Converse „Abstieg ⇒ Witness" (`mod4_three_net_descent_reduction_converse`) | **`[C]`** (`sorry`) |
| `CollatzGlobalTerminationStatement` | offen, nicht behauptet |

---

## Status-Tabelle (Evidence Chain)

| Schritt | Statement | Status |
|---|---|---|
| 7a | `mod4_three_descends_from_net_descent_witness` | **`[A]`** (V2.7, 0 `sorry`) |
| 7b | `bad_run_net_descent_witness_of_mod4_three` | **`[C]`** (V2.7, `sorry`) |
| 8 | `BadRunNetDescentStatement` | **`[C]`** |
| 9 | `Mod4ThreeEventuallyDescendsStatement` | **`[C]`**, reduziert auf Schritt 8 |
| 10 | `CollatzGlobalTerminationStatement` | offen |

---

## Lean-Einstieg

| Datei | Inhalt |
|---|---|
| `KeplerHurwitz/CollatzProofAttemptV27.lean` | Zeugenstruktur, Net-Descent-Komposition, offener Kern |
| `KeplerHurwitz/CollatzNetDescentMod8.lean` | Mod-8-Mikro-Lemmata + Witness-Skeleton-Kanäle |
| `KeplerHurwitz/CollatzProofAttemptV26.lean` | Good-Branch-Eintritt (`mod 4 = 3` → eventually `mod 4 = 1`) |
| `KeplerHurwitz/ReachableTheorems.lean` | `reachable_collatz_proof_attempt_status_v27` |
| `KeplerHurwitz/Core.lean` | Modulbündel |

---

## Verwandte Dokumente

| Dokument | Rolle |
|---|---|
| [`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md) | vollständige lokale Evidence Chain V2–V2.7 |
| [`ARCHITECTURE.md`](../ARCHITECTURE.md) | Schichtenmodell `[A]`/`[B]`/`[C]`/`L4` |
