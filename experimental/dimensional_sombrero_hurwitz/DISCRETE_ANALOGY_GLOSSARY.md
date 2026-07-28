# Diskretes Orbit-Graph-Glossar `[C]`

**Zweck:** Physikalische Analogien (E-076, Maxwell-Lesart, Welle, Ricci, …) sauber in
die **diskrete Modellstruktur** übersetzen — ohne Beweislast und ohne Core-Import.

**Übersetzungsregel:**  
Physikmetapher → **Träger** + **Observable** (Audit-Zahl) + **Nullmodell**  
— nie → Feldgleichung / Teilchenmasse / Führungswelle / ART-Theorem.

**Status:** `claimed_as_theorem=False` für alle Analogie-Slots.  
Harte Evidenz bleibt N8 / N4 / N5 und formalisierte Embed-Geodäten.

---

## 0. Schichten

| Schicht | Inhalt | Darf Physiknamen tragen? |
| --- | --- | --- |
| **Z** Zahlenzeugen | N8, N4, N5, \(L\), \(\kappa\), \(G\), Assoziator-‖A‖² | nein (nur Verweis) |
| **L** Lexikon (dieses Glossar) | Slots mit diskreten Objekten | nur als „Analogie:“-Zeile |
| **P** Physikdossier | E-076, E-084, E-089 | ja, explizit `[C]` |

---

## 1. Kernslots

### Träger \(\Gamma\)
- **Bedeutung:** Diskreter Graph (Knoten + gerichtete Kanten), auf dem alles gemessen wird.
- **Objekt:** EABC-Familiengraph \(\{E,A,B,C\}\) und/oder globale Primbahn.
- **Analogie:** „Raum“ / Raumzeit-Skizze.
- **Verboten:** glatte Mannigfaltigkeit, Lorentz-Metrik.
- **Hooks:** `prime_octonion_geodesic_bahn.py`, `dumas_cone_orbit`.

### Länge \(L\) / Metrik-Slot \(d\)
- **Bedeutung:** Kantenlänge aus formalisierter Geodäte.
- **Objekt:** `euclidean_geodesic(collatzOctEmbed p, collatzOctEmbed q)`.
- **Observable:** Segmentlänge \(L\); Familienmittel \(d(F,G)=\langle L\rangle_{F\to G}\).
- **Analogie:** \(g_{\mu\nu}\) (nur Lesart).
- **Verboten:** Lorentz-Signatur, Kontinuums-Levi-Civita.
- **Hooks:** `octonion_geodesic.py`, `discrete_einstein_geodesic.py`.

### Transport \(W_1\)
- **Bedeutung:** Wasserstein-1-Abstand lokaler Übergangsmaße.
- **Objekt:** lazy one-step measures \(m_F\) auf \(\Gamma\); Ground metric \(d\).
- **Observable:** \(W_1(m_F,m_G)\).
- **Analogie:** „Nachbarschaftstransport“ vor Ricci.
- **Verboten:** kontinuums Ricci-Tensor.
- **Hooks:** `discrete_einstein_geodesic.py`, `discrete_curvature_probe.py`.

### Ollivier-Krümmung \(\kappa\)
- **Bedeutung:** \(\kappa(F,G)=1-W_1(m_F,m_G)/d(F,G)\) (falls \(d>0\)).
- **Observable:** \(\langle\kappa\rangle\), \(\langle\kappa\rangle_{\mathrm{rotor}}\).
- **Analogie:** diskrete Ricci-Lesart.
- **Empirie (\(X=10^5\)):** \(\langle\kappa\rangle\approx 0.54\) (positiv).
- **Verboten:** \(R_{\mu\nu}\), Pseudosphären-Beweis aus N4.
- **Hooks:** `DiscreteCurvature.lean`, Reports unter `experimental/…`.

### Bilanz \(G(e)\)
- **Bedeutung:** \(G(e)=\kappa(e)-\langle\kappa\rangle\) (kombinatorisches Residuum).
- **Observable:** \(\langle G\rangle_{\mathrm{rotor}}\) (≈ 0 bei \(X=10^5\)).
- **Analogie:** Einstein-Tensor-Residuum.
- **Verboten:** \(G_{\mu\nu}=8\pi T_{\mu\nu}\), Massen-Definition, ART (`is_ART=False`).
- **Hooks:** `discrete_einstein_geodesic.py`, `PROTOCOL.md` §12.3.

