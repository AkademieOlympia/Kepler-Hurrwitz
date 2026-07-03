import Mathlib
import KeplerHurwitz.KeplerInvariants
import KeplerHurwitz.ResidueFilters

namespace KeplerHurwitz

/--
Autorenkanal fuer externe mathematische Resultatlinien.
-/
inductive ExternalAuthor where
  | hales
  | tao
deriving DecidableEq, Repr

/--
Integrationsstatus im Lean-Kern.
-/
inductive IntegrationStatus where
  | interface_only
  | formal_seed
  | formalized
deriving DecidableEq, Repr

/--
Ein integrierbarer Resultatknoten mit formaler Aussage.
-/
structure ExternalResultNode where
  id : String
  author : ExternalAuthor
  title : String
  statement : Prop
  status : IntegrationStatus

/--
Ein Knoten gilt als "im Kern integriert", wenn seine Aussage als Proposition
im Lean-System vorliegt (unabhaengig vom aktuellen Statusniveau).
-/
def IsIntegrated (r : ExternalResultNode) : Prop :=
  r.statement

/--
Formaler Seed in der Kepler-Linie:
Geschwindigkeits-zu-Radialverhaeltnis (Kepler-Geometrie).
-/
theorem hales_kepler_seed
    {a e : ℝ}
    (ha : 0 < a) (he0 : 0 ≤ e) (he1 : e < 1) :
    radiusRatio e = perihelionSpeed a e / aphelionSpeed a e := by
  exact radiusRatio_eq_speedRatio ha he0 he1

/--
Formaler Seed in der Collatz-Restklassenlinie:
ungerade Zahlen fallen modulo 8 in vier Klassen.
-/
theorem tao_odd_mod8_seed
    {m : Nat}
    (hm : m % 2 = 1) :
    m % 8 = 1 ∨ m % 8 = 3 ∨ m % 8 = 5 ∨ m % 8 = 7 := by
  exact odd_mod8_cases hm

/--
Kanonischer Hales-Seed-Knoten.
-/
def halesSeedNode : ExternalResultNode where
  id := "HT-HALES-001"
  author := ExternalAuthor.hales
  title := "Kepler ratio-speed identity seed"
  statement := ∀ a e, 0 < a → 0 ≤ e → e < 1 →
    radiusRatio e = perihelionSpeed a e / aphelionSpeed a e
  status := IntegrationStatus.formal_seed

theorem halesSeedNode_integrated : IsIntegrated halesSeedNode := by
  intro a e ha he0 he1
  exact hales_kepler_seed ha he0 he1

/--
Kanonischer Tao-Seed-Knoten.
-/
def taoSeedNode : ExternalResultNode where
  id := "HT-TAO-001"
  author := ExternalAuthor.tao
  title := "Odd mod-8 residue decomposition seed"
  statement := ∀ m, m % 2 = 1 →
    (m % 8 = 1 ∨ m % 8 = 3 ∨ m % 8 = 5 ∨ m % 8 = 7)
  status := IntegrationStatus.formal_seed

theorem taoSeedNode_integrated : IsIntegrated taoSeedNode := by
  intro m hm
  exact tao_odd_mod8_seed hm

end KeplerHurwitz
