import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenAttackV213
import KeplerHurwitz.OddCore

/-!
# Kanal-7 V2.14 — 2-adische Lift-Infrastruktur für `243r + 95`

Governance: `[A]` Ebene A (Generator; Ziel: allgemeines `j`); `[C]` Ebene B (Dynamik nach `S⁵`).

Leitformeln:

`Bewertungskaskade vollständig klassifizieren ≠ dynamischen Lift-Baum schließen`

`2-adische Struktur ≠ dynamischer Deszent`

Ebene A: eindeutiger 2-adischer Lift der **linearen** Kongruenz `243r + 95 ≡ 0 (mod 2^j)`
(243 invertierbar mod 2^j — präziser als allgemeiner Hensel-Lift).

**Governance:** die korrekte Generator-Invariante ist `2^j ∣ 243·ρ_j + 95` (plus `ρ_j < 2^j`),
**nicht** `ν_2(243·ρ_j + 95) = j`. Plateaus sind erlaubt (z. B. `ρ_5 = … = ρ_9 = 27`,
`ν_2(243·27 + 95) = 9 ≠ 5`).

Kanal-7-Kontext: im Zweig `k ≡ 1 (mod 4)` gilt `S⁵ = oddCore(243r + 95)` mit Multiplikator
`243 = 3⁵` und Konstante `95`; mod-256-Faser `{95}` nutzt dieselbe `243`-Skala in
`CollatzNetDescentMod8`.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214

open KeplerHurwitz
open KeplerHurwitz.Collatz.ChannelSevenAttackV213

/-- Kanal-7 Deep-Branch-Multiplikator: `243 = 3⁵`. -/
def deepBranchMultiplier : Nat := 243

/-- Kanal-7 Deep-Branch-Konstante im Zweig `k ≡ 1 (mod 4)`. -/
def deepBranchConstant : Nat := 95

/-- Modulus der `j`-ten Lift-Schale: `2^j`. -/
def deepLiftModulus (j : Nat) : Nat :=
  2 ^ j

/-- Deep-branch polynomial am fünften Kick. -/
def deepBranchPoly (r : Nat) : Nat :=
  deepBranchMultiplier * r + deepBranchConstant

theorem deepBranchPoly_eq (r : Nat) :
    deepBranchPoly r = 243 * r + 95 := by
  unfold deepBranchPoly deepBranchMultiplier deepBranchConstant
  rfl

theorem deepBranchPoly_pos (r : Nat) : 0 < deepBranchPoly r := by
  unfold deepBranchPoly deepBranchMultiplier deepBranchConstant
  omega

theorem deepBranchPoly_ne_zero (r : Nat) : deepBranchPoly r ≠ 0 :=
  deepBranchPoly_pos r |>.ne'

/-!
## padicValNat-Brücke (Ebene A — Bewertungsskala)

Modular sieve `deepLiftResidue_iff` charakterisiert Teilbarkeit; diese Schicht
übersetzt in die exakte Valuationssprache `ν_2`.
-/

/-- `p^j ∣ m ↔ j ≤ ν_p(m)` für `p` prim und `m ≠ 0`. -/
theorem pow_dvd_iff_le_padicValNat {p m j : Nat} (hp : p.Prime) (hm : m ≠ 0) :
    p ^ j ∣ m ↔ j ≤ padicValNat p m :=
  padicValNat_dvd_iff_le_of_ne_one hp.ne_one hm

private theorem two_pow_dvd_iff_le_padicValNat {m j : Nat} (hm : m ≠ 0) :
    2 ^ j ∣ m ↔ j ≤ padicValNat 2 m := by
  simpa using pow_dvd_iff_le_padicValNat (p := 2) (m := m) (j := j) Nat.prime_two hm

private theorem two_pow_succ_not_dvd_of_padicValNat_eq {m j : Nat}
    (hm : m ≠ 0) (heq : padicValNat 2 m = j) :
    ¬ 2 ^ (j + 1) ∣ m := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have h := pow_succ_padicValNat_not_dvd (p := 2) hm
  rwa [← heq]

lemma padicValNat_eight : padicValNat 2 8 = 3 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  rw [show (8 : Nat) = 2 ^ 3 from by decide, padicValNat.prime_pow]

/-- Schritt-5-Kick: `ν_2(8 · (243r + 95)) = 3 + ν_2(243r + 95)`. -/
theorem step5Kick_padicVal (r : Nat) :
    padicValNat 2 (8 * (243 * r + 95)) = 3 + padicValNat 2 (243 * r + 95) := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have h_pos : 243 * r + 95 ≠ 0 := by omega
  have h_eight : 8 ≠ 0 := by decide
  rw [padicValNat.mul h_eight h_pos, padicValNat_eight]

