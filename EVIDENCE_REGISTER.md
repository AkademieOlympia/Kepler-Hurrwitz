# Evidence Register

Dieses Register fuehrt zentrale Aussagen des Projekts mit eindeutiger ID.
Es dient als Referenzschicht fuer Doku, Reviews und spaetere Publikationen.

## Evidenzkategorien

- `[A]`: formal bewiesen (Lean)
- `[B]`: reproduzierbar numerisch/empirisch
- `[C]`: offene mathematische Hypothese/Interface
- `L4`: programmatische Interpretation

### Stabilitaetsstatus

- `stable`: langfristig tragender Projektbaustein
- `experimental`: kann sich mit neuen Daten/Formalisierungen aendern
- `deprecated`: wird nicht mehr aktiv verwendet, bleibt aber dokumentiert
- `superseded`: durch neueren Eintrag ersetzt

### Subtypen innerhalb von `[A]`

- `A-T` (Theorem): voll formal bewiesene mathematische Aussage
- `A-I` (Infrastructure): formale Infrastruktur / Integrationsschnittstelle
- `A-D` (Definition): formale Definition ohne eigenen Theoremschritt

## Register

| ID | Aussage | Ebene | A-Klasse | Quelle | Depends on | Supports | Scope | Metrik/Ergebnis | Status | Stabilitaet | Letzte Pruefung |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `E-001` | `collatz_iterate_pow_two_to_one` | `[A]` | `A-T` | `KeplerHurwitz/CollatzNormShell.lean` | `collatz_step_pow_two` | `-` | Zweierpotenzen | formaler Satz | bewiesen | `stable` | `2026-07-02` |
| `E-002` | B=11-Attraktor zeigt erhoehte Trefferquote | `[B]` | `-` | `docs/energiedoku_exports/smoothness_b_bound_summary.json` | `smoothness_b_bound_matrix.json` | `E-003` (indirekt) | Scans ueber mehrere Skalen/B-Bounds | Trendmetriken (`stability_score`, `v_ratio`) | reproduzierbar | `experimental` | `2026-07-02` |
| `E-003` | `InterferenceSelectsB11` | `[C]` | `-` | `KeplerHurwitz/InterferenceAttraktorBridge.lean` | `E-005`, `E-006`, `E-008`, `E-009` (unterstuetzend, nicht beweisend) | `-` | globale Bridge-Formulierung | offen | offen; nicht zu `[B]` geupgradet | `experimental` | `2026-07-02` |
| `E-004` | Diskrete Operatorgeometrie kann langfristig fuer physikalische Modelle relevant sein | `L4` | `-` | `README.md` | `ARCHITECTURE.md` (`L4`-Vertrag) | `-` | Programmrahmen | programmatische Einordnung | programmatisch | `stable` | `2026-07-02` |
| `E-005` | Reproduzierbare numerische Bridge-Studie fuer den kanonischen Interferenzpunkt innerhalb des definierten Testbereichs | `[B]` | `-` | `docs/energiedoku_exports/interference_b11_study.json` | `examples/run_interference_b11_study.py`, kanonischer Interferenzpunkt (`SymbolicResultants`) | `E-003` | kanonischer Interferenzpunkt `(-5/2, 15/4)`, `limit_m=200001` (`100001` ungerade Samples) | `violation_count=0`, `b11_hit_rate=1.0` | reproduzierbar | `experimental` | `2026-07-02` |
| `E-006` | `CanonicalInterferenceSelectsB11Local` | `[A]` | `A-T` | `KeplerHurwitz/InterferenceAttraktorBridge.lean` | `mod12_residue_le_eleven`, `odd_mod12_cases` | `E-003` | lokale Zwischenstufe via endlicher Mod-12-Restklassenrechnung | formaler Satz (`canonicalInterferenceSelectsB11Local_true`) | bewiesen | `stable` | `2026-07-02` |
| `E-007` | Hales/Tao-Integration als formales Seed-Interface | `[A]` | `A-I` | `KeplerHurwitz/HalesTaoIntegration.lean` | `hales_kepler_seed`, `tao_odd_mod8_seed`, `halesSeedNode_integrated`, `taoSeedNode_integrated` | zukuenftige Hales-Integration, zukuenftige Tao-Integration | nur Interface + konkrete Seed-Lemmata; keine Vollintegration der Arbeiten von Hales oder Tao | typisierte Integrationsstruktur mit formalisierten Seeds | Seed integriert | `stable` | `2026-07-02` |
| `E-008` | `canonicalInterferenceResidue_implies_odd` und `canonicalInterferenceResidue_implies_le11` | `[A]` | `A-T` | `KeplerHurwitz/InterferenceAttraktorBridge.lean` | `odd_mod12_cases`, `mod12_residue_le_eleven` | `E-003` | lokale Residueneigenschaften fuer kanonische Interferenzresiduen | formale Saetze (`r % 2 = 1`, `r ≤ 11`) | bewiesen | `stable` | `2026-07-02` |
| `E-009` | `GlobalCoverageByCanonicalResidues` | `[C]` | `-` | `KeplerHurwitz/InterferenceAttraktorBridge.lean` | `E-006`, `E-008`, `E-010` (lokaler Unterbau) | `E-003` | offene Abdeckungsannahme von global admissible auf kanonische Residuen | offen | offen | `experimental` | `2026-07-02` |
| `E-010` | ModEq-basierte lokale Odd-Residue-Coverage (`OddResidueMod12`) | `[A]` | `A-T` | `KeplerHurwitz/InterferenceModEqCoverage.lean` | `Nat.mod_modEq`, `odd_mod12_to_oddResidueMod12`, `oddResidueMod12_of_canonicalResidue` | `E-009`, `E-003` | lokale Mod-12-Coverage-Schicht ohne Globalclaim | formale Lemmaschicht (`modEq_of_eq_mod12`, `oddResidueMod12_of_canonicalResidue`) | bewiesen | `stable` | `2026-07-02` |
| `E-011` | `OrbitHasSmoothRepresentative` | `[A]` | `A-D` | `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean` | `IsBSmooth` | `E-017` | defensives Orbit-Interface (mindestens ein `B`-glatter Repräsentant in explizitem Carrier) | formale Definition | definiert | `stable` | `2026-07-02` |
| `E-012` | `OrbitAllSmooth` | `[A]` | `A-D` | `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean` | `IsBSmooth` | `E-017` | alle expliziten Orbit-Carrier-Werte sind `B`-glatt | formale Definition | definiert | `stable` | `2026-07-02` |
| `E-013` | `OrbitSmoothProfile` | `[A]` | `A-D` | `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean` | `CyclicWordOrbit`, `IsBSmooth` | `E-015`, `E-016` | Profilstruktur zur Kopplung von Orbit, Werteliste und All-Smooth-Nachweis | formale Strukturdefinition | definiert | `stable` | `2026-07-02` |
| `E-014` | `orbit_has_smooth_rep_mono` | `[A]` | `A-T` | `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean` | `E-011`, `IsBSmooth_mono` | `E-017` | Monotonie in `B` fuer glatten Orbit-Repräsentanten | formales Lemma (defensive Transferaussage) | bewiesen | `stable` | `2026-07-02` |
| `E-015` | `profile_member_smooth_of_dvd` | `[A]` | `A-T` | `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean` | `E-013`, `IsBSmooth_of_dvd` | `E-017` | Teilervererbung auf Profilwerten | formales Lemma | bewiesen | `stable` | `2026-07-02` |
| `E-016` | `profile_member_mul_smooth` | `[A]` | `A-T` | `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean` | `E-013`, `IsBSmooth_mul` | `E-017` | multiplikative Stabilitaet auf Profilwerten | formales Lemma | bewiesen | `stable` | `2026-07-02` |
| `E-017` | `OrbitSmoothBiasHypothesis` | `[C]` | `-` | `KeplerHurwitz/Collatz/CkA/OrbitSmoothBridge.lean` | `E-011`, `E-012`, `E-014`, `E-015`, `E-016`, `E-018` | `-` | offene Smoothness-Bias-Hypothese als reine Interface-Schicht | offen; keine formale Attraktorwirkung behauptet | offen | `experimental` | `2026-07-02` |
| `E-018` | EABC Smoothness Attraktor Dossier + Exportartefakte | `[B]` | `-` | `results/reports/EABC_SMOOTHNESS_ATTRACTOR_DOSSIER.md` | `docs/energiedoku_exports/smoothness_significance.json`, `docs/energiedoku_exports/smoothness_scale_stability.json`, `docs/energiedoku_exports/smoothness_b_bound_matrix.json`, `docs/energiedoku_exports/smoothness_b_bound_summary.json` | `E-017` | reproduzierbare Empirie getrennt von Lean-Theoremen | Artefaktkette dokumentiert; Attraktorfrage bleibt offen | reproduzierbar | `experimental` | `2026-07-02` |
| `E-019` | `a5_geo` invariant-subspace representation check (rotational icosahedral group) | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage` | `KeplerHurwitz/Representation/Invariant.lean` (konzeptioneller Kontext), `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo` mode) | `results/reports/A5_GEO_INVARIANT_SUBSPACES_REPORT.md` | geometrische `A5`-Wirkung auf 12 Ikosaeder-Ecken; explizit nicht `I_h` | `group order=60`, `vertices preserved=True`, `W_triv invariant=True`, `W_sumzero invariant=True`, `direct sum dimension=12`, `intersection dimension=0`, `sum invariant=True` | reproduzierbar | `experimental` | `2026-07-03` |
| `E-020` | `a5_geo_decompose` character decomposition check (geometric `A5` action) | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage` | `E-019`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_decompose` mode) | `results/reports/A5_GEO_CHARACTER_DECOMPOSITION_REPORT.md` | Charakteranalyse der 12-Ecken-Permutationsdarstellung; explizit nicht `I_h` | `class sizes=[1,12,12,15,20]`, `perm char=[12,2,2,0,0]`, `irred deg=[1,3,3,4,5]`, `mult=[1,1,1,0,1]`, `dim sum=12`, `trivial mult=1` | reproduzierbar | `experimental` | `2026-07-03` |
| `E-021` | `a5_geo_projectors` central projector decomposition check (geometric `A5` action) | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage` | `E-020`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_projectors` mode) | `results/reports/A5_GEO_PROJECTOR_DECOMPOSITION_REPORT.md` | zentrale Charakterprojektoren fuer die 12-Ecken-Wirkung; explizit nicht `I_h` | `idempotence=True`, `orthogonality=True`, `ranks=[1,3,3,5]`, `sum identity=True`, `group order=60` | reproduzierbar | `experimental` | `2026-07-03` |
| `E-022` | `a5_geo_mode_fingerprints` mode-energy fingerprint diagnostics (geometric `A5` action) | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage` | `E-021`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_mode_fingerprints` mode) | `results/reports/A5_GEO_MODE_FINGERPRINTS_REPORT.md` | Modenanteile konkreter Testvektoren via Projektoren; explizit nicht `I_h` | `reconstruction=True` und `energy sum=True` fuer alle Testvektoren; Mode-Energien dokumentiert | reproduzierbar | `experimental` | `2026-07-03` |
| `E-023` | `a5_geo_eabc_signature_modes` toy EABC mode comparison (geometric `A5` action) | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage` | `E-022`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_eabc_signature_modes` mode) | `results/reports/A5_GEO_EABC_SIGNATURE_MODES_REPORT.md` | toy zyklische ABCE/CEAB-Labelzuweisung auf 12 Ecken; explizit nicht kanonische EABC-Geometrie und nicht `I_h` | stabile Projektorchecks; unter diesem toy embedding identische ABCE/CEAB-Fingerprints (`delta_3=0`, `delta_3'=0`) | reproduzierbar | `experimental` | `2026-07-03` |
| `E-024` | `a5_geo_eabc_embedding_sweep` embedding-sensitivity check (geometric `A5` action) | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage` | `E-023`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_eabc_embedding_sweep` mode) | `results/reports/A5_GEO_EABC_EMBEDDING_SWEEP_REPORT.md` | Vergleich von ABCE/CEAB-Fingerprints ueber mehrere toy label-to-vertex embeddings; kein kanonisches EABC->Ikosaeder-Embedding behauptet | `tested=15`, `identical=4`, `non-identical=11`, `max|delta E3|=7.15541752799933`, `max|delta E3'|=7.15541752799933`, Rekonstruktion immer wahr | reproduzierbar | `experimental` | `2026-07-03` |
| `E-025` | `Bremensaal` und `MusketiereNeighborTriple` Definitionen (Projekt „Die drei Musketiere“) | `[A]` | `A-D` | `KeplerHurwitz/Representation/DreiMusketiere.lean` | `EABCChronology`, `E-019` | `E-026`, `E-027` | 12-Ecken-Ikosaeder-Träger, vier EABC-Dreierbloecke | formale Definitionen | definiert | `stable` | `2026-07-03` |
| `E-026` | `MusketiereNeighborTripleHypothesis` — Nachbar-Dreier der uebrigen Familien in jedem Bremensaal, objektiv | `[C]` | `-` | `KeplerHurwitz/Representation/DreiMusketiere.lean`, `docs/drei_musketiere_hypothese.md` | `E-025`, `E-024` | `-` | alle Trägerkanaele `E,A,B,C`; Objektivitaet unter label-erhaltenden Automorphismen | offen | offen | `experimental` | `2026-07-03` |
| `E-027` | `a5_geo_drei_musketiere` numerische Nachbar-Dreier-Diagnose | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage` | `E-025`, `E-026`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_drei_musketiere` mode) | `docs/drei_musketiere_hypothese.md` | toy-Embeddings auf 12-Ecken-Ikosaeder; kein kanonisches Embedding behauptet | `tested=16`, `all_pass=10`, `host_failures={E:2,A:2,B:3,C:2}`; zyklisch+antipodal+kanonisch vollstaendig, face_neighbor scheitert | reproduzierbar | `experimental` | `2026-07-03` |
| `E-028` | `a5_geo_canonical_embedding` kanonisches EABC-Ikosaeder-Embedding (K1–K4) | `[B]` | `-` | `scripts/invariant_subspaces_a4_toy.sage`, `docs/drei_musketiere_hypothese.md` | `E-025`, `E-026`, `E-027`, `EABCChronology` | `E-026`, `E-029` | lex-sort + mod-4-Orbit + E-Mittelachse + chi-Label; Hurwitz-Anschluss strukturell | `musketiere_all_hosts_ok=True`, `chi_orbit_under_A5=1/60`, `toy_musk_pass=9/15`, `face_neighbor=False` | reproduzierbar | `experimental` | `2026-07-03` |
| `E-029` | `canonical_musketiere_neighbor_triple_for_all_hosts` (kanonisches Referenzsystem) | `[A]` | `A-T` | `KeplerHurwitz/Representation/DreiMusketiere.lean` | `E-025`, `E-028` | `E-026`, `E-030` | hart kodierter Ikosaeder-Graph + Labelcode auf `Fin 12` | formaler Satz fuer alle Trägerkanaele `E,A,B,C` | bewiesen | `stable` | `2026-07-03` |
| `E-030` | `canonical_musketiere_neighbor_triple_chi_objectivity` (chi-Relabeling) | `[A]` | `A-T` | `KeplerHurwitz/Representation/DreiMusketiere.lean` | `E-029`, `EABCChronology`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_chi_objectivity`) | `E-026`, `E-031` | Invarianz unter chi-Orbit auf festem Vertex-Träger; `HasMusketiereNeighborTriple_relabel` | chi-Potenzen 0..3: `all_hosts_ok=True` | bewiesen | `stable` | `2026-07-03` |
| `E-031` | `musketiere_hypothesis_transfer` / `IsEquivalentToCanonical` (Äquivalenz-Kollaps) | `[A]` | `A-T` | `KeplerHurwitz/Representation/DreiMusketiere.lean`, `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_canonical_equivalence`) | `E-029`, `E-030`, `E-028` | `E-026`, `E-032` | Lean: Graph-Auto + Kanal-Relabeling transportiert kanonischen Beweis; Sage: strikte `(σ,τ)`-Äquivalenz | Lean ohne `sorry`; Sage `strict_equivalent=0/9`, `partition_compatible=0/9` | bewiesen | `stable` | `2026-07-03` |
| `E-032` | `objectivity_hypothesis_implies_canonical_bridge` (Objektivitäts-Brücke) | `[A]` | `A-T` | `KeplerHurwitz/Representation/DreiMusketiere.lean` | `E-025`, `E-031`, `E-046`, `E-047`, `E-026` | `E-026` | `CanonicalBridgeHypothesis`, `RespectsLabelFibersUnderAutos`, `LabelIntertwiningGraphAuto` → `IsEquivalentToCanonical`; Kollaps `musketiere_hypothesis_canonical_orbit` | **0 `sorry`**; Bruecke unter expliziter `CanonicalBridgeHypothesis` (Faser-respektierendes `φ` ∨ `IsEquivalentToCanonical`) | bewiesen | `stable` | `2026-07-03` |
| `E-046` | Primvierling-Komplementarität und Host-Auslassungs-Symmetrie (Lean-Label **E-033**) | `[A]` | `A-T` | `KeplerHurwitz/PrimvierlingSymmetry.lean` | `E-025`, `EABCChronology` | `E-032`, `E-047`, `E-048`, `E-026` | `hostTriple`, `hostTriple_union_host_eq_four_set`, `hostTriples_pairwise_ne`, Gap-Paare, `hostTriple_shiftCEAB` | 0 `sorry`; `lake build KeplerHurwitz.PrimvierlingSymmetry` grün (2026-07-03) | bewiesen | `stable` | `2026-07-03` |
| `E-047` | `hostComponentEquiv` und Dreier-Multiplizität (Lean-Label **E-034**) | `[A]` | `A-T` | `KeplerHurwitz/PrimvierlingSymmetry.lean` | `E-046`, `E-025` | `E-032`, `E-048`, `E-026` | `hostComponentEquiv`; `mem_hostTriple_count = 3`; `unique_excluded_host`; Brücke zu `RespectsLabelFibers` / `LabelIntertwiningGraphAuto` | 0 `sorry`; `lake build KeplerHurwitz.PrimvierlingSymmetry` grün (2026-07-03) | bewiesen | `stable` | `2026-07-03` |
| `E-048` | Dumas-Lemma `Dumas_one_for_all_all_for_one`; `dumas_gap_encodes_host`, `holographic_omission_gap_encodes_host`, `hostTriple_membership_iff_not_host` (Lean **E-048**; Konsolidierung Lean-Label **E-034** / Register **E-047**) | `[A]` | `A-T` | `KeplerHurwitz/PrimvierlingSymmetry.lean` | `E-046`, `E-047`, Lean-**E-034** | `E-032`, `E-026` | `Dumas_one_for_all_all_for_one`, `dumasLemma`, `dumasLemma_hostComponent_bij`, `dumasLemma_otherChannels_card`; Gap kodiert Host | 0 `sorry`; `lake build KeplerHurwitz.PrimvierlingSymmetry` grün (2026-07-03) | bewiesen | `stable` | `2026-07-03` |
| `E-033` | Kepler-Zeit-Leiter: diskretes Delta-M-Linienspektrum auf Floquet-Attraktoren | `[B]` | `-` | `src/kepler_hurwitz/kepler_time_bridge.py`, `src/kepler_hurwitz/kepler_eabc_atlas.py`, `examples/run_kepler_time_bridge.py`, `examples/run_kepler_eabc_floquet_annotation.py`, `docs/plots/spectrum_*.dat`, `docs/reports/E033_FLOQUET_CHANNEL_ALIGNMENT.md` | `discrete_time_flow.simulate_physical_flow`, `tests/test_kepler_time_bridge.py`, `tests/test_kepler_eabc_atlas.py` | `-` | 500 Schritte, Tail=64, soft+ring2, 8 zyklische Operatoren; Floquet-Channel-Alignment [B/C] via `summarize_annotated_delta_m` | baseline `unique_dM=2`, `M_period=8`, Spektrum `±1.85619`; pi/2 `unique_dM=3`; Stoerung `unique_dM=1`; baseline max lift-sheet abs diff ≈3.71 | reproduzierbar | `stable` | `2026-07-03` |
| `E-034` | Riemann-Resonanz via `S(Delta_M)=mean cos(gamma*Delta_M)` — Schnittstellen-Kosinus-Mittelung | `[C]` | `-` | `src/kepler_hurwitz/riemann_resonance_checker.py`, `docs/energiedoku_exports/riemann_resonance.json` | `E-033`, `data/riemann_zeros_imag_f8.bin` (2_001_052 Nullstellen aus `zeros6.npy`) | `-` | volle Stichprobe N=2_001_052; pytest-Gesamtsuite 127 passed (1 skipped) | **Verdict: refuted.** `S(±1.85619)≈2.6e-7`, `var≈0.500`, nicht resonant; `S(0)=1.0` trivial (cos(0)); identisch zum Zufalls-Nullmodell; destruktive Interferenz, kein Baseline-Ueberhang | refuted | `stable` | `2026-07-03` |
| `E-035` | Riemann-Skalen-Interferenz via `S(x_0)=mean cos(gamma*log(a/a_0))` — Skalen-Kosinus-Mittelung | `[C]` | `-` | `src/kepler_hurwitz/riemann_resonance_checker.py`, `docs/energiedoku_exports/riemann_scale_resonance.json` | `E-033`, `E-034`, `phi`/`phi_inv` Skalenkomponente `x_0` | `-` | korrigierte explizite-Formel-Metrik; volle Stichprobe N=2_001_052 | **Verdict: open_hypothesis / experimental.** Tail-`x_0` in `{0,-0.5}`; `S(0)=1.0` trivial; `S(-0.5)≈-1.8e-6`, nicht resonant; negative Evidenz ohne statistisch signifikantes Signal — keine formale Widerlegung der strukturellen Kopplung | open_hypothesis | `experimental` | `2026-07-03` |
| `E-036` | Arithmetische Evolution via Hurwitz-Shell-Operatoren (Proxy N=4,6,8) | `[C]` | `-` | `src/kepler_hurwitz/arithmetic_evolution.py`, `examples/run_arithmetic_evolution.py`, `docs/energiedoku_exports/arithmetic_transition_matrix.json` | `E-033`, `discrete_time_flow.physical_step_filter` | `E-037` | Shell-Proxies 3/5/7; Uebergangsmatrix; periodic_recovery=12/12 | reproduzierbar | `experimental` | `2026-07-03` |
| `E-037` | Dyadische Metakommutation der 112 Norm-2-Integer-Wurzeln | `[C]` | `-` | `src/kepler_hurwitz/metacommutation.py`, `docs/energiedoku_exports/dyadic_metacommutation.json` | `E-036`, `discrete_time_flow.hurwitz_units_240` | `E-038`, `H3` | 112 dyadische Wurzeln x 240 Einheiten; P·U=U'·P' mit Norm-2-Partnern | resolved=26880/26880; dyadic/half-integer Partner-Anteile dokumentiert | reproduzierbar | `experimental` | `2026-07-03` |
| `E-038` | Fano-QEC-Brücke: GF(2)-Stabilisatormatrix, Syndrompartition, CSS-Projektion | `[B]` | `-` | `src/kepler_hurwitz/qec_bridge.py`, `docs/energiedoku_exports/qec_bridge.json`, `tests/test_qec_bridge.py` | `E-037`, `discrete_time_flow.fano_triples` | `E-039`, `H3` | 7 Fano-Linien; 112 dyadische Wurzeln; 26880 Metakommutations-Paare; CSS-Vergleich mit Steane-Referenz | GF(2)-Rang=4; Kern-Dim=3; Syndromklassen=4; Zeilenraum-Schnitt mit Steane H_X=1; Kern-Mindestgewicht=4 vs Steane-Distanz=3 | reproduzierbar | `experimental` | `2026-07-03` |
| `E-039` | E-039-pre: negativer Fano-Koset-Quotient-Test | `[C]` | `-` | `qec_bridge.py`, `fano_shell_cosets.json`, `tests/test_qec_bridge.py` | `E-037`, `E-038` | `E-040`, `H3` | σ₄=σ₈; σ₆ distinct; trennt N=6, nicht N=4/N=8 | e039_upgrade_eligible=false | reproduzierbar | `experimental` | `2026-07-03` |
| `E-040` | E-040-pre: verfeinerte Shell-Signaturen | `[C]` | `-` | `qec_bridge.py`, `refined_shell_projection.json` | `E-039` | `E-041`, `H3` | hurwitz_residue, signed_support, real_axis | alle drei trennen N=4/N=8; residue_key allein gleich | reproduzierbar | `experimental` | `2026-07-03` |
| `E-041` | Signierte Shell-Syndrome als kanonische Verfeinerung | `[B]` | `-` | `qec_bridge.py`, `signed_shell_syndromes.json`, `tests/test_qec_bridge.py` | `E-039`, `E-040`, `E-042` | `H3` | signed_support; validated_by E-042; E-039 unrevidiert | σ₄=σ₈ erhalten; paarweise Trennung N=4/6/8; 0 Fehler unter G | reproduzierbar | `experimental` | `2026-07-03` |
| `E-042` | Symmetrieinvarianz signed_support (Invarianzvalidator) | `[C]` | `-` | `qec_bridge.py`, `signed_support_symmetry.json`, `tests/test_qec_bridge.py` | `E-041` | `E-041`, `H3` | G=Aut(Fano_7)×Z₂^global imag sign; \|G_model\|=336 | Trennung unter allen g∈G; validiert E-041 [B] | reproduzierbar | `experimental` | `2026-07-03` |
| `E-043` | E-043-pre: Coupled Shell Resonance Graph (Keil A) | `[C]` | `-` | `coupled_shell_resonance.py`, `coupled_shell_resonance_graph.json`, `tests/test_coupled_shell_resonance.py` | `E-036`, `E-037`, `E-041`, `S8` | `H3` | gekoppelte N=4,6,8 auf 6 x0-Niveaus | Resonanzgraph; keine Gravitationsbehauptung | reproduzierbar | `experimental` | `2026-07-03` |
| `E-044` | [[5,1,3]]-Stabilisator-Brücke: 112 dyadische Wurzeln x 15 Pauli-Stabilisatoren | `[C]` | `-` | `qec_bridge.py`, `five_qubit_stabilizer_bridge.json`, `examples/run_qec_stabilizer_check.py`, `tests/test_five_qubit_stabilizer_bridge.py` | `E-037`, `E-038` | `E-045`, `H3` | symplektische Projektion der Norm-2-Wurzeln auf den 5-Qubit-Code | 1680 Paare; 15/15 Stabilisatoren kommutieren; Shell-Kommutationsquote entartet (7/15 fuer N=4/6/8); Trennung bleibt in E-037 associative_ratio | reproduzierbar | `experimental` | `2026-07-03` |
| `E-045` | E-045-pre: Signed [[5,1,3]] stabilizer support profile | `[C]` | `-` | `qec_bridge.py`, `signed_stabilizer_support_profile.json`, `examples/run_signed_stabilizer_support.py`, `tests/test_signed_stabilizer_support.py` | `E-044` | `H3` | v_N in {±1}^15; G_5-code vor Vergleich | Rohprofile verschieden; Orbitklassen gleich; e045_upgrade_eligible=false | reproduzierbar | `experimental` | `2026-07-03` |
| `E-049` | EABC/Floquet-Phasenverteilung fuer Zwillingprim-Kandidaten (n ≡ 11 mod 12) | `[B]` | `-` | `src/kepler_hurwitz/twin_prime_eabc_phase_analysis.py`, `examples/run_twin_prime_eabc_phase_analysis.py`, `docs/energiedoku_exports/twin_prime_eabc_phase_analysis.json`, `docs/energiedoku_exports/twin_prime_eabc_phase_analysis_report.md`, `tests/test_twin_prime_eabc_phase_analysis.py` | `E-033` | `-` | CE-Kandidaten n≡11 mod 12; Floquet-Phase via candidate_index mod 8; Small-Sieve-Baseline B=97, X=10^6; chi²-Uniformitaetstest 8 Phasen; explorative Best-Phase [C] | 9654 gesiebte Kandidaten, 4122 Zwillings-Treffer; chi²=2.63, p=0.917, Uniformitaet nicht verworfen; max enrichment 1.03 (Phase A, explorativ) | reproduzierbar | `experimental` | `2026-07-03` |
| `E-051` | Strukturierte Kontrollen fuer Zwillingprim-EABC-Analyse | `[B]` | `-` | `src/kepler_hurwitz/twin_prime_eabc_structured_controls.py`, `examples/run_twin_prime_eabc_structured_controls.py`, `docs/energiedoku_exports/twin_prime_eabc_structured_controls.json`, `docs/energiedoku_exports/twin_prime_eabc_structured_controls_report.md`, `tests/test_twin_prime_eabc_structured_controls.py` | `E-033`, `E-049`, `E-048` | `-` | Restklassen-stratifizierte CE/AB-Kontrollen; E-033 Orientierungsdualitaet; leakage-sichere Dumas-Rechtsfluegel-Features n+6/n+8; Nullmodelle innerhalb Restklasse | X=10^4: Stage-1 durch CE/AB erklaert; orientation_dual unter baseline_cyclic nicht diskriminatif; right_wing ohne stabiles Enrichment; **negativer Kontrollbefund** | negative structured-control result | `experimental` | `2026-07-03` |
| `E-052` | Skalen-Robustheitscheck fuer strukturierte Zwillingprim-Kontrollen | `[B]` | `-` | `src/kepler_hurwitz/twin_prime_eabc_scale_sweep.py`, `examples/run_twin_prime_eabc_scale_sweep.py`, `docs/energiedoku_exports/twin_prime_eabc_scale_sweep.json`, `docs/energiedoku_exports/twin_prime_eabc_scale_sweep_report.md`, `tests/test_twin_prime_eabc_scale_sweep.py` | `E-051` | `-` | Wiederholung E-051 ueber limits 10^4/10^5/10^6 und sieve_bounds 97/997; prueft Robustheit des negativen E-051-Befunds; keine neuen Features | 6 Zellen: orientation_dual delta=0; right_wing nicht skalenstabil; negativer E-051-Befund skalenrobust | descriptive scale robustness check | `experimental` | `2026-07-03` |

**Governance-Klarstellung:** Die Orbit-Smoothness-Bruecke dokumentiert formale Anschlussfaehigkeit zwischen Orbit- und Smoothness-Schicht; sie beweist keine Attraktorwirkung.

## Pflegehinweise

- Jede neue Schluesselaussage bekommt genau eine neue ID.
- Statusaenderungen werden nur gemaess Upgrade-Regeln vollzogen.
- Registereintraege sollen auf konkrete Dateien/Symbole verweisen.
- `Depends on` beschreibt die direkte Evidenzabhaengigkeit (gerichteter Graph).
- `Supports` beschreibt wissenschaftliche Relevanz (unterstuetzt), ohne Beweisimplikation.

### E-033 — Floquet channel alignment `[B/C]`

Reproducible numerical alignment diagnostics compare observed ΔM tails with the formal 2×4 χ-lift annotation. The report does not claim that ΔM values generate or determine the channel projection.

- **ID-Hinweis Musketiere vs. Energiedoku:** Die Lean-internen Labels **E-033/E-034** in `PrimvierlingSymmetry.lean` (Musketiere-Spur) entsprechen den Register-Eintraegen **E-046/E-047**. Die Register-IDs **E-033/E-034** bezeichnen weiterhin den Kepler-Zeit-/Riemann-Block.
- `[B]`-Eintraege dokumentieren immer Scope sowie Metrik/Ergebnis.
- `Stabilitaet` steuert Lebenszyklus (stable/experimental/deprecated/superseded).
- `Letzte Pruefung` wird bei jeder inhaltlichen Re-Validierung aktualisiert.

## Paper-Satzgruppen (Mapping)

Satzgruppen sind kondensierte Manuskript-Claims; sie ersetzen keine Evidenz-IDs, sondern fassen Register-Eintraege zusammen.

| Satzgruppe | Klasse | Evidenz-Basis | Status |
|---|---|---|---|
| S7 | `[B]` | E-038 | QEC-Grundstruktur (Steane-Abgrenzung) |
| S8 | `[B]` | E-039, E-040, E-041, E-042 | Signierte Fano-Shell-Trennung unter G_model |

**QEC-Block (Keil B):** E-038–E-042 + S8 eingefroren (2026-07-03). **Keil A-pre:** E-043. **Stabilizer-Erweiterung:** E-044 (structural interface, not physical identification).

### E-044 `[C]` — Five-qubit stabilizer bridge

**Claim.** The dyadic shell data admit a complete finite projection into the nontrivial stabilizer set of the standard `[[5,1,3]]` code.

**Validated facts.**

- 15 nonidentity stabilizers generated from four standard generators.
- Pairwise commutation verified.
- 1680 = 112 × 15 dyadic/stabilizer match pairs.
- 784/1680 = 7/15 positive commutation-sign pairs.
- 49 distinct symplectic root classes.

**Negative/defensive result.**

The projection does not separate the shell proxies N=4, N=6, N=8 by commutation quota; all remain at 7/15. Empirical separation remains in E-037 (`associative_ratio`: 1.0 vs 0.767).

**Status.** `[C]` structural interface, not a physical identification theorem.

**Prospective follow-up (E-045):** signed stabilizer support profile within the `[[5,1,3]]` projection when the scalar quota stays degenerate.

### E-045-pre `[C]` — Signed [[5,1,3]] stabilizer support profile

**Claim.** Test whether scalar E-044 degeneration (#(+1)=7/15) persists in full signed profiles \(v_N \in \{\pm1\}^{15}\), and whether orbit classes under \(G_{\mathrm{5-code}}\) (|G|=20) separate N=4,6,8.

**Validated facts.**

- 15 stabilizers; positive count 7/15 for all shells (E-044 preserved).
- Raw profiles pairwise distinct.
- Canonical orbit representatives **identical** under pre-defined \(G_{\mathrm{5-code}}\).

**Negative/defensive result.**

Signed stabilizer orbit classes do **not** separate N=4,6,8; `e045_upgrade_eligible=false`. Separation remains in E-037.

**Status.** `[C]` structural test, not a classification theorem.