### Zirkulation \(\oint\) / Umlaufsignatur
- **Bedeutung:** Globale Größe entlang geschlossener Orbit-Schleifen.
- **Objekt:** CEAB-/ABCE-Vierling-Wörter; Kanalumläufe.
- **Analogie:** Aharonov–Bohm-Holonomie (E-076).
- **Verboten:** U(1)-Eichfeld, AB-Experiment-Nachweis.
- **Hooks:** `physical_reference_analogies.md` §4; `orbit_symmetry_guide.md`.

### Stufe / Plateau
- **Bedeutung:** Diskrete robuste Klassen.
- **Objekt:** EABC-Kanäle \(\{1,5,7,11\}\); arithmetische \(x_0\)-Niveaus.
- **Analogie:** von Klitzing / QHE-Plateau (E-076).
- **Verboten:** \(\sigma_{xy}=ν e^2/h\).
- **Hooks:** `arithmetic_evolution.py` / `arithmetic_energy_levels.tex`; E-076 §5.

### Exklusion / Shell
- **Bedeutung:** Trennung „erlaubt / außen / Zwischenraum“.
- **Objekt:** H4′ Even-Norm-Schale vs. Wave-Support; Meissner-Shell-Lesart.
- **Analogie:** Meissner Defekt-Exklusion (E-076).
- **Verboten:** Supraleitung, thermodynamischer Phasenübergang.
- **Hooks:** `WaveParticleShell.lean`, `wave_particle_shell.py`.

### Strom \(J\)
- **Bedeutung:** Kantenfluss aus beobachteten Übergängen.
- **Objekt:** Zählungen / \(P(F\to G)\) auf der Primbahn.
- **Observable:** Rotor-Exzess (N4), C→E-Auffälligkeit (N5).
- **Analogie:** Maxwell-Quelle \(d{*}F=J\) (nur Slot).
- **Verboten:** Maxwell-Feldgleichungen, EM-Wellen.
- **Hooks:** `prime_octonion_bahn_null_eabc_report.json`, N4-Scale-Report.

### Defekt
- **Bedeutung:** Abweichung von Ideal (Assoziativität, Gap-Dominanz, Dualität).
- **Objekt:** Fano-Assoziator ‖A‖²; Residuum \(R=L-\mathrm{gap}\); ABCE/CEAB-Mittlkante.
- **Analogie:** Nichtkommutativität / „Krümmungsfehler“ (proxy).
- **Verboten:** konstante Orbit-Mannigfaltigkeitskrümmung aus ‖A‖²=4.
- **Hooks:** freeze diagnostic; `abce_ceab_geodesic_duality_report.json`.

### Scaffold (Geometrie)
- **Bedeutung:** Klassische euklidische Konfigurationen als gemeinsames Gerüst.
- **Objekt:** Morley, Marion-Walter, Crossed Ptolemy, Icosahedral Ptolemy.
- **Analogie:** Wellen-/Interferenz-Muster (strukturell), nicht Pilotwelle.
- **Verboten:** Führungswelle; Willensstruktur.
- **Hooks:** E-084 / ORQ-084, `open_mathematical_bridge_targets.md` §4.

### Messung (M-Algebra)
- **Bedeutung:** Idempotente Abbildung; Fixpunkte / Zeros.
- **Objekt:** \(\alpha_m\), FP, Z, Interference/Cumulativity als Props.
- **Analogie:** Teilchen = FP; Zwischenraum = Stör-/Nonkommut-Slot.
- **Verboten:** Wavelets aus Interference ableiten; E8 = M-Algebra.
- **Hooks:** `MeasurementAlgebra.lean`, `measurement_algebra_probe.py`.

