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
| `k` gerade (`T_odd % 8 = 5`) | 16/32 | 4 | **`[A]`** |
| `k` ungerade, `k % 4 = 1` (`n = 32j+11`) | 8/32 | 6 | **`[A]`** |
| `k` ungerade, `k % 4 = 3`, `j % 4 = 1` (`n ≡ 59 mod 128`) | 2/32 | 9 | **`[A]`** |
| `k % 4 = 3`, `j % 8 = 3` (`n ≡ 123 mod 256`) | 1/32 | 11 | **`[A]`** |
| `k % 4 = 3`, `j % 8 = 6` (`n ≡ 219 mod 256`) | 1/32 | 11 | **`[A]`** |
| `k % 4 = 3`, `j % 8 ∈ {0,2,4,7}` (`n ≡ {27,91,155,251} mod 256`) | 4/32 | variabel | **`[C]`** |

**Kanal-3-Abdeckung gesamt (mod 256, c9e2d74): 28/32 = 87,5 % formal.**

> **Historischer V2.8-Stand (mod 128):** 13/16 = 81,25 %; offene Elternklassen `{27, 91, 123}`.
> Die selektive mod-256-Verfeinerung (c9e2d74) schließt `{123, 219}`; verbleibende Deep-Tail-Frontier: `{27, 91, 155, 251}`.

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

## Kanal-3-Freeze (V2.8 / c9e2d74, nicht weiter verfolgt)

**Aktueller Freeze-Stand: 28/32 = 87,5 % formal (mod 256).** Keine weitere Arbeit an Kanal `3`.

### Historischer Stand (mod 128, V2.8)

| Kennzahl | Wert |
|---|---|
| formale Abdeckung | 13/16 = 81,25 % |
| offene Elternklassen | `{27, 91, 123}` (mod 128) |
| Beispiel | `n = 27` benötigt numerisch `t_loc ≈ 94` |

### Selektive mod-256-Verfeinerung (c9e2d74)

| mod-128-Elternklasse | mod-256-Split | Status |
|---|---|---|
| `27` | `{27, 155}` | **`[C]`** Deep-Tail |
| `91` | `{91, 219}` | `219` **`[A]`** (`t_loc = 11`); `91` **`[C]`** Deep-Tail |
| `123` | `{123, 251}` | `123` **`[A]`** (`t_loc = 11`); `251` **`[C]`** Deep-Tail |

| Status | mod-256-Restklassen | Anmerkung |
|---|---|---|
| **`[A]` geschlossen** | siehe Abdeckungstabelle oben | inkl. `{123, 219}` bei `t_loc = 11` |
| **`[C]` Deep-Tail-Frontier** | `{27, 91, 155, 251}` | variabel großes `t_loc`; nicht weiter angegriffen |

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

| Metrik | Wert | Bedeutung |
|---|---|---|
| `total_classes` | 16 | mod-128-Repräsentanten |
| `formally_closed_classes` | 6: `{7, 15, 23, 55, 87, 119}` | vollständig in Lean geschlossen (mod 128) |
| `partially_formal_mod128_classes` | 1: `{79}` | mod-256-Teilklasse `n ≡ 79 (mod 256)` formal; Geschwister `n ≡ 207 (mod 256)` offen |
| `formal_mod256_residues` | 1: `{79}` | mod-256-Lift (`j % 8 = 2`, `t_good=6`, `t_loc=7`) |
| `short_numerically_supported_classes` | 2: `{39, 95}` | numerisch short (`t_loc ≤ 10`), nicht formal |
| `medium_numerically_supported_classes` | 1: `{127}` | numerisch medium (`10 < t_loc ≤ 32`), nicht formal |
| `deep_tail_classes` | 6: `{31, 47, 63, 71, 103, 111}` | Witness gefunden, strukturell tief, nicht formalisiert |
| `classes_with_numerical_witness` | 16 | Witness innerhalb `max_t_loc = 500` |
| `unresolved_classes_within_max_t_loc_500` | 0 | kein fehlender numerischer Witness |
| **`formal_coverage_fraction`** | **6/16 = 37,5 %** | formal in Lean geschlossen (mod 128) |
| **`partial_mod256_formal_fraction`** | **1/32 = 3,125 %** | zusätzliche mod-256-Teilklasse formal |
| **`formal_or_non_deep_fraction`** | **10/16 = 62,5 %** | formal **oder** numerisch short/medium (nicht deep) |
| **`numerical_witness_found_fraction`** | **16/16 = 100 %** | Witness gefunden bis `max_t_loc = 500` |
| **`deep_tail_fraction`** | **6/16 = 37,5 %** | deep-tail (numerisch tief, formal offen) |
| `maximum_formal_t_loc` | 7 | |
| `maximum_non_deep_numerical_t_loc` | 12 | |
| `maximum_observed_t_loc` | 83 | |

> **62,5 % ist nicht** bloße Existenz numerischer Witnesses — es ist der Anteil der Klassen, die entweder formal geschlossen **oder** numerisch als short/medium (nicht deep) klassifiziert sind.

**Formulierung (stärkster dokumentierter Stand):**

