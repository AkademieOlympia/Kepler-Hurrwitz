# Nuclear Mass Data — Expected Format (ORQ-090 / E-090)

**Status:** `[C]` — schema documentation only; no nuclear mass table is bundled in the scaffold commit.

---

## Purpose

ORQ-090 requires an external table of experimental nuclear masses or binding energies. This README specifies the normalized input schema expected by `load_mass_table()` in `nuclear_binding_residual_bridge.py`.

The scaffold does not download or bundle a mass table. The parser raises a clear error when the requested file is missing or when the required schema is not satisfied.

---

## Recommended sources

| Source | Role |
|---|---|
| **AME** — Atomic Mass Evaluation | Preferred source for atomic mass excesses or experimentally evaluated binding energies |
| **NUBASE** | Optional source for nuclide labels, state information and half-lives; mass information must be aligned with the selected AME release |

The exact source and release must be recorded in the export column `source_release`, for example:

- `AME2020`
- `AME2020+NUBASE2020`

Data from different releases must not be combined silently.

---

## Required nuclide-identification columns

| Column | Type | Unit | Description |
|---|---|---|---|
| `A` | int | — | Mass number |
| `Z` | int | — | Proton number |
| `element` | str | — | Chemical symbol, for example `Fe` or `U` |

### Optional derived identity column

| Column | Type | Unit | Description |
|---|---|---|---|
| `N` | int | — | Neutron number |

If `N` is absent, the parser derives

\[
N = A - Z.
\]

If `N` is present, the parser must verify this identity. Inconsistent rows cause an explicit error and are not silently corrected.

---

## Required experimental-energy information

The input must provide **at least one** of the following alternatives.

### Alternative A — direct binding energy

| Column | Type | Unit | Description |
|---|---|---|---|
| `binding_exp_MeV` | float | MeV | Experimental total nuclear binding energy |

### Alternative B — atomic mass excess

| Column | Type | Unit | Description |
|---|---|---|---|
| `mass_excess_keV` | float | keV | Atomic mass excess of the neutral atom |

If neither column is present, the parser raises a schema error.

When both columns are present, `binding_exp_MeV` may be retained as the primary value while the reconstructed value is used for a documented consistency check.

---

## Optional columns

| Column | Type | Unit | Description |
|---|---|---|---|
| `label` | str | — | Human-readable nuclide label, for example `Fe-56` |
| `source_release` | str | — | Source release identifier |
| `isomer_flag` | str or bool | — | Identifies an isomeric state where applicable |
| `mass_excess_unc_keV` | float | keV | Reported uncertainty of the atomic mass excess |
| `binding_exp_unc_MeV` | float | MeV | Reported uncertainty of the binding energy |

Ground states and isomeric states must not be merged silently.

---

## Binding-energy convention

AME mass excesses are interpreted using the **neutral atomic mass convention**.

For an atomic mass \(M_{\mathrm{atom}}(A,Z)\), the total nuclear binding energy is

\[
B_{\mathrm{exp}}
=
\left[
Z m_H
+
N m_n
-
M_{\mathrm{atom}}(A,Z)
\right]c^2,
\]

where

- \(m_H\) is the mass of the neutral hydrogen atom,
- \(m_n\) is the neutron mass,
- \(M_{\mathrm{atom}}\) is the neutral atomic mass of the nuclide.

The implementation must **not** substitute an uncorrected bare proton mass for \(m_H\).

`mass_excess_keV` is assumed to refer to the neutral atomic mass convention used by AME. It must not be interpreted as a bare nuclear mass excess. The implementation therefore uses the hydrogen-atom mass or the equivalent hydrogen mass-excess identity, not an uncorrected proton mass.

If the input provides atomic mass excesses,

\[
\Delta(A,Z)
=
\left[M_{\mathrm{atom}}(A,Z)-A\,u\right]c^2,
\]

the numerically preferable equivalent relation is

\[
\boxed{
B_{\mathrm{exp}}
=
Z\Delta_H
+
N\Delta_n
-
\Delta(A,Z)
}
\]

with all mass excesses expressed in the same energy unit.

The numerical constants, their source and their units must be documented in the module docstring before promotion to `[B0]`.

---

## Validation rules

The loader must validate at least:

\[
A > 0,\qquad Z \ge 0,\qquad N = A - Z \ge 0.
\]

It must also check:

- uniqueness of the selected nuclide-state key;
- finite numerical values in required energy columns;
- consistent units;
- consistency between supplied and derived `N`;
- consistency between `binding_exp_MeV` and reconstructed binding energy when both are supplied;
- explicit handling of isomers, extrapolated values and missing uncertainties.

No row may be discarded silently.

Excluded or rejected rows must be listed or counted by reason in the summary export.

---

## File placement

Place downloaded or locally converted tables under:

```
data/external/
```

Example:

```
data/external/ame2020_nuclides.csv
```

External data are not committed during the scaffold phase. Depending on licensing and repository policy, later data handling may use `.gitignore`, Git LFS or a reproducible download-and-conversion script.

---

## Reproducibility metadata

The `[B0]` export summary must record:

- input filename;
- cryptographic input-file hash;
- source and release;
- parser version;
- number of input rows;
- number of accepted rows;
- number and reasons for excluded rows;
- physical constants and units used;
- whether binding energy was supplied or reconstructed;
- whether SEMF results are in-sample or out-of-sample.

SEMF coefficients must be fitted on the training partition only unless an output is explicitly marked as an in-sample diagnostic.

---

## Governance

This document defines an input schema only.

It does not:

- bundle or endorse a particular mass table;
- establish an EABC–nuclear-physics relation;
- provide numerical evidence for ORQ-090;
- elevate the residual bridge beyond `[C]`;
- authorize silent row filtering or release mixing.

See [`docs/reports/orq_090_nuclear_binding_residual_bridge.md`](../reports/orq_090_nuclear_binding_residual_bridge.md).