### Niveau-Split (Lamb-Slot)
- **Bedeutung:** \(E=E_0+V\) auf Fixpunkt-Labels; Split bei \(V_1\neq V_2\).
- **Objekt:** `LambShiftShell.lean` / `lamb_shift_shell.py`.
- **Analogie:** Lamb-Shift / Dirac-Entartung.
- **Verboten:** QED; Hardy = Vakuumfeld; `axiom`-Schema.
- **Hooks:** `PROTOCOL.md` §12.2.

### Dudley–Tucker / alterierte Fibonacci
- **Bedeutung:** \(G_n=F_n+(-1)^n\); acht F/L-Faktorisierungen von \(F_{4n+r}\pm 1\).
- **Objekt:** `fib`/`luc`/`G` in `dudley_tucker_probe.py`; Spec `DudleyTuckerShell.lean`.
- **Observable:** numerische Identitätshaltung; optional \(\gcd(G_a,G_b)\) nach \(n\bmod 4\).
- **Analogie:** arithmetische Schalen-/Teilerstruktur (Literatur 1971).
- **Verboten:** \(\kappa=f(n\bmod 4)\); \(G(e)=\) Gap-Parität; κ∈{0.54, 0.027}; √(F±1) = E8-Geodäte.
- **Hooks:** Dudley–Tucker, Fibonacci Quart. 9 (1971); `dudley_tucker_probe_report.json`.

### Dirac-Bild / freies Spektrum (E-101.5)
- **Bedeutung:** Governance-Lesart: Audit-Bänder = Diagonallabel von abstraktem \(H_0\simeq E_{\log}\) auf B1; nicht Teilchen.
- **Objekt:** `FreeSpectrumBand` / `IsotropicOrNear`; LeafMaps `idMap` / `collapseToMean`; Shuffle-Energieinvarianz.
- **Observable:** `detailEnergy` / \(C_2\); Bandklasse `exactIsotropic` (\(E=0\)) vs `nearIsotropic` (\((0,\varepsilon]\)).
- **Analogie:** Dirac-/Interaction-Picture (E-101.5) — nur Claim-Wand `[C]`.
- **Verboten:** echter QM-Hamiltonian; \(\hbar\); \(e^{iH_0 t}\); Operatoralgebra-\([P,H_0]=0\); Einteilchenzustand; Band = Ruhemasse/PMNS/Oszillation.
- **Hooks:** `KeplerHurwitz/E101/DiracPictureGovernance.lean`, `e101_dirac_picture_governance.py`.

### Konstanten-Rollenäquivalente (E-101.6)
- **Bedeutung:** E-101-interne Größen mit *mathematischer* Rollenanalogie zu \(h,G,\alpha,c,m,q,\Lambda\) — ohne Naturkonstanten-Claim.
- **Objekt:** `E101ConstantNomenclature` (\(h_{101},G_{101},c_{101},\varepsilon_{\mathrm{reg}}\)); abgeleitet \(\hbar_{101},\alpha_{101},\mu_{101},\mathbf q_{101},\Lambda_{101}\).
- **Observable:** \(E_{\mathrm{cross}}=G_{101}K^2\); \(\alpha_{101}=G_{101}K^2/(C_2+\varepsilon_{\mathrm{reg}})\); \(\mu_{101}=\sqrt{C_2}\).
- **Analogie:** Planck-/Newton-/Feinstruktur-/Licht-/Masse-Rollen (nur Nomenklatur `[C]`).
- **Verboten:** \(h_{101}=h_{\mathrm{Planck}}\); \(G_{101}=G_{\mathrm{Newton}}\); \(\alpha_{101}=\alpha_{\mathrm{em}}\); \(c_{101}=c\); \(\mu_{101}=\) Ruhemasse; \(\mathbf q_{101}=\) elektrische Ladung; \(\Lambda_{101}=\) kosmologische Konstante; Index `101` weglassen.
- **Hooks:** `KeplerHurwitz/E101/ConstantNomenclature.lean`, `e101_constant_nomenclature.py`.

