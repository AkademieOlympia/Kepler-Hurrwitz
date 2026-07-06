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

## 2. Zerlegung: glatte Hülle plus Residuen

Standardbild in der Nuklearphysik:

\[
\frac{B}{A}(A) = B_{\mathrm{smooth}}(A) + R(A).
\]

| Anteil | Inhalt | Skala |
|---|---|---|
| \(B_{\mathrm{smooth}}(A)\) | Volumen-, Oberflächen-, Coulomb-Trend der Weizsäcker-Hülle | glatt in \(A\) (ggf. \(\log A\)) |
| \(R(A)\) | Schalenlücken, Magic Numbers, Paarung, lokale Anomalien | diskret / schmalbandig |

**Governance:** \(B_{\mathrm{smooth}}\) ist das **Bulk-/Hüllen-Analogon** (vergleichbar zur Meissner-Lesart „isotroper Trend“ in E-076). \(R(A)\) ist das **Shell-/Feinstruktur-Analogon** — dort, wo EABC-Vergleiche methodisch ansetzen sollen, nicht auf der Gesamtkurve.

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
| Kernbindung | Weizsäcker \(B_{\mathrm{smooth}}(A)\) | \(R(A)\): Magic Numbers, Paarung |
| EABC Weierstrass | Trend / Detrend von \(B(N)\) | Spektralpeaks, ABCE/CEAB-Bias |
| EABC Renorm (E-053) | \(M_{\mathrm{eff}} \to 24I_3\) | Defekt an Shell / Rand (E-076 Meissner) |

Die Weierstrass-Exporte belegen **keine** Kernphysik und umgekehrt. Die Brücke ist **methodisch**: erst Hülle/Residual trennen, dann Invarianten testen.

---

## 5. EABC-Residualhypothese `[C]`

### Was nicht verglichen werden soll

Die volle Kurve \(B/A(A)\) mischt Bulk-Trend, Coulomb-Abfall und alle lokalen Effekte. Ein direkter EABC-fit auf \(B/A\) wäre **überdeterminiert** und governance-unsauber (Post-hoc-Analogie).

### Was verglichen werden soll (wenn überhaupt)

\[
R(A) = \frac{B}{A}(A) - B_{\mathrm{smooth}}(A)
\]

mit einer **fest vorab** gewählten glatten Referenz (z. B. Weizsäcker-Fit oder tabellierte Hülle), und dann — hypothetisch — EABC-Invarianten auf derselben Indexachse (z. B. Primindex, Shell-Label, Kanalmetrik).

**Testfrage (offen, `[C]`):**

\[
\boxed{
\text{Korrelieren EABC-Invarianten mit } R(A) \text{ über Nullmodelle hinaus?}
}
\]

**Voraussetzung für Upgrade zu `[B]`:** reproduzierbarer Export, präregistrierte Hülle, Permutations-/Shuffle-Nullmodelle, keine Auswahl der „besten“ Korrelation post hoc.

**Aktueller Stand:** Kein `nuclear_binding_residual` in `diagnostics.py` — E-092 bleibt **konzeptionell**.

---

## 6. Einordnung zu E-076 (Meissner) und Geschwister-Brücken

| Brücke | E-ID | Parallele Lesefrage |
|---|---|---|
| Meissner Bulk/Shell | E-076 | Defekt aus Bulk in Randschale — \(B_{\mathrm{smooth}}\) vs. \(R(A)\) |
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

1. **Referenzhülle fixieren** — Weizsäcker-Parameter oder externe Tabellen; dokumentieren, nicht optimieren für EABC.
2. **Residuen \(R(A)\) extrahieren** — pro \(A\) oder auf \(\log A\)-Gitter.
3. **EABC-Invarianten auf kompatible Achse** — unabhängig vom Fit der Hülle.
4. **Nullmodelle** — Permutation, Kanal-Shuffle, gleiche Varianz wie bei Weierstrass-/Dumas-Protokollen.
5. **Erst dann** — eventuell `[B]`-Diagnostik-Modul; kein Physik-Identity-Claim.

---

## 8. Governance (verbindlich)

| Claim | Erlaubt? |
|---|---|
| Drei-Regime- und Hülle+Residual-Bild als **Lesesprache** | Ja — `[C]` |
| Weizsäcker als Mehrskalen-Analogon zu \(\log\)-Skalen-Diagnostik | Ja — `[C]`, nicht Identität |
| EABC soll **Residuen** \(R(A)\) treffen, nicht \(B/A\) | Ja — methodische Hypothese `[C]` |
| EABC erklärt Kernbindung / Nukleonen | **Nein** |
| Weierstrass-ABCE-Befund belegt Kernphysik | **Nein** |
| Korrelation EABC–\(R(A)\) ohne Export | **Nein** — erst `[B]` mit Protokoll |

\[
\boxed{
\text{Kernbindung liefert Mehrskalen-Vokabular; EABC liefert Invarianten — die Brücke ist Residual-Vergleich, nicht Physik-Identität.}
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
| [`theory/README.md`](README.md) | Theory-Index |
