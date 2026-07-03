import KeplerHurwitz.Representation.EABCChronology

namespace KeplerHurwitz

/--
12-Ecken-Träger des Ikosaeder-Toymodells (`a5_geo`).
-/
abbrev IcosahedronVertex := Fin 12

/--
A-D: Abstrakter ungerichteter Nachbarschaftsgraph auf 12 Ecken.
Konkrete Ikosaeder-Kanten werden numerisch in Sage geliefert.
-/
structure IcosahedronCarrier where
  adj : IcosahedronVertex → IcosahedronVertex → Prop
  adj_comm : ∀ u v, adj u v ↔ adj v u

namespace IcosahedronCarrier

variable (G : IcosahedronCarrier)

def Adjacent (u v : IcosahedronVertex) : Prop :=
  G.adj u v

theorem adjacent_symm {u v : IcosahedronVertex} :
    G.Adjacent u v ↔ G.Adjacent v u :=
  G.adj_comm u v

/--
A-D: Dreieck im Graphen — drei paarweise benachbarte Ecken.
-/
def IsGraphTriangle (T : Finset IcosahedronVertex) : Prop :=
  ∃ a b c : IcosahedronVertex,
    T = {a, b, c} ∧
    G.Adjacent a b ∧ G.Adjacent a c ∧ G.Adjacent b c

end IcosahedronCarrier

/--
A-D: EABC-Label auf den 12 Ecken.
-/
structure VertexLabeling where
  label : IcosahedronVertex → EABCChannel

/--
A-D: Die drei Musketiere (Mantelkanäle); `E` ist die Mittelachse.
-/
def musketeerChannels : Finset EABCChannel := {EABCChannel.A, EABCChannel.B, EABCChannel.C}

/--
A-D: Die drei uebrigen Kanaele relativ zum Träger-Saal `host`.
-/
def otherChannels (host : EABCChannel) : Finset EABCChannel :=
  Finset.univ \ {host}

/--
A-T: Jeder Bremensaal sieht genau drei uebrige EABC-Kanaele.
-/
theorem otherChannels_card (host : EABCChannel) : (otherChannels host).card = 3 := by
  fin_cases host <;> decide

namespace VertexLabeling

variable (σ : VertexLabeling)

def fiber (c : EABCChannel) : Finset IcosahedronVertex :=
  Finset.univ.filter (fun v => σ.label v = c)

/--
A-D: Bremensaal-Zerlegung — vier disjunkte Dreierbloecke, je ein Kanal.
Jede Ecke traegt genau das Label ihres Saals.
-/
def IsBremensaalDecomposition : Prop :=
  (∀ c : EABCChannel, (σ.fiber c).card = 3) ∧
  (∀ v : IcosahedronVertex, v ∈ σ.fiber (σ.label v))

def isMusketeer (c : EABCChannel) : Prop :=
  c ∈ musketeerChannels

/--
A-D: Das Label-Dreier bildet die drei Nicht-Träger-Kanaele bijektiv ab.
-/
def IsOtherFamilyLabelTriple (host : EABCChannel) (T : Finset IcosahedronVertex) : Prop :=
  ∀ c ∈ otherChannels host, (T.filter (fun v => σ.label v = c)).card = 1

/--
A-D: Graph-Dreier beruehrt den Träger-Bremensaal `host` ueber mindestens eine Kante.
-/
def TriangleTouchesBremensaal
    (G : IcosahedronCarrier) (host : EABCChannel) (T : Finset IcosahedronVertex) : Prop :=
  ∃ v ∈ T, ∃ w ∈ σ.fiber host, G.Adjacent v w

/--
A-D: Musketiere-Nachbar-Dreier fuer den Bremensaal mit Trägerkanal `host`.
-/
def HasMusketiereNeighborTriple (G : IcosahedronCarrier) (host : EABCChannel) : Prop :=
  ∃ T : Finset IcosahedronVertex,
    G.IsGraphTriangle T ∧
    σ.IsOtherFamilyLabelTriple host T ∧
    σ.TriangleTouchesBremensaal G host T

/--
A-D: Relabeling der EABC-Kanaele auf festem Vertex-Träger (Gauge auf Label-Ebene).
-/
def relabelVertexLabeling (σ : VertexLabeling) (π : EABCChannel ≃ EABCChannel) : VertexLabeling :=
  { label := fun v => π (σ.label v) }

theorem relabel_fiber (π : EABCChannel ≃ EABCChannel) (c : EABCChannel) :
    (relabelVertexLabeling σ π).fiber c = σ.fiber (π.symm c) := by
  ext v
  simp [relabelVertexLabeling, fiber, Equiv.eq_symm_apply]

theorem relabel_isBremensaalDecomposition (π : EABCChannel ≃ EABCChannel)
    (hσ : σ.IsBremensaalDecomposition) :
    (relabelVertexLabeling σ π).IsBremensaalDecomposition := by
  constructor
  · intro c
    rw [relabel_fiber σ π c]
    exact hσ.1 (π.symm c)
  · intro v
    simp [relabelVertexLabeling, fiber, hσ.2 v]

private theorem filter_label_relabel (π : EABCChannel ≃ EABCChannel)
    (T : Finset IcosahedronVertex) (c : EABCChannel) :
    (T.filter (fun v => (relabelVertexLabeling σ π).label v = c)) =
      T.filter (fun v => σ.label v = π.symm c) := by
  ext v
  simp [relabelVertexLabeling, Equiv.eq_symm_apply]

private theorem mem_otherChannels_symm {π : EABCChannel ≃ EABCChannel}
    {host c : EABCChannel} (hc : c ∈ otherChannels (π host)) :
    π.symm c ∈ otherChannels host := by
  simp [otherChannels] at hc ⊢
  intro heq
  apply hc
  rw [← π.apply_symm_apply c, heq]

/--
A-T: Musketiere-Nachbar-Dreier ist invariant unter Kanal-Relabeling auf festem Graphen.
-/
theorem HasMusketiereNeighborTriple_relabel (G : IcosahedronCarrier)
    {host : EABCChannel} (π : EABCChannel ≃ EABCChannel)
    (h : σ.HasMusketiereNeighborTriple G host) :
    (relabelVertexLabeling σ π).HasMusketiereNeighborTriple G (π host) := by
  rcases h with ⟨T, htri, hlabels, htouch⟩
  refine ⟨T, htri, ?_, ?_⟩
  · intro c hc
    rw [filter_label_relabel σ π T c]
    exact hlabels (π.symm c) (mem_otherChannels_symm hc)
  · simp [TriangleTouchesBremensaal, relabel_fiber σ π (π host), Equiv.apply_symm_apply]
    exact htouch

end VertexLabeling

@[ext]
theorem VertexLabeling.ext {σ τ : VertexLabeling} (h : ∀ v, σ.label v = τ.label v) : σ = τ := by
  obtain ⟨σl⟩ := σ
  obtain ⟨τl⟩ := τ
  congr
  funext v
  exact h v

/--
A-D: Objektivitaet — die Nachbar-Dreier-Relation ist unter Träger-erhaltenden
Graph-Automorphismen invariant formuliert (Schnittstelle; konkrete Automorphismen
werden numerisch via `A5` geliefert).

Siehe `LabelIntertwiningGraphAuto` (E-032) fuer die Brücke zum kanonischen Transfer.
-/
structure LabelPreservingGraphMap where
  carrier : IcosahedronCarrier
  labeling : VertexLabeling
  toPerm : IcosahedronVertex → IcosahedronVertex
  preserves_adj :
    ∀ u v, carrier.Adjacent u v ↔ carrier.Adjacent (toPerm u) (toPerm v)
  preserves_label :
    ∀ v, labeling.label (toPerm v) = labeling.label v

/--
Legacy (schwach / tautologisch): unter der Praemisse der Existenz von Musketiere-Nachbar-Dreiern
fuer alle Traeger folgt dieselbe Existenz — unabhaengig von `LabelPreservingGraphMap`.
Echte Objektivitaets-Bruecke: `RespectsLabelFibersUnderAutos`, `CanonicalBridgeHypothesis` (E-032).
-/
def MusketiereNeighborTripleObjective
    (G : IcosahedronCarrier) (σ : VertexLabeling) : Prop :=
  (∀ host : EABCChannel, σ.HasMusketiereNeighborTriple G host) →
    ∀ φ : LabelPreservingGraphMap,
      φ.carrier = G → φ.labeling = σ →
      ∀ host : EABCChannel, σ.HasMusketiereNeighborTriple G host

