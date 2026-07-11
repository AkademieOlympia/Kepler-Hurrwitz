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

## V2.8 Angriffsversuch — Kanal-3-Halbfall + 2-adisches Budget

**Modul:** `KeplerHurwitz/CollatzProofAttemptV28.lean`  
**Erweiterung:** `KeplerHurwitz/CollatzNetDescentMod8.lean` (Paritäts-Split + 4-Schritt-Arithmetik)

### Gewählter Angriffsvektor

**Option A + C (partiell):** Kanal `3` nach `T_odd n % 8` zerlegen. Der Unterfall `mod 8 = 5` (äquivalent: `k` gerade bei `n = 8k+3`) schließt mit **uniformem `t_loc = 4`** — der kanonische 3-Schritt-Shrink (`t_loc = 3`) scheitert an der `k+1`-Lücke, aber `ν₂(3m+1) ≥ 3` bei `m % 8 = 5` erzwingt eine vierte Halbierung und liefert den Wert `(3m+1)/8 = 9j+2 < 16j+3 = n`.

**Option B (Gerüst):** `badRunTwoAdicBudget n := ν₂(n+1)` benennt das V2.5-Tiefenbudget; `BadRunTwoAdicBudgetExhaustionStatement` markiert die intendierte Widerspruchsschablone für Kanal `7`.

**Noch offen:** Kanal `3` mod-256-Unterklassen `{27, 91, 155, 251}`; Kanal `7` für `k % 4 ≠ 2`.

**Neu in V2.8 (mod-256):** `j % 8 = 3` (`n ≡ 123 mod 256`) und `j % 8 = 6` (`n ≡ 219 mod 256`) schließen bei uniformem **`t_loc = 11`**.

**Neu in V2.8 (Kanal 7):** `k % 4 = 2` (`n = 32j+23`) schließt bei **`t_good = 4`**, **`t_loc = 4`** (Gesamtabstieg in 8 Schritten).

### V2.8 Lemma-Map `[A]` vs `[C]` (aktualisiert)

