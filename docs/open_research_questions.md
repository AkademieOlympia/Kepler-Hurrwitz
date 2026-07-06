# Open Research Questions

Dieses Dokument ist der **Kurz-Index** offener Forschungsfragen und ORQ-IDs.

**Kanonischer Katalog (Governance, Prioritäten, Abhängigkeiten):** [`open_mathematical_bridge_targets.md`](open_mathematical_bridge_targets.md)

Es enthält bewusst keine Behauptungen über bereits gesicherte Resultate.

**Konvention:** `ORQ-xxx` = interne Open-Research-Question-ID (Fragestellung);
`E-xxx` = Evidenzregister-Eintrag in [`EVIDENCE_REGISTER.md`](../EVIDENCE_REGISTER.md).

---

## Formale Dynamik und Attraktorik

- Existiert ein natuerliches Lyapunov-Funktional fuer `oddCore`-basierte Dynamik?
- Laesst sich Retraktion in eine kategorientheoretische Charakterisierung uebersetzen?
- Gibt es eine intrinsische Automorphismengruppe des EABC-Zustandsraums?

## Defekt- und Spektralstruktur

- Besitzt der Defektoperator eine kanonische Spektralzerlegung?
- Existiert ein natuerlicher Holonomiebegriff fuer diskrete EABC-Orbits?
- Welche minimalen Annahmen reichen fuer ein globales Coverage-Lemma (`E-009`)?

## Thermodynamische Strukturfragen (L4 -> C/B/A)

- Gibt es einen wohldefinierten Zustandssummenoperator fuer endliche EABC-Spektren?
- Welche Spektralparameter sind fuer robuste Entropie-Schaetzungen stabil?
- Wann sind thermodynamische Groessen reine Reparametrisierungen vorhandener Observablen?

## Bulk-Boundary / Rekonstruktion

- Lassen sich Bulk-/Boundary-Projektionen formal definieren?
- Welche Randinvarianten beschraenken innere Freiheitsgrade minimal?
- Gibt es eine diskrete Rekonstruktionsabbildung mit wohldefinierter Fehlerschranke?

## Korrelation und Nichtfaktorisierbarkeit

- Existieren nichtfaktorisierbare EABC-Korrelationen in kanonischer Modellklasse?
- Lässt sich ein Bell-typisches Testfunktional als diskrete Operatorform definieren?
- Welche Transfer-/Labelkanaele bewahren rekonstruktive Information?

## Projekt „Die drei Musketiere“ (E-026)

- Existiert in jedem Bremensaal ein Nachbar-Dreier der drei uebrigen EABC-Familien?
- Unter welchen Annahmen ist die Musketiere-Nachbar-Relation objektiv (chi-Aequivalenz / `LabelPreservingGraphMap`)?
- Welche `A5`-Orbits der 6 scheiternden toy-Embeddings liegen ausserhalb des kanonischen Partitionsmusters (`E-028`)?

## Fixed-Locus / Riemann-Programm (L4)

### ORQ-087: Weyl-Commutator Operator Bridge

- **Kontext:** Weyl-Algebra \([A,B]=AB-BA=I\) als kanonischer nichtkommutativer Defekt; Anschluss an Dedekind-Idealpfade \(H\gamma\) vs.\ \(\gamma H\) (ORQ-085) und Berry-Holonomie (ORQ-083).
- **Kernfrage:** Kann die Links/Rechts-Asymmetrie von Hurwitz-Idealpfaden als Kommutator-Defekt \(\Delta_{\mathrm{LR}}(\gamma)=\|\mathcal{H}\gamma-\gamma\mathcal{H}\|\) gemessen werden?
- **Status:** `[C]` — `[B]`-Upgrade über `weyl_commutator_diagnostics.py` mit Nullmodellen (CEAB, Kanal-Shuffle, Norm-Match).
- **Abhängigkeiten:** ORQ-085 ($\Phi(v)=\gamma$), ORQ-083 (Holonomie); komplementär zu `norm_signature_defect` in `diagnostics.py`.
- **Dossier:** [`theory/weyl_commutator_operator_bridge.md`](theory/weyl_commutator_operator_bridge.md)

### ORQ-092: Nuclear Residual EABC Correlation

- **Kontext:** Kernbindungs-Residuen \(R(A,Z)=B_{\mathrm{exp}}-B_{\mathrm{smooth}}\) (Weizsäcker-Hülle) tragen Schalen-, Paarungs- und Kollektivstruktur; EABC-Invarianten \(I_{\mathrm{EABC}}\) sind arithmetisch definiert — methodische Parallele zu glatt-plus-Fehler-Zerlegungen (\(\pi(x)=\mathrm{Li}(x)+E(x)\)).
- **Kernfrage:** Erklärt \(I_{\mathrm{EABC}}\) einen Teil von \(R(A,Z)\) über Permutations-/Shuffle-Nullmodelle hinaus — nicht die volle Bindungskurve?
- **Status:** `[C]` — `[B]`-Upgrade über präregistriertes Protokoll (Pearson, Spearman, MI, PCA, Fourier/Wavelet; Nullmodelle Pflicht).
- **Abhängigkeiten:** E-076 (Bulk/Shell-Lesesprache), E-092; komplementär zu Weierstrass-Multiscale-Export.
- **Dossier:** [`theory/nuclear_binding_multiscale_analogy.md`](theory/nuclear_binding_multiscale_analogy.md) §5

