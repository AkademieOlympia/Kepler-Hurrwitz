---
title: Open Mathematical and Physical Bridge Targets
date: 2026-07-05
status: canonical
evidence_ids:
  - E-053
  - E-076
  - E-077
  - E-078
  - E-079
  - E-080
  - E-081
  - E-082
  - E-083
  - E-084
  - E-085
  - E-087
  - E-088
  - E-089
orq_range: ORQ-077–ORQ-089
claim_boundary: >-
  Physikalische Analogien sind Resonanzsprache [C], kein Beweisweg. Mathematische
  Existenzfragen werden erst hochgestuft, wenn formal definiert, testbar oder bewiesen.
  E-085 bleibt gesperrt bis E-077 intern nachgewiesen ist.
---

> **Kanonisches Dokument** · **ORQ-Index:** [`open_research_questions.md`](open_research_questions.md) · **Register:** [`EVIDENCE_REGISTER.md`](../EVIDENCE_REGISTER.md) E-077–E-085 · **Research Map:** [`research_map.md`](research_map.md)

# Open Mathematical and Physical Bridge Targets

Dieser Abschnitt sammelt offene Zielstrukturen des Kepler–Hurwitz/EABC-Programms. Die Einträge sind bewusst nach Governance-Status getrennt. Physikalische Analogien werden nicht als Beweise behandelt. Mathematische Existenzfragen werden nur dann hochgestuft, wenn sie formal definiert, testbar oder beweisbar sind.

\[
\boxed{
\text{Was ist formal definierbar? Was ist nur Physik-Analogie? Was ist empirisch testbar? Was hängt wovon ab?}
}
\]

Der entscheidende Punkt: Einige Punkte sind echte mathematische Ziele, andere sind physikalische Brückenhypothesen `[C]`, und wieder andere sind diagnostische Existenzfragen `[B]`. Der Durchbruch liegt nicht darin, alle gleichzeitig zu verfolgen, sondern einen schmalen Pfad zu wählen.

---

## Governance-Abhängigkeitstabelle

| Ziel | Formal definierbar | Operationalisierbar `[B]` | Nur motivisch definierbar | Analogie `[C]` | Abhängig von |
|---|---|---|---|---|---|
| **1** `MetricSeparationLossExist` (E-077 / ORQ-077) | ja | ja (Ziel) | nein | nein | E-053 |
| **2** Globale $\mathbb{R}^3$-Einbettung (E-078 / ORQ-078) | ja | ja | nein | nein | E-053 |
| **3** Minkowski–Bouligand-Dimension (E-079 / ORQ-079) | ja | ja | nein | nein | E-078, E-053 |
| **4** Dedekind-Ideal-Brücke $\Phi(v)=\gamma$ (ORQ-085) | ja | ja (mit Guards) | nein | nein | E-067–E-069 |
| **5** Berry-Holonomie (E-083 / ORQ-083) | ja | ja (Potenzial) | nein | teilweise | E-076 |
| **6** `GeometryScaffold` (E-084 / ORQ-084) | ja | ja (algorithmisch) | nein | nein | E-025 |
| **7** Hurwitz-Windungs-Korrespondenz (E-080 / ORQ-080) | nein | ja (nach Index-Def.) | ja | ja | E-076 |
| **8** Dirac–Schwinger / Dipol–Oktupol (E-081, E-082) | nein | bedingt | ja | ja | E-076, E-080 |
| **9** `shellPrimeMatchAtFirstLoss` (E-085 / ORQ-086) | ja | ja (nach Gate) | nein | nein | E-077 |
| **10** Weyl-Kommutator $\Delta_{\mathrm{LR}}$ (ORQ-087) | ja | ja (Stub) | nein | teilweise | ORQ-085, ORQ-083 |
| **11** Onsager Quantization Bridge (ORQ-089) | nein | bedingt | ja | ja | E-076, ORQ-080, ORQ-087 |
| **12** Weyl–Onsager Komplettangriff (E-087, E-088) | nein | ja (Stub) | ja | ja | E-076, E-077, E-080, E-083, E-089 |

\[
\boxed{
\text{E-077 bis E-085 derzeit } [C]\text{, aber E-077 bis E-079 sind die stärksten } [B]\text{-Upgrade-Kandidaten.}
}
\]

