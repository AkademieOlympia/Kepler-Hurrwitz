import Mathlib
import KeplerHurwitz.PrimvierlingSymmetry

/-!
# Bamberg Modell: #Energiedoku — Baustein 1

Formale Verifikation der Quadruplet-Admissibilität und dualen mod-12-Orientierung.

Governance:
* Scope: post-freeze / Energiedoku-Gerüst; kein Frozen-Dossier-Touch.
* Status: `[A]` (kombinatorische Restklassenarithmetik).
* Nicht beansprucht: Hardy–Littlewood-Dichte, unendlich viele Quadruplets, Collatz.
-/

namespace KeplerHurwitz

/-- Das Prädikat definiert ein Primzahl-Quadruplet `(p, p+2, p+6, p+8)` ab `p > 5`. -/
def IsQuadruplet (p : ℕ) : Prop :=
  Nat.Prime p ∧ Nat.Prime (p + 2) ∧ Nat.Prime (p + 6) ∧ Nat.Prime (p + 8) ∧ p > 5

namespace IsQuadruplet

variable {p : ℕ}

theorem prime (h : IsQuadruplet p) : Nat.Prime p := h.1
theorem prime_add_two (h : IsQuadruplet p) : Nat.Prime (p + 2) := h.2.1
theorem prime_add_six (h : IsQuadruplet p) : Nat.Prime (p + 6) := h.2.2.1
theorem prime_add_eight (h : IsQuadruplet p) : Nat.Prime (p + 8) := h.2.2.2.1
theorem gt_five (h : IsQuadruplet p) : p > 5 := h.2.2.2.2

/-- Brücke zum bestehenden `PrimeQuadruplet`-Träger. -/
theorem of_PrimeQuadruplet (v : PrimeQuadruplet) (hp : v.p > 5) : IsQuadruplet v.p :=
  ⟨v.is_prime_p, v.is_prime_p2, v.is_prime_p6, v.is_prime_p8, hp⟩

def to_PrimeQuadruplet (h : IsQuadruplet p) : PrimeQuadruplet :=
  ⟨p, h.prime, h.prime_add_two, h.prime_add_six, h.prime_add_eight⟩

end IsQuadruplet

/-! ### Interne Ausschlusshilfen (Faktoren 2, 3, 5) -/

private lemma not_prime_of_prime_dvd_ne
    {d n : ℕ} (hd : Nat.Prime d) (hn : Nat.Prime n) (hdvd : d ∣ n) (hne : n ≠ d) : False :=
  hne ((Nat.prime_dvd_prime_iff_eq hd hn).mp hdvd).symm