/-!
## Invertierbarkeit von `243` modulo `2^j` (Ebene A, ohne Dynamik)
-/

theorem deepBranchMultiplier_odd : deepBranchMultiplier % 2 = 1 := by decide

theorem deepBranchMultiplier_coprime_two : Nat.Coprime deepBranchMultiplier 2 := by decide

theorem deepBranchMultiplier_coprime_pow_two (j : Nat) :
    Nat.Coprime deepBranchMultiplier (deepLiftModulus j) := by
  cases j with
  | zero => simp [deepLiftModulus, deepBranchMultiplier_coprime_two]
  | succ j =>
    rw [deepLiftModulus, Nat.coprime_pow_right_iff (Nat.succ_pos j)]
    exact deepBranchMultiplier_coprime_two

theorem deepBranchMultiplier_isUnit_zmod (j : Nat) :
    IsUnit (deepBranchMultiplier : ZMod (deepLiftModulus j)) := by
  rw [ZMod.isUnit_iff_coprime, deepBranchMultiplier, deepLiftModulus]
  exact deepBranchMultiplier_coprime_pow_two j

/-!
## Lift-Generator (H5)

Eindeutiger 2-adischer Lift der linearen Kongruenz `243r + 95 ≡ 0 (mod 2^j)`.

Mit `q_j = (243·ρ_j + 95) / 2^j` und Lift-Bit `b ≡ q_j (mod 2)` (da `243 ≡ 1 (mod 2)`):
`ρ_{j+1} = ρ_j + b·2^j` mit `b = 0` falls `q_j` gerade, sonst `b = 1`.
Äquivalent: `ρ_{j+1} = ρ_j` falls `243·ρ_j + 95 ≡ 0 (mod 2^{j+1})`, sonst `ρ_j + 2^j`.

Die Rekursion garantiert `2^{j+1} ∣ 243·ρ_{j+1} + 95`, aber **nicht** `ν_2 = j+1`.
Der Parameter `j` ist der eigentliche Beitrag — nicht eine Fallliste.
-/

/-- Eindeutige Lift-Restklasse `ρ_j` modulo `2^j`. -/
def deepLiftResidue : Nat → Nat
  | 0 => 0
  | j + 1 =>
    let ρ := deepLiftResidue j
    let m := deepLiftModulus j
    let q := deepBranchPoly ρ / m
    if q % 2 = 0 then ρ else ρ + m

/-- Affine Quotientenkonstante `c_j = (243·ρ_j + 95) / 2^j`. -/
def deepLiftConstant (j : Nat) : Nat :=
  (deepBranchPoly (deepLiftResidue j)) / deepLiftModulus j

theorem deepLiftModulus_succ (j : Nat) :
    deepLiftModulus (j + 1) = 2 * deepLiftModulus j := by
  simp [deepLiftModulus, pow_succ, mul_comm]

theorem deepLiftModulus_pos (j : Nat) : 0 < deepLiftModulus j := by
  simp [deepLiftModulus, pow_pos]

private theorem deepBranchPoly_add_mod (r m : Nat) :
    deepBranchPoly (r + m) = deepBranchPoly r + deepBranchMultiplier * m := by
  unfold deepBranchPoly deepBranchMultiplier
  ring

/-- Lift-Restklasse bleibt strikt unter dem Modulus `2^j`. -/
theorem deepLiftResidue_lt (j : Nat) : deepLiftResidue j < deepLiftModulus j := by
  induction j with
  | zero => simp [deepLiftResidue, deepLiftModulus]
  | succ j ih =>
    dsimp [deepLiftResidue]
    split_ifs with h
    · have hlt : deepLiftModulus j < deepLiftModulus (j + 1) := by
        rw [deepLiftModulus_succ]
        have hmpos : 0 < deepLiftModulus j := deepLiftModulus_pos j
        omega
      exact lt_trans ih hlt
    · have hm : deepLiftModulus j = 2 ^ j := rfl
      have hρ : deepLiftResidue j < 2 ^ j := by simpa [hm] using ih
      have htwo : deepLiftModulus (j + 1) = 2 * 2 ^ j := by
        simp [deepLiftModulus, pow_succ, mul_comm]
      rw [htwo]
      omega

private theorem mul_dvd_mod_zero (a b : Nat) : (a * b) % a = 0 :=
  Nat.mul_mod_right a b

