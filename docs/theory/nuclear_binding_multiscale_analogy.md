---
title: Kernbindungsenergie — Mehrskalen-Analogie und EABC-Residualhypothese
date: 2026-07-06
status: "[C]"
evidence_id: E-092
claim_boundary: >-
  Kernbindungskurve B_exp(A,Z) liefert Lesesprache für glatte Weizsäcker-Hülle B_smooth plus
  Residuen R(A,Z) — kein EABC-Kernphysik-Claim, keine Identität zwischen Nukleonen und
  Primvierling-Invarianten. EABC-Vergleich zielt methodisch auf R(A,Z), nicht auf die volle
  Bindungskurve; empirische Verifikation (I_EABC vs. R, Nullmodelle) ist Voraussetzung für [B].
not_claimed:
  - EABC erklärt oder reproduziert die Semi-Empirische Massenformel
  - Weizsäcker-Terme sind formal identisch mit EABC-Renorm-Termen
  - Korrelation von EABC-Invarianten mit R(A,Z) ist bereits nachgewiesen
  - Weierstrass-Multiscale-Befund an ABCE/CEAB-Bias überträgt sich auf Kernphysik
  - EABC erklärt Kernbindung oder ersetzt die Nuklearphysik-Hülle
---

> **Evidence status:** `[C]` konzeptionelle Brücke (E-092)  
> **Governance (DE):** Heuristische Brücke / Lesesprache nur — keine Physik-Identität, kein EABC-Kernbindungs-Claim. Jeder EABC-Vergleich muss experimentelle **Residuen** \(R(A,Z)\) treffen, nicht die volle Kurve \(B_{\mathrm{exp}}\). Upgrade zu `[B]` erst nach präregistriertem Export und Nullmodell-Nachweis.  
> **Governance (EN):** Heuristic bridge / reading language only — not a physics identity, not an EABC nuclear claim. Any EABC comparison must target experimental **residuals** \(R(A,Z)\), not the full binding curve \(B_{\mathrm{exp}}\). `[B]` upgrade requires preregistered export and null-model evidence.

# Kernbindungsenergie pro Nukleon — Mehrskalen-Struktur und EABC-Residualhypothese

**Stand:** 6. Juli 2026  
**Register:** E-092 (ergänzt E-076 Physik-Referenz-Analogien)  
**Schicht:** L4 / Phase-C — methodische Lesesprache, keine Diagnostik implementiert

---

## Kurzfassung

Die experimentelle Kurve der mittleren Bindungsenergie pro Nukleon \(B/A\) gegen die Massenzahl \(A\) zeigt **drei Regime**, eine **glatte Mehrskalen-Hülle** und **diskrete Residuen** (Schalen-, Magic-Number- und Paarungseffekte). Die Semi-Empirische Massenformel (Weizsäcker) fasst die Hülle als **Summe heterogener Potenzgesetze** in \(A\) — kein einzelnes Skalengesetz.

Für EABC gilt methodisch:

\[
\boxed{
R(A,Z) = B_{\mathrm{exp}}(A,Z) - B_{\mathrm{smooth}}(A,Z)
\quad\text{— nicht die volle Kurve } B_{\mathrm{exp}}.}
\]

Erst wenn EABC-Invarianten \(I_{\mathrm{EABC}}\) mit experimentellen Residuen \(R(A,Z)\) über Nullmodelle hinaus korrelieren, ist ein tieferer Physik-Dialog vertretbar. Bis dahin: **`[C]`-Hypothese nur**.

---

## 1. Drei Regime der Bindungskurve

| Regime | Massenzahl \(A\) | Charakter | Lesefrage |
|---|---|---|---|
| **Leichte Kerne** | \(A \lesssim 20\) | Aufbau, starke Abhängigkeit von einzelnen Nukleonen | Wo dominiert „Aufbau“ gegenüber Hüllentermen? |
| **Mittlere Kerne** | \(\sim 40 \ldots 100\) | Maximum nahe Fe/Ni (\(B/A \approx 8{,}8\,\mathrm{MeV}\)) | Wo sitzt der globale Fixpunkt der Hülle? |
| **Schwere Kerne** | \(A \gg 100\) | Abfall durch Coulomb-Repulsion | Wo überwiegt der langreichweitige Abstoßungsterm? |

Die Kurve ist **nicht** durch eine einzige Potenz \(A^\alpha\) beschreibbar; Regimewechsel und lokale Struktur sind strukturell wichtig.

