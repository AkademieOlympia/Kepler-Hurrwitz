---
title: Skaleninvarianz unter BH-C-11 — Homogenitätskürzung (Protokoll)
date: 2026-07-17
status: "[B] Homogenitätsargument; [C] κ-Faktoren; [D] Zweikanal-Lesart; Numerik = Regression"
claim_boundary: >-
  Die punktweise Konstanz von R_dyn pro Restklasse folgt aus Grad-1-Homogenität
  von E_dyn und (ABC)^{1/3}; p kürzt sich formal. Numerik bestätigt Implementierung
  und Float-Rauschen (~10^{-16}), keine asymptotische oder physikalische Entdeckung.
  κ_5, κ_11 sind modellinterne Skalierungsfaktoren, keine Naturkonstanten.
not_claimed:
  - R_dyn-Plateaus sind empirische Naturkonstanten
  - Konstanz beweist thermodynamische Phasen oder reale Phasenübergänge
  - Homogenitätsargument ersetzt Lean-[A]-Formalisierung ohne eigenen Beweis
  - Koeffizientenschablonen c_A(r),c_B(r),c_C(r) sind physikalisch kalibriert
  - Δ_K als topologische Invariante oder Maß für Transport/Krümmung/Fano-Stärke
    (siehe §5.4; Details in jacobi_minpoly_discriminant_sqf.md)
epistemic_layers:
  B: Grad(R_dyn)=0 aus Homogenität ersten Grades
  C: E_dyn, κ(5), κ(11), lineare Achsenabbildungen
  D: Zweikanalstruktur als Heuristik — kein physikalischer Phasenübergang
  E: Float-Regression / Maschinenpräzision (kein empirischer Physik-Claim)
related:
  - eabc_energy_square_sum_substitution.md
  - eabc_epistemic_layers_vdw_eigen_vacuum.md
  - eabc_constellation_eigenenergy.md
  - ../black_hole/claim_register.md
---

> **Protokoll-Notiz:** Skaleninvarianz unter BH-C-11  
> Homogenitätskürzung · Regression · keine Naturkonstante  
> **Kontrast:** [`primvierling_associator_scaling.md`](primvierling_associator_scaling.md) — dort \(\mathcal{R}_{\mathrm{assoc}}=\mathcal{O}(p)\), kein Grad-0-Plateau.

# Skaleninvarianz unter BH-C-11 — Homogenitätskürzung

## 1. Mathematische Demystifizierung (Ebene B)

Für lineare Achsenabbildungen \(A,B,C \propto p\) und die dynamische Energie

\[
E_{\mathrm{dyn}}(p)=\sqrt{A(p)^2+B(p)^2+C(p)^2}
\]

sowie das geometrische Mittel \(\sqrt[3]{A\cdot B\cdot C}\) gilt:

\[
\mathrm{Grad}(E_{\mathrm{dyn}})=1
\quad\land\quad
\mathrm{Grad}\bigl(\sqrt[3]{A\cdot B\cdot C}\bigr)=1
\quad\Longrightarrow\quad
\mathrm{Grad}(\mathcal{R}_{\mathrm{dyn}})=0,
\]

mit

\[
\mathcal{R}_{\mathrm{dyn}}(p)
=
\frac{E_{\mathrm{dyn}}(p)}{\sqrt[3]{A(p)\,B(p)\,C(p)}}.
\]

Die punktweise Skaleninvarianz (pro fester Restklasse \(r=p\bmod 12\)) ist keine asymptotische Aussage \(p\to\infty\) und kein statistisches Plateau, sondern die Kürzung homogener Funktionen ersten Grades: die Primzahlvariable \(p\) fällt formal aus dem Verhältnis heraus.

## 2. Epistemische Einordnung

```
┌───────────────────────────────────────────────────────────────────────────┐
│ [B] FORMALE MATHEMATISCHE EBENE                                           │
│ Der Homogenitätsbeweis: Grad-0-Invarianz der Verhältnisgröße R_dyn.       │
└─────────────────────────────────────┬─────────────────────────────────────┘
                                      ▼
┌───────────────────────────────────────────────────────────────────────────┐
│ [C] MODELLINTERNE NOMENKLATUR                                             │
│ Die Definition von E_dyn und die Approximationen κ(5) und κ(11)           │
│ als restklassenabhängige Skalierungsfaktoren.                             │
└─────────────────────────────────────┬─────────────────────────────────────┘
                                      ▼
┌───────────────────────────────────────────────────────────────────────────┐
│ [D] INTERPRETATIVE ANALOGIEN                                              │
│ Heuristische Deutung der Zweikanalstruktur als diskrete Zweige;           │
│ kein Nachweis realer physikalischer Phasenübergänge.                      │
└───────────────────────────────────────────────────────────────────────────┘
```