Für sämtliche untersuchten mod-128-Repräsentanten des Kanals 7 wurde innerhalb von `t_loc ≤ 83` ein lokaler Net-Descent-Witness gefunden. Formal uniformisiert sind die Leiterklasse `k ≡ 2 (mod 4)` (`{23, 55, 87, 119}`) sowie zwei mod-128-Lifts: `n ≡ 7 (mod 128)` (`k ≡ 0 (mod 4)`, `j ≡ 0 (mod 4)`, `t_good=4`, `t_loc=7`) und `n ≡ 15 (mod 128)` (`k ≡ 1 (mod 4)`, `j ≡ 0 (mod 4)`, `t_good=6`, `t_loc=5`). Die mod-128-Klasse `{79}` ist **nicht** uniform schließbar; der dokumentierte 2-adische Split `j % 8` liefert die mod-256-Teilklasse `n ≡ 79 (mod 256)` formal bei `t_good=6`, `t_loc=7` — die Geschwisterklasse `n ≡ 207 (mod 256)` bleibt offen (nicht-uniformes `t_loc ∈ {10, 13, 15, …}`). Eine uniforme Übertragung auf die übrigen Restklassen, insbesondere auf den sechs Klassen umfassenden Bad-Run-Deep-Tail, ist weiterhin offen.

### Ergebnistabelle mod 128

| modulus | residue | representative | t_loc | target_channel | status | depth |
|---:|---:|---:|---:|---:|---|---|
| 128 | 7 | 7 | 7 | 3 | formally_closed | closed_short |
| 128 | 15 | 15 | 5 | 7 | formally_closed | closed_short |
| 128 | 23 | 23 | 4 | 3 | formally_closed | closed_short |
| 128 | 31 | 31 | 83 | 7 | deep_tail | closed_deep |
| 128 | 39 | 39 | 9 | 3 | numerically_supported | closed_short |
| 128 | 47 | 47 | 82 | 7 | deep_tail | closed_deep |
| 128 | 55 | 55 | 4 | 3 | formally_closed | closed_short |
| 128 | 63 | 63 | 78 | 7 | deep_tail | closed_deep |
| 128 | 71 | 71 | 79 | 3 | deep_tail | closed_deep |
| 128 | 79 | 79 | 7 | 7 | partial_formal (mod 256) | closed_short |
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
| `formally_closed` | `{7, 15, 23, 55, 87, 119}` |
| `partial_formal_mod128` | `{79}` (mod-256-Teilklasse `n ≡ 79 mod 256`) |
| `deep_tail` (numerisch tief, nicht formal) | `{31, 47, 63, 71, 103, 111}` |

### Lean-Satz-Map Kanal `7` (`[A]` vs `[C]`)

| Name | Status |
|---|---|
| `channel_seven_T_odd_mod4_eq_three` | **`[A]`** |
| `channel_seven_four_step_value_of_thirty_two_mul_add_twenty_three` | **`[A]`** |
| `channel_seven_net_descent_from_good_at_four_k_mod4_two` | **`[A]`** |
| `bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two` | **`[A]`** |
| `bad_run_net_descent_witness_mod8_channel_seven_mod128_seven` | **`[A]`** (`n ≡ 7 mod 128`) |
| `bad_run_net_descent_witness_mod8_channel_seven_mod128_fifteen` | **`[A]`** (`n ≡ 15 mod 128`) |
| `bad_run_net_descent_witness_mod8_channel_seven_mod256_seventy_nine` | **`[A]`** (`n ≡ 79 mod 256`) |
| `mod128_residue_of_thirty_two_mul_add_fifteen_j_mod4` | **`[A]`** |
| `channel_seven_six_step_value_of_two_hundred_fifty_six_mul_add_seventy_nine` | **`[A]`** |
| `channel_seven_seven_step_shrink_value_of_eight_hundred_sixty_four_mul_add_two_sixtynine` | **`[A]`** |
| `channel_seven_net_descent_from_good_at_seven_mod256_seventy_nine` | **`[A]`** |
| `channel_seven_five_step_fails_net_k_mod4_two` | **`[A]`** (Barriere) |
| `channel_seven_classification_status` | **`[A]`** |
| `bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two` | **`[C]`** (`sorry`) |
| `bad_run_net_descent_witness_mod8_channel_seven_v28` | **`[C]`** (`sorry`) |
| `bad_run_net_descent_witness_mod8_channel_seven` (V2.7) | **`[C]`** (`sorry`) |

**Build:** `lake build KeplerHurwitz.CollatzChannelSeven`

---

## Gesamtstand (nach Korrektur)

| Kanal | Formal | Non-Deep | Numerisch gefunden | Status |
|---|---|---|---|---|
| **Kanal 3** | 28/32 = 87,5 % | — | — | **eingefroren** (c9e2d74) |
| **Kanal 7** | 6/16 = 37,5 % | 10/16 = 62,5 % | 16/16 = 100 % | **aktiver Angriff** |

**Offener mathematischer Kern (unverändert):** ∀ `n > 1`, `n ≡ 3 (mod 4)` ⟹ ∃ `BadRunNetDescentWitness(n)` — `bad_run_net_descent_witness_of_mod4_three` bleibt **`[C]`** (`sorry`).

**Zu trennende Ebenen:**

- Endliche Klassifikation der Repräsentanten ist numerisch/lokal (`[B]`).
- Ein Witness für einen Repräsentanten beweist **nicht** automatisch ein uniformes Theorem für die gesamte Restklasse.
- Die sechs Kanal-7-Deep-Tail-Klassen sind numerisch nicht offen, aber formal und strukturell offen.

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
| `KeplerHurwitz/CollatzProofAttemptV28.lean` | Kanal-3/7 Teilklassen, 2-adisches Budget |
| `KeplerHurwitz/Collatz/CeabMirrorBridge.lean` | CEAB-Spiegelparität ↔ mod-8-Faser (ORQ-098) |
| `KeplerHurwitz/CollatzProofAttemptV29.lean` | V2.9 Beweisversuch: Paritätsschicht + Blocking-Assembly |
| `KeplerHurwitz/ReachableTheorems.lean` | `reachable_collatz_proof_attempt_status_v27` |
| `KeplerHurwitz/Core.lean` | Modulbündel |

