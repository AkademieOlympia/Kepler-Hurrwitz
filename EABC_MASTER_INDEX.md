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

- HoTT Identity Layer (konzeptionelles Interface / Grundlagenhypothese) **[C]**
  - **[C] Formal:** `KeplerHurwitz/HoTTIdentityLayer.lean` (`E-073`: `HoTT_EABC_Interface` mit `PathWitness`/`migration_path` als Pfadzeuge-Hypothese, Ideal-Univalenz als Hypothesenfeld, `DH_Quat`-Modellskizze, `period_equiv_zmod12` als Fundamentalperioden-Modellierung)
  - **Basis:** E-067–E-069 (Dedekind-Ideal-Schicht), E-053 (Dedekind–Hasse), E-072 (mod-12-Kanalpartition)
  - **Dossier:** `docs/hott_identity_layer.md`
  - **Governance:** Anschlussraum, kein Ersatz E-067–E-069; Lean 4 ≠ HoTT/Univalenz; `migration_path` = Pfadzeuge (stärkster Kern, kein abgeleiteter HoTT-Satz); `period_equiv_zmod12` ≠ π₁ ≃ Z/12Z; beweist nicht EABC
  - **Externe Referenzen (Referenzrahmen):** HoTT Book, Coq-HoTT, Lean 2 HoTT, nLab (Lean, Univalenz, HITs) — siehe `docs/hott_identity_layer.md`