Numerik (Maschinenpräzision \(\sim 10^{-16}\)) gehört zur **Implementierungsregression** (Ebene E im Sinne der Schichtung B/C/D/E): sie prüft fehlerfreie Koordinatenschablonen und ausbleibendes Float-Rauschen jenseits der Homogenitätsidentität — sie belegt keine Naturerscheinung.

Siehe [`eabc_epistemic_layers_vdw_eigen_vacuum.md`](eabc_epistemic_layers_vdw_eigen_vacuum.md).

## 3. Protokoll-Eintrag (#Energiedoku)

* **Befund:** Der numerische Lauf für Primzahlzwillinge zeigt eine restklassenweise Konstanz der dimensionslosen Verhältnisgröße \(\mathcal{R}_{\mathrm{dyn}}(p)\) bis zur Maschinenpräzision (\(\sim 10^{-16}\)).
* **Algebraische Ursache:** positive Homogenität ersten Grades der Achsenabbildungen und der Energiedefinition; \(p\) kürzt sich formal vollständig aus dem Verhältnis heraus.
* **Modellparameter:** Die numerischen Werte \(\kappa_5 \approx 1{,}983892\) und \(\kappa_{11} \approx 1{,}889882\) sind rein modellinterne, restklassenabhängige Skalierungsfaktoren, die sich aus den exakten Koeffizienten \(c_A(r),\,c_B(r),\,c_C(r)\) der linearen Schablone herleiten (Skript: `Dritte Wurzel.sage`).
* **Geltungsbereich:** Die Skaleninvarianz gilt punktweise und exakt für alle Primzahlen \(p\), die der definierten linearen Koordinatenstruktur folgen. Eine physikalische Entdeckung oder der Nachweis thermodynamischer Phasen ist damit nicht verbunden; das Ergebnis belegt ausschließlich die **interne Skalierungskonsistenz** der EABC-Konstruktion unter BH-C-11.

## 4. Claim-Grenze

1. \(\mathcal{R}_{\mathrm{dyn}}\) und \(\kappa_r\) sind keine Kandidaten für Naturkonstanten.
2. Restklassenweise Zweiwerte-Struktur \(\kappa_5\) vs. \(\kappa_{11}\) ist modellinterne Parameterisierung, keine empirische Phasenphysik.
3. Bezug zu BH-C-11: energetische Quadratform / Modul-Norm — siehe [`eabc_energy_square_sum_substitution.md`](eabc_energy_square_sum_substitution.md).

## 5. Zahlkörper-Zertifikat (Querverweis)

Lokal am Jacobi-Testpunkt: sqf-Kern \(d_J\), SHA256-Fingerprint und
\(K=\mathbb{Q}(\sqrt{d_J})\) — siehe
[`jacobi_minpoly_discriminant_sqf.md`](jacobi_minpoly_discriminant_sqf.md)
und Skript [`../../fano_field_certification.py`](../../fano_field_certification.py).
Die Homogenitätsaussage von \(\mathcal{R}_{\mathrm{dyn}}\) bleibt davon unberührt;
das Zertifikat erweitert weder die Claim-Grenze in §4 noch behauptet es globale
Nichtverschwindung von \(J\).

### 5.3 Implementierung und Versionsrobustheit des Zertifikats

Um eine langfristige maschinelle Verifikation unabhängig von internen Klassenverschiebungen zukünftiger SymPy-Releases (z. B. Übergang zu SymPy 1.14.0) zu stützen, erfolgt der Feldaufbau und die Invariantenprüfung im Skript `fano_field_certification.py` vollständig über funktionale Core-Schnittstellen.
Das Minimalpolynom wird über `sp.minimal_polynomial` explizit berechnet und mittels algebraischer Substitution ($\theta = \sqrt{d_J}$) sowie über quadratfreie Vorzeichentests algebraisch abgesichert, anstatt auf interne Domänen-Attribute wie `K.ext.minpoly` zuzugreifen.

### 5.4 Arithmetische Bedeutung der Fundamentaldiskriminante

Kurzfassung der Claim-Grenze für \(\Delta_K\) am Jacobi-Testpunkt (Details:
[`jacobi_minpoly_discriminant_sqf.md`](jacobi_minpoly_discriminant_sqf.md)):