private lemma quadruplet_not_dvd_two {p : ℕ} (h : IsQuadruplet p) :
    ¬ 2 ∣ p ∧ ¬ 2 ∣ (p + 2) ∧ ¬ 2 ∣ (p + 6) ∧ ¬ 2 ∣ (p + 8) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_two h.prime hdvd (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_two h.prime_add_two hdvd (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_two h.prime_add_six hdvd (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_two h.prime_add_eight hdvd
      (by have := h.gt_five; omega)

private lemma quadruplet_not_dvd_three {p : ℕ} (h : IsQuadruplet p) :
    ¬ 3 ∣ p ∧ ¬ 3 ∣ (p + 2) ∧ ¬ 3 ∣ (p + 6) ∧ ¬ 3 ∣ (p + 8) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_three h.prime hdvd (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_three h.prime_add_two hdvd
      (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_three h.prime_add_six hdvd
      (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne Nat.prime_three h.prime_add_eight hdvd
      (by have := h.gt_five; omega)

private lemma quadruplet_not_dvd_five {p : ℕ} (h : IsQuadruplet p) :
    ¬ 5 ∣ p ∧ ¬ 5 ∣ (p + 2) ∧ ¬ 5 ∣ (p + 6) ∧ ¬ 5 ∣ (p + 8) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro hdvd
    exact not_prime_of_prime_dvd_ne (by decide : Nat.Prime 5) h.prime hdvd
      (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne (by decide : Nat.Prime 5) h.prime_add_two hdvd
      (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne (by decide : Nat.Prime 5) h.prime_add_six hdvd
      (by have := h.gt_five; omega)
  · intro hdvd
    exact not_prime_of_prime_dvd_ne (by decide : Nat.Prime 5) h.prime_add_eight hdvd
      (by have := h.gt_five; omega)

/-- `p` ungerade (äquivalent: `p % 2 = 1`). -/
private lemma quadruplet_mod_two {p : ℕ} (h : IsQuadruplet p) : p % 2 = 1 := by
  have ⟨h2, _, _, _⟩ := quadruplet_not_dvd_two h
  have : p % 2 = 0 ∨ p % 2 = 1 := Nat.mod_two_eq_zero_or_one p
  rcases this with h0 | h1
  · exact absurd (Nat.dvd_iff_mod_eq_zero.mpr h0) h2
  · exact h1

/-- Ausschluss mod 3: nur `p ≡ 2 (mod 3)` überlebt. -/
private lemma quadruplet_mod_three {p : ℕ} (h : IsQuadruplet p) : p % 3 = 2 := by
  have ⟨hp, hp2, hp6, hp8⟩ := quadruplet_not_dvd_three h
  have hlt : p % 3 < 3 := Nat.mod_lt p (by decide : 0 < 3)
  interval_cases r : p % 3
  · exact absurd (Nat.dvd_iff_mod_eq_zero.mpr r) hp
  · have : (p + 2) % 3 = 0 := by omega
    exact absurd (Nat.dvd_iff_mod_eq_zero.mpr this) hp2
  · rfl

/-- Ausschluss mod 5: nur `p ≡ 1 (mod 5)` überlebt. -/
private lemma quadruplet_mod_five {p : ℕ} (h : IsQuadruplet p) : p % 5 = 1 := by
  have ⟨hp, hp2, hp6, hp8⟩ := quadruplet_not_dvd_five h
  have hlt : p % 5 < 5 := Nat.mod_lt p (by decide : 0 < 5)
  interval_cases r : p % 5
  · exact absurd (Nat.dvd_iff_mod_eq_zero.mpr r) hp
  · rfl
  · have : (p + 8) % 5 = 0 := by omega
    exact absurd (Nat.dvd_iff_mod_eq_zero.mpr this) hp8
  · have : (p + 2) % 5 = 0 := by omega
    exact absurd (Nat.dvd_iff_mod_eq_zero.mpr this) hp2
  · have : (p + 6) % 5 = 0 := by omega
    exact absurd (Nat.dvd_iff_mod_eq_zero.mpr this) hp6

/--
**I. Analytischer Kongruenzsatz `[A]`.**

Aus der Quadruplet-Eigenschaft folgt zwingend `p ≡ 11 (mod 30)`.

Beweis: kombinatorischer Ausschluss via Faktoren 2, 3, 5 und CRT
(`p ≡ 1 (mod 2)`, `p ≡ 2 (mod 3)`, `p ≡ 1 (mod 5)` ⇒ `p ≡ 11 (mod 30)`).
-/
theorem analytischer_kongruenzsatz {p : ℕ} (h : IsQuadruplet p) : p % 30 = 11 := by
  have h2 := quadruplet_mod_two h
  have h3 := quadruplet_mod_three h
  have h5 := quadruplet_mod_five h
  omega

/--
**II. Duale mod-12-Orientierung `[A]`.**

Aus der mod-30-Zulässigkeit `p = 30k + 11` folgt die deterministische
Paritäts-Kopplung:
* gerades `k` ⇒ `p ≡ 11 (mod 12)` (EABC-Klasse E),
* ungerades `k` ⇒ `p ≡ 5 (mod 12)` (EABC-Klasse B).
-/
theorem duale_mod12_orientierung (k p : ℕ) (hp : p = 30 * k + 11) :
    (k % 2 = 0 → p % 12 = 11) ∧ (k % 2 = 1 → p % 12 = 5) := by
  constructor
  · intro hk; subst hp; omega
  · intro hk; subst hp; omega

/-- Spezialisierung: jedes Quadruplet mit `p > 5` liegt in der dualen Bahn. -/
theorem quadruplet_duale_mod12 {p : ℕ} (h : IsQuadruplet p) :
    let k := (p - 11) / 30
    (k % 2 = 0 → p % 12 = 11) ∧ (k % 2 = 1 → p % 12 = 5) := by
  have hp30 := analytischer_kongruenzsatz h
  have hp : p = 30 * ((p - 11) / 30) + 11 := by omega
  exact duale_mod12_orientierung ((p - 11) / 30) p hp

/-- Kanonisches Beispiel: `(11, 13, 17, 19)`. -/
example : IsQuadruplet 11 :=
  ⟨by decide, by decide, by decide, by decide, by decide⟩

example : (11 : ℕ) % 30 = 11 := by decide

example : (11 : ℕ) % 12 = 11 := by decide

end KeplerHurwitz
