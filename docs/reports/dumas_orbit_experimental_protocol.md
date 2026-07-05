# Dumas-Orbit Experimental Protocol

**Stand:** 5. Juli 2026  
**Bezug:** [`docs/theory/dumas_cone_orbit_model.md`](../theory/dumas_cone_orbit_model.md) §17 (Falsifikationsrahmen und Prüfmodule A–E)  
**Runner:** `scripts/dumas_orbit_experiment.py`  
**Regression:** `pytest tests/test_dumas_cone_orbit.py -m regression`

---

## Governance (verbindlich)

| Kurzformel | Bedeutung |
|---|---|
| **Dumas = Normalform, nicht Generator** | Orbit permutiert Rollen auf festem \(P(v)\); erzeugt keine Primzahlen |
| **Dumas-Identitäten = Regression** | H1–H11 / Prüfmodul A sind `[A-T]`/`[B]`-Checks — grün erwartet, kein empirischer Befund |
| **Nur nullmodellstabile Abweichungen = empirische Evidenz** | Effekte ohne expliziten Nullmodell-Abzug bleiben **`[B0]` prognoseneutral** |
| **Interessant = über Normalform vs. Nullmodelle** | Echter Treffer nur jenseits H1–H11 und nach kontrolliertem Vergleich |

\[
\boxed{
\text{Forschungsbefund} = \text{robuste Abweichung vom Nullmodell — nicht Dumas-Identität.}
}
\]

\[
\boxed{
\text{Dumas ist Normalform, nicht Generator.}
}
\]

**Tag-Abstufung:**

| Tag | Bedeutung |
|---|---|
| `[A-T]` / `[B]` | Strukturkonsistenz (Modul A) — Regression |
| `[B]` | Reproduzierbare Diagnosewerte (Module B–E) |
| `[B0]` | Prognoseneutral — solange Nullmodell nicht verworfen |
| `[B+]` | Skalenrobuster Effekt (nur Modul D bei bestätigtem H13) |
| `[C]` | Methodische Analogie (Kegel, Kepler) |

**Physik-Analogien (getrennt):** AB / Klitzing / Meissner-Lesarten leben in [`physical_reference_analogies.md`](physical_reference_analogies.md) — **nicht** in diesem Protokoll. Dumas-Befunde dürfen nicht post hoc als Physik-Bestätigung gelesen werden.

---

## Ziel

Dumas **nicht erneut bestätigen**, sondern systematisch prüfen:

1. **Regression** (Modul A) — bleibt grün?
2. **Empirische Zusatzhypothesen** H12–H15 (Module B–E) — Abweichung von H₀?
3. **Nullmodelle** F1–F5 — übersteht ein Effekt Permutation/Shuffle/Vierling-Baseline?
4. **Skalenrobustheit** — konsistent über \(N \in \{10^5, 10^6, 10^7\}\) (optional \(10^8\))?

---

## Skalen und Artefakte

| Parameter | Wert |
|---|---|
| Skalen \(N\) | \(10^5\), \(10^6\), \(10^7\); optional \(10^8\) (`--include-1e8`, nur wenn Laufzeit akzeptabel) |
| Entropie-Fenster \(L\) | Default 50 (Primzahlen im Intervall \([p-L,\,p)\)) |
| Permutationen F1 | Default 500 (`--permutations`) |

**CSV-Ausgabe (Repo-Konvention):** `docs/energiedoku_exports/`

| Datei | Inhalt |
|---|---|
| `dumas_orbit_scale_report.csv` | Eine Zeile pro Skala — Module A–E + Nullmodell F1 |
| `dumas_orbit_gap_phase.csv` | Phasenstratifizierung Modul B (E/A/B/C) |
| `dumas_orbit_entropy_windows.csv` | Modul C — Primvierling vs. Kontrollen |

**Optionale Spiegelung:** `--out-dir exports/` legt dieselben Dateien unter `exports/` ab (nicht kanonisch; primär `docs/energiedoku_exports/`).

---

## Prüfmodul A — Strukturkonsistenz (Regression)

**Hypothesen:** H1–H11 (Dumas-Komplementarität, 12-Slot-Fill, Gap-Rotor, Kepler-Kreis, Host≠Channel, Twin-Degeneration).

**Methode:** `verify_dumas_orbit`, `verify_natural_fill`, `verify_rotor_gap_sequence`, `verify_kepler_circle` auf allen kanonischen Primvierlingen mit \(p \le N\).

**Erwartung:** `dumas_failures = 0` — **keine Überraschung**.

**Falsifikation:** Jeder Ausfall signalisiert Lean/Python-Inkonsistenz, nicht arithmetischen Durchbruch.

