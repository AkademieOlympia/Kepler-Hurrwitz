# Phaseninvarianz — Pauli-Energie-Brücke (E-094, PI-C-01)

**Status:** `[C]` interpretive scaffold with `[A/B]` invariance facts  
**Register:** E-094 · **ORQ:** ORQ-094  
**Claim:** PI-C-01  
**Code:** `src/kepler_hurwitz/phaseninvarianz_pauli_energy.py`  
**Sage:** `scripts/phaseninvarianz/pauli_energy_invariance.sage`

---

## 1. Energetische Norm (BH-C-11)

From `eabc_energy_square_sum.py`:

| Kanal | Energie | Grad |
|---|---|---|
| Vektor \(a\) | \(E_a = a_x^2 + a_y^2\) | quadratisch |
| Bivektor \(bc\) | \(E_{bc} = (b_x^2+b_y^2)(c_x^2+c_y^2)\) | quartisch |

Each axis carries two orthogonal amplitude degrees of freedom \((v_x, v_y)\).

---

## 2. Pauli on amplitude pairs

| Op | Action on \((v_x, v_y)\) | \(E_{\mathrm{pair}} = v_x^2+v_y^2\) |
|---|---|---|
| I | identity | invariant |
| X | \(v_x \leftrightarrow v_y\) | invariant (swap) |
| Z | \(v_y \to -v_y\) | invariant (square kills sign) |
| Y | \(v_x \to -v_y,\; v_y \to v_x\) | invariant: \((-v_y)^2+v_x^2\) |

---

## 3. PI-C-01 tests

### 3.1 a-axis protection `[A/B]`

Pauli Z (\(a_x \to -a_x\)) and Pauli X (\(a_x \leftrightarrow a_y\)) leave \(E_a\) unchanged.

### 3.2 bc-axis partial tensor-X vulnerability `[A/B]`

The **cross-field** error swapping \(b_x \leftrightarrow c_x\) (leaving \(b_y, c_y\)) restructures quartic cross terms:

\[
E_{bc} = b_x^2 c_x^2 + b_x^2 c_y^2 + b_y^2 c_x^2 + b_y^2 c_y^2
\]

After partial swap: \(b_x' = c_x,\; c_x' = b_x\). Invariance requires \((b_y^2 - c_y^2)(c_x^2 - b_x^2) = 0\).

**Generic amplitudes:** not invariant. Symmetric special cases (\(b_x=c_x\) or \(b_y=c_y\)) are invariant.

### 3.3 QEC reading `[C]`

The \(a\)-axis quadratic channel enjoys phase/bit-flip protection. The \(bc\) bivector quartic channel is vulnerable to **cross-field** Pauli errors and, in the interpretive reading, requires full `[[5,1,3]]` QEC grammar (E-044, BH-C-09).

---

## 4. Governance — not_claimed

- Primzahlen sind physisch QEC-stabilisiert
- Pauli-Operatoren = QM-Hilbertraum-Identität
- \(L(s,\chi_{-3})\) implementiert den Five-Qubit-Code
- Phaseninvarianz allein erklärt Twin-Prime-Struktur

---

## 5. Sibling: PI-C-02

See [`phaseninvarianz_tensor_invariant_subspace.md`](phaseninvarianz_tensor_invariant_subspace.md) for the **15 tensor products** \(P_b \otimes P_c\) acting on **separate** amplitude pairs. Full 15/15 invariance of \(E_{bc}\) under per-pair Pauli is algebraic and distinct from the partial cross-field error above.

---

## Artefakte

| Artefakt | Pfad |
|---|---|
| Python | `src/kepler_hurwitz/phaseninvarianz_pauli_energy.py` |
| Tensor subspace | `src/kepler_hurwitz/phaseninvarianz_tensor_invariants.py` |
| Export | `docs/exports/phaseninvarianz_pauli_energy.json` |
| Claim register | `docs/phaseninvarianz/claim_register.md` |