| Status | Aussage |
|---|---|
| **gehalten** | \(d_J>0\) quadratfrei, \(d_J\equiv 3\pmod{4}\) \(\Rightarrow\) \(\Delta_K=4d_J\), \(\mathcal{O}_K=\mathbb{Z}[\sqrt{d_J}]\), Basis \(\{1,\sqrt{d_J}\}\) |
| **gehalten** | \(\mathbb{Q}(r\sqrt{d_J})=\mathbb{Q}(\sqrt{d_J})\) für \(r\in\mathbb{Q}^\times\) |
| **gehalten** | Grad 2: \(\Delta_K\) bestimmt \(K\) bis auf \(\mathbb{Q}\)-Isomorphie; verzweigende Primzahlen genau die Teiler von \(\Delta_K\) (\(2,\,937,\,p_2\)) |
| **nicht** | \(\Delta_K\) als topologische Invariante oder als Maß für Transport/Krümmung/physikalische Deformation/Fano-Stärke |
| **nicht** | Eindeutigkeit durch \(\Delta_K\) für Zahlkörper beliebigen Grades |

\(\Delta_K\) ist hier eine **kanonische arithmetische Isomorphieinvariante** des quadratischen Körpers \(K=\mathbb{Q}(\sqrt{d_J})\). Die Homogenitätsaussage zu \(\mathcal{R}_{\mathrm{dyn}}\) bleibt davon unberührt.

### 5.5 Graphentheoretisches Existenzkriterium für Invarianten unter \(T_{\mathrm{odd}}\)

Für jeden endlichen Zustandsraum \(\mathcal{X}\) unter der deterministischen Abbildung \(T_{\mathrm{odd}} : \mathcal{X} \to \mathcal{X}\) existiert eine nichtkonstante, endlichwertige Invariante \(J \circ T_{\mathrm{odd}} = J\) genau dann, wenn der induzierte Funktionsgraph eine schwache Zusammenhangskomponentenzahl \(> 1\) besitzt.

Ist der Graph schwach zusammenhängend (Komponentenzahl \(= 1\)), kollabiert jede algebraische Invariante zwangsläufig zur Konstanten. In diesem Fall verschiebt sich das Suchziel des Modells auf die Identifikation einer endlichen kovarianten Quotientendynamik \(J(T_{\mathrm{odd}}x) = \sigma(J(x))\) mit einer nichttrivialen Permutation \(\sigma \neq \operatorname{id}\). Experimentelle Laufzeit- und Strukturprüfungen haben sich diesem topologischen Befund bedingungslos unterzuordnen.

**Governance (bindend):** Keine nichtkonstante Invariante durch nachträgliche Unterklassen-Wahl erzwingen. Fano-/Charakter-Kandidaten bleiben reine Hypothesen bis zum Graphen-Befund. Kein Collatz-Beweis-Claim. Implementierung: [`src/kepler_hurwitz/graph_analyzer.py`](../../src/kepler_hurwitz/graph_analyzer.py), Phase-A-Export [`../exports/oddcore_function_graph_phase_a.json`](../exports/oddcore_function_graph_phase_a.json).

### 5.5.1 Befund des Phase-A-Funktionsgraphscans

Nach dem berichteten Scan des Operators \(T_{\mathrm{odd}}\) auf den ungeraden Restklassenräumen modulo 8, 16, 32, 64 und 128 besitzt jeder untersuchte Funktionsgraph genau eine schwache Zusammenhangskomponente. Unter der Voraussetzung, dass die Zustandsräume abgeschlossen und vollständig enumeriert wurden, folgt daraus:
\[
J \circ T_{\mathrm{odd}} = J \implies J \text{ ist konstant}.
\]
Auf den untersuchten vollständigen Restklassenräumen existiert somit keine nichtkonstante exakte Invariante.

Dieser Ausschluss lässt sich nicht durch die Wahl einer nichtleeren vorwärtsabgeschlossenen Unterklasse umgehen. Jede solche Unterklasse enthält den eindeutigen Attraktorzyklus; alle ihre Zustände sind durch ihre Vorwärtsbahnen mit diesem Zyklus verbunden. Der induzierte Funktionsgraph bleibt daher schwach zusammenhängend. Die Einrichtung von Phase-C-Unterklassen zur Generierung statischer Invarianten ist auf diesen endlichen Räumen strukturell gesperrt.

Das weitere Suchprogramm wird in zwei getrennte Richtungen aufgespalten:

