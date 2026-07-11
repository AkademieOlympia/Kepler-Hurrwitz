# Ticket: Extract Explicit Energiedoku Shell Coordinates for n=1,2,3

**Status:** COMPLETE (2026-07-05)  
**Suggested branch:** `extract-energiedoku-shell-coordinates-n1-n3`  
**Suggested commit title (if user commits later):** `Add explicit Energiedoku shell coordinates for embedding audit`

---

## Goal

Provide the machine-readable Energiedoku coordinate baseline required for the canonical embedding audit.

This task does not revise ι_n, does not search for ShellSeparationLoss(n), and does not activate shellPrimeMatchAtFirstLoss.

---

## Output File

Create:

`docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv`

with schema:

```
n,shell,label,x,y,z
```

**Ticket example (illustrative only — not the actual format):**

```
n,shell,label,x,y,z
1,S0,p0,0.0,0.0,0.0
1,S1,p1,1.0,0.0,0.0
```

**Actual format in this repo:** `shell` is a **0-based lex index** (0 … 4^n − 1), not `S0`/`S1`. `label` is an **EABC word** over `{E,A,B,C}` (e.g. `E`, `EA`, `EEE`), not `p0`/`p1`. Example rows:

```
n,shell,label,x,y,z
1,0,E,1.0,0.0,0.0
1,1,A,0.0,1.0,0.0
2,0,EE,0.0,0.0,0.0
3,0,EEE,0.0,0.0,0.0
```

**Row counts:** n=1 → 4, n=2 → 16, n=3 → 64 (**84 data rows** + header).

---

## Source

Coordinates must be extracted from the explicit Energiedoku construction for n=1,2,3, especially from:

- `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` (Energiedoku §8)
- Lean `EabcRenorm/ShellEmbedding.lean` — `cardinalShellEmbedding_one/two/three` (cardinal/lattice branch, not icosahedron variant)

**Source documentation in code:**

| Artefact | Path |
|---|---|
| CSV (Source of Truth) | [`docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv`](../energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv) |
| Loader / fallback rules | [`src/kepler_hurwitz/energiedoku_shell_construction.py`](../../src/kepler_hurwitz/energiedoku_shell_construction.py) |
| Lean reference constant | `ENERGIEDOKU_LEAN_REFERENCE = "EabcRenorm/ShellEmbedding.lean (cardinalShellEmbedding_*)"` |
| Regeneration helper | `export_energiedoku_coordinates_csv()` (code generation from Lean cardinal/lattice rules) |

**Embedding rules (n=1,2,3):**

- n=1: `cardinalDir(c)` → unit axes in R³
- n=2,3: lattice `(φ^{-n}) · classIndex(c_i)` per coordinate axis (E=0, A=1, B=2, C=3)

**Active source at runtime:** `coordinates_source()` → `csv:shell_coordinates_energiedoku_n1_n3.csv` when the file exists; fallback `code_generated_fallback` only if CSV is missing.

---

## Governance

The coordinate file is a baseline for model validation only.

It does not prove:

- MetricSeparationLossExist,
- global ℝ³-embedding,
- Minkowski–Bouligand dimension existence,
- first-loss index n₀,
- shellPrimeMatchAtFirstLoss.

It also does not justify any change to ι_n.

---

## Forbidden in this ticket

Do not:

- modify ι_n,
- tune the canonical embedding,
- tune ε_n,
- use prime indices,
- use EABC channel counts,
- search for ShellSeparationLoss(n),
- upgrade E-077–E-079 from [C] to [B].

---

## After the CSV exists

Run:

```bash
PYTHONPATH=src python scripts/compare_shell_embeddings.py --n-max 3
pytest tests/test_shell_embedding_comparison.py -q
```

Then inspect:

`docs/energiedoku_exports/shell_embedding_comparison_n1_n3.csv`

---

## Acceptance Criteria

- [x] **1.** `shell_coordinates_energiedoku_n1_n3.csv` exists at `docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv`
- [x] **2.** Coordinates for n=1,2,3 (4 + 16 + 64 = **84 data rows**)
- [x] **3.** Every row has fields `n,shell,label,x,y,z` (validated by `TestEnergiedokuCoordinatesCsv.test_csv_columns`)
- [x] **4.** Source documented (module docstring in `energiedoku_shell_construction.py`, Energiedoku §8, Lean `ShellEmbedding.lean`)
- [x] **5.** `compare_shell_embeddings.py` consumes CSV — runtime reports `Energiedoku coordinates source: csv:shell_coordinates_energiedoku_n1_n3.csv` (no toy/fallback)
- [x] **6.** No ι_n, ε_n, or prime-index logic changed in this ticket scope (CSV + loader only; theorematic rules unchanged)

---

## Verification evidence (2026-07-05)

| Check | Result |
|---|---|
| CSV path | `docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv` |
| Data rows | 84 (n=1: 4, n=2: 16, n=3: 64) |
| Schema | `n,shell,label,x,y,z` |
| `compare_shell_embeddings.py --n-max 3` | Exit 0; source `csv:shell_coordinates_energiedoku_n1_n3.csv` |
| `pytest tests/test_shell_embedding_comparison.py -q` | **19 passed** |
| Audit export | `docs/energiedoku_exports/shell_embedding_comparison_n1_n3.csv` — **3 data rows** (one per n, invariant geometry audit) |

---

## Principle

$$
\boxed{
\text{Daten kanonisieren}
\longrightarrow
\text{Invarianten prüfen}
\longrightarrow
\text{erst dann Theorie schärfen}
}
$$

**Next pipeline step (out of scope for this ticket):** ι_n audit for n ≥ 2 — see [`docs/reports/EMBEDDING_AUDIT_PIPELINE.md`](../reports/EMBEDDING_AUDIT_PIPELINE.md).

---

## Related

- Pipeline reference: [`docs/reports/EMBEDDING_AUDIT_PIPELINE.md`](../reports/EMBEDDING_AUDIT_PIPELINE.md)
- Comparison protocol: [`docs/reports/shell_embedding_comparison_protocol.md`](../reports/shell_embedding_comparison_protocol.md)
