import Mathlib

namespace KeplerHurwitz

variable (G : Type*) [Group G]
variable (K : Type*) [Field K]
variable (V : Type*) [AddCommGroup V] [Module K V]

/--
A-D: Lineare Darstellung einer Gruppe auf einem `K`-Vektorraum.
-/
structure LinearRepresentation where
  toLinearMap : G → V →ₗ[K] V
  map_one' : toLinearMap 1 = LinearMap.id
  map_mul' : ∀ g h : G, toLinearMap (g * h) = (toLinearMap g).comp (toLinearMap h)

namespace LinearRepresentation

variable {G K V}
variable (ρ : LinearRepresentation G K V)

/-- Wirkung eines Gruppenelements auf einen Vektor. -/
def act (g : G) (v : V) : V :=
  ρ.toLinearMap g v

/--
A-D: Invarianzbedingung fuer einen Unterraum unter der Darstellung `ρ`.
-/
def IsInvariant (W : Submodule K V) : Prop :=
  ∀ g : G, ∀ v : V, v ∈ W → ρ.act g v ∈ W

/--
A-T: Der Schnitt zweier invarianter Unterraeume ist invariant.
-/
theorem isInvariant_inf
    {W₁ W₂ : Submodule K V}
    (hW₁ : ρ.IsInvariant W₁)
    (hW₂ : ρ.IsInvariant W₂) :
    ρ.IsInvariant (W₁ ⊓ W₂) := by
  intro g v hv
  exact ⟨hW₁ g v hv.1, hW₂ g v hv.2⟩

/--
A-T: Die Summe zweier invarianter Unterraeume ist invariant.
-/
theorem isInvariant_sup
    {W₁ W₂ : Submodule K V}
    (hW₁ : ρ.IsInvariant W₁)
    (hW₂ : ρ.IsInvariant W₂) :
    ρ.IsInvariant (W₁ ⊔ W₂) := by
  intro g w hw
  rcases Submodule.mem_sup.mp hw with ⟨w₁, hw₁, w₂, hw₂, hsum⟩
  refine Submodule.mem_sup.mpr ?_
  refine ⟨ρ.act g w₁, hW₁ g w₁ hw₁, ρ.act g w₂, hW₂ g w₂ hw₂, ?_⟩
  calc
    ρ.act g w₁ + ρ.act g w₂ = ρ.act g (w₁ + w₂) := by
      simp [LinearRepresentation.act, map_add]
    _ = ρ.act g w := by simpa [hsum]

end LinearRepresentation
end KeplerHurwitz