1. **Endliche Faktordynamik (Taktung):** Gesucht werden lokale mathematische Merkmale, welche die kanonische Phasen-Kovarianz \(\varphi(T_{\mathrm{odd}}x) = \varphi(x) + 1 \pmod \ell\) auf und vor dem Zyklus der Länge \(\ell > 1\) rekonstruieren.
2. **Lyapunov-artige Ränge (Abstieg):** Gesucht werden lokale arithmetische Merkmale, welche die global definierte Transiententiefe \(d(T_{\mathrm{odd}}x) \le d(x)\) abbilden, mit strikter Abnahme (\(d-1\)) außerhalb des Attraktors.

**Ehrlichkeit (\(L=1\)):** Auf den Phase-A-Monolithen modulo 8…128 ist der Attraktorzyklus \(\{1\}\), also \(\ell = 1\). Dann ist \(\varphi\) konstant \(0\) und die Kovarianz modulo \(1\) trivial; die Kompressionsfrage für \(\varphi\) kollabiert. Die live Zielobservable ist die Tiefe \(d\). Implementierung: [`src/kepler_hurwitz/cycle_phase_compressor.py`](../../src/kepler_hurwitz/cycle_phase_compressor.py), Export [`../exports/oddcore_cycle_phase_compression.json`](../exports/oddcore_cycle_phase_compression.json).

### 5.5.2 Kanonische Graphobservablen und arithmetische Rekonstruktion

Für einen endlichen, schwach zusammenhängenden Funktionsgraphen mit eindeutigem Attraktorzyklus \(C\) wird die Attraktortiefe
\[
d(x) = \min\{n \ge 0 : T_{\mathrm{odd}}^n(x) \in C\}
\]
definiert. Sie erfüllt \(d(T_{\mathrm{odd}}x) = d(x) - 1\) für \(d(x) > 0\) und \(d(T_{\mathrm{odd}}x) = 0\) auf dem Attraktorzyklus. Damit ist \(d\) eine exakte graphentheoretische Lyapunov-Funktion.

Der Wert der Zykluslänge \(\ell\) erzwingt eine strikte konditionale Fallunterscheidung:
\[
\begin{cases}
\ell > 1: & \varphi(T_{\mathrm{odd}}x) = \varphi(x) + 1 \pmod \ell \text{ liefert eine nichttriviale Taktung}, \\[2mm]
\ell = 1: & \varphi \text{ ist trivial; } d \text{ ist die primäre Graphobservable}.
\end{cases}
\]

Die konkrete Wahl des Phasenursprungs ist bei \(\ell > 1\) nicht eindeutig. Zwei zulässige Phasen unterscheiden sich durch eine globale additive Konstante. Kanonisch ist daher zunächst die Phasenklasse modulo globaler Translation. Eine reproduzierbare konkrete Repräsentation verlangt eine ausdrücklich festgelegte Zyklusnormalisierung; ohne einen solchen eindeutigen strukturellen Anker ist die Darstellung *gauge-dependent*.

Das anschließende Suchprogramm prüft, ob lokale arithmetische Merkmale \(M(x)\) die globalen Zielgrößen \(\varphi(x)\) oder \(d(x)\) bestimmen. Exakte Rekonstruierbarkeit bedeutet:
\[
M(x) = M(y) \implies G(x) = G(y),
\]
wobei \(G\) für \(\varphi\) oder \(d\) steht. Diese Implikation allein beweist noch keine nützliche Kompression. Zusätzlich werden die Anzahl unterschiedlicher Merkmalswerte, die Anzahl der Zielklassen, die Zustandsreduktion sowie die Berechnungskosten des Merkmals dokumentiert. Eine kardinalitätsminimale exakte Zielkodierung liegt im endlichen Fall vor, wenn die Zahl der Merkmalsklassen der Zahl der Zielklassen entspricht (\(F = Q\)). Eine weitergehende Aussage über eine echte Kompression verlangt den expliziten Nachweis reduzierter Beschreibungslängen oder Berechnungskosten im Vergleich zur globalen Graphobservablen.

