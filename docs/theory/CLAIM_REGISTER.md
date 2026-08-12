# Claim-Register (Evidenzarchitektur)

**Schema:** projektweite Kennungen für Aussagen unter der [`EVIDENZARCHITEKTUR.md`](EVIDENZARCHITEKTUR.md).

> *Dieses Kapitel folgt der Evidenzarchitektur und dem Audit-Protokoll AP-1: formaler Kern `[A]`, reproduzierbare Audits `[B]`, Hypothesen `[C]`, Governance `[G]`.*

**AP-1:** [`AUDIT_PROTOCOL_AP1.md`](AUDIT_PROTOCOL_AP1.md)
---

## Präfixe

| Präfix | Bedeutung | Epistemische Ebene |
|---|---|---|
| **A-xxx** | formaler Satz / Lemma / Definitionssatz | `[A]` |
| **B-xxx** | Audit-Befund (vorregistriert, reproduzierbar) | `[B]` |
| **C-xxx** / **C-Hx** | Forschungs-Hypothese | `[C]` |
| **G-xxx** | Governance- oder Modellgrenze | Governance (nicht H1–H5) |

**Abgrenzung:** `E-xxx` im [`EVIDENCE_REGISTER.md`](../EVIDENCE_REGISTER.md) bleibt die **Evidenz-/Artefakt-ID**. Claim-IDs `A/B/C/G-xxx` bezeichnen **Aussagen**. Ein `E-`-Eintrag kann mehrere Claims stützen; ein Claim kann auf mehrere `E-`/`docs/exports`-Artefakte verweisen.

---

## Vergabe

1. Neue Claims nur mit freier Nummer im Register eintragen.  
2. In Texten immer die Claim-ID nennen (z. B. „laut **B-014**“).  
3. Status nur gemäß Evidenzarchitektur ändern (kein stillschweigendes Upgrade).  
4. Hypothesen-Paare dürfen sprechende Suffixe tragen (**C-H2A**, **C-H2B**).

---

## Modul: Nichtkanonische BA-Erweiterungen

**Theorie:** [`noncanonical_twin_color_extensions.md`](noncanonical_twin_color_extensions.md)  
**Claims-Report:** [`../exports/ba_hypothesis_claims_report.md`](../exports/ba_hypothesis_claims_report.md)

### A — formal

| ID | Aussage | Status | Alias (alt) |
|---|---|---|---|
| **A-001** | Klassifikation der Primzahlzwillinge \(p>3\): nur AB bzw. CE | bewiesen | — |
| **A-002** | Offset-Dualität BAC/BAE: Gaps \((4,6)\leftrightarrow(6,4)\) | bewiesen | C-A1 |
| **A-003** | Fenster \(W(b)\): beide Mid-Slots \(\Leftrightarrow\) \(T_4^{\mathrm{BACE}}=T_4^{\mathrm{BAEC}}=W(b)\) | bewiesen | — |
| **A-004** | \(W(b)\) ist kein kanonischer Vierling \(Q(p)\) (Gaps \((2,4,2)\)) | bewiesen | — |
| **A-005** | Minimalschranken / \(d=2\)-Charakterisierung der Restfarbe an \(T_3\) | bewiesen | — |

### B — Audits

