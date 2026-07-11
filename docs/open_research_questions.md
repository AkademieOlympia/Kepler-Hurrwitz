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

## Projekt „Nuclear Binding Residual Bridge“ (E-090 / ORQ-090)

- Liefert \(I_{\mathrm{EABC}}(Z,N)=(Z\bmod 12,N\bmod 12)\) **zusätzliche** out-of-sample Information über SEMF-Residuen \(R_{\mathrm{no\,pair}}\), \(R_{\mathrm{pair}}\) über Paritätskontrolle und strukturtreue Nullmodelle hinaus?
- Sind SEMF-Koeffizienten strikt auf Trainings-Splits geschätzt und Residuen auf gehaltenen Test-Splits bewertet (blockiert nach \(Z\), Isotopenketten, \(A\)-Bins)?
- Besteht ein positiver \(\Delta\mathrm{MAE}_{\mathrm{CV}}\) robust über mehrere Nullmodelle (A-Bin, Paritätsklasse, Isotopenketten-Shift, strukturangepasst)?

**Prüfmodus:**

```bash
pytest tests/test_nuclear_binding_residual_bridge.py -q
```

**Dossier:** [`reports/orq_090_nuclear_binding_residual_bridge.md`](reports/orq_090_nuclear_binding_residual_bridge.md)

## Projekt „Atome“ (E-092 / ORQ-092)

- Korrelieren EABC-Invarianten \(I_{\mathrm{EABC}}(A,Z)\) mit Kernbindungs-Residuen \(R(A,Z)=B_{\mathrm{exp}}-B_{\mathrm{smooth}}\) über Nullmodelle hinaus?
- Liefert die Residualschicht (nicht \(B_{\mathrm{exp}}\)) belastbare Mehrskalen-Signatur (PCA, Fourier/Wavelet entlang \(\log A\))?
- Welche präregistrierte Weizsäcker-Parameterwahl und AME-Schnittmenge sind für einen `[B]`-Upgrade reproduzierbar?

**Prüfmodus:**

```bash
PYTHONPATH=src python examples/run_atome_residual_export.py
pytest tests/test_nuclear_binding_residual.py -q
```

**Dossier:** [`atome_hypothese.md`](atome_hypothese.md) · Vollprotokoll [`theory/nuclear_binding_multiscale_analogy.md`](theory/nuclear_binding_multiscale_analogy.md) §5

## Projekt „Black Hole“ (E-093 / ORQ-093)

- Korrelieren Legendre-verbotene Massenschalen (bei präregistriertem \(\kappa\)) mit \(\chi_p\)-Stratifizierung (1G vs. 2G) über Fisher-Test und Permutations-Nullmodelle hinaus?
- Liefert der \(\kappa\)-Sweep ein resonantes Minimum **nur** auf echtem GWTC-5-Katalog — nicht auf Mock-Daten?
- Welche Toleranz \(\tau\) und Primnorm-Obergrenze sind für ORQ-093 präregistriert?

**Prüfmodus:**

```bash
PYTHONPATH=src python examples/run_black_hole_gwtc_export.py
pytest tests/test_black_hole_legendre_gwtc.py tests/test_black_hole_governance_docs.py -q
```

**Dossier:** [`black_hole_hypothese.md`](black_hole_hypothese.md) · Vollprotokoll [`theory/black_hole_legendre_gwtc_bridge.md`](theory/black_hole_legendre_gwtc_bridge.md) · Claim-Register [`black_hole/claim_register.md`](black_hole/claim_register.md)

## Projekt „Phaseninvarianz“ (E-094 / ORQ-094)

- Bleibt \(E_a = a_x^2 + a_y^2\) unter Pauli Z (\(a_x \to -a_x\)) und X (\(a_x \leftrightarrow a_y\)) algebraisch exakt invariant?
- Restrukturieren partielle Tensor-X-Fehler (\(b_x \leftrightarrow c_x\)) die quartischen \(E_{bc}\)-Kreuzterme signifikant über symmetrische Spezialfälle hinaus?
- Lässt sich die QEC-Schutz-Lesesprache für die 6k+1-Primachse \(a\) über Fehler-Injektions-Nullmodelle empirisch trennen?

