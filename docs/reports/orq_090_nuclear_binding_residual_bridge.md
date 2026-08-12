# ORQ-090: Nuclear Binding Residual Bridge

**Evidence ID:** E-090  
**ORQ:** ORQ-090  
**Status:** `[C]` operational research question  
**Promotion target:** `[B0]` reproducible diagnostic export  
**No promotion to:** physical mechanism or nuclear model  
**Date:** 2026-07-11

---

ORQ-090 untersucht, ob eine vorab definierte arithmetische EABC-Klassifikation außer Stichprobe zusätzliche Information über Residuen eines konventionellen glatten Kernbindungsmodells liefert. Der Test ist eine statistische Residualdiagnostik und weder ein Kernmodell noch ein Nachweis eines physikalischen EABC-Mechanismus.

---

## Claim box

\[
\boxed{
\text{Geprüft wird ausschließlich, ob eine vorab definierte EABC-Variable}
\atop
\text{zusätzliche statistische Information über ein Bindungsresiduum trägt.}
}
\]

## Nicht behauptet

- EABC erklärt Kernbindung.
- EABC ersetzt Schalenmodell, Paarung oder Deformationsphysik.
- Eine Korrelation identifiziert einen physikalischen Mechanismus.
- Numerische Signifikanz begründet eine EABC–Kernphysik-Identität.
- Ein Residualsignal ist automatisch neue Physik.

---

## Residualtypen

Die semiempirische Massenformel (SEMF):

\[
B_{\mathrm{SEMF}}
= a_v A
- a_s A^{2/3}
- a_c \frac{Z(Z-1)}{A^{1/3}}
- a_a \frac{(A-2Z)^2}{A}
+ \delta(A,Z).
\]

Zwei Residuen werden parallel exportiert:

| Symbol | Definition | Zweck |
|---|---|---|
| \(R_{\mathrm{no\,pair}}\) | \(B_{\mathrm{exp}} - B_{\mathrm{SEMF,no\,pair}}\) | enthält erwartungsgemäß Paarungsstruktur |
| \(R_{\mathrm{pair}}\) | \(B_{\mathrm{exp}} - B_{\mathrm{SEMF,pair}}\) | prüft EABC über triviale Parität hinaus |

Ohne beide Residualtypen könnte eine mod-12-Signatur lediglich bekannte Gerade-Ungerade-Struktur wiederentdecken.

---

## Primäre Invariante und Kontrolle

**Primäre Invariante (vorab fixiert):**

\[
I_{\mathrm{EABC}}(Z,N) = (Z \bmod 12,\; N \bmod 12)
\]

mit Abbildung auf EABC-Klassen \(\{E=1,\; A=5,\; B=7,\; C=11\} \pmod{12}\). Restklassen außerhalb \(\{1,5,7,11\}\) werden als eigene Kategorie **`non-EABC`** geführt (keine nachträgliche Projektion).

**Kontrollvariable:**

\[
I_{\mathrm{parity}}(Z,N) = (Z \bmod 2,\; N \bmod 2).
\]

---

## Kontrollhierarchie

Die Frage ist nicht bloß \(R \leftrightarrow I_{\mathrm{EABC}}\), sondern:

\[
\text{liefert } I_{\mathrm{EABC}} \text{ Information über } R \text{ zusätzlich zu bekannten Kontrollgrößen?}
\]

**Baseline-Modell:**

\[
R = \beta_0 + \beta_1 A + \beta_2 Z + \beta_3 \operatorname{Parity}(Z,N) + \varepsilon.
\]

**Erweitertes Modell:**

\[
R = \beta_0 + \beta_1 A + \beta_2 Z + \beta_3 \operatorname{Parity}(Z,N) + f(I_{\mathrm{EABC}}) + \varepsilon.
\]

**Primäre Kennzahl:**

\[
\Delta \mathrm{MAE}_{\mathrm{CV}}
= \mathrm{MAE}_{\mathrm{baseline}} - \mathrm{MAE}_{\mathrm{baseline+EABC}}.
\]

**Sekundäre Kontraste:** \(\Delta R^2\), \(\Delta \mathrm{RMSE}\), Permutations-\(p\), blockiertes Bootstrap-KI.

Bei rein kategorialen EABC-Klassen ist Spearman nur sinnvoll, wenn eine Ordnung vorab begründet ist — sonder Gruppenmodell / CV-Prediction bevorzugen.

---

## Nullmodelle (strukturtreu)

Freie Permutation aller \((A,Z)\)-Labels ist **verboten** (zerstört Nuklidkarten-Autokorrelation).

| ID | Beschreibung | Stub-Interface |
|---|---|---|
| NM-1 | Permutation innerhalb enger \(A\)-Bins (\([1,10], [11,20], \ldots\)) | `run_structured_permutation_test(..., mode="a_bin")` |
| NM-2 | Permutation innerhalb Paritätsklassen (ee / eo / oe / oo) | `mode="parity_class"` |
| NM-3 | Zirkuläre Verschiebung entlang Isotopenketten (festes \(Z\), verschobenes \(N\)) | `mode="isotope_chain_shift"` |
| NM-4 | Strukturangepasste Zufallskategorie (gleiche Besetzung, ähnliche \(A\)-/Paritätsabhängigkeit) | `mode="structure_matched"` |