private theorem m_two_mul_mod_zero (m q : Nat) : (m * (2 * q)) % (2 * m) = 0 := by
  have h : 2 * m ∣ m * (2 * q) := ⟨q, by ring⟩
  exact Nat.mod_eq_zero_of_dvd h

private theorem two_q_mul_m_mod_zero (m q : Nat) : (2 * q * m) % (2 * m) = 0 := by
  have h : 2 * m ∣ 2 * q * m := ⟨q, by ring⟩
  exact Nat.mod_eq_zero_of_dvd h

private theorem deepLiftResidue_spec_succ (j : Nat)
    (ih : deepBranchPoly (deepLiftResidue j) % deepLiftModulus j = 0) :
    deepBranchPoly (deepLiftResidue (j + 1)) % deepLiftModulus (j + 1) = 0 := by
  dsimp [deepLiftResidue]
  set ρ := deepLiftResidue j
  set m := deepLiftModulus j
  have hm : deepLiftModulus (j + 1) = 2 * m := by
    dsimp [m]
    exact deepLiftModulus_succ j
  have hρm : deepBranchPoly ρ % m = 0 := by
    dsimp [ρ, m] at ih ⊢
    exact ih
  have hdvd : m ∣ deepBranchPoly ρ := Nat.dvd_of_mod_eq_zero hρm
  rcases hdvd with ⟨q, hq⟩
  have hqdef : deepBranchPoly ρ / m = q := by
    simpa [hq] using Nat.mul_div_cancel_left q (deepLiftModulus_pos j)
  split_ifs with hqeven
  · have htwo : 2 ∣ q := by
      rw [← hqdef]
      exact Nat.dvd_of_mod_eq_zero hqeven
    rcases htwo with ⟨t, ht⟩
    have hdiv : deepBranchPoly ρ % (2 * m) = 0 := by
      rw [hq, ht, mul_comm m (2 * t)]
      exact two_q_mul_m_mod_zero m t
    simpa [hm, ρ, m, hqdef] using hdiv
  · have hc_odd : q % 2 = 1 := by omega
    have hadd :
        deepBranchPoly (ρ + m) = deepBranchPoly ρ + deepBranchMultiplier * m :=
      deepBranchPoly_add_mod ρ m
    have hcore : deepBranchPoly (ρ + m) = (q + deepBranchMultiplier) * m := by
      rw [hadd, hq, add_mul, mul_comm m q, add_comm (q * m)]
    have hsum_even : (q + deepBranchMultiplier) % 2 = 0 := by
      have hm_odd : deepBranchMultiplier % 2 = 1 := deepBranchMultiplier_odd
      omega
    have hmod :
        deepBranchPoly (ρ + m) % (2 * m) = 0 := by
      rw [hcore]
      have htwo : 2 ∣ q + deepBranchMultiplier :=
        Nat.dvd_of_mod_eq_zero hsum_even
      rcases htwo with ⟨t, ht⟩
      rw [ht]
      exact two_q_mul_m_mod_zero m t
    simpa [hm, ρ, m, hqdef, hc_odd] using hmod

private theorem deepLiftResidue_mod_zero (j : Nat) :
    deepBranchPoly (deepLiftResidue j) % deepLiftModulus j = 0 := by
  induction j with
  | zero =>
    simp [deepLiftResidue, deepLiftModulus, deepBranchPoly, deepBranchConstant]
  | succ j ih =>
    exact deepLiftResidue_spec_succ j ih

/-- H1: Generator-Lösung für beliebiges `j` — Bound plus `2^j ∣ 243·ρ_j + 95` (Induktion). -/
theorem deepLiftResidue_spec (j : Nat) :
    deepLiftResidue j < deepLiftModulus j ∧
      deepLiftModulus j ∣ deepBranchPoly (deepLiftResidue j) := by
  refine ⟨deepLiftResidue_lt j, ?_⟩
  rw [Nat.dvd_iff_mod_eq_zero]
  exact deepLiftResidue_mod_zero j

theorem deepLiftResidue_one : deepLiftResidue 1 = 1 := by decide
theorem deepLiftResidue_two : deepLiftResidue 2 = 3 := by decide
theorem deepLiftResidue_three : deepLiftResidue 3 = 3 := by decide
theorem deepLiftResidue_four : deepLiftResidue 4 = 11 := by decide
theorem deepLiftResidue_five : deepLiftResidue 5 = 27 := by decide

