# Freeze `eabc-functional-info-v0.1` — EABC ↔ Wong Functional Information

**Identifier:** `eabc-functional-info-v0.1`  
**Evidence / ORQ:** E-112 / ORQ-112  
**Klassifikation:** methodischer Snapshot `[A]`+`[B/C]` Spezifikation — **kein** Physik-Claim-Freeze  
**Eingefroren:** 2026-07-26  
**Tests:** `pytest tests/test_prime_tower_bridge.py` → **13 passed** (Claim-Wall-Seal 2026-07-22: 11/11; Guard-Tests ergänzt)  
**Protokoll (Claim-Wall):** [`eabc_wong_functional_information_bridge.md`](../energiedoku_exports/eabc_wong_functional_information_bridge.md)  
**Manifest:** [`eabc_wong_functional_info_v0.1_freeze.json`](../exports/eabc_wong_functional_info_v0.1_freeze.json)

> **Hinweis PROTOCOL.md:** Für E-112 gibt es kein separates `PROTOCOL.md`. Die Claim-Grenze, die der Nutzer als „PROTOCOL.md“ meint, ist die versiegelte Claim-Wall in der Energiedoku-Brücke oben.

---

## Freeze-Eintrag

| Kategorie | Status / Spezifikation |
|---|---|
| **Milestone** | `eabc-functional-info-v0.1` |
| **Spezifikation** | `CLOSED & ACTIVE` (methodische Schicht) |
| **Physical claim freeze** | **not granted** |
| **Snapshot freeze** | granted (Dokumentations-/Audit-Stand v0.1) |
| **Claim-Wall sealed** | 2026-07-22 |
| **Branch** | `post-freeze/octonionic-collatz-proof-attempt` |
| **HEAD `commit_sha`** | `f8d0a087a69520b8ff796e3a7ef4fafe0b1ff159` |
| **Working tree** | **dirty** — Freeze-Cluster teils untracked/modified; Tag deferred |

---

## Eingefrorener Cluster

- `docs/energiedoku_exports/eabc_wong_functional_information_bridge.md`
- `src/kepler_hurwitz/prime_tower_bridge.py` (`Q0_UNIFORM`, `functional_information_bits`)
- `tests/test_prime_tower_bridge.py`
- Register / ORQ: `EVIDENCE_REGISTER.md`, `EVIDENCE_REGISTER.json`, `docs/open_research_questions.md` (ORQ-112)

---

## Claim-Wall (unverändert)

1. **[A]** Partition \(\Omega=E\cup A\cup B\cup C\); Zwei-Quadrate für ungerade Primzahlen \(\Leftrightarrow\) E∪A.  
2. **[B/C]** Modellgröße \(I_{Q_0}=-\log_2 F\) unter \(Q_0=\tfrac14\): 1 Bit (E∪A) / 2 Bit (nur E).  
3. **[C]** ORQ-112 offen — kein Optimalitätsclaim; Physik-Freeze not granted.  
4. **[D]** Wong-Ordnungen = Lesesprache.

---

## v0.2-Fahrplan (Spezifikation only — **nicht** implementiert)

| Feld | Wert |
|---|---|
| Status | **pending / not started** |
| Prerequisite | Freeze v0.1 |
| Fokus | TUR für \(BC\)-Ströme |

1. **Strom \(J_{BC}\):** gerichteter Netto-Fluss aus Übergangsraten \(B\leftrightarrow C\).  
2. **TUR:** \(\mathcal{Q}=\sigma_{J_{BC}}^2/\langle J_{BC}\rangle^2 \ge 2/S_{BC}\).  
3. **Tests:** Parameter-Sweeps \((\theta,\varphi)\).

Kein TUR-Code in diesem Freeze. Kein Physik-Export der TUR-Ungleichung.

---

## Explizit nicht getan

- kein TUR-/v0.2-Code  
- kein `git commit` / kein `git push`  
- kein Release-Tag solange Working Tree dirty (Freeze-Inhalte nicht in `commit_sha`)  
- physical claim freeze bleibt **not granted**