theorem musketiereNeighborTripleObjective_tautological (G : IcosahedronCarrier) (σ : VertexLabeling)
    (h : ∀ host : EABCChannel, σ.HasMusketiereNeighborTriple G host) :
    MusketiereNeighborTripleObjective G σ :=
  fun hTriple _φ _hG _hσ host => hTriple host

/--
C: In jedem Bremensaal (je EABC-Kanal) existiert ein Nachbar-Dreier der
drei uebrigen Familien, und diese Beziehung ist objektiv.

Fuer den kanonischen Orbit-Zielkorridor (`musketiere_hypothesis_canonical_orbit`) genuegt
`CanonicalBridgeHypothesis` statt der schwachen `MusketiereNeighborTripleObjective`.
-/
def MusketiereNeighborTripleHypothesis : Prop :=
  ∀ (G : IcosahedronCarrier) (σ : VertexLabeling),
    σ.IsBremensaalDecomposition →
    (∀ host : EABCChannel, σ.HasMusketiereNeighborTriple G host) ∧
    MusketiereNeighborTripleObjective G σ

/--
C: Spezialisierung auf die vier Trägerkanaele `E`, `A`, `B`, `C`.
-/
def MusketiereNeighborTripleForAllFamilies : Prop :=
  ∀ (G : IcosahedronCarrier) (σ : VertexLabeling),
    σ.IsBremensaalDecomposition →
    ∀ host : EABCChannel, σ.HasMusketiereNeighborTriple G host

/-!
## Kanonisches Referenzsystem (E-028)

Ikosaeder-Kantengraph und Labelcode aus Sage `a5_geo_canonical_embedding`,
fixiert auf die Vertex-Indizes `0..11` des `a5_geo`-Trägers.
-/

private def canonicalUndirectedEdge (a b : Nat) : Bool :=
  match min a b, max a b with
  | 0, 1 => true
  | 0, 2 => true
  | 0, 6 => true
  | 0, 7 => true
  | 0, 8 => true
  | 1, 2 => true
  | 1, 3 => true
  | 1, 5 => true
  | 1, 7 => true
  | 2, 4 => true
  | 2, 5 => true
  | 2, 6 => true
  | 3, 5 => true
  | 3, 7 => true
  | 3, 9 => true
  | 3, 11 => true
  | 4, 5 => true
  | 4, 6 => true
  | 4, 9 => true
  | 4, 10 => true
  | 5, 9 => true
  | 6, 8 => true
  | 6, 10 => true
  | 7, 8 => true
  | 7, 11 => true
  | 8, 10 => true
  | 8, 11 => true
  | 9, 10 => true
  | 9, 11 => true
  | 10, 11 => true
  | _, _ => false

/--
A-D: Entscheidbare Ikosaeder-Adjazenz des kanonischen Referenzsystems.
30 ungerichtete Kanten; 5-regulaerer Graph auf 12 Ecken.
-/
def icosahedronCanonicalAdjBool (u v : IcosahedronVertex) : Bool :=
  canonicalUndirectedEdge u.val v.val

def icosahedronCanonicalAdj (u v : IcosahedronVertex) : Prop :=
  icosahedronCanonicalAdjBool u v = true

theorem icosahedronCanonicalAdj_symm (u v : IcosahedronVertex) :
    icosahedronCanonicalAdj u v ↔ icosahedronCanonicalAdj v u := by
  unfold icosahedronCanonicalAdj icosahedronCanonicalAdjBool canonicalUndirectedEdge
  simp only [min_comm, max_comm]

def canonicalIcosahedronCarrier : IcosahedronCarrier where
  adj := icosahedronCanonicalAdj
  adj_comm := icosahedronCanonicalAdj_symm

/-!
### Ikosaeder-Endomorphismen (E-032 Schritt 1)

Adjazenz-erhaltende Endomorphismen auf dem fest codierten `Fin 12`-Träger sind bijektiv.
Schlüssel: Nur `Finset.univ` trägt 30 Kanten; starke Erhaltung zwingt `Im(f) = univ`.
-/

private def icosahedronNeighborFinset (u : IcosahedronVertex) : Finset IcosahedronVertex :=
  Finset.univ.filter (fun v => icosahedronCanonicalAdjBool u v)

private def icosahedronEdgePairs : Finset (IcosahedronVertex × IcosahedronVertex) :=
  Finset.univ.filter (fun p : IcosahedronVertex × IcosahedronVertex =>
    p.1 < p.2 ∧ icosahedronCanonicalAdjBool p.1 p.2)

private def icosahedronEdgeCount (S : Finset IcosahedronVertex) : Nat :=
  (icosahedronEdgePairs.filter (fun p => p.1 ∈ S ∧ p.2 ∈ S)).card

private lemma icosahedronEdgePairs_card : icosahedronEdgePairs.card = 30 := by
  native_decide

private lemma icosahedronEdgeCount_univ : icosahedronEdgeCount Finset.univ = 30 := by
  native_decide

private lemma icosahedronNeighborFinset_spec (u : IcosahedronVertex) :
    icosahedronNeighborFinset u =
      match u with
      | 0 => ({1, 2, 6, 7, 8} : Finset IcosahedronVertex)
      | 1 => {0, 2, 3, 5, 7}
      | 2 => {0, 1, 4, 5, 6}
      | 3 => {1, 5, 7, 9, 11}
      | 4 => {2, 5, 6, 9, 10}
      | 5 => {1, 2, 3, 4, 9}
      | 6 => {0, 2, 4, 8, 10}
      | 7 => {0, 1, 3, 8, 11}
      | 8 => {0, 6, 7, 10, 11}
      | 9 => {3, 4, 5, 10, 11}
      | 10 => {4, 6, 8, 9, 11}
      | 11 => {3, 7, 8, 9, 10} := by
  fin_cases u <;> decide

private lemma icosahedronNeighborFinset_ne {u v : IcosahedronVertex} (hne : u ≠ v) :
    icosahedronNeighborFinset u ≠ icosahedronNeighborFinset v := by
  fin_cases u <;> fin_cases v <;> first | (contradiction) | (simp [icosahedronNeighborFinset_spec]; native_decide)

private lemma icosahedronNeighborFinset_eq {u v : IcosahedronVertex}
    (h : icosahedronNeighborFinset u = icosahedronNeighborFinset v) : u = v := by
  by_contra hne
  exact icosahedronNeighborFinset_ne hne h

/--
A-T (E-032 Schritt 1): Adjazenz-Iff-Erhaltung auf dem Ikosaeder erzwingt Injektivität.

Zentrale Idee: Ecken haben paarweise verschiedene Nachbarschaftsmengen (`native_decide`);
kollabiert `f`-Bilder würden dieselbe Nachbarschaft tragen — Widerspruch.
-/
theorem icosahedronAdj_preserving_injective {f : IcosahedronVertex → IcosahedronVertex}
    (hf : ∀ u v, icosahedronCanonicalAdj u v ↔ icosahedronCanonicalAdj (f u) (f v)) :
    Function.Injective f := by
  intro u v heq
  by_contra hne
  have hdiff : ¬ ∀ x, x ∈ icosahedronNeighborFinset u ↔ x ∈ icosahedronNeighborFinset v := by
    intro hall
    apply hne
    exact icosahedronNeighborFinset_eq (Finset.ext hall)
  push_neg at hdiff
  obtain ⟨x, hx⟩ := hdiff
  rcases hx with ⟨hxu, hxv⟩ | ⟨hxu, hxv⟩
  · simp only [icosahedronNeighborFinset, icosahedronCanonicalAdj, icosahedronCanonicalAdjBool,
      Finset.mem_filter, Finset.mem_univ, true_and] at hxu hxv
    have hadj_w : icosahedronCanonicalAdj (f u) (f x) := (hf u x).mp hxu
    rw [heq] at hadj_w
    exact hxv ((hf v x).mpr hadj_w)
  · simp only [icosahedronNeighborFinset, icosahedronCanonicalAdj, icosahedronCanonicalAdjBool,
      Finset.mem_filter, Finset.mem_univ, true_and] at hxu hxv
    have hadj_w : icosahedronCanonicalAdj (f v) (f x) := (hf v x).mp hxv
    rw [← heq] at hadj_w
    exact hxu ((hf u x).mpr hadj_w)

