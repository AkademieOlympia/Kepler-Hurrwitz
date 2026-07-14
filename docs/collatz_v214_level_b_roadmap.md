# Collatz V2.15 — Ebene B Roadmap (Dynamik nach `S⁵ = 243t + c_j`)

**Identifier:** `collatz-channel-7-dynamics-v2.15`  
**Vorgänger:** [`collatz_v27_net_descent.md`](collatz_v27_net_descent.md) V2.14 (Ebene A versiegelt)  
**Lean:** `KeplerHurwitz/Collatz/ChannelSevenAffineMod128V215.lean` (H7-A) · `ChannelSevenDynamicsV215.lean` · `ChannelSevenDynamicsHypothesesV215.lean` (H7-C) (`[A]`, H7-A sorry-frei)  
**Dynamik-Hypothesen:** `KeplerHurwitz/Collatz/ChannelSevenDynamicsHypothesesV215.lean` (`[C]`)  
**Witness `[B]`:** `src/kepler_hurwitz/h7_witness_matrix.py`

---

## Governance (unverrückbar)

\[
\boxed{\text{2-adische Struktur} \;\neq\; \text{dynamischer Deszent}}
\]

\[
\boxed{\text{Ebene A versiegelt} \;\neq\; \text{Ebene B geschlossen} \;\neq\; \text{Kanal 7} \;\neq\; \text{globale Collatz-Terminierung}}
\]

| Nicht behaupten | Grund |
|---|---|
| Globale Collatz-Terminierung | außerhalb des Witness-Programms |
| Kanal-7-Schließung | nur Teilmengen formal |
| Ordinaltyp \(\varepsilon_0\) / transfinite Induktion | spekulativ; stattdessen endliche Typenreduktion |
| Lift-Klassifikation ⇒ Netto-Abstieg | Ebene A isoliert |

---

## Ausgangslage (V2.14 sealed)

**Ebene A `[A]` geschlossen** in `ChannelSevenDeepLiftV214.lean` (0 `sorry`):

- Generator `deepLiftResidue j`, `deepLiftConstant j`
- Kongruenz `deepLiftResidue_iff`, Bewertung `nu2_deepBranch_ge_iff` / `nu2_deepBranch_eq_iff`
- Affine Faktorisierung + `oddCore`-Terminal bei exakter Valuation
- Brücke zu V2.13: `channelSeven71_step5_certificate_mod4_one`

**Ebene B `[C]` offen:** Was passiert **nach** der Terminalform

\[
S^5(n) = 243t + c_j
\]

für nichttriviale Lift-Schalen `j`?

---

## Forschungshypothesen (ORQ-Einträge)

### H6 — Normalisierter Schritt `S^ℓ` und Faser `243t + c_j`

**Aussage:** Jede exakte Lift-Schale `(j, c_j)` liefert eine **wohldefinierte affine Terminalfamilie**

\[
\mathcal{F}_{j} := \{ 243t + c_j \mid t \in \mathbb{N},\;
\nu_2(243(\rho_j + 2^j t) + 95) = j \}.
\]

**Ziel-Lemmata (priorisiert):**

| Prio | Lemma | Status |
|---|---|---|
| P0 | `deepLiftFiber` / `deepBranchParam` Definitionen | V2.15 scaffold |
| P0 | `deepLiftFiber_odd_of_exactVal` — Terminal ungerade | V2.15 |
| P0 | `deepLiftFiber_residue_mod` — Restklassen-Split modulo `2^m` | V2.15 (Teil) |
| P1 | `channelSeven71_step5_eq_deepLiftFiber_j3` — V2.13-Zweig `k≡1(mod 4)` bei exakt `j=3` | V2.15 |
| P1 | `deepLiftFiber_small_t_decide` — `t ∈ {0,1,2}` für `j ≤ 5` | V2.15 + `[B]` |
| P2 | Uniforme `S^ℓ`-Form auf `\mathcal{F}_j` für kleines `\ell` | offen |
| P2 | Valuationswort nach Terminalform (Schritt 6+) | V2.15 Schritt-6-Verzweigung (`486u+103`) — **`[A]` geschlossen** |
| P2 | Valuationswort Schritt 7 auf `ν₂=1`-Terminal | V2.15 Schritt-7-Verzweigung (`1458v+155`, `ChannelSeven71Step7BranchingV215`) — **`[A]` geschlossen** |

### H7 — Typenreduktion / Zustandsgraph auf affinen Familien