---

## 2. Formale Residualstruktur \(R(A,Z)\)

### Definition

Sei \(B_{\mathrm{exp}}(A,Z)\) die experimentelle Bindungsenergie eines Kerns mit Massenzahl \(A\) und Protonenzahl \(Z\), und \(B_{\mathrm{smooth}}(A,Z)\) die glatte Referenzhülle aus der Semi-Empirischen Massenformel (Weizsäcker) oder einer äquivalenten tabellierten Hülle mit **fest vorab** dokumentierten Parametern:

\[
\boxed{
R(A,Z) = B_{\mathrm{exp}}(A,Z) - B_{\mathrm{smooth}}(A,Z).
}
\]

Die pro-Nukleon-Residualkurve ist die Projektion

\[
r(A,Z) = \frac{B_{\mathrm{exp}}(A,Z)}{A} - \frac{B_{\mathrm{smooth}}(A,Z)}{A}
= \frac{R(A,Z)}{A}.
\]

**Governance:** \(B_{\mathrm{smooth}}\) wird **nicht** für EABC optimiert. Parameterwahl und Fitfenster sind Teil des Protokolls, nicht des EABC-Vergleichs.

### Zerlegung: glatte Hülle plus Residuen

\[
B_{\mathrm{exp}}(A,Z) = B_{\mathrm{smooth}}(A,Z) + R(A,Z).
\]

| Anteil | Inhalt | Skala |
|---|---|---|
| \(B_{\mathrm{smooth}}(A,Z)\) | Volumen-, Oberflächen-, Coulomb-, Asymmetrie-Trend der Weizsäcker-Hülle | glatt in \(A,Z\) (Potenzgesetze, ggf. \(\log A\)) |
| \(R(A,Z)\) | Quantenstruktur, Schalen, Paarung, Deformation, kollektive Anregungen | diskret / schmalbandig / lokal |

**Governance:** \(B_{\mathrm{smooth}}\) ist das **Bulk-/Hüllen-Analogon** (vergleichbar zur Meissner-Lesart „isotroper Trend“ in E-076). \(R(A,Z)\) ist das **Shell-/Feinstruktur-Analogon** — dort, wo EABC-Vergleiche methodisch ansetzen sollen, nicht auf der Gesamtkurve.

---

## 2a. Was in den Residuen steckt (Quanteninhalt)

Weizsäcker erklärt typischerweise **95–99 %** der Bindungsenergie; der verbleibende Anteil \(R(A,Z)\) trägt den **quantenmechanischen Feinstruktur-Inhalt**:

| Struktur | Erscheinung in \(R(A,Z)\) | Charakter |
|---|---|---|
| **Magic Numbers** | 2, 8, 20, 28, 50, 82, 126 — Schalenlücken, Plateaus in \(B/A\) | diskrete Stufen |
| **Paarung** | Zigzag zwischen geraden/ungeraden \(Z,N\); \(\delta\)-Term in SEMF | alternierend, \(\pm 1\)–2 MeV |
| **Deformation** | Abweichungen vom Kugelmodell (elliptische Kerne) | breitbandig, \(A \gtrsim 150\) |
| **Kollektive Anregungen** | Rotations-/Schwingungsbandstruktur | schmalbandige Moden über Schalengrundzustand |

\[
\boxed{
\text{Informationsgehalt: } \underbrace{B_{\mathrm{smooth}}}_{\sim 95\text{–}99\,\%} + \underbrace{R(A,Z)}_{\sim 1\text{–}0{,}1\,\% \text{ — aber gesamte Quantenphysik}}
}
\]

Die **kleine relative Varianz** von \(R\) bedeutet nicht geringe physikalische Bedeutung: dort sitzen Schalen-, Paarungs- und Kollektivstruktur — analog zum Fehlerterm in anderen glatt-plus-Rest-Zerlegungen (siehe §2b).

**EABC-Lesefrage `[C]`:** Erklärt ein EABC-Invariant \(I_{\mathrm{EABC}}\) einen **Teil** von \(R(A,Z)\) — nicht die volle Bindungskurve?

---

## 2b. Analogie: Primzählzählung \(\pi(x) = \mathrm{Li}(x) + E(x)\) `[C]`

In der analytischen Zahlentheorie gilt das Standardbild

\[
\pi(x) = \mathrm{Li}(x) + E(x),
\]

