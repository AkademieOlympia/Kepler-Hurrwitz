# Projekt „Atome“

Strategisches Ziel: Prüfen, ob **EABC-Invarianten** \(I_{\mathrm{EABC}}(A,Z)\) mit experimentellen **Kernbindungs-Residuen** \(R(A,Z)\) über **Nullmodelle** hinaus korrelieren — nicht die volle Bindungskurve \(B_{\mathrm{exp}}\).

Evidenzstatus zum Anlegen: `[C]` (offene Hypothese) mit `[B]`-Diagnostik-Stub; Upgrade zu `[B]` erst nach präregistriertem Export und signifikantem Nullmodell-Nachweis.

**Register:** E-092 · **ORQ:** ORQ-092 · **Dossier:** [`theory/nuclear_binding_multiscale_analogy.md`](theory/nuclear_binding_multiscale_analogy.md)  
**Demarkation:** [`theory/eabc_constellation_eigenenergy.md`](theory/eabc_constellation_eigenenergy.md) — \(E_{\mathrm{eigen}}\) (intrinsisch) vs. Kopplung an \(R(A,Z)\) (ORQ-092); Toy-Nullbefund widerlegt nicht die Algebra.

---

## 1. Kernzerlegung

\[
B_{\mathrm{exp}}(A,Z) = B_{\mathrm{smooth}}(A,Z) + R(A,Z),
\qquad
R(A,Z) = B_{\mathrm{exp}}(A,Z) - B_{\mathrm{smooth}}(A,Z).
\]

| Anteil | Inhalt | Rolle im Test |
|---|---|---|
| \(B_{\mathrm{smooth}}\) | Weizsäcker-Hülle (präregistrierte Parameter) | **nicht** EABC-optimiert |
| \(R(A,Z)\) | Schalen, Paarung, Deformation, Kollektivstruktur | **Zielgröße** für EABC-Vergleich |

**Analogie `[C]`:** \(\pi(x) = \mathrm{Li}(x) + E(x)\) — das Signal liegt in der **Fehlerschicht**, nicht in der glatten Hülle.

---

## 2. Testprotokoll

Für jedes Nuklid \((A,Z)\):

1. Residuum \(R(A,Z)\) aus präregistrierter Weizsäcker-Hülle berechnen.
2. EABC-Invarianten \(I_{\mathrm{EABC}}(A,Z)\) **unabhängig** von der Hüllen-Fit-Wahl definieren (z. B. \(M(A)\), Kanal-Spread, Chiralitätsnorm auf \(H(A)\)).
3. Korrelationsbatterie anwenden:

| Metrik | Zweck |
|---|---|
| Pearson \(r\) | lineare Kopplung |
| Spearman \(\rho\) | monotone Rangkopplung |
| Mutual Information \(\mathrm{MI}\) | nichtlineare Abhängigkeit |
| PCA | gemeinsames Profil \((I_{\mathrm{EABC},k}, R)\) |
| Fourier / Wavelet auf \(R\) entlang \(\log A\) | Mehrskalen-Feinstruktur der Residuen |

4. **Nullmodelle (Pflicht):** Permutation von \(R\), Kanal-Shuffle der EABC-Zuordnung, Varianz-Match.

**Urteil:** EABC erklärt Residuen **nur**, wenn der Effekt signifikant über Shuffle/Permutation hinaus liegt — kein Post-hoc-Best-Fit.

---

## 3. Implementierung

| Artefakt | Pfad |
|---|---|
| Diagnostik-Modul | `src/kepler_hurwitz/nuclear_binding_residual.py` |
| Export-Skript | `examples/run_atome_residual_export.py` |
| Tests | `tests/test_nuclear_binding_residual.py` |
| Toy-Nuklidtabelle | `data/atome/toy_nuclides.csv` |
| Export-Ziel | `docs/exports/atome_residual_*.{json,csv}` |

Nullmodelle (`permute_R`, `shuffle_channel`, `variance_match`) laufen für **alle** \(I_{\mathrm{EABC}}\)-Features (`eabc_mass`, `eabc_spread`, `chiral_norm`, `proton_eabc_mass`, `channel_e/a/b/c`) — Export: `atome_residual_nullmodels.csv`.

```bash
PYTHONPATH=src python examples/run_atome_residual_export.py
pytest tests/test_nuclear_binding_residual.py -q
```

---

## 4. Governance (verbindlich)

| Claim | Erlaubt? |
|---|---|
| \(R(A,Z)\)-Test als methodische Lesesprache | Ja — `[C]` |
| EABC erklärt Kernbindung / Nukleonen | **Nein** |
| Korrelation ohne Nullmodell als Befund | **Nein** |
| \(\pi(x)=\mathrm{Li}(x)+E(x)\)-Analogie als Identität | **Nein** — nur methodisch `[C]` |

\[
\boxed{
\text{Atome testet } I_{\mathrm{EABC}} \leftrightarrow R(A,Z)\text{, nicht } I_{\mathrm{EABC}} \leftrightarrow B_{\mathrm{exp}}.
}
\]

---

## 5. Querverweise

| Dokument | Rolle |
|---|---|
| [`nuclear_binding_multiscale_analogy.md`](theory/nuclear_binding_multiscale_analogy.md) | Vollprotokoll E-092 |
| [`meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md) | Bulk/Shell-Lesesprache E-076 |
| [`open_research_questions.md`](open_research_questions.md) | ORQ-092 |
| [`eabc_weierstrass_multiscale_report.md`](energiedoku_exports/eabc_weierstrass_multiscale_report.md) | Arithmetische Mehrskalen-Parallele |
