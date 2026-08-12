---
title: EABC ↔ Wong Functional Information Bridge
date: 2026-07-22
status: "specification CLOSED & ACTIVE — snapshot eabc-functional-info-v0.1 frozen; physical claim freeze not granted"
evidence_id: E-112
orq_id: ORQ-112
specification_seal: "2026-07-22"
snapshot_freeze: "eabc-functional-info-v0.1"
snapshot_freeze_date: "2026-07-26"
claim_boundary: >-
  Partition und Zwei-Quadrate-Zulässigkeit für ungerade Primzahlen sind [A]
  (Lean EABC/Basic, PrimeTower; Doku eabc_prime_tower_bridge). Relative
  Modellgröße I_{Q₀} unter gewähltem Nullmodell-Prior und Wong-Mapping sind
  [B/C]/[D]-Interpretation. ORQ-112 untersucht ob/wie Q*/Divergenzen trennen —
  ohne Existenz-/Eindeutigkeitsanspruch; kein Evolutionsgesetz, keine Physik-Kausalität.
not_claimed:
  - Wong-Mapping beweist Physik oder EABC-Dynamik
  - I_{Q₀}(E_x) ∈ {1,2} Bits ist Naturgesetz, adäquate NT-Eigenschaft oder Physikquant
  - Eine feste Divergenz (KL/JS/…) ist kanonisch ausgezeichnet
  - Spaltung / Partition impliziert Leitfähigkeit oder thermodynamische Entropieproduktion
  - Identifikation thermodynamischer Entropie S mit funktionaler Information
---

> **Evidence status:** Spezifikation **CLOSED & ACTIVE** (methodische Schicht) · Physik-Claim-Freeze **not granted** · ORQ-112 bleibt `[C]` offen  
> **Snapshot freeze:** `eabc-functional-info-v0.1` (2026-07-26) — methodischer Stand; **≠** Physik-Freeze  
> **Governance-Vorbild:** Tier-Trennung analog Bamberg/E-076/E-089 — Arithmetik ≠ Transport ≠ Interpretation  
> **Verwandt:** [`eabc_prime_tower_bridge.md`](../eabc_prime_tower_bridge.md), `KeplerHurwitz/EABC/Basic.lean`, E-076, ORQ-089  
> **Freeze-Report:** [`eabc_wong_functional_info_v0.1_freeze.md`](../reports/eabc_wong_functional_info_v0.1_freeze.md) · Manifest [`eabc_wong_functional_info_v0.1_freeze.json`](../exports/eabc_wong_functional_info_v0.1_freeze.json)

# E-112 / ORQ-112: EABC als Entropiefilter und Wong-Funktionale-Information

**Stand:** 26. Juli 2026 (Snapshot v0.1 eingefroren; Claim-Wall sealed 2026-07-22)  
**Branch-Kontext:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku-Spezifikation — methodisch geschlossen & aktiv; **kein** Physik-Freeze  
**Alias „PROTOCOL.md“:** dieses Dokument = Claim-Wall-Protokoll für E-112 (kein separates `PROTOCOL.md`)

```text
E-112 / ORQ-112: specification CLOSED & ACTIVE (methodische Schicht)
Physical claim freeze: not granted
Wong–eabc bridge: claim-wall sealed 2026-07-22
Snapshot freeze: eabc-functional-info-v0.1 (2026-07-26)
v0.2 TUR/BC: pending / not started
```
---

## Governance-Registratur (Slot E-112 / ORQ-112)

