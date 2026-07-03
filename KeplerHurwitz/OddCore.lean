import Mathlib

namespace KeplerHurwitz

/--
Ungerader Kern von `n`: der Anteil von `n`, der nicht mehr durch `2` teilbar ist.
Defensiv als Quotient über die 2-adische Faktoranzahl formuliert.
-/
def oddCore (n : Nat) : Nat := n / 2 ^ (Nat.factorization n 2)

theorem oddCore_eq_ordCompl (n : Nat) : oddCore n = ordCompl[2] n := by
  rfl

/--
Interface-Struktur für eine Normschalen-Zerlegung.
Sie kapselt nur die benötigten Aussagen, ohne Implementierungsdetails.
-/
structure OddCoreDecomposition (n : Nat) where
  k : Nat
  m : Nat
  hm_odd : m % 2 = 1
  hdecomp : n = 2 ^ k * m

theorem exists_pow_two_mul_oddCore (n : Nat) :
    ∃ k, n = 2 ^ k * oddCore n := by
  refine ⟨n.factorization 2, ?_⟩
  simpa [oddCore_eq_ordCompl] using (Nat.ordProj_mul_ordCompl_eq_self n 2).symm

theorem odd_oddCore (n : Nat) (hn : n ≠ 0) :
    Odd (oddCore n) := by
  have hnot : ¬2 ∣ oddCore n := by
    simpa [oddCore_eq_ordCompl] using (Nat.not_dvd_ordCompl Nat.prime_two hn)
  refine Nat.not_even_iff_odd.mp ?_
  intro hEven
  exact hnot (Even.two_dvd hEven)

theorem oddCore_two_pow_mul (k m : Nat) (hm : Odd m) :
    oddCore (2 ^ k * m) = m := by
  have hm_not_dvd : ¬2 ∣ m := hm.not_two_dvd_nat
  simpa [oddCore_eq_ordCompl] using
    (Nat.ordCompl_pow_mul_of_not_dvd (k := k) (p := 2) Nat.prime_two hm_not_dvd)

theorem oddCore_odd_of_pos (hn : 0 < n) :
    Odd (oddCore n) := by
  exact odd_oddCore n (Nat.pos_iff_ne_zero.mp hn)

def oddCoreDecompositionOfPos (hn : 0 < n) :
    OddCoreDecomposition n := by
  refine
    { k := n.factorization 2
      m := oddCore n
      hm_odd := ?_
      hdecomp := ?_ }
  · exact Nat.odd_iff.mp (oddCore_odd_of_pos hn)
  · simpa [oddCore_eq_ordCompl] using (Nat.ordProj_mul_ordCompl_eq_self n 2).symm

/--
Notationelle Brücke zur klassischen ν₂-Sprache:
Der Exponent `k` der kanonischen Zerlegung ist genau `padicValNat 2 n`.
-/
lemma oddCoreDecomposition_k_eq_nu2 (n : Nat) (hn : 0 < n) :
    (oddCoreDecompositionOfPos hn).k = padicValNat 2 n := by
  simp [oddCoreDecompositionOfPos, Nat.factorization_def, Nat.prime_two]

end KeplerHurwitz