**Register-Stand:** E-077–E-085 sind derzeit `[C]` im Evidenzregister; `[B]`-Upgrade nur nach expliziter Operationalisierung und Reproduzierbarkeit.

**Meissner (E-076):** Interpretive Lesesprache **nur** für `ShellSeparationLoss(n)` — kein Hauptangriff. Siehe [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md).

---

## 1. Hurwitz-Windungs-Korrespondenz

**Hypothese:** `MonopoleHurwitzWindingHypothesis` · **ORQ-080** · **E-080**

**Fragestellung:**

Lässt sich eine effektive Monopolladung aus Spin-Eis oder verwandten emergenten Monopolmodellen als algebraischer Index, insbesondere als Windungszahl, auf Hurwitz-Orbits abbilden?

**Mögliche Struktur:**

$$q_{\mathrm{mono}}^{\mathrm{eff}} \quad \longleftrightarrow \quad \mathrm{wind}_{\mathbb H}(O_v)$$

Dabei wäre $O_v$ ein Hurwitz-Orbit und $\mathrm{wind}_{\mathbb H}$ ein algebraischer Index, der Orientierung, Umlaufstruktur oder eine diskrete Holonomie des Orbits misst.

**Status:** `[C]` physikalisch-mathematische Brückenhypothese.

**Nicht behauptet wird:**

- dass Spin-Eis-Monopole echte Dirac-Monopole sind,
- dass Hurwitz-Orbits physikalische Monopole erzeugen,
- dass eine Monopolladung bereits formal aus EABC folgt.

**Upgrade nach `[B]` möglich, wenn:**

1. ein diskreter Hurwitz-Windungsindex definiert wird,
2. dieser Index auf konkreten Orbits berechenbar ist,
3. er unter passenden Orbit-Transformationen invariant oder kontrolliert kovariant bleibt,
4. Nullmodelle zeigen, dass die beobachtete Windungsstruktur nicht trivial aus der Konstruktion folgt.

---

## 2. Metrischer Separationsverlust

**Hypothese:** `MetricSeparationLossExist` · **ORQ-077** · **E-077**

**Fragestellung:**

Existiert ein $n$, für das ein metrischer Separationsverlust in der Schalenrealisierung auftritt?

**Formal als Ziel:**

$$\exists n \;:\; \mathrm{ShellSeparationLoss}(n).$$

Die Grundidee ist, dass eine metrische Schalenrealisierung zunächst getrennte Strukturen sauber separiert, ab einer bestimmten Stufe aber eine erste Instabilität oder Überlappung auftritt.

**Status:** `[C→B]`. Derzeit `[C]` im Register; `[B]`-Upgrade erst nach formaler Definition von `ShellSeparationLoss(n)`, Metrik, Schwelle und reproduzierbarem Export.

Dies ist deutlich härter und wichtiger als die Monopol-Analogien, weil es intern im Modell liegt.

**Operationalisierung (Diagnose, kein Beweis):** `src/kepler_hurwitz/shell_separation_diagnostics.py` · `examples/run_shell_separation_diagnostics.py` · Export: [`energiedoku_exports/shell_separation_diagnostics_sample.json`](energiedoku_exports/shell_separation_diagnostics_sample.json)

**Mögliche Metriken:**

$$d_{\min}(S_i(n), S_j(n)), \qquad \operatorname{overlap}(S_i(n),S_j(n)),$$

$$\mathrm{sep}(n) = \min_{i\neq j} d(S_i(n),S_j(n)).$$

Ein Separationsverlust könnte definiert werden als:

$$\mathrm{ShellSeparationLoss}(n) \;\Longleftrightarrow\; \mathrm{sep}(n) \leq \varepsilon_n$$

oder stärker:

$$\mathrm{sep}(n+1) < \mathrm{sep}(n) \quad \text{und} \quad \mathrm{sep}(n) \to 0.$$

**Priorität:** hoch.

Denn dieser Punkt kann eine echte interne Strukturfrage werden:

\[
\boxed{
\text{Wo verliert die Schalenrealisierung erstmals metrische Trennschärfe?}
}
\]

Das ist näher an einem mathematischen Kern als jede externe Physik-Analogie.