### Kern–Schale–Valenz (E-101.7)
- **Bedeutung:** Externe `[C]`-Lesart: Kern/Schale = orthogonale Zustandszerlegung; Valenz = relationale Kopplungsstruktur (kein dritter Parseval-Summand).
- **Objekt:** \(\Lambda_{101}=\|P_{\mathrm{iso}}\|^2\), \(C_2=\|P_{\mathrm{aniso}}\|^2\); \(\mathrm{Valence}_{101}=(\mathbf q_{101},K_{B1,B2},\alpha_{101})\).
- **Observable:** Parseval \(\|q\|^2=\Lambda_{101}+C_2\); Kopplungsdaten getrennt davon.
- **Analogie:** Bulk/Shell (E-076 boundary-compensated defect exclusion); glatte Hülle + Residuum (E-092) — strukturell, nicht \(R=C_2\).
- **Verboten:** Atom-/Kernschale; chemische Valenz; Supraleitung; Valenz als Energieblock; \(R=C_2\) ohne Satz; Collatz/EABC-Beweis aus Analogie.
- **Hooks:** `KeplerHurwitz/E101/CoreShellValence.lean`, `e101_core_shell_valence.py`.

### Dirac-artiges Auditspektrum (E-101.8)
- **Bedeutung:** Kernzentriertes Spektraldublett als endlicher reeller 2×2-Auditoperator über E-101.7.
- **Objekt:** \(D_{101}=\Lambda I+\mu\sigma_3+g\sigma_1\); \(\lambda_\pm=\Lambda\pm\sqrt{C_2+G_{101}K^2}\); \(\Delta_{101}=2s\).
- **Observable:** Audit-Eigenwerte \(\lambda_\pm\); Gap \(\Delta_{101}\); Orientierung \(\mathrm{sgn}(I_3)\).
- **Analogie:** Dirac-Bild (E-101.5) — Governance nur; Pauli-Matrizen ohne Spin-Claim.
- **Verboten:** Dirac-Gleichung; Fermion; Massenlücke; Bandlücke; Antiteilchen; \(\lambda_\pm\) = Teilchenenergie.
- **Hooks:** `KeplerHurwitz/E101/DiracLikeAudit.lean`, `e101_dirac_like_audit.py`.

### Funktionale Information / Wong-Filter (E-112)
- **Bedeutung:** EABC-Partition als arithmetischer Entropiefilter; relative Information \(I_{Q_0}=-\log_2 F\) unter Uniform-Prior; Wong-Drei-Ordnungen nur als Lesesprache.
- **Objekt:** Klassen \(\{E,A,B,C\}\); Zwei-Quadrate-Grenze E∪A vs. B∪C (`EABC/Basic.lean`); `Q0_UNIFORM` / `functional_information_bits(..., q0=)`.
- **Observable:** Unter \(Q_0=(1/4)^4\) hat die Modellgröße \(I_{Q_0}\) für E∪A bzw. \(\{E\}\) die Werte 1 Bit bzw. 2 Bit (`[B/C]`; kein NT-Absolutum).
- **Analogie:** Wong funktionale Information / drei Selektionsordnungen; ORQ-112 prüft ob/wie \(Q^*\)/Divergenz trennt (ohne Optimalitätsclaim).
- **Verboten:** Physikgesetz; Identifikation mit thermodynamischer Entropie \(S\); Spaltung\(\Rightarrow\)Leitfähigkeit; Freeze von ORQ-112 als Evolutionsgesetz; \(I\) als NT-Absolutum ohne Prior; Existenz/Eindeutigkeit „optimaler“ \(Q^*\).
- **Hooks:** `docs/energiedoku_exports/eabc_wong_functional_information_bridge.md` (Spez. CLOSED & ACTIVE; Snapshot `eabc-functional-info-v0.1`), `prime_tower_bridge.py`, ORQ-112 / E-112; Freeze-Report `docs/reports/eabc_wong_functional_info_v0.1_freeze.md`.

