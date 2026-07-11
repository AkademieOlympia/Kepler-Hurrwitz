# Nuclear Mass Data — Expected Format (ORQ-090 / E-090)

**Status:** `[C]` — schema documentation only; **no mass table is bundled** in the scaffold commit.

---

## Purpose

ORQ-090 requires an external table of experimental nuclear masses. This README documents the expected column layout for `load_mass_table()` in `nuclear_binding_residual_bridge.py`. The parser raises a clear error if the file is missing.

---

## Recommended sources

| Source | Notes |
|---|---|
| **AME** (Atomic Mass Evaluation) | preferred for `binding_exp_MeV` or reconstructable mass excess |
| **NUBASE** | nuclide labels, half-lives; mass columns must align with AME release |

Document the exact release in export column `source_release` (e.g. `AME2020`, `NUBASE2020`).

---

## Required columns (minimal)

| Column | Type | Unit | Description |
|---|---|---|---|
| `A` | int | — | mass number |
| `Z` | int | — | proton number |
| `N` | int | — | neutron number (\(N = A - Z\)); may be derived if absent |
| `element` | str | — | nuclide symbol (e.g. `Fe`, `U`) |
| `mass_excess_keV` | float | keV | tabulated mass excess \(\Delta\) |

Either `binding_exp_MeV` **or** sufficient columns to compute it via `compute_binding_energy()` must be present.

---

## Optional columns

| Column | Type | Unit |
|---|---|---|
| `binding_exp_MeV` | float | MeV |
| `label` | str | — | human-readable nuclide tag (e.g. `Fe-56`) |

---

## Binding energy convention

If only `mass_excess_keV` is supplied, `compute_binding_energy()` derives:

\[
B_{\mathrm{exp}} = Z m_H + N m_n - M_{\mathrm{atom}}
\]

using standard atomic mass constants (documented in module docstring at `[B0]`). Units must remain explicit in column names.

---

## File placement

Place downloaded tables under `data/external/` (gitignored or LFS — **not** committed in the scaffold phase):

```
data/external/ame2020_nuclides.csv
```

---

## Governance

- No silent row drops — excluded nuclides must appear in summary JSON.
- Input file hash recorded in export summary.
- SEMF coefficients fit on training split only; never on the full table without explicit in-sample flag.

See [`docs/reports/orq_090_nuclear_binding_residual_bridge.md`](../reports/orq_090_nuclear_binding_residual_bridge.md).