**Meissner-Lesesprache (E-076, `[C]`):** Im übertragenen Sinn: Der Bulk bleibt geordnet, aber die Randschale trägt die Spannung — nahe an „innere Normalform stabil, metrisch Separationsverlust an der Shell“. **Nicht** der Hauptangriff; siehe [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md).

**Hooks:** [`energiedoku_exports/eabc_renormalisierungsprogramm.md`](energiedoku_exports/eabc_renormalisierungsprogramm.md) §8, §14.3

**Governance:** `projection_loss` in `diagnostics.py` ist Prime-Grid $L_\pi=\Omega-M$, **nicht** metrischer Shell-Separationsverlust.

---

## 3. Drei Monopol-Hypothesen

Diese Hypothesen sollten ausdrücklich als physikalische Resonanzachsen `[C]` geführt werden, nicht als mathematische Hauptsätze.

### 3.1 Dirac–Schwinger für emergente Monopole

**Hypothese:** `DiracSchwingerEmergentHypothesis` · **ORQ-081** · **E-081**

**Fragestellung:**

Gibt es eine sinnvolle Analogie zwischen Dirac–Schwinger-Quantisierung emergenter Monopole und diskreten Ladungs-/Windungsindizes in Hurwitz- oder EABC-Orbits?

**Physikalischer Referenzpunkt:**

$$eg = 2\pi n\hbar$$

oder in geeigneter Konvention:

$$q_e q_m \sim n.$$

**EABC/Hurwitz-Lesart:**

$$\text{diskrete Orbitladung} \quad \leftrightarrow \quad \text{quantisierte Kopplungsbedingung}.$$

**Status:** `[C]`.

**Upgrade nach `[B]` nur, wenn eine konkrete diskrete Paarung definiert wird:**

$$\langle q_{\mathrm{EABC}}, q_{\mathrm{Hurwitz}} \rangle \in \mathbb Z.$$

### 3.2 Dipol/Oktupol-Ladungsdichotomie

**Hypothese:** `DipoleOctupoleMonopoleChargeHypothesis` · **ORQ-082** · **E-082**

**Fragestellung:**

Lässt sich eine Dichotomie zwischen Dipol- und Oktupol-Ladungsanteilen als EABC/Hurwitz-Signatur lesen?

**Mögliche Modellform:**

$$\rho = \rho_{\mathrm{dip}} + \rho_{\mathrm{oct}}$$

mit einer Projektion:

$$P_{\mathrm{dip}}(\rho), \qquad P_{\mathrm{oct}}(\rho).$$

**EABC-Lesart:**

- Dipolanteil: niedrigere, richtungsgebundene Defektordnung.
- Oktupolanteil: höhere, symmetrischere oder tetraedrisch/oktaedrisch gekoppelte Signatur.
- Monopolanteil: effektive Ladung nach Projektion oder Divergenzbildung.

**Status:** `[C]`, eventuell `[B]`, wenn Projektionsoperatoren und Ladungsdichten im Modell formal definiert werden.

### 3.3 Berry-Holonomie als holonome Verbindung

**Hypothese:** `BerryHolonomyConnectionHypothesis` · **ORQ-083** · **E-083**

**Fragestellung:**

Kann eine Berry-artige Holonomie als Verbindung auf EABC/Hurwitz-Orbits gelesen werden?

**Physikalischer Referenzpunkt:**

$$\gamma(C) = \oint_C A$$

oder allgemeiner:

$$\operatorname{Hol}(C) = \mathcal P \exp \oint_C A.$$

**EABC/Hurwitz-Lesart:**

$$\operatorname{Hol}_{\mathrm{EABC}}(O_v)$$

als Orbit-Holonomie oder Umlaufphase.

**Status:** `[C]` mit gutem Potenzial nach `[B]`.

Diese Hypothese ist vermutlich stärker als die Dirac–Schwinger-Analogie, weil sie direkt an Aharonov–Bohm, Chiralität, ABCE/CEAB und Orbit-Signaturen anschließt.

**Minimaler `[B]`-Upgrade:**

