import Mathlib

namespace KeplerHurwitz

noncomputable section

/--
Vier diskrete Kanaele im EABC-Signaturraum.
-/
inductive EABCChannel
  | E | A | B | C
  deriving DecidableEq, Fintype

namespace EABCChannel

/--
Chiraler Zyklus:
`E -> A -> C -> B -> E`.
-/
def chi : EABCChannel → EABCChannel
  | E => A
  | A => C
  | C => B
  | B => E

/--
Inverse chirale Rotation.
-/
def chiInv : EABCChannel → EABCChannel
  | E => B
  | B => C
  | C => A
  | A => E

theorem chiInv_chi (x : EABCChannel) : chiInv (chi x) = x := by
  cases x <;> rfl

theorem chi_chiInv (x : EABCChannel) : chi (chiInv x) = x := by
  cases x <;> rfl

theorem chiInv_injective : Function.Injective chiInv := by
  intro x y hxy
  have h := congrArg chi hxy
  simpa [chi_chiInv] using h

theorem chi_cycle_length_four (x : EABCChannel) :
    chi (chi (chi (chi x))) = x := by
  cases x <;> rfl

end EABCChannel

/--
Einkanaliger Zustandsraum ueber dem EABC-Index.
-/
abbrev EABCKet := EABCChannel → ℂ

/--
Zweikanaliger Zustandsraum (Tensorindexdarstellung).
-/
abbrev EABCBipartiteKet := EABCChannel → EABCChannel → ℂ

/--
Lineare Wirkung der chiralen Rotation auf EABC-Zustaenden.
-/
def Jchi (ψ : EABCKet) : EABCKet :=
  fun i => ψ (EABCChannel.chiInv i)

/--
Inverse Wirkung von `Jchi`.
-/
def JchiInv (ψ : EABCKet) : EABCKet :=
  fun i => ψ (EABCChannel.chi i)

theorem Jchi_four_eq_id (ψ : EABCKet) :
    Jchi (Jchi (Jchi (Jchi ψ))) = ψ := by
  funext i
  cases i <;> rfl

/--
Maximal korrelierter EABC-Zustand.
-/
def Phi : EABCBipartiteKet :=
  fun i j => if i = j then (1 / 2 : ℂ) else 0

/--
Simultane chirale Rotation auf beiden Teilsystemen (`Jchi ⊗ Jchi`).
-/
def JchiTensor (Ψ : EABCBipartiteKet) : EABCBipartiteKet :=
  fun i j => Ψ (EABCChannel.chiInv i) (EABCChannel.chiInv j)

/--
Chirale Rotation links (`Jchi ⊗ I`).
-/
def JchiLeft (Ψ : EABCBipartiteKet) : EABCBipartiteKet :=
  fun i j => Ψ (EABCChannel.chiInv i) j

/--
Inverse chirale Rotation rechts (`I ⊗ Jchi^{-1}`).
-/
def JchiRightInv (Ψ : EABCBipartiteKet) : EABCBipartiteKet :=
  fun i j => Ψ i (EABCChannel.chi j)

/--
A-T: Der korrelierte Zustand `Phi` ist invariant unter simultaner chiraler Rotation.
Entspricht formal `(Jchi ⊗ Jchi)|Phi> = |Phi>`.
-/
theorem Phi_invariant_under_JchiTensor :
    JchiTensor Phi = Phi := by
  funext i j
  have hEq : (EABCChannel.chiInv i = EABCChannel.chiInv j) ↔ i = j :=
    EABCChannel.chiInv_injective.eq_iff
  simp [JchiTensor, Phi, hEq]

/--
A-T: Eine linksseitige chirale Rotation auf `Phi` entspricht
einer rechtsseitigen inversen Rotation.
Entspricht formal `(Jchi ⊗ I)|Phi> = (I ⊗ Jchi^{-1})|Phi>`.
-/
theorem Phi_left_rotation_eq_right_inverse_rotation :
    JchiLeft Phi = JchiRightInv Phi := by
  funext i j
  have hEq : (EABCChannel.chiInv i = j) ↔ (i = EABCChannel.chi j) := by
    constructor
    · intro hij
      have h := congrArg EABCChannel.chi hij
      simpa [EABCChannel.chi_chiInv] using h
    · intro hij
      have h := congrArg EABCChannel.chiInv hij
      simpa [EABCChannel.chiInv_chi] using h
  simp [JchiLeft, JchiRightInv, Phi, hEq]

end
end KeplerHurwitz
