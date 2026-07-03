# EABC-Attraktor-Hypothese: Zielkorridor fuer den formalen Brueckensatz

Dieses Dokument definiert den strategischen Uebergang von den statistischen Befunden des Skalen-Scans (`smoothness_b_bound_summary.json`) zu den zukuenftigen formalen Beweisstrukturen in Lean 4. Ziel ist es, die dissipative Wirkung tiefer Schalenspruenge mathematisch als globalen Kontraktionsmotor zu verankern.

---

## 1. Definition des breitbandigen Attraktorraums

Der klassische Versuch, den Collatz-Fluss direkt auf ultra-glatte Strukturen (`B=3` oder `B=5`) zu reduzieren, scheitert an der kombinatorischen Wildheit der ungeraden Spruenge. Die empirischen Daten des EABC-Programms zeigen jedoch, dass bei `B=11` ein hochstabiler, skaleninvarianter Attraktorraum existiert.

- **Formale Zieldefinition (Lean):**
  Definition eines Praedikats `IsSmoothAttraktor (b : Nat) (m : Nat) : Prop`, das fuer ein festes `B` (Initialwert `11`) die mathematische Glattheit des ungeraden Kerns `m` deklariert.
- **Schnittstelle zu bestehenden Saetzen:**
  Dieses Praedikat baut direkt auf der in `OddCore.lean` verankerten Struktur `OddCoreDecomposition` auf.

---

## 2. Das Schalenkanal-Lemma (Eintrittsrate)

Die statistische Kreuzanalyse zeigt, dass die Wahrscheinlichkeit, in den `B`-glatten Attraktorraum zu fallen, nicht gleichverteilt ist. Sie ist bei tiefen Schalenspruengen dramatisch erhoeht.

- **Defensive Trennung der Ebenen:**

### [A] Formal sicher

```lean
def eSchalenSprung (m : Nat) : Nat := ...
-- sowie Kanal-Klassifikation fuer ungerade m
-- (u. a. 3 ≤ eSchalenSprung m im tiefen Kanal)
```

Die Schalenkanal-Struktur ist in `SchalenDynamik.lean` formal verankert.

### [B] Empirisch gestuetzt

Die Daten zeigen eine hohe Eintrittsrate in den `B=11`-glatten Bereich bei tiefen Schalenspruengen. Das wird als Dichte-/Statistik-Aussage formuliert, nicht als deterministische Implikation.

```lean
def AttraktorHitRate (B N : Nat) : Rat := ...
-- empirisch: AttraktorHitRate(11, N | tiefer Kanal) ist gross
```

### [C] Offene Hypothese

```lean
def SmoothAttraktorHypothesis (B : Nat) : Prop := True
```

Dieses Interface markiert bewusst den offenen Teil, bis Dichte- oder Transferaussagen formalisiert sind.

- **Korrigierte Leitformulierung:**
  Der `B=11`-Scan motiviert die Hypothese, dass tiefe Schalenspruenge statistisch bevorzugt in den breitbandigen glatten Attraktorraum eintreten. Dies ist derzeit **kein** formales Theorem, sondern ein empirischer Zielkorridor fuer spaetere Dichte- oder Transferaussagen.

---

## 3. Das Stabilitaetslemma (Invarianz der Asymmetrie)

Innerhalb des Attraktorraums darf die Dynamik nicht "degenerieren". Die Asymmetrie der Schalenkanaele (`klein`, `mittel`, `tief`) muss als stabiles Gesetz erhalten bleiben, um den permanenten Rueckfluss in kollabierende Bahnen zu garantieren.

- **Formale Zielaussage (Lean):**
  Der Nachweis, dass fuer alle Elemente `m`, die `IsSmoothAttraktor 11 m` erfuellen, die Verteilung der nachfolgenden Schalenspruenge invariant gegenueber Skalierungen des Suchraums bleibt. Dies erzwingt die Existenz einer globalen Ljapunow-artigen Metrik.
- **Mapping auf vorhandene Saetze:**
  Die Erhaltung der algebraischen Gesamtenergie wird hierbei durch die Symmetrie-Garantien aus `PrimvierlingSymmetry.lean` (`quatNorm_invariant_under_shiftCEAB`) gestuetzt. Die Symmetrieklassen des Orbits bilden das geometrische Korsett, innerhalb dessen sich die Schalendynamik stabil bewegt.

---

## Fazit und naechste Schritte

Dieses Memo dient als direkte Bruecke. Mit der Hinterlegung in `docs/` ist der konzeptionelle Rahmen abgesteckt. Der empirische Befund des `B=11`-Scans ist damit offiziell in die mathematische Roadmap des EABC-Programms uebersetzt.