1. Definiere einen diskreten Verbindungswert pro Kante/Kanalwechsel.
2. Definiere die Holonomie als Produkt/Summe entlang eines geschlossenen Orbits.
3. Prüfe Invarianz unter erlaubten Reparametrisierungen.
4. Vergleiche reale Orbits gegen Rotor-Nullmodelle.

---

## 4. Vier Geometrie-Hypothesen

**Sammelstruktur:** `GeometryScaffold` · **ORQ-084** · **E-084**

**Enthalten:**

1. Morley-Konfiguration,
2. Marion-Walter-Konfiguration,
3. gekreuztes Ptolemy,
4. Ikosaeder-Ptolemy-Viereck.

Diese vier Hypothesen sollten nicht als einzelne lose Analogien geführt werden, sondern als geometrisches Scaffold:

\[
\boxed{
\text{GeometryScaffold} = \{\text{Morley}, \text{Marion-Walter}, \text{Crossed Ptolemy}, \text{Icosahedral Ptolemy}\}.
}
\]

**Fragestellung:**

Gibt es eine gemeinsame geometrische Normalform, in der diese Konfigurationen als verschiedene Projektionen, Schnitte oder Stabilitätsbedingungen derselben Schalen-/Orbitstruktur erscheinen?

**Status:** vermutlich `[C]`/`[B]`.

- `[C]`, solange es motivische Geometrie ist.
- `[B]`, sobald konkrete Inzidenzen, Winkel-, Längen- oder Ptolemy-Gleichungen algorithmisch geprüft werden.
- `[A]`, nur wenn ein formaler Satz über die gemeinsame Scaffold-Struktur bewiesen wird.

**Wichtig:**

Diese Geometrie-Hypothesen könnten der beste Weg sein, um die physikalischen Analogien zu erden. Denn Geometrie ist zwischen Physikmetapher und Arithmetikbeweis vermittelbar.

**Hooks:** `KeplerHurwitz/SchuettePtolemyCaeda.lean`, `KeplerHurwitz/Representation/DreiMusketiere.lean`

---

## 5. Dedekind-Ideal-Brücke

**Hypothese:** `DedekindIdealBridge` / `PrimvierlingToQuaternionIdealMap` · **ORQ-085** · **E-067–E-069** (bestehend)

**Fragestellung:**

Existiert eine Abbildung $\Phi(v)=\gamma$ von Primvierlingen in Quaternionenordnungen, sodass $H\gamma$ und $\gamma H$ als Idealpfade analysierbar werden?

**Formal:**

$$\Phi : v \mapsto \gamma_v$$

mit

$$\gamma_v \in \mathcal O_{\mathbb H}$$

für eine geeignete Quaternionenordnung, etwa eine Hurwitz-Ordnung.

Dann könnten links- und rechtsseitige Idealpfade betrachtet werden:

$$H\gamma_v, \qquad \gamma_v H.$$

**Ziel:**

Primvierlinge sollen nicht bloß als Zahlenmuster, sondern als Pfade in einer nichtkommutativen Ordnungsstruktur lesbar werden.

**Status:** `[C]`/`[B]`, je nach Definition von $\Phi$.

Diese Brücke ist zentral, aber gefährlich: Sobald $\Phi$ frei gewählt wird, kann sie Struktur künstlich erzeugen. Deshalb braucht sie harte Guards.

**Minimalanforderungen für `[B]`:**

1. $\Phi$ muss kanonisch oder zumindest regelgebunden sein.
2. $\Phi$ darf nicht nachträglich an gewünschte Signaturen angepasst werden.
3. Links-/Rechts-Idealpfade müssen reproduzierbar berechenbar sein.
4. Es müssen Nullmodelle existieren:
   - zufällige Primvierlinge,
   - strukturierte Nicht-Vierlinge,
   - permutierte Kanäle,
   - alternative Quaternionenordnungen.
5. Die Signaturdifferenz muss skalenrobust sein.

**Repo-Governance:**

Dedekind–Hasse dient zunächst als Stabilitätsprüfer, nicht als Beweiser der Primvierlingsstruktur.

**Hooks:** `KeplerHurwitz/DedekindHasseProofAttempt.lean`; [`pure_prime_quadruple_dedekind_interpretation.md`](pure_prime_quadruple_dedekind_interpretation.md); [`theory/kepler_quaternion_lift_projection.md`](theory/kepler_quaternion_lift_projection.md)