/-- Plateau-Beispiel: `ρ_5 = … = ρ_9 = 27`; hier `ν_2(243·27 + 95) = 9 ≠ 5`. -/
theorem deepLiftResidue_five_nu2 :
    padicValNat 2 (deepBranchPoly (deepLiftResidue 5)) = 9 := by
  rw [deepLiftResidue_five, deepBranchPoly_eq]
  have hnum : 243 * 27 + 95 = 6656 := by decide
  rw [hnum]
  have hn : (6656 : Nat) ≠ 0 := by decide
  have h9 : 2 ^ 9 ∣ 6656 := by decide
  have hnot10 : ¬ 2 ^ 10 ∣ 6656 := by decide
  have hle9 : 9 ≤ padicValNat 2 6656 :=
    (padicValNat_dvd_iff_le (p := 2) (a := 6656) hn).1 h9
  have hnot10le : ¬ 10 ≤ padicValNat 2 6656 := by
    intro h10
    exact hnot10 ((padicValNat_dvd_iff_le (p := 2) (a := 6656) hn).2 h10)
  omega

theorem deepLiftResidue_six : deepLiftResidue 6 = 27 := by decide
theorem deepLiftResidue_seven : deepLiftResidue 7 = 27 := by decide
theorem deepLiftResidue_eight : deepLiftResidue 8 = 27 := by decide
theorem deepLiftResidue_nine : deepLiftResidue 9 = 27 := by decide

theorem deepLiftConstant_one : deepLiftConstant 1 = 169 := by decide
theorem deepLiftConstant_two : deepLiftConstant 2 = 206 := by decide
theorem deepLiftConstant_three : deepLiftConstant 3 = 103 := by decide
theorem deepLiftConstant_four : deepLiftConstant 4 = 173 := by decide
theorem deepLiftConstant_five : deepLiftConstant 5 = 208 := by decide

theorem deepLiftResidue_spec_one :
    deepBranchPoly (deepLiftResidue 1) % deepLiftModulus 1 = 0 := by decide

theorem deepLiftResidue_spec_two :
    deepBranchPoly (deepLiftResidue 2) % deepLiftModulus 2 = 0 := by decide

theorem deepLiftResidue_spec_three :
    deepBranchPoly (deepLiftResidue 3) % deepLiftModulus 3 = 0 := by decide

theorem deepLiftResidue_spec_four :
    deepBranchPoly (deepLiftResidue 4) % deepLiftModulus 4 = 0 := by decide

theorem deepLiftResidue_spec_five :
    deepBranchPoly (deepLiftResidue 5) % deepLiftModulus 5 = 0 := by decide

theorem deepLiftResidue_succ_compat_one :
    deepLiftResidue 2 % deepLiftModulus 1 = deepLiftResidue 1 := by decide

theorem deepLiftResidue_succ_compat_two :
    deepLiftResidue 3 % deepLiftModulus 2 = deepLiftResidue 2 := by decide

theorem deepLiftResidue_succ_compat_three :
    deepLiftResidue 4 % deepLiftModulus 3 = deepLiftResidue 3 := by decide

theorem deepLiftResidue_succ_compat_four :
    deepLiftResidue 5 % deepLiftModulus 4 = deepLiftResidue 4 := by decide

/-!
## Eindeutigkeit der Lift-Restklasse (Ebene A)
-/

private theorem deepLiftResidue_unique_of_lt {j r₁ r₂ : Nat}
    (hr₁ : r₁ < deepLiftModulus j) (hr₂ : r₂ < deepLiftModulus j)
    (hs₁ : deepBranchPoly r₁ % deepLiftModulus j = 0)
    (hs₂ : deepBranchPoly r₂ % deepLiftModulus j = 0) :
    r₁ = r₂ := by
  have h₁ : deepBranchPoly r₁ ≡ 0 [MOD deepLiftModulus j] := by
    rwa [Nat.ModEq]
  have h₂ : deepBranchPoly r₂ ≡ 0 [MOD deepLiftModulus j] := by
    rwa [Nat.ModEq]
  have hmul :
      deepBranchMultiplier * r₁ ≡ deepBranchMultiplier * r₂ [MOD deepLiftModulus j] := by
    simpa [deepBranchPoly] using
      Nat.ModEq.add_right_cancel' deepBranchConstant (h₁.trans h₂.symm)
  have hr : r₁ ≡ r₂ [MOD deepLiftModulus j] :=
    Nat.ModEq.cancel_left_of_coprime
      (by
        rw [Nat.gcd_comm]
        exact Nat.Coprime.gcd_eq_one (deepBranchMultiplier_coprime_pow_two j))
      hmul
  have hmod : r₁ % deepLiftModulus j = r₂ % deepLiftModulus j := hr
  rw [Nat.mod_eq_of_lt hr₁, Nat.mod_eq_of_lt hr₂] at hmod
  exact hmod

