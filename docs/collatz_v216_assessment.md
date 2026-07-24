# Collatz V2.16 — wissenschaftliche & epistemologische Bewertung

> **Branch / Worktree:** `pr/11-collatz-v27-net-descent` · `Kepler-Hurrwitz-h7mod256` (Commit-Anker u. a. `6e832bc`)  
> **Lean:** `CollatzChannelSeven.lean` · `Collatz/ChannelSevenDeepLiftFormalBridgeV216.lean` · `CollatzProofAttemptV216.lean`  
> **Orthogonal:** EABC-Audit-Grid [`eabc_collatz_audit_grid.md`](eabc_collatz_audit_grid.md) · Register `E-097` (mod-24 Syracuse)  
> **Claim-Boundary:** lokaler `[A]`-Raumgewinn unter Kanal 7 — **kein** Collatz-Beweis

Drei Bewertungsachsen: **Methodik**, **Reichweite**, **Grenzen**.

---

## 1. Methodische Qualität — exzellent (`[A]`-Niveau)

* **Rigorosität:** Modul-Erweiterungen kompilieren ohne neue `sorry`-Aussagen in der V2.16-Brücke / Formal-Union. Was hier als `[A]` gilt, ist maschinell geprüft.
* **Zeugen-Basis:** Erweiterung der formalen Abdeckung unter Kanal 7 auf **15/32** Restklassen modulo 256 (\(\approx 46{,}875\,\%\)), inkl. Partial-Klassen `{39,79,95}` neben der mod-128-Leiter `{7,15,23,55,87,119}` (siehe `bad_run_net_descent_witness_channel_seven_formal_extended_union`).
* **Deep-Lift (\(j=3\)):** Faser-Strukturen höherer Schalen werden auf bereits verifizierte Fundamente abgebildet — rekursive Lift-Geometrie statt bloßer Klassenenumeration.

---

## 2. Abdeckungs- und Dichtegewinn

\[
\text{Formale Kanal-7-Ausschöpfung (mod 256)} = \frac{15}{32} \approx 46{,}875\,\%.
\]

Verankerung im Reduktionssatz `bad_run_net_descent_witness_channel_seven_formal_extended_union` / Status `ChannelSevenDeepLiftFormalBridgeV216Status.formal_extended_union`.

Kanal 7 bleibt eine hartnäckige Verzögerungszone; der Dichtegewinn ist **substantiell**, aber nicht gleichbedeutend mit Komplexitätsreduktion des Deep-Tails.

---

## 3. Epistemologische Einordnung & verbleibende Hürden

```text
[ Bisher kontrolliert ]                 [ Die "harte" Wand ]
   15 / 32 Klassen mod 256        --->   Deep-Tail: {31, 47, 63, 71, 103, 111}
   (inkl. j=3 Deep-Lifts +               + dynamischer Eintritts-Proof
    Partial {39,79,95})                  + globale oddCoreCollatz-Kopplung
```

* **Deep-Tail:** Die verbleibenden Klassen tragen die stärkste kaskadierende Expansion. Schließen „leichterer“ Klassen erhöht Abdeckung, löst nicht automatisch den Tail.
* **Globales Eintrittsproblem:** Selbst 100 % Kanal-7-Abdeckung ersetzt nicht den Beweis, dass jede Startzahl in eine absteigende Faser eintritt.

---

## 4. Gesamtbewertung

| Kriterium | Bewertung | Begründung |
|---|---|---|
| Formale Korrektheit | 10/10 | 0 neue `sorry` in der V2.16-Brücken-/Union-Schicht (maschinell) |
| Architektur & Moduldesign | 9/10 | Deep-Lift \(j=3\) skalierbar; klare Status-Bündel |
| Beweisabstand zu Collatz | substantieller Teilschritt | mehr bewiesener Raum unter Kanal 7; globales Halteproblem offen |

**Gesamturteil:** Hochkarätiger, ehrlicher `[A]`-Meilenstein — formale Werkzeuge ohne Illusion, die additive Collatz-Barriere bereits durchbrochen zu haben.

---

## 5. Querverweis: EABC mod-24 Audit (`E-097`)

Die Syracuse-Kurzregel „B→C, C→A“ ist **falsch**. Präzise (mod 24):

| \(\kappa\bmod 24\) | nach \(/2\) | \(V_4\) |
|---|---|---|
| 7 | \(\equiv 11\pmod{12}\) | C |
| 19 | \(\equiv 5\pmod{12}\) | A |
| 11 | \(\equiv 5\pmod{12}\) | A |
| 23 | \(\equiv 11\pmod{12}\) | C |

DualCarrier-Tracking bleibt Diagnosewerkzeug; siehe `docs/eabc_collatz_audit_grid.md`.

---

## 6. Artefakte

| Rolle | Pfad |
|---|---|
| Status-Bundle | `KeplerHurwitz/CollatzProofAttemptV216.lean` |
| Deep-Lift-Brücke | `KeplerHurwitz/Collatz/ChannelSevenDeepLiftFormalBridgeV216.lean` |
| Kanal-7-Union | `KeplerHurwitz/CollatzChannelSeven.lean` |
| Diese Bewertung | `docs/collatz_v216_assessment.md` |
