# EABC Master Index

## Aktuelle Schwerpunkte

- **Projekt „Die drei Musketiere“** **[A-D/C/B]**
  - **[A-T] Formal:** `KeplerHurwitz/Representation/DreiMusketiere.lean` (`E-025`, `E-029`, `E-030`)
  - **[C] Hypothese:** `MusketiereNeighborTripleHypothesis` (`E-026`)
  - **[B] Empirie:** `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_drei_musketiere`, `E-027`; `a5_geo_canonical_embedding`, `E-028`)
  - **Dossier:** `docs/drei_musketiere_hypothese.md` (Abschnitt 5: kanonisches Embedding K1–K4)

- Orbit-Smoothness-Bruecke / EABC Smoothness Attraktor **[A/B/C]**
  - **[A] Formal:** `KeplerHurwitz/SmoothAttraktor.lean`,
    `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean`
  - **[B] Empirie:** Exportartefakte unter `docs/energiedoku_exports/`
  - **[C] Hypothese:** `docs/eabc_attraktor_hypothese.md`
  - **Dossier:** `results/reports/EABC_SMOOTHNESS_ATTRACTOR_DOSSIER.md`

- EABC-Kanal-Partition (Bucket-Maximalitaet) **[A/B+]**
  - **[A] Formal:** `KeplerHurwitz/EABCChannelPartition.lean` (`K = min_c |L_c|`, Greedy-Satz)
  - **[B+] Empirie:** `src/kepler_hurwitz/eabc_rising_collection.py`, Exporte `docs/energiedoku_exports/eabc_partition_*_2000.csv`; Referenz `n=2000`: `m=1998`, `K=486`, Coverage 97,3 %, Greedy 310
  - **Tests:** `tests/test_eabc_rising_collection.py`, `tests/test_kepler_eabc_atlas.py`
  - **Dossier:** `docs/eabc_partition.md`
  - **Commit:** `acfea89` (2026-07-04)

- Kanonische EABC-Signatur \(H(n)\) und Masse \(M(n)\) **[B]**
  - **[A] Formal:** `KeplerHurwitz/EABCLayer.lean` (`EABCSignature4`, `totalWeight`)
  - **[B] Referenz:** `src/kepler_hurwitz/signatures.py` (`signature_from_nat`, `eabc_mass`)
  - **Konvention:** `docs/eabc_mass_convention.md`
  - **Tests:** `tests/test_signatures.py`
  - **Reine Prim-EABC-Quaternionen (p-only, achsenausgerichtet):** `docs/energiedoku_exports/pure_prime_eabc_quaternions.csv`; idealtheoretische Einordnung → `docs/pure_prime_eabc_dedekind_interpretation.md`
  - **Reine Primzahlvierlinge (kanonische Primquadruplet):** `docs/energiedoku_exports/pure_prime_quadruples.csv`; idealtheoretische Einordnung → `docs/pure_prime_quadruple_dedekind_interpretation.md`
  - **Testkonzept Primzahlvierlinge:** `docs/prime_quadruple_test_concept.md`; Tests → `tests/test_prime_quadruple_eabc.py`, `tests/test_prime_quadruple_governance_docs.py`

- HoTT Identity Layer (konzeptionelles Interface / Grundlagenhypothese) **[C]**
  - **[C] Formal:** `KeplerHurwitz/HoTTIdentityLayer.lean` (`E-073`: `HoTT_EABC_Interface` mit `PathWitness`/`migration_path` als Pfadzeuge-Hypothese, `IdealUnivalence*` als univalentes Zielbild-Marker, `DH_Quat`-Modellskizze, `period_equiv_zmod12` als Fundamentalperioden-Modellierung, `EabcMod12Pi1Hypothesis` separat)
  - **Basis:** E-067–E-069 (Dedekind-Ideal-Schicht), E-053 (Dedekind–Hasse), E-072 (mod-12-Kanalpartition)
  - **Dossier:** `docs/hott_identity_layer.md`
  - **Governance:** Anschlussraum, kein Ersatz E-067–E-069; Lean 4 ≠ HoTT/Univalenz; `migration_path` = Pfadzeuge (stärkster Kern, kein abgeleiteter HoTT-Satz); `period_equiv_zmod12` = Fundamentalperioden-Modellierung, nicht π₁ ≃ Z/12Z; `IdealUnivalence*` = Zielbild-Marker, kein Voevodsky-Postulat; E-072-Kanalabbildung ≠ Homotopie; beweist nicht EABC
  - **Externe Referenzen (Referenzrahmen):** HoTT Book, Coq-HoTT, Lean 2 HoTT, nLab (Lean, Univalenz, HITs) — siehe `docs/hott_identity_layer.md`

