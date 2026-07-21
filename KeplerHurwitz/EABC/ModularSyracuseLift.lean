/-
  Abstract finite lift logic for modular functional digraphs.

  Formalizes the combinatorial distinction
    CycleLiftable → ∀ edges EdgeLiftable
  and a tiny counterexample showing the converse fails.

  Claim wall:
    [A] abstract finite combinatorics only (no F_k arithmetic required)
    [B] numerical Bool-trace / δ_coh certificates live in Python (§5.16)
    [C] / NON-CLAIM: no Collatz; no Universal surgery; no ∀k lift theorem

  Docs: docs/eabc_collatz_audit_grid.md §5.16
-/

import Mathlib

namespace KeplerHurwitz.EABC
namespace ModularSyracuseLift

/-! ## Functional digraphs and directed cycles [A] -/

/--
A (partial) functional digraph: each vertex has at most one outgoing edge.
`none` means the vertex is dropped / has no successor (cf. avoid-1 cuts).
-/
structure FunctionalDigraph (α : Type*) where
  next : α → Option α

/-- A finite directed cycle as an ordered list of vertices with wrap-around edges. -/
structure DirectedCycle (α : Type*) where
  nodes : List α
  length_pos : 0 < nodes.length

namespace DirectedCycle

variable {α : Type*}

/-- Successor index on a cycle. -/
def succIdx (C : DirectedCycle α) (i : Fin C.nodes.length) : Fin C.nodes.length :=
  ⟨(i.1 + 1) % C.nodes.length, Nat.mod_lt _ C.length_pos⟩

/-- Vertex at index `i`. -/
def vertex (C : DirectedCycle α) (i : Fin C.nodes.length) : α :=
  C.nodes.get i

/-- Ordered edge `(u_i, u_{i+1})` (indices mod length). -/
def edge (C : DirectedCycle α) (i : Fin C.nodes.length) : α × α :=
  (C.vertex i, C.vertex (C.succIdx i))

end DirectedCycle

/-! ## Liftability relative to a projection [A] -/

/--
An edge `u → v` of the lower graph is edge-liftable along `π` if there exist
upper vertices projecting to `u, v` with an upper edge between them.
-/
def EdgeLiftable {α β : Type*} (Gup : FunctionalDigraph β) (π : β → α)
    (u v : α) : Prop :=
  ∃ uLift vLift : β, π uLift = u ∧ π vLift = v ∧ Gup.next uLift = some vLift

/--
A directed cycle is cycle-liftable if there is a vertex lift of every node
such that each consecutive pair (including the wrap-around) is an upper edge
and projects to the lower edge.
-/
def CycleLiftable {α β : Type*} (Gup : FunctionalDigraph β) (π : β → α)
    (C : DirectedCycle α) : Prop :=
  ∃ lift : Fin C.nodes.length → β,
    (∀ i, π (lift i) = C.vertex i) ∧
      ∀ i, Gup.next (lift i) = some (lift (C.succIdx i))

/-! ## Cycle ⇒ edge liftability [A] -/

/--
`[A]` Any cycle lift restricts to an edge lift on every cycle edge.
-/
theorem cycleLiftable_implies_edgeLiftable
    {α β : Type*} (Gup : FunctionalDigraph β) (π : β → α)
    (C : DirectedCycle α) (h : CycleLiftable Gup π C) :
    ∀ i : Fin C.nodes.length,
      EdgeLiftable Gup π (C.edge i).1 (C.edge i).2 := by
  rcases h with ⟨lift, hπ, hedge⟩
  intro i
  refine ⟨lift i, lift (C.succIdx i), hπ i, hπ (C.succIdx i), ?_⟩
  simpa [DirectedCycle.edge, DirectedCycle.vertex] using hedge i

/-! ## Tiny abstract counterexample: edge lifts ↛ cycle lift [A] -/

/-
  Lower 2-cycle: `u0 → u1 → u0`.
  Upper nodes: `a0, a1` (project to `u0`) and `b0` (projects to `u1`).
  Upper edges: `a0 → b0`, `b0 → a1`, and `a1` has no successor.

  Local edge lifts exist:
    `u0→u1` via `a0→b0`,  `u1→u0` via `b0→a1`.
  No global cycle lift: the only chain is `a0→b0→a1`, and `a1` cannot return.