theorem icosahedronAdj_preserving_bijective {f : IcosahedronVertex → IcosahedronVertex}
    (hf : ∀ u v, icosahedronCanonicalAdj u v ↔ icosahedronCanonicalAdj (f u) (f v)) :
    Function.Bijective f :=
  (Nat.bijective_iff_injective_and_card f).mpr
    ⟨icosahedronAdj_preserving_injective hf, rfl⟩

noncomputable def icosahedronAdjPreserving_toEquiv {f : IcosahedronVertex → IcosahedronVertex}
    (hf : ∀ u v, icosahedronCanonicalAdj u v ↔ icosahedronCanonicalAdj (f u) (f v)) :
    IcosahedronVertex ≃ IcosahedronVertex :=
  Equiv.ofBijective f (icosahedronAdj_preserving_bijective hf)

theorem icosahedronCarrierAdj_preserving_injective {G : IcosahedronCarrier}
    (hG : G = canonicalIcosahedronCarrier) {f : IcosahedronVertex → IcosahedronVertex}
    (hf : ∀ u v, G.Adjacent u v ↔ G.Adjacent (f u) (f v)) :
    Function.Injective f := by
  rw [hG] at hf
  exact icosahedronAdj_preserving_injective hf

theorem icosahedronCarrierAdjPreserving_adj {G : IcosahedronCarrier}
    (hG : G = canonicalIcosahedronCarrier) {f : IcosahedronVertex → IcosahedronVertex}
    (hf : ∀ u v, G.Adjacent u v ↔ G.Adjacent (f u) (f v)) (u v : IcosahedronVertex) :
    canonicalIcosahedronCarrier.Adjacent u v ↔
      canonicalIcosahedronCarrier.Adjacent (f u) (f v) := by
  rw [← hG]
  exact hf u v

noncomputable def icosahedronCarrierAdjPreserving_toEquiv {G : IcosahedronCarrier}
    (hG : G = canonicalIcosahedronCarrier) {f : IcosahedronVertex → IcosahedronVertex}
    (hf : ∀ u v, G.Adjacent u v ↔ G.Adjacent (f u) (f v)) :
    IcosahedronVertex ≃ IcosahedronVertex :=
  icosahedronAdjPreserving_toEquiv (by rw [hG] at hf; exact hf)

/--
A-D: Kanonischer Labelcode (K1–K4), numerisch `0=E, 1=A, 2=B, 3=C`.
-/
def canonicalLabelCode : IcosahedronVertex → EABCChannel
  | ⟨0, _⟩ => EABCChannel.E
  | ⟨1, _⟩ => EABCChannel.A
  | ⟨2, _⟩ => EABCChannel.E
  | ⟨3, _⟩ => EABCChannel.C
  | ⟨4, _⟩ => EABCChannel.B
  | ⟨5, _⟩ => EABCChannel.C
  | ⟨6, _⟩ => EABCChannel.A
  | ⟨7, _⟩ => EABCChannel.E
  | ⟨8, _⟩ => EABCChannel.A
  | ⟨9, _⟩ => EABCChannel.B
  | ⟨10, _⟩ => EABCChannel.C
  | ⟨11, _⟩ => EABCChannel.B

def canonicalVertexLabeling : VertexLabeling :=
  { label := canonicalLabelCode }

private lemma canonicalAdj {u v : IcosahedronVertex}
    (h : icosahedronCanonicalAdjBool u v = true) :
    canonicalIcosahedronCarrier.Adjacent u v :=
  h

theorem canonicalLabelCode_fiber_E :
    canonicalVertexLabeling.fiber EABCChannel.E = {0, 2, 7} := by
  ext v
  fin_cases v <;>
    simp [VertexLabeling.fiber, canonicalVertexLabeling, canonicalLabelCode, EABCChannel]

theorem canonicalLabelCode_fiber_A :
    canonicalVertexLabeling.fiber EABCChannel.A = {1, 6, 8} := by
  ext v
  fin_cases v <;>
    simp [VertexLabeling.fiber, canonicalVertexLabeling, canonicalLabelCode, EABCChannel]

theorem canonicalLabelCode_fiber_B :
    canonicalVertexLabeling.fiber EABCChannel.B = {4, 9, 11} := by
  ext v
  fin_cases v <;>
    simp [VertexLabeling.fiber, canonicalVertexLabeling, canonicalLabelCode, EABCChannel]

theorem canonicalLabelCode_fiber_C :
    canonicalVertexLabeling.fiber EABCChannel.C = {3, 5, 10} := by
  ext v
  fin_cases v <;>
    simp [VertexLabeling.fiber, canonicalVertexLabeling, canonicalLabelCode, EABCChannel]

theorem canonicalVertexLabeling_isBremensaalDecomposition :
    canonicalVertexLabeling.IsBremensaalDecomposition := by
  constructor
  · intro c
    cases c <;> simp [canonicalLabelCode_fiber_E, canonicalLabelCode_fiber_A,
      canonicalLabelCode_fiber_B, canonicalLabelCode_fiber_C]
  · intro v
    fin_cases v <;> simp [VertexLabeling.fiber, canonicalVertexLabeling, canonicalLabelCode]

private def witnessTriangleE : Finset IcosahedronVertex := {4, 6, 10}
private def witnessTriangleA : Finset IcosahedronVertex := {2, 4, 5}
private def witnessTriangleB : Finset IcosahedronVertex := {1, 2, 5}
private def witnessTriangleC : Finset IcosahedronVertex := {2, 4, 6}

private lemma canonical_triangle_E :
    canonicalIcosahedronCarrier.IsGraphTriangle witnessTriangleE := by
  refine ⟨4, 6, 10, ?_, canonicalAdj (by decide), canonicalAdj (by decide),
    canonicalAdj (by decide)⟩
  decide

private lemma canonical_triangle_A :
    canonicalIcosahedronCarrier.IsGraphTriangle witnessTriangleA := by
  refine ⟨2, 4, 5, ?_, canonicalAdj (by decide), canonicalAdj (by decide), canonicalAdj (by decide)⟩
  decide

private lemma canonical_triangle_B :
    canonicalIcosahedronCarrier.IsGraphTriangle witnessTriangleB := by
  refine ⟨1, 2, 5, ?_, canonicalAdj (by decide), canonicalAdj (by decide), canonicalAdj (by decide)⟩
  decide

private lemma canonical_triangle_C :
    canonicalIcosahedronCarrier.IsGraphTriangle witnessTriangleC := by
  refine ⟨2, 4, 6, ?_, canonicalAdj (by decide), canonicalAdj (by decide), canonicalAdj (by decide)⟩
  decide

private lemma canonical_filter_card_one {T : Finset IcosahedronVertex} {c : EABCChannel}
    {v : IcosahedronVertex}
    (h : T.filter (fun x => canonicalLabelCode x = c) = {v}) :
    (T.filter (fun x => canonicalVertexLabeling.label x = c)).card = 1 := by
  have heq : T.filter (fun x => canonicalVertexLabeling.label x = c) =
      T.filter (fun x => canonicalLabelCode x = c) := by
    simp [canonicalVertexLabeling]
  rw [heq, h, Finset.card_singleton]

private lemma canonical_other_labels_E :
    canonicalVertexLabeling.IsOtherFamilyLabelTriple EABCChannel.E witnessTriangleE := by
  intro c hc
  fin_cases c
  · simp [otherChannels] at hc
  · exact canonical_filter_card_one (T := witnessTriangleE) (c := EABCChannel.A) (v := 6) (by decide)
  · exact canonical_filter_card_one (T := witnessTriangleE) (c := EABCChannel.B) (v := 4) (by decide)
  · exact canonical_filter_card_one (T := witnessTriangleE) (c := EABCChannel.C) (v := 10) (by decide)