### Lemaître-Differenz \(\Delta_L\) (E-113)
- **Bedeutung:** Dynamischer Modell-Score \(\Delta_L(N)=v_{\mathrm{mult}}(N)-v_{\mathrm{add}}(N)\) auf Lipschitz-Normschalen; AP-1 Dual-Aggregation \(\langle\Delta_L\rangle_{\mathrm{schale}}\) / \(\langle\Delta_L\rangle_{\mathrm{quat}}\) und Nullmodelle \(H_0^{(1..3)}\).
- **Objekt:** Schalen \(S_N=\{q\in\mathbb{H}[\mathbb{Z}]:N(q)=N\}\); Jacobi \(r_4\); Achsen \(\{\pm1,\pm i,\pm j,\pm k\}\); Radius-Parameter \(R=\sqrt{N}\).
- **Observable:** \(v_{\mathrm{mult}}=\Delta\log(1+r_4)\); \(v_{\mathrm{add}}=\) mittlere minimale Achsenabweichung / \((2R+1)\); AP-1 Endpoint: schale \(-0{,}111\) n.s., quat \(+0{,}157\) mit \(p_{\mathrm{MC}}\le 10^{-4}\) vs. \(H_0^{(3)}\); Schema `friedman_lemaitre.v2`.
- **Analogie:** Friedman–Lemaître / Hubble \(v=HR\) (nur Lesart `[C]`/`[D]`); „Trägheit/Bremse/Void“ nur Interpretation — **nicht** `[B]`.
- **Verboten:** FLRW; `[A]`-Upgrade aus AP-1; Kausal-„Dichteeffekt“; Kosmologie-Claim; \(p=0\) statt \(p_{\mathrm{MC}}\le 10^{-4}\); Collatz/E-096-Transfer ohne eigenen Audit.
- **Hooks:** `friedman_lemaitre_ap1_abschlussbericht.md`, `PROTOCOL.md`, `friedman_lemaitre_ap1_n1000.json`, E-113 / ORQ-113.

### Skalierungsdiagnose \(\widehat{c}_{[B]}\) (E-113-EXT / AP-2)
- **Bedeutung:** Asymptotische Trend-/Plateau-Diagnose für \(\mu_{\mathrm{quat}}\) und \(\mu_{\mathrm{window}}\) bis \(X=10^6\); Fitkatalog \(M_0\)–\(M_4\).
- **Objekt:** \(R_4(X)=\sum r_4\); \(S_\Delta\); Primdichte \(1/\zeta(4)\); dyadisches Fenster \((X/2,X]\).
- **Observable:** \(\widehat{c}_{[B]}(X)\), \(c_{[B]}^{\mathrm{fit}}\) unter \(M_i\); RMSE-Vergleich Plateau vs. Drift.
- **Analogie:** „asymptotische Expansionsrate“ nur `[C]` — nie Grenzwert der Raumzeit.
- **Verboten:** \(c_{[B]}=\lim_{X\to\infty}\langle\Delta_L\rangle_{\mathrm{quat}}\); `[A]`-Upgrade; Kausal-Dichte; Kosmologie; Nicht-Primitiv-„Dominanz“-Korrektur (Primanteil \(\approx 92\%\)).
- **Hooks:** `PROTOCOL_AP2.md`, `friedman_lemaitre_ap2.py`, `LemaitreScalingAP2.lean`, E-113-EXT / ORQ-113-EXT.

### Achsen-Kopplung \(\Delta_{\mathrm{axis}}\) (E-113-TENSION / AP-3)
- **Bedeutung:** `[B]`-Kanaldifferenz Fast vs. Voll: \(\Delta_{\mathrm{axis}}=\widehat{c}_{\mathrm{Fast}}-\widehat{c}_{\mathrm{Voll}}\) (`axis_coupling_delta`).
- **Objekt:** duale Messkanäle \(v_{\mathrm{add}}=0\) vs. \(v_{\mathrm{add}}\neq 0\); λ-Intervention; Fensterdifferenz.
- **Observable:** \(\Delta_{\mathrm{axis}}(1000)=0{,}120185\); \(\chi_{\mathrm{axis}}\) aus λ-Scan (Sensitivität, nicht automatisch Kausalgesetz).
- **Analogie `[D]`:** „quaternionische Hubble-Spannung“ (CMB vs. Cepheiden/SNe) — Alias only.
- **Verboten:** Identität mit astrophysikalischer Hubble-Spannung; Kausalclaim ohne Intervention; \(\lim\Delta_{\mathrm{axis}}\) als `[A]`; Kosmologie/\(H_0\).
- **Hooks:** `PROTOCOL_AP3.md`, `friedman_lemaitre_ap3.py`, `LemaitreTensionAP3.lean`, E-113-TENSION.

