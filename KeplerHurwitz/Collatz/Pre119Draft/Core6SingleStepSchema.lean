import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
import KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail4
import KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail5

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — Core6SingleStepSchema

Schema-Lemma für Single-Step-Endklassen nach Core-6:

`fiberE(e) = [1,1,1,1,2,2] ++ [e]`.

Empirisch / zensusgeschlossen unter `n < 2^21` (offline `[B]`):
- `isGood` genau für `e ≥ 4` (`3^7 < 2^{8+e}`),
- Mitglieder bilden die AP `base(e) + k · 2^{S+1}` mit `S = 8+e`,
- Periode also `2^{S+1}` (nicht `2^S`).

Dieses Modul verankert unter `[A]`:
- Wortalgebra + Güte für alle `e ≥ 4`,
- Periodenformel `2^{S+1}`,
- bekannte Basen `e = 4..11`,
- Vollzensus-Brücke zu Tail-4 (`e=4`) und Tail-5 (`e=5`),
- zusätzliche Zensus `e=6` (`∀k<64`) und `e=7` (`∀k<32`).

Kein ∀n / CoverCertified / Collatz. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema

open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail4
open KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail5

/-- Core-6 prefix shared by Tail-4/5 single-step classes. -/
def core6 : List Nat := [1, 1, 1, 1, 2, 2]

theorem core6_sum : core6.sum = 8 := by native_decide
theorem core6_length : core6.length = 6 := by native_decide

/-- Single-step class fiber `Core6 ++ [e]`. -/
def fiberE (e : Nat) : List Nat := core6 ++ [e]

theorem fiberE_length (e : Nat) : (fiberE e).length = 7 := by
  simp [fiberE, core6]

theorem fiberE_sum (e : Nat) : (fiberE e).sum = 8 + e := by
  simp [fiberE, core6, List.sum_cons, List.sum_nil]
  omega

/-- Observed AP period for the class below `2^21`: `2^{S+1}`. -/
def classPeriod (e : Nat) : Nat := 2 ^ ((fiberE e).sum + 1)

theorem classPeriod_eq (e : Nat) : classPeriod e = 2 ^ (9 + e) := by
  unfold classPeriod
  rw [fiberE_sum]
  congr 1
  omega

/-- Minimal odd bases of exact first-good class `fiberE e` below `2^21` (offline census). -/
def classBase : Nat → Nat
  | 4 => 6687
  | 5 => 10783
  | 6 => 18975
  | 7 => 2591
  | 8 => 100895
  | 9 => 166431
  | 10 => 35359
  | 11 => 297503
  | _ => 0

def classMember (e k : Nat) : Nat := classBase e + k * classPeriod e

/-- Expected member count below `2^21` for `e ∈ [4,11]`: `2^{12-e}`. -/
def classCountBelow2pow21 (e : Nat) : Nat := 2 ^ (12 - e)

/-! ### Güte-Schema: `e ≥ 4` ⇒ `isGood (Core6 ++ [e])` -/

private theorem pow2_ge_twelve_of_e_ge_four {e : Nat} (he : 4 ≤ e) :
    2 ^ 12 ≤ 2 ^ (8 + e) := by
  have : 12 ≤ 8 + e := by omega
  exact Nat.pow_le_pow_right (by decide : 0 < 2) this

/--
`[A]` Schema: jedes Single-Step-Wort `Core6 ++ [e]` mit `e ≥ 4` ist gut.
(`3^7 = 2187 < 4096 = 2^12 ≤ 2^{8+e}`.)
-/
theorem isGood_fiberE_of_e_ge_four {e : Nat} (he : 4 ≤ e) :
    isGoodExpSequence (fiberE e) := by
  dsimp [isGoodExpSequence]
  have hlen : (fiberE e).length = 7 := fiberE_length e
  have hsum : (fiberE e).sum = 8 + e := fiberE_sum e
  rw [hlen, hsum]
  have h12 : 3 ^ 7 < 2 ^ 12 := by native_decide
  have hpow := pow2_ge_twelve_of_e_ge_four he
  exact Nat.lt_of_lt_of_le h12 hpow

theorem fiberE_tail4_matches : fiberE 4 = fiberE_tail4 := by native_decide
theorem fiberE_tail5_matches : fiberE 5 = fiberE_tail5 := by native_decide

theorem classBase_four : classBase 4 = 6687 := rfl
theorem classBase_five : classBase 5 = 10783 := rfl
theorem classPeriod_four : classPeriod 4 = 2 ^ 13 := by native_decide
theorem classPeriod_five : classPeriod 5 = 2 ^ 14 := by native_decide

/-! ### Brücke zu bestehenden Vollzensus Tail-4/5 -/