def DeepLiftResidueUnique (j : Nat) : Prop :=
  ∃! r : Nat, r < deepLiftModulus j ∧ deepBranchPoly r % deepLiftModulus j = 0

theorem existsUnique_deepLiftResidue_of_lt {j r : Nat}
    (hr : r < deepLiftModulus j)
    (hspec : deepBranchPoly r % deepLiftModulus j = 0) :
    DeepLiftResidueUnique j := by
  refine ⟨r, ⟨hr, hspec⟩, ?_⟩
  intro r' ⟨hr', hspec'⟩
  exact deepLiftResidue_unique_of_lt hr' hr hspec' hspec

/-- H1: Eindeutigkeit der Lift-Restklasse für beliebiges `j` (aus `deepLiftResidue_spec`). -/
theorem existsUnique_deepLiftResidue (j : Nat) : DeepLiftResidueUnique j := by
  refine ⟨deepLiftResidue j, ⟨deepLiftResidue_lt j, ?_⟩, ?_⟩
  · exact deepLiftResidue_mod_zero j
  intro r ⟨hr, hspec⟩
  exact deepLiftResidue_unique_of_lt hr (deepLiftResidue_lt j) hspec (deepLiftResidue_mod_zero j)

/-- Eindeutigkeit: die einzige Lösung `< 2^j` der Kongruenz ist `ρ_j`. -/
theorem deepLiftResidue_unique {j r : Nat}
    (hr : r < deepLiftModulus j)
    (hdvd : deepLiftModulus j ∣ deepBranchPoly r) :
    r = deepLiftResidue j :=
  deepLiftResidue_unique_of_lt hr (deepLiftResidue_lt j)
    (Nat.mod_eq_zero_of_dvd hdvd) (deepLiftResidue_mod_zero j)

private theorem deepBranchPoly_mod_eq_residue (j r : Nat) :
    deepBranchPoly r % deepLiftModulus j =
      deepBranchPoly (r % deepLiftModulus j) % deepLiftModulus j := by
  set m := deepLiftModulus j
  have h := (Nat.mod_modEq r m).mul_left deepBranchMultiplier |>.add_right deepBranchConstant
  exact h.symm

private theorem deepBranchPoly_mod_zero_of_residue_mod (j r : Nat)
    (hmod : r % deepLiftModulus j = deepLiftResidue j) :
    deepBranchPoly r % deepLiftModulus j = 0 := by
  rw [deepBranchPoly_mod_eq_residue]
  rw [hmod]
  exact deepLiftResidue_mod_zero j

/-- Kongruenzcharakterisierung: `2^j ∣ 243r + 95` iff Restklasse `ρ_j`. -/
theorem deepLiftResidue_iff (j r : Nat) :
    deepLiftModulus j ∣ deepBranchPoly r ↔ r % deepLiftModulus j = deepLiftResidue j := by
  constructor
  · intro hdvd
    set d := r % deepLiftModulus j
    have hdlt : d < deepLiftModulus j := Nat.mod_lt r (deepLiftModulus_pos j)
    have hzero : deepBranchPoly d % deepLiftModulus j = 0 := by
      rw [← deepBranchPoly_mod_eq_residue]
      exact Nat.mod_eq_zero_of_dvd hdvd
    exact deepLiftResidue_unique_of_lt hdlt (deepLiftResidue_lt j) hzero
      (deepLiftResidue_mod_zero j)
  · intro hmod
    rw [Nat.dvd_iff_mod_eq_zero]
    exact deepBranchPoly_mod_zero_of_residue_mod j r hmod

/-- Schwache Bewertungsuntergrenze am Generator: `j ≤ ν_2(243·ρ_j + 95)` (nicht Gleichheit). -/
theorem deepLiftResidue_val_ge (j : Nat) :
    j ≤ padicValNat 2 (deepBranchPoly (deepLiftResidue j)) := by
  rcases j with - | j
  · simp [deepLiftResidue, deepLiftModulus, deepBranchPoly, deepBranchConstant,
      deepBranchMultiplier]
  · have hne : deepBranchPoly (deepLiftResidue (j + 1)) ≠ 0 := by
      unfold deepBranchPoly deepBranchMultiplier deepBranchConstant
      have := deepLiftResidue_lt (j + 1)
      omega
    have hdvd := (deepLiftResidue_spec (j + 1)).2
    exact (padicValNat_dvd_iff_le (p := 2)
      (a := deepBranchPoly (deepLiftResidue (j + 1))) hne).1 hdvd

