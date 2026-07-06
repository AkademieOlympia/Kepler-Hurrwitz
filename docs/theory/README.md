# Theory — Master Index

Theorie-Dokumente, didaktische Modellbrücken und externe Phase-C-Brücken des Kepler-Hurrwitz-Programms.

---

### Fixed-Locus / Riemann-Programm (L4)

**Datei:** [`fixed_locus_riemann_program.md`](fixed_locus_riemann_program.md)  
**Status:** `[L4 / programmatisch]` — ORQ-088  
**Register-Abgrenzung:** E-034 (`[C]` refuted), E-035 (`[C]` open_hypothesis)  
**Nummern-Abgrenzung:** **ORQ-088** = Fixed-Locus/Riemann-Programm `[L4]` · **E-088** = Onsager-Reziprozitätsdiagnostik im Weyl–Onsager-Kontext — gleiche Nummer, verschiedene Themen, **nicht** identisch (Register-Rename wäre invasiv; Abgrenzung hier dokumentiert).  
**Claim-Grenze:** Symmetrie \(D(Z)=Z\) bekannt; Konfinierung \(\mathrm{Fix}(D\mid_Z)=Z\) offen — kein RH-Loss-Claim.

---

### Ideale, Dedekind-Hasse und quaternionische Primzahlpfade

**Datei:** [`ideal_dedekind_hasse_intro_abitur.md`](ideal_dedekind_hasse_intro_abitur.md)  
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

**Datei:** [`oppenheim_eabc_stability_bridge.md`](oppenheim_eabc_stability_bridge.md)  
**Status:** `[D]` konzeptionelle Brücke / externe Analogie  
**Evidenz:** E-070  
**Zweck:** Methodische Parallele zwischen Oppenheim post-quantum classical gravity (stochastische Metrik) und eabc-/quaternionischen Stabilitätstests — Perturbationsklassen für Invarianten, keine Physikbehauptung.  
**Claim-Grenze:** Keine Kausalbehauptung zwischen Raumzeit-Diffusion und Primidealstruktur.

---

### Weyl–Onsager Komplettangriff (E-087, E-088)

**Datei:** [`weyl_onsager_bridge_attack.md`](weyl_onsager_bridge_attack.md)  
**Status:** `[C]` koordinierter End-of-Day-Angriff — Weyl-Chiralität + Onsager-Reziprozität  
**Evidenz:** E-087 (Weyl), **E-088** (Onsager-Reziprozität — nicht ORQ-088); ergänzt E-089 und ORQ-087  
**Zweck:** Lesesprache und Diagnostik-Scaffold für lokale Chiralität (Berry, Windung) und globale Kopplungssymmetrie (Hall/Klitzing, 24I₃) — ohne Beweis.  
**Claim-Grenze:** koordinierter Diagnose- und Lesesprachangriff, nicht Abschlussbeweis; E-077 bleibt Priorität 1.  
**Stub:** `src/kepler_hurwitz/weyl_onsager_diagnostics.py` · **Export:** `examples/run_weyl_onsager_attack.py`

---

### Onsager Quantization Bridge (ORQ-089)

**Datei:** [`onsager_quantization_bridge.md`](onsager_quantization_bridge.md)  
**Status:** `[C]` Physik-Analogie — vier Resonanzachsen (Flussquantisierung, quantisierte Wirbel, 2D-Ising, Reziprozität)  
**Evidenz:** E-089  
**Zweck:** Onsagers Beiträge als komplementäre Lesesprache für Diskretisierung, Umlauf, Kritikalität und Zeitumkehr in EABC — ohne physikalische Identifikation.  
**Claim-Grenze:** Ergänzt E-076 als Lesesprache; keine Deduktion zwischen Onsager-Physik und Dumas-/EABC-Befunden, keine physikalische Identifikation.

**Governance:** Externe Physik `[C]` · interne Zirkulationsmessung `[B]`

**Diagnostik `[B]` (experimental):**

| Artefakt | Pfad |
|---|---|
| Modul | `src/kepler_hurwitz/onsager_vortex_diagnostics.py` |
| Export-Skript | `scripts/onsager_vortex_export.py` |
| CSV | [`../exports/onsager_vortex_circulation_upto_1000000.csv`](../exports/onsager_vortex_circulation_upto_1000000.csv) |
| Summary JSON | [`../exports/onsager_vortex_circulation_upto_1000000.summary.json`](../exports/onsager_vortex_circulation_upto_1000000.summary.json) |

