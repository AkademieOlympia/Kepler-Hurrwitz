import Mathlib
import KeplerHurwitz.OddCoreDynamics
import KeplerHurwitz.CollatzNormShell
import KeplerHurwitz.CollatzProofAttemptV27

/-!
# Collatz Chirurgery Bridge — odd-core domain + abstract termination

**Collatz?** **NEIN.** This module does **not** prove Collatz.

## Architecture (four blocks)

1. **OddCoreDynamics** — accelerated Syracuse `T` for **odd** inputs; never claim `T(even)<even`
2. **FuelSearch** — structural fuel search + soundness/completeness
3. **AbstractDescentTermination** — `netDescent ⇒ reaches 1` (sorry-free, operator-agnostic)
4. **EabcBridgeBoundary** — open `[C]` absorption / BoolTrace arrow only

## Critical domain fact

`oddCoreSyracuse n = oddCore (3n+1)`. For even `k > 0`, `3k+1` is odd, so
`ν₂(3k+1) = 0` and `T(k) = 3k+1 > k`. Example: `T(2) = 7`.
-/

namespace KeplerHurwitz.Collatz.CollatzChirurgeryBridge

open KeplerHurwitz
open KeplerHurwitz.CollatzAttemptV2.CollatzNetDescent

/-! #########################################################################
## 1. OddCoreDynamics
######################################################################### -/

section OddCoreDynamics

/--
Positive odd natural — Variant A carrier for the accelerated operator.
Not forced through the whole V2 stack; used locally when a typed domain helps.
-/
structure OddNat where
  val : Nat
  is_pos : 0 < val
  is_odd : val % 2 = 1

/--
Accelerated Syracuse map `T(n) = oddCore(3n+1)`.

**Semantic domain: odd inputs.** Defined on all `Nat` for convenience (matches
`oddCoreStep`), but descent hypotheses must restrict to odd `n`. Never claim
`oddCoreSyracuse k < k` for even `k`.
-/
abbrev oddCoreSyracuse : Nat → Nat := oddCoreStep

theorem oddCoreSyracuse_eq_oddCoreStep (n : Nat) :
    oddCoreSyracuse n = oddCoreStep n :=
  rfl

theorem oddCoreSyracuse_odd (n : Nat) : oddCoreSyracuse n % 2 = 1 :=
  oddCoreStep_mod2_eq_one n

theorem oddCoreSyracuse_pos (n : Nat) : 0 < oddCoreSyracuse n :=
  oddCoreStep_pos n

/-- Fixed point at the odd unit: `T(1) = oddCore(4) = 1`. -/
theorem oddCoreSyracuse_one : oddCoreSyracuse 1 = 1 := by
  -- `oddCore (2^2 * 1) = 1`
  simpa [oddCoreSyracuse, oddCoreStep] using
    (oddCore_two_pow_mul 2 1 (by decide : Odd 1))

/--
`[A]` Even inputs **grow** under `oddCoreSyracuse` (counterexample template).
`T(2) = 7 > 2`. This kills any even-branch “shrink” proof that uses `T`.
-/
theorem oddCoreSyracuse_two_gt : oddCoreSyracuse 2 = 7 ∧ ¬oddCoreSyracuse 2 < 2 := by
  have h7 : Odd 7 := by decide
  have hT : oddCoreSyracuse 2 = 7 := by
    -- `3*2+1 = 7` is odd ⇒ `oddCore 7 = 7`
    simpa [oddCoreSyracuse, oddCoreStep] using (oddCore_two_pow_mul 0 7 h7)
  exact ⟨hT, by omega⟩

/--
`[A]` For positive even `k`, `3k+1` is odd ⇒ `ν₂(3k+1)=0` ⇒ `T(k)=3k+1>k`.
-/
theorem oddCoreSyracuse_even_gt {k : Nat} (_hk : 0 < k) (he : k % 2 = 0) :
    k < oddCoreSyracuse k := by
  have h3odd : Odd (3 * k + 1) := Nat.odd_iff.mpr (by omega)
  have hT : oddCoreSyracuse k = 3 * k + 1 := by
    simpa [oddCoreSyracuse, oddCoreStep] using (oddCore_two_pow_mul 0 (3 * k + 1) h3odd)
  omega
/-- Typed Syracuse step on `OddNat`. -/
def OddNat.syracuse (n : OddNat) : OddNat where
  val := oddCoreSyracuse n.val
  is_pos := oddCoreSyracuse_pos n.val
  is_odd := oddCoreSyracuse_odd n.val

