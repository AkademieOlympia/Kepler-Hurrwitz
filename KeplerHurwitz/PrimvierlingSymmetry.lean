import Mathlib
import KeplerHurwitz.Representation.DreiMusketiere
import KeplerHurwitz.Representation.EABCChronology

namespace KeplerHurwitz

open EABCChannel

/--
Primvierling im EABC-Sinn als 4-Tupel `(a,b,c,e)`.
-/
abbrev Primvierling := Nat × Nat × Nat × Nat

/--
Zulaessige Grundsymmetrie `abce -> ceab`.
-/
def shiftCEAB : Primvierling → Primvierling
  | (a, b, c, e) => (c, e, a, b)

theorem shiftCEAB_involutive (v : Primvierling) :
    shiftCEAB (shiftCEAB v) = v := by
  rcases v with ⟨a, b, c, e⟩
  rfl

/--
Die CEAB-Bahn besteht aus Startpunkt und verschobenem Zustand.
-/
def orbitCEAB (v : Primvierling) : Finset Primvierling := {v, shiftCEAB v}

/--
Geometrische Diagonalabstaende als Integer-Observable.
Die Integer-Form vermeidet Trunkierung wie bei `Nat`-Subtraktion.
-/
def pairGapsInt : Primvierling → Int
  | (a, b, c, e) =>
      ((a : Int) - (c : Int)) ^ (2 : Nat) + ((b : Int) - (e : Int)) ^ (2 : Nat)

/--
Quaternionische Normformel in komponentenweiser Darstellung.
-/
def quatNorm : Primvierling → Nat
  | (a, b, c, e) => a ^ (2 : Nat) + b ^ (2 : Nat) + c ^ (2 : Nat) + e ^ (2 : Nat)

def firstComponent : Primvierling → Nat
  | (a, _, _, _) => a

theorem pairGapsInt_invariant_under_shiftCEAB (v : Primvierling) :
    pairGapsInt (shiftCEAB v) = pairGapsInt v := by
  rcases v with ⟨a, b, c, e⟩
  simp [pairGapsInt, shiftCEAB]
  ring

theorem quatNorm_invariant_under_shiftCEAB (v : Primvierling) :
    quatNorm (shiftCEAB v) = quatNorm v := by
  rcases v with ⟨a, b, c, e⟩
  simp [quatNorm, shiftCEAB, add_assoc, add_left_comm, add_comm]

/--
Konkreter Zeuge: Die erste Komponente ist im Allgemeinen nicht invariant.
-/
example : firstComponent (shiftCEAB (11, 13, 17, 19)) ≠ firstComponent (11, 13, 17, 19) := by
  decide

/-!
## Primvierling-Komplementarität und Host-Auslassungs-Symmetrie (E-033)

Bindeglied zwischen arithmetischer Primvierling-Struktur `(a,b,c,e)` und
der Bremensaal-Dreier-Logik der Musketiere-Hypothese: Jeder Trägerkanal
projiziert auf das Komplement seiner Host-Komponente in der invarianten 4-Menge.
-/

/--
A-D: Kanal-Komponente eines Primvierlings (`A=a`, `B=b`, `C=c`, `E=e`).
-/
def hostComponent (host : EABCChannel) : Primvierling → Nat
  | (a, b, c, e) =>
    match host with
    | EABCChannel.E => e
    | EABCChannel.A => a
    | EABCChannel.B => b
    | EABCChannel.C => c

/--
A-D: Die zugrundeliegende 4-Menge eines Primvierlings.
-/
def primvierlingFinset (v : Primvierling) : Finset Nat :=
  let (a, b, c, e) := v
  {a, b, c, e}

/--
A-D: Paarweise Verschiedenheit der vier Primvierling-Komponenten.
-/
def primvierlingDistinct (v : Primvierling) : Prop :=
  let (a, b, c, e) := v
  a ≠ b ∧ a ≠ c ∧ a ≠ e ∧ b ≠ c ∧ b ≠ e ∧ c ≠ e

/--
A-D: Musketiere-Dreier — Komplement der Host-Komponente in der 4-Menge.
Entspricht `otherChannels host` auf Label-Ebene in `DreiMusketiere.lean`.

**Holographische Auslassung:** Das Tripel ist nicht bloß „drei von vier“, sondern die
kanonische Komplement-Codierung `P(v) \ {hostComponent host v}`. Unter Distinktheit
traegt die Auslassung dieselbe Information wie die Host-Zuweisung
(`dumas_gap_encodes_host`, Alias `holographic_omission_gap_encodes_host`).
Prägnant: *Die Lücke im Tripel ist kein Verlust, sondern die Codierung des Hosts.*
-/
def hostTriple (host : EABCChannel) (v : Primvierling) : Finset Nat :=
  primvierlingFinset v \ {hostComponent host v}