theorem existsUnique_deepLiftResidue_one : DeepLiftResidueUnique 1 := by
  refine ⟨1, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 1 = 2 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 1 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_two : DeepLiftResidueUnique 2 := by
  refine ⟨3, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 2 = 4 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 3 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_three : DeepLiftResidueUnique 3 := by
  refine ⟨3, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 3 = 8 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 7 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_four : DeepLiftResidueUnique 4 := by
  refine ⟨11, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 4 = 16 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 15 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_five : DeepLiftResidueUnique 5 := by
  refine ⟨27, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 5 = 32 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 31 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

/-!
## Bewertungscharakterisierung und affine Terminalform (Ebene A — Ziele)

Korrekte Zielaussagen (keine falsche Identität `ν_2 = j` am Generator):

- `ν_2(243r + 95) ≥ j` ↔ `r ≡ ρ_j (mod 2^j)` (`nu2_deepBranch_ge_iff`)
- `ν_2(243r + 95) = j` ↔ `r ≡ ρ_j (mod 2^j)` und `r ≢ ρ_{j+1} (mod 2^{j+1})`
  (`nu2_deepBranch_eq_iff`)

Plateau-Beispiel: `ρ_5 = 27`, aber `ν_2(243·27 + 95) = ν_2(6656) = 9`.
-/

/-- H2: Bewertungsuntergrenze — `ν_2(243r+95) ≥ j` iff modulares Sieb `ρ_j`. -/
theorem nu2_deepBranch_ge_iff (j r : Nat) :
    j ≤ padicValNat 2 (deepBranchPoly r) ↔
      r % deepLiftModulus j = deepLiftResidue j := by
  have hm := deepBranchPoly_ne_zero r
  rw [← deepLiftResidue_iff, deepLiftModulus, two_pow_dvd_iff_le_padicValNat hm]

/-- H2: exakte Bewertungsschale — Plateau via fehlgeschlagenem Lift auf `j+1`. -/
theorem nu2_deepBranch_eq_iff (j r : Nat) :
    padicValNat 2 (deepBranchPoly r) = j ↔
      r % deepLiftModulus j = deepLiftResidue j ∧
        r % deepLiftModulus (j + 1) ≠ deepLiftResidue (j + 1) := by
  have hm := deepBranchPoly_ne_zero r
  constructor
  · intro heq
    constructor
    · exact (nu2_deepBranch_ge_iff j r).1 (le_of_eq heq.symm)
    · intro hmod
      have hdvd : deepLiftModulus (j + 1) ∣ deepBranchPoly r :=
        (deepLiftResidue_iff (j + 1) r).2 hmod
      have hge : j + 1 ≤ padicValNat 2 (deepBranchPoly r) := by
        rw [deepLiftModulus] at hdvd
        exact (two_pow_dvd_iff_le_padicValNat hm).1 hdvd
      omega
  · intro ⟨hmod_j, hnot_mod_succ⟩
    have hj_le : j ≤ padicValNat 2 (deepBranchPoly r) :=
      (nu2_deepBranch_ge_iff j r).2 hmod_j
    have hnot_succ : ¬ j + 1 ≤ padicValNat 2 (deepBranchPoly r) := by
      intro hge
      have hdvd : 2 ^ (j + 1) ∣ deepBranchPoly r :=
        (two_pow_dvd_iff_le_padicValNat hm).2 hge
      have hmod : r % deepLiftModulus (j + 1) = deepLiftResidue (j + 1) := by
        rw [deepLiftModulus]
        exact (deepLiftResidue_iff (j + 1) r).1 hdvd
      exact hnot_mod_succ hmod
    omega

