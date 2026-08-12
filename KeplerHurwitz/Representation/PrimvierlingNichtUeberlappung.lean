/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Hoffbauer, Kepler-Hurrwitz Team
-/

import Mathlib

/-!
# Nichtüberlappung verketteter Primzahlvierlinge

Für `p > 5` können die sechs Zahlen
`p, p+2, p+6, p+8, p+12, p+14` nicht gleichzeitig prim sein.
Damit ist die Verschränkung der ersten beiden Vierlinge
`(5,7,11,13)` und `(11,13,17,19)` (Startabstand `6`) ein
arithmetisches Initialphänomen: der zweite Start läge bei `q = p+6`.

Paper-Lesart (`docs/manuscripts/spectral_geometry_prime_configurations.tex`):
**Skalen-Initial-Anomalie** / Einschwingvorgang des modularen Siebes.
Nicht beansprucht: Eichgruppen-Analogien (`SU(3)`, `SU(2)×U(1)`),
dynamische Symmetriebrechung, physikalische Reichweite.
-/

namespace KeplerHurwitz

private lemma not_prime_of_five_dvd
    {n : ℕ} (hn : Nat.Prime n) (hdvd : 5 ∣ n) (hne : n ≠ 5) : False :=
  hne ((Nat.prime_dvd_prime_iff_eq (by decide : Nat.Prime 5) hn).mp hdvd).symm

/--
Für jede Primzahl `p > 5` ist die Sechskette
`{p, p+2, p+6, p+8, p+12, p+14}` nicht durchweg prim.
Insbesondere kann kein zweiter regulärer Vierling bei `q = p+6` starten.
-/
theorem primzahl_vierling_nicht_ueberlappung
    (p : ℕ) (hp : Nat.Prime p) (hp5 : p > 5) :
    ¬ (Nat.Prime (p + 2) ∧ Nat.Prime (p + 6) ∧ Nat.Prime (p + 8) ∧
        Nat.Prime (p + 12) ∧ Nat.Prime (p + 14)) := by
  intro ⟨h2, h6, h8, _h12, h14⟩
  have hlt : p % 5 < 5 := Nat.mod_lt p (by decide)
  interval_cases r : p % 5
  · exact not_prime_of_five_dvd hp (Nat.dvd_of_mod_eq_zero r) (by omega)
  · have : (p + 14) % 5 = 0 := by omega
    exact not_prime_of_five_dvd h14 (Nat.dvd_of_mod_eq_zero this) (by omega)
  · have : (p + 8) % 5 = 0 := by omega
    exact not_prime_of_five_dvd h8 (Nat.dvd_of_mod_eq_zero this) (by omega)
  · have : (p + 2) % 5 = 0 := by omega
    exact not_prime_of_five_dvd h2 (Nat.dvd_of_mod_eq_zero this) (by omega)
  · have : (p + 6) % 5 = 0 := by omega
    exact not_prime_of_five_dvd h6 (Nat.dvd_of_mod_eq_zero this) (by omega)

/-- Speziell: zwei reguläre Vierlinge mit Startabstand `6` sind für `p > 5` unmöglich. -/
theorem kein_vierling_start_plus_sechs
    (p : ℕ) (hp : Nat.Prime p) (hp5 : p > 5)
    (hQ1 : Nat.Prime (p + 2) ∧ Nat.Prime (p + 6) ∧ Nat.Prime (p + 8))
    (hQ2 : Nat.Prime (p + 6) ∧ Nat.Prime (p + 8) ∧ Nat.Prime (p + 12) ∧ Nat.Prime (p + 14)) :
    False :=
  primzahl_vierling_nicht_ueberlappung p hp hp5
    ⟨hQ1.1, hQ1.2.1, hQ1.2.2, hQ2.2.2.1, hQ2.2.2.2⟩

end KeplerHurwitz
