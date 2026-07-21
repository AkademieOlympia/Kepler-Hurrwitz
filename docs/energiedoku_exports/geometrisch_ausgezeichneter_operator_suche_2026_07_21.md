---
title: Suche — geometrisch ausgezeichneter Operator (explorativ)
date: 2026-07-21
status: >-
  Explorative Suche / Non-Freeze. Keine Uniqueness bewiesen.
  „Geometrisch ausgezeichnete Operatorwahl bleibt offen“ bleibt gültig [C].
governance: >-
  [C] Suchnotiz; zitierte Teilkerne behalten ihren eigenen [A]/[B]/[C]-Status.
  Kein Collatz-Beweis; kein Freeze der Operatorwahl; keine Teleologie.
claim_boundary: >-
  Diese Datei schließt die offene Operatorwahl nicht.
  Ranking = Forschungspriorität, nicht Theorem.
not_claimed:
  - Einzigartiger Collatz-/Syracuse-Operator geometrisch bewiesen
  - Freeze der Operatorwahl
  - Identifikation R* ≡ BoolTrace-Monoid ≡ M_w ≡ Φ_θ
  - Collatz bewiesen
  - Teleologische Notwendigkeit eines Operators
---

# Geometrisch ausgezeichneter Operator — Explorationssuche (2026-07-21)

**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku — explorative Suche (**kein** Freeze)  
**Collatz?** **NEIN** · **Teleologie?** **NEIN**

\[
\boxed{
\text{Wahl bleibt offen [C]}
\;\big|\;
\text{Absorption+BoolTrace = stärkster [A]/[B]-Diagnose-Kandidat, nicht Unique}
}
\]

**Kontext:** Versiegelter Non-Claim: *geometrisch ausgezeichnete Operatorwahl bleibt offen*.  
Diese Notiz **sucht** und **rangiert** Kandidaten; sie **hebt** den Non-Claim **nicht** auf.

**Kriterium „geometrisch ausgezeichnet“ (Arbeitsdefinition):** durch Geometrie/Symmetrie stark gepickt — z. B. Fixpunkt / Eigenvektor / invariantes Funktional / Paralleltransport / \(\Phi_k\)- oder \(C_4\)-Phasenstruktur — nicht nur Konvention. **Nicht** behauptet: eindeutige Pick auf \(\mathbb N\)/Syracuse.

---

## 1. Vergleichstafel — fünf Kandidaten

| # | Kandidat | Epistemischer Schwerpunkt | Kurzrolle |
|---|---|---|---|
| **1** | Absorption + \(\mathrm{BoolTrace}\) (\(P=\bigodot_j M_j\)) | **stärkster [A]/[B]-Diagnose-Kandidat** | Frozen Lift-Kern; extremale Invarianten; Primärfokus der Suche |
| **2** | Retraktion \(R^*\mapsto 24I_3\) | geometrisches **Ziel** / isotrope Fixpunktklasse | Zeichnet Zielklasse aus, nicht die Syracuse-Dynamik |
| **3** | \(C_4+\Phi_\theta\) | Phasen-/Typwort-Symmetrie auf Primvierlingen | Modular erzwungen nach Fixierung von \(\mathcal S\); Konvention bleibt |
| **4** | \(\Phi_k^{\mathrm{ref}}\) | Wrap-aware Kantenklassifikator → Alphabet | Brücke Fokus-Wörter ↔ Einheitsdefekt; Fenster `[B]` |
| **5** | Doob–Perron / \(M_w\) (H7) | spektrale Normalform; **[C] für Kanonizität** | Perron/Doob klassisch ausgezeichnet; Gewichte/Schnitte nicht aus EABC-Geometrie forciert |

Detailkurzprofile:

### #1 — Absorption + \(\mathrm{BoolTrace}\)

| | |
|---|---|
| **Definition** | Alphabet \(\{E_{00},E_{01},Z\}\); zyklisches Produkt \(P_j\); \(\mathrm{BoolTrace}(P_j)\). Einheitsdefekt \(\sim_{\mathrm{cyc}} E_{00}^{\ell-1}E_{01}\) ⇒ \(\delta_{\mathrm{coh}}=1\), \(\kappa_{\mathrm{loc}}=a_{\mathrm{abs}}=2\). |
| **Repo** | Lean: `KeplerHurwitz/EABC/BooleanRelationAbsorption.lean`, `FocusCycleUnitDefect.lean` · Python/Export: `eabc_boolean_absorption*` · Theorie: `docs/eabc_collatz_audit_grid.md` §5.18–5.20 |
| **Blockiert Uniqueness** | Relations-/Monodromie-Operator auf endlichen Liftgraphen ≠ kanonischer Syracuse-Operator auf \(\mathbb N\). |

### #2 — Retraktion \(R^*\)