---

## Weitere offene mathematische Ziele

### 6. Minkowski–Bouligand-Box-Dimension

**ORQ-079** · **E-079**

**Fragestellung:**

Besitzt eine metrische Schalenrealisierung eine wohldefinierte Minkowski–Bouligand-Box-Dimension?

**Formal:**

$$\dim_B(S) = \lim_{\varepsilon \to 0} \frac{\log N(S,\varepsilon)}{-\log \varepsilon},$$

falls der Grenzwert existiert.

**Status:** `[B]`.

Dieser Punkt ist mathematisch sauber und operationalisierbar. Er eignet sich sehr gut als Diagnose, ob die Schalenrealisierung nur konstruktiv hübsch ist oder eine echte Skalenstruktur trägt.

**Abhängig von:** E-078 (globale Einbettung), E-053

**Hooks:** [`energiedoku_exports/eabc_renormalisierungsprogramm.md`](energiedoku_exports/eabc_renormalisierungsprogramm.md) §7–8, §14.2

---

### 7. Globale $\mathbb{R}^3$-Einbettung für alle $n$

**ORQ-078** · **E-078**

**Fragestellung:**

Existiert eine globale $\mathbb{R}^3$-Einbettung der Schalenstruktur für alle $n$, wenn bisher nur $n \leq 3$ konstruktiv vorliegt?

**Formal:**

$$\forall n \; \exists \iota_n : S_n \hookrightarrow \mathbb R^3.$$

Oder stärker mit Kompatibilität:

$$\iota_{n+1}|_{S_n} = \iota_n.$$

**Status:** `[B]`/`[A]`-fähig.

Das ist einer der wichtigsten echten mathematischen Kerne. Denn hier geht es nicht um Analogie, sondern um Existenz, Konstruktion und Kompatibilität.

**Mögliche Aufspaltung:**

1. lokale Einbettung für jedes feste $n$,
2. globale kompatible Einbettung für alle $n$,
3. Einbettung mit Separation,
4. Einbettung mit kontrolliertem Separationsverlust.

**Hooks:** [`energiedoku_exports/eabc_renormalisierungsprogramm.md`](energiedoku_exports/eabc_renormalisierungsprogramm.md) §8–9, §14.1

---

### 8. Kopplung erster Instabilitätsstufe an EABC-Primindex

**Hypothese:** `shellPrimeMatchAtFirstLoss` · **ORQ-086** · **E-085**

**Fragestellung:**

Koppelt die erste intern nachgewiesene Instabilitätsstufe der Schalenrealisierung an einen EABC-Primindex?

**Wichtiger Governance-Guard:**

\[
\boxed{
\text{Diese Hypothese darf erst nach internem Instabilitätsnachweis aktiviert werden.}
}
\]

**Also Reihenfolge:**

1. Zuerst: Existenz von $\mathrm{ShellSeparationLoss}(n)$ intern beweisen oder diagnostizieren.
2. Dann: erstes $n_0$ bestimmen.
3. Erst danach: prüfen, ob $n_0$ mit einem EABC-Primindex koppelt.

Bis dahin bleibt `shellPrimeMatchAtFirstLoss` inaktiv und darf **nicht** zur Auswahl von $n$, Metrik oder Schwelle verwendet werden.

**Nicht erlaubt:**

Wir suchen so lange nach einem Primindex, bis einer passt.

**Erlaubt:**

Wir bestimmen die erste Instabilität blind/intern und testen danach die Kopplung.

**Status:**

- Vor Instabilitätsnachweis: `[C]`/deaktiviert.
- Nach Instabilitätsnachweis: `[B]`.
- Bei skalenrobuster Nullmodelltrennung: `[B+]`.

**Abhängig von:** E-077 · **Evidenz:** E-072 (mod-12-Kanalpartition)

---

## 10. Weyl-Kommutator-Operator-Brücke

**Hypothese:** `WeylCommutatorOperatorBridge` · **ORQ-087**

**Fragestellung:**

Kann die Links/Rechts-Asymmetrie von Hurwitz-Idealpfaden als Kommutator-Defekt gemessen werden?

**Formal:**