### Spin(8)-Ankopplung (E-113-SPIN8)
- **Bedeutung:** Arbeitshypothese: \(\Delta_{\mathrm{axis}}\) als mögliches Projektions-Residuum \(\mathbb{R}^8/\mathrm{Spin}(8)/E_8\to\mathbb{R}^4/\mathrm{Spin}(4)\).
- **Objekt:** Träger \(r_4\) / künftiges \(r_8\)- bzw. \(E_8\)-Schalenanalogon; Nähe-Proben zu \(1/\zeta(4),1/\zeta(8),V_8/(V_4)^2,1/8\).
- **Observable:** 4D-\(\Delta_{\mathrm{axis}}\) + Smoke \(\Delta_{\mathrm{axis}}^{\mathbb{Z}^8}/\Delta_{\mathrm{root}}^{E_8}\) (**ARCHIVED**); Skalierungs-Gate **DORMANT**.
- **Analogie:** Trialität; KS/Runge–Lenz auf \(S^7\) (`[D]`).
- **Verboten:** Ableitung aus \(\mathrm{Spin}(8)\); Identität mit Zeta-/Volumenkonstanten; KS-Physik-Claim; Verwechslung Hurwitz-24 ↔ E8-240; intrinsische \(E_8\)-Wirkung aus Smoke.
- **Hooks:** `PROTOCOL_SPIN8.md`, `friedman_lemaitre_spin8_probe.py`, `friedman_lemaitre_spin8_sensors.py`, `LemaitreSpin8Coupling.lean`, E-113-SPIN8.

---

## 2. Harte Zeugen (nicht umbenennen)

| Code | Kurz | Quelle |
| --- | --- | --- |
| **N8** | \(L=\hat L\) exakt (Embed-Identität) | `prime_octonion_bahn_null_eabc_report.json` |
| **N4** | Rotor-Zählungen ≠ Familien-Shuffle; \(z(X)\) wächst | `prime_octonion_bahn_n4_scale_report.json` |
| **N5** | C→E-Residuum gap-stratifiziert höher | null-eabc-Report |
| **Dualität** | ABCE/CEAB außen satzgleich, Mitte nicht | `abce_ceab_geodesic_duality_report.json` |

---

## 3. Verbotene Identitäten (Kurzliste)

- Embed-Bahn = Oktonionen-Multiplikationsgeodäte  
- \(\kappa\) / \(G\) = ART  
- \(G(e)\) = Masse / \(T_{00}\)  
- N4-Drift = negative Ricci / Pseudosphäre  
- AB-Anker = Eichfeld  
- Klitzing-Anker = Hall-Leitfähigkeit  
- Morley/Marion-Walter = Führungswelle  
- M-Algebra-Interference = CWT  
- Lamb-Slot = QED-Lamb-Shift  
- Dudley–Tucker-Faktorisierung = Ollivier-κ / Einstein-\(G(e)\)  
- E-101-Audit-Band / \(E_{\log}\) = Teilchenidentität / Ruhemasse / PMNS  
- Dirac-Bild-Slot = echter QM-Hamiltonian / unitäre Gruppe  
- \(h_{101}/G_{101}/\alpha_{101}/c_{101}/\mu_{101}\) = Planck / Newton / Feinstruktur / Licht / Teilchenmasse  
- Kern–Schale–Valenz (E-101.7) = Atom-/Kern-/Chemiephysik; Valenz = dritter Parseval-Summand; \(R=C_2\)  
- E-101.8-Auditdublett \(\lambda_\pm\) = physikalische Dirac-/Massen-/Bandlücke  
- Wong-\(I_{Q_0}(E_x)\) / ORQ-112-\(Q^*\) = bewiesenes Physik- oder Evolutionsgesetz  
- Lemaître-\(\Delta_L\) / E-113 = Hubble-Parameter / FLRW / kosmische Materie-Voids  
- \(\widehat{c}_{[B]}\) / E-113-EXT = \(\lim\langle\Delta_L\rangle_{\mathrm{quat}}\) / bewiesene asymptotische Konstante  
- \(\Delta_{\mathrm{axis}}\) / „quaternionische Hubble-Spannung“ = astrophysikalische Hubble-Spannung / \(H_0\) / Kausalparameter ohne λ-Intervention  
- \(\Delta_{\mathrm{axis}}\) / E-113-SPIN8 = aus \(\mathrm{Spin}(8)\)-Trialität abgeleiteter Satz / KS-Physik / Zeta-Identität  


