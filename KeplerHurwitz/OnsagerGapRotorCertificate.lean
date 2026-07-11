import KeplerHurwitz.DumasIntertwiningBridge
import KeplerHurwitz.PrimvierlingSymmetry

namespace KeplerHurwitz

open EABCChannel

/-!
## Onsager Gap-Rotor certificate (E-089, Phase 1)

Formalisiert die Dumas-Primquadruplet-Kombinatorik hinter den Onsager-Diagnostiken
(Schicht B, `onsager_vortex_diagnostics.py`): Gap-Law, Defect-Core-Auslassung, Host-Zyklus und
diskrete Windungszahlen — ohne physikalische Onsager-Identifikation.

Governance: interpretative Resonanzsprache (ORQ-089); keine Superfluid- oder Φ₀-Behauptung.
Dokumentation: `docs/theory/onsager_quantization_bridge.md`.
-/

/-!
### Gap-Law und Defect-Core
-/

/--
A-D (E-089): Gap-Law — sortierte Abstandspaare aller Host-Dreier entsprechen
`hostTripleGapPair` des kanonischen Primquadruplets `(p,p+2,p+6,p+8)`.
-/
def gapLawOk (q : PrimeQuadruplet) (_hp : q.p > 3) : Prop :=
  ∀ host : EABCChannel,
    sortedGapPair (hostTriple host q.toPrimvierling) = hostTripleGapPair host q.p

/--
A-T (E-089): Kanonisches Primquadruplet erfuellt die Gap-Law.

Bundelt `PrimeQuadruplet.hostTriple_gap_pair` fuer alle vier Traegerkanaele.
-/
theorem PrimeQuadruplet.gap_law_ok (q : PrimeQuadruplet) (hp : q.p > 3) :
    gapLawOk q hp :=
  fun host => hostTriple_gap_pair host q hp

/--
A-T (E-089): Defect-Core-Auslassung — die Host-Komponente liegt nie im eigenen Musketiere-Dreier.

Entspricht `defect_musketeer_overlap = 0` in den Python-Diagnostiken.
-/
theorem defect_core_absent (host : EABCChannel) (v : Primvierling) :
    hostComponent host v ∉ hostTriple host v := by
  rcases v with ⟨a, b, c, e⟩
  fin_cases host <;> simp [hostTriple, Finset.mem_sdiff, Finset.mem_singleton, hostComponent]

/--
A-T (E-089): Gap-Rotor-Zertifikat — Dumas-Lemma, Gap-Law und Defect-Core fuer ein Primquadruplet.
-/
structure GapRotorCertificate (q : PrimeQuadruplet) (hp : q.p > 3) : Prop where
  /-- Dumas *Un pour tous, tous pour un*. -/
  dumas : Dumas_one_for_all_all_for_one q.toPrimvierling (PrimeQuadruplet.distinct q hp)
  /-- Alle vier Gap-Paare stimmen mit der kanonischen Primquadruplet-Gesetzmäßigkeit ueberein. -/
  gapLaw : gapLawOk q hp
  /-- Jeder Host traegt seinen Defect-Core ausserhalb des rotierenden Musketiere-Dreiers. -/
  defectCoreAbsent : ∀ host, hostComponent host q.toPrimvierling ∉ hostTriple host q.toPrimvierling

/--
A-T (E-089): Jedes kanonische Primquadruplet mit `p > 3` traegt ein Gap-Rotor-Zertifikat.
-/
theorem PrimeQuadruplet.gap_rotor_certificate (q : PrimeQuadruplet) (hp : q.p > 3) :
    GapRotorCertificate q hp where
  dumas := dumasLemma q.toPrimvierling (PrimeQuadruplet.distinct q hp)
  gapLaw := gap_law_ok q hp
  defectCoreAbsent := fun host => defect_core_absent host q.toPrimvierling