wobei \(\mathrm{Li}(x)\) die glatte Hauptterm-Hülle ist und \(E(x)\) der oszillierende Fehlerterm (Riemann-Nullstellen, Primzahllücken).

| Zerlegung | Glatte Hülle | Residuum / Fehler |
|---|---|---|
| Primzählzählung | \(\mathrm{Li}(x)\) | \(E(x)\) |
| Kernbindung | \(B_{\mathrm{smooth}}(A,Z)\) (Weizsäcker) | \(R(A,Z)\) |
| EABC (methodisch) | Trend / Detrend auf \(\log p\) | ABCE/CEAB-Bias, Spektralpeaks |

**Gemeinsame Lesefrage `[C]`:** Liegt das interessante Signal in der **Fehler-/Residualschicht**, nicht in der glatten Hauptkurve?

**Nicht behauptet:** \(R(A,Z)\) ist formal identisch mit \(E(x)\) oder mit EABC-Bias; die Analogie ist **methodisch** (glatt + Rest), nicht ontologisch.

---

## 3. Weizsäcker als Mehrskalen-Modell (nicht Ein-Potenz-Gesetz)

Die Semi-Empirische Massenformel (vereinfacht) schreibt die Bindungsenergie als Summe heterogener Terme:

\[
B(A,Z) \approx a_V A - a_S A^{2/3} - a_C \frac{Z(Z-1)}{A^{1/3}} - a_A \frac{(A-2Z)^2}{A} + \delta(A,Z).
\]

| Term | Skalierung | Rolle |
|---|---|---|
| Volumen | \(\propto A\) | Bulk-Energie |
| Oberfläche | \(\propto A^{2/3}\) | Rand-/Shell-Korrektur |
| Coulomb | \(\propto Z^2 / A^{1/3}\) | langreichweitige Abstoßung |
| Asymmetrie | \(\propto (A-2Z)^2/A\) | Neutron-Proton-Ungleichgewicht |
| \(\delta\) | diskret (Paarung) | lokales Residuum |

**Kernsatz:** Weizsäcker ist ein **Mehrskalen-Modell** — Summe von Potenzen mit **unterschiedlichen Exponenten**, nicht ein fraktales Einzelgesetz.

### \(\log A\) als gemeinsame Achse

Potenzterme \(A^\alpha\) werden auf der \(\log A\)-Achse zu **verschiedenen linearen Steigungen** in \(\log A\). Das erleichtert numerisches Ausbalancieren und den Vergleich mit anderen Mehrskalen-Diagnostiken im Repo (z. B. Spektren entlang \(\log p\) bei Primvierlingen).

**Nicht behauptet:** Weizsäcker-Exponenten sind identisch mit EABC-Skalen oder Weierstrass-Frequenzen.

---

## 4. Verbindung zur Weierstrass-Mehrskalen-Lesart im Repo

Im Repo existiert eine **arithmetische** Weierstrass-Multiscale-Diagnostik (ABCE/CEAB-Bias \(B(N)\) entlang \(\log p\)) — strikt getrennt von Kernphysik:

| Artefakt | Rolle | Status |
|---|---|---|
| [`eabc_weierstrass_multiscale_report.md`](../energiedoku_exports/eabc_weierstrass_multiscale_report.md) | Deskriptiver Export, FFT/Lomb–Scargle auf \(\log p\) | `[C]` inconclusive |
| `src/kepler_hurwitz/eabc_weierstrass_multiscale.py` | Numerisches Scaffold | `[B]` experimental |
| `KeplerHurwitz/EabcWeierstrassMultiscaleInterface.lean` | Lean-Placeholder für Hypothese | `[C]` |

**Gemeinsame Lesefrage (nur Analogie):** Liegt das interessante Signal in einer **glatten Mehrskalen-Hülle** plus **Reststruktur**, nicht in einem einzelnen globalen Potenzgesetz?

| Kontext | Glatte Hülle | Residuum / Feinstruktur |
|---|---|---|
| Kernbindung | Weizsäcker \(B_{\mathrm{smooth}}(A,Z)\) | \(R(A,Z)\): Magic, Paarung, Deformation |
| EABC Weierstrass | Trend / Detrend von \(B(N)\) | Spektralpeaks, ABCE/CEAB-Bias |
| EABC Renorm (E-053) | \(M_{\mathrm{eff}} \to 24I_3\) | Defekt an Shell / Rand (E-076 Meissner) |