- Dedekind-Ideal-Brücke / Primzahlvierlinge **[B/C]**
  - **[B] Arithmetik:** \(M(P(v))=4\) für kanonische Primvierlinge; Dumas E-048
  - **[C] Interface:** \(\Phi(v)=\gamma\) — Domain/Codomain in `docs/pure_prime_quadruple_dedekind_interpretation.md`, `docs/energiedoku_exports/dedekind_hasse_eabc_bridge.md`
  - **[C] Methode:** Lift-Projektions-Prinzip (Quaternionen ↔ Kepler/Givental) — `docs/theory/kepler_quaternion_lift_projection.md`
  - **[B] Dumas Cone–Orbit (H1–H11):** numerisch auf 166 Primvierlingen bis \(p\le10^6\) — `docs/theory/dumas_cone_orbit_model.md` · `tests/test_dumas_cone_orbit.py`
  - **[B] Dumas-Orbit Experimental Protocol:** Regression vs. H12–H15 vs. Nullmodelle F1–F5 — `docs/reports/dumas_orbit_experimental_protocol.md` · `scripts/dumas_orbit_experiment.py` · CSV unter `docs/energiedoku_exports/dumas_orbit_*.csv`
  - **[B] Parameter-Atlas:** `docs/theory/distilled_parameters.md` · `src/kepler_hurwitz/diagnostics.py` (acht priorisierte Diagnostics, Governance-Box)
  - **LaTeX:** `eabc-renorm/docs/EABC_Uebersicht.tex` (`sec:prime-quadruple-dedekind`, Alias `eabc_renorm_overview.tex`)
  - **Register:** E-067–E-069, E-053, E-072, E-073

- Collatz V2.7 — Net-Descent-Bridge **[A/C]**
  - **[A] Formal:** `KeplerHurwitz/CollatzProofAttemptV27.lean` — `mod4_three_descends_from_net_descent_witness` (0 `sorry`)
  - **[C] Offen:** `bad_run_net_descent_witness_of_mod4_three` — uniforme Existenz `BadRunNetDescentWitness` für \(n \equiv 3 \pmod 4\)
  - **Dossier:** `docs/collatz_v27_net_descent.md` · Kette: `docs/collatz_v2_evidence_chain.md`
  - **Nächster Angriffspunkt:** quantitative Abschätzung \(m_{\mathrm{good}}\) vs. \(n\)

- Energiedoku Shell-Koordinaten (n=1..3) **[B]**
  - **CSV:** `docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv` (84 Datenzeilen)
  - **Loader:** `src/kepler_hurwitz/energiedoku_shell_construction.py`
  - **Audit:** `scripts/compare_shell_embeddings.py`, `docs/reports/EMBEDDING_AUDIT_PIPELINE.md`
  - **Ticket:** `docs/tickets/extract-energiedoku-shell-coordinates-n1-n3.md` (COMPLETE)

- **Physical Analogies [C]** — AB / Klitzing / Meissner als Resonanzanker
  - **[C] Interpretation:** Aharonov–Bohm → Orbit-/Phasenanker; von Klitzing/QHE → Kanal-/Topologieanker; Meissner → Defekt-Exklusionsanker (Meissner-Shell / Meissner-Randschale)
  - **[C] Analogiekette (nicht Identität):** \(B \approx 0 \leadsto \Delta_{\mathrm{innen}} \approx 0 \leadsto M_{\mathrm{eff}} \to 24I_3\)
  - **[B] Meissner-Diagnostik:** vorgeschlagene Metriken — operationalisiert in `diagnostics.py` erst dann `[B]`
  - **Dossier:** `docs/reports/physical_reference_analogies.md` · Didaktik: `docs/physics/meissner_effect.md`
  - **Trennung:** Dumas-Orbit-Protokoll bleibt empirisch — Physik-Analogien separat (siehe Protokoll §Governance)
  - **Register:** E-076