/--
A-T (E-033, Satz 1): Host-Dreier plus ausgelassene Komponente stellen die 4-Menge her.
-/
theorem hostTriple_union_host_eq_four_set (host : EABCChannel) (v : Primvierling) :
    hostTriple host v ∪ {hostComponent host v} = primvierlingFinset v := by
  ext x
  simp only [hostTriple, primvierlingFinset, hostComponent, Finset.mem_union,
    Finset.mem_sdiff, Finset.mem_singleton]
  rcases v with ⟨a, b, c, e⟩
  fin_cases host <;> simp [Finset.mem_insert] <;> tauto

private lemma hostComponent_mem_primvierlingFinset (host : EABCChannel) (v : Primvierling) :
    hostComponent host v ∈ primvierlingFinset v := by
  rcases v with ⟨a, b, c, e⟩
  fin_cases host <;> simp [hostComponent, primvierlingFinset, Finset.mem_insert]

private lemma mem_hostTriple_iff {host : EABCChannel} {v : Primvierling} {x : Nat} :
    x ∈ hostTriple host v ↔ x ∈ primvierlingFinset v ∧ x ≠ hostComponent host v := by
  simp [hostTriple, Finset.mem_sdiff, Finset.mem_singleton, and_comm]

private lemma hostComponent_not_mem_hostTriple (host : EABCChannel) (v : Primvierling) :
    hostComponent host v ∉ hostTriple host v := by
  rw [mem_hostTriple_iff]
  exact fun ⟨_, heq⟩ => heq rfl

private lemma hostTriple_subset (host : EABCChannel) (v : Primvierling) :
    hostTriple host v ⊆ primvierlingFinset v :=
  Finset.sdiff_subset

theorem hostComponent_injective_of_distinct (v : Primvierling) (hv : primvierlingDistinct v)
    {h₁ h₂ : EABCChannel} (hne : h₁ ≠ h₂) :
    hostComponent h₁ v ≠ hostComponent h₂ v := by
  rcases v with ⟨a, b, c, e⟩
  fin_cases h₁ <;> fin_cases h₂ <;>
    first | contradiction |
    (simp only [hostComponent, primvierlingDistinct] at hv ⊢; tauto)

/--
A-T (E-033, Satz 1): Bei paarweise verschiedenen Komponenten sind Host-Dreier
fuer verschiedene Trägerkanaele paarweise verschieden.
-/
theorem hostTriple_ne_of_ne_host {host₁ host₂ : EABCChannel} (v : Primvierling)
    (hne : host₁ ≠ host₂) (hv : primvierlingDistinct v) :
    hostTriple host₁ v ≠ hostTriple host₂ v := by
  intro heq
  have hinj := hostComponent_injective_of_distinct v hv hne
  have hmiss₁ := hostComponent_not_mem_hostTriple host₁ v
  have hmiss₂ : hostComponent host₁ v ∉ hostTriple host₂ v := by
    rw [← heq]
    exact hmiss₁
  have hmem : hostComponent host₁ v ∈ primvierlingFinset v :=
    hostComponent_mem_primvierlingFinset host₁ v
  have hmem' : hostComponent host₁ v ∈ hostTriple host₂ v :=
    (mem_hostTriple_iff (host := host₂) (v := v)).mpr ⟨hmem, hinj⟩
  exact hmiss₂ hmem'

theorem hostTriples_pairwise_ne (v : Primvierling) (hv : primvierlingDistinct v)
    {host₁ host₂ : EABCChannel} (hne : host₁ ≠ host₂) :
    hostTriple host₁ v ≠ hostTriple host₂ v :=
  hostTriple_ne_of_ne_host v hne hv

/-!
## Host-Komponente als Kanal-Bijektion und Dreier-Multiplizität (E-034)

Bindeglied zu `RespectsLabelFibers` / `LabelIntertwiningGraphAuto` (E-032):
`hostComponent` ist bei paarweise verschiedenen Komponenten eine Bijektion
`EABCChannel ≃ primvierlingFinset v`; jede 4-Menge-Komponente liegt in genau
drei Host-Dreiern und wird von genau einem Host ausgelassen.
-/

theorem hostComponent_injective (v : Primvierling) (hv : primvierlingDistinct v) :
    Function.Injective (hostComponent · v) := by
  intro h₁ h₂ heq
  by_contra hne
  exact hostComponent_injective_of_distinct v hv hne heq

theorem exists_unique_hostComponent (v : Primvierling) (hv : primvierlingDistinct v) (x : Nat)
    (hx : x ∈ primvierlingFinset v) :
    ∃! h : EABCChannel, hostComponent h v = x := by
  rcases v with ⟨a, b, c, e⟩
  simp only [primvierlingFinset, Finset.mem_insert, Finset.mem_singleton] at hx
  rcases hx with rfl | rfl | rfl | rfl
  · refine ⟨EABCChannel.A, by simp [hostComponent], ?_⟩
    intro h hh
    fin_cases h <;> simp [hostComponent] at hh <;> first | rfl | (simp_all [primvierlingDistinct])
  · refine ⟨EABCChannel.B, by simp [hostComponent], ?_⟩
    intro h hh
    fin_cases h <;> simp [hostComponent] at hh <;> first | rfl | (simp_all [primvierlingDistinct])
  · refine ⟨EABCChannel.C, by simp [hostComponent], ?_⟩
    intro h hh
    fin_cases h <;> simp [hostComponent] at hh <;> first | rfl | (simp_all [primvierlingDistinct])
  · refine ⟨EABCChannel.E, by simp [hostComponent], ?_⟩
    intro h hh
    fin_cases h <;> simp [hostComponent] at hh <;> first | rfl | (simp_all [primvierlingDistinct])