Die Weierstrass-Exporte belegen **keine** Kernphysik und umgekehrt. Die Brücke ist **methodisch**: erst Hülle/Residual trennen, dann Invarianten testen.

---

## 5. EABC-Residualhypothese und empirisches Testprotokoll `[C]`

### Was nicht verglichen werden soll

Die volle Kurve \(B_{\mathrm{exp}}(A,Z)\) oder \(B/A\) mischt Bulk-Trend, Coulomb-Abfall und alle lokalen Quanteneffekte. Ein direkter EABC-Fit auf \(B_{\mathrm{exp}}\) wäre **überdeterminiert** und governance-unsauber (Post-hoc-Analogie).

### Was verglichen werden soll (wenn überhaupt)

\[
R(A,Z) = B_{\mathrm{exp}}(A,Z) - B_{\mathrm{smooth}}(A,Z)
\]

gegen EABC-Invarianten \(I_{\mathrm{EABC}}\) auf einer **fest vorab** gewählten Indexachse (z. B. Primindex, Shell-Label, Kanalmetrik, \(\log A\)-Gitter).

**Kernfrage (ORQ-092, `[C]`):**

\[
\boxed{
\text{Erklärt } I_{\mathrm{EABC}} \text{ einen Teil von } R(A,Z) \text{ — besser als ein Nullmodell?}
}
\]

### Protokoll: \(I_{\mathrm{EABC}}\) vs. \(R(A,Z)\) `[C]`

| Schritt | Vorgabe | Governance |
|---|---|---|
| 1. Referenzhülle | Weizsäcker-Parameter oder AME/ENSDF-Tabellen; **präregistriert**, nicht EABC-optimiert | dokumentiert |
| 2. Residuen-Export | \(R(A,Z)\) pro stabiler Kern; optional \(r(A,Z)=R/A\) auf \(\log A\)-Gitter | reproduzierbar |
| 3. EABC-Invarianten | unabhängig von Hüllen-Fit; z. B. Shell-Label, Kanalentropie, Primvierling-Metrik | fest vorab |
| 4. Korrelationsmetriken | Pearson \(r\), Spearman \(\rho\), gegenseitige Information \(\mathrm{MI}(I_{\mathrm{EABC}}, R)\) | alle reportieren |
| 5. Mehrvariates Profil | PCA auf \((I_{\mathrm{EABC},k}, R)\)-Feature-Matrix; Fourier-/Wavelet-Spektren von \(R\) entlang \(\log A\) | explorativ, nicht cherry-picken |
| 6. Nullmodelle | Permutation, Kanal-Shuffle, Varianz-Match — wie bei Weierstrass-/Dumas-Protokollen | **Pflicht** für `[B]` |
| 7. Urteil | EABC erklärt Residuen **nur** wenn Effekt signifikant über Shuffle/Permutation hinaus | kein Post-hoc-Best-Fit |

**Voraussetzung für Upgrade zu `[B]`:** reproduzierbarer Export, präregistrierte Hülle, Permutations-/Shuffle-Nullmodelle, keine Auswahl der „besten“ Korrelation post hoc.

**Aktueller Stand:** Projekt **„Atome“** — Diagnostik-Stub `nuclear_binding_residual.py` (`[C]`); Export über `examples/run_atome_residual_export.py` → `docs/exports/atome_residual_*`. Vollständiger AME-Schnitt und `[B]`-Nullmodell-Nachweis noch offen.

### Implementierter Stub (Projekt „Atome“)

| Artefakt | Pfad |
|---|---|
| Projekt-Dossier | [`../atome_hypothese.md`](../atome_hypothese.md) |
| Diagnostik | `src/kepler_hurwitz/nuclear_binding_residual.py` |
| Export | `examples/run_atome_residual_export.py` |
| Toy-Daten | `data/atome/toy_nuclides.csv` |

```bash
PYTHONPATH=src python examples/run_atome_residual_export.py
pytest tests/test_nuclear_binding_residual.py -q
```

---

## 6. Einordnung zu E-076 (Meissner) und Geschwister-Brücken

