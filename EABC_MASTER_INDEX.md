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
  - **[C] Methode:** Lift-Projektions-Prinzip (Quaternionen ↔ Kepler/Givental) — `docs/lift_projection_principle.md`
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
