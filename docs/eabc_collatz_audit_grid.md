# EABC × Collatz: Audit-Grid vs. formaler Beweis

> **Governance / Claim-Boundary**  
> **Register:** [`E-097`](../EVIDENCE_REGISTER.md) · Normalform-Stack: [`E-096`](../EVIDENCE_REGISTER.md)  
> **Master-Index:** [`EABC_MASTER_INDEX.md`](../EABC_MASTER_INDEX.md)  
> Voraussetzung: [`eabc_normal_form.md`](eabc_normal_form.md) · [`eabc_v4_quaternion_bridge.md`](eabc_v4_quaternion_bridge.md)

Dieses Dokument ordnet die Anwendung von \(n=2^\alpha 3^\beta r\,e\), \(V_4\), DualCarrier und Quaternionen-Brücke auf die **Collatz-/Syracuse-Dynamik** ein: als **konstruktives Audit-Grid** `[A]`/`[B]`, nicht als Beweis der Vermutung `[C]`.

---

## 1. Abbildung des beschleunigten Syracuse-Schritts

Für ungerade Kerne \(\kappa\) mit \(\gcd(\kappa,6)=1\) sei

\[
T_{\mathrm{acc}}(\kappa)=\frac{3\kappa+1}{2^{\nu_2(3\kappa+1)}}=\kappa',\qquad
\kappa'=2^{0}\,3^{\beta'}\,r'\,e'
\]

