# PR #16 Closure Audit — Core6 Static Dyadic Certificate

**Mathematical freeze (closure candidate):** `3740183198160e79b302eb2fcd8250d1e9fd925e`  
**This audit commit / tip:** see git HEAD after certificate packaging.  
**Status:** `[C→A]` until CI green ∧ review ∧ merge ∧ separate promotion commit to `[A]`.

## Toolchain

| Item | Value |
|------|--------|
| Lean | 4.31.0 (`68218e876d2a38b1985b8590fff244a83c321783`) |
| Mathlib | `fabf563a7c95` (from `lake-manifest.json`) |
| Module | `KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition` |
| Build | `lake build KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition` |
| Local build result | **success** (reported locally; GitHub CI may still be queued) |

## Sorry / admit scan

Command:

```bash
rg -n -P '(^|[^A-Za-z0-9_/`])(sorry|admit)([^A-Za-z0-9_]|$)' \
  KeplerHurwitz/Collatz/Pre119Draft --glob '*.lean'
```

**Result:** no `sorry` / `admit` **tactics**. Only documentation lines of the form `0 sorry.` appear in module headers.

## `#print axioms core6StaticDyadicCertificate`

```
'…core6StaticDyadicCertificate' depends on axioms: [propext,
 Classical.choice,
 Quot.sound,
 …native_decide axioms from census/identity lemmas…]
```

Kernel / classical axioms: `propext`, `Classical.choice`, `Quot.sound`.  
Additional entries are Lean `native_decide` certificates for fixed Nat identities
(`core6_sum`, `core6_length`, `wordC`/`coprime` decides, etc.) — not unpaid proof debt.

## Closure lemmas (bundled only)

| Field | Lemma |
|-------|--------|
| `phasePartition` / `phaseDisjoint` | `core6Cylinder_eq_expanding_disjoint_union_contracting` |
| `finiteSubset` | `contractingResidues_subset_core6Residues` |
| `contractingCard` | `contractingResidues_card` |
| `core6Card` | `core6Residues_card` |
| `dyadicProportion` | `contractingResidues_dyadicProportion` |
| `dyadicLimit` | `contractingResidues_tendsto_dyadicDensity` |

Entry point: `theorem core6StaticDyadicCertificate : Core6StaticDyadicCertificate`.

## Claim wall (frozen)

| Claim | In PR #16? |
|-------|------------|
| Relative dyadic density → 1/8 | **yes** |
| Natural density on ℕ | **no** |
| Global Collatz statement | **no** |
| Dynamical feed-in / reachability | **no** (`[C]`, separate PR) |

## Stack merge order

1. Integrate PR #15 first.  
2. Retarget/rebase PR #16 onto accepted base.  
3. Re-run full CI on the new tip.  
4. Review & merge PR #16.  
5. Separate status-promotion commit `[C→A] → [A]` after merge.

## Out of scope after freeze

No natural density, no reachability, no further orbit dynamics in PR #16 —
only proof/import/linter/doc/review fixes.