| Name | Status |
|---|---|
| `T_odd_mod8_eq_five_iff_k_even_of_mod8_eq_three` | **`[A]`** |
| `T_odd_mod8_eq_one_iff_k_odd_of_mod8_eq_three` | **`[A]`** |
| `collatz_four_steps_mod8_five_eq_three_mul_add_one_div8` | **`[A]`** |
| `channel_three_four_step_value_of_sixteen_mul_add_three` | **`[A]`** |
| `channel_three_collatz_net_descent_mod8_five_at_four` | **`[A]`** |
| `bad_run_net_descent_witness_mod8_channel_three_mod8_five` | **`[A]`** — voller Witness, `t_loc = 4` |
| `collatz_three_steps_mod8_one_eq_three_mul_add_one_div4` | **`[A]`** — `ν₂=2` bei `m % 8 = 1` |
| `channel_three_three/four/five_step_value_of_odd_k` | **`[A]`** — geschlossene Formeln `9k+4`, `27k+13`, `(27k+13)/2` |
| `channel_three_uniform_five_step_fails_net_odd_k` | **`[A]`** — uniformes `t_loc ≤ 5` unmöglich |
| `channel_three_six_step_value_of_thirty_two_mul_add_eleven` | **`[A]`** — `t_loc = 6` Wert `27j+10` |
| `channel_three_collatz_net_descent_mod8_one_at_six_k_mod4_one` | **`[A]`** — Netto-Abstieg bei `k % 4 = 1` |
| `bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_one` | **`[A]`** — voller Witness, `t_loc = 6` |
| `channel_three_six_step_fails_net_k_mod4_three` | **`[A]`** — uniformes `t_loc = 6` scheitert bei `k % 4 = 3` |
| `exists_eq_one_hundred_twenty_eight_mul_add_fiftynine_of_mod8_eq_three_and_j_mod4_one` | **`[A]`** — `j % 4 = 1` ⇔ `n = 128m+59` |
| `mod128_residue_of_thirty_two_mul_add_twentyseven_j_mod4` | **`[A]`** — mod-128-Split `{27,59,91,123}` |
| `channel_three_six/seven/eight/nine_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine` | **`[A]`** — `648m+304`, `324m+152`, `162m+76`, `81m+38` |
| `channel_three_eight_step_fails_net_mod128_fiftynine` | **`[A]`** — uniformes `t_loc = 8` scheitert auf `n ≡ 59 (mod 128)` |
| `channel_three_collatz_net_descent_mod128_fiftynine_at_nine` | **`[A]`** — Netto-Abstieg bei `n ≡ 59 (mod 128)`, `t_loc = 9` |
| `bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_mod4_one` | **`[A]`** — voller Witness, `t_loc = 9` |
| `exists_eq_two_hundred_fifty_six_mul_add_one_hundred_twenty_three_of_j_mod8_three` | **`[A]`** — `j % 8 = 3` ⇔ `n = 256m+123` |
| `exists_eq_two_hundred_fifty_six_mul_add_two_hundred_nineteen_of_j_mod8_six` | **`[A]`** — `j % 8 = 6` ⇔ `n = 256m+219` |
| `mod256_residue_of_thirty_two_mul_add_twentyseven_j_mod8` | **`[A]`** — mod-256-Split `{27,59,91,123,155,187,219,251}` |
| `channel_three_*_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three` | **`[A]`** — Schritte 6–11, Wert `243m+118` |
| `channel_three_ten_step_fails_net_mod256_one_hundred_twenty_three` | **`[A]`** — uniformes `t_loc = 10` scheitert |
| `channel_three_collatz_net_descent_mod256_one_hundred_twenty_three_at_eleven` | **`[A]`** — Netto-Abstieg bei `n ≡ 123 (mod 256)`, `t_loc = 11` |
| `bad_run_net_descent_witness_mod8_channel_three_j_mod8_three` | **`[A]`** — voller Witness, `t_loc = 11` |
| `channel_three_*_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen` | **`[A]`** — Schritte 6–11, Wert `243m+209` |
| `channel_three_collatz_net_descent_mod256_two_hundred_nineteen_at_eleven` | **`[A]`** — Netto-Abstieg bei `n ≡ 219 (mod 256)`, `t_loc = 11` |
| `bad_run_net_descent_witness_mod8_channel_three_j_mod8_six` | **`[A]`** — voller Witness, `t_loc = 11` |
| `T_odd_mod8_eq_three_iff_k_even_of_mod8_eq_seven` | **`[A]`** |
| `exists_eq_thirty_two_mul_add_twenty_three_of_mod8_eq_seven_and_k_mod4_two` | **`[A]`** — `k % 4 = 2` ⇔ `n = 32j+23` |
| `channel_seven_four_step_value_of_thirty_two_mul_add_twenty_three` | **`[A]`** — Good-Branch-Eintritt `m = 72j+53` |
| `channel_seven_four_step_shrink_value_of_seventy_two_mul_add_fiftythree` | **`[A]`** — Shrink-Wert `27j+20` |
| `channel_seven_five_step_fails_net_k_mod4_two` | **`[A]`** — uniformes `t_loc = 5` scheitert |
| `bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two` | **`[A]`** — voller Witness, `t_good=4`, `t_loc=4` |
| `bad_run_two_adic_budget_ge_two_of_mod4_eq_three` | **`[A]`** |
| `channel_seven_T_odd_mod4_eq_three` | **`[A]`** |
| `bad_run_net_descent_witness_mod8_channel_three_j_mod8_open` | **`[C]`** (`sorry`) |
| `bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two` | **`[C]`** (`sorry`) |
| `BadRunTwoAdicBudgetExhaustionStatement` | **`[C]`** (Platzhalter) |

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV28`

**Fortschritt gegenüber V2.7:** Kanal-`3`-Starts mit geradem `k` (`t_loc=4`), ungeradem `k % 4 = 1` (`t_loc=6`), `k % 4 = 3` mit `j % 4 = 1` (`t_loc=9`), mod-256 `{123,219}` (`t_loc=11`) haben **`[A]`**-Zeugen; Kanal `7` mit `k % 4 = 2` (`t_good=4`, `t_loc=4`); verbleibende mod-256-Klassen `{27,91,155,251}` und Kanal `7` `k % 4 ≠ 2` bleiben **`[C]`**.

#### Kanal-3-Abdeckung (V2.8, mod-256 verfeinert)

Für `n % 8 = 3` mit `n = 8k+3`:

| Unterfall | Anteil | `t_loc` | Status |
|---|---|---|---|
| `k` gerade (`T_odd % 8 = 5`) | 1/2 | 4 | **`[A]`** |
| `k` ungerade, `k % 4 = 1` (`n = 32j+11`) | 1/4 | 6 | **`[A]`** |
| `k` ungerade, `k % 4 = 3`, `j % 4 = 1` (`n ≡ 59 mod 128`) | 1/16 | 9 | **`[A]`** |
| `k % 4 = 3`, `j % 8 = 3` (`n ≡ 123 mod 256`) | 1/32 | 11 | **`[A]`** |
| `k % 4 = 3`, `j % 8 = 6` (`n ≡ 219 mod 256`) | 1/32 | 11 | **`[A]`** |
| `k % 4 = 3`, `j % 8 ∈ {0,2,4,7}` | 4/32 = 1/8 | variabel | **`[C]`** |

**Kanal-3-Abdeckung gesamt: 14/16 = 87,5 %.**

#### Kanal-7-Abdeckung (V2.8, partiell)

Für `n % 8 = 7` mit `n = 8k+7`:

| Unterfall | Anteil | Witness | Status |
|---|---|---|---|
| `k % 4 = 2` (`n = 32j+23`) | 1/4 | `t_good=4`, `t_loc=4` | **`[A]`** |
| `k % 4 ∈ {0,1,3}` | 3/4 | offen | **`[C]`** |

**Kanal-7-Abdeckung: 1/4 = 25 %.**

#### Beispiel `n = 27` (`k = 3`, `k % 4 = 3`, `j = 0`, `n % 256 = 27`) — **offen**

| Größe | Wert |
|---|---|
| `T_odd 27` | `41` (`% 8 = 1`) |
| `(collatzStep^[10]) 41` | `236` (≥ `n` — **`[A]`** mod-256-Barriere) |
| `(collatzStep^[11]) 41` | `118` (≥ `n` — **`[A]`** mod-256-Barriere) |
| minimales `t_loc` (numerisch) | `94` → Wert `23 < 27` |
| mod-256-Split | `j % 8 = 0` innerhalb `n ≡ 27 (mod 256)` — kein uniformes kleines `t_loc` |

#### Beispiel `n = 123` (`j = 3`, `j % 8 = 3`, `n ≡ 123 mod 256`) — **geschlossen**

| Größe | Wert |
|---|---|
| `(collatzStep^[10]) (T_odd 123)` | `236` (≥ `n` — **`[A]`** Barriere) |
| `(collatzStep^[11]) (T_odd 123)` | `118 < 123` — **`[A]`** Witness bei `t_loc = 11` |
| geschlossene Form | `243m+118` bei `n = 256m+123` |

#### Beispiel `n = 219` (`j = 6`, `j % 8 = 6`, `n ≡ 219 mod 256`) — **geschlossen**

| Größe | Wert |
|---|---|
| `(collatzStep^[11]) (T_odd 219)` | `209 < 219` — **`[A]`** Witness bei `t_loc = 11` |
| geschlossene Form | `243m+209` bei `n = 256m+219` |

#### Beispiel `n = 23` (Kanal 7, `k = 2`, `k % 4 = 2`) — **geschlossen**

| Größe | Wert |
|---|---|
| `(collatzStep^[4]) 23` | `53` (`% 4 = 1`, Good-Branch-Eintritt) |
| `(collatzStep^[4]) 53` | `20 < 23` — **`[A]`** Witness (`t_loc=4` ab Good-Branch) |
| Gesamtabstieg | `(collatzStep^[8]) 23 = 20 < 23` |

#### Beispiel `n = 59` (`k = 7`, `k % 4 = 3`, `j = 1`, `n % 128 = 59`)

| Größe | Wert |
|---|---|
| `T_odd 59` | `89` (`% 8 = 1`) |
| `(collatzStep^[8]) 89` | `76` (≥ `n` — **`[A]`** Barriere) |
| `(collatzStep^[9]) 89` | `38 < 59` — **`[A]`** Witness bei `t_loc = 9` |
| geschlossene Form | `81m+38` bei `n = 128m+59` |

---

## Kanal-3-Freeze (V2.8, nicht weiter verfolgt)

**Abdeckung eingefroren bei 13/16 ≈ 81,25 %.** Keine weitere Arbeit an Kanal `3`.

| Status | mod-128-Restklassen | Anmerkung |
|---|---|---|
| **`[A]` geschlossen** | `{59, 123, 219}` (+ niedrigere Lifts) | siehe V2.8-Lemma-Map |
| **`[C]` Deep-Tail-Frontier** | `{27, 91, 123}` | variabel großes `t_loc` (z. B. `n=27` ⇒ `t_loc=94`); nicht weiter angegriffen |

> Kanal `3` bleibt dokumentiert in V2.8; der aktive Angriff ist **Kanal `7`**.

---

## Kanal `7` — lokale Witness-Klassifikation (Pivot)

**Modul:** `KeplerHurwitz/CollatzChannelSeven.lean`  
**Numerik `[B]`:** `src/kepler_hurwitz/channel_seven_witness_scan.py`  
**Export:** [`docs/exports/channel_seven_witness_classification.json`](exports/channel_seven_witness_classification.json)

### Kanal-7-Fakten (aus Repo)

| Eigenschaft | Wert | Status |
|---|---|---|
| Eingang | `n % 8 = 7` | — |
| `T_odd n % 4` | `3` (Bad-Run-Tail) | **`[A]`** (`channel_seven_T_odd_mod4_eq_three`) |
| `eSchalenSprung` | `1` | **`[A]`** (gemeinsame `ν₂=1`-Kette) |
| Good-Branch-Eintritt | länger als Kanal `3` (z. B. `t_good=4` bei `k%4=2`) | **`[A]`** partiell |

### Methodik (adaptive 2-adische Lifting)

1. **mod 32** (`k % 4` bei `n = 8k+7`): vier Klassen `{7, 15, 23, 31}`
2. **mod 64** nur für offene mod-32-Kinder liften
3. **mod 128** nur für verbleibend offene Kinder
4. **kein mod 256** ohne dokumentierten 2-adischen Bit-Grund

### Abdeckung mod 128 (Stand)

| Feld | Wert |
|---|---|
| `total_classes` | 16 |
| `formally_closed_classes` | 4 (`{23, 55, 87, 119}` — Leiter `k % 4 = 2`) |
| `numerically_supported_classes` | 6 (`{7, 15, 39, 79, 95, 127}`) |
| `deep_tail_classes` | 6 (`{31, 47, 63, 71, 103, 111}`) |
| `open_classes` | 0 (innerhalb `max_t_loc=500`) |
| **`coverage_fraction` (formal)** | **4/16 = 25 %** |
| `numerical_coverage_fraction` | 10/16 = 62,5 % |
| `maximum_formal_t_loc` | 4 |
| `maximum_numerical_t_loc` | 83 |

### Ergebnistabelle mod 128

| modulus | residue | representative | t_loc | target_channel | status | depth |
|---:|---:|---:|---:|---:|---|---|
| 128 | 7 | 7 | 7 | 3 | numerically_supported | closed_short |
| 128 | 15 | 15 | 5 | 7 | numerically_supported | closed_short |
| 128 | 23 | 23 | 4 | 3 | formally_closed | closed_short |
| 128 | 31 | 31 | 83 | 7 | deep_tail | closed_deep |
| 128 | 39 | 39 | 9 | 3 | numerically_supported | closed_short |
| 128 | 47 | 47 | 82 | 7 | deep_tail | closed_deep |
| 128 | 55 | 55 | 4 | 3 | formally_closed | closed_short |
| 128 | 63 | 63 | 78 | 7 | deep_tail | closed_deep |
| 128 | 71 | 71 | 79 | 3 | deep_tail | closed_deep |
| 128 | 79 | 79 | 7 | 7 | numerically_supported | closed_short |
| 128 | 87 | 87 | 4 | 3 | formally_closed | closed_short |
| 128 | 95 | 95 | 5 | 7 | numerically_supported | closed_short |
| 128 | 103 | 103 | 64 | 3 | deep_tail | closed_deep |
| 128 | 111 | 111 | 44 | 7 | deep_tail | closed_deep |
| 128 | 119 | 119 | 4 | 3 | formally_closed | closed_short |
| 128 | 127 | 127 | 12 | 7 | numerically_supported | closed_medium |

### Tiefe-Klassifikation

| Label | mod-128-Reste |
|---|---|
| `closed_short` (`t_loc ≤ 10`) | `{7, 15, 23, 39, 55, 79, 87, 95, 119}` |
| `closed_medium` (`10 < t_loc ≤ 32`) | `{127}` |
| `closed_deep` (`t_loc > 32`) | `{31, 47, 63, 71, 103, 111}` |
| `formally_closed` | `{23, 55, 87, 119}` |
| `deep_tail` (numerisch tief, nicht formal) | `{31, 47, 63, 71, 103, 111}` |

### Lean-Satz-Map Kanal `7` (`[A]` vs `[C]`)

| Name | Status |
|---|---|
| `channel_seven_T_odd_mod4_eq_three` | **`[A]`** |
| `channel_seven_four_step_value_of_thirty_two_mul_add_twenty_three` | **`[A]`** |
| `channel_seven_net_descent_from_good_at_four_k_mod4_two` | **`[A]`** |
| `bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two` | **`[A]`** |
| `channel_seven_five_step_fails_net_k_mod4_two` | **`[A]`** (Barriere) |
| `channel_seven_classification_status` | **`[A]`** |
| `bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two` | **`[C]`** (`sorry`) |
| `bad_run_net_descent_witness_mod8_channel_seven_v28` | **`[C]`** (`sorry`) |
| `bad_run_net_descent_witness_mod8_channel_seven` (V2.7) | **`[C]`** (`sorry`) |

**Build:** `lake build KeplerHurwitz.CollatzChannelSeven`

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
| `KeplerHurwitz/CollatzChannelSeven.lean` | Kanal-7-Witness-Klassifikation + Status-Bündel |
| `KeplerHurwitz/CollatzProofAttemptV26.lean` | Good-Branch-Eintritt (`mod 4 = 3` → eventually `mod 4 = 1`) |
| `KeplerHurwitz/ReachableTheorems.lean` | `reachable_collatz_proof_attempt_status_v27` |
| `KeplerHurwitz/Core.lean` | Modulbündel |

---

## Verwandte Dokumente

| Dokument | Rolle |
|---|---|
| [`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md) | vollständige lokale Evidence Chain V2–V2.7 |
| [`ARCHITECTURE.md`](../ARCHITECTURE.md) | Schichtenmodell `[A]`/`[B]`/`[C]`/`L4` |