---

## Verwandte Dokumente

| Dokument | Rolle |
|---|---|
| [`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md) | vollständige lokale Evidence Chain V2–V2.7 |
| [`reports/octonionic_chiral_system_v3_freeze.md`](reports/octonionic_chiral_system_v3_freeze.md) | ORQ-098 Paritätsschicht (getrennt von Collatz-Kern) |
| [`ARCHITECTURE.md`](../ARCHITECTURE.md) | Schichtenmodell `[A]`/`[B]`/`[C]`/`L4` |

---

## V2.9 — CEAB-Spiegelparitäts-Brücke (ORQ-098 → Collatz)

**Modul:** `KeplerHurwitz/CollatzProofAttemptV29.lean`  
**Brücke:** `KeplerHurwitz/Collatz/CeabMirrorBridge.lean`

### Governance

\[
\text{Paritätsschicht validiert} \;\not\Rightarrow\; \text{Collatz-Vermutung bewiesen}
\]

Analog zum ORQ-098-Freeze: formale Spiegelparität auf Faser-Budgets sichert **nicht**
automatisch den globalen Collatz-Satz.

### Was V2.9 neu formalisiert (`[A]`)

| Satz | Rolle |
|---|---|
| `mod8FiberSwap_involutive` | \(S^2=\mathrm{id}\) auf mod-8-Fasern `{8k+3, 8k+7}` |
| `fiberBudget_chiral_eq_mirror_odd_part` | \(C_\Delta\) = ungerader Budget-Anteil |
| `fiberBudget_symmetrized_eq_mirror_even_part` | \(A_{\mathrm{sym}}\) = gerader Budget-Anteil |
| `net_descent_of_mod8_blocking` | Blocking-Interface ⇒ `BadRunNetDescentWitness` |
| `collatz_proof_attempt_status_v29` | Status-Bündel inkl. Kanal-7-Klassifikation |

### Offener Kern (`[C]`, unverändert)

| Statement | Status |
|---|---|
| `mod8_blocking_interface_of_mod4_three` | `sorry` — äquivalent zu V2.7-Kern |
| `bad_run_net_descent_witness_of_mod4_three` | Kanal-3 Deep-Tail + Kanal-7 Restklassen |
| `CollatzGlobalTerminationStatement` | nicht behauptet |

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV29`

---

## V2.10 — Kanal-7 Restklasse `55 mod 128` (`[A]`)

**Modul:** `KeplerHurwitz/Collatz/ChannelSevenAttackV210.lean`  
**Assembly:** `KeplerHurwitz/CollatzProofAttemptV210.lean`

### Geschlossenes Drei-Schritt-Zertifikat

Für `n = 128k + 55`:

\[
T_{\mathrm{odd}}^{\,3}(n) = 108k + 47 < 128k + 55
\]

| Metadatum | Wert |
|---|---|
| Odd-Core-Tiefe | `3` |
| Valuationswort | `[1, 1, 3]` |
| Terminale affine Form | `108k + 47` |
| Uniformer Abstand | `20k + 8` |
| Status | `[A]` (0 `sorry` in der Klasse) |

Zentrale Lean-Sätze: `syracuseOdd_iterate_three_channelSeven55`,
`channelSeven55_strict_descent`, `bad_run_net_descent_witness_mod8_channel_seven_mod128_fifty_five`.

Brückenlemma: `oddCoreStep_eq_of_two_pow_mul_odd` in `Collatz/Octonion/Definitions.lean`.

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV210`

### Methodischer Abschluss (`collatz-channel-7-residue-55-v2.10`)

| Feld | Wert |
|---|---|
| Layer | `[A]` |
| Scope | Restklasse `55 mod 128` |
| Operator | voll beschleunigter Odd-Syracuse-Schritt (`oddCoreStep`) |
| Tiefe | `3` |
| Valuationswort | `[1, 1, 3]` |
| Terminale Form | `108k + 47` |
| Abstiegsabstand | `20k + 8` |
| Globale Implikation | keine |

**Parametrischer Kern:** Für `n = mk + r` und `S^t(n) = ak + b` gilt uniform

\[
(m - a)\,k + (r - b) > 0 \quad (\forall k \in \mathbb{N}).
\]

Im Ankerfall: `S^3(128k+55) = 108k+47`, also `(128k+55)-(108k+47) = 20k+8 > 0`.
Das ist **ein** Beweis über eine unendliche Restklassenfaser — kein Haufen bestätigter Einzeltrajektorien.

**Präzise Trennung (dauerhaft):**

\[
\boxed{\text{endliche Enumeration} \neq \text{uniformer parametrischer Beweis}}
\]

Eine Enumeration kann Teil eines algebraischen Arguments sein; sie ersetzt aber keinen Satz über alle `k ∈ ℕ`.

**Governance (unverrückbar):**

\[
\boxed{\text{Faser geschlossen} \neq \text{Kanal geschlossen} \neq \text{globale Terminierung}}
\]

\[
\boxed{\text{algebraische Eleganz} \neq \text{empirische Evidenz} \neq \text{formaler globaler Satz}}
\]

**Referenzschema für weitere Angriffe:**

Restklasse → Valuationswort → affine Iterationsform → Paritätszertifikate → uniforme Ungleichung → lokaler Satz.

**Parallele Zweige:** Im oktonionischen Chiral-System wurde ein attraktiver Mechanismus bei ausbleibender statistischer Trennung korrekt als Nullbefund eingefroren (`[B]`/`[C]`); im Collatz-Zweig wurde eine konkrete unendliche Faser symbolisch geschlossen (`[A]`). Beide Ergebnisse werden exakt auf der Ebene verbucht, die sie tragen.

---

## V2.11 — Kanal-7 Restklasse `87 mod 128` (`[A]`)

**Identifier:** `collatz-channel-7-residue-87-v2.11`  
**Modul:** `KeplerHurwitz/Collatz/ChannelSevenAttackV211.lean`  
**Assembly:** `KeplerHurwitz/CollatzProofAttemptV211.lean`

Für alle `k ∈ ℕ` auf der Faser `n = 128k + 87` (keine Nebenbedingung):

\[
S^3(n) = 54k + 37 < 128k + 87
\]

Schritt 3: `3(288k+197)+1 = 864k+592 = 16(54k+37)` — der zusätzliche Zweierfaktor (`ν₂=4`)
halbiert den Endkoeffizienten gegenüber V2.10 (`108 → 54`) und erzwingt den steileren Abstand `74k+50`.

| Metadatum | Wert |
|---|---|
| Layer | `[A]` (lokaler Lean-Build + sorry-Audit) |
| Odd-Core-Tiefe | `3` |
| Valuationswort | `[1, 1, 4]` |
| Terminale affine Form | `54k + 37` |
| Uniformer Abstand | `74k + 50` |
| Globale Implikation | keine |

Zentrale Lean-Sätze: `syracuseOdd_iterate_three_channelSeven87`,
`channelSeven87_strict_descent`, `bad_run_net_descent_witness_mod8_channel_seven_mod128_eighty_seven`.

Neues Valuationslemma: `nu2_three_mul_add_one_eq_four_of_mod8_eq5_quotient_odd` in `Nu2Bounds.lean`.

**Build (lokal):** `lake build KeplerHurwitz.CollatzProofAttemptV211`

---

## V2.12 — Kanal-7 Restklasse `119 mod 128` (`[A]`)

**Identifier:** `collatz-channel-7-residue-119-v2.12`  
**Modul:** `KeplerHurwitz/Collatz/ChannelSevenAttackV212.lean`  
**Assembly:** `KeplerHurwitz/CollatzProofAttemptV212.lean`

Für alle `k ∈ ℕ` auf der Faser `n = 128k + 119`:

\[
S^3(n) = 108k + 101 < 128k + 119
\]

Valuationswort `[1, 1, 3]`; Abstand `(128-108)k + (119-101) = 20k + 18 > 0`.

| Metadatum | Wert |
|---|---|
| Layer | `[A]` |
| Odd-Core-Tiefe | `3` |
| Valuationswort | `[1, 1, 3]` |
| Terminale affine Form | `108k + 101` |
| Uniformer Abstand | `20k + 18` |
| Globale Implikation | keine |

Zentrale Lean-Sätze: `syracuseOdd_iterate_three_channelSeven119`,
`channelSeven119_strict_descent`, `bad_run_net_descent_witness_mod8_channel_seven_mod128_one_nineteen`.

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV212`

---

## V2.12 Block-Abschluss — `collatz-channel-7-affine-block-v2.12`

### Topologisches und verfahrensmäßiges Korrektiv

1. **Diskrete Progressionen, kein Kontinuum:** `ℕ` ist abzählbar unendlich und diskret. Die drei
   parametrischen Sätze erfassen jeweils eine vollständige **unendliche arithmetische Progression**
   `128k + r` mit einem einzigen symbolischen Beweis — nicht eine „Faser“ im kontinuierlichen Sinn.

2. **Beweisverfahren, kein universeller Algorithmus:** Das Schema
   (Restklasse → Valuationswort → affine Iteration → Paritätszertifikate → uniforme Ungleichung → lokaler Satz)
   ist ein **stabil wiederverwendbares Beweisverfahren** für geeignete affine Progressionen. Es garantiert
   weder Terminierung noch Erfolg für jede Restklasse; komplexere Strukturen können längere Valuationswörter,
   Modulusverfeinerung oder verzweigte Lifts erfordern.

```markdown
Identifier:   collatz-channel-7-affine-block-v2.12
Layer:        [A] für die drei einzelnen parametrischen Sätze
              (lokale Systembehauptung: Lean-Build 8628 jobs)
Closed:       55 mod 128, 87 mod 128, 119 mod 128
Common depth: 3 fully accelerated odd Syracuse steps
Open fibers:  31, 47, 63, 71, 103, 111 mod 128
Channel 7:    not closed
Global:       not established
```

### Uniforme Abstiegsmatrix (verifizierte Familie)

Jeder Eintrag ist ein Satz über alle `k ∈ ℕ` auf der Progression `n = 128k + r`:

| Startrest `r` | Endkoeff. `a` | Terminal `ak + b` | Abstand `(128−a)k + (r−b)` |
|---|---|---|---|
| **55** | 108 | `108k + 47` | `20k + 8 > 0` |
| **87** | 54 | `54k + 37` | `74k + 50 > 0` |
| **119** | 108 | `108k + 101` | `20k + 18 > 0` |

### Epistemische Abgrenzung der offenen Fasern

Für die sechs verbleibenden Klassen `[31, 47, 63, 71, 103, 111]` gilt: das Ausbleiben eines
einfachen Drei-Schritt-Valuationsworts ist **kein** Unmöglichkeitsbeweis für einen parametrischen Satz.
Offene Lösungsräume:

\[
\text{Längeres Valuationswort} \;\lor\; \text{Modulusverfeinerung } (256/512) \;\lor\; \text{Verzweigter Lift-Baum} \;\lor\; \text{Faser-Reduktion}
\]

**Governance-Hierarchie (V2.12):**

\[
\boxed{\text{drei Kurzfasern geschlossen} \neq \text{Kanal 7 geschlossen} \neq \text{globale Terminierung}}
\]

\[
\boxed{\text{kurzer Einzelorbit fehlt} \not\Rightarrow \text{parametrischer Satz unmöglich}}
\]

\[
\boxed{\text{endliche Enumeration} \neq \text{uniformer parametrischer Beweis}}
\]

**Lean-Bündel:** `CollatzProofAttemptStatusV212` / `channel_seven_affine_block_v212_status`
in `KeplerHurwitz/CollatzProofAttemptV212.lean`.

**Build (lokal):** `lake build KeplerHurwitz.CollatzProofAttemptV212`

---

## V2.13 — `collatz-channel-7-open-fiber-71-v2.13` (Freeze)

**Identifier:** `collatz-channel-7-open-fiber-71-v2.13`  
**Layer:** `[A]` (lokale Systembehauptung über Lean-Build)  
**Modul:** `KeplerHurwitz/Collatz/ChannelSevenAttackV213.lean`

### Uniform prefix

`ω_val = [1, 1, 2, 2]` — strikte Invariante über ganz `ℕ` (Schritte 1–4).

\[
\boxed{\forall k \in \mathbb{N},\ \forall t \in \{1,2,3,4\}:\ S^t(128k+71) > 128k+71}
\]

| Tiefe `t` | `S^t(128k+71)` | Margin über Start |
|---|---|---|
| 1 | `192k + 107` | `64k + 36` |
| 2 | `288k + 161` | `160k + 90` |
| 3 | `216k + 121` | `88k + 50` |
| 4 | `162k + 91` | `34k + 20` |

### Zertifizierte Schritt-5-Verzweigung der Faser `128k + 71`

Für die Restklasse

\[
n = 128k + 71
\]

ist das Valuationswort der ersten vier normalisierten Collatz-Schritte uniform:

\[
\omega = [1, 1, 2, 2].
\]

Für alle \(k \in \mathbb{N}\) liegen explizite Orbitformen für \(S^t(n)\), \(1 \le t \le 4\), sowie die strikten Ungleichungen

\[
S^t(n) > n
\]

vor.

Die Uniformität endet im fünften Schritt. Dort zerfällt der Parameterraum vollständig und disjunkt nach \(k \bmod 4\):

| Parameterzweig | \(\nu_2(3S^4(n)+1)\) am fünften Schritt | \(S^5(n)\) |
|---|---|---|
| \(k = 2q\) | \(= 1\) | \(486q + 137\) |
| \(k = 4r + 3\) | \(= 2\) | \(486r + 433\) |
| \(k = 4r + 1\) | \(\ge 3\) (siehe unten) | \(\mathrm{oddCore}(243r + 95)\) |

#### Dritter Zweig (\(k = 4r + 1\)): Faktor \(2^3\), Bewertung und Terminalform getrennt

Im Zweig \(k = 4r + 1\) gilt das **Eingangs-Zertifikat** für den garantierten Faktor \(2^3\):

\[
3 \cdot S^4(n) + 1 = 8(243r + 95).
\]

Daraus folgt zunächst nur

\[
\nu_2\!\left(3S^4(n)+1\right) = 3 + \nu_2(243r + 95) \ge 3.
\]

Das Zertifikat weist den **garantierten Faktor \(2^3\)** exakt nach — nicht bereits die gesamte Bewertung des dritten Zweigs. Die nächste Bruchkante ist damit unmittelbar sichtbar.

Wegen

\[
243r + 95 \equiv r + 1 \pmod 2
\]

gilt genauer:

- \(r \equiv 0 \pmod 2 \Longrightarrow \nu_2\!\left(3S^4(n)+1\right) = 3\);
- \(r \equiv 1 \pmod 2 \Longrightarrow \nu_2\!\left(3S^4(n)+1\right) \ge 4\) — ein weiterer 2-adischer Lift ist nötig.

Die **Terminalform** des normalisierten fünften Schritts ist

\[
S^5(n) = \mathrm{oddCore}(243r + 95).
\]

Hier ist \(S\) der normalisierte Odd-Core-Schritt (`syracuseOddStep` = `oddCoreStep` in Lean); \(\mathrm{oddCore}(m)\) bezeichnet die vollständige 2-adische Odd-Part-Reduktion von \(m\). Da \(\mathrm{oddCore}(8m) = \mathrm{oddCore}(m)\), bleiben Eingangsidentität und Terminalform logisch getrennt: das Zertifikat beschreibt die 2-adische Faktorisierung am Eingang des fünften normalisierten Schritts; die Terminalzeile beschreibt dessen Odd-Core-Ausgabe.

Sämtliche Fallunterscheidungen und algebraischen Formen der **ersten Schritt-5-Verzweigung** sind in Lean ohne `sorry` verifiziert (`ChannelSeven71Step5BranchingCascade`). Das Resultat ist eine vollständige lokale Klassifikation nach dem uniformen Präfix. Es impliziert weder einen Deszentsatz für die gesamte Faser noch die Schließung des verbleibenden Lift-Baums — insbesondere nicht die vollständige Bewertungspartition im Zweig \(k \equiv 1 \pmod 4\) für ungerades \(r\).

### Wissenschaftlicher Ertrag

- **Formaler Ertrag:** Für die Faser \(128k + 71\) ist das uniforme Präfix \([1,1,2,2]\) einschließlich der ersten nicht-uniformen Verzweigung vollständig formalisiert.
- **Struktureller Ertrag:** Die Zerlegung in Eingangszertifikat, Bewertungsidentität und Odd-Core-Ausgabe ist sauber getrennt; dadurch wird die 2-adische Struktur transparent und maschinell überprüfbar.
- **Methodischer Ertrag:** Die Vorgehensweise liefert ein reproduzierbares Schema, das sich prinzipiell auch auf andere Restklassen anwenden lässt.
- **Offener Teil:** Die rekursive Analyse des Astes mit \(\nu_2 \ge 4\) bleibt ein eigenständiges Forschungsproblem.

> **Status von V2.13**
>
> V2.13 liefert eine vollständig formal verifizierte lokale Analyse der ersten Schritt-5-Verzweigung der Faser \(128k + 71\). Das uniforme Valuationspräfix, die erste Bewertungsaufspaltung und die zugehörigen Odd-Core-Formen sind in Lean zertifiziert. Die anschließende rekursive Auflösung des Astes \(\nu_2 \ge 4\) bleibt ausdrücklich Gegenstand weiterer Arbeit.

**Nachweisgrenze:**

**Established:**
- Exact orbit prefix and strict non-descent through depth 4.
- Termination of the globally uniform valuation word at step 5.
- Complete disjoint step-5 partition by \(k \bmod 4\) with explicit algebraic forms.

**Not established:**
- Vollständige Bewertungspartition im Zweig \(k \equiv 1 \pmod 4\) für ungerades \(r\) (\(\nu_2 \ge 4\), weiterer Lift).
- Closure of the branch \(k \equiv 1 \pmod 4\) on higher 2-adic lifts.
- Parametric descent or finite reduction to already controlled fibers.
- Closure of `71 mod 128` / Channel 7 / Global Core.

### Governance (End-Governance)

\[
\boxed{\text{Verzweigungspunkt formalisiert} \neq \text{Faser geschlossen}}
\]

\[
\boxed{\text{kein Kurzabstieg} \neq \text{kein späterer parametrischer Abstieg}}
\]

\[
\boxed{\text{einzelne Fasern analysiert} \neq \text{Kanal 7 geschlossen} \neq \text{globale Terminierung}}
\]

\[
\boxed{\text{exaktes Orbitpräfix bewiesen} \neq \text{lokaler Abstieg bewiesen}}
\]

**Lean-Bündel:** `ChannelSeven71OpenFiberStatus` / `ChannelSeven71Step5BranchingCascade`  
**Erreichbar:** `reachable_channel_seven71_step5_branching_cascade`, `reachable_channel_seven_mod512_step5_cascade`

**Build (lokal):** `lake build KeplerHurwitz.CollatzProofAttemptV213`

---

## V2.14 — Algebraische Lift-Geometrie (`243r + 95`)

**Identifier:** `collatz-channel-7-deep-lift-v2.14`  
**Modul:** `KeplerHurwitz/Collatz/ChannelSevenDeepLiftV214.lean`  
**Layer:** `[A]` Ebene A (Generator, Ziel: allgemeine `j`); `[C]` Ebene B (Dynamik nach `S⁵`)

### Zwei Ebenen (strikt entkoppelt)

\[
\boxed{
\text{2-adische Struktur}
\;\neq\;
\text{dynamischer Deszent}
}
\]

\[
\boxed{
2^j \mid 243\rho_j + 95
\;\;\text{(Generator-Invariante — nicht}\;
\nu_2 = j\text{)}
}
\]

| Ebene | Bezeichnung | Gegenstand | Collatz-Bezug |
|---|---|---|---|
| **A** | Algebraische Lift-Geometrie | \(243r + 95 \equiv 0 \pmod{2^j}\) | **keiner** — eigenständige lineare 2-adische Arithmetik |
| **B** | Dynamische Iteration | Verhalten von \(S^5 = 243t + c_j\) und Folgeschritten | eigentliches Collatz-Problem |

**Ebene A** umfasst insbesondere:

- Existenz und Eindeutigkeit der Restklasse modulo \(2^j\)
- Eindeutiger **2-adischer Lift** der linearen Kongruenz (nicht allgemeine Hensel-Geometrie: \(243r + 95\) ist **linear**, \(243\) ist modulo jeder Zweierpotenz invertierbar)
- Explizite Lift-Residuen \(\rho_j\) und Quotienten \(c_j\)
- Charakterisierung der Bewertungen \(\nu_2(243r + 95)\)

**Ebene B** beginnt erst, wenn

\[
S^5 = 243t + c_j
\]

feststeht. Dann folgen Fragen zu Rang, Faserrückführung, Netto-Deszent und neuen tiefen Ästen — **ohne** Deduktion aus dem Lift allein.

### Leitformel

\[
\boxed{
\text{Bewertungskaskade vollständig klassifizieren}
\;\neq\;
\text{dynamischen Lift-Baum schließen}
}
\]

Diese Formel verhindert den Fehlschluss

> vollständige 2-adische Analyse \(\Rightarrow\) Collatz gelöst.

Was algebraische Resultate **leisten**: Die **Bewertungskaskade** wird zu einem vollständig beschriebenen 2-adischen Objekt. Ob daraus der **dynamische Lift-Baum** kontrollierbar wird, ist die offene Forschungsfrage (H6–H8) und muss getrennt bewiesen werden.

### Kernbeitrag: H5-Generator (Parameter `j`)

Der eigentliche Beitrag von V2.14 ist nicht eine Fallliste `j = 1, 2, 3, …`, sondern die Konstruktion

```lean
deepLiftResidue j   -- ρ_j
deepLiftConstant j  -- c_j
```

als **allgemeine Parameterisierung**: künftig ist `j` nur noch ein Argument, nicht ein neuer Datei-Fall.

**Zieltheorem (Ebene A, für beliebiges `j`) — korrekte Spezifikation:**

\[
\rho_j < 2^j,\qquad 2^j \mid 243\rho_j + 95.
\]

**Kongruenz-Äquivalenz (bewiesen):** `deepLiftResidue_iff` — \(2^j \mid 243r + 95 \iff r \equiv \rho_j \pmod{2^j}\).

**Schichtdiagramm (V2.14):**

```text
Ebene A — drei getrennte Schichten
┌─────────────────────────────────────────────────────────────┐
│ 1. Modular sieve   deepLiftResidue_iff                      │
│    2^j | 243r+95  ↔  r ≡ ρ_j (mod 2^j)          [H1 DONE] │
├─────────────────────────────────────────────────────────────┤
│ 2. Valuation scale pow_dvd_iff_le_padicValNat, step5Kick_padicVal       │
│    2^j | m  ↔  j ≤ ν_2(m)                       [H2 DONE] │
│    ν_2 = j  ↔  r ≡ ρ_j ∧ r ≢ ρ_{j+1} (mod 2^{j+1})         │
├─────────────────────────────────────────────────────────────┤
│ 3. Terminal oddCore (nur bei exakter Valuation j)           │
│    deepLift_affine_factorization; odd_of_exact_padicVal     │
│    oddCore(m) = 243t + c_j  wenn ν_2(m)=j         [H4 DONE] │
└─────────────────────────────────────────────────────────────┘
```

**Bewertungscharakterisierung (bewiesen):** `nu2_deepBranch_ge_iff`, `nu2_deepBranch_eq_iff`.

\[
\nu_2(243r + 95) \ge j
\iff
r \equiv \rho_j \pmod{2^j},
\]

\[
\nu_2(243r + 95) = j
\iff
r \equiv \rho_j \pmod{2^j}
\;\text{und}\;
r \not\equiv \rho_{j+1} \pmod{2^{j+1}}.
\]

**Wichtig:** Die Generator-Invariante ist **Teilbarkeit**, nicht `ν_2(243·ρ_j + 95) = j`.
Plateau-Beispiel: `ρ_5 = 27`, aber `ν_2(243·27 + 95) = ν_2(6656) = 9`.

**Repository-Stand:** Generator implementiert; `243` invertierbar mod `2^j` maschinell verifiziert; Schalen `j = 1,…,5` per `decide`/`interval_cases` verifiziert. **H1 geschlossen:** `deepLiftResidue_spec`, `deepLiftResidue_unique`, `deepLiftResidue_iff`, `existsUnique_deepLiftResidue`. **H2/H4 geschlossen:** `pow_dvd_iff_le_padicValNat`, `step5Kick_padicVal`, `nu2_deepBranch_ge_iff`, `nu2_deepBranch_eq_iff`, `deepLift_affine_factorization`, `odd_of_exact_padicVal`, `deepLift_terminal_of_exactVal`, `deepLift_terminal_next_lift_fails`. Python: `verify_padic_bridge_and_offsets`.

### Angriffshypothesen (H1–H8)

**`[A]` — Ebene A, formal angreifbar**

| ID | Aussage | Lean-Ziel |
|---|---|---|
| H1 | Eindeutige Lift-Kette \(\rho_{j+1} \equiv \rho_j \pmod{2^j}\); \(2^j \mid 243\rho_j + 95\) | `existsUnique_deepLiftResidue` (**bewiesen**); `deepLiftResidue_spec` (**bewiesen**: Bound + Teilbarkeit); `deepLiftResidue_unique`; `deepLiftResidue_iff` |
| H2 | Bewertungsschalen (≥ und = mit Plateau-Ausschluss) | `nu2_deepBranch_ge_iff`; `nu2_deepBranch_eq_iff` (**bewiesen**) |
| H4 | Affine Terminalform \(243r + 95 = 2^j(243t + c_j)\) bei \(r = \rho_j + 2^j t\); `oddCore` bei exakter Val | `deepLift_terminal_affine`; `deepLift_terminal_of_exactVal` (**bewiesen**) |
| H5 | Generator `deepLiftResidue` / `deepLiftConstant` | `ChannelSevenDeepLiftScaffold`; `deepBranchMultiplier_coprime_pow_two` |

**`[B]` — Ebene B, rechnerisch**

- Restklassen von \(243t + c_j\) modulo \(3 \cdot 2^m\), \(12 \cdot 2^m\), \(128 \cdot 3\)
- Rückkehrzeiten in bekannte Fasern \(\{55, 87, 119\}\)
- Endlicher Zustandsgraph modulo \(M\)
- \(\rho_j, c_j\) als Präfixe von \(\rho_\infty \in \mathbb{Z}_2\)

**`[C]` — Ebene B, Forschungshypothesen**

- Parametrischer Deszentszeugen pro Lift-Schale (H6)
- Endliche Typenreduktion der Terminalfamilien (H7)
- Geometrische Dünheit der Schalen \(\neq\) dynamische Irrelevanz (H3)

### 2-adischer Lift (präzise Formulierung)

Die Folge der Restklassen entsteht als **eindeutiger 2-adischer Lift** der linearen Kongruenz

\[
243r + 95 \equiv 0 \pmod{2^j},
\]

da \(243\) modulo jeder Zweierpotenz invertierbar ist. Rekursive Konstruktion im Generator (mit `q_j = (243·ρ_j + 95) / 2^j`, Lift-Bit `b ≡ q_j (mod 2)`):

```text
ρ_{j+1} = ρ_j + b·2^j     b = 0 wenn q_j gerade, b = 1 wenn q_j ungerade
c_j = (243·ρ_j + 95) / 2^j
```

**Governance:** `2^j ∣ 243·ρ_j + 95` — **nicht** `ν_2(243·ρ_j + 95) = j`. Plateaus sind erlaubt.

Erste Werte (`decide`-verifiziert, Stichprobe für den Generator):

| `j` | `ρ_j` | `c_j` | `ν_2(243·ρ_j + 95)` |
|---|---|---|---|
| 1 | 1 | 169 | 1 |
| 2 | 3 | 206 | 3 |
| 3 | 3 | 103 | 3 |
| 4 | 11 | 173 | 4 |
| 5 | 27 | 208 | **9** (Plateau bis `j = 9`) |

**Lean-Bündel:** `ChannelSevenDeepLiftScaffold` / `channel_seven_deep_lift_scaffold`  
**Build:** `lake build KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214`

> **Status von V2.14**
>
> V2.14 etabliert die parameterische Lift-Infrastruktur für Ebene A im tiefen Zweig `k ≡ 1 (mod 4)`. Generator, Invertierbarkeit von `243` mod `2^j`, Eindeutigkeitslemma und Schalen `j ≤ 5` sind maschinell verifiziert. **H1–H2/H4 (modulares Sieb, padicVal-Brücke, affine Terminalform, oddCore bei exakter Valuation) sind geschlossen.** Ebene B (Dynamik nach `S⁵ = 243t + c_j`) bleibt ausdrücklich offen. Ein algebraischer Abschluss von Ebene A impliziert weder Kanal-7-Schließung noch globales Collatz.

---

## Kanal-7-Kern — `ChannelSevenKernel` (V2.10–V2.13 konsolidiert)

**Identifier:** `collatz-channel-seven-kernel`  
**Modul:** `KeplerHurwitz/Collatz/ChannelSevenKernel.lean`  
**Status-Bündel:** `ChannelSevenKernelStatus` / `collatz_proof_attempt_status_v213`

### Inhalt

| Komponente | Inhalt | Status |
|---|---|---|
| Affine Progressionen | `{55, 87, 119} mod 128`, Tiefe-3-Abstieg | `[A]` |
| Parametrisches Schema | `ParametricUniformDescentCertificate` | `[A]` |
| Offene Faser `71` | Kurzpräfix `[1,1,2,2]`, Nicht-Abstieg bis Tiefe 4 | `[A]` |
| mod-256-Split | `256q+71` / `256q+199` ab Schritt 5 | `[A]` |
| Operator-Brücke | `syracuseOddStep = oddCoreStep` | `[A]` |
| Schalenbrücke | `eSchalenSprung (128k+r) = 1` für `r % 8 = 7` | `[A]` |

### Anschlüsse an andere Zahlentheorie-Linien

| Linie | Lean-Modul | Anschluss | Status |
|---|---|---|---|
| 2-adische Valuation | `Nu2Bounds`, `SchalenDynamik` | `eSchalenSprung m = ν₂(3m+1)`; Kanal-7-Eingang hat stets `ν₂=1` | `[A]` direkt |
| Odd-Core-Dynamik | `OddCoreDynamics`, `Octonion/Definitions` | `syracuseOddStep = oddCoreStep`; Division `3m+1 = 2^ν · q` | `[A]` direkt |
| mod-8-Restklassen | `ResidueFilters`, `HalesTaoIntegration` | Kanal-7-Fasern ⊆ Tao-Seed `odd_mod8_cases` | `[A]` direkt |
| 2-adische Tiefenextraktion | V2.4–V2.5, `ChannelSevenAttackV213` | mod-256-Lift bei `71`; `ν₂`-Verzweigung Schritt 5 | `[A]` scaffold |
| CEAB-Spiegel / Chiralität | `OctonionicChiralDiagnostic`, `PrimvierlingSymmetry` | Kanal 3↔7, strukturelle Spiegelung | `[B]`/`[C]` |
| EABC mod-6 | `EabcSixStateMod6` | mod-6-Klassifikation schwächer als mod-8; keine Deduktion | `[C]` |
| Dedekind-Ideal / Primvierling | `DedekindIdealLayer` | Chiralitäts-Parallelität, kein Collatz-Pfad | `[C]` |

### Governance (Kern)

\[
\boxed{\text{geschlossene Progressionen } \{55,87,119\} \neq \text{offener Deep-Tail } 71 \neq \text{Kanal 7} \neq \text{global}}
\]

\[
\boxed{\text{ParametricUniformDescentCertificate} = \text{wiederverwendbares Schema, kein universeller Algorithmus}}
\]

**Erreichbare Theoreme:** `reachable_channel_seven_kernel_status`, `reachable_channel_seven_mod256_split_71` in `ReachableTheorems.lean`.

**Build (lokal):** `lake build KeplerHurwitz.Core` (8631 jobs, sorry-frei für `[A]`-Block)
