# Audit-Protokoll Standard (AP-1)

**Kurzname:** AP-1  
**Schicht:** Methodik (Prozess-Framework) — nicht Theorieinhalt  
**Status:** verbindliches Standard-Protokoll für `[B]`-Audits zu Greedy-Erweiterungsregeln und Farbfamilien  
**Evidenzarchitektur:** [`EVIDENZARCHITEKTUR.md`](EVIDENZARCHITEKTUR.md) · **Claim-Register:** [`CLAIM_REGISTER.md`](CLAIM_REGISTER.md)  
**Governance:** **G-001**, **G-007**, **G-008**

> *Dieses Dokument ist Methodik, kein mathematischer Inhalt. Es spezifiziert, wie Audits durchgeführt und dokumentiert werden — unabhängig vom Ausgang einzelner empirischer Läufe.*

---

## Zweck

AP-1 erhebt das Audit-Verfahren von einer Auswertungsmethode zu einem **instanziierbaren Protokoll**. Neue Audits (BA, BAC, CE, AB, …) werden als Plug-ins über dieselben sechs Phasen evaluiert, ohne das formale Fundament `[A]` zu berühren.

**Invarianz des Rahmens:** Die Methodik bleibt gültig, auch wenn einzelne empirische Befunde unentschieden ausfallen oder revidiert werden.

---

## Architektur: Theorie vs. Methodik

```
                    #Energiedoku Architektur
                              │
          ┌───────────────────┴───────────────────┐
          ▼                                       ▼
 THEORIE (Inhaltsebene)              METHODIK (Prozess-Framework)
 ──────────────────────              ───────────────────────────
 • [A] Formale Mathematik            • Evidenzarchitektur ([A]/[B]/[C]/[G])
 • Blindheitssätze & Invarianten     • Audit-Protokoll Standard (AP-1)
 • Formalismus der Greedy-Regeln     • Hypothesen-Taxonomie
 • Mathematischer Diversitätsindex D • Claim-Register & Vorregistrierung
                                     • Governance-Regeln (G-001 … G-008)
```

Theorie-Module zitieren AP-1; sie ersetzen es nicht.

---

## Die sechs Phasen

```
                     ┌───────────────────────────┐
                     │   Audit-Protokoll (AP-1)  │
                     └─────────────┬─────────────┘
                                   │
    ┌──────────────┬───────────────┼───────────────┬──────────────┬──────────────┐
    ▼              ▼               ▼               ▼              ▼              ▼
1. Vorreg.    2. Kennzahlen    3. Kontrollen   4. Entscheidungs- 5. Artefakte   6. Governance-
   Hypothesen    & Metriken       (K1–K4)         matrix           reproduzierbar  Prüfung
```

| Phase | Pflichtinhalt | Abnahme |
|---|---|---|
| **1. Vorregistrierung** | Exakte \(C\)-Hypothesen (IDs), Scope, Limit \(N\), Ausschlüsse — *vor* dem Lauf | Text/JSON mit Zeitstempel oder Commit-Hash |
| **2. Kennzahlen & Metriken** | Festgelegte Schätzer (z. B. \(D\), \(D(N)\), \(D_F(N)\), \(CI_{95\%}\), Fluktuation, Kohärenz) | Spezifikation im Vorregistrierungsblock |
| **3. Kontrollfamilien** | Negativ-/Neutral-/Positivkontrollen (K1–K4 oder modulspezifisch) | Kontrollmatrix mit erwarteter Richtung |
| **4. Entscheidungsmatrix** | Zuordnung Ergebnis → Statuswort (*bewiesen* nur `[A]`; *bestätigt* `[B]`; *Richtung gestützt*; *keine Entscheidung*; *gegen*) | Tabelle vor dem Lauf |
| **5. Reproduzierbare Artefakte** | Skript, Parameter, Export-JSON/MD, optional Hash der Outputs | Pfade unter `docs/exports/` + Skript unter `scripts/` |
| **6. Governance-Prüfung** | Check gegen \(G\)-Regeln (mind. **G-007**: keine tautologischen Mittelwerte als Befund; Objekttrennung **G-006** wo einschlägig) | Explizite Checkliste im Report |

**Kein Audit gilt als AP-1-konform**, wenn eine Phase fehlt oder nachträglich umdefiniert wird, um das Ergebnis zu retten.

---

## Audit-Unterklassen (`[B]`)

| Audit-Klasse | Fokus & Metriken | Beispiele |
|---|---|---|
| **Struktur-Audits** | Lokale Konfigurationen, Offsets, Fenster-Dichten, Dualitätskennahlen | **B-011**–**B-014** |
| **Trajektorien-Audits** | Dynamische Verläufe \(D(N)\), \(D_F(N)\), Trajektorienkohärenz; Vierlings-Phasen \(D_{\mathrm{quad}}\) | **B-015**, **B-015b**, **B-016** |
| **Kontroll-Audits** | Kalibrierung gegen Kontrollgruppen K1–K4; Mode-IN-Positivkontrollen | **B-K***; Mode IN in **B-016** |

