import KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — Core6Lifting

Hebung von der **Wort**-Güte `isGoodExpSequence (Core6 ++ [e])` zur
**Zahlen**-Familienaussage entlang der AP
`n_k = base(e) + k · 2^{S(e)+1}`.

## Korrektur zur Skizzenfassung
Die Entwurfsskizze vermischte:
- `isGood` auf dem **Valuation-Wort** `Core6 ++ [e]`, und
- eine fälschliche `isGood` auf **Zahlen** `n` bzw. `Core6PlusPlus e + k·P`
  (Listen sind keine ℕ; Güte ist keine Eigenschaft von `n`).

Korrektes Lifting unter `[A]`:
`RealizesWord (fiberE e) n_k ∧ realizedImage n_k (fiberE e) < n_k`.

Das unendliche `∀ k : ℕ`-Lifting ist hier als `InfiniteApLiftingHypothesis`
benannt; die Entladung für `e = 4..7` liegt in `Core6InfiniteLifting`
(via `FiberWordAffine`: Valuation-Stabilität + affine Contracts).

Kein CoverCertified / Collatz. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6Lifting

open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema

/-- Schema-Parameter `S(e) = e + 8` (= Exponentensumme von `fiberE e`). -/
def S (e : Nat) : Nat := e + 8

theorem S_eq_fiberE_sum (e : Nat) : S e = (fiberE e).sum := by
  rw [fiberE_sum, S]
  omega

/-- Periode `P(e) = 2^{S(e)+1} = 2^{e+9}`. -/
def period (e : Nat) : Nat := 2 ^ (S e + 1)

theorem period_eq_classPeriod (e : Nat) : period e = classPeriod e := by
  simp [period, classPeriod, S_eq_fiberE_sum]

theorem period_eq_pow (e : Nat) : period e = 2 ^ (e + 9) := by
  simp [period, S]

/-- Member of the Core6-single-step AP (alias of `classMember`). -/
def apMember (e k : Nat) : Nat := classMember e k

theorem apMember_eq (e k : Nat) :
    apMember e k = classBase e + k * period e := by
  simp [apMember, classMember, period_eq_classPeriod]

/--
Correct lifting predicate on AP indices: realize the class word and contract.
(Not an `isGood` on numbers.)
-/
def ApMemberOk (e k : Nat) : Prop :=
  RealizesWord (fiberE e) (apMember e k) ∧
    realizedImage (apMember e k) (fiberE e) < apMember e k

/-! ### Finite lifting under `2^21` (already censused for e = 4..7) -/

/-- `[A]` Finite lifting for `e = 4` (`k < 256`). -/
theorem lifting_e4_below_2pow21 {k : Nat} (hk : k < 256) : ApMemberOk 4 k := by
  simpa [ApMemberOk, apMember] using schema_bridges_tail4 hk

/-- `[A]` Finite lifting for `e = 5` (`k < 128`). -/
theorem lifting_e5_below_2pow21 {k : Nat} (hk : k < 128) : ApMemberOk 5 k := by
  simpa [ApMemberOk, apMember] using schema_bridges_tail5 hk

/-- `[A]` Finite lifting for `e = 6` (`k < 64`). -/
theorem lifting_e6_below_2pow21 {k : Nat} (hk : k < 64) : ApMemberOk 6 k := by
  simpa [ApMemberOk, apMember] using forall_e6_k_lt_64 hk

/-- `[A]` Finite lifting for `e = 7` (`k < 32`). -/
theorem lifting_e7_below_2pow21 {k : Nat} (hk : k < 32) : ApMemberOk 7 k := by
  simpa [ApMemberOk, apMember] using forall_e7_k_lt_32 hk

/--
`[A]` Family coverage below `2^21` for the four closed exponents:
every AP index in the census range is a realizing contractor.
-/
theorem family_coverage_e4_to_e7_below_2pow21 :
    (∀ k, k < 256 → ApMemberOk 4 k) ∧
    (∀ k, k < 128 → ApMemberOk 5 k) ∧
    (∀ k, k < 64 → ApMemberOk 6 k) ∧
    (∀ k, k < 32 → ApMemberOk 7 k) :=
  ⟨fun _ hk => lifting_e4_below_2pow21 hk,
    fun _ hk => lifting_e5_below_2pow21 hk,
    fun _ hk => lifting_e6_below_2pow21 hk,
    fun _ hk => lifting_e7_below_2pow21 hk⟩

/-- Residue form: `n = base + k·P` recovers the AP member. -/
theorem apMember_of_add (e k : Nat) :
    classBase e + k * period e = apMember e k :=
  (apMember_eq e k).symm

/-! ### Infinite lifting — named hypothesis (discharged for e=4..7 elsewhere) -/

/--
Infinite AP lifting hypothesis for a fixed `e ≥ 4`:
every `k : ℕ` (unbounded) yields a realizing contractor on `apMember e k`.

Discharged under `[A]` for `e = 4..7` in `Core6InfiniteLifting`.
-/
def InfiniteApLiftingHypothesis (e : Nat) : Prop :=
  4 ≤ e → ∀ k : Nat, ApMemberOk e k

/--
Rejected sketch (documentation only): `isGood` does **not** apply to numbers, and
`Core6 ++ [e]` is a word, not an `ℕ` to which one adds `k * period`.
-/
def RejectedNumericIsGoodLiftingSketch : Prop := False

end KeplerHurwitz.Collatz.Pre119Draft.Core6Lifting
