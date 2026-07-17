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