**Prüfmodus:**

```bash
PYTHONPATH=src python examples/run_phaseninvarianz_export.py
pytest tests/test_phaseninvarianz_pauli_energy.py tests/test_phaseninvarianz_governance_docs.py -q
```

**Dossier:** [`phaseninvarianz_hypothese.md`](phaseninvarianz_hypothese.md) · Vollprotokoll [`theory/phaseninvarianz_pauli_energy_bridge.md`](theory/phaseninvarianz_pauli_energy_bridge.md) · Claim-Register [`phaseninvarianz/claim_register.md`](phaseninvarianz/claim_register.md)

### ORQ-094: Pauli Phase Invariance on EABC Energy

- **Kontext:** Energetische Quadratsummen-Substitution (BH-C-11) liefert \(E_a\) (quadratisch) und \(E_{bc}\) (quartisch); Pauli-Operatoren auf Amplituden testen Schutz vs. Verwundbarkeit; QEC-Grammatik aus E-044/BH-C-09 als Lesesprache.
- **Kernfrage:** Ist die \(a\)-Achse (6k+1-Primachsen) gegen Phasen-/Bitflip-Fehler algebraisch geschützt, während der \(bc\)-Bivektor volle Fehlerkorrektur erfordert?
- **Status:** `[C]` — `[A/B]`-Invarianzfakten reproduzierbar; `[B]`-Upgrade über präregistriertes Fehler-Injektionsprotokoll.
- **Abhängigkeiten:** E-093 (BH-C-11 Energetik), E-044 (`qec_bridge.py`), BH-C-09 (symplektische Stabilisator-Brücke).
- **Dossier:** [`phaseninvarianz_hypothese.md`](phaseninvarianz_hypothese.md) · [`theory/phaseninvarianz_pauli_energy_bridge.md`](theory/phaseninvarianz_pauli_energy_bridge.md)

### ORQ-093: Legendre-GWTC Mass-Gap Correlation

- **Kontext:** Drei-Quadrate-Obstruktion \(4^a(8b+7)\) induziert verbotene EABC-Normschalen; GWTC-Massen erfordern Quantisierung \(\kappa: M_\odot \to \mathbb{Z}\); \(\chi_p\) stratifiziert 1G/2G-Kandidaten.
- **Kernfrage:** Meiden 1G-Systeme Legendre-Lücken signifikant häufiger als 2G-Merger-Kandidaten?
- **Status:** `[C]` — `[B]`-Upgrade über `black_hole_legendre_gwtc.py` mit echtem GWTC, präregistriertem \(\kappa\) und Nullmodellen.
- **Präregistrierung:** **LOCK** (07.07.2026) — [`black_hole/preregistration_gwtc5.md`](black_hole/preregistration_gwtc5.md) (BH-GOV-01): Phase 1 GWTC-3-Grid (92 Tests, Bonferroni) → \((\kappa^*, \tau^*)\); Phase 2 GWTC-4/5 blind.
- **Abhängigkeiten:** E-076, `GodelKerr.lean`; komplementär zu E-092 (Residual-Test-Methodik).
- **Dossier:** [`black_hole_hypothese.md`](black_hole_hypothese.md) · [`theory/black_hole_legendre_gwtc_bridge.md`](theory/black_hole_legendre_gwtc_bridge.md) · [`black_hole/preregistration_gwtc5.md`](black_hole/preregistration_gwtc5.md)

### ORQ-095: Riemann Zero Interference at bc-Axis Nodes

- **Kontext:** Explizite-Formel-Oszillationen \(\cos(\gamma\ln x)\); EABC bc-Achse (mod 6); Geschwister zu E-092 (Residual-Oszillation), E-094 (Cross-Talk \(\Delta E\)), E-034/E-035 (mean-cos-Abgrenzung).
- **Kernfrage:** Zeigt \(S(x;\Gamma)=\sum_{\gamma\in\Gamma}\cos(\gamma\ln x)\) an präregistrierten Knoten signifikante Prim/Komposit-Trennung (insb. bc-Stratifizierung) über Zufalls-\(\Gamma\) hinaus?
- **Status:** `[C]` — `[B]`-Diagnostik-Stub; Nullmodell-Pflicht vor Discovery-Claim.
- **Abhängigkeiten:** E-034, E-035, E-092, E-094 (PI-C-03).
- **Dossier:** [`theory/riemann_zero_interference_analogy.md`](theory/riemann_zero_interference_analogy.md)