$$[\mathcal{H}, \gamma] := \mathcal{H}\gamma - \gamma\mathcal{H}, \qquad
\Delta_{\mathrm{LR}}(\gamma) := \|[\mathcal{H}, \gamma]\|.$$

Die Weyl-Algebra $[A,B]=AB-BA=I$ liefert die kanonische Lesart: Reihenfolge zählt, Orbit-Pfade sind gerichtet, nichtkommutative Defekte sind strukturell — kein Störfall.

**EABC/Hurwitz-Lesart:**

| Weyl | Hurwitz/EABC |
|---|---|
| $AB \neq BA$ | $H\gamma \neq \gamma H$ |
| Kommutator-Norm | $\Delta_{\mathrm{LR}}$ vs.\ $\delta_H$ (`norm_signature_defect`) |
| Umlauf | CEAB-Orbit, Berry-Holonomie (ORQ-083) |

**Status:** `[C]` — `[B]`-Upgrade über `weyl_commutator_diagnostics.py` mit Nullmodellen (CEAB, Kanal-Shuffle, Norm-Match).

**Nicht behauptet wird:**

- dass $\Delta_{\mathrm{LR}}$ bereits Berry-Holonomie misst,
- dass die Hurwitz-Ordnung eine Weyl-Darstellung trägt,
- dass Kommutator-Nullheit Idealpfad-Symmetrie beweist.

**Minimalanforderungen für `[B]`:**

1. $\mathcal{H}$ kanonisch dokumentieren (nicht nachträglich an Profile anpassen).
2. Batch-Export $\Delta_{\mathrm{LR}}(v)$ für Primvierlinge mit fünf Nullmodellen.
3. Trennschärfe vs.\ Nullmodelle berichten.
4. Vergleich mit `norm_signature_defect` — komplementär, nicht redundant.

**Hooks:** [`theory/weyl_commutator_operator_bridge.md`](theory/weyl_commutator_operator_bridge.md); `src/kepler_hurwitz/weyl_commutator_diagnostics.py`; [`pure_prime_quadruple_dedekind_interpretation.md`](pure_prime_quadruple_dedekind_interpretation.md) §3

---

## 11. Onsager Quantization Bridge

**Hypothese:** `OnsagerQuantizationBridge` · **ORQ-089** · **E-089**

**Fragestellung:**

Lassen sich Lars Onsagers vier Grundbeiträge — Flussquantisierung, quantisierte Wirbel, exakte 2D-Ising-Lösung, Reziprozitätsbeziehungen — als komplementäre Resonanzachsen für diskrete EABC-Strukturen lesen?

**Vier Achsen:**

| Achse | Physik | EABC-Lesefrage |
|---|---|---|
| Flussquantisierung | $\Phi = n \Phi_0$, $\Phi_0 = h/2e$ | mod-$12$-Kanäle, diskrete Buckets (E-072) |
| Quantisierte Wirbel | $\kappa = n h/m$ | Orbit-Windung (ORQ-080), Holonomie (ORQ-083) |
| 2D-Ising | Phasenübergang bei $T_c$ | ShellSeparationLoss (ORQ-077), $\dim_B$ (ORQ-079) |
| Reziprozität | $L_{ij} = L_{ji}$ | Idealpfad-Symmetrie, $\Delta_{\mathrm{LR}}$ (ORQ-087) |

**Status:** `[C]` — ergänzt E-076 (AB/Klitzing/Meissner); `[B]`-Upgrade über vorgeschlagene Diagnostik mit Nullmodellen.

**Nicht behauptet wird:**

- dass EABC Suprafluidität, Supraleitung oder Ising-Kritikalität implementiert,
- dass $\Phi_0$ im Hurwitz-Formalismus definiert ist,
- dass Onsager-Reversibilität Dedekind-Symmetrie beweist.

**Hooks:** [`theory/onsager_quantization_bridge.md`](theory/onsager_quantization_bridge.md); [`reports/physical_reference_analogies.md`](reports/physical_reference_analogies.md) (E-076); `src/kepler_hurwitz/onsager_vortex_diagnostics.py`

---

## Prioritätsordnung

Die offenen Ziele sollten nicht gleichrangig behandelt werden. Sinnvolle Priorität:

| Priorität | Ziel | ORQ | E-ID | Grund |
|---|---|---|---|---|
| **1** | `MetricSeparationLossExist` | ORQ-077 | E-077 | interne mathematische Existenzfrage |
| **2** | Globale $\mathbb{R}^3$-Einbettung | ORQ-078 | E-078 | harter geometrischer Kern |
| **3** | Minkowski–Bouligand-Dimension | ORQ-079 | E-079 | skalenfähige Metrik |
| **4** | Dedekind-Ideal-Brücke | ORQ-085 | E-067–E-069 | arithmetisch stark, aber Guard-pflichtig |
| **5** | Berry-Holonomie | ORQ-083 | E-083 | beste physikalische Brücke zu Orbit/Phase |
| **6** | `GeometryScaffold` | ORQ-084 | E-084 | hilfreich als geometrischer Vermittler |
| **7** | Hurwitz-Windungs-Korrespondenz | ORQ-080 | E-080 | interessant, aber physikalisch riskanter |
| **8** | Dirac–Schwinger / Dipol–Oktupol | ORQ-081, ORQ-082 | E-081, E-082 | vorerst Resonanzachsen `[C]` |
| **9** | `shellPrimeMatchAtFirstLoss` | ORQ-086 | E-085 | erst nach internem Instabilitätsnachweis aktivieren |
| **10** | Weyl-Kommutator $\Delta_{\mathrm{LR}}$ | ORQ-087 | — | arithmetisch komplementär zu ORQ-085; `[B]`-Stub vorhanden |
| **11** | Onsager Quantization Bridge | ORQ-089 | E-089 | interpretativ; ergänzt E-076; vier Resonanzachsen `[C]` |

---

## Minimaler Durchbruchspfad

Der stärkste Weg wäre nicht, bei den Monopolanalogien zu beginnen, sondern bei der internen Geometrie:

\[
\boxed{
\text{Schale} \to \text{Separation} \to \text{erster Verlust} \to \text{Dimension} \to \text{Primindex-Test}
}
\]

**Konkret:**

1. Definiere $\mathrm{ShellSeparationLoss}(n)$.
2. Konstruiere Schalen bis möglichst hohe $n$.
3. Messe minimale Separation und Überlappung.
4. Bestimme den ersten Verlust $n_0$.
5. Prüfe erst dann `shellPrimeMatchAtFirstLoss`.
6. Nutze Hurwitz-/Meissner-/Berry-Sprache erst danach zur Interpretation.

Damit bleibt die Governance sauber:

\[
\boxed{
\text{erst interne Instabilität, dann externe Deutung.}
}
\]

---

## Abschluss

Die Monopol-, Berry-, Meissner- und Quanten-Hall-Analogien sind nützlich als Resonanzsprache. Der mathematische Kern liegt aber in den internen Existenzfragen:

$$\exists n : \mathrm{ShellSeparationLoss}(n), \qquad \forall n : S_n \hookrightarrow \mathbb R^3, \qquad \dim_B(S) \text{ existiert},$$

und in einer kontrollierten, nicht nachträglich angepassten Abbildung

$$\Phi(v)=\gamma_v.$$

Der wahrscheinlich stärkste Durchbruchspfad ist deshalb nicht „Monopol beweist EABC“, sondern:

\[
\boxed{
\text{metrische Schaleninstabilität sauber finden, dann arithmetisch testen.}
}
\]

Erst wenn eine interne Instabilität unabhängig gefunden wurde, darf ihre Kopplung an EABC-Primindizes als echte Hypothese geprüft werden.

---

## 12. Weyl–Onsager Komplettangriff (E-087, E-088)

**Hypothesen:** `WeylChiralBridgeHypothesis` (E-087) · `OnsagerReciprocalBridgeHypothesis` (E-088)  
**Kanonisches Dossier:** [`theory/weyl_onsager_bridge_attack.md`](theory/weyl_onsager_bridge_attack.md)

**Fragestellung:**

Lassen sich Weyl-Chiralität (lokal) und Onsager-Reziprozität (global) als **koordinierte Lesesprache** auf EABC-Kanalstrukturen lesen — ohne physikalische Identifikation?