**Referenzlauf** (Primvierlinge `(p,p+2,p+6,p+8)` mit `p+8 ≤ 10^6`): **166** Quadrupel — Befund: `n_vortex=1`, `n_trivial=0`, Phasenabschluss positiv (`all_phase_closed: true`).  
**Status:** `[B]` experimental diagnostic — kombinatorische Zirkulationsdiagnostik, kein Physikclaim.  
**Nullmodelle (optional):** `--include-nullmodels shuffle,ceab` auf dem Export-Skript.

---

### Weyl-Commutator Operator Bridge (ORQ-087)

**Datei:** [`weyl_commutator_operator_bridge.md`](weyl_commutator_operator_bridge.md) — inkl. didaktischer Einstieg *Why Weyl algebra?* / *Warum die Weyl-Algebra?* und EABC-`[C]`-Brücke
**Status:** `[C]` Brückenhypothese — `[B]` über $\Delta_{\mathrm{LR}}(\gamma)$  
**Abhängigkeiten:** ORQ-085 (Dedekind $\Phi$), ORQ-083 (Berry-Holonomie)  
**Stub:** `src/kepler_hurwitz/weyl_commutator_diagnostics.py`  
**Claim-Grenze:** Weyl-Lesart für L/R-Asymmetrie — kein Dedekind-Beweis, keine Berry-Identität.

---

### Offene Bridge Targets `[C]` (ORQ-077–ORQ-087)

**Kanonischer Katalog:** [`../open_mathematical_bridge_targets.md`](../open_mathematical_bridge_targets.md) — Governance-Tabelle, Prioritäten, Abhängigkeiten, Durchbruchspfad  
**ORQ-Kurzindex:** [`../open_research_questions.md`](../open_research_questions.md)  
**Register:** E-077–E-085 (+ E-076 Physik-Dossier, E-053 Renorm-Stub) in [`EVIDENCE_REGISTER.md`](../../EVIDENCE_REGISTER.md)  
**Research Map:** [`../research_map.md`](../research_map.md)

| Prio | Cluster | ORQ | E-ID |
|---|---|---|---|
| 1 | Metrischer Separationsverlust | ORQ-077 | E-077 |
| 2–3 | Globale R³ / Bouligand | ORQ-078–079 | E-078–E-079 |
| 4 | Dedekind Φ(v)=γ | ORQ-085 | E-067–E-069, Lean `EabcToQuaternionOrderMapHypothesis` |
| 5 | Berry-Holonomie | ORQ-083 | E-083 |
| 6 | GeometryScaffold | ORQ-084 | E-084 |
| 7–8 | Monopol / Windung | ORQ-080–082 | E-080–E-082 |
| 9 | shellPrimeMatchAtFirstLoss | ORQ-086 | E-085 (gated on E-077) |
| 10 | Weyl-Commutator $\Delta_{\mathrm{LR}}$ | ORQ-087 | — (`weyl_commutator_diagnostics.py`) |
| 11 | Onsager Quantization Bridge | ORQ-089 | E-089 |
| 12 | Weyl–Onsager Komplettangriff | — | E-087, E-088 |

**Claim-Grenze:** Alle Eintraege sind `[C]` — keine physikalische Identifikation, kein Lean-Beweis ohne explizite Formalisierung. E-085 erst nach internem Nachweis von `MetricSeparationLossExists`. Meissner (E-076) nur als Lesesprache fuer E-077: [`meissner_analogy_assessment.md`](meissner_analogy_assessment.md).

**Shell-Separationsdiagnostik (E-077–E-079):** [`../reports/shell_separation_diagnostics_protocol.md`](../reports/shell_separation_diagnostics_protocol.md) · Implementierung `src/kepler_hurwitz/shell_separation_diagnostics.py` · CSV-Export `scripts/shell_separation_diagnostics.py`

---

### Arithmetisches Vakuum–eabc: Externe arithmetische Feinstruktur-Analogie

**Datei:** [`arithmetic_vacuum_eabc_analogy.md`](arithmetic_vacuum_eabc_analogy.md)  
**Status:** `[C]` externe arithmetische Feinstruktur-Analogie  
**Evidenz:** E-073 (motivisch; keine Lean-Formalisation)  
**Zweck:** Einordnung des Hassall-Papers (*Arithmetic Vacuum*) und Energiedoku-Skripte ($\alpha \approx 1/(4\pi\zeta(3)\cdot 3^2)$, Prim-Log-Gitter, Zeta-Jitter, Dirac-artige Ladungsquantisierung) als **externer Resonanzanker** — ohne Formal-Core-Beleg für EABC, Lean oder Dedekind–Hasse.  
**Claim-Grenze:** EABC besitzt Anschlussmotive zu arithmetischen Feinstruktur-Modellen — **nicht** „EABC erklärt $\alpha$“.