private lemma canonical_other_labels_A :
    canonicalVertexLabeling.IsOtherFamilyLabelTriple EABCChannel.A witnessTriangleA := by
  intro c hc
  fin_cases c
  · exact canonical_filter_card_one (T := witnessTriangleA) (c := EABCChannel.E) (v := 2) (by decide)
  · simp [otherChannels] at hc
  · exact canonical_filter_card_one (T := witnessTriangleA) (c := EABCChannel.B) (v := 4) (by decide)
  · exact canonical_filter_card_one (T := witnessTriangleA) (c := EABCChannel.C) (v := 5) (by decide)

private lemma canonical_other_labels_B :
    canonicalVertexLabeling.IsOtherFamilyLabelTriple EABCChannel.B witnessTriangleB := by
  intro c hc
  fin_cases c
  · exact canonical_filter_card_one (T := witnessTriangleB) (c := EABCChannel.E) (v := 2) (by decide)
  · exact canonical_filter_card_one (T := witnessTriangleB) (c := EABCChannel.A) (v := 1) (by decide)
  · simp [otherChannels] at hc
  · exact canonical_filter_card_one (T := witnessTriangleB) (c := EABCChannel.C) (v := 5) (by decide)

private lemma canonical_other_labels_C :
    canonicalVertexLabeling.IsOtherFamilyLabelTriple EABCChannel.C witnessTriangleC := by
  intro c hc
  fin_cases c
  · exact canonical_filter_card_one (T := witnessTriangleC) (c := EABCChannel.E) (v := 2) (by decide)
  · exact canonical_filter_card_one (T := witnessTriangleC) (c := EABCChannel.A) (v := 6) (by decide)
  · exact canonical_filter_card_one (T := witnessTriangleC) (c := EABCChannel.B) (v := 4) (by decide)
  · simp [otherChannels] at hc

private lemma canonical_touches_E :
    canonicalVertexLabeling.TriangleTouchesBremensaal
      canonicalIcosahedronCarrier EABCChannel.E witnessTriangleE := by
  refine ⟨4, by decide, 2, by decide, canonicalAdj (by decide)⟩

private lemma canonical_touches_A :
    canonicalVertexLabeling.TriangleTouchesBremensaal
      canonicalIcosahedronCarrier EABCChannel.A witnessTriangleA := by
  refine ⟨2, by decide, 1, by decide, canonicalAdj (by decide)⟩

private lemma canonical_touches_B :
    canonicalVertexLabeling.TriangleTouchesBremensaal
      canonicalIcosahedronCarrier EABCChannel.B witnessTriangleB := by
  refine ⟨2, by decide, 4, by decide, canonicalAdj (by decide)⟩

private lemma canonical_touches_C :
    canonicalVertexLabeling.TriangleTouchesBremensaal
      canonicalIcosahedronCarrier EABCChannel.C witnessTriangleC := by
  refine ⟨2, by decide, 5, by decide, canonicalAdj (by decide)⟩

/--
A-T: Kanonisches Referenzsystem — Musketiere-Nachbar-Dreier fuer Träger `E`.
Sage-Zeuge: `(4, 6, 10)` mit Labels `(B, A, C)`, beruehrt E-Saal an Ecke `2`.
-/
theorem canonical_has_musketiere_neighbor_triple_E :
    canonicalVertexLabeling.HasMusketiereNeighborTriple
      canonicalIcosahedronCarrier EABCChannel.E := by
  refine ⟨witnessTriangleE, canonical_triangle_E, canonical_other_labels_E, canonical_touches_E⟩

/--
A-T: Kanonisches Referenzsystem — Musketiere-Nachbar-Dreier fuer Träger `A`.
Sage-Zeuge: `(2, 4, 5)` mit Labels `(E, B, C)`.
-/
theorem canonical_has_musketiere_neighbor_triple_A :
    canonicalVertexLabeling.HasMusketiereNeighborTriple
      canonicalIcosahedronCarrier EABCChannel.A := by
  refine ⟨witnessTriangleA, canonical_triangle_A, canonical_other_labels_A, canonical_touches_A⟩

/--
A-T: Kanonisches Referenzsystem — Musketiere-Nachbar-Dreier fuer Träger `B`.
Sage-Zeuge: `(1, 2, 5)` mit Labels `(A, E, C)`.
-/
theorem canonical_has_musketiere_neighbor_triple_B :
    canonicalVertexLabeling.HasMusketiereNeighborTriple
      canonicalIcosahedronCarrier EABCChannel.B := by
  refine ⟨witnessTriangleB, canonical_triangle_B, canonical_other_labels_B, canonical_touches_B⟩

/--
A-T: Kanonisches Referenzsystem — Musketiere-Nachbar-Dreier fuer Träger `C`.
Sage-Zeuge: `(2, 4, 6)` mit Labels `(E, B, A)`.
-/
theorem canonical_has_musketiere_neighbor_triple_C :
    canonicalVertexLabeling.HasMusketiereNeighborTriple
      canonicalIcosahedronCarrier EABCChannel.C := by
  refine ⟨witnessTriangleC, canonical_triangle_C, canonical_other_labels_C, canonical_touches_C⟩

/--
A-T: Kanonisches Referenzsystem erfuellt die Musketiere-Nachbar-Dreier-Eigenschaft
fuer alle vier Trägerkanaele.
-/
theorem canonical_musketiere_neighbor_triple_for_all_hosts :
    ∀ host : EABCChannel,
      canonicalVertexLabeling.HasMusketiereNeighborTriple canonicalIcosahedronCarrier host := by
  intro host
  cases host with
  | E => exact canonical_has_musketiere_neighbor_triple_E
  | A => exact canonical_has_musketiere_neighbor_triple_A
  | B => exact canonical_has_musketiere_neighbor_triple_B
  | C => exact canonical_has_musketiere_neighbor_triple_C

/-!
## Objektivitaet unter chi-Relabeling (E-030)
-/

/--
A-D: Chirale Permutation als Kanal-Automorphismus (`E -> A -> C -> B -> E`).
-/
def chiEquiv : EABCChannel ≃ EABCChannel where
  toFun := EABCChannel.chi
  invFun := EABCChannel.chiInv
  left_inv := EABCChannel.chiInv_chi
  right_inv := EABCChannel.chi_chiInv

/--
A-D: `pi` liegt in der chi-Orbitgruppe (Ordnung 4) auf den EABC-Kanaelen.
-/
def IsChiRelabeling (π : EABCChannel ≃ EABCChannel) : Prop :=
  ∃ n : Fin 4, π = chiEquiv ^ (n : Nat)

theorem chiEquiv_isChiRelabeling (n : Fin 4) : IsChiRelabeling (chiEquiv ^ (n : Nat)) :=
  ⟨n, rfl⟩

/--
A-T: chi-Relabeling erhaelt Musketiere-Nachbar-Dreier auf dem kanonischen Referenzsystem.
Der kanonische Beweis fuer Träger `pi.symm host` wird via `HasMusketiereNeighborTriple_relabel`
auf `host` transportiert.
-/
theorem musketiere_neighbor_triple_objectivity_chi (π : EABCChannel ≃ EABCChannel)
    (_hπ : IsChiRelabeling π) (host : EABCChannel) :
    (VertexLabeling.relabelVertexLabeling canonicalVertexLabeling π).HasMusketiereNeighborTriple
      canonicalIcosahedronCarrier host := by
  have h := canonical_musketiere_neighbor_triple_for_all_hosts (π.symm host)
  simpa [Equiv.symm_apply_apply] using
    VertexLabeling.HasMusketiereNeighborTriple_relabel canonicalVertexLabeling
      canonicalIcosahedronCarrier π h

/--
A-T: Globale Objektivitaetsfassung — alle chi-Relabelings des kanonischen Systems
erben die E-029-Eigenschaft fuer jeden Trägerkanal.
-/
theorem canonical_musketiere_neighbor_triple_chi_objectivity
    (π : EABCChannel ≃ EABCChannel) (hπ : IsChiRelabeling π) :
    ∀ host : EABCChannel,
      (VertexLabeling.relabelVertexLabeling canonicalVertexLabeling π).HasMusketiereNeighborTriple
        canonicalIcosahedronCarrier host :=
  fun host => musketiere_neighbor_triple_objectivity_chi π hπ host

