import KeplerHurwitz.PrimvierlingSymmetry

namespace KeplerHurwitz

open EABCChannel

/-!
## E-032-Brücke: Dumas-Host-Komplement ↔ Label-Intertwining

Verknüpft die arithmetische Host-Bijektion `hostComponentEquiv` (E-034/E-047)
mit der Kanal-Gauge `τ` aus `LabelIntertwiningGraphAuto` (E-032).

Schicht 2 (`PrimvierlingSymmetry.lean`) bleibt unangetastet; diese Datei ist die
explizite Brückenschicht zwischen Dumas/Host-Komplement und Musketiere-Label-Symmetrie.
-/

/--
A-D: Kanal-Gauge `τ` induziert via `hostComponentEquiv` eine Komponenten-Gauge
auf `P(v) = primvierlingFinset v`.
-/
noncomputable def componentGauge (v : Primvierling) (hv : primvierlingDistinct v)
    (τ : EABCChannel ≃ EABCChannel) :
    {x // x ∈ primvierlingFinset v} ≃ {x // x ∈ primvierlingFinset v} :=
  (hostComponentEquiv v hv).symm.trans (τ.trans (hostComponentEquiv v hv))

/--
A-D: Defensive Schnittstelle — Host-Zuweisung konjugiert Kanal-Relabeling zu Komponenten-Relabeling.
-/
def HostComponentIntertwinesChannelGauge (v : Primvierling) (hv : primvierlingDistinct v)
    (τ : EABCChannel ≃ EABCChannel) : Prop :=
  ∀ host : EABCChannel,
    hostComponent (τ host) v =
      (componentGauge v hv τ
        ⟨hostComponent host v, (hostComponentEquiv v hv host).property⟩).val

/--
A-T (E-032): `hostComponent` konjugiert die Kanal-Bijektion `τ` zu `componentGauge`.
-/
theorem hostComponent_intertwines_channelEquiv (v : Primvierling) (hv : primvierlingDistinct v)
    (τ : EABCChannel ≃ EABCChannel) (host : EABCChannel) :
    hostComponent (τ host) v =
      (componentGauge v hv τ
        ⟨hostComponent host v, (hostComponentEquiv v hv host).property⟩).val := by
  simp [componentGauge, hostComponentEquiv]

theorem hostComponentIntertwinesChannelGauge (v : Primvierling) (hv : primvierlingDistinct v)
    (τ : EABCChannel ≃ EABCChannel) :
    HostComponentIntertwinesChannelGauge v hv τ :=
  hostComponent_intertwines_channelEquiv v hv τ

/--
A-T (E-032): `hostComponentEquiv` konjugiert Kanal-Gauge `τ` zu `componentGauge`.
-/
theorem hostComponentEquiv_conjugates_channelEquiv (v : Primvierling) (hv : primvierlingDistinct v)
    (τ : EABCChannel ≃ EABCChannel) (host : EABCChannel) :
    hostComponentEquiv v hv (τ host) = componentGauge v hv τ (hostComponentEquiv v hv host) := by
  simp [componentGauge, hostComponentEquiv]

/--
A-T (E-032): Domänen-Kardinalität von `hostComponentEquiv` — vier Kanaele, vier Komponenten.
-/
theorem hostComponentEquiv_domain_card (v : Primvierling) (hv : primvierlingDistinct v) :
    Fintype.card EABCChannel = Fintype.card {x // x ∈ primvierlingFinset v} := by
  rw [← Fintype.card_congr (hostComponentEquiv v hv)]

/--
A-T (E-032): `LabelIntertwiningGraphAuto.τ` wirkt auf `hostComponent` wie `componentGauge`.
-/
theorem labelIntertwining_hostComponent_intertwines (v : Primvierling) (hv : primvierlingDistinct v)
    {G : IcosahedronCarrier} {source target : VertexLabeling}
    (φ : LabelIntertwiningGraphAuto G source target) (host : EABCChannel) :
    hostComponent (φ.τ host) v =
      (componentGauge v hv φ.τ
        ⟨hostComponent host v, (hostComponentEquiv v hv host).property⟩).val :=
  hostComponent_intertwines_channelEquiv v hv φ.τ host

theorem labelIntertwining_hostComponentEquiv_conjugates (v : Primvierling)
    (hv : primvierlingDistinct v) {G : IcosahedronCarrier} {source target : VertexLabeling}
    (φ : LabelIntertwiningGraphAuto G source target) (host : EABCChannel) :
    hostComponentEquiv v hv (φ.τ host) =
      componentGauge v hv φ.τ (hostComponentEquiv v hv host) :=
  hostComponentEquiv_conjugates_channelEquiv v hv φ.τ host

/-!
### Parallele Struktur: `otherChannels` (Label) und `hostTriple` (arithmetisch)

Beide sind 3-Mengen relativ zum Host; unter Kanal-Gauge `τ` transformieren sie parallel.
-/

/--
A-T (E-032): Kanal-Gauge bildet `otherChannels` equivariant ab.
-/
theorem otherChannels_channelEquiv (τ : EABCChannel ≃ EABCChannel) (host : EABCChannel) :
    otherChannels (τ host) = (otherChannels host).map τ.toEmbedding := by
  ext c
  simp only [otherChannels, Finset.mem_map, Finset.mem_sdiff, Finset.mem_singleton,
    Finset.mem_univ, true_and]
  constructor
  · intro hc
    refine ⟨τ.symm c, ?_, τ.apply_symm_apply c⟩
    intro heq
    apply hc
    rw [← heq, Equiv.apply_symm_apply]
  · rintro ⟨c', hc', rfl⟩
    intro heq
    apply hc'
    exact τ.injective heq

private theorem primvierlingFinset_shiftCEAB (v : Primvierling) :
    primvierlingFinset (shiftCEAB v) = primvierlingFinset v := by
  rcases v with ⟨a, b, c, e⟩
  ext x
  simp [primvierlingFinset, shiftCEAB, Finset.mem_insert, Finset.mem_singleton]
  tauto

/--
A-T (E-032): CEAB-Wirkung auf Primvierling und `shiftHostChannel` konjugieren `hostComponent`.

Verbindet die arithmetische Orbit-Symmetrie `shiftCEAB` mit der Kanal-Permutation
`shiftHostChannel` aus `PrimvierlingSymmetry.lean`.
-/
theorem hostComponent_shiftCEAB (host : EABCChannel) (v : Primvierling)
    (_hv : primvierlingDistinct v) :
    hostComponent host (shiftCEAB v) = hostComponent (shiftHostChannel host) v := by
  have hfin : primvierlingFinset (shiftCEAB v) = primvierlingFinset v :=
    primvierlingFinset_shiftCEAB v
  have htriple := hostTriple_shiftCEAB host v
  have hx : hostComponent host (shiftCEAB v) ∈ primvierlingFinset v := by
    rw [← hfin]
    rcases v with ⟨a, b, c, e⟩
    fin_cases host <;> simp [hostComponent, primvierlingFinset, shiftCEAB, Finset.mem_insert]
  have hmiss₂ : hostComponent host (shiftCEAB v) ∉ hostTriple (shiftHostChannel host) v := by
    have hmiss₁ : hostComponent host (shiftCEAB v) ∉ hostTriple host (shiftCEAB v) := by
      simp [mem_hostTriple_iff_ne_hostComponent]
    rwa [← htriple]
  exact (not_mem_hostTriple_iff_eq_hostComponent hx).mp hmiss₂

/--
A-D: `shiftHostChannel` ist die kanonische Kanal-Permutation zur CEAB-Orbit-Wirkung.
-/
def shiftHostChannelEquiv : EABCChannel ≃ EABCChannel where
  toFun := shiftHostChannel
  invFun := shiftHostChannel
  left_inv h := by fin_cases h <;> rfl
  right_inv h := by fin_cases h <;> rfl

theorem hostComponent_shiftHostChannelEquiv (v : Primvierling) (hv : primvierlingDistinct v)
    (host : EABCChannel) :
    hostComponent host (shiftCEAB v) =
      (componentGauge v hv shiftHostChannelEquiv
        ⟨hostComponent host v, (hostComponentEquiv v hv host).property⟩).val := by
  simp [hostComponent_shiftCEAB host v hv, componentGauge, shiftHostChannelEquiv,
    hostComponentEquiv, shiftHostChannel]

/--
A-D: Defensive Gesamt-Schnittstelle — jede Kanal-Gauge respektiert die Host-Komponenten-Bijektion.
-/
def HostComponentRespectsLabelBridge (v : Primvierling) (hv : primvierlingDistinct v) : Prop :=
  ∀ (τ : EABCChannel ≃ EABCChannel), HostComponentIntertwinesChannelGauge v hv τ

theorem hostComponentRespectsLabelBridge (v : Primvierling) (hv : primvierlingDistinct v) :
    HostComponentRespectsLabelBridge v hv :=
  fun τ => hostComponentIntertwinesChannelGauge v hv τ

/--
A-T (E-032): `constructChannelPermutation` aus faser-respektierendem Graph-Automorphismus
liefert dieselbe Host-Intertwining-Schnittstelle wie explizite Kanal-Gauge.
-/
theorem constructChannelPermutation_hostComponent_intertwines (v : Primvierling)
    (hv : primvierlingDistinct v) (L : VertexLabeling) (σ : IcosahedronVertex ≃ IcosahedronVertex)
    (hL : L.IsBremensaalDecomposition) (hFib : RespectsLabelFibers L σ) (host : EABCChannel) :
    hostComponent (constructChannelPermutation L σ hL hFib host) v =
      (componentGauge v hv (constructChannelPermutation L σ hL hFib)
        ⟨hostComponent host v, (hostComponentEquiv v hv host).property⟩).val :=
  hostComponent_intertwines_channelEquiv v hv (constructChannelPermutation L σ hL hFib) host

end KeplerHurwitz
