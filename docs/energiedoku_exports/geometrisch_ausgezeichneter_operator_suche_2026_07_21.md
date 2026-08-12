---
title: Suche — geometrisch ausgezeichneter Operator (explorativ)
date: 2026-07-21
status: >-
  Versiegelte Forschungsstance / Non-Freeze. Keine Uniqueness bewiesen.
  „Geometrisch ausgezeichnete Operatorwahl bleibt offen“ bleibt gültig [C].
governance: >-
  [C] Suchnotiz; zitierte Teilkerne behalten ihren eigenen [A]/[B]/[C]-Status.
  Kein Collatz-Beweis; kein Freeze der Operatorwahl; keine Teleologie.
claim_boundary: >-
  Absorptionsdiagnostik ist strukturell bevorzugt, aber nicht als universeller
  Operator auf ℕ ausgezeichnet. Ranking = Forschungspriorität, nicht Theorem.
not_claimed:
  - Einzigartiger Collatz-/Syracuse-Operator geometrisch bewiesen
  - Freeze der Operatorwahl
  - Identifikation R* ≡ BoolTrace-Monoid ≡ M_w ≡ Φ_θ
  - Jede relevante Syracuse-Bahn ⇒ Einheitsdefektwort
  - BoolTrace(P)=0 ⇒ archimedischer Abstieg
  - Collatz bewiesen
  - Teleologische Notwendigkeit eines Operators
  - PR #8 als Typentrennungs-/Tensorchirurgie-Beweis
---

# Geometrisch ausgezeichneter Operator — Explorationssuche (2026-07-21)

**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku — explorative Suche (**kein** Freeze)  
**Collatz?** **NEIN** · **Teleologie?** **NEIN** · **Uniqueness?** **NEIN**

---

## 0. PR-#8-Korrektur (verbindlich)