**Verwandte Schichten:**

| ID | Datei | Rolle |
|---|---|---|
| E-053 | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` | EABC-Renormierungskern |
| E-064 | [`ideal_dedekind_hasse_intro_abitur.md`](ideal_dedekind_hasse_intro_abitur.md) | DH-QPID-Stabilitätstest |
| E-067–E-069 | `docs/dedekind_ideal_layer.md` | Lean-Ideal-Schicht |
| E-073 | `docs/hott_identity_layer.md` | HoTT Identity Layer (motivisch) |
| E-075 | `docs/energiedoku_exports/e075_prime_grid_signaturgeometrie.md` | Prime Grid / Signaturgeometrie (`[B]`/`[C]`) |

---

### Higgs-Blasen–eabc: Topologische Defektkollision als Renormierungstest

**Datei:** [`higgs_bubble_eabc_analogy.md`](higgs_bubble_eabc_analogy.md)  
**Status:** `[D]` konzeptionelle Brücke / externe Analogie  
**Evidenz:** E-071  
**Zweck:** Methodische Parallele zwischen DESY/Hamburg Higgs-Blasenkollisions-Baryogenese ($T=0$, nichtthermische Sphaleronen) und eabc-Renormierungs-/Invariantentests — Defektkollision, topologischer Sektorwechsel, globaler Bias, keine Physikbehauptung.  
**Claim-Grenze:** Keine Kausalbehauptung zwischen Higgs-Blasendynamik und quaternionischer Primstruktur oder eabc.

**Verwandte Schichten:**

| ID | Datei | Rolle |
|---|---|---|
| E-053 | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` | EABC-Renormierungskern |
| E-070 | [`oppenheim_eabc_stability_bridge.md`](oppenheim_eabc_stability_bridge.md) | Geschwister-[D]-Brücke (stochastische Perturbation) |
| E-064 | [`ideal_dedekind_hasse_intro_abitur.md`](ideal_dedekind_hasse_intro_abitur.md) | DH-QPID-Stabilitätstest |

---

### Prime Grid / Signaturgeometrie (E-075)

**Datei:** `docs/energiedoku_exports/e075_prime_grid_signaturgeometrie.md`  
**Status:** `[B]` Prime Grid-Normalform; `[C]` EABC-Brückeninterpretation  
**Evidenz:** E-075 · **Quellen:** [`kolossvary_the_prime_grid.pdf`](../mathematische_texte/kolossvary_the_prime_grid.pdf), [`givental_kepler_laws_conic_sections.pdf`](../mathematische_texte/givental_kepler_laws_conic_sections.pdf)  
**Claim-Grenze:** Externe Signaturgeometrie — **kein** Beweis von EABC, Dedekind–Hasse, HoTT oder Renormalisierung.

---

### Dumas Cone–Orbit Model (E-048 / Gedankenexperiment)

**Datei:** [`dumas_cone_orbit_model.md`](dumas_cone_orbit_model.md)  
**Status:** `[C]` methodische Analogie  
**Evidenz:** E-048 (Dumas-Lemma), Lift-Parallel E-075  
**Zweck:** D'Artagnan-Kreis / Musketeer-Triple im Doppelkegel-Lift; Gewichtspartition auf \(\Delta^3\); Zwei-Prim-Extension mit Phantom-Inversen.  
**Claim-Grenze:** Gleiche Methode, nicht gleiche Objekte; Kepler-Namen sind Analogiesprache.

---

### Lift-Projektions-Prinzip (Quaternionen ↔ Kepler/Givental)