---

## 4. Satzbausteine (für Text/Protokoll)

**Erlaubt:**  
„Auf dem Träger \(\Gamma\) messen wir Observable \(X\); die Physikmetapher \(P\) ist nur Lesart `[C]`.“

**Verboten:**  
„Daraus folgt die Maxwell-/Einstein-/Bohm-Gleichung.“

**Abschlussformel:**  
`claimed_as_theorem=False` · `is_ART=False` · `is_EM=False` (falls Maxwell-Slot) · Core unberührt.

---

## 5. Datei-Index

| Thema | Datei |
| --- | --- |
| Claim-Wand gesamt | `PROTOCOL.md` §12 |
| Ollivier / \(G\) auf Geodäten | `discrete_einstein_geodesic.py` |
| Assoziator / Hop-κ / N4-Fit | `discrete_curvature_probe.py` |
| Lean-Spec Krümmung | `DiscreteCurvature.lean` |
| M-Algebra | `MeasurementAlgebra.lean` |
| Lamb-Slot | `LambShiftShell.lean` |
| Dirac-Bild / E-101.5 | `KeplerHurwitz/E101/DiracPictureGovernance.lean` |
| Konstanten-Rollen / E-101.6 | `KeplerHurwitz/E101/ConstantNomenclature.lean` |
| Kern–Schale–Valenz / E-101.7 | `KeplerHurwitz/E101/CoreShellValence.lean` |
| Dirac-artiges Auditspektrum / E-101.8 | `KeplerHurwitz/E101/DiracLikeAudit.lean` |
| Wong Functional Information / E-112 | `docs/energiedoku_exports/eabc_wong_functional_information_bridge.md` |
| Lemaître-Differenz / E-113 | `experimental/friedman_lemaitre/PROTOCOL.md`, `friedman_lemaitre.py` |
| Skalierung \(\widehat{c}_{[B]}\) / E-113-EXT | `experimental/friedman_lemaitre/PROTOCOL_AP2.md`, `friedman_lemaitre_ap2.py` |
| Achsen-Kopplung \(\Delta_{\mathrm{axis}}\) / E-113-TENSION | `experimental/friedman_lemaitre/PROTOCOL_AP3.md`, `friedman_lemaitre_ap3.py` |
| Spin(8)-Ankopplung / E-113-SPIN8 | `experimental/friedman_lemaitre/PROTOCOL_SPIN8.md`, `friedman_lemaitre_spin8_{probe,sensors}.py` |
| Physik-Anker AB/Klitzing/Meissner | `docs/reports/physical_reference_analogies.md` |
| GeometryScaffold | `docs/open_mathematical_bridge_targets.md` §4 |

---

## 6. Agent-Skill (befragen & erweitern)

Cursor-Projekt-Skill:

→ **[`.cursor/skills/discrete-analogy-glossary/SKILL.md`](../../.cursor/skills/discrete-analogy-glossary/SKILL.md)**

| Modus | Nutzen |
| --- | --- |
| **A Befragen** | Slot-Lookup, Übersetzungsfragen, Verbote |
| **B Erweitern** | neuen `### Slot` im gleichen Format anhängen |
| **C Konsistenz** | Abgleich mit N8/N4/N5 und `PROTOCOL` §12 |

Aufruf z. B.: *„Glossar: wohin gehört Onsager?“* oder *„Glossar erweitern: Slot …“*.

---

*Glossar-Version: 2026-07-22 · Schicht `[C]` · kein Lake-Default / kein Manuskript-Import als Theorem.*