### ORQ-089: Onsager Quantization Bridge

- **Kontext:** Lars Onsagers vier Grundbeiträge — Flussquantisierung ($\Phi_0=h/2e$), quantisierte Wirbel (Onsager–Feynman), exakte 2D-Ising-Lösung, Reziprozitätsbeziehungen — als Resonanzsprache für diskrete EABC-Strukturen.
- **Kernfrage:** Lassen sich Diskretisierung, Umlauf, Kritikalität und Zeitumkehr entlang der vier Onsager-Achsen operationalisieren, ohne physikalische Identifikation?
- **Status:** `[C]` — `[B]`-Upgrade über vorgeschlagene Diagnostik (Diskretisierungs-Index, Zirkulations-Defekt, Separations-Kritikalitäts-Profil, Reversibilitäts-Asymmetrie).
- **Abhängigkeiten:** Ergänzt E-076 (AB/Klitzing/Meissner); komplementär zu ORQ-080/083 (Wirbel/Holonomie), ORQ-087 (Reversibilität), ORQ-077–079 (Kritikalität).
- **Dossier:** [`theory/onsager_quantization_bridge.md`](theory/onsager_quantization_bridge.md)

### ORQ-088: Fixed-Locus Nullstellen-Konfinierung via SDTC

- **Kontext:** Involutive Selbstdualität \(D(s)=1-\bar{s}\); Lokations-Aussage \(\sigma=\tfrac{1}{2}\) als Fixpunkt-Locus; programmatischer HoTT-Anschluss (Identitätstyp \(D(z)\equiv z\)).
- **Kernfrage:** Lässt sich die Abweichung einer Nullstelle von der kritischen Linie als anti-invarianter spektraler Operator \(\mathcal{A}\) so darstellen, dass *Self-Dual Trace Confinement (SDTC)* eine spurlos gegen Null konvergierende Dominanz erzwingt?
- **Status:** `[C / programmatisch-offen]` — kein Register-Upgrade ohne explizite Operator-Brücke.
- **Abhängigkeiten:** Lean-Stufe 3 (abstraktes Symmetrie-Skelett); blockiert nicht den Daten-Kanonisierungs-Branch `extract-energiedoku-shell-coordinates-n1-n3`.
- **Gegen-Evidenz:** E-034 (`[C]` refuted) — Kosinus-Mittelung über \(\Delta M\) erzeugt keine Trennschärfe; E-035 (`[C]` open_hypothesis) — Skalenpfad offen.
- **Dossier:** [`theory/fixed_locus_riemann_program.md`](theory/fixed_locus_riemann_program.md)

---

## ORQ-Index: Bridge Targets (priorisiert)

Vollstaendige Statements, Governance-Tabelle und Durchbruchspfad: [`open_mathematical_bridge_targets.md`](open_mathematical_bridge_targets.md).

| Prio | ORQ | Kurztitel | E-ID | Status |
|---|---|---|---|---|
| 1 | ORQ-077 | `MetricSeparationLossExist` | E-077 | `[C]` → `[B]`-Ziel |
| 2 | ORQ-078 | Globale R³-Einbettung | E-078 | `[C]` |
| 3 | ORQ-079 | Minkowski–Bouligand | E-079 | `[C]` |
| 4 | ORQ-085 | Dedekind $\Phi(v)=\gamma$ | E-067–E-069 | `[C]` |
| 5 | ORQ-083 | Berry-Holonomie | E-083 | `[C]` |
| 6 | ORQ-084 | `GeometryScaffold` | E-084 | `[C]` |
| 7 | ORQ-080 | Hurwitz-Windungs-Monopol | E-080 | `[C]` |
| 8 | ORQ-081 | Dirac–Schwinger emergent | E-081 | `[C]` |
| 8 | ORQ-082 | Dipol/Oktupol-Monopol | E-082 | `[C]` |
| 9 | ORQ-086 | `shellPrimeMatchAtFirstLoss` | E-085 | `[C]` GATE INACTIVE / PRE-REGISTRATION NOT COMPLETE (→ Protokoll Pre-Registration Gate) |
| 10 | ORQ-087 | Weyl-Commutator $\Delta_{\mathrm{LR}}$ | — | `[C]` → `[B]`-Ziel |
| 11 | ORQ-089 | Onsager Quantization Bridge | E-089 | `[C]` |
| 12 | ORQ-092 | Nuclear residual \(I_{\mathrm{EABC}}\) vs. \(R(A,Z)\) | E-092 | `[C]` → `[B]`-Ziel |

**Shell-Separationsdiagnostik (E-077–E-079):** Mess-Schicht `[C]` — [`reports/shell_separation_diagnostics_protocol.md`](reports/shell_separation_diagnostics_protocol.md) · CSV via `scripts/shell_separation_diagnostics.py`

**Meissner (E-076):** Interpretive Lesesprache nur fuer ORQ-077 — siehe [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md).