/-- H4: affine Faktorisierung bei `r = ρ_j + 2^j t`. -/
theorem deepLift_affine_factorization (j t : Nat) :
    deepBranchPoly (deepLiftResidue j + deepLiftModulus j * t) =
      deepLiftModulus j * (deepBranchMultiplier * t + deepLiftConstant j) := by
  set ρ := deepLiftResidue j
  set m := deepLiftModulus j
  set c := deepLiftConstant j
  have hdvd : m ∣ deepBranchPoly ρ := (deepLiftResidue_spec j).2
  have hc : deepBranchPoly ρ / m = c := rfl
  have hq : deepBranchPoly ρ = m * c := by
    rw [← hc, Nat.mul_div_cancel' hdvd]
  calc
    deepBranchPoly (ρ + m * t)
        = deepBranchPoly ρ + deepBranchMultiplier * (m * t) := by
            rw [deepBranchPoly_add_mod ρ (m * t)]
    _ = m * c + deepBranchMultiplier * (m * t) := by rw [hq]
    _ = m * (c + deepBranchMultiplier * t) := by ring
    _ = m * (deepBranchMultiplier * t + c) := by ring

theorem deepLift_terminal_affine (j t : Nat) :
    deepBranchPoly (deepLiftResidue j + deepLiftModulus j * t) =
      deepLiftModulus j * (deepBranchMultiplier * t + deepLiftConstant j) :=
  deepLift_affine_factorization j t

private theorem deepLift_affine_quotient_odd_of_exactVal (j t : Nat)
    (heq : padicValNat 2 (deepBranchPoly (deepLiftResidue j + deepLiftModulus j * t)) = j) :
    Odd (deepBranchMultiplier * t + deepLiftConstant j) := by
  set q := deepBranchMultiplier * t + deepLiftConstant j
  set r := deepLiftResidue j + deepLiftModulus j * t
  have hm := deepBranchPoly_ne_zero r
  have hnot : ¬ 2 ^ (j + 1) ∣ deepBranchPoly r :=
    two_pow_succ_not_dvd_of_padicValNat_eq hm heq
  refine Nat.not_even_iff_odd.mp ?_
  intro hEven
  have h2 := Even.two_dvd hEven
  rcases h2 with ⟨u, hu⟩
  have haff := deepLift_affine_factorization j t
  have hpow : 2 ^ (j + 1) ∣ deepBranchPoly (deepLiftResidue j + deepLiftModulus j * t) := by
    rw [haff, show deepBranchMultiplier * t + deepLiftConstant j = q from rfl, hu,
      deepLiftModulus, pow_succ]
    exact ⟨u, by simp [mul_assoc, mul_comm, mul_left_comm]⟩
  exact hnot (by simpa [r] using hpow)

/-- Bei exakter Valuation `j` ist der affine Quotient `243t + c_j` ungerade. -/
theorem odd_of_exact_padicVal (j t : Nat)
    (heq : padicValNat 2 (deepBranchPoly (deepLiftResidue j + deepLiftModulus j * t)) = j) :
    Odd (deepBranchMultiplier * t + deepLiftConstant j) :=
  deepLift_affine_quotient_odd_of_exactVal j t heq

/-- H4 + oddCore: bei exakter Valuation `j` ist `oddCore(243r+95) = 243t + c_j`. -/
theorem deepLift_terminal_of_exactVal (j r t : Nat)
    (hr : r = deepLiftResidue j + deepLiftModulus j * t)
    (heq : padicValNat 2 (deepBranchPoly r) = j) :
    oddCore (deepBranchPoly r) = deepBranchMultiplier * t + deepLiftConstant j := by
  rw [hr, deepLift_affine_factorization]
  have hodd := odd_of_exact_padicVal j t (by simpa [hr] using heq)
  rw [deepLiftModulus, oddCore_two_pow_mul j _ hodd]

/-- Exakte Valuation `j` ↔ fehlgeschlagener Lift auf Schale `j+1`. -/
theorem deepLift_terminal_next_lift_fails (j r : Nat)
    (heq : padicValNat 2 (deepBranchPoly r) = j) :
    r % deepLiftModulus (j + 1) ≠ deepLiftResidue (j + 1) :=
  (nu2_deepBranch_eq_iff j r).1 heq |>.2

theorem channelSeven71_step5_certificate_link (r : Nat) :
    3 * (162 * (4 * r + 1) + 91) + 1 = 2 ^ 3 * deepBranchPoly r :=
  channelSeven71_step5_certificate_mod4_one r

/-- Scaffold-Status: Generator + Ebene-A-Kern + verifizierte Anfangs-Schalen (`j ≤ 5`). -/
structure ChannelSevenDeepLiftScaffold : Prop where
  multiplier_invertible :
    ∀ j : Nat, Nat.Coprime deepBranchMultiplier (deepLiftModulus j)
  generator_values :
    deepLiftResidue 1 = 1 ∧
      deepLiftResidue 2 = 3 ∧
        deepLiftResidue 3 = 3 ∧
          deepLiftResidue 4 = 11 ∧
            deepLiftResidue 5 = 27
  constant_values :
    deepLiftConstant 1 = 169 ∧
      deepLiftConstant 2 = 206 ∧
        deepLiftConstant 3 = 103 ∧
          deepLiftConstant 4 = 173 ∧
            deepLiftConstant 5 = 208
  residue_specs :
    deepBranchPoly (deepLiftResidue 1) % deepLiftModulus 1 = 0 ∧
      deepBranchPoly (deepLiftResidue 2) % deepLiftModulus 2 = 0 ∧
        deepBranchPoly (deepLiftResidue 3) % deepLiftModulus 3 = 0 ∧
          deepBranchPoly (deepLiftResidue 4) % deepLiftModulus 4 = 0 ∧
            deepBranchPoly (deepLiftResidue 5) % deepLiftModulus 5 = 0
  compat_samples :
    deepLiftResidue 2 % deepLiftModulus 1 = deepLiftResidue 1 ∧
      deepLiftResidue 3 % deepLiftModulus 2 = deepLiftResidue 2 ∧
        deepLiftResidue 4 % deepLiftModulus 3 = deepLiftResidue 3 ∧
          deepLiftResidue 5 % deepLiftModulus 4 = deepLiftResidue 4
  existsUnique_samples :
    DeepLiftResidueUnique 1 ∧
      DeepLiftResidueUnique 2 ∧
        DeepLiftResidueUnique 3 ∧
          DeepLiftResidueUnique 4 ∧
            DeepLiftResidueUnique 5
  step5_certificate :
    ∀ r : Nat, 3 * (162 * (4 * r + 1) + 91) + 1 = 2 ^ 3 * deepBranchPoly r

/-- V2.14 Ebene A: vollständig formalisierte Bewertungsklassifikation (H1–H4). -/
structure ChannelSevenDeepLiftLevelAStatus : Prop where
  existsUnique_residue : ∀ j : Nat, DeepLiftResidueUnique j
  residue_iff :
    ∀ j r : Nat, deepLiftModulus j ∣ deepBranchPoly r ↔ r % deepLiftModulus j = deepLiftResidue j
  nu2_ge_iff :
    ∀ j r : Nat, j ≤ padicValNat 2 (deepBranchPoly r) ↔ r % deepLiftModulus j = deepLiftResidue j
  nu2_eq_iff :
    ∀ j r : Nat,
      padicValNat 2 (deepBranchPoly r) = j ↔
        r % deepLiftModulus j = deepLiftResidue j ∧ r % deepLiftModulus (j + 1) ≠ deepLiftResidue (j + 1)
  affine_factorization :
    ∀ j t : Nat,
      deepBranchPoly (deepLiftResidue j + deepLiftModulus j * t) =
        deepLiftModulus j * (deepBranchMultiplier * t + deepLiftConstant j)
  scaffold : ChannelSevenDeepLiftScaffold

theorem channel_seven_deep_lift_scaffold : ChannelSevenDeepLiftScaffold where
  multiplier_invertible := deepBranchMultiplier_coprime_pow_two
  generator_values := ⟨deepLiftResidue_one, deepLiftResidue_two, deepLiftResidue_three,
    deepLiftResidue_four, deepLiftResidue_five⟩
  constant_values := ⟨deepLiftConstant_one, deepLiftConstant_two, deepLiftConstant_three,
    deepLiftConstant_four, deepLiftConstant_five⟩
  residue_specs := ⟨deepLiftResidue_spec_one, deepLiftResidue_spec_two, deepLiftResidue_spec_three,
    deepLiftResidue_spec_four, deepLiftResidue_spec_five⟩
  compat_samples := ⟨deepLiftResidue_succ_compat_one, deepLiftResidue_succ_compat_two,
    deepLiftResidue_succ_compat_three, deepLiftResidue_succ_compat_four⟩
  existsUnique_samples := ⟨
    existsUnique_deepLiftResidue_one,
    existsUnique_deepLiftResidue_two,
    existsUnique_deepLiftResidue_three,
    existsUnique_deepLiftResidue_four,
    existsUnique_deepLiftResidue_five⟩
  step5_certificate := channelSeven71_step5_certificate_link

theorem channel_seven_deep_lift_level_a_status : ChannelSevenDeepLiftLevelAStatus where
  existsUnique_residue := existsUnique_deepLiftResidue
  residue_iff := fun j r => (deepLiftResidue_iff j r)
  nu2_ge_iff := fun j r => (nu2_deepBranch_ge_iff j r)
  nu2_eq_iff := fun j r => (nu2_deepBranch_eq_iff j r)
  affine_factorization := fun j t => (deepLift_affine_factorization j t)
  scaffold := channel_seven_deep_lift_scaffold

end KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
