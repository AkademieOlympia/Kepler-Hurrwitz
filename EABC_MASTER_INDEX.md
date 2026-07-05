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