```text
┌── Slot E-112 / ORQ-112 ──────────────────────────────────────────┐
│ Spezifikation (CLOSED & ACTIVE)                                  │
│   docs/energiedoku_exports/eabc_wong_functional_information_     │
│     bridge.md                                                    │
│ Evidence                                                         │
│   EVIDENCE_REGISTER.md / EVIDENCE_REGISTER.json  → E-112         │
│   docs/open_research_questions.md                → ORQ-112       │
│ Code / Tests                                                     │
│   src/kepler_hurwitz/prime_tower_bridge.py                       │
│     (Q0_UNIFORM, functional_information_bits(..., q0=...))       │
│   tests/test_prime_tower_bridge.py                               │
│     ::TestFunctionalInformationBits                              │
│ Glossar                                                          │
│   experimental/.../DISCRETE_ANALOGY_GLOSSARY.md                  │
│   experimental/.../DiscreteAnalogyGlossary.lean                  │
│     (FunktionaleInformation_WongFilter_E112)                     │
│ Physik-Claim-Freeze: NOT GRANTED                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## Finale Claim-Wall (versiegelt)

1. **[A]** Disjunkt \(\Omega = E \cup A \cup B \cup C\). Äquivalenz \(p = x^2+y^2 \Longleftrightarrow p \in E\cup A\) für ungerade Primzahlen (Primzahl-Turm). Explizit: „beide Quadrate in E“ ist **kein** belastbarer Primzahl-Satz.
2. **[B/C]** Unter dem Referenzprior \(Q_0=\tfrac14\) ergibt die **Modellgröße** \(I_{Q_0}(E_x)=-\log_2 F(E_x)\) für die betrachteten Ereignisse die Werte 1 Bit (E∪A) bzw. 2 Bit (nur E) — nicht intrinsische Primzahl-Information.
3. **[C]** ORQ-112 untersucht, ob und wie geeignete \(Q^*\)/Divergenzen trennen können — **ohne** Existenz-/Eindeutigkeitsanspruch; **freeze not granted**.
4. **[D]** Wong-Ordnungen / thermodynamische Analoge = Lesesprache/Heuristik (außerhalb der Beweis-/Evidenzkette).

### Gesamtbild

| Ebene | Rolle |
|---|---|
| **[A]** | beweisbar (Partition, Zwei-Quadrate) |
| **[B/C]** | definierte Modellgrößen / Audits unter \(Q_0\) |
| **[C]** | offene ORQ (Trennung vs. Nullmodelle; kein Optimalitätsclaim) |
| **[D]** | Interpretation außerhalb Beweis-/Evidenzebene |

---

## 0. Vier-Ebenen-Architektur

```text
┌─────────────────────────────────────────────────────────────────┐
│  [A] Formale Mathematik                                         │
│      Partition Ω = E∪A∪B∪C; Zwei-Quadrate ↔ E∪A (ungerade p)   │
├─────────────────────────────────────────────────────────────────┤
│  [B/C] Informationstheoretisches Audit (prior-abhängig)         │
│      I_{Q₀}(E_x) = −log₂[F(E_x)] = D_KL(P ∥ Q₀)                │
│      Q₀ = Uniform (1/4)^4 als transparenter Modellparameter     │
├─────────────────────────────────────────────────────────────────┤
│  [C] ORQ-112 — ob/wie Q*/Divergenz trennt (kein Existenzclaim)  │
│      Kandidaten: D_KL, D_JS, Rényi/Tsallis, Wasserstein/OT      │
├─────────────────────────────────────────────────────────────────┤
│  [D] Wong-Mapping / Heuristik (außerhalb Evidenzkette)          │
│      1./2./3. Selektionsordnung als Lesesprache — keine Physik  │
└─────────────────────────────────────────────────────────────────┘
```

\[
\boxed{
\begin{aligned}
&\text{[A] Partition + Zwei-Quadrate} \\
&\quad\neq\quad
\text{[B/C] Modellgröße } I_{Q_0} \\
&\quad\neq\quad
\text{[C] ORQ-112 (ob/wie }Q^*\text{/Divergenz)} \\
&\quad\neq\quad
\text{[D] Wong-Heuristik} \\
&\quad\neq\quad
\text{bewiesene Evolution / Thermodynamik}
\end{aligned}
}
\]

| Schicht | Inhalt dieser Brücke | Status |
|---|---|---|
| **[A]** | Disjunkte EABC-Klassen; ungerade Primzahl \(=x^2+y^2\) \(\Leftrightarrow\) Klasse in E∪A | Lean + klassische NT |
| **[B/C]** | Modellgröße \(I_{Q_0}=-\log_2 F\) unter dokumentiertem Prior (Werte 1 bzw. 2 Bit für die betrachteten Ereignisse) | Hilfsfunktion; kein Physik-Export |
| **[C]** | ORQ-112: ob/wie \(Q^*\) bzw. Divergenzen trennen — ohne Optimalitätsanspruch | offen, freeze **not** granted |
| **[D]** | Wong drei Selektionsordnungen; phys. Analogien | Analogie only |

**Explizit ausgeschlossen** (analog „Spaltung \(\not\Rightarrow\) Leitfähigkeit“):

- Partition E/A/B/C \(\not\Rightarrow\) Leitfähigkeit, Phasenübergang oder Entropieproduktion
- Zwei-Quadrate-Zulässigkeit \(\not\Rightarrow\) thermodynamische Entropie \(S\)
- \(I_{Q_0}\) \(\not\Rightarrow\) intrinsische Eigenschaft der Zahlentheorie (ohne Prior)
- Wong-Mapping \(\not\Rightarrow\) Formal-Core-Theorem oder Collatz-/Physikbeweis

---

## 1. Partitionierungstheorem als Entropiefilter `[A]` + Audit `[B/C]`

### 1.1 Trägerpartition `[A]`

Für ungerade natürliche Zahlen (Mod-8-Schicht in `EABC/Basic.lean`):

\[
\Omega_{\mathrm{odd}} \;=\; E \cup A \cup B \cup C
\quad\text{(paarweise disjunkt)},
\]

mit \(E\equiv 1\), \(A\equiv 5\), \(B\equiv 3\), \(C\equiv 7\pmod 8\).

**Namenshinweis:** Die Massen-/Kanal-Konvention (`eabc_mass_convention.md`, `eabc_channel_from_mod12`) nutzt Mod-12-Reste \(\{1,5,7,11\}\). Beide Schichten teilen die Zwei-Quadrate-Grenze \(p\equiv 1\pmod 4\) (E∪A) vs. \(p\equiv 3\pmod 4\) (B∪C), sind aber **nicht** mengenidentisch — siehe [`eabc_prime_tower_bridge.md`](../eabc_prime_tower_bridge.md) §1.2.

Quellen `[A]`:

- `KeplerHurwitz/EABC/Basic.lean` — `EABCClass`, `classify`, `odd_prime_sum_of_two_squares_iff_EA`
- `KeplerHurwitz/EABC/PrimeTower.lean` — Turm-Wörterbuch / `channelEA_sum_of_two_squares`
- Docs: `docs/eabc_prime_tower_bridge.md`

### 1.2 Summe zweier Quadrate `[A]`

**Klassischer Fermat-/Christmas-Satz** (im Repo formalisiert für ungerade Primzahlen):

\[
p\text{ ungerade Primzahl:}
\quad
p=x^2+y^2
\;\Longleftrightarrow\;
p\in E\cup A
\;\Longleftrightarrow\;
p\equiv 1\pmod 4.
\]

Damit:

| Menge | Zwei Quadrate (ungerade Primzahl) |
|---|---|
| \(\omega\in E\cup A\) | **zulässig** |
| \(\omega\in B\cup C\) | **verboten** |

**Korrektur zur Entwurfsskizze „\(x,y\in E\)“:**  
Das Prädikat `IsSumOfTwoSquaresInE` (beide Quadrate in Klasse E) erzwingt \(n\equiv 2\pmod 8\) und trifft **keine** ungerade Primzahl (`Basic.lean`, Kommentar zu `IsSumOfTwoSquaresInE`). Die belastbare `[A]`-Aussage ist die **klassische** Summe zweier Quadrate ohne E-Beschränkung der Summanden — Alias `sum_of_squares_restricted` / `odd_prime_sum_of_two_squares_iff_EA`.

### 1.3 Relative funktionale Information \(I_{Q_0}\) `[B/C]`

**Annahme (Modellparameter, nicht zahlentheoretisch deduziert):** Referenzprior \(Q_0(\omega)=\tfrac14\) auf \(\{E,A,B,C\}\).

Unter diesem Referenzprior ergibt die **definierte Modellgröße**

\[
I_{Q_0}(E_x)
\;=\;
-\log_2\bigl[F(E_x)\bigr]
\;=\;
D_{\mathrm{KL}}(P\,\|\,Q_0)
\]

(mit \(F(E_x)=Q_0(E_x)\) der Prior-Masse der Selektion und \(P\) der auf \(E_x\) eingeschränkten, renormalisierten Verteilung)
für die betrachteten Ereignisse die Werte **1 Bit** bzw. **2 Bit**. Die Zahlen beziehen sich auf diese Modellgröße — **nicht** auf intrinsische Information der Primzahlen.

\(Q_0\) ist der natürliche **ungeprägte** Referenzzustand unter Dirichlet-/Restklassen-Gleichverteilung. Ein anderer Prior \(Q^*\) (z. B. Chebotarev-gewichtet) verschiebt die Modellwerte — ohne die `[A]`-Partition zu ändern.

| Selektion \(E_x\) | \(F=Q_0(E_x)\) | Modellwert \(I_{Q_0}(E_x)\) |
|---|---|---|
| E∪A (Quadrate möglich) | \(\tfrac12\) | **1 Bit** |
| reine Klasse (nur E) | \(\tfrac14\) | **2 Bit** |

**Lesart `[C]`/`[D]`:** Die Modellwerte unter **diesem** \(Q_0\) können als relative funktionale Information **gelesen** werden — nicht als bewiesenes Physikgesetz und nicht als Lean-Theorem.

Python (reine Info-Arithmetik; Default-Prior-Label `q0="uniform"`):

```python
from kepler_hurwitz.prime_tower_bridge import functional_information_bits
functional_information_bits(0.5)                 # I_{Q0}=1.0
functional_information_bits(0.25, q0="uniform")  # I_{Q0}=2.0
```

---

## 2. Abbildung auf drei Selektionsordnungen (Wong) `[D]`

```text
(E∪A): Quadrate möglich     →  1. Ordnung  (Statische Persistenz)
(B∪C): Quadrate verboten    →  2. Ordnung  (Dynamische Persistenz)
Wechselwirkung (E,A)↔(B,C)  →  3. Ordnung  (Neuartigkeit)
```

| Wong-Ordnung | EABC-Slot | Analogie `[D]` (nicht Identität) |
|---|---|---|
| 1. Statische Persistenz | E∪A, Zwei-Quadrate-Kanal | „Struktur bleibt darstellbar / zerlegbar“ |
| 2. Dynamische Persistenz | B∪C, inert / keine Zwei-Quadrate | „Struktur hält sich durch Ausschluss / Trägheit“ |
| 3. Neuartigkeit | Wechselwirkung zwischen den Blöcken | „Innovation an der Blockgrenze“ |

**Verboten:** Gleichsetzung mit thermodynamischer Entropieproduktion, QHE-Leitfähigkeit, BCS/Cooper-Paaren oder evolutionsbiologischer Fitness — alles höchstens Resonanzsprache (vgl. E-076, ORQ-089).

Glossar-Slot: `FunktionaleInformation_WongFilter` in
`experimental/dimensional_sombrero_hurwitz/DISCRETE_ANALOGY_GLOSSARY.md`.

---

## 3. Konsequenz für #Energiedoku — ORQ-112 `[C]`

### 3.1 Thermodynamische Entropie \(S\) vs. relative Information

| Größe | Rolle hier |
|---|---|
| Thermodynamische Entropie \(S\) | **nicht** mit \(I_{Q_0}\) identifiziert |
| Relative Information \(I_{Q_0}\) | Audit relativ zum Prior \(Q_0\) (Nullmodell) |
| EABC-Gitter | **topologischer / arithmetischer Filter** der zulässigen Konfigurationen |

### 3.2 Open Research Question (metrikfrei)

**ORQ-112 (überarbeitet):**

> ORQ-112 untersucht, ob und wie geeignete Referenzverteilungen \(Q^*\)
> bzw. Divergenzmaße die beobachteten EABC-Verteilungen gegenüber
> Nullmodellen trennen können — **ohne** Existenz- oder Eindeutigkeitsanspruch
> für eine „optimale“ \(Q^*\).

| Feld | Wert |
|---|---|
| Status | **offen** / `[C]` |
| Freeze | **not granted** |
| Kein Claim | keine Existenz/Eindeutigkeit von \(Q^*\); kein Evolutionsgesetz; keine Physik-Kausalität |
| Methodischer Gewinn | Forschungsfrage ist **nicht** auf \(D_{\mathrm{KL}}\) festgelegt |

**Warum metrikfrei?** \(D_{\mathrm{KL}}(P\|Q)\) setzt absolute Stetigkeit \(P\ll Q\) voraus; Nullstellen in der Referenzdichte treiben \(D_{\mathrm{KL}}\to+\infty\). Deshalb bleibt die Wahl des Trennmaßes offen für unter anderem:

- Jensen–Shannon \(D_{\mathrm{JS}}\) (symmetrisch, beschränkt)
- Rényi- / Tsallis-Divergenzen
- Wasserstein / Optimal Transport

\(D_{\mathrm{KL}}\) bleibt ein **Kandidat** (und die Identität \(I_{Q_0}=-\log_2 F=D_{\mathrm{KL}}(P\|Q_0)\) gilt im Audit unter dem gewählten \(Q_0\)), aber **kein** eingefrorenes Evolutionsprinzip.

---

## 4. Tier-Governance (Analog zu Frobenius-/Bamberg-Trennung)

| Tier | Erlaubt | Verboten |
|---|---|---|
| **[A] Arithmetik** | E/A/B/C-Partition; Fermat Zwei-Quadrate für ungerade Primzahlen | „Bits beweisen Physik“ |
| **[B/C] Info-Audit** | \(I_{Q_0}\) unter dokumentiertem Prior; reproduzierbare Bit-Rechnung | Prior weglassen / als NT-Theorem verkaufen |
| **[C] ORQ-112** | Ob/wie \(Q^*\) bzw. Divergenzen trennen | Existenz/Eindeutigkeit „optimaler“ \(Q^*\); Freeze als Gesetz |
| **[D] Analogie** | Wong-Ordnungen; Persistenz-/Neuartigkeit-Metaphern | Kausalitätsbehauptungen |

Hinweis: Die Datei `eabc_frobenius_tier_governance.md` ist im Workspace nicht als kanonischer Pfad vorhanden; die Trennung folgt dem gleichen Muster wie Bamberg-Protokolle (E-110/E-111) und E-076/E-089 Claim-Walls.

---

## 5. Prüfmodus (minimal)

```bash
pytest tests/test_prime_tower_bridge.py -q
# optional isoliert:
pytest tests/test_prime_tower_bridge.py::TestFunctionalInformationBits -q
```

**Nicht** starten / nicht anfassen: E-110b/E-110c-Preregistration-Fits, `mollweide-e8-world-v1`-Freeze, `e8_kwant_transport`-Freeze-Status.

---

## 6. Ablehnungssatz (Archivgrenze)

\[
\boxed{
\text{Wong-Mapping, } I_{Q_0}\text{ und ORQ-112 sind}
\textbf{ nicht }
\text{als bewiesene Physik archiviert.}
}
\]

---

## 7. Fazit — Schutzschild gegen Kategoriefehler

Diese Brücke ist eine **saubere methodische Schicht**: `[A]` trägt die Arithmetik; `[B/C]` misst relative Information nur relativ zu einem transparenten Prior \(Q_0\); `[C]` hält die Suche nach \(Q^*\) und Divergenzmaß offen; `[D]` bleibt Heuristik. Damit wird spekulativer Beweisanspruch blockiert — weder Zahlentheorie „besitzt“ Bits absolut, noch folgt aus der Partition Physik oder Evolution.

**Versiegelung:** Spezifikation E-112 / ORQ-112 = `CLOSED & ACTIVE` (methodisch). Physical claim freeze = **not granted**. Claim-Wall sealed `2026-07-22`.  
**Snapshot v0.1:** `eabc-functional-info-v0.1` eingefroren `2026-07-26` — bereit für TUR/v0.2-Spezifikation (ohne Physik-Claim).

---

## 8. Snapshot Freeze v0.1 (`eabc-functional-info-v0.1`)

| Feld | Wert |
|---|---|
| Freeze-ID | `eabc-functional-info-v0.1` |
| Datum | 2026-07-26 |
| Spezifikation | CLOSED & ACTIVE |
| Physical claim freeze | **not granted** |
| Tests | `pytest tests/test_prime_tower_bridge.py` — 13 passed (Referenz 11/11 am Claim-Wall-Seal) |
| Report | [`docs/reports/eabc_wong_functional_info_v0.1_freeze.md`](../reports/eabc_wong_functional_info_v0.1_freeze.md) |
| Manifest | [`docs/exports/eabc_wong_functional_info_v0.1_freeze.json`](../exports/eabc_wong_functional_info_v0.1_freeze.json) |

Signal: **v0.1 Snapshot eingefroren — bereit für TUR/v0.2** (Implementierung separat; hier nur Fahrplan).

---

## 9. Fahrplan v0.2 — TUR für \(BC\)-Ströme (Spezifikation only)

| Feld | Wert |
|---|---|
| Status | **pending / not started** |
| Prerequisite | Freeze v0.1 |
| Implementierung in diesem Freeze | **nein** |

1. **Strom-Definition \(J_{BC}\):** gerichteter Netto-Fluss aus Übergangsraten zwischen den Klassen \(B\) und \(C\).
2. **TUR-Ungleichung (Audit-Proxy, kein Physikgesetz):**
   \[
   \mathcal{Q}
   \;=\;
   \frac{\sigma_{J_{BC}}^{2}}{\langle J_{BC}\rangle^{2}}
   \;\ge\;
   \frac{2}{S_{BC}}
   \]
3. **Testsuite:** Parameter-Sweeps \((\theta,\varphi)\).

**Nicht behauptet:** Identität von \(S_{BC}\) mit thermodynamischer Entropie; TUR als Naturgesetz; Kausalität aus der EABC-Partition.