**Prüfmodus:**

```bash
PYTHONPATH=src python examples/run_riemann_interference_export.py
pytest tests/test_riemann_interference_diagnostics.py -q
```

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

### ORQ-090: Nuclear Binding Residual Bridge

- **Kontext:** SEMF-Residuen \(R=B_{\mathrm{exp}}-B_{\mathrm{SEMF}}\) mit vorab definierter EABC-Klassifikation \((Z\bmod 12,N\bmod 12)\mapsto\{E,A,B,C,\mathrm{non\mbox{-}EABC}\}\); Kontrollhierarchie gegen \(A,Z,I_{\mathrm{parity}}\).
- **Kernfrage:** Trägt \(I_{\mathrm{EABC}}\) **zusätzliche** statistische Information über Bindungsresiduen — nicht die volle Bindungskurve, kein physikalischer Mechanismus?
- **Status:** `[C]` — Promotion-Ziel `[B0]` über `nuclear_binding_residual_bridge.py`; kein Upgrade zu Kernphysik-Claim.
- **Abhängigkeiten:** Geschwister ORQ-092 (E-092); komplementär zur multiskaligen Korrelationsbatterie in `nuclear_binding_residual.py`.
- **Dossier:** [`reports/orq_090_nuclear_binding_residual_bridge.md`](reports/orq_090_nuclear_binding_residual_bridge.md)

### ORQ-092: Nuclear Residual EABC Correlation

- **Kontext:** Kernbindungs-Residuen \(R(A,Z)=B_{\mathrm{exp}}-B_{\mathrm{smooth}}\) (Weizsäcker-Hülle) tragen Schalen-, Paarungs- und Kollektivstruktur; EABC-Invarianten \(I_{\mathrm{EABC}}\) sind arithmetisch definiert — methodische Parallele zu glatt-plus-Fehler-Zerlegungen (\(\pi(x)=\mathrm{Li}(x)+E(x)\)).
- **Kernfrage:** Erklärt \(I_{\mathrm{EABC}}\) einen Teil von \(R(A,Z)\) über Permutations-/Shuffle-Nullmodelle hinaus — nicht die volle Bindungskurve?
- **Status:** `[C]` — `[B]`-Upgrade über `nuclear_binding_residual.py` und präregistriertes Protokoll (Pearson, Spearman, MI, PCA, Fourier/Wavelet; Nullmodelle Pflicht).
- **Abhängigkeiten:** E-076 (Bulk/Shell-Lesesprache), E-092; komplementär zu Weierstrass-Multiscale-Export.
- **Dossier:** [`atome_hypothese.md`](atome_hypothese.md) · [`theory/nuclear_binding_multiscale_analogy.md`](theory/nuclear_binding_multiscale_analogy.md) §5

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
| 12 | ORQ-090 | Nuclear binding residual bridge (SEMF + \(I_{\mathrm{EABC}}\)) | E-090 | `[C]` → `[B0]`-Ziel |
| 13 | ORQ-092 | Nuclear residual \(I_{\mathrm{EABC}}\) vs. \(R(A,Z)\) | E-092 | `[C]` → `[B]`-Ziel |
| 14 | ORQ-093 | Legendre-GWTC mass-gap vs. \(\chi_p\) | E-093 | `[C]` → `[B]`-Ziel |
| 15 | ORQ-094 | Pauli phase invariance on EABC energy | E-094 | `[C]` → `[B]`-Ziel |
| 16 | ORQ-095 | Riemann zero interference at bc-axis nodes | E-095 | `[C]` → `[B]`-Ziel |

**Shell-Separationsdiagnostik (E-077–E-079):** Mess-Schicht `[C]` — [`reports/shell_separation_diagnostics_protocol.md`](reports/shell_separation_diagnostics_protocol.md) · CSV via `scripts/shell_separation_diagnostics.py`

**Meissner (E-076):** Interpretive Lesesprache nur fuer ORQ-077 — siehe [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md).