/--
Custom iteration matching the project recursion direction:
`Iter(0,n)=n`, `Iter(k+1,n)=T(Iter(k,n))`.
-/
def oddCoreSyracuseIter : Nat → Nat → Nat
  | 0, n => n
  | k + 1, n => oddCoreSyracuse (oddCoreSyracuseIter k n)

theorem oddCoreSyracuseIter_zero (n : Nat) : oddCoreSyracuseIter 0 n = n :=
  rfl

theorem oddCoreSyracuseIter_succ (k n : Nat) :
    oddCoreSyracuseIter (k + 1) n = oddCoreSyracuse (oddCoreSyracuseIter k n) :=
  rfl

theorem oddCoreSyracuseIter_eq_iterate (k n : Nat) :
    oddCoreSyracuseIter k n = oddCoreSyracuse^[k] n := by
  induction k with
  | zero => rfl
  | succ k ih =>
      rw [oddCoreSyracuseIter_succ, ih, Function.iterate_succ_apply']

/--
`[A]` Iteration composition for the project recursion:
`Iter(a+b,n) = Iter(a, Iter(b,n))`.
-/
theorem oddCoreSyracuseIter_add (a b n : Nat) :
    oddCoreSyracuseIter (a + b) n =
      oddCoreSyracuseIter a (oddCoreSyracuseIter b n) := by
  induction a with
  | zero =>
      simp [oddCoreSyracuseIter]
  | succ a ih =>
      rw [Nat.succ_add, oddCoreSyracuseIter_succ, oddCoreSyracuseIter_succ, ih]

theorem oddCoreSyracuseIter_pos {n : Nat} (hn : 0 < n) (k : Nat) :
    0 < oddCoreSyracuseIter k n := by
  induction k with
  | zero => simpa [oddCoreSyracuseIter] using hn
  | succ k ih =>
      simpa [oddCoreSyracuseIter] using oddCoreSyracuse_pos _

theorem oddCoreSyracuseIter_odd_of_odd {n : Nat} (ho : n % 2 = 1) (k : Nat) :
    oddCoreSyracuseIter k n % 2 = 1 := by
  induction k with
  | zero => simpa [oddCoreSyracuseIter] using ho
  | succ k _ih =>
      simpa [oddCoreSyracuseIter] using oddCoreSyracuse_odd _

/--
Clean odd-only net-descent statement (no redundant `True`).

Compatibility: V2.7 `BadRunNetDescentStatement` remains the mod-4=3 /
`collatzStep` witness cover — do not rename that globally.
-/
def OddNetDescentStatement : Prop :=
  ∀ n, 1 < n → n % 2 = 1 → ∃ t, 0 < t ∧ oddCoreSyracuseIter t n < n

/--
Witness packaging for odd-core net descent (dynamical payload only).
-/
structure OddCoreNetDescentWitness (n : Nat) where
  t_loc : Nat
  ht_pos : 0 < t_loc
  local_shrink : oddCoreSyracuseIter t_loc n < n

/--
`[A]` Packing only: existence of a shrink iterate ⇒ witness structure.

Does **not** use BoolTrace / relations product `P` / `Φ_k` / absorption.
-/
theorem descent_exists_to_witness {n : Nat}
    (h : ∃ t, 0 < t ∧ oddCoreSyracuseIter t n < n) :
    Nonempty (OddCoreNetDescentWitness n) := by
  rcases h with ⟨t, ht_pos, ht⟩
  exact ⟨⟨t, ht_pos, ht⟩⟩

/-- Alias: packing name preferred in the Fahrplan. -/
theorem pack_net_descent_witness {n : Nat}
    (h : ∃ t, 0 < t ∧ oddCoreSyracuseIter t n < n) :
    Nonempty (OddCoreNetDescentWitness n) :=
  descent_exists_to_witness h

/--
Deprecated name from an earlier prototype. **Not** an EABC bridge —
definitionally `descent_exists_to_witness`.
-/
@[deprecated descent_exists_to_witness (since := "2026-07-21")]
theorem eabc_to_witness_constructive {n : Nat}
    (h : ∃ t, 0 < t ∧ oddCoreSyracuseIter t n < n) :
    Nonempty (OddCoreNetDescentWitness n) :=
  descent_exists_to_witness h

/-- 2-adic strip: positive `n` retracts to its odd part by `k = ν₂(n)` halvings. -/
theorem even_strip_to_oddPart {n : Nat} (hn : 0 < n) :
    let d := oddCoreDecompositionOfPos hn
    Nat.iterate collatzStep d.k n = d.m ∧ d.m % 2 = 1 ∧ 0 < d.m := by
  intro d
  refine ⟨collatz_iterate_of_decomposition d, d.hm_odd, ?_⟩
  exact (Nat.odd_iff.mpr d.hm_odd).pos

end OddCoreDynamics

/-! #########################################################################
## 2. FuelSearch
######################################################################### -/

section FuelSearch

/--
Search for a positive step `t ∈ [step, step+fuel)` with
`oddCoreSyracuseIter t n < n`. Fuel decreases on each recursive call ⇒
structural termination.
-/
def findWitnessWithFuel (n fuel step : Nat) : Option Nat :=
  match fuel with
  | 0 => none
  | fuel' + 1 =>
      if 0 < step ∧ oddCoreSyracuseIter step n < n then
        some step
      else
        findWitnessWithFuel n fuel' (step + 1)

/--
`[A]` Soundness: a returned step lies in the searched window and shrinks.
-/
theorem findWitnessWithFuel_sound
    {n fuel step t : Nat}
    (h : findWitnessWithFuel n fuel step = some t) :
    step ≤ t ∧ t < step + fuel ∧ 0 < t ∧ oddCoreSyracuseIter t n < n := by
  induction fuel generalizing step with
  | zero =>
      simp [findWitnessWithFuel] at h
  | succ fuel ih =>
      simp [findWitnessWithFuel] at h
      by_cases hcond : 0 < step ∧ oddCoreSyracuseIter step n < n
      · simp [hcond] at h
        subst t
        refine ⟨Nat.le_refl _, ?_, hcond.1, hcond.2⟩
        omega
      · simp [hcond] at h
        rcases ih h with ⟨hle, hlt, htpos, hshrink⟩
        refine ⟨by omega, ?_, htpos, hshrink⟩
        omega

/--
`[A]` Completeness: if a shrink step exists in the window, search finds one.
-/
theorem findWitnessWithFuel_complete
    {n fuel step : Nat}
    (h : ∃ t, step ≤ t ∧ t < step + fuel ∧ 0 < t ∧
        oddCoreSyracuseIter t n < n) :
    ∃ t, findWitnessWithFuel n fuel step = some t := by
  induction fuel generalizing step with
  | zero =>
      rcases h with ⟨t, hle, hlt, _, _⟩
      omega
  | succ fuel ih =>
      simp [findWitnessWithFuel]
      by_cases hcond : 0 < step ∧ oddCoreSyracuseIter step n < n
      · exact ⟨step, by simp [hcond]⟩
      · simp [hcond]
        apply ih
        rcases h with ⟨t, hle, hlt, htpos, hshrink⟩
        have ht_ne : t ≠ step := by
          intro heq
          subst heq
          exact hcond ⟨htpos, hshrink⟩
        refine ⟨t, ?_, ?_, htpos, hshrink⟩
        · omega
        · omega

/-- Convenience: search from step `1` over `fuel` candidates. -/
def findWitnessFromOne (n fuel : Nat) : Option Nat :=
  findWitnessWithFuel n fuel 1

end FuelSearch

/-! #########################################################################
## 3. AbstractDescentTermination
######################################################################### -/

section AbstractDescentTermination

/-- Positivity of iterates under a positivity-preserving map. -/
theorem iterate_pos_of_pos
    (T : Nat → Nat) (h_pos : ∀ n, 0 < n → 0 < T n)
    {n t : Nat} (hn : 0 < n) :
    0 < T^[t] n := by
  induction t with
  | zero =>
      simpa using hn
  | succ t ih =>
      rw [Function.iterate_succ_apply']
      exact h_pos _ ih

/--
`[A]` **Boxed next step** — abstract, operator-agnostic:

```
(∀ n>1, ∃ t>0, T^t(n)<n)  ∧  T(1)=1  ∧  T preserves positivity
    ⟹  ∀ n>0, ∃ k, T^k(n)=1
```

Domain of `h_descent` is **all** `n > 1`. For odd-only operators use
`odd_descent_implies_reaches_one` instead — do **not** feed even states to
`oddCoreSyracuse` as if it were halving.
-/
theorem descent_implies_reaches_one
    (T : Nat → Nat)
    (_h_one : T 1 = 1)
    (h_pos : ∀ n, 0 < n → 0 < T n)
    (h_descent : ∀ n, 1 < n → ∃ t, 0 < t ∧ T^[t] n < n) :
    ∀ n, 0 < n → ∃ k, T^[k] n = 1 := by
  intro n
  induction n using Nat.strong_induction_on with
  | h n ih =>
      intro hn
      by_cases h1 : n = 1
      · exact ⟨0, by simp [h1]⟩
      · have hn_gt : 1 < n := by omega
        rcases h_descent n hn_gt with ⟨t, _ht_pos, ht⟩
        have hmt : 0 < T^[t] n := iterate_pos_of_pos T h_pos hn
        rcases ih (T^[t] n) ht hmt with ⟨r, hr⟩
        refine ⟨r + t, ?_⟩
        rw [Function.iterate_add_apply, hr]

/-- Alias matching the Fahrplan name. -/
theorem netDescent_implies_termination
    (T : Nat → Nat)
    (h_one : T 1 = 1)
    (h_pos : ∀ n, 0 < n → 0 < T n)
    (h_descent : ∀ n, 1 < n → ∃ t, 0 < t ∧ T^[t] n < n) :
    ∀ n, 0 < n → ∃ k, T^[k] n = 1 :=
  descent_implies_reaches_one T h_one h_pos h_descent

/-- `collatzStep` preserves positivity. -/
theorem collatzStep_pos {n : Nat} (hn : 0 < n) : 0 < collatzStep n := by
  unfold collatzStep
  split_ifs with he
  · have h2le : 2 ≤ n := by omega
    exact Nat.div_pos h2le (by decide : 0 < 2)
  · omega

theorem collatzStep_one : collatzStep 1 = 4 := by
  decide

/--
Note: `collatzStep 1 = 4 ≠ 1`, so the abstract theorem’s `h_one` does **not**
apply directly to `collatzStep`. Classical Collatz uses the usual strong
induction with base `n=1` via `k=0` (zero iterates), not `T 1 = 1`.
See `classicalCollatz_of_local_strict_descent` in the claim-boundary module.
-/
theorem collatzStep_not_fixpoint_one : collatzStep 1 ≠ 1 := by
  decide

/--
`[A]` Odd-only Variant A: net descent on odd `n>1` under `oddCoreSyracuse`
⇒ every positive odd start reaches `1` under `oddCoreSyracuseIter`.
-/
theorem odd_descent_implies_reaches_one
    (h_descent : OddNetDescentStatement) :
    ∀ n, 0 < n → n % 2 = 1 → ∃ k, oddCoreSyracuseIter k n = 1 := by
  intro n
  induction n using Nat.strong_induction_on with
  | h n ih =>
      intro hn ho
      by_cases h1 : n = 1
      · exact ⟨0, by simp [h1, oddCoreSyracuseIter]⟩
      · have hn_gt : 1 < n := by omega
        rcases h_descent n hn_gt ho with ⟨t, _ht_pos, ht⟩
        have hmt : 0 < oddCoreSyracuseIter t n := oddCoreSyracuseIter_pos hn t
        have hmo : oddCoreSyracuseIter t n % 2 = 1 :=
          oddCoreSyracuseIter_odd_of_odd ho t
        rcases ih (oddCoreSyracuseIter t n) ht hmt hmo with ⟨r, hr⟩
        refine ⟨r + t, ?_⟩
        rw [oddCoreSyracuseIter_add, hr]

/-- Each odd Syracuse step is realized by some `collatzStep` iterate. -/
theorem oddCoreSyracuse_realized {m : Nat} (hm : m % 2 = 1) :
    ∃ t, collatzStep^[t] m = oddCoreSyracuse m := by
  simpa [oddCoreSyracuse, Nat.iterate] using oddCoreStep_reached_by_collatz hm

theorem oddCoreSyracuseIter_realized {m : Nat} (hm : m % 2 = 1) (k : Nat) :
    ∃ t, collatzStep^[t] m = oddCoreSyracuseIter k m := by
  induction k with
  | zero =>
      exact ⟨0, by simp [oddCoreSyracuseIter]⟩
  | succ k ih =>
      rcases ih with ⟨t, ht⟩
      have hmo : oddCoreSyracuseIter k m % 2 = 1 :=
        oddCoreSyracuseIter_odd_of_odd hm k
      rcases oddCoreSyracuse_realized hmo with ⟨s, hs⟩
      refine ⟨s + t, ?_⟩
      calc
        collatzStep^[s + t] m
            = collatzStep^[s] (collatzStep^[t] m) := by
                rw [Function.iterate_add_apply]
        _ = collatzStep^[s] (oddCoreSyracuseIter k m) := by rw [ht]
        _ = oddCoreSyracuse (oddCoreSyracuseIter k m) := hs
        _ = oddCoreSyracuseIter (k + 1) m := by rfl

/--
`[A]` Odd-core Syracuse termination on odds ⇒ `OddCoreCollatzConjecture`
(`collatzStep` route), via realization of each Syracuse step.
-/
theorem oddCoreCollatz_of_odd_syracuse_termination
    (h : ∀ n, 0 < n → n % 2 = 1 → ∃ k, oddCoreSyracuseIter k n = 1) :
    OddCoreCollatzConjecture := by
  intro m hm_pos hm_odd
  rcases h m hm_pos hm_odd with ⟨k, hk⟩
  rcases oddCoreSyracuseIter_realized hm_odd k with ⟨t, ht⟩
  refine ⟨t, ?_⟩
  simpa [Nat.iterate, hk] using ht

/--
`[A]` OddNetDescent ⇒ OddCore Collatz (still conditional on the odd cover).
Even starts are handled by the existing oddPart / 2-adic strip in
`oddCoreCollatz_implies_classicalCollatz` — **not** by `oddCoreSyracuse` on evens.
-/
theorem oddCoreCollatz_of_OddNetDescent
    (h : OddNetDescentStatement) :
    OddCoreCollatzConjecture :=
  oddCoreCollatz_of_odd_syracuse_termination (odd_descent_implies_reaches_one h)

/--
`[A]` Local strict descent on **all** `n>1` for an arbitrary positive-preserving
`T` with `T 1 = 1` ⇒ termination. Specialization of `descent_implies_reaches_one`.
-/
def LocalStrictDescentStatement (T : Nat → Nat) : Prop :=
  ∀ n, 1 < n → ∃ t, 0 < t ∧ T^[t] n < n

theorem reaches_one_of_local_strict_descent
    (T : Nat → Nat)
    (h_one : T 1 = 1)
    (h_pos : ∀ n, 0 < n → 0 < T n)
    (hdesc : LocalStrictDescentStatement T) :
    ∀ n, 0 < n → ∃ k, T^[k] n = 1 :=
  descent_implies_reaches_one T h_one h_pos hdesc

end AbstractDescentTermination

/-! #########################################################################
## 4. EabcBridgeBoundary  — open [C] only
######################################################################### -/

section EabcBridgeBoundary

/--
`[C]` **Open** — named absorption / BoolTrace certificate slot.

Intended reading:
`BoolTrace(P)=0 ⇒ ∃ t, T^t(n)<n`
with `T = oddCoreSyracuse` (odd `n`) or the V2.7 `collatzStep` packaging.

**Not proved.** No fake `exact`. Kept visible as the sole EABC arithmetic gap.
-/
def AbsorbingTraceCertificate (n fuel : Nat) : Prop :=
  ∃ t ≤ fuel, 0 < t ∧ oddCoreSyracuseIter t n < n

/--
`[C]` Open arrow: BoolTrace-zero / absorption ⇒ local odd-core shrink.

Same epistemic slot as `BoolTraceZeroImpliesLocalShrink` in the claim-boundary
module (there: `collatzStep` / good-branch packaging).
-/
def BoolTraceZeroImpliesLocalShrink : Prop :=
  ∀ {n : Nat}, 1 < n → n % 2 = 1 →
    ∃ fuel, AbsorbingTraceCertificate n fuel

/-- Alias preferred in the architectural note. -/
abbrev BoolTraceZeroImpliesLocalShrink_oddCore := BoolTraceZeroImpliesLocalShrink

/--
`[A]` **Conditional** packing only: an absorbing-trace certificate packages to
an odd-core witness. Does not prove the certificate exists.
-/
theorem descent_exists_to_witness_of_absorbing
    {n fuel : Nat}
    (h : AbsorbingTraceCertificate n fuel) :
    Nonempty (OddCoreNetDescentWitness n) := by
  rcases h with ⟨t, _, ht_pos, ht⟩
  exact descent_exists_to_witness ⟨t, ht_pos, ht⟩

/--
`[C]` Status marker: EABC / BoolTrace ⇒ archimedean odd-core net descent remains open.
-/
def EabcBridgeOpenGap : Prop :=
  BoolTraceZeroImpliesLocalShrink

end EabcBridgeBoundary

end KeplerHurwitz.Collatz.CollatzChirurgeryBridge