| Achse | E-ID | Diagnostik-Stub | Abhängigkeit |
|---|---|---|---|
| Weyl / Chiral / Berry | E-087 | `weyl_chirality_proxy`, `berry_holonomy_product` | E-080, E-083, ORQ-087 |
| Onsager / Reziprozität / Hall | E-088 | `onsager_reciprocity_residual` | E-076, E-089 |

**Governance:** Komplettangriff = Lesesprache + Diagnostik, nicht Großsatz. E-077 bleibt Priorität 1; Weyl/Onsager-Deutung erst nach internem Shell-Loss **oder** als parallele `[B]`-Exports.

**Nicht behaupten:** Weyl beweist EABC; Onsager beweist Collatz; Hall-Effekt = Hurwitz-Primzahlen.

**Ordnungs-Defekt-Parallelismus:** ORQ-089 (Schleifen-Zirkulation) ↔ ORQ-087 (Operator-Kommutator); Claim-Status-Tabelle und See-also-Block in [`theory/weyl_onsager_bridge_attack.md`](theory/weyl_onsager_bridge_attack.md).

---

## Meissner als ergänzende Sprache (Punkt 2)

Die Meissner-Analogie passt gut als ergänzende Sprache für Punkt 2: $\mathrm{ShellSeparationLoss}(n)$.

Denn Meissner sagt im übertragenen Sinn: Der Bulk bleibt geordnet, aber die Randschale trägt die Spannung. Das ist sehr nah an: Die innere Normalform bleibt stabil, aber metrisch entsteht an der Shell ein Separationsverlust.

Aber der eigentliche harte Angriffspunkt ist **nicht** Meissner, sondern:

\[
\boxed{
\exists n : \mathrm{ShellSeparationLoss}(n)
}
\]

Wenn man diesen Punkt sauber definiert und testet, könnte Meissner später helfen, das Ergebnis zu deuten. Der mögliche Durchbruch liegt aber in der metrischen Schale, nicht in der Supraleitungsmetapher.

**Urteil:** [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md) (E-076) — Meissner hilft beim Lesen, nicht beim Durchbruch.

---

## Querverweise

| Dokument | Rolle |
|---|---|
| [`open_research_questions.md`](open_research_questions.md) | Kurz-ORQ-Index mit Prioritätsspalte |
| [`research_map.md`](research_map.md) | Kategorie-Einordnung (Definition/Theorem/Numerik/Hypothese/Interpretation) |
| [`theory/README.md`](theory/README.md) | Theory-Master-Index |
| [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md) | Meissner-Urteil: Lesesprache für ShellSeparationLoss, kein Hauptangriff |
| [`energiedoku_exports/eabc_renormalisierungsprogramm.md`](energiedoku_exports/eabc_renormalisierungsprogramm.md) | Formaler Renorm-Kern E-053 |
| [`reports/physical_reference_analogies.md`](reports/physical_reference_analogies.md) | AB / Klitzing / Meissner E-076 |
| [`theory/onsager_quantization_bridge.md`](theory/onsager_quantization_bridge.md) | Onsager-Achsen E-089 |
| [`theory/weyl_onsager_bridge_attack.md`](theory/weyl_onsager_bridge_attack.md) | Weyl–Onsager Komplettangriff E-087/E-088 |
| [`diagnostics_parameter_atlas.md`](diagnostics_parameter_atlas.md) | E-077 Shell-Separationsdiagnostik `[B]`-Kandidat |
| `src/kepler_hurwitz/shell_separation_diagnostics.py` | E-077 Operationalisierung (Diagnose only) |

---

## Governance-Schlussbox

\[
\boxed{
\begin{aligned}
&\text{Open-Core-Pfad: interne Geometrie vor externer Deutung.} \\
&\text{Minimaler harter Pfad: } \mathrm{ShellSeparationLoss} \to n_0 \to \dim_B \to \texttt{shellPrimeMatchAtFirstLoss}. \\
&\text{EABC-Primindex-Kopplung bleibt deaktiviert, bis } n_0 \text{ blind/intern feststeht.}
\end{aligned}
}
\]

Monopol-, Berry- und Meissner-Sprache dürfen erst **nach** reproduzierbarem Separationsverlust-Diagnoseexport interpretativ herangezogen werden — nicht zur Vorauswahl von Metrik, Schwelle oder Instabilitätsstufe.