theorem hostComponent_surjective_of_distinct (v : Primvierling) (hv : primvierlingDistinct v)
    {x : Nat} (hx : x ∈ primvierlingFinset v) :
    ∃ h : EABCChannel, hostComponent h v = x :=
  (exists_unique_hostComponent v hv x hx).exists

private theorem hostComponent_surjective_subtype (v : Primvierling) (hv : primvierlingDistinct v) :
    Function.Surjective
      (fun h : EABCChannel =>
        (⟨hostComponent h v, hostComponent_mem_primvierlingFinset h v⟩ :
          {x // x ∈ primvierlingFinset v})) := by
  intro y
  obtain ⟨h, hh, _⟩ := exists_unique_hostComponent v hv y.val y.property
  exact ⟨h, Subtype.ext hh⟩

private theorem hostComponent_injective_subtype (v : Primvierling) (hv : primvierlingDistinct v) :
    Function.Injective
      (fun h : EABCChannel =>
        (⟨hostComponent h v, hostComponent_mem_primvierlingFinset h v⟩ :
          {x // x ∈ primvierlingFinset v})) := by
  intro h₁ h₂ heq
  exact hostComponent_injective v hv (congrArg Subtype.val heq)

/--
A-T (E-034): Kanal-Host-Komponente ist eine Bijektion auf die Primvierling-4-Menge.
Bruecke zu E-032: dieselbe 4↔4-Struktur wie Faser-Bijektionen auf `EABCChannel`.
-/
noncomputable def hostComponentEquiv (v : Primvierling) (hv : primvierlingDistinct v) :
    EABCChannel ≃ {x // x ∈ primvierlingFinset v} :=
  Equiv.ofBijective
    (fun h => ⟨hostComponent h v, hostComponent_mem_primvierlingFinset h v⟩)
    ⟨hostComponent_injective_subtype v hv, hostComponent_surjective_subtype v hv⟩

theorem mem_hostTriple_iff_ne_hostComponent {host : EABCChannel} {v : Primvierling} {x : Nat} :
    x ∈ hostTriple host v ↔ x ∈ primvierlingFinset v ∧ x ≠ hostComponent host v :=
  mem_hostTriple_iff

/-- Paper alias: explizite Komplement-Iff-Form der Host-Dreier-Mitgliedschaft. -/
theorem mem_hostTriple_iff_complement {host : EABCChannel} {v : Primvierling} {x : Nat} :
    x ∈ hostTriple host v ↔ x ∈ primvierlingFinset v ∧ x ≠ hostComponent host v :=
  mem_hostTriple_iff_ne_hostComponent

theorem not_mem_hostTriple_iff_eq_hostComponent {host : EABCChannel} {v : Primvierling} {x : Nat}
    (hx : x ∈ primvierlingFinset v) :
    x ∉ hostTriple host v ↔ x = hostComponent host v := by
  constructor
  · intro hnot
    by_contra hne
    exact hnot (mem_hostTriple_iff.mpr ⟨hx, hne⟩)
  · intro heq
    rw [heq]
    exact hostComponent_not_mem_hostTriple host v

/--
A-T (E-034): Jede Komponente der 4-Menge liegt in genau drei der vier Host-Dreier.
-/
theorem mem_hostTriple_count (v : Primvierling) (hv : primvierlingDistinct v)
    {x : Nat} (hx : x ∈ primvierlingFinset v) :
    ({host : EABCChannel | x ∈ hostTriple host v}.toFinset.card = 3) := by
  obtain ⟨h₀, h₀_comp, h₀_unique⟩ := exists_unique_hostComponent v hv x hx
  have hmiss : x ∉ hostTriple h₀ v :=
    (not_mem_hostTriple_iff_eq_hostComponent hx).mpr h₀_comp.symm
  have heq :
      Finset.univ.filter (fun host => x ∈ hostTriple host v) = Finset.univ.erase h₀ := by
    ext host
    simp only [Finset.mem_filter, Finset.mem_erase, Finset.mem_univ, true_and]
    constructor
    · intro hmem
      refine ⟨?_, trivial⟩
      intro heq'
      subst heq'
      exact hmiss hmem
    · intro ⟨hne, _⟩
      have hcomp : x ≠ hostComponent host v := fun heq' =>
        hne (h₀_unique host heq'.symm)
      exact (mem_hostTriple_iff (host := host) (v := v) (x := x)).mpr ⟨hx, hcomp⟩
  have hfilter :
      ({host : EABCChannel | x ∈ hostTriple host v}.toFinset =
        Finset.univ.filter (fun host => x ∈ hostTriple host v)) := by
    ext host
    simp [Set.mem_setOf_eq, Finset.mem_filter]
  rw [hfilter, heq, Finset.card_erase_of_mem (Finset.mem_univ h₀), Finset.card_univ]
  decide

/--
A-T (E-034): Genau ein Host schliesst `x` aus seinem Dreier aus — der mit `hostComponent = x`.
-/
theorem unique_excluded_host (v : Primvierling) (hv : primvierlingDistinct v) {x : Nat}
    (hx : x ∈ primvierlingFinset v) :
    ∃! host : EABCChannel, x ∉ hostTriple host v := by
  obtain ⟨h₀, h₀_comp, h₀_unique⟩ := exists_unique_hostComponent v hv x hx
  refine ExistsUnique.intro h₀ ?_ ?_
  · exact (not_mem_hostTriple_iff_eq_hostComponent hx).mpr h₀_comp.symm
  · intro host hnot
    exact h₀_unique host ((not_mem_hostTriple_iff_eq_hostComponent hx).mp hnot).symm

private lemma primvierlingFinset_card_four (v : Primvierling) (hv : primvierlingDistinct v) :
    (primvierlingFinset v).card = 4 := by
  rcases v with ⟨a, b, c, e⟩
  rcases hv with ⟨hab, hac, hae, hbc, hbe, hce⟩
  simp only [primvierlingFinset]
  have hc : c ∉ ({e} : Finset Nat) := by simp [Finset.mem_singleton, hce]
  have hb : b ∉ ({c, e} : Finset Nat) := by simp [Finset.mem_insert, Finset.mem_singleton, hbc, hbe]
  have ha : a ∉ ({b, c, e} : Finset Nat) := by simp [Finset.mem_insert, Finset.mem_singleton, hab, hac, hae]
  rw [Finset.card_insert_of_notMem ha, Finset.card_insert_of_notMem hb,
    Finset.card_insert_of_notMem hc, Finset.card_singleton]

private lemma hostTriple_card (host : EABCChannel) (v : Primvierling)
    (hv : primvierlingDistinct v) :
    (hostTriple host v).card = 3 := by
  have hdisj : Disjoint (hostTriple host v) {hostComponent host v} := by
    simpa [Finset.disjoint_singleton_right] using hostComponent_not_mem_hostTriple host v
  have hcard := Finset.card_union_of_disjoint hdisj
  rw [hostTriple_union_host_eq_four_set, Finset.card_singleton,
    primvierlingFinset_card_four v hv] at hcard
  omega

/-!
### Holographische Auslassung (Gap encodes Host)

Im Host-Dreier `hostTriple host v = P(v) \ {hostComponent host v}` fehlt genau eine
Primzahl — die vom Host getragene Komponente. Diese **Auslassung** (Gap) kodiert
bidirektional den Host: wer im Dreier fehlt, ist der Host (`dumas_gap_encodes_host`).

Metapher: Wie holographische Rekonstruktion aus Randinformation liefert die 3-Menge
den fehlenden 4.-Eintrag eindeutig — *Division* des Dumas-Lemmas.
-/

/--
A-T (E-048): Gap kodiert Host — fehlende Komponente im Host-Dreier ist genau die Host-Komponente.

Fuer `x ∈ primvierlingFinset v`: Auslassung im Host-Dreier genau dann, wenn
`x = hostComponent host v`.
Unter `primvierlingDistinct` identifiziert die Auslassung im Dreier den Traegerkanal eindeutig.

Informationsaussage: `Luecke ↔ Host` — die Auslassung kodiert den Host, kein zusaetzlicher Wahlparameter.
-/
theorem dumas_gap_encodes_host {host : EABCChannel} {v : Primvierling} {x : Nat}
    (hx : x ∈ primvierlingFinset v) :
    x ∉ hostTriple host v ↔ x = hostComponent host v :=
  not_mem_hostTriple_iff_eq_hostComponent hx

/-- Paper-Zitiername fuer `dumas_gap_encodes_host` (holographische Auslassung). -/
theorem holographic_omission_gap_encodes_host {host : EABCChannel} {v : Primvierling} {x : Nat}
    (hx : x ∈ primvierlingFinset v) :
    x ∉ hostTriple host v ↔ x = hostComponent host v :=
  dumas_gap_encodes_host hx

/--
A-T (E-048): Aequivalente Membership-Form — Tripel-Mitglied genau dann, wenn Komplement des Hosts.
-/
theorem hostTriple_membership_iff_not_host {host : EABCChannel} {v : Primvierling} {x : Nat} :
    x ∈ hostTriple host v ↔ x ∈ primvierlingFinset v ∧ x ≠ hostComponent host v :=
  mem_hostTriple_iff_ne_hostComponent

/-!
## Dumas-Lemma (E-048, Konsolidierung von E-034/E-047)

Benannt nach Alexandre Dumas (*Drei Musketiere*): vier Helden, Motto *Un pour tous,
tous pour un*. Vier Traegerkanaele `E`, `A`, `B`, `C`; jeder Host `h` sieht genau
die drei Komponenten der uebrigen Kanaele (`hostTriple h v`), analog zu
`otherChannels h` in `DreiMusketiere.lean`.

**Tous pour un:** `hostTriple h v` ist die 3-Menge der Nicht-Host-Komponenten;
Vereinigung mit `hostComponent h v` ergibt `primvierlingFinset v`
(`hostTriple_union_host_eq_four_set`, `hostTriple_card`).

**Un pour tous:** Jede Komponente liegt in genau drei Host-Dreiern
(`mem_hostTriple_count`); genau ein Host schliesst sie aus (`unique_excluded_host`).

**Division:** `hostComponentEquiv` ist Bijektion `EABCChannel ≃ P(v)`;
ausgeschlossener Host ↔ fehlende Komponente im Dreier.

Korollar `dumasLemma_otherChannels_card`: `|hostTriple| = |otherChannels| = 3`.

Ausfuehrliches Dossier: `docs/dumas_lemma.md`.
-/

/--
A-D (E-048): Zustandsbundle des Dumas-Lemmas — *Un pour tous, tous pour un*.

Buendelt Tous pour un (`hostTriple_card_three`, `hostTriple_union`),
Un pour tous (`mem_hostTriple_card_three`, `unique_excluded`).
Division via `dumasLemma_hostComponent_bij` (= `hostComponentEquiv`).

Siehe `docs/dumas_lemma.md`.
-/
structure Dumas_one_for_all_all_for_one (v : Primvierling) (hv : primvierlingDistinct v) : Prop where
  /-- Tous pour un: jeder Host-Dreier hat Kardinalitaet 3. -/
  hostTriple_card_three : ∀ host, (hostTriple host v).card = 3
  /-- Tous pour un: Host-Dreier ∪ ausgelassene Komponente = 4-Menge. -/
  hostTriple_union : ∀ host, hostTriple host v ∪ {hostComponent host v} = primvierlingFinset v
  /-- Un pour tous: jede Komponente in genau drei Host-Dreiern. -/
  mem_hostTriple_card_three : ∀ {x}, x ∈ primvierlingFinset v →
    ({host : EABCChannel | x ∈ hostTriple host v}.toFinset.card = 3)
  /-- Division: genau ein Host schliesst jede Komponente aus. -/
  unique_excluded : ∀ {x}, x ∈ primvierlingFinset v → ∃! host, x ∉ hostTriple host v

/--
A-T (E-048): Dumas-Lemma — *Un pour tous, tous pour un* fuer den Primvierling.

Konsolidiert E-033/E-046 (Komplementaritaet) und E-034/E-047 (Bijektion/Multiplizitaet).
Siehe `docs/dumas_lemma.md`.
-/
theorem dumasLemma (v : Primvierling) (hv : primvierlingDistinct v) :
    Dumas_one_for_all_all_for_one v hv where
  hostTriple_card_three host := hostTriple_card host v hv
  hostTriple_union host := hostTriple_union_host_eq_four_set host v
  mem_hostTriple_card_three hx := mem_hostTriple_count v hv hx
  unique_excluded hx := unique_excluded_host v hv hx

/--
Division (E-048): `hostComponent(·, v)` als Bijektion `EABCChannel ≃ P(v)`.

Alias fuer `hostComponentEquiv`; siehe `docs/dumas_lemma.md` Abschnitt Division.
-/
noncomputable def dumasLemma_hostComponent_bij (v : Primvierling) (hv : primvierlingDistinct v) :
    EABCChannel ≃ {x // x ∈ primvierlingFinset v} :=
  hostComponentEquiv v hv

/--
Korollar (Musketiere, E-048): `|hostTriple h v| = |otherChannels h| = 3`.

Bruecke arithmetischer Host-Dreier (`hostTriple`) und geometrischer Kanal-Dreier
(`otherChannels` in `DreiMusketiere.lean`). Siehe `docs/dumas_lemma.md`.
-/
theorem dumasLemma_otherChannels_card (host : EABCChannel) (v : Primvierling)
    (hv : primvierlingDistinct v) :
    (hostTriple host v).card = (otherChannels host).card := by
  rw [hostTriple_card host v hv, otherChannels_card host]

/-!
### Kanonisches Primquadruplet `(p, p+2, p+6, p+8)`
-/

/--
A-D: Kanonisches arithmetisches Primquadruplet.
-/
structure PrimeQuadruplet where
  p : Nat
  is_prime_p : Nat.Prime p
  is_prime_p2 : Nat.Prime (p + 2)
  is_prime_p6 : Nat.Prime (p + 6)
  is_prime_p8 : Nat.Prime (p + 8)

def PrimeQuadruplet.toPrimvierling (v : PrimeQuadruplet) : Primvierling :=
  (v.p, v.p + 2, v.p + 6, v.p + 8)

def PrimeQuadruplet.toFinset (v : PrimeQuadruplet) : Finset Nat :=
  primvierlingFinset v.toPrimvierling

theorem PrimeQuadruplet.toFinset_eq (v : PrimeQuadruplet) :
    v.toFinset = {v.p, v.p + 2, v.p + 6, v.p + 8} := by
  ext x
  simp [PrimeQuadruplet.toFinset, PrimeQuadruplet.toPrimvierling, primvierlingFinset,
    Finset.mem_insert, Finset.mem_singleton]

theorem primeQuadruplet_components_distinct {p : Nat} (hp : p > 3) :
    p ≠ p + 2 ∧ p ≠ p + 6 ∧ p ≠ p + 8 ∧ p + 2 ≠ p + 6 ∧ p + 2 ≠ p + 8 ∧ p + 6 ≠ p + 8 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  all_goals omega

theorem PrimeQuadruplet.distinct (v : PrimeQuadruplet) (hp : v.p > 3) :
    primvierlingDistinct v.toPrimvierling := by
  simpa [primvierlingDistinct, PrimeQuadruplet.toPrimvierling] using
    primeQuadruplet_components_distinct hp

theorem PrimeQuadruplet.hostTriple_union (host : EABCChannel) (v : PrimeQuadruplet) :
    hostTriple host v.toPrimvierling ∪ {hostComponent host v.toPrimvierling} = v.toFinset :=
  hostTriple_union_host_eq_four_set host v.toPrimvierling

/--
A-D: Sortierte Abstandspaare `(d₁, d₂)` eines Host-Dreiers.
-/
def hostTripleGapPair (host : EABCChannel) (_p : Nat) : Nat × Nat :=
  match host with
  | EABCChannel.E => (2, 4)
  | EABCChannel.A => (4, 2)
  | EABCChannel.B => (6, 2)
  | EABCChannel.C => (2, 6)

def sortedGapPair (S : Finset Nat) : Nat × Nat :=
  let l := S.sort (· ≤ ·)
  (l[1]! - l[0]!, l[2]! - l[1]!)

private lemma finset_sort_p_p2_p6 (p : Nat) :
    ({p, p + 2, p + 6} : Finset Nat).sort (· ≤ ·) = [p, p + 2, p + 6] := by
  have hp6 : p + 6 ∉ (∅ : Finset Nat) := by simp
  have hp2 : p + 2 ∉ insert (p + 6) (∅ : Finset Nat) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hp : p ∉ insert (p + 2) (insert (p + 6) (∅ : Finset Nat)) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hfin : ({p, p + 2, p + 6} : Finset Nat) =
      insert p (insert (p + 2) (insert (p + 6) (∅ : Finset Nat))) := by
    ext x <;> simp [Finset.mem_insert, Finset.mem_singleton] <;> try omega
  have h0 : ∀ b ∈ insert (p + 2) (insert (p + 6) (∅ : Finset Nat)), p ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; rcases hb with hb | hb <;> omega
  have h1 : ∀ b ∈ insert (p + 6) (∅ : Finset Nat), p + 2 ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; omega
  have h2 : ∀ b ∈ (∅ : Finset Nat), p + 6 ≤ b := by intro b hb; simp at hb
  have hs : (insert p (insert (p + 2) (insert (p + 6) (∅ : Finset Nat)))).sort (· ≤ ·) =
      [p, p + 2, p + 6] := by
    rw [Finset.sort_insert (· ≤ ·) h0 hp, Finset.sort_insert (· ≤ ·) h1 hp2, Finset.sort_insert (· ≤ ·) h2 hp6,
      Finset.sort_empty]
  simpa [hfin] using hs

private lemma finset_sort_p2_p6_p8 (p : Nat) :
    ({p + 2, p + 6, p + 8} : Finset Nat).sort (· ≤ ·) = [p + 2, p + 6, p + 8] := by
  have hp8 : p + 8 ∉ (∅ : Finset Nat) := by simp
  have hp6 : p + 6 ∉ insert (p + 8) (∅ : Finset Nat) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hp2 : p + 2 ∉ insert (p + 6) (insert (p + 8) (∅ : Finset Nat)) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hfin : ({p + 2, p + 6, p + 8} : Finset Nat) =
      insert (p + 2) (insert (p + 6) (insert (p + 8) (∅ : Finset Nat))) := by
    ext x <;> simp [Finset.mem_insert, Finset.mem_singleton] <;> try omega
  have h0 : ∀ b ∈ insert (p + 6) (insert (p + 8) (∅ : Finset Nat)), p + 2 ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; rcases hb with hb | hb <;> omega
  have h1 : ∀ b ∈ insert (p + 8) (∅ : Finset Nat), p + 6 ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; omega
  have h2 : ∀ b ∈ (∅ : Finset Nat), p + 8 ≤ b := by intro b hb; simp at hb
  have hs : (insert (p + 2) (insert (p + 6) (insert (p + 8) (∅ : Finset Nat)))).sort (· ≤ ·) =
      [p + 2, p + 6, p + 8] := by
    rw [Finset.sort_insert (· ≤ ·) h0 hp2, Finset.sort_insert (· ≤ ·) h1 hp6, Finset.sort_insert (· ≤ ·) h2 hp8,
      Finset.sort_empty]
  simpa [hfin] using hs

private lemma finset_sort_p_p6_p8 (p : Nat) :
    ({p, p + 6, p + 8} : Finset Nat).sort (· ≤ ·) = [p, p + 6, p + 8] := by
  have hp8 : p + 8 ∉ (∅ : Finset Nat) := by simp
  have hp6 : p + 6 ∉ insert (p + 8) (∅ : Finset Nat) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hp : p ∉ insert (p + 6) (insert (p + 8) (∅ : Finset Nat)) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hfin : ({p, p + 6, p + 8} : Finset Nat) =
      insert p (insert (p + 6) (insert (p + 8) (∅ : Finset Nat))) := by
    ext x <;> simp [Finset.mem_insert, Finset.mem_singleton] <;> try omega
  have h0 : ∀ b ∈ insert (p + 6) (insert (p + 8) (∅ : Finset Nat)), p ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; rcases hb with hb | hb <;> omega
  have h1 : ∀ b ∈ insert (p + 8) (∅ : Finset Nat), p + 6 ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; omega
  have h2 : ∀ b ∈ (∅ : Finset Nat), p + 8 ≤ b := by intro b hb; simp at hb
  have hs : (insert p (insert (p + 6) (insert (p + 8) (∅ : Finset Nat)))).sort (· ≤ ·) =
      [p, p + 6, p + 8] := by
    rw [Finset.sort_insert (· ≤ ·) h0 hp, Finset.sort_insert (· ≤ ·) h1 hp6, Finset.sort_insert (· ≤ ·) h2 hp8,
      Finset.sort_empty]
  simpa [hfin] using hs

private lemma finset_sort_p_p2_p8 (p : Nat) :
    ({p, p + 2, p + 8} : Finset Nat).sort (· ≤ ·) = [p, p + 2, p + 8] := by
  have hp8 : p + 8 ∉ (∅ : Finset Nat) := by simp
  have hp2 : p + 2 ∉ insert (p + 8) (∅ : Finset Nat) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hp : p ∉ insert (p + 2) (insert (p + 8) (∅ : Finset Nat)) := by
    simp [Finset.mem_insert, Finset.mem_singleton]
  have hfin : ({p, p + 2, p + 8} : Finset Nat) =
      insert p (insert (p + 2) (insert (p + 8) (∅ : Finset Nat))) := by
    ext x <;> simp [Finset.mem_insert, Finset.mem_singleton] <;> try omega
  have h0 : ∀ b ∈ insert (p + 2) (insert (p + 8) (∅ : Finset Nat)), p ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; rcases hb with hb | hb <;> omega
  have h1 : ∀ b ∈ insert (p + 8) (∅ : Finset Nat), p + 2 ≤ b := by
    intro b hb; simp [Finset.mem_insert, Finset.mem_singleton] at hb; omega
  have h2 : ∀ b ∈ (∅ : Finset Nat), p + 8 ≤ b := by intro b hb; simp at hb
  have hs : (insert p (insert (p + 2) (insert (p + 8) (∅ : Finset Nat)))).sort (· ≤ ·) =
      [p, p + 2, p + 8] := by
    rw [Finset.sort_insert (· ≤ ·) h0 hp, Finset.sort_insert (· ≤ ·) h1 hp2, Finset.sort_insert (· ≤ ·) h2 hp8,
      Finset.sort_empty]
  simpa [hfin] using hs

private lemma hostTriple_finset_E (v : PrimeQuadruplet) :
    hostTriple EABCChannel.E v.toPrimvierling = {v.p, v.p + 2, v.p + 6} := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, PrimeQuadruplet.toPrimvierling,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro ⟨hmem, hne⟩
    rcases hmem with rfl | rfl | rfl | rfl <;> simp at hne <;> omega
  · intro h
    rcases h with rfl | rfl | rfl
    · exact ⟨Or.inl rfl, by omega⟩
    · exact ⟨Or.inr (Or.inl rfl), by omega⟩
    · exact ⟨Or.inr (Or.inr (Or.inl rfl)), by omega⟩

private lemma hostTriple_finset_A (v : PrimeQuadruplet) :
    hostTriple EABCChannel.A v.toPrimvierling = {v.p + 2, v.p + 6, v.p + 8} := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, PrimeQuadruplet.toPrimvierling,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro ⟨hmem, hne⟩
    rcases hmem with rfl | rfl | rfl | rfl <;> simp at hne <;> omega
  · intro h
    rcases h with rfl | rfl | rfl
    · exact ⟨Or.inr (Or.inl rfl), by omega⟩
    · exact ⟨Or.inr (Or.inr (Or.inl rfl)), by omega⟩
    · exact ⟨Or.inr (Or.inr (Or.inr rfl)), by omega⟩

private lemma hostTriple_finset_B (v : PrimeQuadruplet) :
    hostTriple EABCChannel.B v.toPrimvierling = {v.p, v.p + 6, v.p + 8} := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, PrimeQuadruplet.toPrimvierling,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro ⟨hmem, hne⟩
    rcases hmem with rfl | rfl | rfl | rfl <;> simp at hne <;> omega
  · intro h
    rcases h with rfl | rfl | rfl
    · exact ⟨Or.inl rfl, by omega⟩
    · exact ⟨Or.inr (Or.inr (Or.inl rfl)), by omega⟩
    · exact ⟨Or.inr (Or.inr (Or.inr rfl)), by omega⟩

private lemma hostTriple_finset_C (v : PrimeQuadruplet) :
    hostTriple EABCChannel.C v.toPrimvierling = {v.p, v.p + 2, v.p + 8} := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, PrimeQuadruplet.toPrimvierling,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro ⟨hmem, hne⟩
    rcases hmem with rfl | rfl | rfl | rfl <;> simp at hne <;> omega
  · intro h
    rcases h with rfl | rfl | rfl
    · exact ⟨Or.inl rfl, by omega⟩
    · exact ⟨Or.inr (Or.inl rfl), by omega⟩
    · exact ⟨Or.inr (Or.inr (Or.inr rfl)), by omega⟩

theorem PrimeQuadruplet.hostTriple_gap_pair (host : EABCChannel) (v : PrimeQuadruplet)
    (_hp : v.p > 3) :
    sortedGapPair (hostTriple host v.toPrimvierling) = hostTripleGapPair host v.p := by
  rcases host with _ | _ | _ | _
  · rw [hostTriple_finset_E v]
    unfold sortedGapPair
    rw [finset_sort_p_p2_p6 v.p]
    simp [hostTripleGapPair, List.getElem_cons_zero, List.getElem_cons_succ, Nat.succ_eq_add_one]
  · rw [hostTriple_finset_A v]
    unfold sortedGapPair
    rw [finset_sort_p2_p6_p8 v.p]
    simp [hostTripleGapPair, List.getElem_cons_zero, List.getElem_cons_succ, Nat.succ_eq_add_one]
  · rw [hostTriple_finset_B v]
    unfold sortedGapPair
    rw [finset_sort_p_p6_p8 v.p]
    simp [hostTripleGapPair, List.getElem_cons_zero, List.getElem_cons_succ, Nat.succ_eq_add_one]
  · rw [hostTriple_finset_C v]
    unfold sortedGapPair
    rw [finset_sort_p_p2_p8 v.p]
    simp [hostTripleGapPair, List.getElem_cons_zero, List.getElem_cons_succ, Nat.succ_eq_add_one]

theorem hostTripleGapPair_permutation :
    (Finset.univ : Finset EABCChannel).image (hostTripleGapPair · 0) =
      {(2, 4), (4, 2), (6, 2), (2, 6)} := by
  decide

/--
A-D: CEAB-Wirkung auf Trägerkanaele — permutiert die Host-Projektionen.
-/
def shiftHostChannel : EABCChannel → EABCChannel
  | EABCChannel.E => EABCChannel.B
  | EABCChannel.A => EABCChannel.C
  | EABCChannel.B => EABCChannel.E
  | EABCChannel.C => EABCChannel.A

private lemma hostTriple_shiftCEAB_E (a b c e : Nat) :
    hostTriple EABCChannel.E (shiftCEAB (a, b, c, e)) =
      hostTriple EABCChannel.B (a, b, c, e) := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, shiftCEAB,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  tauto

private lemma hostTriple_shiftCEAB_A (a b c e : Nat) :
    hostTriple EABCChannel.A (shiftCEAB (a, b, c, e)) =
      hostTriple EABCChannel.C (a, b, c, e) := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, shiftCEAB,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  tauto

private lemma hostTriple_shiftCEAB_B (a b c e : Nat) :
    hostTriple EABCChannel.B (shiftCEAB (a, b, c, e)) =
      hostTriple EABCChannel.E (a, b, c, e) := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, shiftCEAB,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  tauto

private lemma hostTriple_shiftCEAB_C (a b c e : Nat) :
    hostTriple EABCChannel.C (shiftCEAB (a, b, c, e)) =
      hostTriple EABCChannel.A (a, b, c, e) := by
  ext x
  simp only [hostTriple, hostComponent, primvierlingFinset, shiftCEAB,
    Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton]
  tauto

theorem hostTriple_shiftCEAB (host : EABCChannel) (v : Primvierling) :
    hostTriple host (shiftCEAB v) = hostTriple (shiftHostChannel host) v := by
  rcases v with ⟨a, b, c, e⟩
  fin_cases host <;>
    simp [shiftHostChannel, hostTriple_shiftCEAB_E, hostTriple_shiftCEAB_A,
      hostTriple_shiftCEAB_B, hostTriple_shiftCEAB_C]

end KeplerHurwitz