| ID | Aussage | Status | Artefakt |
|---|---|---|---|
| **B-011** | Muster-Audit P1–P7 (BA→BACE/BAEC) bis \(5\cdot10^5\) | bestätigt `[B]` | `ba_bace_baec_pattern_audit*` |
| **B-012** | BAC-vs-BAE-Tripelvergleich: Audit-Dualität / fehlende Distanzdominanz bis \(5\cdot10^5\) | bestätigt `[B]` | `ba_bac_vs_bae_triple_compare*` |
| **B-013** | Skalenreplikation Audit-Dualität bis \(10^8\) (alle Skalenpunkte dual) | bestätigt `[B]` | `ba_hypothesis_scale_1e8.json`, `ba_bac_vs_bae_scale_1e7*` |
| **B-014** | BASE-Audit-Dualität C↔E unter vorregistrierten M1–M4 bis \(10^8\) (\(n=293\,399\); zuvor \(2\cdot10^6\) / \(10^7\)) | bestätigt `[B]` | `ba_hypothesis_scale_1e8.json`, `ba_hypothesis_control_study.json` |
| **B-015** | Bootstrap-\(CI_{95\%}\) für Diversitätsindex \(D\) (C-H7) bis \(10^7\) | bestätigt `[B]` · Trajektorien-Audit / AP-1 | `ba_C_H7_diversity_index_bootstrap.json` |
| **B-015b** | Diversitätstrajektorie \(D(N)\), Familientrajektorien \(D_F(N)\), Trajektorienkohärenz bis \(10^7\) | bestätigt `[B]` · Trajektorien-Audit / AP-1 (kein Asymptotik-Nachweis) | `ba_C_H7_diversity_trajectory.json` |
| **B-016** | Vierlings-Phasen-Audit: \(D_{\mathrm{quad}}(N)\), Phasen AB/CE, \(\Delta_{\mathrm{sym}}\) auf \(Q(p)\) bis \(10^7\); lokale Regel in `b016_quadruplet_greedy_sign` | bestätigt `[B]` · Trajektorien- & Kontroll-Audit / AP-1 · **Abgrenzungssignal:** OUT \(D_{\mathrm{quad}}\approx-0{,}10\) (kein Transfer von C-H7); IN \(=1\); leichte Phasen-Asymmetrie \(\Delta_{\mathrm{sym}}^{\mathrm{phase}}\approx0{,}033\) | `ba_B016_quadruplet_phase_audit*`, `b016_quadruplet_greedy_sign.py` |
| **B-017** | Semiprim-Träger \(T(n)=\{p,q\}\to\vec D(T)\); Kontroll \(K_{\mathrm{perm}}\) | bestätigt `[B]` · Struktur- & Kontroll-Audit / AP-1 · Dictionary unter **G-006**; speist **C-H9** | `ba_B017_semiprim_carrier_profile*`, `b017_semiprim_carrier_profile.py` |

**Audit-Klassen (AP-1):** Struktur (**B-011**–**B-014**, **B-017**) · Trajektorie (**B-015**/**B-015b**/**B-016**) · Kontrolle (**B-K*** / Mode-IN in **B-016** / \(K_{\mathrm{perm}}\) in **B-017**). Protokoll: [`AUDIT_PROTOCOL_AP1.md`](AUDIT_PROTOCOL_AP1.md).  
**Greedy-Distanz-API (modularer Kern):** `src/kepler_hurwitz/eabc_greedy_distance.py` — \(\mathrm{dist}(T,X)\), \(\mathrm{dist}(T,S)\), \(\vec D(T)\), \(d(T)=\mathrm{sign}(\mathrm{dist}_{\mathrm{erst}}-\mathrm{dist}_{\mathrm{self}})\); speist B-016/B-017; **G-007** (Algorithmus-Score, keine Primzahl-Invariante).

### C — Hypothesen