/-!
## Äquivalenz-Kollaps zum kanonischen Referenzsystem (E-031)

Sage liefert fuer die 9 bestandenen toy-Embeddings Zeugen `(σ, τ)` mit
Graph-Automorphismus `σ` und Kanal-Relabeling `τ`. Lean transportiert E-029
entlang dieser Brücke auf alle `IsEquivalentToCanonical`-Labelings.
-/

/--
A-D: Musketiere-Nachbar-Dreier fuer alle vier Trägerkanaele auf festem `(G, σ)`.
-/
def MusketiereNeighborTripleHypothesisFor (G : IcosahedronCarrier) (σ : VertexLabeling) : Prop :=
  ∀ host : EABCChannel, σ.HasMusketiereNeighborTriple G host

abbrev CanonicalMusketiereNeighborTripleHypothesis : Prop :=
  MusketiereNeighborTripleHypothesisFor canonicalIcosahedronCarrier canonicalVertexLabeling

theorem canonical_musketiere_hypothesis : CanonicalMusketiereNeighborTripleHypothesis :=
  canonical_musketiere_neighbor_triple_for_all_hosts

/--
A-D: Automorphismus des kanonischen Ikosaeder-Graphen auf `Fin 12`.
Numerisch entspricht dies einer `A5`-Wirkung auf den sortierten Ecken.
-/
def IsIcosahedronGraphAutomorphism (σ : IcosahedronVertex ≃ IcosahedronVertex) : Prop :=
  ∀ u v, canonicalIcosahedronCarrier.Adjacent u v ↔
    canonicalIcosahedronCarrier.Adjacent (σ u) (σ v)

noncomputable def LabelPreservingGraphMap.toGraphEquiv (φ : LabelPreservingGraphMap)
    (hG : φ.carrier = canonicalIcosahedronCarrier) :
    IcosahedronVertex ≃ IcosahedronVertex :=
  icosahedronCarrierAdjPreserving_toEquiv hG φ.preserves_adj

theorem LabelPreservingGraphMap.isIcosahedronGraphAutomorph (φ : LabelPreservingGraphMap)
    (hG : φ.carrier = canonicalIcosahedronCarrier) :
    IsIcosahedronGraphAutomorphism (φ.toGraphEquiv hG) := by
  intro u v
  simp only [IsIcosahedronGraphAutomorphism, toGraphEquiv,
    icosahedronCarrierAdjPreserving_toEquiv, icosahedronAdjPreserving_toEquiv,
    Equiv.ofBijective_apply]
  exact icosahedronCarrierAdjPreserving_adj hG φ.preserves_adj u v

/--
A-D: Labeling ist bis auf Graph-Automorphismus und Kanal-Relabeling kanonisch.
-/
def IsEquivalentToCanonical (L : VertexLabeling) : Prop :=
  ∃ (σ : IcosahedronVertex ≃ IcosahedronVertex) (τ : EABCChannel ≃ EABCChannel),
    IsIcosahedronGraphAutomorphism σ ∧
      ∀ v, L.label v = τ (canonicalLabelCode (σ v))

/--
A-D: Kanonisches Labeling entlang eines Graph-Automorphismus vorziehen.
-/
def pushLabelAlongAutomorph (σ : IcosahedronVertex ≃ IcosahedronVertex) : VertexLabeling :=
  { label := fun v => canonicalLabelCode (σ v) }

theorem pushLabelAlongAutomorph_fiber (σ : IcosahedronVertex ≃ IcosahedronVertex)
    (c : EABCChannel) :
    (pushLabelAlongAutomorph σ).fiber c = (canonicalVertexLabeling.fiber c).map σ.symm.toEmbedding := by
  ext v
  simp only [pushLabelAlongAutomorph, VertexLabeling.fiber, canonicalVertexLabeling,
    Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_map]
  constructor
  · intro h
    exact ⟨σ v, h, σ.left_inv v⟩
  · intro ⟨a, ha, heq⟩
    subst heq
    simpa using ha

