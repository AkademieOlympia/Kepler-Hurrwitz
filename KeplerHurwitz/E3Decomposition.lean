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

/--
Lemma 2 — Produktzerlegung des Restkanals: wenn `r = b * c`, dann
`e * a = q * e³ + b * c * e` (gegeben `a = q * e² + r` aus Lemma 1).
-/
theorem e3_product_decomposition (e a q r b c : Nat) (_he : 0 < e)
    (ha : a = q * e ^ 2 + r) (hr : r = b * c) :
    e * a = q * e ^ 3 + b * c * e := by
  calc
    e * a = e * (q * e ^ 2 + r) := by rw [ha]
    _ = e * (q * e ^ 2) + e * r := by rw [Nat.mul_add]
    _ = q * e ^ 3 + r * e := by
      simp [Nat.mul_comm, Nat.mul_left_comm, Nat.pow_succ]
    _ = q * e ^ 3 + b * c * e := by rw [hr, Nat.mul_comm]

/--
Lemma 2 — Schranke: wenn `r = b * c` und `r < e²`, dann `b * c < e²`.
-/
theorem e3_product_bound (e r b c : Nat) (hr : r = b * c) (hlt : r < e ^ 2) :
    b * c < e ^ 2 := by
  rw [← hr]
  exact hlt

/--
Struktur für die e³-Produktzerlegung: `n = q * e³ + b * c * e` mit `r = b * c`.
-/
structure E3ProductSplit (e a b c : Nat) where
  q : Nat := a / e ^ 2
  r : Nat := a % e ^ 2
  hrest : r = b * c
  hdecomp : e * a = q * e ^ 3 + b * c * e
  hbound : b * c < e ^ 2

theorem e3_product_split_rest_lt (e a b c : Nat) (he : 0 < e) (hrest : a % e ^ 2 = b * c) :
    b * c < e ^ 2 := by
  rw [← hrest]
  have he2 : 0 < e ^ 2 := by
    rw [Nat.pow_two]
    exact Nat.mul_pos he he
  exact Nat.mod_lt a he2

def e3ProductSplitOfPos (e a b c : Nat) (he : 0 < e) (hrest : a % e ^ 2 = b * c) :
    E3ProductSplit e a b c :=
  let q := a / e ^ 2
  let r := a % e ^ 2
  have ha : a = q * e ^ 2 + r := by
    rw [← Nat.mul_comm (e ^ 2) q]
    exact (Nat.div_add_mod a (e ^ 2)).symm
  have hr : r = b * c := hrest
  have he2 : 0 < e ^ 2 := by
    rw [Nat.pow_two]
    exact Nat.mul_pos he he
  {
    q := q
    r := r
    hrest := hr
    hdecomp := e3_product_decomposition e a q r b c he ha hr
    hbound := e3_product_bound e r b c hr (Nat.mod_lt a he2)
  }

end KeplerHurwitz
