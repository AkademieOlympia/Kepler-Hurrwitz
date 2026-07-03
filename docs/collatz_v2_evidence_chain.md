# Collatz-V2 — lokale Evidence Chain

**Quelle:** `KeplerHurwitz/CollatzProofAttemptV2.lean` … `CollatzProofAttemptV25.lean`  
**Register-Verweis:** `EVIDENCE_REGISTER.md` (Collatz-Kern, unabhaengig von Musketiere-Spur)

Diese Kette dokumentiert den **lokalen** Beweisstand des Collatz-V2-Versuchs (ungerader Kern `T_odd`,
mod-4-Fallzerlegung). Sie ist von der Musketiere-Evidence Chain **E-046 → E-048 → E-032 → E-026**
getrennt.

---

## Lokale Evidence Chain

| Schritt | Statement / Satz | Rolle | Status |
|---|---|---|---|
| 1 | `CollatzAttemptV2Mod4EqOneShrink` | Good-Branch — mod 4 = 1 ⇒ strikter lokaler Shrink | `[A]` geschlossen |
| 2 | `ExactTwoAdicDepthExtractionStatement` | 2-adische Tiefenextraktion fuer mod 4 = 3 | `[A]` geschlossen |
| 3 | `BadRunDepthExtractionStatement` | Bad-Run-Tiefe aus Extraktion | `[A]` geschlossen |
| 4 | `BadBranchEventuallyLocalShrinkStatement` | Endlicher lokaler Shrink nach Bad-Branch | `[A]` geschlossen |
| 5 | `CollatzProofAttemptStatus` | Buendel der vier geschlossenen lokalen Ziele | `[A]` geschlossen |
| 6 | `CollatzMod4ThreeGlobalDescentStatement` | Bruecke zu globalem `collatzStep`-Abstieg | **offen** |
| 7 | `CollatzGlobalTerminationStatement` | Globale Collatz-Termination | **offen** |

---

## Schritt 2: `ExactTwoAdicDepthExtractionStatement` — `[A]` geschlossen

**Beweisweg:** `CollatzProofAttemptV25.lean`

1. `n % 4 = 3` ⇒ `4 ∣ n + 1` ⇒ `2 ≤ padicValNat 2 (n + 1)` (`two_le_padicValNat_two_of_mod4_eq_three`)
2. `padicValNat 2 (n + 1)` liefert exakte 2-adische Tiefe (`exact_two_adic_depth_of_padicValNat_succ`)
3. Damit `exact_two_adic_depth_extraction_statement_holds : ExactTwoAdicDepthExtractionStatement`

Die Extraktion laeuft vollstaendig ueber **`padicValNat 2 (n + 1)`** — kein offenes arithmetisches Subziel
in dieser Schicht.

**Build:** `lake build KeplerHurwitz.CollatzProofAttemptV25`

---

## Offene globale Schicht

Lokale Odd-Tail-Shrink und Tiefenextraktion sind geschlossen; der globale Collatz-Beweis bleibt offen
(`CollatzGlobalTerminationStatement`, Bruecke mod 4 = 3 → `collatzStep`-Iteration unter Startwert).