**Freeze-Kandidat-Status (bindend, lokal noch nicht beglaubigt):**
\[
\boxed{\begin{aligned}
\text{Monolith-Topologie:}\quad& \text{nach berichtetem Graphscan für mod } 8 \text{ bis } 128, \\
\text{statische Invarianten:}\quad& \text{auf den vollständigen Monolithen ausgeschlossen}, \\
\text{Phasenfaktor:}\quad& \varphi(Tx)=\varphi(x)+1\pmod\ell, \\
\text{Phasennormalisierung:}\quad& \text{nur bei eindeutigem strukturellen Anker reproduzierbar}, \\
\text{Attraktortiefe:}\quad& d(Tx)\le d(x) \text{ mit striktem Abstieg außerhalb des Zyklus}, \\
\text{Rekonstruktionsaudit:}\quad& \text{liefert vollständige Kollisions-Witnesses}, \\
\text{Bedingung } F=Q:\quad& \text{kardinalitätsminimale exakte Zielkodierung}, \\
\text{echte Kompression:}\quad& \text{erst nach Kosten-, Bitlängen- oder Entropieanalyse}, \\
\text{lokaler Freeze:}\quad& \text{noch nicht durch Laufprotokoll, Hash und Commit belegt}.
\end{aligned}}
\]
\[
\boxed{\text{Graphobservable} \;\longrightarrow\; \text{Rekonstruierbarkeit} \;\longrightarrow\; \text{kardinalitätsminimale Kodierung} \;\longrightarrow\; \text{erst danach echte Kompressionsbewertung}}
\]

### 5.6 Exhaustiver 2-adischer Zylinder-Cutoff (Schicht B1–B2)

**Status (Schicht B2):** Vollständig spezifizierter und ausführbarer Freeze-Kandidat; lokale Ausführung und Revisionsartefakte weiterhin ausstehend. Agenten *berichtete* Läufe gelten **nicht** als physischer Bamberg-Vollzug und **nicht** als revisionssichere Beglaubigung. Details: [`../energiedoku_exports/form_inhalt_bigraded_cylinder_b2_2026_07_17.md`](../energiedoku_exports/form_inhalt_bigraded_cylinder_b2_2026_07_17.md). **Kein** Collatz-Beweis. **Schicht B3 (Fano-/Inzidenz-Kopplung) bleibt blockiert**, bis B2 physisch geschlossen ist.

Epistemische Staffelung:
\[
\boxed{\text{Automatisierte Meldung} \;\neq\; \text{physischer Vollzug} \;\neq\; \text{revisionssicher beglaubigtes Artefakt}}
\]
\[
\boxed{\text{vollständige Spezifikation} \quad \neq \quad \text{lokale Ausführung} \quad \neq \quad \text{revisionssicher beglaubigter Freeze}}
\]

Zur Beseitigung unvollständiger Zustandsschätzungen wird das System zwingend über dem kanonischen, ebenenvollständigen Cutoff \(\mathcal{Z}_{\le P} = \{(r,p) : 1 \le p \le P, \ 1 \le r < 2^p, \ r \text{ ungerade}\}\) mit exakt \(2^P - 1\) Zuständen definiert. Der beschleunigte Schritt operiert unter Reduktion der ableitbaren Ausgangsbeschränkung (Bestimmtheitsverlust) um \(j\) Bits.

Innerhalb des geschlossenen Cutoffs gilt für alle Dynamikkanten \(E_{\mathrm{dyn}}^{\mathrm{boundary}} = 0\), was das Auftreten von Definitionslecks ausschließt. Für den Grenzfall \(j = p\) bricht die Dynamik mangels Bit-Tiefe zusammen (*dynamics blocked*). Auf jeder Präzisionsebene existiert exakt ein solcher Zylinder:
\[
\#\{r \bmod 2^p : j_p(r) = p\} = 1.
\]
Dieser Zustand unterliegt dem *Singular-Lift-Split-Lemma*: Seine beiden unmittelbaren Nachfolger auf Ebene \(p+1\) nehmen zwingend die Bewertungen \(\{p, p+1\}\) an. Dadurch wird der fortlaufend unverzweigte, singuläre 2-adische Pfadpräfix \(s_1 \rightsquigarrow s_2 \rightsquigarrow \dots \rightsquigarrow s_P\) nach \(-\frac{1}{3} \in \mathbb{Z}_2\) als exakt lift-verbundene Kette isoliert und maschinell serialisiert.

Implementierung: [`src/kepler_hurwitz/bigraded_cylinder_graph.py`](../../src/kepler_hurwitz/bigraded_cylinder_graph.py), Runner [`python -m kepler_hurwitz.run_bigraded_cylinder_audit`](../../src/kepler_hurwitz/run_bigraded_cylinder_audit.py), kanonische Exporte [`../exports/audit-cylinder-normal.json`](../exports/audit-cylinder-normal.json) / [`../exports/audit-cylinder-optimized.json`](../exports/audit-cylinder-optimized.json) (Alias: [`../exports/bigraded_cylinder_cutoff_protocol.json`](../exports/bigraded_cylinder_cutoff_protocol.json)).

**Governance:** **[B]** diagnostischer Cutoff-Audit — **kein** Collatz-Beweis.
