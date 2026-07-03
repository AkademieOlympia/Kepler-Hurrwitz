import Mathlib
import KeplerHurwitz.CollatzProofAttemptV2

namespace KeplerHurwitz

namespace CollatzAttemptV2
namespace BadRuns

/--
Praezises Restklassen-Interface fuer "bad runs":
`BadRunResidue r n` bedeutet `n ≡ -1 (mod 2^(r+3))`.
-/
def BadRunResidue (r n : Nat) : Prop :=
  n % (2 ^ (r + 3)) = 2 ^ (r + 3) - 1

/--
`n` bleibt bis Tiefe `r` im bad-run-Kanal, aber nicht auf der naechsten Tiefe.
-/
def BadRunBreaksAt (r n : Nat) : Prop :=
  BadRunResidue r n ∧ ¬ BadRunResidue (r + 1) n

/--
Existenz eines endlichen Abbruchniveaus der bad-run-Restklassentreppe.
-/
def HasFiniteBadRunBreak (n : Nat) : Prop :=
  ∃ r, BadRunBreaksAt r n

/--
Offene globale Hypothese: jede ungerade Zahl besitzt eine endliche bad-run-Abbruchtiefe.
-/
def BadRunFiniteBreakHypothesis : Prop :=
  ∀ n, n % 2 = 1 → ∃ r, BadRunBreaksAt r n

/--
Schwaechere Hypothese nur fuer den offenen `mod 4 = 3`-Zweig.
-/
def BadRunFiniteBreakHypothesisFromMod3 : Prop :=
  ∀ n, n % 4 = 3 → ∃ r, BadRunBreaksAt r n

/--
Allgemeines Ziel-Interface fuer den bad-run-Abstieg um eine Zweierpotenzstufe.
Ohne globalen Beweisanspruch in dieser Datei.
-/
def BadRunDescentGeneralStatement : Prop :=
  ∀ {m n : Nat},
    3 ≤ m →
    n % (2 ^ m) = 2 ^ m - 1 →
    T_odd n % (2 ^ (m - 1)) = 2 ^ (m - 1) - 1

/--
Iterated bad-run descent target.
If `n` starts in the bad-run residue class `-1 mod 2^m`,
then after `r` applications of `T_odd` it should lie in the residue class
`-1 mod 2^(m-r)`.
This is an interface/target statement only. It is deliberately not used
as a global Collatz claim.
-/
def BadRunIteratedDescentStatement : Prop :=
  ∀ {m r n : Nat},
    3 ≤ m →
    r ≤ m - 3 →
    n % (2 ^ m) = 2 ^ m - 1 →
    (T_odd^[r]) n % (2 ^ (m - r)) =
      2 ^ (m - r) - 1

/--
Endpoint form of the bad-run chain.
Starting from `-1 mod 2^m`, after `m - 2` odd steps one reaches
the persistent bad branch `3 mod 4`.
This is kept as an interface only.
-/
def BadRunIteratedEndpointMod4Statement : Prop :=
  ∀ {m n : Nat},
    3 ≤ m →
    n % (2 ^ m) = 2 ^ m - 1 →
    (T_odd^[m - 2]) n % 4 = 3

def T_odd_iter (r n : Nat) : Nat :=
  (T_odd^[r]) n

theorem exists_eq_sixteen_mul_add_fifteen_of_mod16_eq_fifteen
    {n : Nat}
    (hmod : n % 16 = 15) :
    ∃ k, n = 16 * k + 15 := by
  refine ⟨n / 16, ?_⟩
  calc
    n = n % 16 + 16 * (n / 16) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n 16).symm
    _ = 15 + 16 * (n / 16) := by simp [hmod]
    _ = 16 * (n / 16) + 15 := by omega

theorem T_odd_of_sixteen_mul_add_fifteen
    (k : Nat) :
    T_odd (16 * k + 15) = 24 * k + 23 := by
  unfold T_odd
  omega

theorem T_odd_mod8_eq_seven_of_mod16_eq_fifteen
    {n : Nat}
    (hmod : n % 16 = 15) :
    T_odd n % 8 = 7 := by
  rcases exists_eq_sixteen_mul_add_fifteen_of_mod16_eq_fifteen hmod with ⟨k, rfl⟩
  rw [T_odd_of_sixteen_mul_add_fifteen]
  omega

theorem exists_eq_thirtytwo_mul_add_thirtyone_of_mod32_eq_thirtyone
    {n : Nat}
    (hmod : n % 32 = 31) :
    ∃ k, n = 32 * k + 31 := by
  refine ⟨n / 32, ?_⟩
  calc
    n = n % 32 + 32 * (n / 32) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n 32).symm
    _ = 31 + 32 * (n / 32) := by simp [hmod]
    _ = 32 * (n / 32) + 31 := by omega