**Repo:** `src/kepler_hurwitz/dumas_cone_orbit.py`, `tests/test_dumas_cone_orbit.py` (`@pytest.mark.regression`).

---

## Prüfmodul B — Rotorphase vs. Lücken \(\Delta_i\)

**Hypothese H12:** Abstände \(\Delta_i = p_{i+1} - p_i\) zwischen aufeinanderfolgenden Primvierling-Starts hängen von Rotorphase \(h_i = \rho(i)\) ab.

**H₀:** \(\mathbb E[\Delta_i \mid h_i]\) unter Phasen-Permutation nicht von Zufallsbaseline unterscheidbar.

**Methode:**
- \(\Delta_i\) für \(i = 1,\ldots,n-1\)
- Phase \(h_i = \texttt{host\_for\_quadruplet\_index}(i+1)\) (E/A/B/C)
- Deskriptiv: `phase_gap_mean`, `phase_gap_std` pro Phase
- Inferenz: Kruskal–Wallis \(H\) und Einweg-ANOVA \(F\) (ohne externe Abhängigkeit)

**Prior:** Szenario A (Nullmodell) — **0,55** (§16.4).

**Treffer-Kriterium:** Signifikante Stratifikation **und** Verwerfung von F1 (Phasen-Permutation).

---

## Prüfmodul C — Umfeld-Entropie \(S_L(p)\)

**Hypothesen H14/H15:** Kanalentropie im Fenster \([p-L, p)\) vor Primvierling-Start \(p\).

**H₀:** \(S_L(p)\) vor echten Primvierlingen unterscheidet sich nicht von Vergleichsgruppen.

**Vergleichsgruppen:**

| Gruppe | Definition |
|---|---|
| `primvierling` | Startprim \(p\) jedes kanonischen Vierlings |
| `structured_control` | Prim \(q\) gleicher Größenordnung, für das \((q,q+2,q+6,q+8)\) **kein** Primvierling ist |
| `random_n` | Zufällige gerade \(n \in [p_{\min}, p_{\max}]\) (Seed fixiert) |

**Methode:** `channel_entropy` auf aggregierter EABC-Signatur der Primzahlen im Fenster (`signature_from_nat` pro Prim, Summe der Kanalzähler).

**Prior:** Szenario A — Entropie-Fenster allein tragen vermutlich keine Vorhersagekraft ohne Kontrolle.

---

## Prüfmodul D — ABCE/CEAB-Orientierungsbias

**Hypothese H13:** \(\Pr(\mathrm{ABCE}) \approx \Pr(\mathrm{CEAB})\).

**Methode:** Kanonische Speicherung \(v=(a,b,c,e)=(p,p+2,p+6,p+8)\). Kanalwörter \(\texttt{channel\_from\_mod12}\) entlang ABCE-Slots vs. entlang `shiftCEAB`-Slots; Repräsentantenwahl:
- **ABCE:** Kanalwort in Slot-Reihenfolge \(\le\) Kanalwort nach CEAB-Shift (lexikographisch)
- **CEAB:** sonst

**Hinweis:** Lexikographischer Vergleich der **Prim-Tupel** wäre tautologisch (immer ABCE) — daher Kanalwort-Vergleich.

**H₀:** Gleichverteilung / zufällige Orientierung.

**Upgrade `[B+]`:** Nur wenn Asymmetrie **skalenrobust** über \(N\)-Bänder und nicht durch mod-12/Sieb erklärbar.

**Prior:** Robuste CEAB-Asymmetrie — **niedrig** (0,15).

**Repo:** `primvierling.symmetry_shift_ceab`, `orbit_symmetry_guide.md`.

---

## Prüfmodul E — Gewichtungsorbit als Feature (minimal)

**Hypothese H14 (diagnostisch):** Host-gewichteter Vektor \(\mathbf w^{(h)}(\omega)\) korreliert mit nächster Lücke \(\Delta_i\) — **nicht** Entropie-Konstanz (H8, Modul A).

**Methode:** Für \(\omega = 0{,}5\), Host \(h_i\) am Index \(i\): Feature \(f_i = \|\mathbf w - \mathbf u\|_2\) (`l2_from_uniform`). Pearson-\(r\) mit \(\Delta_i\).

**H₀:** \(r \le\) Korrelation unter Gap-Shuffle (F2).

**Abgrenzung:** H8 bestätigt Permutationsorbit bei festem \(\omega\) — das ist Modul-A-Normalform.

---

## Nullmodelle F1–F5