private theorem isGraphTriangle_map {σ : IcosahedronVertex ≃ IcosahedronVertex}
    (hσ : IsIcosahedronGraphAutomorphism σ) {T : Finset IcosahedronVertex}
    (ht : canonicalIcosahedronCarrier.IsGraphTriangle T) :
    canonicalIcosahedronCarrier.IsGraphTriangle (T.map σ.symm.toEmbedding) := by
  rcases ht with ⟨a, b, c, hT, hab, hac, hbc⟩
  refine ⟨σ.symm a, σ.symm b, σ.symm c, ?_, ?_, ?_, ?_⟩
  · rw [hT]
    ext x
    simp only [Finset.mem_map, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · intro ⟨y, hy, heq⟩
      rcases hy with rfl | rfl | rfl
      · exact Or.inl heq.symm
      · exact Or.inr (Or.inl heq.symm)
      · exact Or.inr (Or.inr heq.symm)
    · intro hx
      rcases hx with rfl | rfl | rfl
      · exact ⟨a, Or.inl rfl, rfl⟩
      · exact ⟨b, Or.inr (Or.inl rfl), rfl⟩
      · exact ⟨c, Or.inr (Or.inr rfl), rfl⟩
  · have hσab : canonicalIcosahedronCarrier.Adjacent (σ (σ.symm a)) (σ (σ.symm b)) := by
      simpa [Equiv.apply_symm_apply] using hab
    exact (hσ (σ.symm a) (σ.symm b)).mpr hσab
  · have hσac : canonicalIcosahedronCarrier.Adjacent (σ (σ.symm a)) (σ (σ.symm c)) := by
      simpa [Equiv.apply_symm_apply] using hac
    exact (hσ (σ.symm a) (σ.symm c)).mpr hσac
  · have hσbc : canonicalIcosahedronCarrier.Adjacent (σ (σ.symm b)) (σ (σ.symm c)) := by
      simpa [Equiv.apply_symm_apply] using hbc
    exact (hσ (σ.symm b) (σ.symm c)).mpr hσbc

private theorem map_symm_comp_map_eq {σ : IcosahedronVertex ≃ IcosahedronVertex}
    (T : Finset IcosahedronVertex) :
    (T.map σ.symm.toEmbedding).map σ.toEmbedding = T := by
  ext x
  simp [Finset.mem_map_equiv]

private theorem filter_pushLabelAlongAutomorph {σ : IcosahedronVertex ≃ IcosahedronVertex}
    (T : Finset IcosahedronVertex) (c : EABCChannel) :
    (T.filter (fun v => (pushLabelAlongAutomorph σ).label v = c)) =
      ((T.map σ.toEmbedding).filter (fun v => canonicalLabelCode v = c)).map σ.symm.toEmbedding := by
  simp only [pushLabelAlongAutomorph]
  symm
  rw [Finset.map_filter (f := σ.symm) (s := T.map σ.toEmbedding)
    (p := fun v => canonicalLabelCode v = c)]
  ext x
  simp [Finset.mem_map_equiv, Function.comp_def, canonicalLabelCode]

private theorem filter_pushLabelAlongAutomorph_card {σ : IcosahedronVertex ≃ IcosahedronVertex}
    (T : Finset IcosahedronVertex) (c : EABCChannel) :
    (T.filter (fun v => (pushLabelAlongAutomorph σ).label v = c)).card =
      ((T.map σ.toEmbedding).filter (fun v => canonicalLabelCode v = c)).card := by
  rw [filter_pushLabelAlongAutomorph, Finset.card_map]

private theorem map_symm_comp_map_eq' {σ : IcosahedronVertex ≃ IcosahedronVertex}
    (T : Finset IcosahedronVertex) :
    Finset.map σ.toEmbedding (Finset.map σ.symm.toEmbedding T) = T := by
  simpa using map_symm_comp_map_eq (σ := σ) (T := T)

private theorem isOtherFamilyLabelTriple_map {σ : IcosahedronVertex ≃ IcosahedronVertex}
    (host : EABCChannel) {T : Finset IcosahedronVertex}
    (h : canonicalVertexLabeling.IsOtherFamilyLabelTriple host T) :
    (pushLabelAlongAutomorph σ).IsOtherFamilyLabelTriple host (T.map σ.symm.toEmbedding) := by
  intro c hc
  rw [filter_pushLabelAlongAutomorph_card (σ := σ) (T := T.map σ.symm.toEmbedding) (c := c)]
  rw [show
      ((T.map σ.symm.toEmbedding).map σ.toEmbedding).filter (fun v => canonicalLabelCode v = c) =
        T.filter (fun v => canonicalVertexLabeling.label v = c) from by
    rw [map_symm_comp_map_eq (σ := σ) (T := T)]
    simp [canonicalVertexLabeling]]
  exact h c hc

private theorem triangleTouchesBremensaal_map {σ : IcosahedronVertex ≃ IcosahedronVertex}
    (hσ : IsIcosahedronGraphAutomorphism σ) (host : EABCChannel)
    {T : Finset IcosahedronVertex}
    (h : canonicalVertexLabeling.TriangleTouchesBremensaal
      canonicalIcosahedronCarrier host T) :
    (pushLabelAlongAutomorph σ).TriangleTouchesBremensaal
      canonicalIcosahedronCarrier host (T.map σ.symm.toEmbedding) := by
  rcases h with ⟨v, hvT, w, hwFiber, hadj⟩
  refine ⟨σ.symm v, ?_, σ.symm w, ?_, ?_⟩
  · simpa [Finset.mem_map_equiv] using hvT
  · rw [pushLabelAlongAutomorph_fiber σ host]
    simpa [Finset.mem_map_equiv] using hwFiber
  · have hσvw : canonicalIcosahedronCarrier.Adjacent (σ (σ.symm v)) (σ (σ.symm w)) := by
      simpa [Equiv.apply_symm_apply] using hadj
    exact (hσ (σ.symm v) (σ.symm w)).mpr hσvw

/--
A-T: Graph-Automorphismus transportiert den kanonischen Musketiere-Nachbar-Dreier-Beweis.
-/
theorem HasMusketiereNeighborTriple_pushAlongAutomorph
    (σ : IcosahedronVertex ≃ IcosahedronVertex) (hσ : IsIcosahedronGraphAutomorphism σ)
    {host : EABCChannel}
    (h : canonicalVertexLabeling.HasMusketiereNeighborTriple
      canonicalIcosahedronCarrier host) :
    (pushLabelAlongAutomorph σ).HasMusketiereNeighborTriple
      canonicalIcosahedronCarrier host := by
  rcases h with ⟨T, htri, hlabels, htouch⟩
  exact ⟨T.map σ.symm.toEmbedding, isGraphTriangle_map hσ htri,
    isOtherFamilyLabelTriple_map (σ := σ) (host := host) hlabels,
    triangleTouchesBremensaal_map hσ host htouch⟩

private theorem relabel_pushLabel_eq (σ : IcosahedronVertex ≃ IcosahedronVertex)
    (τ : EABCChannel ≃ EABCChannel) {L : VertexLabeling}
    (hlabel : ∀ v, L.label v = τ (canonicalLabelCode (σ v))) :
    L = VertexLabeling.relabelVertexLabeling (pushLabelAlongAutomorph σ) τ :=
  VertexLabeling.ext fun v => by simp [VertexLabeling.relabelVertexLabeling,
    pushLabelAlongAutomorph, hlabel v]

theorem canonical_is_equivalent_to_canonical : IsEquivalentToCanonical canonicalVertexLabeling := by
  refine ⟨Equiv.refl _, Equiv.refl _, ?_, fun _ => rfl⟩
  intro u v
  simp [IsIcosahedronGraphAutomorphism, canonicalIcosahedronCarrier, icosahedronCanonicalAdj]

theorem chi_relabeling_is_equivalent_to_canonical (π : EABCChannel ≃ EABCChannel) :
    IsEquivalentToCanonical (VertexLabeling.relabelVertexLabeling canonicalVertexLabeling π) := by
  refine ⟨Equiv.refl _, π, ?_, fun _ => rfl⟩
  intro u v
  simp [IsIcosahedronGraphAutomorphism, canonicalIcosahedronCarrier, icosahedronCanonicalAdj]

/--
A-T: Transfer-Theorem — kanonischer Beweis (E-029) plus chi-Objektivitaet (E-030)
erben alle `IsEquivalentToCanonical`-Labelings auf dem kanonischen Graphen.
-/
theorem musketiere_hypothesis_transfer (L : VertexLabeling) (h_equiv : IsEquivalentToCanonical L)
    (h_canon : CanonicalMusketiereNeighborTripleHypothesis) :
    MusketiereNeighborTripleHypothesisFor canonicalIcosahedronCarrier L := by
  intro host
  rcases h_equiv with ⟨σ, τ, hσauto, hlabel⟩
  have hpush := HasMusketiereNeighborTriple_pushAlongAutomorph σ hσauto
    (h_canon (τ.symm host))
  rw [relabel_pushLabel_eq σ τ hlabel]
  simpa [Equiv.apply_symm_apply] using
    VertexLabeling.HasMusketiereNeighborTriple_relabel (pushLabelAlongAutomorph σ)
      canonicalIcosahedronCarrier τ hpush

/--
A-D: K1–K4-Konformitaet (Sage `a5_geo_canonical_equivalence` liefert Zeugen fuer toy-Embeddings).
K1 lex-sort, K2 mod-4-Orbit, K3 E-Mittelachse, K4 chi-Label — numerisch auf dem
`a5_geo`-Träger verifiziert; formaler Kollaps via `IsEquivalentToCanonical`.
-/
def IsK1ToK4Conforming (L : VertexLabeling) : Prop :=
  L.IsBremensaalDecomposition ∧ IsEquivalentToCanonical L

theorem k1_k4_conforming_implies_musketiere (L : VertexLabeling)
    (h : IsK1ToK4Conforming L) (h_canon : CanonicalMusketiereNeighborTripleHypothesis) :
    MusketiereNeighborTripleHypothesisFor canonicalIcosahedronCarrier L :=
  musketiere_hypothesis_transfer L h.2 h_canon

theorem canonical_is_k1_k4_conforming : IsK1ToK4Conforming canonicalVertexLabeling :=
  ⟨canonicalVertexLabeling_isBremensaalDecomposition, canonical_is_equivalent_to_canonical⟩

/-!
## Objektivitäts-Brücke (E-032)

Verknüpft label- und adjazenz-erhaltende Strukturabbildungen mit
`IsEquivalentToCanonical` (E-031) und damit den generischen Transfer auf `E-026`.

Bijektivität von `σ` ist analytisch via `icosahedronAdj_preserving_bijective` gesichert
(Sage-Zählung: genau 120 Adjazenz-Automorphismen = |I_h|); ein `decide`-Pool der
Permutationen waere redundant.
-/

/--
A-D: Graph-Isomorphie auf festem Träger, die zwei Belegungen via Kanal-Gauge `τ` verknüpft.

Spezialfall `source = target`, `τ = id`: label-erhaltender Graph-Automorphismus
(legacy `LabelPreservingGraphMap` auf dem kanonischen Träger).
-/
structure LabelIntertwiningGraphAuto (G : IcosahedronCarrier)
    (source target : VertexLabeling) where
  σ : IcosahedronVertex ≃ IcosahedronVertex
  τ : EABCChannel ≃ EABCChannel
  preserves_adj :
    ∀ u v, G.Adjacent u v ↔ G.Adjacent (σ u) (σ v)
  intertwine : ∀ v, source.label v = τ (target.label (σ v))

/--
A-D: Strukturerhaltende Abbildung von `L` zum kanonischen Labelcode auf `Fin 12`.
Entspricht dem Sage-Zeugen `(σ, τ)` aus `a5_geo_canonical_equivalence`.
-/
abbrev LabelPreservingGraphMapToCanonical (L : VertexLabeling) :=
  LabelIntertwiningGraphAuto canonicalIcosahedronCarrier L canonicalVertexLabeling

/-!
### Faser-Symmetrie (E-032 Schritt 2)

Aus faser-respektierendem Graph-Automorphismus `σ` wird die Kanal-Bijektion `τ`
via `Fin 4`-Endlichkeit konstruiert.
-/

/--
A-D: `σ` bildet jede Quell-Faser auf eine einheitliche kanonische Kanalfaser ab.
Voraussetzung fuer die wohldefinierte Zuordnung `c ↦ d` mit
`canonicalLabelCode (σ v) = d` fuer alle `v ∈ L.fiber c`.
-/
def RespectsLabelFibers (L : VertexLabeling) (σ : IcosahedronVertex ≃ IcosahedronVertex) :
    Prop :=
  ∀ c : EABCChannel, ∃ d : EABCChannel, ∀ v ∈ L.fiber c, canonicalLabelCode (σ v) = d

private lemma mem_fiber_label (L : VertexLabeling) (v : IcosahedronVertex) :
    v ∈ L.fiber (L.label v) := by
  simp [VertexLabeling.fiber]

private lemma label_fiber_disjoint {L : VertexLabeling} {c₁ c₂ : EABCChannel}
    (hne : c₁ ≠ c₂) : Disjoint (L.fiber c₁) (L.fiber c₂) := by
  rw [Finset.disjoint_left]
  intro v hc₁ hc₂
  simp [VertexLabeling.fiber] at hc₁ hc₂
  exact hne (hc₁.symm.trans hc₂)

noncomputable def forwardChannelMap (L : VertexLabeling)
    (σ : IcosahedronVertex ≃ IcosahedronVertex) (h : RespectsLabelFibers L σ)
    (c : EABCChannel) : EABCChannel :=
  (h c).choose

theorem forwardChannelMap_spec (L : VertexLabeling) (σ : IcosahedronVertex ≃ IcosahedronVertex)
    (h : RespectsLabelFibers L σ) (c : EABCChannel) {v : IcosahedronVertex}
    (hv : v ∈ L.fiber c) :
    canonicalLabelCode (σ v) = forwardChannelMap L σ h c :=
  (h c).choose_spec v hv

private lemma forwardChannelMap_fiber_subset (L : VertexLabeling)
    (σ : IcosahedronVertex ≃ IcosahedronVertex) (h : RespectsLabelFibers L σ)
    (c : EABCChannel) :
    (L.fiber c).map σ.toEmbedding ⊆
      canonicalVertexLabeling.fiber (forwardChannelMap L σ h c) := by
  intro w hw
  obtain ⟨v, hv, rfl⟩ := Finset.mem_map.mp hw
  simp only [VertexLabeling.fiber, Finset.mem_filter, canonicalVertexLabeling,
    Finset.mem_univ, true_and]
  exact forwardChannelMap_spec L σ h c hv

/--
A-T (E-032 Schritt 2): Faser-respektierende Vorwärtsabbildung auf den vier Kanaelen ist injektiv.

Zentrale Idee: Zwei verschiedene Quell-Fasern (je Kardinalitaet 3) wuerden unter
disjunkten `σ`-Bildern eine kanonische Faser der Kardinalitaet 3 ueberfuellen.
-/
theorem forwardChannelMap_injective (L : VertexLabeling)
    (hL : L.IsBremensaalDecomposition) (σ : IcosahedronVertex ≃ IcosahedronVertex)
    (h : RespectsLabelFibers L σ) :
    Function.Injective (forwardChannelMap L σ h) := by
  intro c₁ c₂ heq
  by_contra hne
  have hdisj : Disjoint (L.fiber c₁) (L.fiber c₂) :=
    label_fiber_disjoint hne
  have hdisjσ : Disjoint ((L.fiber c₁).map σ.toEmbedding) ((L.fiber c₂).map σ.toEmbedding) := by
    rw [Finset.disjoint_map]
    exact hdisj
  let d := forwardChannelMap L σ h c₁
  have heq' : forwardChannelMap L σ h c₂ = d := heq.symm
  have hsub₁ := forwardChannelMap_fiber_subset L σ h c₁
  have hsub₂ : (L.fiber c₂).map σ.toEmbedding ⊆ canonicalVertexLabeling.fiber d := by
    rw [← heq']
    exact forwardChannelMap_fiber_subset L σ h c₂
  have hcard₁ : ((L.fiber c₁).map σ.toEmbedding).card = 3 := by
    simp [Finset.card_map, hL.1 c₁]
  have hcard₂ : ((L.fiber c₂).map σ.toEmbedding).card = 3 := by
    simp [Finset.card_map, hL.1 c₂]
  have hcard_union :
      ((L.fiber c₁).map σ.toEmbedding ∪ (L.fiber c₂).map σ.toEmbedding).card = 6 := by
    rw [Finset.card_union_of_disjoint hdisjσ, hcard₁, hcard₂]
  have hcard_canon : (canonicalVertexLabeling.fiber d).card = 3 :=
    canonicalVertexLabeling_isBremensaalDecomposition.1 d
  have hunion_sub :
      (L.fiber c₁).map σ.toEmbedding ∪ (L.fiber c₂).map σ.toEmbedding ⊆
        canonicalVertexLabeling.fiber d :=
    Finset.union_subset hsub₁ hsub₂
  have hle : 6 ≤ (canonicalVertexLabeling.fiber d).card := by
    calc
      6 = ((L.fiber c₁).map σ.toEmbedding ∪ (L.fiber c₂).map σ.toEmbedding).card := by
        rw [hcard_union]
      _ ≤ (canonicalVertexLabeling.fiber d).card := Finset.card_le_card hunion_sub
  linarith

theorem forwardChannelMap_bijective (L : VertexLabeling)
    (hL : L.IsBremensaalDecomposition) (σ : IcosahedronVertex ≃ IcosahedronVertex)
    (h : RespectsLabelFibers L σ) :
    Function.Bijective (forwardChannelMap L σ h) :=
  (Nat.bijective_iff_injective_and_card (forwardChannelMap L σ h)).mpr
    ⟨forwardChannelMap_injective L hL σ h, rfl⟩

/--
A-D: Kanal-Bijektion `τ = (c ↦ d)⁻¹`, sodass `L.label v = τ (canonicalLabelCode (σ v))`.
-/
noncomputable def constructChannelPermutation (L : VertexLabeling)
    (σ : IcosahedronVertex ≃ IcosahedronVertex) (hL : L.IsBremensaalDecomposition)
    (h : RespectsLabelFibers L σ) : EABCChannel ≃ EABCChannel :=
  (Equiv.ofBijective (forwardChannelMap L σ h)
    (forwardChannelMap_bijective L hL σ h)).symm

theorem constructChannelPermutation_intertwine (L : VertexLabeling)
    (σ : IcosahedronVertex ≃ IcosahedronVertex) (hL : L.IsBremensaalDecomposition)
    (h : RespectsLabelFibers L σ) (v : IcosahedronVertex) :
    L.label v = constructChannelPermutation L σ hL h (canonicalLabelCode (σ v)) := by
  rw [← Equiv.symm_apply_eq]
  dsimp [constructChannelPermutation, forwardChannelMap]
  exact (forwardChannelMap_spec L σ h (L.label v) (mem_fiber_label L v)).symm

/--
A-D: Zeuge `LabelIntertwiningGraphAuto` aus `(σ, τ)`-Daten.
-/
noncomputable def LabelIntertwiningGraphAuto.ofRespectsLabelFibers (L : VertexLabeling)
    (σ : IcosahedronVertex ≃ IcosahedronVertex) (hσ : IsIcosahedronGraphAutomorphism σ)
    (hL : L.IsBremensaalDecomposition) (hFib : RespectsLabelFibers L σ) :
    LabelIntertwiningGraphAuto canonicalIcosahedronCarrier L canonicalVertexLabeling where
  σ := σ
  τ := constructChannelPermutation L σ hL hFib
  preserves_adj := hσ
  intertwine := constructChannelPermutation_intertwine L σ hL hFib

noncomputable def LabelPreservingGraphMapToCanonical.ofRespectsLabelFibers (L : VertexLabeling)
    (φ : LabelPreservingGraphMap) (hG : φ.carrier = canonicalIcosahedronCarrier)
    (hL_eq : φ.labeling = L) (hL : L.IsBremensaalDecomposition)
    (hFib : RespectsLabelFibers L (φ.toGraphEquiv hG)) :
    LabelPreservingGraphMapToCanonical L :=
  LabelIntertwiningGraphAuto.ofRespectsLabelFibers L (φ.toGraphEquiv hG)
    (φ.isIcosahedronGraphAutomorph hG) hL hFib

theorem objectivity_hypothesis_implies_canonical_bridge_of_map (L : VertexLabeling)
    (φ : LabelPreservingGraphMap) (hG : φ.carrier = canonicalIcosahedronCarrier)
    (hL_eq : φ.labeling = L) (hL : L.IsBremensaalDecomposition)
    (hFib : RespectsLabelFibers L (φ.toGraphEquiv hG)) :
    Nonempty (LabelPreservingGraphMapToCanonical L) :=
  ⟨LabelPreservingGraphMapToCanonical.ofRespectsLabelFibers L φ hG hL_eq hL hFib⟩

theorem labelIntertwining_to_equivalence {L : VertexLabeling}
    (φ : LabelPreservingGraphMapToCanonical L) : IsEquivalentToCanonical L :=
  ⟨φ.σ, φ.τ, φ.preserves_adj, φ.intertwine⟩

theorem isEquivalentToCanonical_iff_labelIntertwining (L : VertexLabeling) :
    IsEquivalentToCanonical L ↔ Nonempty (LabelPreservingGraphMapToCanonical L) where
  mp h := by
    rcases h with ⟨σ, τ, hσ, hlab⟩
    exact ⟨⟨σ, τ, hσ, hlab⟩⟩
  mpr := fun ⟨φ⟩ => labelIntertwining_to_equivalence φ

/--
A-T: Explizite Objektivitäts-Brücke induziert kanonische Äquivalenz (E-032, definitorisch).
-/
theorem objectivity_map_implies_equivalence (L : VertexLabeling)
    (φ : LabelPreservingGraphMapToCanonical L) :
    IsEquivalentToCanonical L :=
  labelIntertwining_to_equivalence φ

/--
A-T: Objektivitäts-Brücke + kanonischer Kern → Musketiere auf `L` (E-031 ∘ E-032).
-/
theorem objectivity_bridge_implies_musketiere (L : VertexLabeling)
    (φ : LabelPreservingGraphMapToCanonical L)
    (h_canon : CanonicalMusketiereNeighborTripleHypothesis) :
    MusketiereNeighborTripleHypothesisFor canonicalIcosahedronCarrier L :=
  musketiere_hypothesis_transfer L (objectivity_map_implies_equivalence L φ) h_canon

/--
A-D: `LabelPreservingGraphMap` auf dem kanonischen Träger mit Ziel-Belegung `L`.
-/
def LabelPreservingGraphMapFor (L : VertexLabeling) : Type :=
  { φ : LabelPreservingGraphMap //
    φ.carrier = canonicalIcosahedronCarrier ∧ φ.labeling = L }

lemma LabelPreservingGraphMapFor.carrier_eq (φ : LabelPreservingGraphMapFor L) :
    φ.val.carrier = canonicalIcosahedronCarrier := φ.property.1

lemma LabelPreservingGraphMapFor.labeling_eq (φ : LabelPreservingGraphMapFor L) :
    φ.val.labeling = L := φ.property.2

def RespectsLabelFibersOf (L : VertexLabeling) (φ : LabelPreservingGraphMapFor L) : Prop :=
  RespectsLabelFibers L (φ.val.toGraphEquiv φ.property.1)

/--
A-D (E-032, stark): Jeder label-erhaltende Graph-Automorphismus auf `(canonical, L)`
respektiert Bremensaal-Fasern im Sinne von `RespectsLabelFibers`.

Nicht aus label-Erhaltung allein ableitbar; explizite Annahme fuer die Bruecke.
-/
def RespectsLabelFibersUnderAutos (L : VertexLabeling) : Prop :=
  ∀ (φ : LabelPreservingGraphMapFor L), RespectsLabelFibersOf L φ

/--
A-D (E-032): Es existiert ein label-erhaltendes `φ` mit Faser-Symmetrie.
Schwaecher als `RespectsLabelFibersUnderAutos`, ausreichend fuer die Bruecke.
-/
def ExistsRespectingLabelFiberMap (L : VertexLabeling) : Prop :=
  ∃ (φ : LabelPreservingGraphMapFor L), RespectsLabelFibersOf L φ

/--
A-D (E-032, stark): Kanonische Bruecke — Faser-respektierendes `φ` oder direkte
`IsEquivalentToCanonical`-Aequivalenz. Alias: `StrongMusketiereObjective`.
-/
def CanonicalBridgeHypothesis (L : VertexLabeling) : Prop :=
  ExistsRespectingLabelFiberMap L ∨ IsEquivalentToCanonical L

abbrev StrongMusketiereObjective (L : VertexLabeling) := CanonicalBridgeHypothesis L

theorem existsRespectingLabelFiberMap_implies_canonical_bridge_hypothesis (L : VertexLabeling)
    (h : ExistsRespectingLabelFiberMap L) : CanonicalBridgeHypothesis L :=
  Or.inl h

theorem isEquivalentToCanonical_implies_canonical_bridge_hypothesis (L : VertexLabeling)
    (h : IsEquivalentToCanonical L) : CanonicalBridgeHypothesis L :=
  Or.inr h

theorem respectsLabelFibersUnderAutos_implies_existsRespecting (L : VertexLabeling)
    (h : RespectsLabelFibersUnderAutos L) (φ : LabelPreservingGraphMapFor L) :
    RespectsLabelFibersOf L φ :=
  h φ

theorem respectsLabelFibersUnderAutos_implies_existsRespectingLabelFiberMap (L : VertexLabeling)
    (hφ : Nonempty (LabelPreservingGraphMapFor L)) (h : RespectsLabelFibersUnderAutos L) :
    ExistsRespectingLabelFiberMap L :=
  ⟨hφ.some, h hφ.some⟩

/--
E-032: Starke Objektivitaets-Bruecke induziert `LabelPreservingGraphMapToCanonical`.

Beweis via `objectivity_hypothesis_implies_canonical_bridge_of_map` (Faser-Fall) bzw.
`isEquivalentToCanonical_iff_labelIntertwining` (Aequivalenz-Fall). Die schwache
`MusketiereNeighborTripleObjective` reicht hier nicht — sie ist tautologisch.
-/
theorem objectivity_hypothesis_implies_canonical_bridge (L : VertexLabeling)
    (hL : L.IsBremensaalDecomposition) (h : CanonicalBridgeHypothesis L) :
    Nonempty (LabelPreservingGraphMapToCanonical L) := by
  rcases h with h | h
  · rcases h with ⟨φ, hFib⟩
    exact objectivity_hypothesis_implies_canonical_bridge_of_map L φ.val
      φ.property.1 φ.property.2 hL hFib
  · exact (isEquivalentToCanonical_iff_labelIntertwining L).mp h

theorem respectsLabelFibersUnderAutos_implies_canonical_bridge (L : VertexLabeling)
    (hL : L.IsBremensaalDecomposition) (hφ : Nonempty (LabelPreservingGraphMapFor L))
    (h : RespectsLabelFibersUnderAutos L) :
    Nonempty (LabelPreservingGraphMapToCanonical L) :=
  objectivity_hypothesis_implies_canonical_bridge L hL
    (existsRespectingLabelFiberMap_implies_canonical_bridge_hypothesis L
      (respectsLabelFibersUnderAutos_implies_existsRespectingLabelFiberMap L hφ h))

/--
E-032 Zielkorridor: `E-026`-Hypothese auf dem kanonischen Traeger via starker Bruecke.
-/
theorem musketiere_hypothesis_canonical_orbit (L : VertexLabeling)
    (hL : L.IsBremensaalDecomposition)
    (_h_triple : ∀ host : EABCChannel,
      L.HasMusketiereNeighborTriple canonicalIcosahedronCarrier host)
    (h_bridge : CanonicalBridgeHypothesis L)
    (h_canon : CanonicalMusketiereNeighborTripleHypothesis) :
    MusketiereNeighborTripleHypothesisFor canonicalIcosahedronCarrier L := by
  have h_witness := objectivity_hypothesis_implies_canonical_bridge L hL h_bridge
  exact objectivity_bridge_implies_musketiere L h_witness.some h_canon

end KeplerHurwitz