**Datei:** [`kepler_quaternion_lift_projection.md`](kepler_quaternion_lift_projection.md)  
**Status:** `[C]` methodische Brücke  
**Evidenz:** E-075 (Givental-Parallele), E-067–E-069 (Dedekind-Ideal-Schicht)  
**Zweck:** Kepler-Kegel und quaternionische Norm als **quadratische Lift-Strukturen** im gleichen Projektionsschema ($\mathcal{O}=\pi_K(C\cap\Pi)$, $H=\pi_Q(\mathcal{Q}_{\mathrm{arith}}\cap\mathcal{S})$) — gleiche Methode, nicht gleiche Objekte.  
**Claim-Grenze:** Kein Identitätsclaim; $\Phi(v)=\gamma$ bleibt offen.  
**Stub:** [`docs/lift_projection_principle.md`](../lift_projection_principle.md) (Weiterleitung)  
**Parameter:** [`distilled_parameters.md`](distilled_parameters.md) — acht priorisierte Diagnostics (`kepler_hurwitz.diagnostics`)

---

### Parameter-Atlas (E-075)

**Datei:** [`../diagnostics_parameter_atlas.md`](../diagnostics_parameter_atlas.md) — Top-8 Primär-API, Formeln, Governance-Box  
**Theorie:** [`distilled_parameters.md`](distilled_parameters.md)  
**Implementierung:** `src/kepler_hurwitz/diagnostics.py`  
**Status:** `[B]` arithmetische Diagnostics; `[C]` Collatz-Witness, Chiralität Nat→8D  
**Acht Kernfunktionen:** `net_descent_margin`, `bad_run_cost`, `shrink_efficiency`, `channel_entropy`, `prime_grid_compression`, `norm_signature_defect`, `projection_loss`, `chirality_norm`  
**Governance:** Parameter destillieren ja; Identifikation behaupten nein.

---

### Collatz V2.7 — Net-Descent-Bridge

**Datei:** `docs/collatz_v27_net_descent.md`  
**Status:** `[A]` Witness ⇒ Abstieg; `[C]` uniforme Witness-Existenz  
**Lean:** `KeplerHurwitz/CollatzProofAttemptV27.lean`  
**Kette:** `docs/collatz_v2_evidence_chain.md`

**Tao-inspirierte Syracuse-Diagnostics `[B]`:** [`../collatz_tao_diagnostics.md`](../collatz_tao_diagnostics.md)  
**Modul:** `src/kepler_hurwitz/tao_collatz_diagnostics.py` · **Export:** `examples/run_tao_collatz_diagnostics_export.py`  
**Claim-Grenze:** numerische First-Passage-/Valuation-Experimente nach Tao (2019) — kein Collatz-Beweis, keine Tao-Formalisierung.

---

### Physical Analogies [C] — AB / Klitzing / Meissner (E-076)

**Datei:** [`../reports/physical_reference_analogies.md`](../reports/physical_reference_analogies.md)  
**Status:** `[C]` methodische Physik-Analogie  
**Evidenz:** E-076 (interpretativ; keine Lean-Formalisation der Analogien)  
**Zweck:** Drei Referenzphänomene als Resonanzanker — Aharonov–Bohm (Orbit/Phase), von Klitzing/QHE (Kanal/Topologie), Meissner (Defekt-Exklusion, Meissner-Shell) — für Lesefragen zu $24I_3$, Retraktion und Shell-Stapel.  
**Claim-Grenze:** Analogie, nicht Identität; Dumas-Orbit-Protokoll bleibt empirisch getrennt.

**Verwandte Schichten:**

| ID | Datei | Rolle |
|---|---|---|
| E-053 | [`eabc_renormalisierungsprogramm.md`](../energiedoku_exports/eabc_renormalisierungsprogramm.md) | Formaler $24I_3$-Kern `[A]`/`[B]` |
| E-074 | [`arithmetic_vacuum_eabc_analogy.md`](arithmetic_vacuum_eabc_analogy.md) | Geschwister-`[C]` (Feinstruktur/Vakuum) |
| E-076 | [`physical_reference_analogies.md`](../reports/physical_reference_analogies.md) | AB / Klitzing / Meissner |
| E-076 | [`meissner_analogy_assessment.md`](meissner_analogy_assessment.md) | Urteil: Meissner `[C]` — Lesen ja, Durchbruch nein |

---

### Physik-Referenz (extern)

| Thema | Datei | Rolle |
|---|---|---|
| Meissner-Effekt | [`../physics/meissner_effect.md`](../physics/meissner_effect.md) | Didaktische Referenz zu Supraleitung und Magnetfeldverdrängung (extern, nicht EABC-Kern) |
| Physical Analogies | [`../reports/physical_reference_analogies.md`](../reports/physical_reference_analogies.md) | EABC-Interpretation AB / Klitzing / Meissner `[C]` |