(nach erneuter EABC-Normalform von \(\kappa'\)). Die \(V_4\)-Klasse von \(\kappa\) ist \([\kappa]_{V_4}=[r]_{V_4}\) (E-Faktor neutral).

### 1.1 Exakte 2-Bewertung (Lean `[A]`)

| Kanal von \(\kappa\) | \(\kappa\bmod 12\) | \(\nu_2(3\kappa+1)\) |
|---|---|---|
| **E** | \(1\) | \(\ge 2\) |
| **A** | \(5\) | \(\ge 2\) |
| **B** | \(7\) | \(=1\) |
| **C** | \(11\) | \(=1\) |

### 1.2 Kanalziel nach \(T_{\mathrm{acc}}\) — Verfeinerung mod 24

Die oft zitierte Kurzregel „B→C, C→A“ ist **nur halb wahr**. Für den Schritt \(\kappa\mapsto(3\kappa+1)/2\) (Kanäle B/C, \(\alpha=1\)):

1. **Kanal B** (\(7\bmod 12 \iff 7,19\bmod 24\)):
   * \(\kappa\equiv 7\pmod{24}\implies 3\kappa+1\equiv 22\pmod{72}\xrightarrow{/2}11\pmod{12}\implies\mathbf{C}\)
   * \(\kappa\equiv 19\pmod{24}\implies 3\kappa+1\equiv 58\pmod{72}\xrightarrow{/2}29\equiv 5\pmod{12}\implies\mathbf{A}\)
2. **Kanal C** (\(11\bmod 12 \iff 11,23\bmod 24\)):
   * \(\kappa\equiv 11\pmod{24}\implies 3\kappa+1\equiv 34\pmod{72}\xrightarrow{/2}17\equiv 5\pmod{12}\implies\mathbf{A}\)
   * \(\kappa\equiv 23\pmod{24}\implies 3\kappa+1\equiv 70\pmod{72}\xrightarrow{/2}35\equiv 11\pmod{12}\implies\mathbf{C}\)
3. **Kanäle E/A** (\(\nu_2\ge 2\)): Zielkanal nicht allein durch die Mod-12-Startklasse bestimmt.

| Start | \(\kappa\bmod 24\) | \(\alpha\) | Klasse von \(\kappa'\) |
|---|---|---|---|
| **B** | \(7\) | \(1\) | **C** |
| **B** | \(19\) | \(1\) | **A** |
| **C** | \(11\) | \(1\) | **A** |
| **C** | \(23\) | \(1\) | **C** |
| **E** / **A** | \(1\) / \(5\) mod 12 | \(\ge 2\) | Streuung über \(\{\mathbf{E},\mathbf{A},\mathbf{B},\mathbf{C}\}\) |

Beispiele: \(7\mapsto 11\), \(19\mapsto 29\), \(11\mapsto 17\), \(23\mapsto 35\) (\(r'=35\)).

Lean: `KeplerHurwitz/EABC/CollatzAuditGrid.lean` · Python: `eabc_collatz_audit.py`.

---

## 2. Warum das Raster ein Audit-Grid ist (kein formaler Beweis)

### A. Additive Barriere (\(+1\)) vs. Multiplikativität

Zerlegung \(\kappa=r\cdot e\) und \(V_4\) sind **multiplikative** Invarianten. Der Schritt \(\kappa\mapsto 3\kappa+1\) ist **affin**.

Durch \(+1\) bricht die Primfaktorstruktur auf: \(r',e'\) lassen sich **nicht** algebraisch aus \(r,e\) berechnen. Es entsteht eine Neu-Faktorisierung mit neuen Primfaktoren in A/B/C/E.

Deshalb: Tracking \(\gamma(\kappa)\to\gamma(\kappa')\) und DualCarrier entlang einer Trajektorie ist ein **Audit**, keine multiplikative Dynamik auf \(\mathbb H[\mathbb Z]\).

### B. Zwei ungelöste Kernprobleme der Dynamik `[C]`

Ein Collatz-Beweis aus dem EABC-Modell müsste u. a. leisten:

1. **Ausschluss von Divergenz:** strikt trajektorienweise \(\mathbb E[\alpha]>\log_2 3\) (nicht nur im Maß).
2. **Ausschluss fremder Zyklen:** keine Schleife außerhalb \(1\to 4\to 2\to 1\).

Beides bleibt **offen** — unabhängig von der Schärfe des Audit-Grids.

---

## 3. Epistemologische Einordnung (Claim-Boundary)

| Schicht | Was gilt | Status |
|---|---|---|
| Normalform, \(V_4\), DualCarrier, \(\gamma\) | Sprache und Invarianten | [`E-096`](../EVIDENCE_REGISTER.md) `[A]`/`[B]` |
| Syracuse-Kanalregeln (mod 12 / mod 24), \(\nu_2\) | konstruktives Audit-Grid | [`E-097`](../EVIDENCE_REGISTER.md) `[A]`/`[B]` |
| „EABC beweist Collatz“ | Sprung über die additive Barriere | **unzulässig** `[C]` / nicht behauptet |

Das EABC-Modell liefert eine präzise Sprache, Trajektorien als Phasen-Drifts in \(\mathbb H[\mathbb Z]\) zu **visualisieren und zu auditieren**. Die analytische Schließung der Collatz-Vermutung bleibt ein offenes Problem der Mathematik.

---

## 4. Integration mit dem Normalform-Stack

Entlang einer endlichen \(T_{\mathrm{acc}}\)-Trajektorie (EABC-Kerne, \(\gcd(\kappa,6)=1\)):

1. **Einzelschritt:** `syracuse_audit_step` — Kanal, \(\alpha\), DualCarrier in/out, Mod-24-Regel.
2. **Trajektorie:** `audit_trajectory` — Schritte + volle `eabc_pipeline`-Snapshots (Form \(e_{\mathrm{kep}}\) und Frame \(\gamma\)).
3. **Schichtentrennung:** Lean-Zeuge `mod8_class_not_equal_v4_class_witness_seven` — Mod-8-`EABCClass` von 7 ist **C**, \(V_4\) ist **B**. Keine stille Identifikation mit Net-Descent/Kanal-7.

Das bleibt Audit `[B]`; die additive Barriere (§2) bleibt.

---

## 5. Bedingte Norm-Relation unter Syracuse-Hypothesen

Lean: `KeplerHurwitz/EABC/CollatzSyracuseNorm.lean`

| Hypothese | Inhalt | Folgerung `[A under H]` |
|---|---|---|
| `SyracuseNormHypothesis κ κ' v` | \(3\kappa+1=\kappa'\,2^v\), beide Kerne embeddable, \(v\ge 1\) | `normSq(embed κ)=κ²`, `normSq(embed κ')=κ'²`; Cross-Identität |
| `SyracuseHalfStepHypothesis` | B/C-Halbschritt \(v=1\) | Spezialfall; Audit-Zeugen 7→11, 19→29, 11→17 |
| `SyracuseEmbedFactors` | `post = pre * factor` | `normSq post = normSq pre * normSq factor` |

**Offen / Non-Claim:** H gilt nicht automatisch für alle Odd-Trajektorien; globale Norm-Descent und Collatz bleiben offen. Die B/C-Zeugen sind sogar **Ascents** (`¬ SyracuseNormDescent 7 11`).

### 5.1 Doppelschritt / Makro-Abstieg (`CollatzTwoStep`)

Lean: `KeplerHurwitz/EABC/CollatzTwoStep.lean`

| Objekt | Inhalt |
|---|---|
| `SyracuseTwoStepHypothesis κ κ' κ'' v₁ v₂` | zwei beschleunigte Schritte gebündelt |
| Makro-Abstieg | `κ'' < κ` ⇔ `3κ'+1 < κ·2^{v₂}` **`[A under H]`** |
| Half-then-compensate | bei `v₁=1`, `κ>0`: Zwischenkern steigt ⇒ zweiter Schritt muss kompensieren |
| Zeuge Abstieg | `13 → 5 → 1` (`v=3,4`) |
| Zeuge Ascent | `7 → 11 → 17` (beide `v=1`) |
| \(V_4\)-Paar/Produkt | Dictionary `[B]` (nicht `toV4 κ''`) |

**Weiter offen (die drei Bausteine):** ergodisches \(\mathbb E[v]>\log_2 3\); Zykel-Ausschluss; Divergenz-Ausschluss. Doppelschritt klassifiziert Makro-Bedingungen — beweist sie nicht global.

### 5.2 Dreischritt-Kompensationsschranke (`CollatzThreeStep`)

Lean: `KeplerHurwitz/EABC/CollatzThreeStep.lean`

| Objekt | Inhalt |
|---|---|
| `SyracuseThreeStepHypothesis` | `κ → κ' → κ'' → κ'''` mit `(v₁,v₂,v₃)` |
| Makro-Abstieg | `κ''' < κ` ⇔ `3κ''+1 < κ·2^{v₃}` **`[A under H]`** |
| Double-half then compensate | `v₁=v₂=1` ⇒ `κ < κ''`; Abstieg braucht Kompensation in `v₃` |
| Zeuge Abstieg | `11 → 17 → 13 → 5` (`v=1,2,3`) |
| Zeuge Non-Descent | `7 → 11 → 17 → 13` (`v=1,1,2`; `52 \nless 7·4`) |

### 5.3 Zykel-Notwendige Bedingungen — Option A (`CollatzCycleNecessary`)

Lean: `KeplerHurwitz/EABC/CollatzCycleNecessary.lean`

| Aussage | Tag |
|---|---|
| Einziger 1-Schritt-Fixpunkt: `κ=1`, `v=2` | `[A]` |
| 3-Schritt-Return (`κ'''=κ`) ⇒ kein Makro-Abstieg / keine Kompensation | `[A]` |
| \(V_4\)-Kanalprodukt = `E` als Dictionary-Hypothese | `[B]` |
| Vollständiger Zykel-Ausschluss / Option B (Zylinder-Dichte) | **offen / Non-Claim** |

### 5.4 Option B — Zylinder-Scan Nicht-Kompensierer (Python `[B]`)

Modul: `src/kepler_hurwitz/eabc_cylinder_noncompensator_scan.py`

Für ungerade Starts \(\kappa\le N\) (default: \(\gcd(\kappa,6)=1\)) und Tiefen \(k\):

| Größe | Bedeutung |
|---|---|
| Nicht-Kompensierer | \(\kappa_k \ge \kappa_0\) nach \(k\) Schritten \(T_{\mathrm{acc}}\) |
| \(\rho_{\mathrm{nc}}(k)\) | Anteil Nicht-Kompensierer |
| Zylinder-Slice | Stratifikation nach \(\kappa\bmod 2^m\) |
| 3-Schritt-iff-Rate | numerischer Check der Lean-Schranke auf dem letzten Tripel |

```bash
PYTHONPATH=src python -m kepler_hurwitz.eabc_cylinder_noncompensator_scan \
  --n-max 5000 --k 1,2,3,4,5,6,8,10 --cylinder-mod 16 \
  --out docs/exports/eabc_cylinder_noncompensator_report.json
```

**Non-Claim:** kein Satz \(\rho_{\mathrm{nc}}(k)\to 0\); kein ergodisches \(\mathbb E[v]>\log_2 3\).

### 5.5 Richtung B — \(V_4\) × Zylinder-Korrelation (Python `[B]`)

Modul: `src/kepler_hurwitz/eabc_cylinder_v4_correlation.py`

Kontingenztabelle \((\kappa_0\bmod 2^m,\;\mathrm{toV}_4(\kappa_0))\) gegen Makro-Kompensation bei Tiefe \(k\); Fokus-Residuen (default \(5,15\bmod 16\)); Pfad-Kanalprodukt als Dictionary-Label.

**Beobachtung → Lean `[A]`:** Bei \(\gcd(\kappa,6)=1\) erzwingen die Klassen

| \(\kappa\bmod 16\) | mögliche \(V_4\) (mod 12) | Erstschritt \(\nu_2\) |
|---|---|---|
| \(5\) | nur \(E,A\) (\(\equiv 1,5\pmod{12}\)) | \(\ge 4\) |
| \(15\) | nur \(B,C\) (\(\equiv 7,11\pmod{12}\)) | \(=1\) |

Formal: `CollatzModularV2` (§5.6). Empirisch dazu: bei \(k=3\) ist \(\rho_{\mathrm{nc}}(5)\approx 0\) und \(\rho_{\mathrm{nc}}(15)=1\) im Fenster \(N=5000\).

```bash
PYTHONPATH=src python -m kepler_hurwitz.eabc_cylinder_v4_correlation \
  --n-max 5000 --k 3,10 --cylinder-mod 16 --focus 5,15 \
  --out docs/exports/eabc_cylinder_v4_correlation_report.json
```

**Non-Claim:** Korrelation ≠ Dominanz der kompensierenden Zylinder auf dem \(2^k\)-Baum; kein Collatz.

### 5.6 Modularer Erstschritt-Filter (Lean `[A]`)

Modul: `KeplerHurwitz/EABC/CollatzModularV2.lean`

| Aussage | Tag |
|---|---|
| \(\kappa\equiv 15\pmod{16}\) ⇒ \(\nu_2(3\kappa+1)=1\) | `[A]` |
| \(\kappa\equiv 5\pmod{16}\) ⇒ \(\nu_2(3\kappa+1)\ge 4\) | `[A]` |
| \(\kappa\equiv 5\pmod{16}\), \(\gcd(\kappa,6)=1\) ⇒ \(\kappa\equiv 1\) oder \(5\pmod{12}\) | `[A]` |
| \(\kappa\equiv 15\pmod{16}\), \(\gcd(\kappa,6)=1\) ⇒ \(\kappa\equiv 7\) oder \(11\pmod{12}\) | `[A]` |
| Maß-Dominanz / Collatz | **Non-Claim** |

Reachable-Fassade: `reachable_mod16_fifteen_v2_eq_one`, `reachable_mod16_five_v2_ge_four`, CRT-Varianten.

Unter `SyracuseNormHypothesis` zusätzlich `[A under H]`:

| Aussage | Tag |
|---|---|
| \(\kappa\equiv 15\pmod{16}\) ⇒ \(v=1\) und \(\kappa<\kappa'\) | `[A under H]` |
| \(\kappa\equiv 5\pmod{16}\) ⇒ \(v\ge 4\) und \(\kappa'<\kappa\) | `[A under H]` |

### 5.7 Mischung auf \(\mathbb Z/16\mathbb Z\) (Python `[B]`)

Modul: `src/kepler_hurwitz/eabc_cylinder_mixing.py`

Ein-Schritt-Übergangszählung \(r\mapsto r'\) unter \(T_{\mathrm{acc}}\) im Fenster; algebraische Notizen für die Lean-Zylinder 5 und 15.

```bash
PYTHONPATH=src python -m kepler_hurwitz.eabc_cylinder_mixing \
  --n-max 5000 --modulus 16 \
  --out docs/exports/eabc_cylinder_mixing_report.json
```

**Non-Claim:** kein invariantes Maß / keine Dominanz auf dem \(2^k\)-Baum.

### 5.8 Gefängnis \(\{7,15\}\) — Bilder `[A]` und Escape-Zeit `[B]`

Lean (`CollatzModularV2`):

| Aussage | Tag |
|---|---|
| \(\kappa\equiv7\pmod{16}\) ⇒ \(\nu_2=1\) | `[A]` |
| Half-step-Bild: \(15\mapsto\{7,15\}\), \(7\mapsto\{3,11\}\) | `[A]` |
| Exact \(m\bmod 2\)-Split: \(15\to7\) ↔ `Even(κ/16)`; \(7\to11\) ↔ `Even(κ/16)` | `[A]` |
| unter H: dieselben Bilder + Ascent für Klasse 7 | `[A under H]` |

Python: `src/kepler_hurwitz/eabc_prison_escape.py` — Escape-Zeit aus \(\{7,15\}\), Survival \(S(k)\).

```bash
PYTHONPATH=src python -m kepler_hurwitz.eabc_prison_escape \
  --n-max 5000 --max-steps 64 \
  --out docs/exports/eabc_prison_escape_report.json
```

**Non-Claim:** kein geometrischer Tail-Satz / kein invariantes Maß.

### 5.9 Übersicht §§5.4–5.8 (Index)

Lokale Zylinder- / Modular-Kette ohne Überinterpretation. Claim-Wand: In-Window ≠ Maß auf \(\mathbb N\).

| § | Baustein | Schicht | Kernaussage | Artefakt / Report |
|---|---|---|---|---|
| 5.4 | Nicht-Kompensierer \(\rho_{\mathrm{nc}}(k)\) | Python `[B]` | Trend nach unten, lokal nicht monoton; starke Mod-16-Asymmetrie | `eabc_cylinder_noncompensator_scan.py` · [`eabc_cylinder_noncompensator_report.json`](exports/eabc_cylinder_noncompensator_report.json) |
| 5.5 | \(V_4\) × Zylinder | Python `[B]` → Lean `[A]` | CRT: \(5\mapsto\{E,A\}\), \(15\mapsto\{B,C\}\); \(\rho_{\mathrm{nc}}(5)=0\), \(\rho_{\mathrm{nc}}(15)=1\) bei \(k=3\) (\(N=5000\)) | `eabc_cylinder_v4_correlation.py` · [`eabc_cylinder_v4_correlation_report.json`](exports/eabc_cylinder_v4_correlation_report.json) |
| 5.6 | Modular-Erstschritt | Lean `[A]` / `[A under H]` | \(15\Rightarrow\nu_2=1\), Ascent; \(5\Rightarrow\nu_2\ge4\), Descent | `CollatzModularV2.lean` · `reachable_mod16_*` |
| 5.7 | \(T_{\mathrm{acc}}\)-Mischung | Python `[B]` | \(15\to\{7,15\}\) 50/50; \(5\) streut; Klassen \(3,7,11\) mit \(\langle v\rangle=1\) | `eabc_cylinder_mixing.py` · [`eabc_cylinder_mixing_report.json`](exports/eabc_cylinder_mixing_report.json) |
| 5.8 | Gefängnis \(\{7,15\}\) | Lean `[A]` + Python `[B]` | Bilder \(15\mapsto\{7,15\}\), \(7\mapsto\{3,11\}\); exact \(m\bmod 2\)-Split; Escape \(S(t)\approx 2^{-t}\) im Fenster | `CollatzModularV2.lean` · `eabc_prison_escape.py` · [`eabc_prison_escape_report.json`](exports/eabc_prison_escape_report.json) |
| 5.10 | Exit \(\{3,11\}\) + AP-Hälften | Lean `[A]` | \(3\mapsto\{5,13\}\), \(11\mapsto\{1,9\}\); finite 50/50-Zählungen Länge \(2M\) | `CollatzModularV2.lean` · `reachable_mod16_three_*` / `*_AP_*_card` |
| 5.11 | Vollständige odd-mod-16 \(\nu_2\)-Tafel + Master-API | Lean `[A]` / `[A under H]` | \(1,9=2\); \(13=3\); \(5\ge4\); Dispatcher `mod16_normHyp_firstStep` | `CollatzModularV2.lean` · `reachable_mod16_normHyp_firstStep` |
| 5.12 | Ascent-Digraph / Zykel-Obstruktion | Lean `[A]` | Nur konstante-`15`-Zykeln; `{3,7,11}` exit ≤2 Half-Steps; kein ℕ-Fixpunkt unter `15→15` | `CollatzDigraph.lean` · `reachable_ascent_*` |
| 5.13 | Ansatz-4 Spektralradius \(A_k\) | Python `[B]` | relationaler Ascent-Automat: \(\lambda_{\max}=1\) für \(k=2..12\) (Selbstschleife \(2^k-1\)); kein \(\lambda\to0\) | `docs/exports/eabc_automaton_spectral_ak_report.json` |
| 5.14 | Ansatz-4 Wrap-/Chirurgie-Audit | Python `[B]` (+ Lean-Kontrast `[A]`) | \(F_k=\pi_k\circ T\circ s_k\); \(G_k^{\mathrm{cut}}\) nilpotent/\(\rho=0\) primär \(k\in[2,12]\), Ext. \(k\in[2,14]\); Zykeln \(k=10..12\) nur mit Wrap; \(\forall k\) azyklisch offen `[C]` | `docs/exports/eabc_modular_wrap_surgery_report.json` |
| 5.15 | Ansatz-4 projektive Liftbarkeit | Python `[B]` | \(C_{26}\): \(L_{\mathrm{edge}}=26\), \(L_{\mathrm{cyc-edge}}=18\), \(L_{\mathrm{cycle}}=0\); 4 Zykeln ohne Set-/Order-Lift; keine Tower-Länge \(\ge2\) auf \(k\in[2,14]\); Wrap-Break \(719\mapsto1079\) | `docs/exports/eabc_cycle_liftability_report.json` |
| 5.16 | Boolesche Lift-Kohärenz | Python `[B]` + Lean `[A]` abstrakt | \(C_{26}\): Bool-tr\((P)=0\), \(\delta_{\mathrm{coh}}=1\); lokal≠global als CSP; Lean: Cycle⇒Edge, Gegenbsp. Edge⇏Cycle | `eabc_c26_lift_obstruction_certificate.json` · `ModularSyracuseLift.lean` |
| 5.17 | Boolesche Lift-Monodromie auf affinen A-Constraint-Kreisen | Python `[B]` + Lean OR-AND `[A]` | \(P\neq S\); \(P\in\{Z,E_{01}\}\); nichtinvertierbare Relationsmonodromie; keine ℤ₂-Holonomie | `eabc_lift_monodromy_report.json` |
| 5.18 | Boolescher Absorptionsmechanismus (Kern) | Python `[B]` | **frozen:** \(P\neq S\); \(P\in\{Z,E_{01}\}\); Einheitsdefekt \((\ell-1)E_{00}+E_{01}\Rightarrow\delta=1\); ersetzt Flip/Coxeter | §5.18 · `eabc_lift_monodromy_report.json` |
| 5.19 | Boolesches Absorptionsmonoid | Python `[B]` + Lean `[A]` | **frozen:** \(M_{\mathrm{abs}}\) / \(M_{\mathrm{abs}}^{1}\); \(a_{\mathrm{abs}}=2\); lokale Absorption | `eabc_boolean_absorption_monoid_report.json` · `BooleanRelationAbsorption.lean` |
| 5.20 | Minimaler Kohärenzdefekt | Python `[B]` + Lean `[A]` (allg. \(\ell\ge2\) + Fokus-Spezialisierung) | **frozen:** \(\kappa_{\mathrm{loc}}=2\), \(a_{\mathrm{abs}}=2\), BoolTrace\((P_j)=0\), \(P_j\in\{E_{01},Z\}\), \(\delta_{\mathrm{coh}}=1\); \(F_k\) = `[B]`-Zeugen von `MatchesUnitDefectPattern` | §5.20 · `FocusCycleUnitDefect.lean` · derselbe Export |
| 5.21 | Archimedische Bilanz / Aperiodizitätskontrolle | Docs `[C]` Open-Non-Claim | **frozen:** exakte Bilanz \(\log_2 n_m=\log_2 n_0+m\log_2 3-V_m+R_m\); Drift \(D_m\) definiert; Brücken zu ℕ-Abstieg offen | §5.21 |
| 5.22 | Arithmetischer Relations-Klassifikator \(\Phi_k\) | Python `[B]` + Lean `[A]` (Labels/Packaging) | **audit:** naive \(\Phi_k^{\mathrm{stated}}\) scheitert auf \(G_k^{\mathrm{cut}}\) bei \(\nu_2=1\); refined \(\Phi_k^{\mathrm{ref}}\) trifft \(F_k\); Fokus-Wörter \(E_{00}^{\ell-1}E_{01}\); \(G_k^{\mathrm{cut}}\) azyklisch \(k\in[10,14]\) | `relation_classifier_phi_k_focus_cycles_k10_14.json` · `SyracuseRelationClassifierPhi.lean` |
| 5.23 | Stabile-Zyklus-Klassifikation auf \(G_k^{\mathrm{cut}}\) | Stub / next | offen: absorbierende Wörter \(\forall\) Cut-Zykeln; \(\forall k\) azyklisch bleibt `[C]` | — |

**Kausalkette (lokal, geschlossen):**
\[
\{7,15\}_{v=1}
\to\{3,11\}_{v=1}
\to\{5\}_{v\ge4},\;\{13\}_{v=3},\;\{1,9\}_{v=2}
\]
Einstieg: `reachable_mod16_normHyp_firstStep` / `mod16OddV2LowerBound`.

**Gemeinsamer Non-Claim:** kein \(\rho_{\mathrm{nc}}\to 0\); kein invariantes Maß / keine Ergodizität auf ganz \(\mathbb N\); kein Collatz-Beweis. Der \(m\bmod 2\)-Split ist Lean `[A]` (`mod16_*_half_image_iff_even_quot`); finite 50/50-Zählungen auf APs der Länge \(2M\) sind Lean `[A]` (§5.10); kein globaler Tail-Satz.

### 5.10 Exit-Kanäle \(\{3,11\}\) und finite AP-Hälften (Lean `[A]`)

Fortsetzung von §5.8: nach dem Gefängnis-Exit.

| Aussage | Tag |
|---|---|
| \(\kappa\equiv3\pmod{16}\) ⇒ \(\nu_2=1\); Bild \(\{5,13\}\); \(3\to5\) ↔ `Even(κ/16)` | `[A]` |
| \(\kappa\equiv11\pmod{16}\) ⇒ \(\nu_2=1\); Bild \(\{1,9\}\); \(11\to1\) ↔ `Even(κ/16)` | `[A]` |
| unter H: Ascent für Klassen 3 und 11 | `[A under H]` |
| `fifteen_AP_image7_card` / `seven_AP_image11_card` / `three_*` / `eleven_*`: unter den ersten \(2M\) AP-Indizes genau \(M\) auf dem Even-Zweig | `[A]` (endlich, nicht asymptotisches Maß) |

Fluss-Skizze (alle \(\nu_2\) Lean `[A]`):
\[
\{7,15\}_{v=1}
\to\{3,11\}_{v=1}
\to
\begin{cases}
5 & (v\ge 4,\ \text{Descent}) \\
13 & (v=3,\ \text{Descent}) \\
1,9 & (v=2,\ \text{Descent für }\kappa>1)
\end{cases}
\]

### 5.11 Vollständige \(\nu_2\)-Tafel und Master-API (Lean `[A]`)

| \(\kappa\bmod 16\) | \(\nu_2(3\kappa+1)\) | unter H (Kern) |
|---|---|---|
| 3,7,11,15 | \(=1\) | Ascent \(\kappa<\kappa'\) |
| 1,9 | \(=2\) | Descent falls \(\kappa>1\) |
| 13 | \(=3\) | Descent |
| 5 | \(\ge4\) | Descent |

**Primäre Einstiege (wiederverwendbar):**

| API | Rolle |
|---|---|
| `mod16OddV2LowerBound` / `mod16_odd_v2_ge_lowerBound` | untere Schranke aus Residuum |
| `normHyp_descent_of_v_ge_two` | generischer Descent bei \(v\ge2\), \(\kappa>1\) |
| `mod16_normHyp_firstStep` | Master-Klassifikator Ascent/Descent nach \(\kappa\bmod 16\) |
| `reachable_mod16_normHyp_firstStep` | Reachable-Fassade |

**Non-Claim:** keine natürliche Dichte als `Tendsto`-Theorem; kein globaler Tail; kein Collatz.

### 5.12 Ascent-Digraph und Zykel-Obstruktion (Lean `[A]`)

Modul: `KeplerHurwitz/EABC/CollatzDigraph.lean` — endlicher Half-Step-Digraph auf den odd Residuen mod 16, gebaut aus den Bild-Lemmata von `CollatzModularV2`.

| Aussage | Tag |
|---|---|
| `IsAscentClass` = \(\{3,7,11,15\}\); `IsDescentClass` = \(\{1,5,9,13\}\) | `[A]` |
| Half-Step-Kanten: \(15\mapsto\{7,15\}\), \(7\mapsto\{3,11\}\), \(3\mapsto\{5,13\}\), \(11\mapsto\{1,9\}\) | `[A]` |
| Klassen 3 und 11 haben keine ausgehende Kante in die Ascent-Menge (Exit-Senken) | `[A]` |
| Klasse 7: jeder Länge-2-Walk landet in einer Descent-Klasse | `[A]` |
| Jede Ascent-Klasse \(\neq 15\) erreicht Descent in ≤2 Digraph-Kanten / ≤2 Half-Steps | `[A]` |
| Jeder gerichtete Zykel, der nur Ascent-Residuen besucht, ist konstant `15` | `[A]` |
| Klasse 7 liegt auf keinem Ascent-only-Zykel | `[A]` |
| Residuum-Selbstschleife `15→15` existiert, hebt aber nicht zu einem ℕ-Fixpunkt: \((3\kappa+1)/2\neq\kappa\) bei \(\kappa\equiv15\) | `[A]` |
| unter H: `15→15` bleibt strikter Kern-Ascent | `[A under H]` |

**Schärfe der Aussage:** Es gibt Ascent-only-Zykeln auf Residuen-Ebene (konstante `15`-Schleifen). Die Obstruktion ist: (i) keine gemischten Ascent-Zykeln durch `3`/`7`/`11`; (ii) `{3,7,11}` bricht nach ≤2 Half-Steps in Descent aus; (iii) die `15`-Schleife ist kein Fixpunkt auf \(\mathbb N\). Klasse `15` ist absichtlich vom ≤2-Exit ausgenommen (Residuen-Selbstschleife).

**Non-Claim:** kein Baire / \(\mathbb Z_2\) / \(\lambda_{\max}\to0\); kein Satz, dass jede odd \(\mathbb N\)-Bahn die Ascent-Menge verlässt; kein Collatz.

Reachable-Fassade: `reachable_ascent_cycle_all_fifteen`, `reachable_no_ascent_cycle_with_non_fifteen`, `reachable_seven_not_on_ascent_cycle`, `reachable_half_step_ne_self_of_mod16_fifteen`, `reachable_mod16_fifteen_self_loop_not_fixed`, `reachable_seven_two_step_reaches_descent`, `reachable_ascent_non_fifteen_reaches_descent_within_two_edges`, `reachable_ascent_non_fifteen_exits_in_at_most_two_half_steps`.

#### 5.12.1 Trennung: Lean-Digraph `[A]` vs. \(\mathbb Z_2\)-Baire `[B]`/`[C]`

| Ebene | Resultat | Claim |
|---|---|---|
| Lean `CollatzDigraph` | keine Ascent-only-Zykeln außer konstant-`15`; `{3,7,11}` → Descent in ≤2 Half-Steps; `15→15` ≠ ℕ-Fixpunkt | `[A]` |
| \(\mathbb Z_2\)-Baire-Diagnostik (Ansatz 1) | \(X_{\mathrm{avoid}}\) typischerweise komager; relatives Haar der \(k\)-Schritt-Ausweicher \(\to 1\) (Zylinder-Proxy) | `[B]` numerisch / `[C]` topologische Lesart |
| Notwendige Kopplung für eine künftige ℕ-Ausweich-Sperre | \(\mathbb N\subset\mathbb Z_2\) vs. generisches Ausweichen in \(\mathbb Z_2\) | **Non-Claim** |

**Explizit:**

* **Ansatz 1 allein ist unzureichend:** reine 2-adische Topologie liefert keine ℕ-Ausweich-Sperre — eher das Gegenteil (komageres Ausweichen in \(\mathbb Z_2\)).
* **Ansatz 3 (Christol / Galois-Rigidität):** zurückgestellt / derzeit nicht verfolgt (kein Repo-Anschluss; Überclaim-Risiko).
* **Ansatz 2 (Lyapunov / mittlere \(\nu_2\)):** nur `[B]`-Skizze — Mittel-\(\nu_2\) entlang endlicher Ascent-Pfade / Gefängnis-Sojourns; **kein** Lean-Entropie- oder Periodenmittelwert-Theorem. Schwelle \(\log_2 3\) bleibt heuristisch.

Der Lean-Hebel bleibt die **endliche Digraph-Kombinatorik** mod 16; alles ab „unendliches Ausweichen auf \(\mathbb N\) unmöglich“ bleibt Non-Claim.

### 5.13 Ansatz 4: Spektralradius endlicher Automaten `[B]`

Finite-\(k\)-Diagnostik auf zwei getrennten Digraphen (\(k=2..12\)); Export: `docs/exports/eabc_automaton_spectral_ak_report.json`.

| Graph | Konstruktion | Befund \(k=2..12\) |
|---|---|---|
| **A** (Lean-nah) | odd Residuen in Ascent-Klassen; **relationale** Kante \(u\to v\) wenn ein Lift \(\kappa\equiv u\pmod{2^k}\) mit \(T_{\mathrm{acc}}(\kappa)\equiv v\pmod{2^k}\) und \(v\) Ascent (bei \(k=4\) = `HalfStepEdge`) | \(\lambda_{\max}=1\); genau eine Selbstschleife an \(2^k-1\) (\(\equiv15\bmod16\) für \(k\ge4\)) |
| **B** (User-Variante) | funktional auf allen odd Residuen; Kante nur wenn \(T_{\mathrm{acc}}(u)\not\equiv1\pmod{2^k}\) — **nicht** der Lean-Ascent-Digraph | \(\lambda_{\max}=0\) für \(k\le9\); \(\lambda_{\max}=1\) ab \(k=10\) (fremde Zykeln im Avoid-1-Graphen) |

**Kontrast:** der *funktionale* Ascent-Graph auf kanonischen Repräsentanten hat keine Selbstschleifen und \(\lambda_{\max}=0\) — er ist **nicht** Lean-`HalfStepEdge`.

**Non-Claim:** kein \(\lambda_{\max}(A_k)\to0\); \(\lambda_{\max}<1\) bei festem \(k\) wäre nur eine Aussage über diesen endlichen Automaten, kein globaler Limes; kein unendliches ℕ-Ausweichen; kein Collatz; kein Lean-Theorem aus dieser Diagnostik.

### 5.14 Ansatz 4: Modularer Wrap- / Chirurgie-Audit `[B]`

Präzisierung von §5.13: der Avoid-1-Graph ist der **funktionale** Graph \(F_k=\pi_k\circ T\circ s_k\) (ein Ausgangspfeil pro odd Rest). Daher \(\rho(A_k)\in\{0,1\}\) — reiner Zykel-Indikator, kein Verzweigungs-Spektrum.

Skript: `src/kepler_hurwitz/eabc_modular_wrap_surgery.py` · Export: [`eabc_modular_wrap_surgery_report.json`](exports/eabc_modular_wrap_surgery_report.json). Audit-Schicht: **Python** (Repo-Implementierung; keine SageMath-Abhängigkeit für diesen Stand).

#### Finales Ergebnis-System (Energiedoku-Stand)

```
[A] Digraph & Lokale Steigungsklassen (Lean 4)
    ├── Ascent-only-Zykel in {3,7,11,15} mod 16: Lean schließt echte Ascent-only-Zykel aus
    │   (keine gemischten Zykeln durch 3/7/11); Residuen-Selbstschleife 15→15 / u=2^k−1
    │   ist logisch getrennt (kein ℕ-Fixpunkt). Siehe §5.12 / CollatzDigraph.
    └── Fixpunktbetrachtung u = 2^k − 1 getrennt von modularen Sektionen s_k.
[B] Endliche modulare Wrap-Surgery (Python-Audit)
    ├── F_k = π_k ∘ T ∘ s_k auf ungeraden Restklassen, Senke 1 entfernt
    ├── G_k^cut = G_k \ (E_k^wrap ∪ E_k^loss)
    ├── Primär verifiziert k∈[2,12]: A_k^cut nilpotent (ρ=0)
    │   Extended check k∈[2,14] ebenfalls ρ_cut=0 (Export-JSON; §5.15)
    └── Zyklen: k=10 C_26 (719↦1079≡55); k=11 C_25 (1619↦2429≡381);
        k=12 lengths 7,6
[C] Offener Non-Claim
    ├── Offen: ∀k≥2 G_k^cut azyklisch
    └── Keine projektive Allquantifizierung, keine Ricci-Metapher
```

**Reichweiten-Hinweis:** Primärer Surgery-Theoremtext dieses § bezieht sich auf \(k\in[2,12]\). Die erweiterte Prüfung \(k\in[2,14]\) (ebenfalls \(\rho_{\mathrm{cut}}=0\)) ist im Export und in **§5.15** mitgeführt; kein \(\forall k\)-Satz.

Liftbarkeit / projektive Kompatibilität unter \(\pi_{k+1,k}\) ist **Diagnostik in §5.15** (finite Negativbefunde), nicht Teil des universellen Claims hier.

#### Textfassung (kanonisch)

> Für jede Präzisionsstufe \(k\ge 2\) wird der beschleunigte Syracuse-Schritt auf den kleinsten positiven ungeraden Repräsentanten modulo \(2^k\) angewandt und anschließend wieder modulo \(2^k\) reduziert. Dadurch entsteht ein endlicher partieller funktionaler Digraph \(G_k\), nachdem der Zustand \(1\) als Senke entfernt wurde.
>
> Als chirurgisch instabil gelten
> \[
> E_k^{\mathrm{wrap}}=\{(u,F_k(u)):T(u)\ge 2^k\},\qquad
> E_k^{\mathrm{loss}}=\{(u,F_k(u)):\nu_2(3u+1)\ge k\}.
> \]
> Der geschnittene Graph ist \(G_k^{\mathrm{cut}}=G_k\setminus(E_k^{\mathrm{wrap}}\cup E_k^{\mathrm{loss}})\).
>
> Exhaustive Python-Computation für \(2\le k\le 12\) (primärer Surgery-Stand): die Cut-Graphen sind azyklisch; \(A_k^{\mathrm{cut}}\) ist nilpotent; \(\rho=0\). Extended check \(2\le k\le 14\) bestätigt dasselbe \(\rho_{\mathrm{cut}}=0\) (siehe Verifikationstabelle und **§5.15**). Vor dem Schnitt treten Zykeln nur bei \(k=10\) (\(C_{26}\), Wrap \(719\mapsto1079\equiv55\)), \(k=11\) (\(C_{25}\), Wrap \(1619\mapsto2429\equiv381\)) und \(k=12\) (Längen \(7\) und \(6\)) auf. Über die geprüften aufeinanderfolgenden Stufen gibt es keine kompatible projektive Zykel-Familie (Details: **§5.15**, Export [`eabc_cycle_liftability_report.json`](exports/eabc_cycle_liftability_report.json)).
>
> Explizit **kein** universelles Theorem: \(\forall k\ge 2\,(G_k^{\mathrm{cut}}\text{ azyklisch})\) bleibt offen `[C]`. „Chirurgie“ meint hier ausschließlich graphentheoretische Kantenentfernung — keine Ricci-/Perelman-Metapher als Mathematik.

**Lean-Nuance `[A]` (nicht überclaimen):** Nicht ungequalifiziert „Ascent-only-Zykel formal ausgeschlossen“ schreiben — in `CollatzDigraph` existiert die Residuen-Selbstschleife \(15\to15\) (bzw. \(u=2^k-1\)). Lean schließt *echte* geschlossene Ascent-only-Dynamik durch gemischte Klassen \(\{3,7,11\}\) aus und trennt die \(15\)-Selbstschleife logisch von einem ℕ-Fixpunkt (§5.12). Surgery am funktionalen Avoid-1-Graphen entfernt diese relationale Selbstschleife **nicht**.

#### Verifikationstabelle (funktionaler Avoid-1-Graph)

| \(k\) | \(\rho\) | Zykeln (Längen) | Wrap-Kanten auf Zykeln | `#cut` | \(\rho_{\mathrm{cut}}\) |
|---:|---:|---|---|---:|---:|
| 2–9 | 0 | — | 0 | 0–43 | 0 |
| 10 | 1 | \([26]\) | \(719\to55\) (exakt \(1079\)) | 85 | 0 |
| 11 | 1 | \([25]\) | \(1619\to381\) (exakt \(2429\)) | 171 | 0 |
| 12 | 1 | \([7,6]\) | \(3563\to1249\), \(3311\to871\) | 341 | 0 |
| 13–14 | 0 | — | 0 | 683–1365 | 0 |

**User-Vorschau korrigiert:** \(k=10\) (\(C_{26}\), \(719\to55\)) bestätigt; \(k=11\) war nicht \(C_{26}/1743\to1079\) (\(1743\) wrappt nach \(567\) und speist nur in den Zykel); \(k=12\) war nicht \([26,12]\).

> **Non-Claim-Box `[C]`**
> - Kein Collatz-Beweis; kein unendliches ℕ-Ausweichen; keine Ricci-Metapher als Mathematik.
> - Wrap-Schnitt ≠ Beweis der Abwesenheit von ℕ-Zykeln.
> - \(\rho(A_k^{\mathrm{cut}})=0\) bzw. Nilpotenz für alle \(k\ge2\) ist **kein** Theorem hier — nur finite Verifikation: primär \(k\in[2,12]\), extended \(k\in[2,14]\) (Export / §5.15).
> - Keine projektive Allquantifizierung (Liftbarkeit: §5.15, finite Negativbefunde).
> - Nicht identisch mit Lean-`CollatzDigraph` `[A]`; kein Lean-Theorem für universelle Surgery.

### 5.15 Projektive Liftanalyse der modularen Wrap-Zyklen `[B]`

Fortsetzung von §5.14. Skript: `src/kepler_hurwitz/eabc_cycle_liftability.py` · Export: [`eabc_cycle_liftability_report.json`](exports/eabc_cycle_liftability_report.json).

Statusformel: **vollständig reproduzierbar innerhalb des explizit geprüften Bereichs und der festgelegten Definitionen** — kein \(\forall k\)-Satz, kein Collatz.

#### Freeze-Fassung (kanonisch)

Für die modularen Syracuse-Abbildungen \(F_k\) wurden die im Bereich \(2\le k\le 14\) auftretenden nichttrivialen Zyklen bestimmt und auf ihre Kompatibilität mit der natürlichen Projektion
\[
\pi_{k+1,k}:\mathbb Z/2^{k+1}\mathbb Z\longrightarrow\mathbb Z/2^k\mathbb Z
\]
untersucht. Dabei sind drei verschiedene Liftbegriffe zu unterscheiden.

#### Drei Lift-Ebenen

\[
\begin{aligned}
L_{\mathrm{edge}}(C_k)
&=
\#\{\text{Kanten von }C_k\text{ mit mindestens einem zulässigen lokalen Lift}\},\\[2mm]
L_{\mathrm{cyc-edge}}(C_k)
&=
\#\{\text{Kanten, deren Lift auf einem Zyklus von }F_{k+1}\text{ liegt}\},\\[2mm]
L_{\mathrm{cycle}}(C_k)
&=
\mathbf 1_{\{\text{vollständiger kompatibler Zykellift existiert}\}}.
\end{aligned}
\]

Eine einzelne Zykluskante \(u_i\to u_{i+1}\) ist **lokal liftbar**, wenn Lifts \(\widetilde u_i\equiv u_i\pmod{2^k}\), \(\widetilde u_{i+1}\equiv u_{i+1}\pmod{2^k}\) existieren mit \(F_{k+1}(\widetilde u_i)=\widetilde u_{i+1}\).

**Set-Liftbarkeit:** \(C_k\) ist set-liftbar, wenn ein Zyklus \(C_{k+1}\) existiert mit \(\pi_{k+1,k}(C_{k+1})=C_k\) als Mengen (unabhängig von Reihenfolge/Multiplizitäten).

**Order-Liftbarkeit:** zusätzlich bleibt die zyklische Reihenfolge der Zustände bis auf zyklische Rotation unter der Projektion erhalten.

Es gilt \(\text{order-liftbar}\Longrightarrow\text{set-liftbar}\); die Umkehrung gilt nicht zwingend. Beide Prüfungen sind im JSON getrennt ausgewiesen (`set_liftable`, `order_liftable`).

#### \(C_{26}\) bei \(k=10\): \(L_{\mathrm{edge}}=26\), \(L_{\mathrm{cyc-edge}}=18\), \(L_{\mathrm{cycle}}=0\)

Für den bei \(k=10\) auftretenden Zyklus \(C_{26}\) sind alle 26 Kanten einzeln lokal liftbar. Von diesen lokalen Kantenlifts liegen 18 auf zyklischen Komponenten der Folgestufe. Dennoch existiert keine gemeinsame konsistente Auswahl der Zustandslifts, die den vollständigen \(C_{26}\) zu einem geschlossenen Zyklus auf Stufe \(k=11\) fortsetzt:
\[
L_{\mathrm{edge}}=26,\qquad L_{\mathrm{cyc-edge}}=18,\qquad L_{\mathrm{cycle}}=0.
\]
Das ist der mathematisch interessante Befund: alle lokalen Übergänge können irgendwo eine Stufe höher realisiert werden, aber diese lokalen Realisierungen lassen sich nicht zu einem einzigen geschlossenen, kohärent projizierenden Zyklus zusammensetzen.

#### Kantenlift vs. Zykellift als CSP

Sei \(C_k=(u_0,\dots,u_{\ell-1})\) mit \(F_k(u_i)=u_{i+1}\) (zyklisch). Zustandslifts nach \(k+1\) liegen in \(\pi_{k+1,k}^{-1}(u_i)=\{u_i,\,u_i+2^k\}\). Schreibt man \(\widetilde u_i=u_i+\varepsilon_i 2^k\) mit \(\varepsilon_i\in\{0,1\}\), so erzeugt jede Kante eine Relation \(R_i\subseteq\{0,1\}^2\) durch
\[
(\varepsilon_i,\varepsilon_{i+1})\in R_i
\iff
F_{k+1}(u_i+\varepsilon_i 2^k)=u_{i+1}+\varepsilon_{i+1}2^k.
\]
Lokale Kantenliftbarkeit bedeutet lediglich \(R_i\neq\varnothing\) für jedes \(i\). Ein vollständiger Zykellift existiert erst, wenn das zyklische Constraint-System \((\varepsilon_i,\varepsilon_{i+1})\in R_i\) für alle \(i\) eine gemeinsame Lösung besitzt. Lokales \(R_i\neq\varnothing\) impliziert diese globale zyklische Lösung nicht. Für den untersuchten \(C_{26}\) ist das System unerfüllbar — globaler Kohärenzdefekt, nicht notwendig lokales Fehlen von Übergangslifts.

#### Wrap-Break \(719\to55\) / \(T=1079\) / \(F_{11}(719)=1079\)

Auf Stufe \(k=10\): \(T(719)=1079\), also \(F_{10}(719)=1079\bmod 1024=55\). Auf Stufe \(k=11\) liegt \(1079<2048\) im Fundamentalbereich, also \(F_{11}(719)=1079\) (nicht \(55\)). Unter der Projektion gilt \(1079\equiv55\pmod{1024}\), sodass die einzelne Kante projektiv korrekt erscheint; die Trajektorie setzt sich aber von \(1079\) fort, nicht vom kanonischen Repräsentanten \(55\).

**Definition Wrap-Break:** Eine auf Stufe \(k\) rückgefaltete Kante verliert auf Stufe \(k+1\) ihre kanonische Zielrepräsentation. Das bedeutet nicht zwangsläufig, dass die Kante nicht projektiv liftbar ist — nur, dass die endliche Repräsentantendynamik nicht unverändert fortgesetzt wird.

#### Endliche Ergebnisse (`k∈[2,14]`, Lifts gegen \(k+1\le15\`)

Im gesamten untersuchten Bereich wurden genau vier nichttriviale \(F_k\)-Zyklen erfasst; keiner ist zur jeweils geprüften Folgestufe set- oder order-liftbar.

| \(k\) | Länge | Set-Lift | Order-Lift | \(L_{\mathrm{edge}}\) | \(L_{\mathrm{cyc-edge}}\) | \(L_{\mathrm{cycle}}\) | pred / succ |
|---:|---:|:---:|:---:|---:|---:|:---:|:---:|
| 10 | 26 | nein | nein | 26 | 18 | 0 | — / — |
| 11 | 25 | nein | nein | 25 | 0 | 0 | — / — |
| 12 | 7 | nein | nein | 7 | 0 | 0 | — / — |
| 12 | 6 | nein | nein | 6 | 0 | 0 | — / — |

**Keine Tower-Länge \(\ge 2\)** (nur geprüfter Bereich): Unter den im Bereich \(2\le k\le 14\) gefundenen und geprüften Zyklen existiert kein kompatibler projektiver Turm mit mindestens zwei Stufen. Daraus folgt **nicht** \(\forall k\ge 2\): es existiert kein Zyklenturm ab Stufe \(k\) — das bleibt Non-Claim `[C]`.

#### Surgery-Extension (Konsistenz mit §5.14)

Parallel wurde die Wrap-Surgery auf \(2\le k\le 14\) erweitert (primärer Theoremtext §5.14: \([2,12]\); Extended check hier und im Surgery-Export). Nach Entfernung der Wrap- und Präzisionsverlustkanten ist jeder geprüfte geschnittene Digraph azyklisch; \(A_k^{\mathrm{cut}}\) ist nilpotent mit \(\rho(A_k^{\mathrm{cut}})=0\) für alle \(k\in\{2,\dots,14\}\). Kein \(\forall k\ge 2\)-Satz.

#### Claim-Wall / Energiedoku-Raster

```
[A] Digraph & Lokale Steigungsklassen (Lean 4) — wie §5.14 / §5.12:
    echte Ascent-only-Zykel in {3,7,11} ausgeschlossen; Residuen-Schleife
    15→15 / 2^k−1 logisch getrennt (kein ℕ-Fixpunkt).
[B] Finite-k Python: Wrap-Surgery k∈[2,14] + projektive Lift-Tests
    └── C_26: L_edge=26, L_cyc-edge=18, L_cycle=0;
        alle 4 gefundenen Zykeln nicht set-/order-liftbar;
        keine Tower-Länge ≥2 auf k∈[2,14]; Wrap-Break 719↦1079
[C] Offener Non-Claim — ∀k Lift-/Azyklizitäts-Allquantor offen;
    keine Ricci-Metapher; Baire/ℤ₂ ≠ ℕ; kein Collatz
```

| Ebene | Reichweite | Status |
|---|---|---|
| `[A]` Digraph | lokale Steigungsklassen | Ascent-only-Struktur mod 16 formal in Lean 4 (15→15 getrennt) |
| `[B]` Wrap-Surgery + Lift | \(2\le k\le 14\) | \(A_k^{\mathrm{cut}}\) nilpotent; keine gefundenen Türme der Länge \(\ge2\) |
| `[C]` globale Grenze | \(k\ge 15\) und asymptotischer Grenzfall | offener Non-Claim |

Die Begriffe Wrap-Surgery, Wrap-Break und Zykluszerfall bezeichnen ausschließlich die hier definierten Operationen und Kompatibilitätseigenschaften endlicher modularer Digraphen. Sie implizieren weder einen Ricci-Fluss noch einen globalen Satz über die Collatz-Dynamik auf \(\mathbb N\).

> **Non-Claim-Box `[C]`**
> - Kein Collatz-Beweis; keine leere Avoider-Menge in \(\mathbb N\).
> - Finite only: kein \(\forall k\); „jeder modulare Zykel ist Artefakt \(\forall k\)“ = **OPEN / Non-Claim**.
> - Fehlende Lifts \(\neq\) Collatz; Baire/\(\mathbb Z_2\) \(\neq\) ℕ-Dynamik.
> - Kein universelles Liftbarkeits-Theorem — Definition + finite Negativbefunde im geprüften Bereich.
> - Ricci/Christol bleiben Non-Claim; kein Lean-Theorem für universelle Surgery (§5.14).

### 5.16 Boolesche Lift-Kohärenz `[B]` / Lean `[A]` abstrakt

Fortsetzung von §5.15. Skript: `src/kepler_hurwitz/eabc_lift_coherence.py` · Zertifikat: [`eabc_c26_lift_obstruction_certificate.json`](exports/eabc_c26_lift_obstruction_certificate.json) · Lean: `KeplerHurwitz/EABC/ModularSyracuseLift.lean`.

Statusformel: **finite modulare Objekte + abstrakte Lift-Logik** — kein Collatz, keine universelle Surgery, kein \(k\)-Bump jenseits des Freeze-Bereichs.

#### Definitionen

Sei \(C_k=(u_0,\dots,u_{\ell-1})\) ein Zyklus von \(F_k\). Binäre Lifts:
\[
\widetilde u_i = u_i + \varepsilon_i\, 2^k,\qquad \varepsilon_i\in\{0,1\}.
\]
Jede Kante \(u_i\to u_{i+1}\) induziert eine Relation
\[
R_i\subseteq\{0,1\}^2,\qquad
(\varepsilon,\varepsilon')\in R_i
\iff
F_{k+1}(u_i+\varepsilon\,2^k)=u_{i+1}+\varepsilon'\,2^k,
\]
und die boolesche \(2\times 2\)-Matrix \(M_i\) mit \(M_i[\varepsilon,\varepsilon']=1\) genau dann, wenn \((\varepsilon,\varepsilon')\in R_i\).

Boolesches Semiring-Produkt \(P=M_0\cdots M_{\ell-1}\); Bool-Spur \(\mathrm{Bool\text{-}tr}(P)=P_{00}\lor P_{11}\).

**Kriterium:** \(C_k\) ist **CycleLiftable** (im ε-CSP-Sinn) genau dann, wenn \(\mathrm{Bool\text{-}tr}(P)=1\).

Kohärenzdefekt:
\[
\delta_{\mathrm{coh}}(C)=\min_{\varepsilon\in\{0,1\}^\ell}\#\{\,i:(\varepsilon_i,\varepsilon_{i+1})\notin R_i\,\}.
\]

#### \(C_{26}\) bei \(k=10\)

Aus dem maschinenlesbaren Obstruktionszertifikat (und konsistent mit §5.15):
\[
L_{\mathrm{edge}}=26,\qquad L_{\mathrm{cyc-edge}}=18,\qquad L_{\mathrm{cycle}}=0,
\]
\[
\mathrm{Bool\text{-}tr}(P)=0,\qquad \delta_{\mathrm{coh}}(C_{26})=1.
\]
Alle Kanten sind lokal liftbar (\(R_i\neq\varnothing\)), aber die boolesche Spur verschwindet — globaler Kohärenzdefekt. Exhaustive ε-Erreichbarkeit (Meet-in-the-Middle über dem 2-Zustands-CSP) bestätigt \(\mathrm{CycleLiftable}\Leftrightarrow\mathrm{Bool\text{-}tr}(P)=1\) für \(C_{26}\).

Billige Fokus-Zyklen im Freeze: \(k=11\) \(C_{25}\) und beide \(k=12\)-Zyklen haben ebenfalls \(\mathrm{Bool\text{-}tr}=0\) und \(\delta_{\mathrm{coh}}=1\) (Summary-Export).

#### Lokal ≠ global als kombinatorisches CSP

Lokale Kantenliftbarkeit (\(R_i\neq\varnothing\) für alle \(i\)) ist ein *lokales* CSP; ein geschlossener Zykellift verlangt eine *globale* Belegung \(\varepsilon\) mit \((\varepsilon_i,\varepsilon_{i+1})\in R_i\) für alle \(i\). Das ist genau die Erfüllbarkeit eines zyklischen 2-Zustands-Constraint-Systems — lokal≠global ist hier kombinatorisch, nicht analytisch.

Lean `[A]` (`ModularSyracuseLift.lean`) formalisiert die abstrakte Implikation
\(\mathrm{CycleLiftable}\Rightarrow\forall e\,\mathrm{EdgeLiftable}\)
und ein winziges Gegenbeispiel (2+3 Knoten), dass die Umkehrung fehlschlägt — ohne \(F_k\)-Arithmetik und ohne Collatz-Brücke.

#### Research-Stränge (ohne Overclaim)

Drei parallele Stränge, klar getrennt:

1. **Formales Lift-System (Python `[B]`)** — Relationen \(R_i\), boolesche Produkte, \(\delta_{\mathrm{coh}}\), Obstruktionszertifikate für gefrorene Fokus-Zyklen.
2. **Lean endliche Kombinatorik `[A]`** — abstrakte Digraph-/Lift-Prädikate und Implikationen; keine ℕ-Collatz-Aussage.
3. **Strukturelle Numerik `[B]`** — bereits bestehende Lift-/Surgery-Scans im Freeze (\(k\le 14\)); kein \(k\)-Bump in diesem Schritt.

#### Roadmap-Stubs

| § | Thema | Status |
|---|---|---|
| 5.17 | Boolesche Lift-Monodromie auf affinen A-Constraint-Kreisen | **frozen** — Daten/Tabelle; Kern in §5.18 |
| 5.18 | Boolescher Absorptionsmechanismus (geschlossener Kern) | **frozen** — Binding-Box |
| 5.19 | Boolesches Absorptionsmonoid | **frozen** — Halbgruppe/Monoid + Tafel |
| 5.20 | Minimaler Kohärenzdefekt (\(\kappa_{\mathrm{loc}}\), \(a_{\mathrm{abs}}\)) | **frozen** — Lean `[A]` allg. \(\ell\ge2\) + `FocusCycleUnitDefect`; Python `[B]` Fokus-Zeugen |
| 5.21 | Archimedische Bilanz und Grenze der Aperiodizitätskontrolle | **frozen** — Open Non-Claim `[C]`; exakte Bilanz; Drift \(D_m\); Abstieg offen |
| 5.22 | Arithmetische Erzeugung der Relationsklasse \(\Phi_k\) | **audit** — Python `[B]` refined hält; naive stated nicht; Lean Labels `[A]` |
| 5.23 | Stabile-Zyklus-Klassifikation (\(G_k^{\mathrm{cut}}\)) | **stub** — nächster Arbeitsblock |

#### Claim-Wall

```
[A] Lean ModularSyracuseLift — abstrakte Cycle/Edge-Lift-Logik + Gegenbeispiel
[A] Lean SyracuseRelationClassifierPhi — Φ_k Labels / E00·E01-Packaging + Absorption-Reuse
[B] Python Bool-Kohärenz — C_26 Zertifikat; Fokus k=10,11,12 im Freeze
[B] Python Φ_k-Audit — refined match auf F_k; Fokus-Wörter; stated≠cut
[C] OPEN / Non-Claim — Universal surgery; ∀k; Collatz; Christol/Ricci;
    §5.21 archimedische Bilanz / Drift ≠ bewiesene Aperiodizitätssperre
```

> **Non-Claim-Box `[C]`**
> - Kein Collatz; keine universelle Wrap-Surgery-Vermutung als Theorem.
> - \(\mathrm{Bool\text{-}tr}(P)=0\) bzw. \(\delta_{\mathrm{coh}}\ge 1\) auf endlichen Zyklen \(\neq\) leere Avoider-Menge in \(\mathbb N\).
> - Kein \(k\)-Bump; Freeze-Bereich unverändert.
> - Keine ℤ₂-/Coxeter-Flip-Holonomie auf Fokus; kein Lie/Kac–Moody.
> - §5.21: exakte archimedische Bilanz ≠ bewiesene Aperiodizitätssperre; keine Brücke Liftabsorption → alle ℕ-Bahnen.
> - §5.22: refined \(\Phi_k\) auf endlichem \(k\)-Fenster \(\neq\) \(\forall k\) Graphsatz; naive stated-\(\Phi\) nicht als Theorem.

### 5.17 Boolesche Lift-Monodromie auf affinen A-Constraint-Kreisen `[B]`

Fortsetzung von §5.16. Skript: `src/kepler_hurwitz/eabc_lift_coherence.py` (`run_monodromy_audit`) · Export: [`eabc_lift_monodromy_report.json`](exports/eabc_lift_monodromy_report.json).

**Freeze-Befund (Daten):** Auf allen vier Fokus-Zyklen ist \(P\neq S\). Klasse: **nichtinvertierbare boolesche Relationsmonodromie** — **keine** ℤ₂-Holonomie, keine Coxeter-\(I/S\)-Lesart, kein Möbius-Flip. Der **geschlossene mathematische Kern** steht in **§5.18** (Absorption/Collapse); §5.17 hält Tabelle und OR-AND-Norm.

#### Komposition = OR-AND (Lean `boolMatMul`), nicht GF(2)

\[
(A\odot B)[i,j]=\bigvee_r\bigl(A[i,r]\land B[r,j]\bigr).
\]
Gegenbeispiel zwei Pfade: \(U\odot U=U\), aber \(U\cdot_{\mathrm{GF}(2)}U=0\). JSON-Feld `gf2_product` nur Diff/Warnung.

#### Inzidenzgraph vs. Operativ

Constraint-Kreis ≅ \(\tilde A_{\ell-1}\) **nur als Inzidenzgraph**. Operative Struktur = Monoid der \(2\times2\)-Boolrelationen unter \(\odot\). Kein Lie-/Kac–Moody-Claim.

#### Monodromie und \(\delta_{\mathrm{coh}}\)

\[
P_C=M_0\odot\cdots\odot M_{\ell-1},\qquad
\text{CycleLiftable}\iff\mathrm{Bool\text{-}tr}(P_C)=1.
\]
- \(P=Z\): kein Anfangszustand \(\varepsilon\) hat vollständigen zyklischen Transport.
- \(P=E_{01}\): nur Transport \(0\mapsto1\); Diagonale leer \(\Rightarrow\mathrm{Bool\text{-}tr}=0\).
- \(\delta_{\mathrm{coh}}=1\) bei BoolTrace\((P)=0\): lokaler Engpass (\(E_{01}\odot E_{00}=Z\)) plus globaler Einheitsdefekt; CSP-Minimum bleibt 1.

#### Fokus-Tabelle (OR-AND, kanonische Rotation)

| \(k\) | \(\ell\) | \(P\) | Typ | \(=S\)? | Holonomie | \(z_2\) | nichtinvertierbar | \(\delta_{\mathrm{coh}}\) |
|---:|---:|---|---|:---:|:---:|:---:|:---:|---:|
| 10 | 26 | \(\begin{pmatrix}0&0\\0&0\end{pmatrix}\) | \(Z\) | nein | relational | null | ja | 1 |
| 11 | 25 | \(Z\) | \(Z\) | nein | relational | null | ja | 1 |
| 12 | 7 | \(Z\) | \(Z\) | nein | relational | null | ja | 1 |
| 12 | 6 | \(\begin{pmatrix}0&1\\0&0\end{pmatrix}\) | \(E_{01}\) | nein | relational | null | ja | 1 |

\(P\in\{Z,E_{01}\}\) unter OR-AND **bestätigt** (kein GF(2)-Artefakt: Singleton-Matrizen haben ≤1 Pfad/Eintrag).

#### Claim-Wall

```
[A] Lean boolMatMul = OR-AND-Referenz
[B] Freeze: P≠S; nichtinvertierbare Relationsmonodromie
[C] kein Lie/Kac–Moody/Collatz; keine ℤ₂-Flip-Holonomie; kein ∀k
```

### 5.18 Boolescher Absorptionsmechanismus `[B]` — **frozen core**

Geschlossener mathematischer Kern der Lift-CSP-Lesart (ersetzt die verworfene Coxeter/Flip-Holonomie). Export/Tests: [`eabc_lift_monodromy_report.json`](exports/eabc_lift_monodromy_report.json) · `e00_e01_word_analysis`.

> **Binding-Box — §5.18 Kern (frozen)**
>
> 1. \(P\neq S\) unter **echtem OR–AND** (Lean `boolMatMul`) — **kein** GF(2)-Artefakt, **keine** invertierbare ℤ₂-Holonomie.
> 2. Vier Fokus-Zyklen: \(P\in\{Z,E_{01}\}\) — drei \(Z\), einer \(E_{01}\) (\(k=12\), \(\ell=6\)).
> 3. Algebraische Klasse: **nichtinvertierbare Relationsmonodromie** (Totalkollaps \(Z\) / einseitige Partialrelation \(E_{01}\)).
> 4. Muster \((\ell-1)\times E_{00}+1\times E_{01}\) \(\Rightarrow\) \(\delta_{\mathrm{coh}}=1\) (und \(\mathrm{Bool\text{-}tr}(P)=0\)).
> 5. §5.18 **ersetzt** die verworfene Coxeter/Flip-Lesart durch boolesche Absorptions-/Collapse-Theorie im Relationsmonoid.
>
> Claim-Wand: finite modular only; \(\tilde A_{\ell-1}\) nur Inzidenzgraph; kein Lie/Kac–Moody/Collatz; kein \(k\)-Bump; Universal Surgery Non-Claim.

#### Lokales Muster (Fokus)

Alle vier Zyklen:
\[
\#E_{00}=\ell-1,\qquad \#E_{01}=1
\]
(keine \(I\), keine \(S\), keine \(U\)).

#### Einheitsdefekt-Wörter (reine Kombinatorik)

Unter OR-AND:
\[
E_{00}\odot E_{00}=E_{00},\quad
E_{00}\odot E_{01}=E_{01},\quad
E_{01}\odot E_{00}=Z.
\]
- \(P=E_{01}\) iff \(E_{01}\) letzter Faktor; sonst \(P=Z\).
- Stets \(\mathrm{Bool\text{-}tr}(P)=0\) und \(\delta_{\mathrm{coh}}=1\).
- Kreisrotation wählt nur die Matrixform \(Z\) vs. \(E_{01}\); Nicht-Liftbarkeit identisch.

**Allgemeiner Einheitsdefekt (Monoid):** Jeder zyklische 2-Zustands-CSP mit genau einer \(E_{01}\)-Kante und sonst \(E_{00}\) hat Kohärenzdefekt 1 — Absorption/Collapse, kein Flip.

> **Non-Claim `[C]`:** Fokus + Monoid-Kombinatorik; kein \(\forall k\) über \(F_k\); kein Collatz; \(\tilde A\) ≠ Wurzelsystem.

### 5.19 Boolesches Absorptionsmonoid `[B]` / Lean `[A]` — **frozen**

Fortsetzung von §5.18 (frozen core). Skript: `src/kepler_hurwitz/eabc_boolean_absorption.py` · Export: [`eabc_boolean_absorption_monoid_report.json`](exports/eabc_boolean_absorption_monoid_report.json) · Lean: `KeplerHurwitz/EABC/BooleanRelationAbsorption.lean`.

> **Ergebnissystem (Freeze §5.19 / §5.20)**
> ```
> [§5.19] Boolesche Absorptionshalbgruppe / Monoidisierung
>     ├── Alphabet: {E00,E01,Z}; Monoidisierung mit I
>     ├── Produkttafel; Z absorbing
>     └── a_abs=2
> [§5.20] Obstruktionskern & Einheitsdefekt
>     ├── κ_loc=2 (E01⊙E00=Z + Nonemptiness-Minimalität)
>     ├── BoolTrace Rotationsinvarianz
>     └── δ_coh=1
> ```

> **Terminologie-Box (verbindlich)**
>
> | Symbol | Menge | Name |
> |---|---|---|
> | \(M_{\mathrm{abs}}\) | \(\{E_{00},E_{01},Z\}\) | **Absorptionshalbgruppe** (kein \(I\)) |
> | \(M_{\mathrm{abs}}^{1}\) | \(\{I,E_{00},E_{01},Z\}\) | **Absorptionsmonoid** (Monoidisierung) |
>
> Titel „Absorptionsmonoid“ = \(M_{\mathrm{abs}}^{1}\). Operative Absorption lebt in \(M_{\mathrm{abs}}\). Lean: `identityRel`, `identity_mul`, `mul_identity`.

#### Alphabet und Produkttafel

\(\Sigma_{\mathrm{lift}}=\{E_{00},E_{01}\}\). OR-AND (Lean `BoolMat2.mul` / `boolMatMul`):
\[
E_{00}\odot E_{00}=E_{00},\;
E_{00}\odot E_{01}=E_{01},\;
E_{01}\odot E_{00}=Z,\;
E_{01}\odot E_{01}=Z.
\]
Nullprodukt \(E_{01}\odot E_{00}=Z\) = **kein kompatibler Zwischenzustand** (`E01_then_E00_unsatisfiable`).

**Wortlemma:** \(E_{00}^{a}\odot E_{01}\odot E_{00}^{b}=E_{01}\) falls \(b=0\), sonst \(Z\).

#### Basispunkt vs. Spur

\(P_j\in\{E_{01},Z\}\) basispunktabhängig; \(\mathrm{Bool\text{-}tr}(P_j)=0\) stets. Spur-Kommutativität \(\mathrm{Bool\text{-}tr}(A\odot B)=\mathrm{Bool\text{-}tr}(B\odot A)\) \(\Rightarrow\) Rotationsinvarianz.

Claim-Wand: finite modular / boolean relations only; kein Flip/Coxeter/Lie/Collatz; **kein** \(\kappa=\ell\).

### 5.20 Minimaler Kohärenzdefekt `[B]` / Lean `[A]` — **frozen**

**Verworfen:** „\(\kappa=\ell\)“, „jedes echte Teilpfadsystem erfüllbar“, „obstruction locally invisible until full length“.

> **Gesamtresultat-Box (Freeze)**
>
> Für zyklische Wörter mit genau einer \(E_{01}\) und sonst \(E_{00}\) (\(\ell\ge2\), Fokus und kombinatorisches Muster):
>
> | Größe | Wert |
> |---|---|
> | \(\kappa_{\mathrm{loc}}\) | \(2\) |
> | \(a_{\mathrm{abs}}\) | \(2\) |
> | \(\mathrm{Bool\text{-}tr}(P_j)\) | \(0\) |
> | \(P_j\) | \(\in\{E_{01},Z\}\) |
> | \(\delta_{\mathrm{coh}}\) | \(1\) |
>
> **Terminologie:** *lokale zweistufige Absorption mit globalem Einheitsdefekt*.
>
> Minimalität: \(E_{00},E_{01}\) nonempty \(\Rightarrow\) \(\kappa_{\mathrm{loc}},a_{\mathrm{abs}}\ge2\); \(E_{01}\odot E_{00}=Z\) \(\Rightarrow\) \(\le2\).

Lean `[A]` (allgemeines \(\ell\ge2\), Muster „eine \(E_{01}\), Rest \(E_{00}\)“): `one_E01_rest_E00_not_satisfiable` (Allows/CSP auf `Fin ℓ`); `delta_coh_one_E01_rest_E00` (all-false Zeuge ⇒ Defekt \(=1\)); `unitDefect_product` / `unitDefect_all_rotations_trace_mem` (\(\mathrm{Bool\text{-}tr}(P_j)=0\), \(P_j\in\{E_{01},Z\}\)); `word_E00_E01_E00`; `boolTrace_listProduct_rotate_iterate` (Rotationsinvarianz via `trace_mul_comm`+Assoziativität); `kappa_loc_eq_a_abs_two` / `a_abs_le_two_unitDefect`. Spezialfall ℓ=2 bleibt als `delta_coh_one_E01_E00_len2`.

**\(F_k\)-Kopplung:** Die vier frozen Fokus-Zyklen \((k,\ell)\in\{(10,26),(11,25),(12,7),(12,6)\}\) sind keine parallele informelle Spur, sondern **[B]-Zeugen** der Hypothese `MatchesUnitDefectPattern` (Typ-Histogramm \((\ell-1)\times E_{00}+1\times E_{01}\)). Lean-Brücke `KeplerHurwitz/EABC/FocusCycleUnitDefect.lean` spezialisiert das allgemeine ℓ-Gesetz auf genau diese Längen (`focus_ell{6,7,25,26}_unitDefect`, `conclusions_of_matchesUnitDefect`) — **[A]** unter der Muster-Hypothese, **kein** modularer \(F_k\)-Arithmetik-Beweis in Lean, **kein** \(\forall k\), **kein** Collatz.

Python `[B]` erzeugt weiterhin Fokus-Zykeln, numerische δ_coh-Exports und Alphabet-Scans; Export-Felder (`ell`, `j_E01`, `delta_coh`, `MatchesUnitDefectPattern`, `BoolTrace_class`, Rotation) sind an Lean-Hypothesennamen angeglichen.

### 5.21 Archimedische Bilanz und Grenze der Aperiodizitätskontrolle `[C]` — **frozen**

Die vorangegangenen modularen und booleschen Untersuchungen beschreiben endliche Quotientengraphen, projektive Liftrelationen und lokale Absorptionsmechanismen. Der Übergang von diesen endlichen Strukturen zur unbeschränkten Syracuse-Dynamik auf den positiven ganzen Zahlen erfordert jedoch eine zusätzliche archimedische Kontrolle.

Für eine ungerade positive Zahl \(n_i\) sei
\[
n_{i+1}
=
\frac{3n_i+1}{2^{v_i}},
\qquad
v_i=\nu_2(3n_i+1).
\]
Dann gilt die exakte logarithmische Bilanz
\[
\log_2 n_{i+1}
=
\log_2 n_i
+
\log_2 3
-
v_i
+
\log_2\Bigl(1+\frac{1}{3n_i}\Bigr).
\]
Nach \(m\) beschleunigten Syracuse-Schritten folgt
\[
\log_2 n_m
=
\log_2 n_0
+
m\log_2 3
-
\sum_{i=0}^{m-1}v_i
+
\sum_{i=0}^{m-1}
\log_2\Bigl(1+\frac{1}{3n_i}\Bigr).
\]
Mit
\[
V_m=\sum_{i=0}^{m-1}v_i
\qquad\text{und}\qquad
R_m=
\sum_{i=0}^{m-1}
\log_2\Bigl(1+\frac{1}{3n_i}\Bigr)
\]
lautet diese Identität kompakt:
\[
\log_2 n_m
=
\log_2 n_0
+
m\log_2 3
-
V_m
+
R_m.
\]

Eine gegen unendlich divergierende Bahn (\(n_m\to\infty\)) müsste daher
\[
m\log_2 3-V_m+R_m\to+\infty
\]
erfüllen. Für eine lediglich unbeschränkte Bahn genügt eine Teilfolge \(m_j\to\infty\), für die
\[
m_j\log_2 3-V_{m_j}+R_{m_j}\to+\infty
\]
gilt. Eine punktweise Ungleichung
\[
V_m<m\log_2 3
\qquad\text{für jedes }m
\]
ist hierfür weder notwendig noch im gegenwärtigen Modell bewiesen: Zwischenrückfälle sind zulässig; Unbeschränktheit ist schwächer als Divergenz. Zusätzlich ist der Fall „beschränkt, aber nicht bei \(1\)“ von periodischer Richtung zu trennen (Surgery/Lift betreffen primär diese).

Die endliche archimedische Anfangshöhe
\[
H_{\mathrm{Arch}}(n_0)=\log_2 n_0
\]
stellt allein **keine** Sperre gegen eine wachsende Bitlänge dar. Die Operation \(3n+1\) kann aus einem endlichen Anfangswert deterministisch beliebig hohe Bitpositionen erzeugen. Das offene Problem besteht deshalb nicht in der Bereitstellung neuer Bitinformation, sondern in der globalen Bilanz zwischen dem multiplikativen Zuwachs \(m\log_2 3\) und der kumulierten Zweierbewertung \(V_m\).

Die in §5.19 und §5.20 formalisierte Relation
\[
E_{01}\odot E_{00}=Z
\]
beschreibt einen lokalen zweistufigen Absorptionskern in den untersuchten endlichen projektiven Lift-Constraint-Systemen. Zusammen mit
\[
\kappa_{\mathrm{loc}}=a_{\mathrm{abs}}=2,
\qquad
\operatorname{BoolTrace}(P_j)=0,
\qquad
\delta_{\mathrm{coh}}=1
\]
erklärt sie die Nichtliftbarkeit der analysierten modularen Zyklen.

Aus diesen endlichen Resultaten folgt gegenwärtig jedoch **kein** allgemeiner Satz über unbeschränkte aperiodische Bahnen in \(\mathbb N\). Insbesondere fehlen die beiden Brückenimplikationen
\[
\text{unbeschränkte ganzzahlige Bahn}
\Longrightarrow
\text{wiederkehrendes absorbierendes Liftmuster}
\]
und
\[
\text{absorbierendes Liftmuster}
\Longrightarrow
\text{archimedischer Abstieg}.
\]
Beide sind offen. Die Bezeichnung „archimedische Aperiodizitäts-Sperre“ wird daher in diesem Abschnitt **nicht** als bewiesene Sperre verwendet, sondern als **Name des noch offenen Brückenproblems** zwischen modularer Liftabsorption und archimedischer Wachstumsbilanz.

> **Epistemischer Status `[C]` — Open-Non-Claim-Grenze**
>
> Der Abschnitt gehört zur Ebene `[C]` und bildet eine ausdrückliche Open-Non-Claim-Grenze.
>
> **Bewiesen beziehungsweise exakt hergeleitet:**
> - Bilanzidentität \(\log_2 n_m=\log_2 n_0+m\log_2 3-V_m+R_m\)
> - endliche Absorptionsresultate aus §5.19 und §5.20
>
> **Nicht bewiesen:**
> - \(\forall n>1\;\exists r\ge1:\ T^r(n)<n\)
> - universelle asymptotische Untergrenze für den Mittelwert \(\frac1m\sum_{i<m}v_i\)
> - Ausschluss unbeschränkter aperiodischer Bahnen
> - Übertragung von Baire- oder 2-adischen Aussagen auf sämtliche eingebetteten natürlichen Startwerte
>
> Das verbleibende zentrale Hindernis ist die ausnahmslose Kontrolle der Bewertungssummen \(V_m\) entlang jeder natürlichen Syracuse-Bahn. Erst ein wohlfundierter archimedischer Abstiegssatz oder eine äquivalente Beschränktheitsaussage würde die Lücke zum vollständigen Collatz-Beweis schließen — **kein Collatz-Beweis hier**.

#### Drift-Variable \(D_m\) (Definition, Open Non-Claim)

Zur Vorbereitung einer späteren Aperiodizitätskontrolle setzen wir
\[
D_m = V_m - m\log_2 3 - R_m
\]
mit der exakten Identität \(\log_2 n_m = \log_2 n_0 - D_m\), also \(n_m < n_0 \Leftrightarrow D_m > 0\).
**Status `[C]`:** Definition und Bilanz sind exakt; die Kopplung „fehlende Absorption \(\Rightarrow\) Drift \(>0\)“ bleibt offen — **kein** Abstiegssatz, **kein** Collatz.

### 5.22 Arithmetischer Relations-Klassifikator \(\Phi_k\) `[B]` / Lean `[A]` (Labels)

Skript: `src/kepler_hurwitz/eabc_relation_classifier_phi_k.py` · Export: [`relation_classifier_phi_k_focus_cycles_k10_14.json`](exports/relation_classifier_phi_k_focus_cycles_k10_14.json) · Lean: `KeplerHurwitz/EABC/SyracuseRelationClassifierPhi.lean` · Energiedoku: [`energiedoku_exports/eabc_relation_classifier_phi_k_2026_07_21.md`](energiedoku_exports/eabc_relation_classifier_phi_k_2026_07_21.md).

> **Satz 5.22 (Arbeitsfassung — ehrlich auditiert)**
>
> Sei \(u\) ungerade modulo \(2^k\) und \(v=\nu_2(3u+1)\). Die Lift-Matrix der Kante \(u\to F_k(u)\) entsteht aus den beiden Lifts \(\tilde u_0=u\), \(\tilde u_1=u+2^k\).
>
> **Research-Skizze (stated, valuation-only):**
> \[
> \Phi_k^{\mathrm{stated}}(u)=\begin{cases}
> E_{01} & \text{falls }v=1,\\
> E_{00} & \text{falls }2\le v<k,\\
> Z & \text{falls }v\ge k.
> \end{cases}
> \]
> **Audit `[B]` \(k\in[4,14]\):** Auf wrap-/loss-freien Kanten von \(G_k^{\mathrm{cut}}\) gilt stets die Lift-Matrix \(E_{00}\) — auch bei \(v=1\). Die Skizze \(\Phi_k^{\mathrm{stated}}\) ist daher **falsch** für Cut-Kanten mit \(v=1\).
>
> **Refined Klassifikator (trifft alle \(F_k\)-Kanten im Audit):**
> \[
> \Phi_k^{\mathrm{ref}}(u)=\begin{cases}
> E_{01} & \text{falls wrap und }v=1,\\
> E_{00} & \text{falls nicht-wrap und }1\le v<k,\\
> Z & \text{falls }v\ge k.
> \end{cases}
> \]
> Insbesondere: \(G_k^{\mathrm{cut}}\) enthält im Fenster **keine** \(E_{01}\)-Kante; \(E_{01}\) entsteht genau an Wrap-Kanten mit \(v=1\).

#### Bewertungs-Kopplungs-Lemma (Skizze)

Für \(v=\nu_2(3u+1)<k\) gilt \(v_1=\nu_2(3(u+2^k)+1)=v\) und
\[
T(u+2^k)=T(u)+3\cdot 2^{k-v}.
\]
Der Shift \(3\cdot 2^{k-v}\) ist modulo \(2^{k+1}\) weder \(0\) noch \(2^k\) (\(1\le v<k\)). Deshalb trifft der Eins-Lift bei wrap-freien Kanten **keinen** Lift des modularen Ziels — die Relation enthält nur \((0,0)\), also \(E_{00}\). Bei Wrap mit \(v=1\) trifft der Null-Lift mit Bit \(1\), also \(E_{01}\). Vollständige padic-Formalisierung der Miss-Lemmata: follow-up; Python `[B]` + konkrete Lean-Smokes (`lift_T_add_example_*`).

#### Korollar (Fokus-Wörter → Absorption)

Die frozen Fokus-Zyklen \((k,\ell)\in\{(10,26),(11,25),(12,7),(12,6)\}\) liegen in \(F_k\) (je genau eine Wrap-Kante), **nicht** in \(G_k^{\mathrm{cut}}\). Audit: Wort \(\sim_{\mathrm{cyc}} E_{00}^{\ell-1}\odot E_{01}\), BoolTrace\(=0\), `MatchesUnitDefectPattern`. Unter dieser Hypothese greifen Lean `[A]` `BooleanRelationAbsorption` / `FocusCycleUnitDefect` — **kein** neuer Absorptionsbeweis, **kein** Collatz, **kein** \(\forall k\) über ℕ.

Für \(k\in[10,14]\) ist \(G_k^{\mathrm{cut}}\) azyklisch (0 Cut-Zykeln); das Korollar „Cut-Zyklus mit genau einem \(v=1\) \(\Rightarrow\) Einheitsdefektwort“ ist im Fenster **leer anwendbar**.

> **Epistemik §5.22**
>
> | Ebene | Inhalt |
> |---|---|
> | `[A]` | Labels \(\Phi_k\); E00/E01-Packaging; Absorption-Reuse; konkrete \(\nu_2\)/T-Smokes |
> | `[B]` | refined match auf \(F_k\); Fokus-Wörter; stated≠cut; Cut azyklisch \(k\in[10,14]\) |
> | `[C]` | \(\forall k\); Cut-Absorptionssatz (§5.23); Collatz |

### 5.23 Stub — Stabile-Zyklus-Klassifikation `[C]` / next

Ziel: jeder wrap-/loss-freie Zyklus in \(G_k^{\mathrm{cut}}\) erzeugt ein absorbierendes Relationswort; Verbindung zu \(\rho(A_k^{\mathrm{cut}})=0\). Im aktuellen Fenster gibt es keine Cut-Zykeln — der universelle Satz bleibt offen.

#### Bereinigtes Register (§5.14–§5.23)

| § | Gegenstand | Ebene | Belastbarer Status |
|---|---|---|---|
| 5.14 | Modulare Wrap-Surgery | `[B]` | Endliche Prüfung im angegebenen \(k\)-Bereich |
| 5.15 | Projektive Lift-Diagnostik | `[B]` | Keine Lift-Türme unter den untersuchten Zyklen |
| 5.19 | Absorptionshalbgruppe | `[A]` | Lean-Kern für die lokalen Relationen |
| 5.20 | Absorptionskern und Defekt | `[A]`/`[B]` | \(\kappa_{\mathrm{loc}}=a_{\mathrm{abs}}=2\), \(\delta_{\mathrm{coh}}=1\) im spezifizierten Muster; Lean allgemein \(\ell\) `[A]`; \(F_k\)-Fokus = `[B]`-Zeugen + Lean-Spezialisierung `FocusCycleUnitDefect` |
| 5.21 | Archimedische Bilanz / Drift \(D_m\) | `[C]` | Exakte Bilanz + Drift-Definition; globale Abstiegsimplikation offen (Open Non-Claim Boundary) |
| 5.22 | Arithmetischer Relations-Klassifikator \(\Phi_k\) | `[A]`/`[B]` | Labels `[A]`; refined Audit `[B]`; naive stated **nicht** verifiziert |
| 5.23 | Stabile Cut-Zyklus-Klassifikation | stub | nächster Block; \(\forall k\) offen |

Die Formulierung „vollständig strukturiert“ ist damit gerechtfertigt. **Nicht** gerechtfertigt wäre „mathematisch unumstößliche Aperiodizitätssperre“: unumstößlich sind die Bilanzidentität und die endlichen Absorptionssätze; die eigentliche Sperrwirkung auf alle natürlichen Bahnen bleibt genau das offene Kernproblem.

---

## 6. Artefakte

| Schicht | Pfad |
|---|---|
| Diese Governance | `docs/eabc_collatz_audit_grid.md` |
| Lean Audit-Grid | `KeplerHurwitz/EABC/CollatzAuditGrid.lean` |
| Lean Norm unter H | `KeplerHurwitz/EABC/CollatzSyracuseNorm.lean` |
| Lean Doppelschritt / Makro | `KeplerHurwitz/EABC/CollatzTwoStep.lean` |
| Lean Dreischritt-Kompensation | `KeplerHurwitz/EABC/CollatzThreeStep.lean` |
| Lean Zykel-Notwendigkeit (Option A) | `KeplerHurwitz/EABC/CollatzCycleNecessary.lean` |
| Lean Modular-ν₂ / CRT-Filter / Erstschritt→Makro | `KeplerHurwitz/EABC/CollatzModularV2.lean` |
| Lean Ascent-Digraph / Zykel-Obstruktion | `KeplerHurwitz/EABC/CollatzDigraph.lean` |
| Python Ansatz-4 Spektralradius \(A_k\) `[B]` | `docs/exports/eabc_automaton_spectral_ak_report.json` · §5.13 |
| Python Ansatz-4 Wrap-/Chirurgie `[B]` | `src/kepler_hurwitz/eabc_modular_wrap_surgery.py` · `docs/exports/eabc_modular_wrap_surgery_report.json` · §5.14 |
| Python Ansatz-4 projektive Liftbarkeit `[B]` | `src/kepler_hurwitz/eabc_cycle_liftability.py` · `docs/exports/eabc_cycle_liftability_report.json` · §5.15 |
| Python Boolesche Lift-Kohärenz `[B]` | `src/kepler_hurwitz/eabc_lift_coherence.py` · `docs/exports/eabc_c26_lift_obstruction_certificate.json` · §5.16 |
| Python Boolesche Lift-Monodromie `[B]` | `eabc_lift_coherence.py` (`run_monodromy_audit`, OR-AND) · `docs/exports/eabc_lift_monodromy_report.json` · §5.17 |
| Python Boolescher Absorptionsmechanismus `[B]` | `e00_e01_word_analysis` / `absorption_mechanism_report` · §5.18 |
| Python Boolesches Absorptionsmonoid `[B]` | `src/kepler_hurwitz/eabc_boolean_absorption.py` · `docs/exports/eabc_boolean_absorption_monoid_report.json` · §5.19–§5.20 |
| Lean abstrakte Lift-Logik `[A]` | `KeplerHurwitz/EABC/ModularSyracuseLift.lean` · §5.16–§5.17 |
| Lean Boolesche Absorption `[A]` | `KeplerHurwitz/EABC/BooleanRelationAbsorption.lean` · §5.19–§5.20 |
| Lean \(F_k\)-Fokus-Spezialisierung `[A]`←`[B]` | `KeplerHurwitz/EABC/FocusCycleUnitDefect.lean` · §5.20 |
| Docs Archimedische Bilanz / Drift `[C]` Open-Non-Claim | §5.21 (keine Lean-Descent-Aussage; Bilanz + \(D_m\) als Definition) |
| Python \(\Phi_k\)-Klassifikator-Audit `[B]` | `src/kepler_hurwitz/eabc_relation_classifier_phi_k.py` · `docs/exports/relation_classifier_phi_k_focus_cycles_k10_14.json` · §5.22 |
| Lean \(\Phi_k\) Labels / Packaging `[A]` | `KeplerHurwitz/EABC/SyracuseRelationClassifierPhi.lean` · §5.22 |
| Energiedoku §5.22 | `docs/energiedoku_exports/eabc_relation_classifier_phi_k_2026_07_21.md` |
| Tests \(\Phi_k\) | `tests/test_eabc_relation_classifier_phi_k.py` |
| Python Zylinder Nicht-Kompensierer (Option B) | `src/kepler_hurwitz/eabc_cylinder_noncompensator_scan.py` |
| Python \(V_4\) × Zylinder (Richtung B) | `src/kepler_hurwitz/eabc_cylinder_v4_correlation.py` |
| Python \(T_{\mathrm{acc}}\)-Mischung mod \(2^m\) | `src/kepler_hurwitz/eabc_cylinder_mixing.py` |
| Python Escape-Zeit Gefängnis \(\{7,15\}\) | `src/kepler_hurwitz/eabc_prison_escape.py` |
| Python Audit | `src/kepler_hurwitz/eabc_collatz_audit.py` (`audit_trajectory`) |
| Python Pipeline | `src/kepler_hurwitz/eabc_pipeline.py` |
| Tests | `tests/test_eabc_collatz_audit.py`, `tests/test_eabc_pipeline.py` |
| Normalform §7 | [`eabc_normal_form.md`](eabc_normal_form.md) |
| Collatz-Evidence-Kette (orthogonal) | `docs/collatz_v2_evidence_chain.md` |
