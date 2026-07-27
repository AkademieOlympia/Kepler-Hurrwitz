# Pre119 — Core6 Cylinder Partition (PR #16)

**Governance:** 16a/16b/16c-set `[A]` · finite dyadic count `[C]` ·
Collatz unproved · ClaimsFreeze false · 0 sorry in discharged parts

## Claim hierarchy

| ID | Status | Statement |
|----|--------|-----------|
| **PR #15** | `[A]` | For each `e ≥ 4`, a unique canonical contracting AP cylinder exists |
| **16a** | `[A]` | `n ∈ canonicalCylinder e ↔ RealizesWord (fiberE e) n` (`e ≥ 1`); pairwise disjoint via unique `ν₂(3x+1)` after Core6 |
| **16b** | `[A]` | `core6Cylinder = ⋃_{e≥1} canonicalCylinder e` |
| **16c set** | `[A]` | `core6Cylinder \ contractingCore6 = C_1 ∪ C_2 ∪ C_3` |
| **16c count** | `[C]` | Finite residues mod `2^{m+9}` certify relative density `1/8 - 1/2^m` |
| **Front** | `[C]` | Feed-in of the three small channels into controlled contracting cylinders |

## Semantic route (not bare Diophantine)

Disjointness is **not** proved by solving
`canonicalBase(e)+k·2^{e+9} = canonicalBase(f)+m·2^{f+9}` directly.

PR #15 already gives `n ∈ C_e ⇒ RealizesWord(Core6++[e], n)`.
A shared start traverses the same Core6 prefix; the reached odd value has a
**unique** valuation `ν₂(3x+1)`. Two memberships would force `e = f`.

## Completeness bridge (before density)

```
RealizesWord (fiberE e) n
  ⇒ AffineOddQuotient
  ⇒ 3⁷n+2347 ≡ 2^{e+8} (mod 2^{e+9})
  ⇒ n ≡ canonicalBase e (mod 2^{e+9})
  ⇒ n ∈ canonicalCylinder e
```

Together with the AP lifting of the unique seed, this yields the biconditional
`mem_canonicalCylinder_iff_realizes_fiberE`.

## The 7/8 complement is three channels

After Core6 the current value is odd, so `ν₂(3x+1) ≥ 1` and takes exactly one
value `e ∈ {1,2,3,…}`. Hence

```
C_Core6 = ⊔_{e≥1} C_e
```

with relative Core6 weights `δ(C_e) = 2^{-e}`. Therefore

```
∑_{e≥4} 2^{-e} = 1/8,
1 − 1/8 = 7/8 = 1/2 + 1/4 + 1/8
```

is **exactly** the channels

```
boxed{ e=1, e=2, e=3 }.
```

These are also the non-contracting / below-margin regimes (`2^{e+8} < 3⁷` for
`e=1,2,3`; threshold `e=4` starts `2^{e+8} > 3⁷`).

## Module

`KeplerHurwitz/Collatz/Pre119Draft/Core6CylinderPartition.lean`

- Package A: `canonicalCylinder`, `mem_canonicalCylinder_iff_realizes_fiberE`
- Package B: `canonicalCylinders_pairwise_disjoint`, `core6Cylinder_eq_iUnion_tailCylinders`
- Package C set: `core6_complement_contracting_eq_smallTails`
- Package C count: `FiniteDyadicContractingCountGoal` still `[C]`

## Open front after 16a–16c-set

Not a diffuse coverage question — a **finite three-channel problem**:

```
Core6++[1],  Core6++[2],  Core6++[3].
```