Starker Befund erfordert Robustheit gegen **mehrere** dieser Nullmodelle.

---

## Blockierte Splits

Keine zufällige Zeilenaufteilung — benachbarte Kerne sind zu ähnlich.

| Split-Typ | `group_column` / Regel |
|---|---|
| Protonenzahl | `Z` — ganze \(Z\)-Bereiche zurückhalten |
| Isotopenketten | `(Z, chain_id)` — ganze Ketten zurückhalten |
| Massenzahl-Bins | `A_bin` — Massenbereiche zurückhalten |

Workflow:

1. SEMF-Koeffizienten auf Trainingsdaten fitten.
2. Residuen auf gehaltenen Testdaten berechnen.
3. EABC-Zusatzinformation außer Stichprobe prüfen.

In-Sample-Diagnostik ohne explizite Kennzeichnung ist **nicht** `[B0]`-tauglich.

---

## Dateistruktur

| Pfad | Rolle |
|---|---|
| [`docs/reports/orq_090_nuclear_binding_residual_bridge.md`](orq_090_nuclear_binding_residual_bridge.md) | dieses Dossier |
| [`src/kepler_hurwitz/nuclear_binding_residual_bridge.py`](../../src/kepler_hurwitz/nuclear_binding_residual_bridge.py) | Parser, SEMF, EABC-Zuordnung, CV-Diagnostik |
| [`tests/test_nuclear_binding_residual_bridge.py`](../../tests/test_nuclear_binding_residual_bridge.py) | synthetische Tests |
| [`data/external/README_nuclear_mass_data.md`](../../data/external/README_nuclear_mass_data.md) | erwartetes AME/NUBASE-Format |
| [`artifacts/orq_090/`](../../artifacts/orq_090/) | Export-Ziel |

**Exports (Ziel `[B0]`):**

- `artifacts/orq_090/nuclear_binding_residuals.csv`
- `artifacts/orq_090/nuclear_binding_residual_summary.json`
- `artifacts/orq_090/nuclear_binding_residual_nulls.csv`

---

## CSV-Schema

**Eingabe** (`load_mass_table`): `A`, `Z`, `element` zwingend; `N` optional (ableitbar als `A − Z`, sonst Konsistenzprüfung). Mindestens eine Energiespalte: `binding_exp_MeV` **oder** atomarer `mass_excess_keV` (neutral-atomare AME-Konvention, Rekonstruktion mit \(m_H\) nicht \(m_p\)). Siehe [`data/external/README_nuclear_mass_data.md`](../../data/external/README_nuclear_mass_data.md).

**Export** — Spalten (Einheiten im Namen):

```
A, Z, N, element,
mass_excess_keV,
binding_exp_MeV,
binding_semf_no_pair_MeV,
binding_semf_pair_MeV,
residual_no_pair_MeV,
residual_pair_MeV,
z_parity, n_parity, pairing_class,
z_mod12, n_mod12,
z_eabc_class, n_eabc_class,
eabc_joint_class,
split_id, source_release
```

Optional später (nicht im Minimaltest): `shell_distance_Z`, `shell_distance_N`, `is_magic_Z`, `is_magic_N`, `deformation_proxy`, `local_residual_laplacian`.

---

## Governance

| Regel | Detail |
|---|---|
| Zufallsseed | fest (`seed` Parameter, dokumentiert im Summary) |
| Daten-Hash | SHA-256 der Eingabedatei im Summary |
| Massentabelle | Versionsangabe / `source_release` |
| Zeilenausschluss | keine stillen Drops — `excluded_count` im Summary |
| SEMF-Fit | Train/Test getrennt; Koeffizienten nicht EABC-optimiert |
| Invariantenwahl | genau eine primäre \(I_{\mathrm{EABC}}\) — keine undokumentierte Kandidatensuche |
| Physik | auch bei `[B]` bleibt Interpretation `[C]` |

**Geschwister-ORQ:** ORQ-092 (E-092) — multiskalige \(I_{\mathrm{EABC}}(A,Z)\)-Korrelationsbatterie; ORQ-090 ist die **härtere** Residual-Brücke mit SEMF-Kontrollhierarchie und strukturtreuen Nullmodellen.

**Prüfmodus (Scaffold):**

```bash
pytest tests/test_nuclear_binding_residual_bridge.py -q
```

---

## Promotionskriterien

### `[C]` → `[B0]`

Nur wenn vorhanden:

- fest definierte Datenquelle,
- reproduzierbarer Parser,
- dokumentierte SEMF-Form,
- vorab definierte EABC-Invariante,
- strukturtreues Nullmodell,
- deterministischer Export,
- Tests und Daten-Hash.

### `[B0]` → `[B]`

Nur wenn zusätzlich:

- Effekt außer Stichprobe,
- robuste Richtung über mehrere Splits,
- Effekt bleibt nach Paritätskontrolle bestehen,
- Effekt schlägt mehrere strukturtreue Nullmodelle,
- keine Auswahl der besten Invariante aus einer undokumentierten Kandidatenmenge.

Auch dann bleibt die physikalische Interpretation `[C]`.