Ein vollständiges Modul-Audit kann mehrere Unterklassen instanziieren (z. B. Struktur + Trajektorie + Kontrolle), jeweils mit eigenem Vorregistrierungsblock.

---

## Entscheidungsmatrix (kanonische Statuswörter)

| Statuswort | Ebene | Bedeutung |
|---|---|---|
| **bewiesen** | `[A]` | nur mit Beweis |
| **bestätigt** | `[B]` | vorregistrierter Audit reproduzierbar erfüllt |
| **Richtung gestützt** | `[C]` | konsistente Tendenz unter Vorregistrierung; Hypothese bleibt offen |
| **keine Entscheidung** | `[C]` | gemischt / Kontrollen widersprüchlich |
| **gegen / widerlegt (Richtung)** | `[C]` | systematisch entgegen der Vorhersage bis \(N\) |
| **Governance** | `[G]` | Rahmenregel, kein empirischer Claim |

**AP-1 erzwingt:** unentschiedene Befunde auszuweisen; keine stillschweigenden Upgrades `[B]`→`[A]` oder Fenster→Asymptotik.

---

## Governance-Prüfung (Phase 6) — Checkliste

- [ ] **G-001:** Kurzformel / Evidenzarchitektur am Report-Kopf  
- [ ] **G-006:** kein Objekttransfer (Konstellation ↔ Normalform) ohne eigenen Audit  
- [ ] **G-007:** keine Interpretation konstruktionsbedingt identischer Mittelwerte; Fokus Form/Streuung/Phase  
- [ ] **G-008:** dieses Audit folgt AP-1 (Phasen 1–6 dokumentiert)  
- [ ] Kein \(D_\infty\)- / Asymptotik-Claim ohne eigene `[C]`/`[A]`-Begründung  

---

## Instanziierung (Vorlage)

Jeder neue AP-1-Lauf dokumentiert am Report-Kopf:

```text
AP-1-Instanz: <kurzname>
Audit-Klasse: Struktur | Trajektorie | Kontrolle
Claims: C-… / B-…
Limit N: …
Skript: scripts/…
Exports: docs/exports/…
Governance: G-001, G-007, G-008 [, G-006]
```

**Referenzinstanz (Trajektorien-Audit):** C-H7 / **B-015b** — [`../exports/ba_C_H7_first_vs_self_extension_report.md`](../exports/ba_C_H7_first_vs_self_extension_report.md).  
**Referenzinstanz (Vierlings-Phasen / Kontrolle):** **B-016** — [`../exports/ba_B016_quadruplet_phase_audit_report.md`](../exports/ba_B016_quadruplet_phase_audit_report.md).  
**Referenzinstanz (Semiprim-Träger / G-006-Dictionary):** **B-017** / **C-H9** — [`../exports/ba_B017_semiprim_carrier_profile_report.md`](../exports/ba_B017_semiprim_carrier_profile_report.md).

**Lokaler metrischer Kern (Greedy):** [`../../src/kepler_hurwitz/eabc_greedy_distance.py`](../../src/kepler_hurwitz/eabc_greedy_distance.py) — \(\mathrm{dist}(T,X)\), Sektor-Distanz, \(\vec D(T)\), Sign via Distanzvergleich; speist **B-015**/ **B-016**/ **B-017**-Plugins. Rein algorithmischer Score (**G-007**), keine `[A]`-Invariante.

**Zwischenraum-Raster (Kandidaten-\(Q\)):** [`eabc_candidate_quad_index.md`](eabc_candidate_quad_index.md) — \(\Phi(Q)\) / \(I_{\mathrm{local}}\) auf EABC-Vierlingen in \(I_k=(p_k+8,p_{k+1})\); \(K=16\) Muster pro 30er-Block; dual \(\Phi_{\mathrm{lattice}}\) vs. \(\phi_{\mathrm{global}}\); Feinstruktur \(\Pi(Q)\in S_4\) (14/24 in-block realisierbar; Blockparität); Diagnose \(\Delta D\) / geplant \(D_\Pi\) (**B-018** / **C-H10**); kombinatorische Farbsymmetrie ≠ dynamische Isotropie (**G-007**).

---

## Erweiterbarkeit

Neue Farbfamilien oder Greedy-Regeln werden als **Plug-ins** angebunden:

1. Theorieobjekt und Formalismus in der Inhaltsebene definieren (`[A]`/`[C]`).  
2. AP-1-Instanz mit Phasen 1–6 anlegen.  
3. Claim-IDs im Register vergeben.  
4. Artefakte exportieren; Governance-Checkliste abhaken.

Die Methodik selbst ändert sich dabei nicht.

---

## Was AP-1 absichtlich nicht ist

- kein Ersatz für Beweise (`[A]`)  
- keine Garantie, dass Hypothesen entschieden werden  
- keine physikalische Existenzaussage  
- kein Freibrief, reproduzierbare Empirie als Theorem zu lesen
