# Bridges 2026 — Einreichungsnotizen (Okto-Computing / EABC)

**Stand:** 7. Juli 2026  
**Begleitdokument:** [`bridges_2026_okto_computing_outline.tex`](bridges_2026_okto_computing_outline.tex)

---

## 1. Was in der Einreichung behauptet werden darf

| Thema | Einreichung (Haupttext) | Nur Anhang / Diagnostik |
|---|---|---|
| EABC-Vierkanal $H(n)=(E,A,B,C)$ | Ja, als formale Signaturgeometrie `[A]`/`[B]` | — |
| Dumas-Host-Komplementarität (E-048) | Ja, als bewiesene kombinatorische Struktur `[A-T]` | Physik-Orbit-Interpretation `[C]` |
| Energiedoku / Schalen-Resonanz | Ja, als reproduzierbare numerische Kette `[B]` | Physikalische Identität `[C]` |
| Riemann-Interferenz-Plots | Ja, als **illustrative** Visualisierung `[B]` | Kausalität Nullstellen → EABC `[C]` |
| Fractional-weighted Kernel $\Phi_{R,\alpha}$ | Ja, als **gewichteter Kern** mit PoC-Vergleich `[B]` | Caputo-/RIemann-Liouville-Ableitung — **nein** |
| Symmetriebruch / Bivektor | Ja, als Lesesprache / Hypothese `[C]` | Beweis von Tensor-Zerreissung — **nein** |
| Kernbindung E-092 | Ja, als **methodisches** Residual-Protokoll `[C]` → `[B]` | EABC erklärt Bindungskurve — **nein** |
| Collatz | Nur Anhang: Diagnostik + Lean-Kern S1–S3 | Collatz-Vermutung bewiesen — **nein** |

---

## 2. Fractional-PoC — ehrliche Ergebnisse ($N=150$ Nullstellen)

**Definition (kein Caputo):**

$$\Phi_{R,\alpha}(x) = \sum_n \cos(\gamma_n \ln x)\, x^{-\alpha}$$

Reproduktion: `PYTHONPATH=src python -c "from kepler_hurwitz.riemann_interference_diagnostics import export_fractional_comparison_bundle; export_fractional_comparison_bundle('docs/exports')"`

### Signale an Testknoten

| $x$ | Rolle | $\alpha=0$ | $\alpha=0.5$ |
|---:|---|---:|---:|
| 31 | Prim | −29.64 | −5.32 |
| 35 | bc-Komposit $5\cdot7$ | +3.03 | +0.51 |
| 137 | Prim | −10.68 | −0.91 |
| 139 | Prim | −14.14 | −1.20 |
| 143 | bc-Komposit $11\cdot13$ | +7.29 | +0.61 |

### Trennung Komposit vs. nächster Prim-Nachbar (Betrag der Differenz)

| Paar | $\alpha=0$ | $\alpha=0.5$ | $\alpha=0.5$ besser? |
|---|---:|---:|---|
| 35 vs. 31 | 32.66 | 5.83 | **Nein** |
| 143 vs. 139 | 21.43 | 1.81 | **Nein** |

### „Unterdrückung“ am Komposit ($|\Phi|$ kleiner als beim Prim-Nachbarn)

| Paar | $\alpha=0$: $|\mathrm{comp}|/|\mathrm{prim}|$ | $\alpha=0.5$: $|\mathrm{comp}|/|\mathrm{prim}|$ |
|---|---:|---:|
| 35 vs. 31 | 0.102 | 0.096 |
| 143 vs. 139 | 0.516 | 0.509 |

**Befund:** $\alpha=0.5$ skaliert alle Amplituden mit $x^{-1/2}$ herunter. Das Vorzeichenmuster (Komposit positiv, benachbarte Primzahlen negativ) bleibt qualitativ gleich. Die **absolute** Trennung sinkt mit $\alpha=0.5$ deutlich — der Kernel **verschärft** die Detektion **nicht**. Das Verhältnis $|\mathrm{comp}|/|\mathrm{prim}|$ ändert sich nur marginal (35/31 leicht kleiner, 143/139 praktisch unverändert).

**Empfehlung für Einreichung:** Fractional-Gewichtung als **exploratives Visualisierungswerkzeug** `[B]` erwähnen, nicht als verbesserten Suppression-Detektor. Terminologie strikt: *fractional-weighted interference kernel*, nicht „fraktionale Ableitung“.

Export-Artefakte:

- `docs/exports/riemann_fractional_interference_comparison.png`
- `docs/exports/riemann_fractional_interference_comparison.summary.json`
- `docs/exports/riemann_interference_phase_collapse.png` (Basis $\alpha=0$)

---

## 3. Governance-Grenzen (Kurzform)

**Bewiesen / formal:** Dumas-Host-Komplementarität; Collatz odd-core-Äquivalenz (Lean S1–S3); Hurwitz-Sieb-Fakten.

**Illustriert:** Riemann-Wellenplots; fractional-Vergleich; Energiedoku-Exports; Collatz-Atlas.

**Analogie:** Riemann ↔ bc-Achse; Pauli-Bivektor; Kern-Residual ↔ $I_{\mathrm{EABC}}$; Onsager ↔ Dumas-Gap-Rotor.

**Explizit nicht:** RH-Beweis; Collatz-Vollbeweis; Physik-Identität; discovery-taugliche Prim/Komposit-Trennung ohne Präregistrierung.

---

## 4. Bridges-Konferenz-Fit

**Passt gut:**

- Visuelle Brücke zwischen Zahlentheorie (Prim/Komposit-Knoten) und Wellen-/Interferenzbildern
- Geometrische Lesart (Dumas-Doppelkegel, EABC-Kanäle) als Kunst/Mathematik-Narrativ
- Defensive, ehrliche Abgrenzung passt zur Bridges-Kultur (Mathematik + Visualisierung, nicht Overclaim)

**Vorsicht:**

- Physik-Brücken (Kernbindung, QEC) nur als **methodische** Analogie, nicht als Anwendungsclaim
- Fractional-Kernel nicht als Analysis-Beitrag verkaufen
- Collatz strikt vom Hauptnarrativ trennen (Anhang)

**Vorgeschlagener Titelton:** *Okto-Computing Bridges: Quaternionic EABC Channels and Arithmetic Interference Diagnostics*

---

## 5. Nächste Schritte vor Einreichung

1. Fig. 3–4 aus Exports in finale Auflösung prüfen
2. Governance-Box aus LaTeX-Gliederung in Abstract/Introduction spiegeln
3. Bibliographie-Stubs durch echte Zitate ersetzen
4. Optional: TikZ für EABC-Kegel und Dumas-Host (Fig. 1–2)
5. Kein Upgrade des fractional-PoC ohne präregistriertes Protokoll und weiteres $\alpha$-Sweep