| Brücke | E-ID | Parallele Lesefrage |
|---|---|---|
| Meissner Bulk/Shell | E-076 | Defekt aus Bulk in Randschale — \(B_{\mathrm{smooth}}\) vs. \(R(A,Z)\) |
| Onsager / Hall | E-089 | Diskrete Stufen, Reziprozität — Magic Numbers als „Plateaus“? |
| Weyl–Onsager | E-087, E-088 | Lokale Chiralität vs. globale Symmetrie — leichte vs. schwere Kerne |
| Weierstrass (arithmetisch) | (Export, kein separates E-ID) | \(\log\)-Achse, Mehrskalen-Hülle + Rest |

Meissner (E-076) und Kernbindung teilen **keine Physik**, aber dieselbe **Zerlegungsfrage**:

\[
\text{Was ist isotroper Trend? Was bleibt als Shell-Residual?}
\]

Siehe [`meissner_analogy_assessment.md`](meissner_analogy_assessment.md) und [`physical_reference_analogies.md`](../reports/physical_reference_analogies.md).

---

## 7. Methodischer Fahrplan (Dokumentation only)

1. **Referenzhülle fixieren** — Weizsäcker-Parameter oder AME/ENSDF-Tabellen; dokumentieren, nicht optimieren für EABC.
2. **Residuen \(R(A,Z)\) extrahieren** — pro \((A,Z)\) oder auf \(\log A\)-Gitter; Export als CSV/JSON.
3. **EABC-Invarianten \(I_{\mathrm{EABC}}\) auf kompatible Achse** — unabhängig vom Fit der Hülle.
4. **Korrelationsbatterie** — Pearson, Spearman, MI, PCA, Fourier/Wavelet von \(R\) (§5).
5. **Nullmodelle** — Permutation, Kanal-Shuffle, gleiche Varianz wie bei Weierstrass-/Dumas-Protokollen.
6. **Erst dann** — eventuell `[B]`-Diagnostik-Modul (§5 Stub); kein Physik-Identity-Claim.

---

## 7b. Offene Forschungsfrage

**ORQ-092:** Korrelieren EABC-Invarianten mit Kernbindungs-Residuen \(R(A,Z)\) über Nullmodelle hinaus?  
→ [`../open_research_questions.md`](../open_research_questions.md) · Vollprotokoll §5 oben.

---

## 8. Governance (verbindlich)

| Claim | Erlaubt? |
|---|---|
| Drei-Regime- und Hülle+Residual-Bild als **Lesesprache** | Ja — `[C]` |
| Weizsäcker als Mehrskalen-Analogon zu \(\log\)-Skalen-Diagnostik | Ja — `[C]`, nicht Identität |
| EABC soll **Residuen** \(R(A,Z)\) treffen, nicht \(B_{\mathrm{exp}}\) | Ja — methodische Hypothese `[C]` |
| EABC erklärt Kernbindung / Nukleonen | **Nein** |
| Weierstrass-ABCE-Befund belegt Kernphysik | **Nein** |
| Korrelation EABC–\(R(A,Z)\) ohne Export und Nullmodell | **Nein** — erst `[B]` mit Protokoll |
| \(\pi(x)=\mathrm{Li}(x)+E(x)\)-Analogie als Identität | **Nein** — nur methodische Lesesprache `[C]` |

\[
\boxed{
\text{Kernbindung liefert Mehrskalen-Vokabular; EABC liefert Invarianten — die Brücke ist Residual-Vergleich } I_{\mathrm{EABC}} \text{ vs. } R(A,Z)\text{, nicht Physik-Identität.}
}
\]

---

## 9. Querverweise

| Dokument | Rolle |
|---|---|
| [`physical_reference_analogies.md`](../reports/physical_reference_analogies.md) | E-076 Hauptdossier (AB / Klitzing / Meissner) |
| [`meissner_analogy_assessment.md`](meissner_analogy_assessment.md) | Bulk/Shell-Urteil E-076 |
| [`weyl_onsager_bridge_attack.md`](weyl_onsager_bridge_attack.md) | Weyl–Onsager `[C]`-Diagnostik |
| [`eabc_weierstrass_multiscale_report.md`](../energiedoku_exports/eabc_weierstrass_multiscale_report.md) | Arithmetische Weierstrass-Mehrskalen-Exporte |
| [`eabc_renormalisierungsprogramm.md`](../energiedoku_exports/eabc_renormalisierungsprogramm.md) | Formaler EABC-Renorm-Kern E-053 |
| [`open_research_questions.md`](../open_research_questions.md) | ORQ-092: \(I_{\mathrm{EABC}}\) vs. \(R(A,Z)\) |
| [`theory/README.md`](README.md) | Theory-Index |
