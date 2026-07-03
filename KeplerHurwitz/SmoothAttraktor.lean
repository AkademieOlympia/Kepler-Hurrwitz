import Mathlib

namespace KeplerHurwitz.CkA

/--
`m` ist `B`-glatt, wenn jeder Primteiler von `m` durch `B` beschraenkt ist.
-/
def IsBSmooth (B m : Nat) : Prop :=
  ∀ p, Nat.Prime p → p ∣ m → p ≤ B

/--
Ein einfacher Attraktor-Interfacezustand:
ungerader Kern und `B`-glatt.
-/
def IsSmoothAttraktor (B m : Nat) : Prop :=
  m % 2 = 1 ∧ IsBSmooth B m

/--
Expliziter ungerader Kern nach dem Kick `3*m+1`.
Die Division entfernt exakt den 2-adischen Anteil.
-/
def oddCoreStep (m : Nat) : Nat :=
  (3 * m + 1) / 2 ^ Nat.factorization (3 * m + 1) 2

/--
Empirische Hitrate-Interface:
Anteil der ungeraden Startwerte `m <= N`, deren Folgekern im Attraktorraum liegt.
-/
def AttraktorHitRate (_B _N : Nat) : Rat := 0

/--
Bewusst offenes Interface fuer die spaetere asymptotische Stabilitaetsaussage.
-/
def SmoothAttraktorHypothesis (_B : Nat) : Prop := True

theorem IsBSmooth_one (B : Nat) :
    IsBSmooth B 1 := by
  intro p hp hdiv
  exact (False.elim (hp.not_dvd_one hdiv))

theorem IsBSmooth_mono {B C m : Nat}
    (hBC : B ≤ C)
    (hm : IsBSmooth B m) :
    IsBSmooth C m := by
  intro p hp hpm
  exact Nat.le_trans (hm p hp hpm) hBC

theorem IsSmoothAttraktor_mono {B C m : Nat}
    (hBC : B ≤ C)
    (hm : IsSmoothAttraktor B m) :
    IsSmoothAttraktor C m := by
  constructor
  · exact hm.1
  · exact IsBSmooth_mono hBC hm.2

theorem IsBSmooth_mul {B a b : Nat}
    (ha : IsBSmooth B a)
    (hb : IsBSmooth B b) :
    IsBSmooth B (a * b) := by
  intro p hp hdiv
  have hpa_or_hpb : p ∣ a ∨ p ∣ b := (hp.dvd_mul).1 hdiv
  cases hpa_or_hpb with
  | inl hpa => exact ha p hp hpa
  | inr hpb => exact hb p hp hpb

theorem IsBSmooth_of_dvd {B a b : Nat}
    (ha : IsBSmooth B a)
    (hba : b ∣ a) :
    IsBSmooth B b := by
  intro p hp hpb
  exact ha p hp (Nat.dvd_trans hpb hba)

end KeplerHurwitz.CkA