theorem schema_bridges_tail4 {k : Nat} (hk : k < 256) :
    RealizesWord (fiberE 4) (classMember 4 k) ∧
      realizedImage (classMember 4 k) (fiberE 4) < classMember 4 k := by
  simpa [fiberE_tail4_matches, classMember, classBase, classPeriod_four,
    tail4ClassMember] using tail4_forall_k_lt_256 hk

theorem schema_bridges_tail5 {k : Nat} (hk : k < 128) :
    RealizesWord (fiberE 5) (classMember 5 k) ∧
      realizedImage (classMember 5 k) (fiberE 5) < classMember 5 k := by
  simpa [fiberE_tail5_matches, classMember, classBase, classPeriod_five,
    tail5ClassMember] using tail5_forall_k_lt_128 hk

/-! ### Zusätzliche Zensus e=6 (64) und e=7 (32) -/

theorem fiberE6_isGood : isGoodExpSequence (fiberE 6) :=
  isGood_fiberE_of_e_ge_four (by decide : 4 ≤ 6)

theorem fiberE7_isGood : isGoodExpSequence (fiberE 7) :=
  isGood_fiberE_of_e_ge_four (by decide : 4 ≤ 7)

theorem classBase_six : classBase 6 = 18975 := rfl
theorem classBase_seven : classBase 7 = 2591 := rfl
theorem classPeriod_six : classPeriod 6 = 2 ^ 15 := by native_decide
theorem classPeriod_seven : classPeriod 7 = 2 ^ 16 := by native_decide

theorem realizes_e6_base : RealizesWord (fiberE 6) (classBase 6) := by native_decide
theorem contracts_e6_base :
    realizedImage (classBase 6) (fiberE 6) < classBase 6 := by native_decide

theorem realizes_e7_base : RealizesWord (fiberE 7) (classBase 7) := by native_decide
theorem contracts_e7_base :
    realizedImage (classBase 7) (fiberE 7) < classBase 7 := by native_decide

/-- `[A]` Vollzensus der `e=6`-Klasse unter `2^21` (`k < 64`). -/
theorem forall_e6_fin64 :
    ∀ k : Fin 64,
      RealizesWord (fiberE 6) (classMember 6 k.val) ∧
        realizedImage (classMember 6 k.val) (fiberE 6) < classMember 6 k.val := by
  native_decide

theorem forall_e6_k_lt_64 {k : Nat} (hk : k < 64) :
    RealizesWord (fiberE 6) (classMember 6 k) ∧
      realizedImage (classMember 6 k) (fiberE 6) < classMember 6 k :=
  forall_e6_fin64 ⟨k, hk⟩

/-- `[A]` Vollzensus der `e=7`-Klasse unter `2^21` (`k < 32`). -/
theorem forall_e7_fin32 :
    ∀ k : Fin 32,
      RealizesWord (fiberE 7) (classMember 7 k.val) ∧
        realizedImage (classMember 7 k.val) (fiberE 7) < classMember 7 k.val := by
  native_decide

theorem forall_e7_k_lt_32 {k : Nat} (hk : k < 32) :
    RealizesWord (fiberE 7) (classMember 7 k) ∧
      realizedImage (classMember 7 k) (fiberE 7) < classMember 7 k :=
  forall_e7_fin32 ⟨k, hk⟩

/--
`[A]` Schema-Pack: Güte für `e≥4`, Periodenformel, Basen 4–7,
Vollzensus-Brücken Tail-4/5 plus Zensus `e=6,7`.
-/
theorem core6_single_step_schema_pack :
    (∀ e, 4 ≤ e → isGoodExpSequence (fiberE e)) ∧
    (∀ e, classPeriod e = 2 ^ (9 + e)) ∧
    classBase 4 = 6687 ∧ classBase 5 = 10783 ∧
    classBase 6 = 18975 ∧ classBase 7 = 2591 ∧
    (∀ k, k < 256 →
      RealizesWord (fiberE 4) (classMember 4 k) ∧
        realizedImage (classMember 4 k) (fiberE 4) < classMember 4 k) ∧
    (∀ k, k < 128 →
      RealizesWord (fiberE 5) (classMember 5 k) ∧
        realizedImage (classMember 5 k) (fiberE 5) < classMember 5 k) ∧
    (∀ k, k < 64 →
      RealizesWord (fiberE 6) (classMember 6 k) ∧
        realizedImage (classMember 6 k) (fiberE 6) < classMember 6 k) ∧
    (∀ k, k < 32 →
      RealizesWord (fiberE 7) (classMember 7 k) ∧
        realizedImage (classMember 7 k) (fiberE 7) < classMember 7 k) :=
  ⟨fun _ he => isGood_fiberE_of_e_ge_four he,
    fun e => classPeriod_eq e,
    classBase_four, classBase_five, classBase_six, classBase_seven,
    fun _ hk => schema_bridges_tail4 hk,
    fun _ hk => schema_bridges_tail5 hk,
    fun _ hk => forall_e6_k_lt_64 hk,
    fun _ hk => forall_e7_k_lt_32 hk⟩

end KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
