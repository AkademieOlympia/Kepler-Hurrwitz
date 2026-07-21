---
title: Suche — geometrisch ausgezeichneter Operator (explorativ)
date: 2026-07-21
status: >-
  Explorative Suche / Non-Freeze. Keine Uniqueness bewiesen.
  „Geometrisch ausgezeichnete Operatorwahl bleibt offen“ bleibt gültig [C].
governance: >-
  [C] Suchnotiz; zitierte Teilkerne behalten ihren eigenen [A]/[B]/[C]-Status.
  Kein Collatz-Beweis; kein Freeze der Operatorwahl.
claim_boundary: >-
  Diese Datei schließt die offene Operatorwahl nicht.
  Ranking = Forschungspriorität, nicht Theorem.
not_claimed:
  - Einzigartiger Collatz-/Syracuse-Operator geometrisch bewiesen
  - Freeze der Operatorwahl
  - Identifikation R* ≡ BoolTrace-Monoid ≡ M_w ≡ Φ_θ
  - Collatz bewiesen
---

# Geometrisch ausgezeichneter Operator — Explorationssuche (2026-07-21)

**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku — explorative Suche (**kein** Freeze)  
**Collatz?** **NEIN**

\[
\boxed{
\text{Wahl bleibt offen [C]}
\;\big|\;
\text{Shortlist priorisiert Diagnose, nicht Claim}
}
\]

**Kontext:** Versiegelter Non-Claim: *geometrisch ausgezeichnete Operatorwahl bleibt offen*.  
Diese Notiz **sucht** Kandidaten; sie **hebt** den Non-Claim **nicht** auf.

**Kriterium „geometrisch ausgezeichnet“ (Arbeitsdefinition):** durch Geometrie/Symmetrie eindeutig gepickt — z. B. eindeutiger Fixpunkt / Eigenvektor / invariantes Funktional-Extremum / natürliche Paralleltransport-Induktion / Zwang durch \(\Phi_k\)- oder \(C_4\)-Phasenstruktur — nicht nur Konvention.

---

## 1. Ranked Shortlist (2–5)

### #1 — Lift-Monodromie / Absorptionsprodukt \(P=\bigodot_j M_j\) + \(\mathrm{BoolTrace}\)

| | |
|---|---|
| **Definition** | Kantenrelationen im Alphabet \(\{E_{00},E_{01},Z\}\); zyklisches OR-AND-Produkt \(P_j\); Observable \(\mathrm{BoolTrace}(P_j)\). Einheitsdefekt-Wörter \(\sim_{\mathrm{cyc}} E_{00}^{\ell-1}E_{01}\) ⇒ \(\delta_{\mathrm{coh}}=1\), \(\kappa_{\mathrm{loc}}=a_{\mathrm{abs}}=2\). |
| **Repo** | Theorie: `docs/eabc_collatz_audit_grid.md` §5.18–5.20 · Python: `src/kepler_hurwitz/eabc_boolean_absorption.py` · Lean: `KeplerHurwitz/EABC/BooleanRelationAbsorption.lean`, `FocusCycleUnitDefect.lean` · Export: `docs/exports/eabc_boolean_absorption_monoid_report.json` |
| **Warum ausgezeichnet?** | Unter Lift-CSP-Kandidaten: Coxeter/Flip **verworfen**; Absorption ist der frozen Kern. \(\mathrm{BoolTrace}\) rotationsinvariant (Konjugationsklasse). Extremal: minimale lokale Absorptionslänge 2, globaler Defekt 1 — kein freier Parameter. |
| **Blockiert Uniqueness** | Wählt einen **Relations-/Monodromie-Operator** auf endlichen Liftgraphen, nicht eindeutig einen Syracuse-Operator auf \(\mathbb N\). Kopplung an \(F_k\) nur via Muster-Hypothese + `[B]`-Zeugen; kein \(\forall k\). |
| **Status** | **[A]** Lean-Monoid/Defekt · **[B]** Fokus-Exporte · **[C]** „das ist *der* geometrische Collatz-Operator“ |

### #2 — Retraktion \(R^*\) auf isotropen Fixpunkt \(M_{\mathrm{geom}}=24I_3\)

