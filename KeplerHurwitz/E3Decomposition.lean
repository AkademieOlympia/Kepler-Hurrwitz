import Mathlib

namespace KeplerHurwitz

/--
Kanonsiche e³-Zerlegung für `n = e * a`:
`q = a / e²`, `r = a % e²`, sodass `n = q * e³ + r * e`.
-/
def e3Decompose (e a : Nat) : Nat × Nat :=
  (a / e ^ 2, a % e ^ 2)

/--
Struktur für die e³-Zerlegung mit eingebettetem Identitätsbeweis.
-/
structure E3Decomposition (e a : Nat) where
  q : Nat := a / e ^ 2
  r : Nat := a % e ^ 2
  hdecomp : e * a = q * e ^ 3 + r * e

theorem e3_decomposition_identity (e a : Nat) (_he : 0 < e) :
    e * a = (a / e ^ 2) * e ^ 3 + (a % e ^ 2) * e := by
  have hdiv : a = (a / e ^ 2) * e ^ 2 + a % e ^ 2 := by
    rw [← Nat.mul_comm (e ^ 2) (a / e ^ 2)]
    exact (Nat.div_add_mod a (e ^ 2)).symm
  calc
    e * a = e * ((a / e ^ 2) * e ^ 2 + a % e ^ 2) := by rw [← hdiv]
    _ = (a / e ^ 2) * e ^ 3 + (a % e ^ 2) * e := by
      rw [Nat.mul_add]
      simp [Nat.mul_comm, Nat.mul_left_comm, Nat.pow_succ]

def e3DecompositionOfPos (e a : Nat) (he : 0 < e) : E3Decomposition e a :=
  { q := a / e ^ 2
    r := a % e ^ 2
    hdecomp := e3_decomposition_identity e a he }

theorem e3Decompose_fst (e a : Nat) : (e3Decompose e a).1 = a / e ^ 2 := rfl

theorem e3Decompose_snd (e a : Nat) : (e3Decompose e a).2 = a % e ^ 2 := rfl

end KeplerHurwitz