theorem T_odd_of_thirtytwo_mul_add_thirtyone
    (k : Nat) :
    T_odd (32 * k + 31) = 48 * k + 47 := by
  unfold T_odd
  omega

theorem T_odd_mod16_eq_fifteen_of_mod32_eq_thirtyone
    {n : Nat}
    (hmod : n % 32 = 31) :
    T_odd n % 16 = 15 := by
  rcases exists_eq_thirtytwo_mul_add_thirtyone_of_mod32_eq_thirtyone hmod with ⟨k, rfl⟩
  rw [T_odd_of_thirtytwo_mul_add_thirtyone]
  omega

theorem exists_eq_sixtyfour_mul_add_sixtythree_of_mod64_eq_sixtythree
    {n : Nat}
    (hmod : n % 64 = 63) :
    ∃ k, n = 64 * k + 63 := by
  refine ⟨n / 64, ?_⟩
  calc
    n = n % 64 + 64 * (n / 64) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n 64).symm
    _ = 63 + 64 * (n / 64) := by simp [hmod]
    _ = 64 * (n / 64) + 63 := by omega

theorem T_odd_of_sixtyfour_mul_add_sixtythree
    (k : Nat) :
    T_odd (64 * k + 63) = 96 * k + 95 := by
  unfold T_odd
  omega

theorem T_odd_mod32_eq_thirtyone_of_mod64_eq_sixtythree
    {n : Nat}
    (hmod : n % 64 = 63) :
    T_odd n % 32 = 31 := by
  rcases exists_eq_sixtyfour_mul_add_sixtythree_of_mod64_eq_sixtythree hmod with ⟨k, rfl⟩
  rw [T_odd_of_sixtyfour_mul_add_sixtythree]
  omega

theorem T_odd_twice_mod8_eq_seven_of_mod32_eq_thirtyone
    {n : Nat}
    (hmod : n % 32 = 31) :
    T_odd (T_odd n) % 8 = 7 := by
  have h1 : T_odd n % 16 = 15 :=
    T_odd_mod16_eq_fifteen_of_mod32_eq_thirtyone hmod
  exact T_odd_mod8_eq_seven_of_mod16_eq_fifteen h1

theorem T_odd_twice_mod16_eq_fifteen_of_mod64_eq_sixtythree
    {n : Nat}
    (hmod : n % 64 = 63) :
    T_odd (T_odd n) % 16 = 15 := by
  have h1 : T_odd n % 32 = 31 :=
    T_odd_mod32_eq_thirtyone_of_mod64_eq_sixtythree hmod
  exact T_odd_mod16_eq_fifteen_of_mod32_eq_thirtyone h1

theorem T_odd_three_mod8_eq_seven_of_mod64_eq_sixtythree
    {n : Nat}
    (hmod : n % 64 = 63) :
    T_odd (T_odd (T_odd n)) % 8 = 7 := by
  have h1 : T_odd n % 32 = 31 :=
    T_odd_mod32_eq_thirtyone_of_mod64_eq_sixtythree hmod
  have h2 : T_odd (T_odd n) % 16 = 15 :=
    T_odd_mod16_eq_fifteen_of_mod32_eq_thirtyone h1
  exact T_odd_mod8_eq_seven_of_mod16_eq_fifteen h2

theorem T_odd_four_bad_mod4_of_mod64_eq_sixtythree
    {n : Nat}
    (hmod : n % 64 = 63) :
    T_odd (T_odd (T_odd (T_odd n))) % 4 = 3 := by
  have h3 : T_odd (T_odd (T_odd n)) % 8 = 7 :=
    T_odd_three_mod8_eq_seven_of_mod64_eq_sixtythree hmod
  exact T_odd_mod4_eq_three_of_mod8_eq_seven h3

theorem exists_eq_pow_two_mul_add_pow_two_sub_one_of_mod_eq_pow_two_sub_one
    {m n : Nat}
    (hmod : n % (2 ^ m) = 2 ^ m - 1) :
    ∃ k, n = 2 ^ m * k + (2 ^ m - 1) := by
  refine ⟨n / (2 ^ m), ?_⟩
  calc
    n = n % (2 ^ m) + (2 ^ m) * (n / (2 ^ m)) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n (2 ^ m)).symm
    _ = (2 ^ m - 1) + (2 ^ m) * (n / (2 ^ m)) := by simp [hmod]
    _ = 2 ^ m * (n / (2 ^ m)) + (2 ^ m - 1) := by omega