| | |
|---|---|
| **Definition** | \(M_{\mathrm{eff}}(K^+)=24I_3+w_p vv^T\); nach \(R^*\): \(M_{\mathrm{eff}}(R^*(K^+))=24I_3\). \(\Delta(M)=\lambda_{\max}-\lambda_{\min}\); isotrop \(\Leftrightarrow\Delta=0\). |
| **Repo** | `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` (explizit: „geometrisch ausgezeichnete Fixpunktklasse“) · Lean-Marker u. a. `DedekindHasseProofAttempt.lean` · komplementär ORQ-099: `docs/theory/anisotropic_binary_volume_contraction.md` |
| **Warum ausgezeichnet?** | Eindeutige isotrope Zielklasse im Tensorraum (\(\Delta=0\)); Rang-1-Defekt wird auf Fixpunktklasse zurückprojiziert — stärkste im Repo **explizit so benannte** geometrische Auszeichnung. |
| **Blockiert Uniqueness** | Zeichnet ein **geometrisches Ziel** / eine Retraktion aus, nicht die Dynamik `oddCoreStep` / Transfer \(M_w\). Welche konkrete \(R^*\)-Realisierung kanonisch ist, bleibt an Ideal-/Dedekind-Brücken `[C]` gekoppelt. |
| **Status** | **[A]**/**[B]** Renorm-Kern · **[C]** Operatorwahl für Syracuse/Collatz |

### #3 — \(C_4\)-Generator \(\mathrm{Rot}_{+1}\) + Typmap \(\Phi_\theta\)

| | |
|---|---|
| **Definition** | Zustandsraum \(\mathcal S=(11,1,5,7)\); \(\varphi\mapsto\theta=\varphi\cdot\pi/2\); \(\Phi_\theta(0)=\Phi_\theta(3\pi/2)=\mathrm{inert}\), \(\Phi_\theta(\pi/2)=\Phi_\theta(\pi)=\mathrm{zerfallend}\). Reguläre Primvierlinge: invariantes Übergangswort \((+1,+1,+1)\); Kanäle um \(\pi\) phasenverschoben. |
| **Repo** | `docs/theory/primvierling_c4_rotation.md` · `src/kepler_hurwitz/primvierling_c4_rotation.py` · Seal: `docs/energiedoku_exports/eabc_inert_c4_phase_shift_2026_07_17.md` |
| **Warum ausgezeichnet?** | Modular erzwungenes invariantes \(\Delta\theta=+1\); komplementäre Typwörter; reine Phasenverschiebung \(\pi\) zwischen den beiden regulären Kanälen — Symmetrie, keine Enumeration. |
| **Blockiert Uniqueness** | Ordnung von \(\mathcal S\) und damit \(\Phi_\theta\) sind **wohldefiniert nach Fixierung**, aber nicht ohne Konvention aus einer größeren Transformationsgruppe erzwungen (explizit abgetreten: keine Antipodalität, keine \(\mathbb C\)-Achsen). |
| **Status** | **[B]** Kongruenzkern · **[C]** „geometrischer Operator der Collatz-Dynamik“ |

### #4 — Wrap-aware \(\Phi_k^{\mathrm{ref}}\) (Kantenklassifikator → Alphabet)

| | |
|---|---|
| **Definition** | \(\Phi_k^{\mathrm{ref}}(u)=E_{01}\) bei Wrap\(\wedge\nu_2=1\); \(E_{00}\) bei \(\neg\)Wrap und \(1\le\nu_2<k\); \(Z\) bei \(\nu_2\ge k\). Naive \(\Phi_k^{\mathrm{stated}}\) scheitert auf \(G_k^{\mathrm{cut}}\). |
| **Repo** | `docs/eabc_collatz_audit_grid.md` §5.22 · `src/kepler_hurwitz/eabc_relation_classifier_phi_k.py` · Lean: `KeplerHurwitz/EABC/SyracuseRelationClassifierPhi.lean` · Energiedoku: `eabc_relation_classifier_phi_k_2026_07_21.md` |
| **Warum ausgezeichnet?** | Zwang durch Wrap-/Phasenstruktur des modularen Graphen: Cut-Kanten alle \(E_{00}\); Fokus-Wörter exakt die Einheitsdefekt-Klasse von #1. |
| **Blockiert Uniqueness** | Klassifikator, kein globaler Operator; Fenster \(k\in[10,14]\) (`[B]`); \(\forall k\) offen. |
| **Status** | **[A]** Labels · **[B]** Audit · **[C]** globale Zwangsstruktur |

### #5 — Gewichteter Shift-Transfer \(M_w\) / Doob–Perron (H7)

| | |
|---|---|
| **Definition** | Shift-Kanten auf Survivor-Wörtern; Gewichte \(w(0)=\tfrac12\), \(w(1)=\tfrac32\); Dissipativität via Perron-Zeuge; Doob-Kernel \(\widetilde M_{ij}=M_{ij}v_j/(\theta v_i)\). |
| **Repo** | `KeplerHurwitz/Collatz/ResonanzOperator.lean` (+ Audits L8/C8–C12) · Exporte `docs/exports/h7_shift_*.json`, `doob_data_L8_C8.json` |
| **Warum ausgezeichnet?** | Bei Irreduzibilität/Positivität: Perron-Eigenrichtung extremal; Doob normalisiert zur stochastischen Form — klassische spektrale Auszeichnung. |
| **Blockiert Uniqueness** | Gewichte sind Collatz-arithmetisch motiviert, nicht aus EABC-Geometrie abgeleitet; soft case \(C=8\) empirisch \(\rho>1\); Wahl von \((L,C)\)-Schnitten konventionell. |
| **Status** | **[A]** kleine Zertifikate (z. B. L8/C12) · **[B]** Scans · **[C]** kanonische Operatorwahl |

---

## 2. Bewusst nachrangig / nicht Shortlist-Kern

| Kandidat | Kurzgrund |
|---|---|
| `oddCoreStep` / Syracuse \(T\) | Arithmetisch kanonisch, geometrisch erst nach Einbettungswahl |
| Oktonion-Assoziator / Fano | Defekt-Diagnostik `[B]`/`[C]`; Zeugen-Tripel nicht unique-forciert |
| \(\gamma(n)\) / \(V_4\to\mathbb H\) | Kanalgestalt kanonisch für \(\Omega(r)\le2\) distinctChannel; **Einbettung**, keine Dynamik |
| Weyl \(\Delta_{\mathrm{LR}}\) / Bamberg-Plakette / Kwant | Brücken `[C]` bzw. anderes Subsystem; keine Collatz-Operatorwahl |
| Hadamard / Charaktertafeln mod 12 | Im Programm kaum als kanonischer Operator ausgearbeitet (A4-Toy/Fourier nur randständig) |
| Anisotrope Volumenkontraktion \(2^{-S_n}\) | Algebra `[A]`, EABC-Lesart `[C]`; ersetzt \(R^*\) nicht |

---

## 3. Empfehlung für nächste Formal-/Diagnose-Arbeit

**Primärkandidat (Arbeitsfokus, kein Freeze):**  
**#1 Absorptionsprodukt + \(\mathrm{BoolTrace}\), gekoppelt an #4 \(\Phi_k^{\mathrm{ref}}\).**

Begründung: Einziger Kandidat, der (i) eine **verworfene** Alternativklasse (Coxeter/Flip) hinter sich hat, (ii) **extremale** Invarianten \(\kappa_{\mathrm{loc}}=2\), \(\delta_{\mathrm{coh}}=1\) trägt, (iii) durch Wrap-Phasenstruktur von \(\Phi_k\) an Fokus-Zyklen **angereichert** wird. Nächster sinnvoller Schritt: Uniqueness-Audit „gibt es im Lift-Alphabet eine andere rotationsinvariante Observable mit gleichem Extremum?“ + Brücke Transfer \(M_w\) ↔ Bool-Monoid (nur `[B]`-Diagnostik).

**Nicht behauptet:** Damit wäre die Operatorwahl geschlossen.  
**Explizit:** **Wahl bleibt offen [C].** Uniqueness ist **nicht** etabliert.

**Sekundär (Geometrie-Fixpunkt, parallel):** #2 \(R^*\mapsto 24I_3\) weiter als isotrope Zielklasse führen — komplementär, nicht als Syracuse-Operator substitutieren.

---

## 4. Status-Tafel

| Frage | Antwort |
|---|---|
| Ist ein Operator geometrisch unique bewiesen? | **Nein** |
| Schließt diese Suche den Non-Claim? | **Nein** — Wahl bleibt offen |
| Collatz? | **Nein** |
| Freeze? | **Nein** — explorativ |
