# Theory — Master Index

Theorie-Dokumente, didaktische Modellbrücken und externe Phase-C-Brücken des Kepler-Hurrwitz-Programms.

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

---

### Arithmetisches Vakuum–eabc: Externe arithmetische Feinstruktur-Analogie

**Datei:** `docs/theory/arithmetic_vacuum_eabc_analogy.md`  
**Status:** `[C]` externe arithmetische Feinstruktur-Analogie  
**Evidenz:** E-073 (motivisch; keine Lean-Formalisation)  
**Zweck:** Einordnung des Hassall-Papers (*Arithmetic Vacuum*) und Energiedoku-Skripte ($\alpha \approx 1/(4\pi\zeta(3)\cdot 3^2)$, Prim-Log-Gitter, Zeta-Jitter, Dirac-artige Ladungsquantisierung) als **externer Resonanzanker** — ohne Formal-Core-Beleg für EABC, Lean oder Dedekind–Hasse.  
**Claim-Grenze:** EABC besitzt Anschlussmotive zu arithmetischen Feinstruktur-Modellen — **nicht** „EABC erklärt $\alpha$“.

**Verwandte Schichten:**

| ID | Datei | Rolle |
|---|---|---|
| E-053 | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` | EABC-Renormierungskern |
| E-064 | `docs/theory/ideal_dedekind_hasse_intro_abitur.md` | DH-QPID-Stabilitätstest |
| E-067–E-069 | `docs/dedekind_ideal_layer.md` | Lean-Ideal-Schicht |
| E-073 | `docs/hott_identity_layer.md` | HoTT Identity Layer (motivisch) |
| E-075 | `docs/energiedoku_exports/e075_prime_grid_signaturgeometrie.md` | Prime Grid / Signaturgeometrie (`[B]`/`[C]`) |

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

---

### Prime Grid / Signaturgeometrie (E-075)

**Datei:** `docs/energiedoku_exports/e075_prime_grid_signaturgeometrie.md`  
**Status:** `[B]` Prime Grid-Normalform; `[C]` EABC-Brückeninterpretation  
**Evidenz:** E-075 · **Quellen:** [`kolossvary_the_prime_grid.pdf`](../mathematische_texte/kolossvary_the_prime_grid.pdf), [`givental_kepler_laws_conic_sections.pdf`](../mathematische_texte/givental_kepler_laws_conic_sections.pdf)  
**Claim-Grenze:** Externe Signaturgeometrie — **kein** Beweis von EABC, Dedekind–Hasse, HoTT oder Renormalisierung.

---

### Lift-Projektions-Prinzip (Quaternionen ↔ Kepler/Givental)

**Datei:** `docs/lift_projection_principle.md`  
**Status:** `[C]` methodische Brücke  
**Zweck:** Givental-Kegel-Lift und EABC-Normschale als **parallele** Projektionsschemata — gleiche Methode, nicht gleiche Objekte.  
**Claim-Grenze:** Kein Identitätsclaim; \(\Phi(v)=\gamma\) bleibt offen.

---

### Collatz V2.7 — Net-Descent-Bridge

**Datei:** `docs/collatz_v27_net_descent.md`  
**Status:** `[A]` Witness ⇒ Abstieg; `[C]` uniforme Witness-Existenz  
**Lean:** `KeplerHurwitz/CollatzProofAttemptV27.lean`  
**Kette:** `docs/collatz_v2_evidence_chain.md`