theorem T_odd_of_pow_two_mul_add_pow_two_sub_one
    (m k : Nat)
    (hm : 1 ≤ m) :
    T_odd (2 ^ m * k + (2 ^ m - 1))
      =
    3 * 2 ^ (m - 1) * k + (3 * 2 ^ (m - 1) - 1) := by
  cases m with
  | zero =>
      cases hm
  | succ m =>
      let u : Nat := 2 ^ m
      let t : Nat := u * k
      let r : Nat := 3 * t + (3 * u - 1)
      unfold T_odd
      have hu : 2 ^ m = u := rfl
      have hk2 : u * 2 * k = 2 * t := by
        calc
          u * 2 * k = 2 * (u * k) := by ring
          _ = 2 * t := by simp [t]
      have hnum :
          3 * (2 ^ (Nat.succ m) * k + (2 ^ (Nat.succ m) - 1)) + 1 = 2 * r := by
        rw [Nat.pow_succ]
        rw [hu, hk2]
        have hu2 : u * 2 = 2 * u := by omega
        rw [hu2]
        change 3 * (2 * t + (2 * u - 1)) + 1 = 2 * r
        simp [r]
        have hu_pos : 0 < u := by
          simp [u]
        have hu_one : 1 ≤ u := Nat.succ_le_of_lt hu_pos
        omega
      rw [hnum]
      calc
        (2 * r) / 2 = r := by simpa using (Nat.mul_div_right r 2)
        _ = 3 * 2 ^ m * k + (3 * 2 ^ m - 1) := by
              simp [r, t, u, Nat.mul_assoc, Nat.mul_comm]

theorem three_mul_q_mul_k_add_three_mul_q_sub_one_mod_q
    (q k : Nat)
    (hq : 0 < q) :
    (3 * q * k + (3 * q - 1)) % q = q - 1 := by
  have hdecomp : 3 * q * k + (3 * q - 1) = q * (3 * k + 2) + (q - 1) := by
    calc
      3 * q * k + (3 * q - 1)
          = 3 * q * k + (2 * q + (q - 1)) := by omega
      _ = q * (3 * k + 2) + (q - 1) := by ring
  have hlt : q - 1 < q := by omega
  calc
    (3 * q * k + (3 * q - 1)) % q
        = (q * (3 * k + 2) + (q - 1)) % q := by simpa [hdecomp]
    _ = ((q * (3 * k + 2)) % q + (q - 1) % q) % q := by rw [Nat.add_mod]
    _ = (0 + (q - 1) % q) % q := by simp [Nat.mul_mod_right]
    _ = (q - 1) % q := by simp
    _ = q - 1 := Nat.mod_eq_of_lt hlt

theorem T_odd_bad_residue_descends
    {m n : Nat}
    (hm : 3 ≤ m)
    (hmod : n % (2 ^ m) = 2 ^ m - 1) :
    T_odd n % (2 ^ (m - 1)) = 2 ^ (m - 1) - 1 := by
  rcases exists_eq_pow_two_mul_add_pow_two_sub_one_of_mod_eq_pow_two_sub_one
      (m := m) (n := n) hmod with ⟨k, rfl⟩
  rw [T_odd_of_pow_two_mul_add_pow_two_sub_one m k (by omega)]
  exact three_mul_q_mul_k_add_three_mul_q_sub_one_mod_q
    (q := 2 ^ (m - 1))
    (k := k)
    (by positivity)