\[
\boxed{
\begin{aligned}
&\textbf{PR \#8 ist nicht} \text{ der formale Beweis der Typentrennung }
E_\Delta\neq E_{\mathrm{vol}}.\\
&\textbf{PR \#8 =}\ \text{Renormierungs-/Energiedoku-Export + Primvierling-Daten}\\
&\quad\text{(}eabc\_renormalisierungsprogramm.md,\ primvierling\_norm\_height.csv,\ Export-Skript\text{).}\\
&\textbf{Nicht} \text{ Inhalt von PR \#8: Typentrennung, Tensorchirurgie,}\\
&\quad\text{Semiprime24Bridge-Verifikation.}
\end{aligned}
}
\]

Verifiziert: [PR #8](https://github.com/AkademieOlympia/Kepler-Hurrwitz/pull/8) — Titel *Add energiedoku renormalization program exports and Primvierling data*.

---

## 1. Forschungskette

\[
\text{Absorptionsalgebra }[A]
\;\longrightarrow\;
\text{endliche wrap-bewusste Diagnostik }[B]
\;\longrightarrow\;
\text{Operatorwahl auf }\mathbb N\ [C]
\]

| Stufe | Inhalt | Status |
|---|---|---|
| **[A]** | Absorptionsmonoid \(\{E_{00},E_{01},Z\}\); \(E_{01}\odot E_{00}=Z\); BoolTrace-Rotationsinvarianz | Lean-Kern |
| **[B]** | Wrap-bewusste Fensterdiagnostik; \(\Phi_k^{\mathrm{ref}}\); Fokus-Wörter; \(P=\bigodot_j M_j\) | Audit / Export |
| **[C]** | Geometrisch ausgezeichneter Operator auf \(\mathbb N\) / Syracuse; archimedischer Abstieg | **offen** |

---

## 2. Bindende Primärdiagnose-Linie

\[
\Phi_k^{\mathrm{ref}}
\;\longmapsto\;
(M_0,\ldots,M_{\ell-1})
\;\longmapsto\;
P=\bigodot_j M_j
\;\longmapsto\;
\mathrm{BoolTrace}(P)
\]

**Stärken (auf geprüften Fokusstrukturen):**

- \(E_{01}\odot E_{00}=Z\)
- \(\kappa_{\mathrm{loc}}=a_{\mathrm{abs}}=2\)
- \(\delta_{\mathrm{coh}}=1\)
- zyklische Basispunktunabhängigkeit (\(\mathrm{BoolTrace}\) rotationsinvariant)

\[
\boxed{
P\text{ ist scharfe Obstruktionsdiagnose für endliche modulare Liftstrukturen —}
\textbf{ nicht}\text{ geometrisch ausgezeichneter Operator auf }\mathbb N.
}
\]

---

## 3. Präziser Claim-Rand

| | Aussage |
|---|---|
| **Bewiesen** | \(W\sim_{\mathrm{cyc}} E_{00}^{\ell-1}E_{01}\ \Rightarrow\ P_j\in\{E_{01},Z\}\ \Rightarrow\ \mathrm{BoolTrace}(P_j)=0\) |
| **Nicht bewiesen** | jede relevante Syracuse-Bahn \(\Rightarrow\) dieses Wortmuster |
| **Nicht bewiesen** | \(\mathrm{BoolTrace}(P)=0\ \Rightarrow\) archimedischer Abstieg |

Die beiden fehlenden Pfeile bilden die **[C]-Grenze**.

---

## 4. Operator-Ranking (Forschungspriorität, kein Theorem)

| # | Kandidat | Rolle | Warum nicht „der“ Operator auf \(\mathbb N\) |
|---|---|---|---|
| **1** | Absorption + \(\mathrm{BoolTrace}\) | stärkste strukturelle Diagnose | endliche Lift-/Relationsdiagnose ≠ kanonische Syracuse-Dynamik |
| **2** | \(\Phi_k^{\mathrm{ref}}\) | wrap-aware Alphabetbrücke | Klassifikator im Fenster `[B]`; \(\forall k\) offen |
| **3** | Doob–Perron / \(M_w\) | asymptotische Spektralform | klassisch ausgezeichnet *gegeben* Gewichte — **nicht** kanonisch aus EABC-Geometrie |
| **4** | \(C_4+\Phi_\theta\) | Phasen-/Typwort-Symmetrie | modular erzwungen nach Fixierung von \(\mathcal S\); Konvention bleibt |
| **5** | \(R^*\) | Retraktion / isotrope Zielklasse | Restauration der Zielklasse; **keine** Notwendigkeit / Uniqueness der Dynamik |

Detailkurzprofile:

### #1 — Absorption + \(\mathrm{BoolTrace}\)

| | |
|---|---|
| **Definition** | Alphabet \(\{E_{00},E_{01},Z\}\); zyklisches Produkt \(P_j\); \(\mathrm{BoolTrace}(P_j)\). Einheitsdefekt \(\sim_{\mathrm{cyc}} E_{00}^{\ell-1}E_{01}\) ⇒ \(\delta_{\mathrm{coh}}=1\), \(\kappa_{\mathrm{loc}}=a_{\mathrm{abs}}=2\). |
| **Repo** | Lean: `KeplerHurwitz/EABC/BooleanRelationAbsorption.lean`, `FocusCycleUnitDefect.lean` · Python/Export: `eabc_boolean_absorption*` · Theorie: `docs/eabc_collatz_audit_grid.md` §5.18–5.22 |
| **Blockiert Uniqueness** | Relations-/Monodromie-Operator auf endlichen Liftgraphen ≠ kanonischer Syracuse-Operator auf \(\mathbb N\). |

### #2 — \(\Phi_k^{\mathrm{ref}}\)

| | |
|---|---|
| **Definition** | Wrap\(\wedge\nu_2=1\mapsto E_{01}\); sonst \(E_{00}\) bzw. \(Z\) bei \(\nu_2\ge k\). |
| **Repo** | Lean: `SyracuseRelationClassifierPhi.lean` · Energiedoku `eabc_relation_classifier_phi_k_2026_07_21.md` · Audit-Grid §5.22 |
| **Blockiert Uniqueness** | Klassifikator; Fokus \(k\in[10,14]\) als `[B]`; \(\forall k\) offen. |

### #3 — Doob–Perron / \(M_w\)

| | |
|---|---|
| **Definition** | Shift-Transfer mit Collatz-Gewichten; Perron-Zeuge; Doob-Kernel. |
| **Repo** | `KeplerHurwitz/Collatz/ResonanzOperator.lean` · Exporte `h7_shift_*`, `doob_data_L8_C8.json` |
| **Blockiert Uniqueness** | Asymptotisch nützlich; Gewichte und \((L,C)\) bleiben `[C]` für geometrische Kanonizität. |

### #4 — \(C_4\) + \(\Phi_\theta\)

| | |
|---|---|
| **Definition** | \(\mathcal S=(11,1,5,7)\); Typmap inert/zerfallend; reguläre Kanäle phasenverschoben um \(\pi\). |
| **Repo** | `docs/theory/primvierling_c4_rotation.md` · Seal `eabc_inert_c4_phase_shift_2026_07_17.md` |
| **Blockiert Uniqueness** | Ordnung von \(\mathcal S\) nach Fixierung wohldefiniert, nicht ohne Konvention aus größerer Gruppe erzwungen. |

### #5 — Retraktion \(R^*\)

| | |
|---|---|
| **Definition** | \(M_{\mathrm{eff}}(K^+)=24I_3+w_p vv^T\) → \(M_{\mathrm{eff}}(R^*(K^+))=24I_3\); isotrop \(\Leftrightarrow\Delta(M)=0\). |
| **Repo** | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` (**PR #8:** Energiedoku-Export / Primvierling-Daten — **nicht** Typentrennung) |
| **Blockiert Uniqueness** | Zielklasse / Restauration; keine Dynamik-Notwendigkeit; keine Uniqueness. |

---

## 5. Warum Absorption strukturell führt (kein Unique-Claim)

1. **Graphentheoretische Unvermeidlichkeit des Alphabets auf Lifts.**  
   Auf den geprüften Lift-/Fokusgraphen erzwingen Wrap- und Cut-Struktur die Relationslabels \(\{E_{00},E_{01},Z\}\). Das zeichnet das Absorptionsalphabet als Diagnosekern aus — **nicht** einen Operator auf ganz \(\mathbb N\).

2. **Kombinatorische Minimalität \(\kappa_{\mathrm{loc}}=2\).**  
   Lokale Absorption \(E_{01}\odot E_{00}=Z\) ist die kürzeste nichttriviale Kollapslänge (\(a_{\mathrm{abs}}=2\)); globaler Einheitsdefekt \(\delta_{\mathrm{coh}}=1\) auf dem Muster — weiterhin **kein** Uniqueness-Satz für Syracuse.

3. **BoolTrace-Rotationsinvarianz.**  
   \(\mathrm{BoolTrace}\) hängt nur von der zyklischen Konjugationsklasse ab — diagnostisch robust, teleologisch irrelevant.

---

## 6. Statusbaum

```
[A] Verifizierter Kern (Lean 4)
    ├── Absorptions-Lemma E₀₁ ⊙ E₀₀ = Z
    ├── BoolTrace-Rotationsinvarianz
    └── Alphabet-Trennung E₀₀ ≠ E₀₁ (≠ Z)
          — Lean-Fakt im Absorptionsmonoid;
            nicht „Typentrennung E_Δ ≠ E_vol“ und nicht Inhalt von PR #8

[B] Endliche wrap-bewusste Diagnostik
    └── Φ_k^ref ↦ (M_j) ↦ P=⊙ M_j ↦ BoolTrace(P)
    └── κ_loc=2, δ_coh=1 auf geprüften Fokus-Zyklen

[C] Open Non-Claim (zwei fehlende Pfeile)
    └── nicht bewiesen: relevante Syracuse-Bahn ⇒ Einheitsdefektwort
    └── nicht bewiesen: BoolTrace(P)=0 ⇒ archimedischer Abstieg
    └── Operatorwahl auf ℕ bleibt offen
```

---

## 7. Explizite Non-Claims

| Frage | Antwort |
|---|---|
| Ist ein Operator geometrisch unique bewiesen? | **Nein** |
| Ist \(P\) geometrisch ausgezeichnet auf \(\mathbb N\)? | **Nein** — scharfe endliche Obstruktionsdiagnose |
| Schließt diese Suche den Non-Claim? | **Nein** — **Wahl bleibt offen [C]** |
| Collatz? | **Nein** |
| Teleologie / „muss dieser Operator sein“? | **Nein** |
| Freeze? | **Nein** — explorativ |
| Ist PR #8 der Typentrennungsbeweis? | **Nein** — nur Renormierungs-/Primvierling-Export |

---

## 8. Schlussbox

\[
\boxed{
\text{Absorptionsdiagnostik strukturell bevorzugt,}
\text{ aber nicht als universeller Operator auf }\mathbb N\text{ ausgezeichnet.}
}
\]

**Empfehlung (Forschungspriorität):** #1+#2 als Diagnoseachse; #3 als asymptotischer Vergleich unter `[C]`; #4/#5 als Symmetrie- bzw. Restaurationskontext.  
**Nicht behauptet:** damit wäre die Operatorwahl geschlossen · Collatz · Teleologie · Uniqueness.