-/

inductive Lower2
  | u0
  | u1
  deriving DecidableEq, Repr

inductive Upper3
  | a0
  | a1
  | b0
  deriving DecidableEq, Repr

def π_ex : Upper3 → Lower2
  | .a0 => .u0
  | .a1 => .u0
  | .b0 => .u1

def G_ex : FunctionalDigraph Upper3 where
  next
    | .a0 => some .b0
    | .b0 => some .a1
    | .a1 => none

def C_ex : DirectedCycle Lower2 where
  nodes := [.u0, .u1]
  length_pos := by decide

theorem C_ex_length : C_ex.nodes.length = 2 := rfl

theorem C_ex_vertex_0 : C_ex.vertex ⟨0, by decide⟩ = Lower2.u0 := rfl
theorem C_ex_vertex_1 : C_ex.vertex ⟨1, by decide⟩ = Lower2.u1 := rfl

theorem C_ex_succ_0 : C_ex.succIdx ⟨0, by decide⟩ = ⟨1, by decide⟩ := by
  simp [DirectedCycle.succIdx, C_ex_length]

theorem C_ex_succ_1 : C_ex.succIdx ⟨1, by decide⟩ = ⟨0, by decide⟩ := by
  simp [DirectedCycle.succIdx, C_ex_length]

/-- Edge `u0 → u1` is edge-liftable via `a0 → b0`. -/
theorem edgeLiftable_ex_0 :
    EdgeLiftable G_ex π_ex Lower2.u0 Lower2.u1 :=
  ⟨Upper3.a0, Upper3.b0, rfl, rfl, rfl⟩

/-- Edge `u1 → u0` is edge-liftable via `b0 → a1`. -/
theorem edgeLiftable_ex_1 :
    EdgeLiftable G_ex π_ex Lower2.u1 Lower2.u0 :=
  ⟨Upper3.b0, Upper3.a1, rfl, rfl, rfl⟩

/-- Every lower cycle edge is edge-liftable. -/
theorem edgeLiftable_ex :
    ∀ i : Fin C_ex.nodes.length,
      EdgeLiftable G_ex π_ex (C_ex.edge i).1 (C_ex.edge i).2 := by
  intro i
  have hi : i.val = 0 ∨ i.val = 1 := by
    have := i.isLt
    simp [C_ex_length] at this
    omega
  rcases hi with h0 | h1
  · have : i = ⟨0, by decide⟩ := Fin.ext h0
    subst this
    simpa [DirectedCycle.edge, C_ex_vertex_0, C_ex_succ_0, C_ex_vertex_1] using
      edgeLiftable_ex_0
  · have : i = ⟨1, by decide⟩ := Fin.ext h1
    subst this
    simpa [DirectedCycle.edge, C_ex_vertex_1, C_ex_succ_1, C_ex_vertex_0] using
      edgeLiftable_ex_1

/--
`[A]` Local edge liftability does **not** imply cycle liftability
(combinatorial CSP obstruction on a 2-cycle).
-/
theorem not_cycleLiftable_ex : ¬ CycleLiftable G_ex π_ex C_ex := by
  intro h
  rcases h with ⟨lift, hπ, hedge⟩
  have h1 : π_ex (lift ⟨1, by decide⟩) = Lower2.u1 := by
    simpa [C_ex_vertex_1] using hπ ⟨1, by decide⟩
  have e0 := hedge ⟨0, by decide⟩
  have e1 := hedge ⟨1, by decide⟩
  -- lift at index 1 must be b0
  have lift1 : lift ⟨1, by decide⟩ = Upper3.b0 := by
    cases hlift : lift ⟨1, by decide⟩ with
    | a0 =>
      have : π_ex Upper3.a0 = Lower2.u1 := by simpa [hlift] using h1
      cases this
    | a1 =>
      have : π_ex Upper3.a1 = Lower2.u1 := by simpa [hlift] using h1
      cases this
    | b0 => rfl
  -- succIdx 0 = 1, so next(lift0) = lift1 = b0
  have e0' : G_ex.next (lift ⟨0, by decide⟩) = some Upper3.b0 := by
    simpa [C_ex_succ_0, lift1] using e0
  have lift0 : lift ⟨0, by decide⟩ = Upper3.a0 := by
    cases hlift : lift ⟨0, by decide⟩ with
    | a0 => rfl
    | a1 =>
      simp [G_ex, hlift] at e0'
    | b0 =>
      simp [G_ex, hlift] at e0'
  -- succIdx 1 = 0, so next(b0) = lift0 = a0, contradiction
  have e1' : G_ex.next Upper3.b0 = some Upper3.a0 := by
    simpa [lift1, lift0, C_ex_succ_1] using e1
  simp [G_ex] at e1'