/--
One-step induction bridge for the iterated bad-run descent.
If after `r` applications of `T_odd` the orbit lies in the bad-run residue
class `-1 mod 2^(m-r)`, and the current modulus level is at least `2^3`,
then after one additional `T_odd` step it lies in
`-1 mod 2^(m-r-1)`.
This is a local 2-adic descent lemma only. It is not a global Collatz claim.
-/
theorem bad_run_iterated_descent_step
    {m r n : Nat}
    (hlevel : 3 ≤ m - r)
    (hres :
      (T_odd^[r]) n % (2 ^ (m - r)) =
        2 ^ (m - r) - 1) :
    (T_odd^[r + 1]) n % (2 ^ (m - r - 1)) =
      2 ^ (m - r - 1) - 1 := by
  have h :=
    T_odd_bad_residue_descends
      (m := m - r)
      (n := (T_odd^[r]) n)
      hlevel
      hres
  rw [Function.iterate_succ_apply']
  exact h

/--
Iterated bad-run descent.
Starting in the residue class `-1 mod 2^m`, after `r` applications of
`T_odd` the orbit lies in `-1 mod 2^(m-r)`, as long as `r ≤ m - 3`.
This is still a local 2-adic bad-run statement, not a global Collatz claim.
-/
theorem bad_run_iterated_descent
    {m r n : Nat}
    (hm : 3 ≤ m)
    (hr : r ≤ m - 3)
    (hmod : n % (2 ^ m) = 2 ^ m - 1) :
    (T_odd^[r]) n % (2 ^ (m - r)) =
      2 ^ (m - r) - 1 := by
  induction r generalizing m n with
  | zero =>
      simp only [Function.iterate_zero]
      exact hmod
  | succ r ih =>
      have hr_prev : r ≤ m - 3 := by omega
      have ih' :
          (T_odd^[r]) n % (2 ^ (m - r)) =
            2 ^ (m - r) - 1 :=
        ih hm hr_prev hmod
      have hlevel : 3 ≤ m - r := by omega
      have hstep :=
        bad_run_iterated_descent_step
          (m := m)
          (r := r)
          (n := n)
          hlevel
          ih'
      have hiter : T_odd^[Nat.succ r] n = T_odd^[r + 1] n := rfl
      have hsub : m - Nat.succ r = m - r - 1 := by omega
      rw [hiter, hsub]
      exact hstep

theorem bad_run_iterated_descent_statement_holds :
    BadRunIteratedDescentStatement := by
  intro m r n hm hr hmod
  exact bad_run_iterated_descent hm hr hmod

/--
Endpoint theorem for the iterated bad-run chain.
Starting in the residue class `-1 mod 2^m`, after `m - 2`
applications of `T_odd` the orbit reaches the persistent bad branch
`3 mod 4`.
This is a local 2-adic endpoint statement only, not a global Collatz claim.
-/
theorem bad_run_iterated_endpoint_mod4
    {m n : Nat}
    (hm : 3 ≤ m)
    (hmod : n % (2 ^ m) = 2 ^ m - 1) :
    (T_odd^[m - 2]) n % 4 = 3 := by
  have hres8 :
      (T_odd^[m - 3]) n % (2 ^ (m - (m - 3))) =
        2 ^ (m - (m - 3)) - 1 :=
    bad_run_iterated_descent
      (m := m)
      (r := m - 3)
      (n := n)
      hm
      (by omega)
      hmod
  have hres8' : (T_odd^[m - 3]) n % 8 = 7 := by
    have hsub : m - (m - 3) = 3 := by omega
    simpa [hsub] using hres8
  have hnext :
      T_odd ((T_odd^[m - 3]) n) % 4 = 3 :=
    T_odd_mod4_eq_three_of_mod8_eq_seven hres8'
  have hidx : m - 2 = m - 3 + 1 := by omega
  rw [hidx]
  rw [Function.iterate_succ_apply']
  exact hnext

theorem bad_run_iterated_endpoint_mod4_statement_holds :
    BadRunIteratedEndpointMod4Statement := by
  intro m n hm hmod
  exact bad_run_iterated_endpoint_mod4 hm hmod

/--
Regression bridge: Der konkrete `%16 -> %8`-Schritt folgt aus dem allgemeinen
2-adischen Descent-Satz. Das handparametrisierte Lemma bleibt als robuster
Low-Level-Arithmetiktest bewusst erhalten.
-/
theorem T_odd_mod8_eq_seven_of_mod16_eq_fifteen_from_general
    {n : Nat}
    (hmod : n % 16 = 15) :
    T_odd n % 8 = 7 := by
  have hmod' : n % (2 ^ 4) = 2 ^ 4 - 1 := by
    norm_num
    exact hmod
  have h :
      T_odd n % (2 ^ (4 - 1)) = 2 ^ (4 - 1) - 1 :=
    T_odd_bad_residue_descends
      (m := 4)
      (n := n)
      (by norm_num)
      hmod'
  norm_num at h
  exact h

/--
Regression bridge: Der konkrete `%32 -> %16`-Schritt folgt aus dem allgemeinen
2-adischen Descent-Satz.
-/
theorem T_odd_mod16_eq_fifteen_of_mod32_eq_thirtyone_from_general
    {n : Nat}
    (hmod : n % 32 = 31) :
    T_odd n % 16 = 15 := by
  have hmod' : n % (2 ^ 5) = 2 ^ 5 - 1 := by
    norm_num
    exact hmod
  have h :
      T_odd n % (2 ^ (5 - 1)) = 2 ^ (5 - 1) - 1 :=
    T_odd_bad_residue_descends
      (m := 5)
      (n := n)
      (by norm_num)
      hmod'
  norm_num at h
  exact h

/--
Regression bridge: Der konkrete `%64 -> %32`-Schritt folgt aus dem allgemeinen
2-adischen Descent-Satz.
-/
theorem T_odd_mod32_eq_thirtyone_of_mod64_eq_sixtythree_from_general
    {n : Nat}
    (hmod : n % 64 = 63) :
    T_odd n % 32 = 31 := by
  have hmod' : n % (2 ^ 6) = 2 ^ 6 - 1 := by
    norm_num
    exact hmod
  have h :
      T_odd n % (2 ^ (6 - 1)) = 2 ^ (6 - 1) - 1 :=
    T_odd_bad_residue_descends
      (m := 6)
      (n := n)
      (by norm_num)
      hmod'
  norm_num at h
  exact h

end BadRuns
end CollatzAttemptV2

end KeplerHurwitz