- **Onsager Quantization Bridge [C]** — Flussquantisierung / Wirbel / Ising / Reziprozität
  - **[C] Interpretation:** vier Onsager-Achsen als Resonanzsprache für Diskretisierung, Umlauf, Kritikalität, Zeitumkehr in EABC
  - **Verwandte ORQs:** ORQ-080, ORQ-083, ORQ-087, ORQ-077–079
  - **Dossier:** `docs/theory/onsager_quantization_bridge.md`
  - **Stub `[B]`:** `src/kepler_hurwitz/onsager_vortex_diagnostics.py` (Gap-Rotor-Zirkulation, Holonomie, Defektkern)
  - **Claim-Grenze:** Ergänzt E-076 — keine physikalische Identifikation, keine Deduktion aus Dumas-Empirie
  - **Register:** E-089 (ORQ-089)

- **Projekt „Black Hole“** — Legendre-GWTC-Massenlücken **[C/B]**
  - **[A/B] Algebra:** `scripts/black_hole/legendre_mass_gaps.sage`, `black_hole_legendre_gwtc.py`
  - **[C] Brücke:** \(\kappa: M_\odot \to \mathbb{Z}\), \(\chi_p\)-Stratifizierung 1G/2G, `eabc_merger.sage`, `five_qubit_bridge.sage`, `monopole_gap_test.sage`
  - **[C] Riemann-Achsen-Monopol:** \(\delta=\psi_a-\psi_{bc}\) an \(\gamma_n\); `eabc_monopole_axis_resonance.py`, `eabc_six_state_prime_axes.py` · Dossier `docs/theory/eabc_riemann_axis_monopole.md` (BH-C-08)
  - **[C] L-Gap-Symplektik-Brücke:** \(\Delta\gamma\) → 15 `[[5,1,3]]`-Stabilisatoren GF\((2)^4\setminus\{0\}\); `eabc_symplectic_stabilizer_bridge.py` · Dossier `docs/theory/eabc_symplectic_l_gap_bridge.md` (BH-C-09)
  - **[C] Energetische Quadratsumme:** \(a = a_x^2 + a_y^2\) als Energiedichte-Metrik; `eabc_energy_square_sum.py` · Dossier `docs/theory/eabc_energy_square_sum_substitution.md` (BH-C-11)
  - **[B] Stub:** Fisher-Test + Mock-GWTC-Export — `examples/run_black_hole_gwtc_export.py`
  - **Dossier:** `docs/black_hole_hypothese.md`, `docs/theory/black_hole_legendre_gwtc_bridge.md`, `docs/black_hole/claim_register.md`
  - **Lean `[C]`:** `KeplerHurwitz/BlackHoleInterface.lean`
  - **Register:** E-093 (ORQ-093)
  - **Geschwister `[C]`:** mod-6-Sechs-Zustands-Primachsen — `docs/theory/eabc_six_state_prime_axes.md`, `eabc_six_state_prime_axes.py`, `eabc_prime_six_state.sage` (kein neues E-ID; BH-C-07)

- **Projekt „Phaseninvarianz“** — Pauli-Energie-Schutz/Verwundbarkeit **[C/B]**
  - **[A/B] Algebra:** \(E_a\) invariant unter Pauli Z/X; \(E_{bc}\) verwundbar unter Tensor-X — `phaseninvarianz_pauli_energy.py`, `pauli_energy_invariance.sage`
  - **[C] Brücke:** 6k+1-Primachse \(a\) QEC-geschützt; \(bc\)-Bivektor benötigt volle `[[5,1,3]]`-Grammatik (E-044, BH-C-09)
  - **[B] Stub:** `pauli_invariance_report` + Export — `examples/run_phaseninvarianz_export.py`
  - **Dossier:** `docs/phaseninvarianz_hypothese.md`, `docs/theory/phaseninvarianz_pauli_energy_bridge.md`, `docs/phaseninvarianz/claim_register.md`
  - **Lean `[C]`:** `KeplerHurwitz/PhaseninvarianzInterface.lean`
  - **Register:** E-094 (ORQ-094)

- **Projekt „Riemann-Interferenz“** — ln(x)-Knoten-Interferenz **[C/B]**
  - **[B] Stub:** \(S(x;\Gamma)=\sum\cos(\gamma\ln x)\) über erste 50 \(\gamma_n\) — `riemann_interference_diagnostics.py`
  - **[C] Brücke:** konstruktiv/destruktiv an Prim/Komposit bc-Knoten; Cross-Talk \(\Delta E\) (PI-C-03); Residual-Oszillation (E-092)
  - **Dossier:** `docs/theory/riemann_zero_interference_analogy.md`
  - **Register:** E-095 (ORQ-095)
  - **Abgrenzung:** E-034 (refuted mean \(\Delta M\)), E-035 (open mean \(x_0\)) — andere Normalisierung
