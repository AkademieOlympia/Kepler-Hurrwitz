# Theory — Master Index

Theorie-Dokumente und didaktische Modellbrücken des Kepler-Hurrwitz-Programms.

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