> **Blocker (V2.16, `pr/11-collatz-v27-net-descent`):** Der geplante endliche H7-Zustandsgraph
> (`KeplerHurwitz/Collatz/H7StateGraph.lean` / `H7StateGraphAudit.lean`, Auftrag an einen
> vorherigen Agenten `9d8a4ff2`) ist **nicht** im Repository gelandet — weder als Datei noch
> als Commit (`git log --all --grep="H7 mod-128 state graph"` liefert keinen Treffer). Die
> geplante endliche Erreichbarkeit / exakte residuale Restfront über die kontrollierten Fasern
> `{39,79,95,103}` wurde **nicht neu formalisiert** (kein Wiederholungsversuch von Grund auf).
> Stattdessen wurde in V2.16 nur das bereits vorhandene Material (`ChannelSevenKernel`,
> `ChannelSevenAttackV210–V212`) zu einem einzigen Einstiegspunkt für die sechs bekannten
> mod-128-Klassen `{7,15,23,55,87,119}` zusammengeführt — reine `[A]`-Fallvereinigung, keine
> neue Restklasse. Die H7-C/H8-Hypothesen unten (dynamischer Eintritt, Rang, Assembly) bleiben
> **vollständig offen**; der H7-Zustandsgraph ist weiterhin das empfohlene nächste Ziel.

**H7-A `[A]` geschlossen** in `ChannelSevenAffineMod128V215.lean` (mod-128 affine Bijektion,
`entryParameterMod128`, `deepLiftFiber_entry_spec`, `deepLiftFiberPermutation`;
Nat-Brücke `deepLiftFiber_modEq128_iff` / `deepLiftFiber_mod128_parameter` in `ChannelSevenDynamicsV215.lean`).

**Governance:** \(\boxed{\text{algebraisch parametrisiert} \neq \text{dynamisch erreicht}}\)

**H7-C `[C]` offen** in `ChannelSevenDynamicsHypothesesV215.lean`
(`DeepLiftFiberMod128EntryHypothesis`, kontrollierte Fasern `{39,79,95,103}`).

**Aussage:** Endlicher Graph modulo `M` (z. B. `128`, `256`, `3·2^m`) klassifiziert Übergänge

\[
243t + c_j \;\xrightarrow{\;S\;}\; 243t' + c_{j'}
\]

oder Rückkehr in bekannte geschlossene Fasern `{55, 87, 119}`.

**Ziel-Lemmata:**

| Prio | Lemma | Status |
|---|---|---|
| P0 | `deepLiftAffine_mod128_equiv` — bijektive affine Permutation mod 128 | **V2.15 `[A]` geschlossen** |
| P0 | `deepLiftFiber_modEq128_iff` / `deepLiftFiber_mod128_parameter` | **V2.15 `[A]` geschlossen** |
| P1 | `DeepLiftFiberState` — endlicher Typ `(j, c_j, t mod M)` | Hypothesen-Scaffold |
| P1 | `DeepLiftFiberMod128EntryHypothesis` — dynamischer Eintritt `{39,79,95,103}` | offen (`[C]`, Hypothesen) |
| P2 | Rückkehrzeit in kontrollierten Fasern für `t ≤ T` | `[B]` numerisch (`generate_h7_witness_matrix`) |
| P2 | mod-128-Reduktion der Schritt-7-Terminalfamilien (`50v+27`, `22s+105`, `22w+69`) | **V2.15 `[A]` geschlossen** (`ChannelSeven71Step7BranchingV215`) + `[B]` Histogramm (`scan_step7_kick_on_nu1_terminal`) |
| P2 | Keine unbeschränkte Schleife auf `\mathcal{F}_j` ohne Rang | offen |

### H8 — Deszentszeuge → `BadRunNetDescentWitness`

**Aussage:** Parametrischer Netto-Abstieg auf Deep-Tail-Fasern (z. B. `71 mod 128`, `{39,95,79}`) reduziert auf

\[
\exists\, t_{\mathrm{loc}}:\;
\mathrm{collatzStep}^{[t_{\mathrm{loc}}]}(\mathrm{good}) < n
\]

via bereits geschlossene `[A]`-Reduktion `bad_run_net_descent_witness_mod8_channel_seven_of_local_shrink`.

**Ziel-Lemmata:**

