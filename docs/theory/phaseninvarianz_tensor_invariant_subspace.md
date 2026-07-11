# Phaseninvarianz — Pauli-Tensor-Invarianten-Teilraum (E-094, PI-C-02)

**Status:** `[A/B]` algebraische Invarianz + `[C]` Eigenzustands-Lesesprache  
**Register:** E-094 · **ORQ:** ORQ-094  
**Claim:** PI-C-02  
**Code:** `src/kepler_hurwitz/phaseninvarianz_tensor_invariants.py`  
**Sage:** `scripts/phaseninvarianz/pauli_tensor_invariant_subspace.sage`

---

## 1. Zwei-Qubit-Amplitudenraum

Model two independent amplitude pairs:

- **b-pair:** \((b_x, b_y)\)
- **c-pair:** \((c_x, c_y)\)

Tensor Pauli operators \(P_b \otimes P_c\) act **separately** on each pair (not cross-field).

There are \(4 \times 4 - 1 = 15\) non-trivial tensor strings (excluding \(II\)):

\[
\{IX, IY, IZ, XI, XX, XY, XZ, YI, YX, YY, YZ, ZI, ZX, ZY, ZZ\}
\]

---

## 2. Quartic bc energy

\[
E_{bc} = E_b \cdot E_c, \qquad
E_b = b_x^2 + b_y^2, \quad E_c = c_x^2 + c_y^2
\]

---

## 3. Single-pair invariance `[A/B]`

For any amplitude pair \((v_x, v_y)\) and Pauli \(P \in \{I,X,Y,Z\}\):

\[
E_{\mathrm{pair}} = v_x^2 + v_y^2 \quad \Longrightarrow \quad P(E_{\mathrm{pair}}) = E_{\mathrm{pair}}
\]

**Proof sketch:**

| \(P\) | Transform | Squared sum |
|---|---|---|
| I | \((v_x, v_y)\) | \(v_x^2+v_y^2\) |
| X | \((v_y, v_x)\) | \(v_y^2+v_x^2\) |
| Z | \((v_x, -v_y)\) | \(v_x^2+v_y^2\) |
| Y | \((-v_y, v_x)\) | \(v_y^2+v_x^2\) |

---

## 4. Full 15/15 tensor invariance `[A/B]`

If \(P_b\) preserves \(E_b\) and \(P_c\) preserves \(E_c\), then

\[
(P_b \otimes P_c)(E_{bc}) = (P_b E_b)(P_c E_c) = E_b E_c = E_{bc}.
\]

Since **all four** single-qubit Paulis preserve each quadratic factor, **all 15** non-trivial tensor products preserve \(E_{bc}\).

**Result:** `invariant_count = 15/15` at generic amplitudes.

This includes all pure Z and X combinations (as expected from squaring) and also all Y combinations.

---

## 5. Eigenstate interpretation `[C]`

In stabilizer/QEC language, an operator \(S\) with \(S|\psi\rangle = |\psi\rangle\) defines an eigenstate subspace. Here the **energy functional** plays the role of the observable:

\[
S(E_{bc}) = E_{bc} \quad \text{under all 15 tensor Paulis.}
\]

**Physical consequence (Lesesprache):** The bc quartic energy density is algebraically blind to local Pauli frame changes on each amplitude pair. This is **not** a quantum error-correction miracle — it follows from squaring amplitudes. It does **not** contradict PI-C-01: cross-field errors (\(b_x \leftrightarrow c_x\)) that mix the two pairs still break \(E_{bc}\).

---

## 6. Distinction from PI-C-01 partial tensor-X

| Error type | Action | \(E_{bc}\) invariant? |
|---|---|---|
| Per-pair tensor \(P_b \otimes P_c\) | Pauli on \((b_x,b_y)\) and \((c_x,c_y)\) separately | **Yes** (all 15) |
| Partial cross-field X | \(b_x \leftrightarrow c_x\) only | **No** (generic) |

The 15/15 result strengthens the **local** robustness reading but does not replace full `[[5,1,3]]` protection against **conjugate-channel** mixing (BH-C-09).

---

## 7. Governance — not_claimed

- Full 15/15 invariance means primes need no QEC
- Tensor eigenstate = physical quantum eigenstate
- Replacement of `[[5,1,3]]` grammar on bc channel
- Confusion with partial \(b_x \leftrightarrow c_x\) swap

---

## 8. Artefakte

| Artefakt | Pfad |
|---|---|
| Python | `src/kepler_hurwitz/phaseninvarianz_tensor_invariants.py` |
| Tests | `tests/test_phaseninvarianz_tensor_invariants.py` |
| Export | `docs/exports/phaseninvarianz_tensor_invariants.json` |
| Claim | `docs/phaseninvarianz/claim_register.md` → PI-C-02 |

```bash
PYTHONPATH=src python examples/run_phaseninvarianz_tensor_invariants_export.py
pytest tests/test_phaseninvarianz_tensor_invariants.py -q
sage scripts/phaseninvarianz/pauli_tensor_invariant_subspace.sage
```
