# Pre119 — Core6 Cylinder Partition (PR #16)

**Governance:** 16a–16dδ `[A]` · 16e Zählung `[C→A]` · Zuführung `[C]` ·
Collatz unproved · ClaimsFreeze false · 0 sorry in discharged parts

## Beweisreihenfolge (formal belastbar)

```
Realisierungsäquivalenz
  ⟹ vollständige Partition
  ⟹ Disjunktheit (via unique tail valuation)
  ⟹ Komplementgleichung
  ⟹ (noch offen) Zählung und Dichte
```

## Statusschema

| Paket | Inhalt | Status |
|-------|--------|--------|
| Auftakt | `fiberE_positive_of_one_le`, `canonicalBase_realizes_of_one_le` (`e≥1`, nur Realisierung) | `[A]` |
| 16a | `mem_canonicalCylinder_iff_realizes_fiberE` | `[A]` |
| 16b | `tailExponent_unique`, `canonicalCylinders_disjoint` | `[A]` |
| 16c | `core6Cylinder = ⋃_{e≥1} C_e` | `[A]` |
| 16d | `core6 \ contracting = C_1 ∪ C_2 ∪ C_3` | `[A]` |
| 16dδ | `expands_fiberE_of_le_three`; Phasengrenze `e=4` | `[A]` |
| 16e | endliche dyadische Zählung → `1/8` / `7/8` | `[C→A]` |
| danach | Zuführung der drei Expansionskanäle | `[C]` |

> Epistemische Note: Bis zum Lean-Beweis standen 16a–16d unter `[C→A]`.
> Die Algebra war in PR #15 vorhanden; die Mengenidentitäten sind jetzt
> in `Core6CylinderPartition.lean` unter `[A]` entladen.

## Struktursatz

```
core6Cylinder
  = (C_1 ⊔ C_2 ⊔ C_3)_{expandierend}
  ⊔ (⊔_{e≥4} C_e)_{kontraktiv}
```

Für `e=1,2,3`: `2^{e+8} < 3^7` ⇒ `realizedImage > n` auf dem Sieben-Schritt-Block.
Für `e≥4`: kanonisch kontraktive APs (PR #15).

## Offene Front

Nicht diffuse Restmasse, sondern drei explizite Zuführkanäle:

```
Core6++[1],  Core6++[2],  Core6++[3].
```