| ID | Aussage | Status |
|---|---|---|
| **C-H1** | Dichteskala: Ø\(d\) wächst mit \(\log N\); Slots/\(W\) sinken | Richtung gestützt (offen) |
| **C-H2A** | Parallelität spezifisch aus Offset-Dualität | unentschieden vs H2B |
| **C-H2B** | Parallelität generisch (Primzahldichte) | unentschieden vs H2A |
| **C-H2** | Meta: Konkurrenz H2A/H2B; Kontrollstudie gemischt ⇒ keine Entscheidung | Protokoll: Modell verfeinern |
| **C-H3** | Fehlende Distanzdominanz bleibt (decisive ≈ ½) | gestützt bis \(N\) |
| **C-H4** | \(W=o(1)\), mutual-third \(\to c_{\mathrm{mt}}\) | Richtung gestützt (offen) |
| **C-H5** | Flügelasymmetrie unter Greedy-Regel + betrachteten Kontrollen | gestützt bis \(N\) (geltungsbeschränkt) |
| **C-H7** | Algorithmushypothese: Diversitätsindex \(D=P_{\mathrm{erst}}-P_{\mathrm{self}}>0\); unabhängig von C-H2 | Richtung gestützt bis \(10^7\); \(D\approx0{,}094\), \(CI_{95\%}\approx[0{,}085,0{,}104]\) (**Makro**/BA-Hintergrund; offen) · **Transfer auf OUT-Vierlinge: eingeschränkt/widerlegt** (**B-016**, **G-007**) |
| **C-H7a** | Trajektorienstabilität von \(D(N)\) über das Suchfenster \(N\) | Richtung gestützt bis \(10^7\) (offen; **B-015b**) |
| **C-H7b** | Familien-Kohärenz der Trajektorien \(D_F(N)\) für \(F\in\{E,A,B,C\}\) | Richtung gestützt bis \(10^7\) (offen; **B-015b**) |
| **C-H8** | Greedy-Diversität auf Vierlings-Phasen (Modus OUT): \(D_{\mathrm{quad}}(N)>0\) | bis \(10^7\) **Richtung gegen** (\(D_{\mathrm{quad}}\approx-0{,}10\); leichte Selbstverdichtung; offen; **B-016**); Mode IN trivial \(=1\); \(\Delta_{\mathrm{sym}}^{\mathrm{phase}}\approx0{,}033\) (leichte Phasen-Asymmetrie) |
| **C-H9** | Semiprim-Umfeld-Kopplung: \(\vec D(T(n))\) unterscheidet `SemiprimKind`/Farbwort vs. \(K_{\mathrm{perm}}\) | offen / vorregistriert (**B-017**); **kein** Transfer auf Normalform-Invariante (**G-006**) |
| **C-H10** | Permutationsfeinstruktur: Dichte/\(D_\Pi\)/\(\Delta D_\Pi\) über realisierte \(\Pi(Q)\in S_4\) auf \(\Phi_{\mathrm{lattice}}\) | offen / vorregistriert (Audit **B-018** ausstehend). **Abgrenzung:** Lean-`[A]` \(\Pi(Q+30)=\tau(\Pi(Q))\) und endliches `[B]` \(\lvert R_{16}\rvert=14\) sind **nicht** C-H10; siehe `eabc_pi_30block_color_involution.md` |

### G — Governance / Modellgrenzen

| ID | Aussage | Status |
|---|---|---|
| **G-006** | Kein Transfer BA-Konstellations-Audits → `SemiprimKind` / E-096-Normalform ohne eigenen Audit | Governance (vormals H6 / C-C-H6) |
| **G-007** | Interpretationsregel für Aggregationen / Kontextabhängigkeit: Form/Streuung/Phase von \(D(N)\), \(D_F(N)\); **kein Transfer** Makro-\(D>0\) → starre Geometrie (**B-016**); Φ-Raster: \(K=16\) = neutrales Messgitter ≠ Isotropie; \(\Delta D\) = Diagnose ≠ Claim; siehe Merksätze unten | Governance |
| **G-008** | Neue `[B]`-Audits zu Greedy-/Farbfamilien folgen dem Audit-Protokoll Standard **AP-1** (sechs Phasen) | Meta-Governance / Methodik |
| **G-001** | Evidenzarchitektur verbindlich für Modultexte (Kurzformel am Kapitelanfang) | Meta-Governance |

### Merksätze — Phasen-Labor \(\Phi(Q)\) (Freeze, unter G-007)

1. \(\Phi(Q)\) nummeriert EABC-Kandidaten so, dass sowohl ihre echte Lage im Modulo-30-Sieb (\(\Phi_{\mathrm{lattice}}\)) als auch ihre lückenlose Beobachtungsreihenfolge (\(\phi_{\mathrm{global}}\)) analysiert werden können.
2. \(K=16\) beschreibt die symmetrische Kapazität des Messgitters, nicht die Symmetrie der gemessenen Arithmetik.
3. \(\Delta D=D_{\mathrm{lattice}}-D_{\mathrm{global}}\) zeigt, ob ein Signal von der realen Siebgeometrie oder von der lückenlosen Komprimierung abhängt (Diagnose, kein Claim).

**Tooling:** [`eabc_candidate_quad_index.md`](eabc_candidate_quad_index.md) · `src/kepler_hurwitz/eabc_candidate_quad_index.py` — Freeze geschlossen, auditbereit.

---

## Nächste freie Nummern (Hinweis)

| Serie | Nächste frei (Stand) |
|---|---|
| A | A-006 |
| B | B-018 (für C-H10 vorgesehen) |
| C-H | C-H6 nicht vergeben (Governance → G); **C-H7/a/b**, **C-H8**, **C-H9**, **C-H10** vergeben; nächste frei **C-H11** |
| G | G-009 |