/--
A-T (E-089): Ein Gap-Rotor-Durchlauf ueber alle vier Hosts deckt genau die vier Gap-Paare ab.

Entspricht `ROTOR_GAP_CYCLE` / `hostTripleGapPair_permutation` in Python.
-/
private theorem hostTripleGapPair_param_invariant (host : EABCChannel) (p : Nat) :
    hostTripleGapPair host p = hostTripleGapPair host 0 := by
  cases host <;> rfl

theorem PrimeQuadruplet.gap_rotor_cycle_covers_all_pairs (q : PrimeQuadruplet) (hp : q.p > 3) :
    (Finset.univ : Finset EABCChannel).image (fun host =>
      sortedGapPair (hostTriple host q.toPrimvierling)) =
      {(2, 4), (4, 2), (6, 2), (2, 6)} := by
  have hgap (host : EABCChannel) :
      sortedGapPair (hostTriple host q.toPrimvierling) = hostTripleGapPair host q.p :=
    hostTriple_gap_pair host q hp
  have hfun :
      (fun host => sortedGapPair (hostTriple host q.toPrimvierling)) =
      (fun host => hostTripleGapPair host 0) := by
    funext host
    exact (hgap host).trans (hostTripleGapPair_param_invariant host q.p)
  rw [hfun, hostTripleGapPair_permutation]

/-!
### Host-Zyklus E → A → B → C (Gap-Rotor)
-/

/--
A-D (E-089): Diskrete Phasenlabels auf dem Kanal-Kreis (Python `CHANNEL_PHASE`).
-/
def channelPhaseIndex : EABCChannel → Fin 4
  | EABCChannel.E => 0
  | EABCChannel.A => 1
  | EABCChannel.B => 2
  | EABCChannel.C => 3

/--
A-D (E-089): Kanonischer Gap-Rotor-Host-Zyklus `E → A → B → C → E`.
-/
def nextGapRotorHost : EABCChannel → EABCChannel
  | EABCChannel.E => EABCChannel.A
  | EABCChannel.A => EABCChannel.B
  | EABCChannel.B => EABCChannel.C
  | EABCChannel.C => EABCChannel.E

/--
A-D (E-089): Eine volle Gap-Rotor-Umdrehung als Host-Liste.
-/
def gapRotorHostCycle : List EABCChannel :=
  [EABCChannel.E, EABCChannel.A, EABCChannel.B, EABCChannel.C]

/--
A-D (E-089): `n`-fache Iteration des Gap-Rotor-Schritts.
-/
def iterNextGapRotorHost : Nat → EABCChannel → EABCChannel
  | 0, h => h
  | n + 1, h => iterNextGapRotorHost n (nextGapRotorHost h)

theorem channelPhaseIndex_next (h : EABCChannel) :
    channelPhaseIndex (nextGapRotorHost h) = channelPhaseIndex h + 1 := by
  fin_cases h <;> rfl

theorem nextGapRotorHost_pow_four (h : EABCChannel) :
    iterNextGapRotorHost 4 h = h := by
  fin_cases h <;> rfl

theorem gapRotorHostCycle_length :
    gapRotorHostCycle.length = 4 := by
  decide

/--
A-T (E-089): `shiftHostChannel` ist ein 4-Zyklus (CEAB-Kanal-Gauge).

Unabhaengig vom Gap-Rotor-Anzeigezyklus `E→A→B→C`; verknuepft ORQ-089 mit E-032.
-/
theorem shiftHostChannel_pow_four (h : EABCChannel) :
    shiftHostChannel (shiftHostChannel (shiftHostChannel (shiftHostChannel h))) = h := by
  fin_cases h <;> rfl

theorem shiftHostChannelEquiv_order_four (h : EABCChannel) :
    (shiftHostChannelEquiv ^ 4) h = h := by
  fin_cases h <;> rfl

/-!
### Holonomie und Windung (diskret, mod 4)
-/