| | |
|---|---|
| **Definition** | \(M_{\mathrm{eff}}(K^+)=24I_3+w_p vv^T\) → \(M_{\mathrm{eff}}(R^*(K^+))=24I_3\); isotrop \(\Leftrightarrow\Delta(M)=0\). |
| **Repo** | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` (PR #8: Energiedoku-Export; **nicht** Typentrennung \(E_\Delta\neq E_{\mathrm{vol}}\)) |
| **Blockiert Uniqueness** | Zielklasse, keine Dynamik `oddCoreStep` / Transfer \(M_w\). |

### #3 — \(C_4\) + \(\Phi_\theta\)

| | |
|---|---|
| **Definition** | \(\mathcal S=(11,1,5,7)\); Typmap inert/zerfallend; reguläre Kanäle phasenverschoben um \(\pi\). |
| **Repo** | `docs/theory/primvierling_c4_rotation.md` · Seal `eabc_inert_c4_phase_shift_2026_07_17.md` |
| **Blockiert Uniqueness** | Ordnung von \(\mathcal S\) nach Fixierung wohldefiniert, nicht ohne Konvention aus größerer Gruppe erzwungen. |

### #4 — \(\Phi_k^{\mathrm{ref}}\)

| | |
|---|---|
| **Definition** | Wrap\(\wedge\nu_2=1\mapsto E_{01}\); sonst \(E_{00}\) bzw. \(Z\) bei \(\nu_2\ge k\). |
| **Repo** | Lean: `SyracuseRelationClassifierPhi.lean` · Energiedoku `eabc_relation_classifier_phi_k_2026_07_21.md` |
| **Blockiert Uniqueness** | Klassifikator; Fokus \(k\in[10,14]\) als `[B]`; \(\forall k\) offen. |

### #5 — Doob–Perron / \(M_w\)

| | |
|---|---|
| **Definition** | Shift-Transfer mit Collatz-Gewichten; Perron-Zeuge; Doob-Kernel. |
| **Repo** | `KeplerHurwitz/Collatz/ResonanzOperator.lean` · Exporte `h7_shift_*`, `doob_data_L8_C8.json` |
| **Blockiert Uniqueness** | Spektral kanonisch *gegeben* Irreduzibilität/Gewichte — Gewichte und \((L,C)\) bleiben `[C]` für geometrische Kanonizität. |

---

## 2. Warum Absorption weiterhin führt (drei Gründe, kein Unique-Claim)

1. **Graphentheoretische Unvermeidlichkeit des Alphabets auf Lifts.**  
   Auf den geprüften Lift-/Fokusgraphen erzwingen Wrap- und Cut-Struktur die Relationslabels \(\{E_{00},E_{01},Z\}\); Coxeter/Flip-Lesarten sind verworfen. Das zeichnet das Absorptionsalphabet als Diagnosekern aus — **nicht** einen Operator auf ganz \(\mathbb N\).

2. **Kombinatorische Minimalität \(\kappa_{\mathrm{loc}}=2\).**  
   Lokale Absorption \(E_{01}\odot E_{00}=Z\) ist die kürzeste nichttriviale Kollapslänge im Monoid (\(a_{\mathrm{abs}}=2\)); globaler Einheitsdefekt \(\delta_{\mathrm{coh}}=1\) auf dem Muster. Extremal im CSP-Sinn, ohne freien Parameter — weiterhin **kein** Uniqueness-Satz für Syracuse.

3. **BoolTrace-Rotationsinvarianz.**  
   \(\mathrm{BoolTrace}\) hängt nur von der zyklischen Konjugationsklasse ab (Lean: Rotationsinvarianz des Listenprodukts). Das macht die Observable basispunktfrei — diagnostisch robust, teleologisch irrelevant.

**Primärkopplung (Arbeitsfokus):** \(P=\bigodot_j M_j\) an \(\Phi_k^{\mathrm{ref}}\) — Ranking, kein Freeze.

---

## 3. Statusbaum

```
[A] Verifizierter Kern (Lean 4)
    ├── Absorptions-Lemma E₀₁ ⊙ E₀₀ = Z
    │     (BooleanRelationAbsorption: E01_mul_E00 / E01_E00_absorbs)
    ├── BoolTrace-Rotationsinvarianz
    │     (boolTrace_listProduct_rotate_iterate)
    └── Alphabet-Trennung E₀₀ ≠ E₀₁ (≠ Z)
          — Lean-Fakt im Absorptionsmonoid;
            nicht „Typentrennung E_Δ ≠ E_vol“ und nicht Inhalt von PR #8
            (PR #8 = Renormierungs-Energiedoku-Export / Primvierling-Daten)

[B] Diagnostischer Primärkandidat
    └── P = ⨀ M_j gekoppelt an Φ_k^ref
    └── κ_loc=2, δ_coh=1 auf geprüften Fokus-Zyklen k∈[10,14]

[C] Open Non-Claim
    └── Geometrische Uniqueness keines Operators auf ℕ/Syracuse bewiesen
    └── Operatorwahl bleibt offene Forschungsfrage
```

---

## 4. Explizite Non-Claims

| Frage | Antwort |
|---|---|
| Ist ein Operator geometrisch unique bewiesen? | **Nein** |
| Schließt diese Suche den Non-Claim? | **Nein** — **Wahl bleibt offen [C]** |
| Collatz? | **Nein** |
| Teleologie / „muss dieser Operator sein“? | **Nein** |
| Freeze? | **Nein** — explorativ |

**Empfehlung (Forschungspriorität):** weiter #1+#4 als Diagnoseachse; #2 parallel als isotrope Zielklasse; #5 nur als spektrale Vergleichsform unter `[C]`-Kanonizität.  
**Nicht behauptet:** damit wäre die Operatorwahl geschlossen.
