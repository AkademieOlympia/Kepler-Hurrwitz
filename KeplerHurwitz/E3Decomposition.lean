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

/--
Symmetrischer Operator `S₊ = (b + c) / 2` (exakt wenn `b + c` gerade).
-/
def e3SPlus (b c : Nat) : Nat := (b + c) / 2

/--
Symmetrischer Operator `S₋ = |b - c| / 2 = dist(b,c) / 2` (exakt wenn gleiche Parität).
-/
def e3SMinus (b c : Nat) : Nat := Nat.dist b c / 2

theorem e3_same_parity_dist_even (b c : Nat) (hparity : (b + c) % 2 = 0) :
    Nat.dist b c % 2 = 0 := by
  have hmod : b % 2 = c % 2 := by omega
  rcases Nat.le_total b c with hbc | hcb
  · rw [Nat.dist_eq_sub_of_le hbc]
    omega
  · rw [Nat.dist_comm, Nat.dist_eq_sub_of_le hcb]
    omega

private theorem e3_binomial_four_bc (b c : Nat) :
    (b + c) ^ 2 - Nat.dist b c ^ 2 = 4 * b * c := by
  rcases Nat.le_total b c with hbc | hcb
  · have hdist : Nat.dist b c = c - b := Nat.dist_eq_sub_of_le hbc
    rw [hdist]
    have hadd : (b + c) ^ 2 = 4 * b * c + (c - b) ^ 2 := by
      apply Int.ofNat_inj.mp
      push_cast
      rw [Nat.cast_sub hbc]
      ring
    exact Nat.sub_eq_of_eq_add hadd
  · have hdist : Nat.dist b c = b - c := by
      rw [Nat.dist_comm]
      exact Nat.dist_eq_sub_of_le hcb
    rw [hdist]
    have hadd : (b + c) ^ 2 = 4 * b * c + (b - c) ^ 2 := by
      apply Int.ofNat_inj.mp
      push_cast
      rw [Nat.cast_sub hcb]
      ring
    exact Nat.sub_eq_of_eq_add hadd

private theorem e3_splus_sq_ge_sminus_sq (b c : Nat) (_hparity : (b + c) % 2 = 0) :
    e3SMinus b c ^ 2 ≤ e3SPlus b c ^ 2 := by
  unfold e3SPlus e3SMinus
  have hdist_le : Nat.dist b c ≤ b + c := by
    rcases Nat.le_total b c with hbc | hcb
    · rw [Nat.dist_eq_sub_of_le hbc]
      omega
    · rw [Nat.dist_comm, Nat.dist_eq_sub_of_le hcb]
      omega
  have hdiv : Nat.dist b c / 2 ≤ (b + c) / 2 := by gcongr
  exact Nat.pow_le_pow_left hdiv 2

/--
Lemma 3 — Kommutativer Produkt-Split: bei gleicher Parität (`(b + c) % 2 = 0`, d. h. `[b,c]=0`
im Nat-Ring) gilt `b * c = S₊² - S₋²` mit `S₊ = (b+c)/2`, `S₋ = dist(b,c)/2`.
-/
theorem e3_commutative_product_split (b c : Nat) (hparity : (b + c) % 2 = 0) :
    b * c = e3SPlus b c ^ 2 - e3SMinus b c ^ 2 := by
  unfold e3SPlus e3SMinus
  have hdist_even : 2 ∣ Nat.dist b c := by
    rw [Nat.dvd_iff_mod_eq_zero]
    exact e3_same_parity_dist_even b c hparity
  have hsum_even : 2 ∣ b + c := by
    rw [Nat.dvd_iff_mod_eq_zero]
    exact hparity
  have hfour := e3_binomial_four_bc b c
  have hsplus : (b + c) / 2 * 2 = b + c := Nat.div_mul_cancel hsum_even
  have hsminus : Nat.dist b c / 2 * 2 = Nat.dist b c := Nat.div_mul_cancel hdist_even
  have hfactor :
      ((b + c) / 2) ^ 2 * 4 - (Nat.dist b c / 2) ^ 2 * 4 =
        (b + c) ^ 2 - Nat.dist b c ^ 2 := by
    have h1 : ((b + c) / 2) ^ 2 * 4 = (b + c) ^ 2 := by
      calc
        ((b + c) / 2) ^ 2 * 4 = ((b + c) / 2 * 2) ^ 2 := by ring
        _ = (b + c) ^ 2 := by rw [hsplus]
    have h2 : (Nat.dist b c / 2) ^ 2 * 4 = Nat.dist b c ^ 2 := by
      calc
        (Nat.dist b c / 2) ^ 2 * 4 = (Nat.dist b c / 2 * 2) ^ 2 := by ring
        _ = Nat.dist b c ^ 2 := by rw [hsminus]
    rw [h1, h2]
  have hmul :
      (((b + c) / 2) ^ 2 - (Nat.dist b c / 2) ^ 2) * 4 =
        ((b + c) / 2) ^ 2 * 4 - (Nat.dist b c / 2) ^ 2 * 4 :=
    Nat.sub_mul (((b + c) / 2) ^ 2) ((Nat.dist b c / 2) ^ 2) 4
  have hsq_diff :
      ((b + c) / 2) ^ 2 - (Nat.dist b c / 2) ^ 2 = b * c := by
    apply Nat.mul_left_cancel (by decide : 0 < 4)
    rw [Nat.mul_comm, hmul, hfactor, hfour, ← Nat.mul_assoc]
  exact hsq_diff.symm

