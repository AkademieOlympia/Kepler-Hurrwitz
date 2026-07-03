import Mathlib

namespace KeplerHurwitz

/--
Ein zyklischer Links-Shift auf Listen.
-/
def rotateLeft : List α → List α
  | [] => []
  | x :: xs => xs ++ [x]

/--
Zyklische Erreichbarkeit: `v` entsteht aus `u` durch endlich viele Shifts.
-/
def CyclicEquivalent (u v : List α) : Prop :=
  ∃ k : Nat, Nat.iterate rotateLeft k u = v

theorem cyclicEquivalent_refl (u : List α) : CyclicEquivalent u u := by
  refine ⟨0, ?_⟩
  simp

theorem cyclicEquivalent_trans {u v w : List α} :
    CyclicEquivalent u v → CyclicEquivalent v w → CyclicEquivalent u w := by
  intro huv hvw
  rcases huv with ⟨k, hk⟩
  rcases hvw with ⟨l, hl⟩
  refine ⟨l + k, ?_⟩
  calc
    Nat.iterate rotateLeft (l + k) u
        = Nat.iterate rotateLeft l (Nat.iterate rotateLeft k u) := by
            simpa [Nat.iterate] using (Function.iterate_add_apply rotateLeft l k u)
    _ = Nat.iterate rotateLeft l v := by simp [hk]
    _ = w := hl

/--
Eine Bahn unter zyklischem Shift als endliche Initialsequenz.
Diese Rechenform ist fuer Filter-Reduktion praktisch.
-/
def orbitPrefix (u : List α) (steps : Nat) : List (List α) :=
  (List.range (steps + 1)).map (fun k => Nat.iterate rotateLeft k u)

end KeplerHurwitz