| Prio | Lemma | Status |
|---|---|---|
| P1 | `DeepLiftNetDescentCertificate` — Schema Good-Branch + `t_loc` | scaffold |
| P2 | `deepLiftFiber_net_descent_witness` — uniform für eine Schale `j` | offen (`sorry`) |
| P3 | Assembly → `bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two` | offen |
| — | Global: `bad_run_net_descent_witness_of_mod4_three` | **`[C]`** unverändert |

---

## Konkrete nächste Beweisschritte (priorisiert)

### Sofort (V2.15)

1. **`deepLiftFiber_residue_mod_three`** — `243t + c_j ≡ c_j (mod 3)`; erste Dynamik-Splitting-Invariante
2. **`channelSeven71_step5_deepLiftFiber_j3_even_t`** — exakte Schale `j=3`, gerades `t`: `S^5 = 243t + 103`
3. **`deepLiftFiber_t_zero_values`** — Anker `t=0` für `j ∈ {1,…,5}` per `decide`
4. **`[B]` scan** — `S`, `S²`, `S³` auf `243t + c_j` für `t ≤ 20`, `j ≤ 5`

### Kurzfristig (V2.16)

5. ~~Schritt-6-Zertifikat auf `\mathcal{F}_3`~~ — geschlossen in `ChannelSeven71Step6BranchingV215.lean` (`ν₂ ∈ {1,2,≥3}`)
6. mod-128-Eintritt: wann landet `243t + c_j` in `{55,87,119}`?
7. `{39}`, `{95}` mod-256: formalisieren numerische Witnesses aus `CollatzChannelSeven` (uncommitted)

### Mittelfristig

8. Deep-Tail `{31,47,63,71,103,111}`: parametrischer Satz oder weiterer Lift
9. H8-Brücke für eine Deep-Tail-Restklasse → voller `BadRunNetDescentWitness`

---

## Angriffsvektor (empfohlen)

```text
V2.13 Schritt-5-Verzweigung (k mod 4)
        ↓ exakte Valuation j (V2.14)
Terminalfamilie 243t + c_j
        ↓ S^ℓ-Dynamik (V2.15)
mod-M Zustandsgraph (H7)
        ↓ Rückkehr / Rang R (H6)
DeepLiftNetDescentCertificate (H8)
        ↓ Assembly
BadRunNetDescentWitness (bestehende [A]-Reduktion)
```

**Empfohlenes nächstes Lemma:** `channelSeven71_step5_deepLiftFiber_j3_even_t` — schließt die erste dynamische Brücke zwischen V2.13 (`k≡1 mod 4`) und V2.14 (`243t+c_3`) bei exakter Valuation.

---

## Offene Sorry-Inventar (Collatz-Kern)

| Modul | Sorry | Rolle |
|---|---|---|
| `CollatzProofAttemptV27.lean` | 4 | globaler `[C]`-Kern |
| `CollatzProofAttemptV28.lean` | 2 | Kanal-3/7 Rest |
| `CollatzProofAttemptV29.lean` | 1 | Blocking-Interface |
| `ChannelSevenAffineMod128V215.lean` | **0** | H7-A mod-128 Permutation |
| `ChannelSevenDynamicsV215.lean` | **0** | Ebene B Dynamik `[A]` |
| `ChannelSevenDynamicsHypothesesV215.lean` | 4 | H7-C / H8 Hypothesen |
| `ChannelSeven71Step6BranchingV215.lean` | 0 | Schritt-6-Verzweigung `486u+103` |
| `CollatzChannelSeven.lean` | **0** (2 neue `[A]`-Sätze, V2.16 mechanische Vereinigung `{7,15,23,55,87,119}`) | Formal-Union-Einstiegspunkt |
| `H7StateGraph.lean` / `H7StateGraphAudit.lean` | **fehlt** (nicht gelandet, V2.16-Blocker) | endlicher Zustandsgraph, exakte Restfront |
| Kanal 3 | **FROZEN** | Deep-Tail `{27,91,155,251}` |

---

## Build

```bash
lake build KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215
lake build KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
lake build KeplerHurwitz.Collatz.ChannelSevenDynamicsHypothesesV215
lake build KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
lake build KeplerHurwitz.CollatzProofAttemptV215
```

**Python `[B]`:**

```bash
python -m kepler_hurwitz.h7_witness_matrix  # H7-A witness matrix mod 128
python -m kepler_hurwitz.deep_lift_hensel_diagnostic  # padic bridge
pytest tests/test_deep_lift_hensel_diagnostic.py -q
```