/--
A-D (E-089): Phasenfortschritt entlang einer Gap-Rotor-Kante (mod 4).
-/
def channelPhaseDelta (prev next : EABCChannel) : Nat :=
  ((channelPhaseIndex next).val + 4 - (channelPhaseIndex prev).val) % 4

theorem channelPhaseDelta_gapRotorStep (h : EABCChannel) :
    channelPhaseDelta h (nextGapRotorHost h) = 1 := by
  fin_cases h <;> decide

/--
A-D (E-089): Pop-Schwelle — keine Windung unter vier Schritten.

Entspricht `partial_rotor_winding` in Python.
-/
def partialRotorWinding (stepCount : Nat) : Nat :=
  stepCount / 4

theorem partialRotorWinding_zero_below_four {k : Nat} (hk : k < 4) :
    partialRotorWinding k = 0 := by
  simp [partialRotorWinding, Nat.div_eq_zero_iff]
  omega

theorem partialRotorWinding_one_at_four :
    partialRotorWinding 4 = 1 := rfl

/--
A-D (E-089): Kombinatorische Windung — volle 4-Schritt-Zyklen; Fest-Host-Pfad liefert 0.
-/
def combinatorialWinding (stepCount : Nat) (singleHost : Bool) : Nat :=
  if singleHost then 0 else partialRotorWinding stepCount

theorem trivial_host_winding_zero (stepCount : Nat) :
    combinatorialWinding stepCount true = 0 := by
  simp [combinatorialWinding]

/--
A-D (E-089): Strukturierte Windung unter gueltigem Gap-Rotor-Zertifikat.

Unter `GapRotorCertificate` ist die Windungszahl gleich der Anzahl voller Zyklen.
-/
def structuredWinding {q : PrimeQuadruplet} {hp : q.p > 3} (cycles : Nat)
    (_cert : GapRotorCertificate q hp) : Nat :=
  cycles

/--
A-T (E-089): Ein voller Gap-Rotor-Zyklus liefert strukturierte Windung `n = 1`.
-/
theorem structured_winding_one {q : PrimeQuadruplet} {hp : q.p > 3}
    (cert : GapRotorCertificate q hp) :
    structuredWinding 1 cert = 1 := rfl

theorem structured_winding_eq_combinatorial_one_cycle {q : PrimeQuadruplet} {hp : q.p > 3}
    (cert : GapRotorCertificate q hp) :
    structuredWinding 1 cert = combinatorialWinding 4 false := by
  simp [structuredWinding, combinatorialWinding, partialRotorWinding]

/--
A-T (E-089): Holonomie-Phasensumme entlang eines Gap-Rotor-Vierzyklus schliesst mod 4.

Entspricht `holonomy_phase_total = 0` / `phase_closure_ok = true` fuer den kanonischen Loop.
-/
def gapRotorHolonomyPhaseSum : Nat :=
  channelPhaseDelta EABCChannel.E EABCChannel.A +
  channelPhaseDelta EABCChannel.A EABCChannel.B +
  channelPhaseDelta EABCChannel.B EABCChannel.C +
  channelPhaseDelta EABCChannel.C EABCChannel.E

theorem holonomy_closure_one_cycle :
    gapRotorHolonomyPhaseSum % 4 = 0 := by
  decide

/--
A-T (E-089): Gap-Rotor besucht alle vier Defect-Cores — vier verschiedene Host-Komponenten.

Entspricht `loop_encircles_defect_structure` / `encircles_defect = true` fuer kanonische Quadruplet.
-/
theorem gap_rotor_encircles_all_defect_cores (q : PrimeQuadruplet) (hp : q.p > 3) :
    (gapRotorHostCycle.map (hostComponent · q.toPrimvierling)).Nodup :=
  List.Nodup.map (hostComponent_injective q.toPrimvierling (PrimeQuadruplet.distinct q hp))
    (by decide : gapRotorHostCycle.Nodup)

end KeplerHurwitz