| ID | Name | Anwendung | Definition |
|---|---|---|---|
| **F1** | Rotor-Phasen-Permutation | Modul B | Phasenlabels E/A/B/C zufällig permutieren; Kruskal-\(H\) neu berechnen; empirisches \(p\) = Anteil Permutationen mit \(H_{\mathrm perm} \ge H_{\mathrm obs}\) |
| **F2** | Gap-Shuffle | Modul B, E | \(\Delta_i\) permutieren, Phasen fix halten |
| **F3** | Strukturierte Nicht-Vierlinge | Modul C | Primzahlen ohne kanonisches 4-Tupel (structured_control) |
| **F4** | CEAB-Orbit-Tausch | Modul D | Jeder Vierling zählt gleich oft in ABCE/CEAB-Orbit — erwartete 50/50-Baseline |
| **F5** | Twin-Prime-Baseline | Modul D (Referenz) | Twin-Paar-Signatur `(1,0,0,1)` vs. `(0,1,1,0)` als Orientierungs-Referenz (`twin_channel_signature`) |

**Verwerfungslogik:** Effekt gilt nur dann als **`[B]`** (nicht `[B0]`), wenn
1. beobachtete Statistik signifikant von H₀ abweicht **und**
2. mindestens das zuständige Nullmodell (F1 für B, F3 für C, F4 für D) **nicht** erklärt.

---

## Skalenrobustheit (Abschnitt G)

Für jedes Modul B–E und jede Statistik:

| Kriterium | Schwellwert |
|---|---|
| Richtungskonsistenz | Effekt-Vorzeichen gleich über \(\ge 2\) Skalen |
| Magnitude | Kein Einzel-Skala-Ausreißer ohne Replikation |
| Nullmodell | F1/F3/F4-\(p > 0{,}05\) auf **allen** Skalen → **`[B0]`** |

**Skalenreport:** `dumas_orbit_scale_report.csv` — eine Zeile pro \(N\).

---

## Befundlogik

```
IF Modul A failures > 0:
    → STOP: Inkonsistenz (Lean/Python), nicht interpretieren
ELIF Modul B–E p > 0.05 OR F1/F3/F4 nicht verworfen:
    → [B0] prognoseneutral (Default)
ELIF Effekt skalenrobust (≥2 Skalen) AND Nullmodell verworfen:
    → [B] reproduzierbare Abweichung
    IF Modul D AND H13 skalenrobust:
        → [B+] (Orientierungsbias)
ELSE:
    → [B] diagnostisch, aber Vorsicht (schwache/skaliensensitive Effekte)
```

**Erwartung (Repo-Prior):** Module B–E **nullmodellnah** — keine `[B+]`-Upgrades ohne Überraschung.

---

## Abschluss-Checkliste

- [ ] `pytest tests/test_dumas_cone_orbit.py -m regression` grün
- [ ] `python scripts/dumas_orbit_experiment.py` — drei CSVs geschrieben
- [ ] Modul A: `total_regression_failures = 0` auf allen Skalen
- [ ] Befundbericht: explizit `[B0]` vs. `[B]` pro Modul
- [ ] Keine Prognosebehauptung ohne F1–F5-Verwerfung

---

## Harte Repo-Boxen

\[
\boxed{
\text{Dumas ist Normalform, nicht Generator.}
}
\]

\[
\boxed{
\text{Interessant} = \text{über Normalform hinaus — und nur vs. Nullmodelle.}
}
\]

\[
\boxed{
\text{Forschungsbefund} = \text{robuste Abweichung vom Nullmodell — nicht Dumas-Identität.}
}
\]

| Rolle | Repo-Schicht |
|---|---|
| Normalform-Atlas | `dumas_natural_fill.py`, `dumas_drillinge.csv`, Modul A |
| Diagnose / Vergleich | `diagnostics.py`, Parameter-Atlas, Module B–E |
| Prognose | **`[B0]`** bis explizite Nullmodell-Verwerfung |
| Dieses Protokoll | `docs/reports/dumas_orbit_experimental_protocol.md` |

---

## Verwandte Dokumente

- [`physical_reference_analogies.md`](physical_reference_analogies.md) — Physik-Analogien `[C]` (strikt getrennt von Dumas-Empirie)
- [`dumas_cone_orbit_model.md`](../theory/dumas_cone_orbit_model.md) §17 — Falsifikationsrahmen
- [`diagnostics_parameter_atlas.md`](../diagnostics_parameter_atlas.md) — `channel_entropy`
- [`orbit_symmetry_guide.md`](../orbit_symmetry_guide.md) — CEAB-Orbit
- [`EABC_MASTER_INDEX.md`](../../EABC_MASTER_INDEX.md) — Schwerpunkt Dumas Cone–Orbit