/--
Lemma 3 — Symmetrische Rest-Zerlegung: `r = b * c = S₊² - S₋²` unter gleicher Parität.
-/
theorem e3_symmetric_rest_decomposition (b c r : Nat) (hparity : (b + c) % 2 = 0)
    (hr : r = b * c) :
    r = e3SPlus b c ^ 2 - e3SMinus b c ^ 2 := by
  rw [hr]
  exact e3_commutative_product_split b c hparity

/--
Lemma 3 — Multiplet-Identität: `n = q * e³ + S₊² * e - S₋² * e` bei `a = q * e² + b * c`
und gleicher Parität von `b`, `c`.
-/
theorem e3_multiplet_identity (e a q b c : Nat) (_he : 0 < e) (hparity : (b + c) % 2 = 0)
    (ha : a = q * e ^ 2 + b * c) :
    e * a = q * e ^ 3 + e3SPlus b c ^ 2 * e - e3SMinus b c ^ 2 * e := by
  have hsplit := e3_commutative_product_split b c hparity
  calc
    e * a = e * (q * e ^ 2 + b * c) := by rw [ha]
    _ = e * (q * e ^ 2) + e * (b * c) := Nat.mul_add e (q * e ^ 2) (b * c)
    _ = q * e ^ 3 + b * c * e := by
      simp [Nat.mul_comm, Nat.mul_left_comm, Nat.pow_succ]
    _ = q * e ^ 3 + (e3SPlus b c ^ 2 - e3SMinus b c ^ 2) * e := by rw [← hsplit]
    _ = q * e ^ 3 + e3SPlus b c ^ 2 * e - e3SMinus b c ^ 2 * e := by
      rw [Nat.sub_mul]
      exact (Nat.add_sub_assoc
        (Nat.mul_le_mul_right e (e3_splus_sq_ge_sminus_sq b c hparity)) (q * e ^ 3)).symm

/--
Struktur für die e³-Multiplet-Zerlegung mit symmetrischen Operatoren `S₊`, `S₋`.
-/
structure E3CommutativeMultiplet (e a b c : Nat) where
  q : Nat := a / e ^ 2
  sPlus : Nat := e3SPlus b c
  sMinus : Nat := e3SMinus b c
  hparity : (b + c) % 2 = 0
  hrest : a % e ^ 2 = b * c
  hsplit : b * c = sPlus ^ 2 - sMinus ^ 2
  hdecomp : e * a = q * e ^ 3 + sPlus ^ 2 * e - sMinus ^ 2 * e
  hbound : b * c < e ^ 2

def e3CommutativeMultipletOfPos (e a b c : Nat) (he : 0 < e) (hparity : (b + c) % 2 = 0)
    (hrest : a % e ^ 2 = b * c) : E3CommutativeMultiplet e a b c :=
  let q := a / e ^ 2
  let sPlus := e3SPlus b c
  let sMinus := e3SMinus b c
  have ha : a = q * e ^ 2 + b * c := by
    have hr : a % e ^ 2 = b * c := hrest
    have hdiv : a = q * e ^ 2 + a % e ^ 2 := by
      rw [← Nat.mul_comm (e ^ 2) q]
      exact (Nat.div_add_mod a (e ^ 2)).symm
    rw [hdiv, hr]
  have he2 : 0 < e ^ 2 := by
    rw [Nat.pow_two]
    exact Nat.mul_pos he he
  {
    q := q
    sPlus := sPlus
    sMinus := sMinus
    hparity := hparity
    hrest := hrest
    hsplit := e3_commutative_product_split b c hparity
    hdecomp := e3_multiplet_identity e a q b c he hparity ha
    hbound := e3_product_bound e (a % e ^ 2) b c hrest (Nat.mod_lt a he2)
  }

end KeplerHurwitz
