# Theory — Master Index

Theorie-Dokumente und didaktische Modellbrücken des Kepler-Hurrwitz-Programms.

---

### Fixed-Locus / Riemann-Programm (L4)

**Datei:** [`fixed_locus_riemann_program.md`](fixed_locus_riemann_program.md)  
**Status:** `[L4 / programmatisch]` — ORQ-087  
**Register-Abgrenzung:** E-034 (`[C]` refuted), E-035 (`[C]` open_hypothesis)  
**Claim-Grenze:** Symmetrie \(D(Z)=Z\) bekannt; Konfinierung \(\mathrm{Fix}(D\mid_Z)=Z\) offen — kein RH-Loss-Claim.

---

### Ideale, Dedekind-Hasse und quaternionische Primzahlpfade

**Datei:** `docs/theory/ideal_dedekind_hasse_intro_abitur.md`  
**Status:** `[C]` didaktische Modellbrücke  
**Evidenz:** E-064  
**Zweck:** Verständliche Einführung in Ideale, Einheiten, nichtkommutative Quaternionenordnungen und Dedekind-Hasse als Test für arithmetische Stabilität.  
**Claim-Grenze:** Der Text erklärt die Motivation und Struktur der DH-QPID-Testreihe, beweist aber keine EABC-Struktur.

**Verwandte technische Schichten:**

| ID | Datei | Rolle |
|---|---|---|
| E-061, E-062 | `src/kepler_hurwitz/dhqpid_prototype.py` | Numerischer DH-Prototyp |
| E-063 | (offen) | Restklassen-DH-Profil mod 12 |
| E-067–E-069 | `KeplerHurwitz/DedekindIdealLayer.lean` | Lean-Ideal-Schicht |
| E-053 | `KeplerHurwitz/DedekindHasseDumasInterface.lean` | Dedekind–Hasse ↔ Dumas |

---

### Oppenheim–eabc: Stochastische Raumzeit als Stabilitätstest

**Datei:** `docs/theory/oppenheim_eabc_stability_bridge.md`  
**Status:** `[D]` konzeptionelle Brücke / externe Analogie  
**Evidenz:** E-070  
**Zweck:** Methodische Parallele zwischen Oppenheim post-quantum classical gravity (stochastische Metrik) und eabc-/quaternionischen Stabilitätstests — Perturbationsklassen für Invarianten, keine Physikbehauptung.  
**Claim-Grenze:** Keine Kausalbehauptung zwischen Raumzeit-Diffusion und Primidealstruktur.

**Verwandte Schichten:**

| ID | Datei | Rolle |
|---|---|---|
| E-053 | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` | EABC-Renormierungskern |
| E-064 | `docs/theory/ideal_dedekind_hasse_intro_abitur.md` | DH-QPID-Stabilitätstest |
| E-067 | `docs/dedekind_ideal_layer.md` | Lean-Idealinterface |

---

### Higgs-Blasen–eabc: Topologische Defektkollision als Renormierungstest

**Datei:** `docs/theory/higgs_bubble_eabc_analogy.md`  
**Status:** `[D]` konzeptionelle Brücke / externe Analogie  
**Evidenz:** E-071  
**Zweck:** Methodische Parallele zwischen DESY/Hamburg Higgs-Blasenkollisions-Baryogenese ($T=0$, nichtthermische Sphaleronen) und eabc-Renormierungs-/Invariantentests — Defektkollision, topologischer Sektorwechsel, globaler Bias, keine Physikbehauptung.  
**Claim-Grenze:** Keine Kausalbehauptung zwischen Higgs-Blasendynamik und quaternionischer Primstruktur oder eabc.

**Verwandte Schichten:**

| ID | Datei | Rolle |
|---|---|---|
| E-053 | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` | EABC-Renormierungskern |
| E-070 | `docs/theory/oppenheim_eabc_stability_bridge.md` | Geschwister-[D]-Brücke (stochastische Perturbation) |
| E-064 | `docs/theory/ideal_dedekind_hasse_intro_abitur.md` | DH-QPID-Stabilitätstest |