/-- Package: all edges liftable, yet the cycle is not. -/
theorem edgeLiftable_not_implies_cycleLiftable_ex :
    (∀ i : Fin C_ex.nodes.length,
        EdgeLiftable G_ex π_ex (C_ex.edge i).1 (C_ex.edge i).2) ∧
      ¬ CycleLiftable G_ex π_ex C_ex :=
  ⟨edgeLiftable_ex, not_cycleLiftable_ex⟩

/-! ## Boolean 2×2 matrix product (combinatorial criterion stubs) [A] -/

/-
  Normative lift criterion: OR-AND relation product, **not** GF(2)/XOR.

    (A ⊙ B)[i,j] = ⋁_r (A[i,r] ∧ B[r,j])

  Python `kepler_hurwitz.eabc_lift_coherence.bool_matmul` must match this.
  Cross-check (two paths): U = all-true; U ⊙ U = U, while U·_{GF2} U = 0.
-/

/-- Boolean OR-AND product of 2×2 `Bool` matrices (normative for lift monodromy). -/
def boolMatMul (A B : Fin 2 → Fin 2 → Bool) : Fin 2 → Fin 2 → Bool :=
  fun i j => (A i 0 && B 0 j) || (A i 1 && B 1 j)

/-- Boolean trace: diagonal OR. -/
def boolTrace (P : Fin 2 → Fin 2 → Bool) : Bool :=
  P 0 0 || P 1 1

/-- All-ones matrix (two-path witness vs GF(2)). -/
def boolMatU : Fin 2 → Fin 2 → Bool := fun _ _ => true

/-- OR-AND keeps the two-path contribution: `U ⊙ U = U`. -/
theorem boolMatMul_U_U : boolMatMul boolMatU boolMatU = boolMatU := by
  funext i j
  fin_cases i <;> fin_cases j <;> simp [boolMatMul, boolMatU]

/-- Identity for the boolean semiring on 2×2 matrices. -/
def boolMatId : Fin 2 → Fin 2 → Bool :=
  fun i j => decide (i = j)

theorem boolMatMul_id_left (A : Fin 2 → Fin 2 → Bool) :
    boolMatMul boolMatId A = A := by
  funext i j
  fin_cases i <;> fin_cases j <;> simp [boolMatMul, boolMatId]

/-- Boolean Flip / C₂ generator `S = [[false,true],[true,false]]`. -/
def boolMatFlip : Fin 2 → Fin 2 → Bool
  | 0, 1 => true
  | 1, 0 => true
  | _, _ => false

/--
`[A]` The Flip has vanishing boolean trace — hence Flip-monodromy alone
already obstructs CycleLiftable in the boolean criterion.

No Dynkin / root-system claim: this is a 2×2 boolean matrix fact only.
Docs: §5.17 (Python shows focus cycles have P ≠ Flip).
-/
theorem boolTrace_flip : boolTrace boolMatFlip = false := by
  native_decide

/-!
  Numerical monodromy types for frozen F_k-cycles live in Python (§5.17).
  Maximum lemma (pure ℕ inequality): planned later; no Collatz sorry-bridge here.
-/

/--
**NON-CLAIM:** No Collatz theorem; no Universal surgery; no ∀k liftability;
no Lie root system / E₈ reading of the lift CSP.
Abstract finite combinatorics only.
-/
theorem modular_lift_forall_k_not_claimed : True := trivial

end ModularSyracuseLift
end KeplerHurwitz.EABC
