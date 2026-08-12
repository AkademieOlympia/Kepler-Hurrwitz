"""
[A/B] ERPC 2+3+3-Hamiltonoperator — sektoraufgelöste 8-Komponenten-Kette.

Hilbertraum pro Site: H_x = C^2_EA ⊕ C^3_B ⊕ C^3_C (dim 8).
Finite Kette L Sites → dim 8L (z. B. L=36 → 288).

Governance:
  [A] Projektoren, Blockdimensionen, Hermitizitäts- und Summenidentitäten
  [B] konkrete H_EA, H_B, H_C, Kopplungsmatrizen, Ladungs-Kommutator-Audit

Protokoll:
  docs/energiedoku_exports/erpc_233_sector_transport_protocol.md (E-108)
  docs/energiedoku_exports/bamberg_d_int_coupling_protocol.md (E-110)
Lean: KeplerHurwitz/BambergInternalCoupling.lean
"""

from __future__ import annotations

import math
from dataclasses import asdict, dataclass, field
from typing import Any, Literal

import numpy as np

from kepler_hurwitz.eabc_graph_audit import CHI_ELEVEN, eabc_residue_at_site

GOVERNANCE_STRUCTURE = "[A]"
GOVERNANCE_MODEL = "[B]"
GOVERNANCE_CHARGE_AUDIT = "[B]"

NORB = 8
DIM_EA = 2
DIM_B = 3
DIM_C = 3
SECTOR_NAMES = ("EA", "B", "C")
SECTOR_SLICES = {
    "EA": slice(0, 2),
    "B": slice(2, 5),
    "C": slice(5, 8),
}

DEFAULT_CHARGE_AUDIT_THETAS = (0.1, 0.5, math.pi / 4, math.pi / 2)
CHARGE_AUDIT_ALLOWED_ATOL = 1e-14
CHARGE_AUDIT_VIOLATION_RTOL = 1e-2

SIGMA_Z = np.diag([1.0, -1.0])

# Normalisierte Minimal-Kopplungen (alle Einträge aktiv, Hermitizität via Konjugation)
K_EB = np.ones((DIM_EA, DIM_B), dtype=complex) / np.sqrt(DIM_EA * DIM_B)
K_EC = np.ones((DIM_EA, DIM_C), dtype=complex) / np.sqrt(DIM_EA * DIM_C)
K_BC = np.ones((DIM_B, DIM_C), dtype=complex) / np.sqrt(DIM_B * DIM_C)

CouplingClass = Literal["none", "ea_b_only", "ea_c_only", "ea_bc_symmetric"]


@dataclass(frozen=True)
class ERPC233Params:
    """Modellparameter für einen Lauf."""

    L: int = 36
    e0: float = 0.2
    a0: float = 0.5
    b0: float = 0.3
    c0: float = 0.1
    t0: float = 1.0
    delta: float = 0.0
    g_eb: float = 0.0
    g_ec: float = 0.0
    g_bc: float = 0.0

    def with_coupling_class(self, coupling_class: CouplingClass, g: float) -> ERPC233Params:
        """Setzt Kopplungsstärken gemäß Scan-Klasse."""
        if coupling_class == "none":
            return ERPC233Params(**{**asdict(self), "g_eb": 0.0, "g_ec": 0.0, "g_bc": 0.0})
        if coupling_class == "ea_b_only":
            return ERPC233Params(**{**asdict(self), "g_eb": g, "g_ec": 0.0, "g_bc": 0.0})
        if coupling_class == "ea_c_only":
            return ERPC233Params(**{**asdict(self), "g_eb": 0.0, "g_ec": g, "g_bc": 0.0})
        if coupling_class == "ea_bc_symmetric":
            return ERPC233Params(**{**asdict(self), "g_eb": g, "g_ec": g, "g_bc": 0.0})
        raise ValueError(f"unknown coupling_class {coupling_class!r}")


def chi_eleven_at_site(x: int) -> int:
    """χ₁₁-Wert am Site x (0-indexiert); 0 außerhalb EABC-Restklassen."""
    residue = eabc_residue_at_site(x)
    return 0 if residue is None else CHI_ELEVEN[residue]


def sector_projectors() -> dict[str, np.ndarray]:
    """Orthogonale 8×8-Sektorprojektoren P_EA, P_B, P_C."""
    p_ea = np.zeros((NORB, NORB), dtype=complex)
    p_b = np.zeros((NORB, NORB), dtype=complex)
    p_c = np.zeros((NORB, NORB), dtype=complex)
    p_ea[0:2, 0:2] = np.eye(2)
    p_b[2:5, 2:5] = np.eye(3)
    p_c[5:8, 5:8] = np.eye(3)
    return {"EA": p_ea, "B": p_b, "C": p_c}


def audit_projectors(atol_sum: float = 1e-14, atol_orth: float = 1e-14) -> dict[str, Any]:
    """[A] Prüft P_EA+P_B+P_C=I und P_i P_j = δ_ij P_i."""
    projectors = sector_projectors()
    p_sum = sum(projectors.values())
    sum_defect = float(np.linalg.norm(p_sum - np.eye(NORB), ord="fro"))
    orth_defects: dict[str, float] = {}
    names = list(SECTOR_NAMES)
    for i, ni in enumerate(names):
        for j, nj in enumerate(names):
            key = f"{ni}_{nj}"
            expected = projectors[ni] if i == j else np.zeros((NORB, NORB), dtype=complex)
            orth_defects[key] = float(np.linalg.norm(projectors[ni] @ projectors[nj] - expected, ord="fro"))
    max_orth = max(orth_defects.values()) if orth_defects else 0.0
    return {
        "sum_defect_fro": sum_defect,
        "max_orth_defect_fro": max_orth,
        "orth_defects": orth_defects,
        "passed_sum": sum_defect <= atol_sum,
        "passed_orth": max_orth <= atol_orth,
        "passed": sum_defect <= atol_sum and max_orth <= atol_orth,
    }


def onsite_block(x: int, params: ERPC233Params) -> np.ndarray:
    """
    [B] 8×8 Onsite-Block H_x.

    H_EA(x) = diag(e0,a0) + δ χ₁₁(x) σ_z
    H_B = b0 I_3, H_C = c0 I_3
    Off-Diagonal: g_EB K_EB, g_EC K_EC, g_BC K_BC
    """
    h = np.zeros((NORB, NORB), dtype=complex)
    chi = chi_eleven_at_site(x)
    h_ea = np.diag([params.e0, params.a0]) + params.delta * chi * SIGMA_Z
    h[0:2, 0:2] = h_ea
    h[2:5, 2:5] = params.b0 * np.eye(DIM_B)
    h[5:8, 5:8] = params.c0 * np.eye(DIM_C)
    if params.g_eb:
        h[0:2, 2:5] = params.g_eb * K_EB
        h[2:5, 0:2] = params.g_eb * K_EB.conj().T
    if params.g_ec:
        h[0:2, 5:8] = params.g_ec * K_EC
        h[5:8, 0:2] = params.g_ec * K_EC.conj().T
    if params.g_bc:
        h[2:5, 5:8] = params.g_bc * K_BC
        h[5:8, 2:5] = params.g_bc * K_BC.conj().T
    return h


def lead_onsite_block(params: ERPC233Params) -> np.ndarray:
    """Blockdiagonaler Lead-Onsite (keine χ₁₁-Modulation, keine Inter-Sektor-Kopplung)."""
    h = np.zeros((NORB, NORB), dtype=complex)
    h[0:2, 0:2] = np.diag([params.e0, params.a0])
    h[2:5, 2:5] = params.b0 * np.eye(DIM_B)
    h[5:8, 5:8] = params.c0 * np.eye(DIM_C)
    return h


def build_finite_hamiltonian(params: ERPC233Params) -> np.ndarray:
    """Geschlossene 8L×8L-Matrix (ohne Leads) für Audits."""
    l_dim = params.L * NORB
    h = np.zeros((l_dim, l_dim), dtype=complex)
    for x in range(params.L):
        sl = slice(x * NORB, (x + 1) * NORB)
        h[sl, sl] = onsite_block(x, params)
    hop = -params.t0 * np.eye(NORB)
    for x in range(params.L - 1):
        sl0 = slice(x * NORB, (x + 1) * NORB)
        sl1 = slice((x + 1) * NORB, (x + 2) * NORB)
        h[sl0, sl1] = hop
        h[sl1, sl0] = hop
    return h


def audit_hermiticity(params: ERPC233Params, atol: float = 1e-12) -> dict[str, Any]:
    """‖H - H†‖_F ≤ atol."""
    h = build_finite_hamiltonian(params)
    defect = float(np.linalg.norm(h - h.conj().T, ord="fro"))
    return {"hermiticity_defect_fro": defect, "passed": defect <= atol}


def sector_weights(state: np.ndarray) -> dict[str, float]:
    """w_X = ⟨ψ|P_X|ψ⟩ für normalisierten oder unnormierten Zustand."""
    psi = np.asarray(state, dtype=complex).reshape(-1)
    projectors = sector_projectors()
    weights = {name: float(np.real(np.vdot(psi, projectors[name] @ psi))) for name in SECTOR_NAMES}
    norm = sum(weights.values())
    if norm > 0:
        weights = {k: v / norm for k, v in weights.items()}
    return weights


def is_block_diagonal(params: ERPC233Params, atol: float = 1e-12) -> bool:
    """True wenn alle Inter-Sektor-Kopplungen null sind."""
    return abs(params.g_eb) <= atol and abs(params.g_ec) <= atol and abs(params.g_bc) <= atol


def global_sector_projector(params: ERPC233Params, sector: str) -> np.ndarray:
    """P_X^{(L)} = I_L ⊗ P_X auf dem geschlossenen 8L-Raum."""
    if sector not in SECTOR_NAMES:
        raise ValueError(f"unknown sector {sector!r}")
    return np.kron(np.eye(params.L), sector_projectors()[sector])


def sector_commutator_defect(
    params: ERPC233Params,
    sector: str,
    *,
    atol: float = 1e-12,
) -> dict[str, float | bool]:
    """
    D_X^{bulk} = ||[H, P_X^{(L)}]||_F / ||H||_F für die geschlossene Bulk-Kette.
    """
    h = build_finite_hamiltonian(params)
    h_norm = float(np.linalg.norm(h, ord="fro"))
    pg = global_sector_projector(params, sector)
    comm = h @ pg - pg @ h
    defect = float(np.linalg.norm(comm, ord="fro"))
    rel = defect / max(h_norm, 1e-15)
    return {
        "sector": sector,
        "commutator_fro": defect,
        "relative_defect": rel,
        "passed": rel <= atol,
    }


def lead_commutator_defects(
    params: ERPC233Params,
    *,
    atol: float = 1e-12,
) -> dict[str, dict[str, float | bool]]:
    """D_{X,lead} = ||[H_lead, P_X]||_F / ||H_lead||_F für blockdiagonalen Lead-Onsite."""
    h_lead = lead_onsite_block(params)
    h_norm = float(np.linalg.norm(h_lead, ord="fro"))
    projectors = sector_projectors()
    out: dict[str, dict[str, float | bool]] = {}
    for name in SECTOR_NAMES:
        comm = h_lead @ projectors[name] - projectors[name] @ h_lead
        defect = float(np.linalg.norm(comm, ord="fro"))
        rel = defect / max(h_norm, 1e-15)
        out[name] = {
            "commutator_fro": defect,
            "relative_defect": rel,
            "passed": rel <= atol,
        }
    return out


def bulk_sector_commutator_audit(
    params: ERPC233Params,
    *,
    atol: float = 1e-12,
) -> dict[str, Any]:
    """Alle Bulk-Sektor-Kommutatoren."""
    sectors = {name: sector_commutator_defect(params, name, atol=atol) for name in SECTOR_NAMES}
    return {
        "sectors": sectors,
        "passed_all": all(v["passed"] for v in sectors.values()),
    }


def expected_decoupled_sectors(params: ERPC233Params, atol: float = 1e-12) -> set[str]:
    """
    Sektoren X mit [H,P_X]≈0 (symmetrisch erhalten), abgeleitet aus aktiven Kopplungen.

    none: alle drei; ea_b_only: C; ea_c_only: B; ea_bc_symmetric: keine.
    """
    if is_block_diagonal(params, atol):
        return set(SECTOR_NAMES)
    decoupled: set[str] = set()
    if abs(params.g_ec) <= atol and abs(params.g_bc) <= atol:
        decoupled.add("C")
    if abs(params.g_eb) <= atol and abs(params.g_bc) <= atol:
        decoupled.add("B")
    return decoupled


def forbidden_transmission_pairs(
    params: ERPC233Params,
    atol: float = 1e-12,
) -> list[tuple[str, str]]:
    """
    Kanalpaare (X_in, Y_out), die bei erhaltenem Sektor X bzw. Y null sein müssen.

    Wenn [H,P_C]=0: jede Transmission, die C als Quelle oder Senke involviert, ist verboten
    (X→C und C→Y für alle X,Y).
    """
    forbidden: list[tuple[str, str]] = []
    for sector in expected_decoupled_sectors(params, atol):
        idx = SECTOR_NAMES.index(sector)
        for x in range(3):
            if x != idx:
                forbidden.append((SECTOR_NAMES[x], sector))  # X → preserved sector
            forbidden.append((sector, SECTOR_NAMES[x]))  # preserved sector → X
    # dedupe
    return sorted(set(forbidden))


@dataclass(frozen=True)
class IntChargeConfig:
    """Ganzzahlige U(1)-Ladungen der internen 2+3+3-Sektoren (Lean: IntChargeConfig)."""

    q_ea: int = 0
    q_b: int = 0
    q_c: int = 0

    def sector_charge(self, sector: str) -> int:
        if sector == "EA":
            return self.q_ea
        if sector == "B":
            return self.q_b
        if sector == "C":
            return self.q_c
        raise ValueError(f"unknown sector {sector!r}")

    @classmethod
    def neutral(cls) -> IntChargeConfig:
        return cls(0, 0, 0)

    def as_tuple(self) -> tuple[int, int, int]:
        return (self.q_ea, self.q_b, self.q_c)


def off_diagonal_coupling_allowed(q: IntChargeConfig, source: str, target: str) -> bool:
    """[A]-Spiegel: Kopplung erlaubt iff q_source = q_target (Diagonal immer erlaubt)."""
    if source == target:
        return True
    return q.sector_charge(source) == q.sector_charge(target)


def _random_complex_block(
    rows: int,
    cols: int,
    rng: np.random.Generator,
    *,
    hermitian: bool = False,
) -> np.ndarray:
    real = rng.standard_normal((rows, cols))
    imag = rng.standard_normal((rows, cols))
    block = real + 1j * imag
    if hermitian:
        if rows != cols:
            raise ValueError("hermitian blocks must be square")
        block = 0.5 * (block + block.conj().T)
    return block


def build_d_int(
    d_ea: np.ndarray,
    m_b: np.ndarray,
    m_c: np.ndarray,
    y_b: np.ndarray,
    y_c: np.ndarray,
    k_bc: np.ndarray,
) -> np.ndarray:
    """
    [B] 8×8 hermitesche Kopplungsmatrix D_int aus sechs Blöcken.

    D_int = [ D_EA     Y_B^†   Y_C^† ]
            [ Y_B      M_B     K     ]
            [ Y_C      K^†     M_C   ]
    """
    row1 = np.block([d_ea, y_b.conj().T, y_c.conj().T])
    row2 = np.block([y_b, m_b, k_bc])
    row3 = np.block([y_c, k_bc.conj().T, m_c])
    return np.block([[row1], [row2], [row3]])


def build_internal_gauge_matrix(theta: float, q: IntChargeConfig) -> np.ndarray:
    """Unitäre blockdiagonale U(1)-Eichmatrix G_g^int auf C^8."""
    g_ea = np.exp(1j * q.q_ea * theta) * np.eye(DIM_EA)
    g_b = np.exp(1j * q.q_b * theta) * np.eye(DIM_B)
    g_c = np.exp(1j * q.q_c * theta) * np.eye(DIM_C)
    g = np.zeros((NORB, NORB), dtype=complex)
    g[SECTOR_SLICES["EA"], SECTOR_SLICES["EA"]] = g_ea
    g[SECTOR_SLICES["B"], SECTOR_SLICES["B"]] = g_b
    g[SECTOR_SLICES["C"], SECTOR_SLICES["C"]] = g_c
    return g


def frobenius_commutator_norm(left: np.ndarray, right: np.ndarray) -> float:
    """‖[left, right]‖_F."""
    comm = left @ right - right @ left
    return float(np.linalg.norm(comm, ord="fro"))


def random_d_int_blocks(
    q: IntChargeConfig,
    rng: np.random.Generator,
    *,
    include_violations: bool = False,
) -> dict[str, np.ndarray]:
    """
    Zufällige D_int-Blöcke unter Ladungserhaltung.

    Mit include_violations=True werden zusätzlich nicht-erlaubte Off-Diagonal-Blöcke
    mit zufälligen Nicht-Null-Matrizen befüllt (Gegen-Audit).
    """
    d_ea = _random_complex_block(DIM_EA, DIM_EA, rng, hermitian=True)
    m_b = _random_complex_block(DIM_B, DIM_B, rng, hermitian=True)
    m_c = _random_complex_block(DIM_C, DIM_C, rng, hermitian=True)

    y_b = (
        _random_complex_block(DIM_B, DIM_EA, rng)
        if off_diagonal_coupling_allowed(q, "B", "EA")
        else np.zeros((DIM_B, DIM_EA), dtype=complex)
    )
    y_c = (
        _random_complex_block(DIM_C, DIM_EA, rng)
        if off_diagonal_coupling_allowed(q, "C", "EA")
        else np.zeros((DIM_C, DIM_EA), dtype=complex)
    )
    k_bc = (
        _random_complex_block(DIM_B, DIM_C, rng)
        if off_diagonal_coupling_allowed(q, "B", "C")
        else np.zeros((DIM_B, DIM_C), dtype=complex)
    )

    if include_violations:
        if not off_diagonal_coupling_allowed(q, "B", "EA"):
            y_b = y_b + _random_complex_block(DIM_B, DIM_EA, rng)
        if not off_diagonal_coupling_allowed(q, "C", "EA"):
            y_c = y_c + _random_complex_block(DIM_C, DIM_EA, rng)
        if not off_diagonal_coupling_allowed(q, "B", "C"):
            k_bc = k_bc + _random_complex_block(DIM_B, DIM_C, rng)

    return {
        "d_ea": d_ea,
        "m_b": m_b,
        "m_c": m_c,
        "y_b": y_b,
        "y_c": y_c,
        "k_bc": k_bc,
    }


@dataclass(frozen=True)
class ChargeAuditScenario:
    """Vordefiniertes Audit-Szenario für E-110."""

    name: str
    description: str
    charge: IntChargeConfig


CHARGE_AUDIT_SCENARIOS: tuple[ChargeAuditScenario, ...] = (
    ChargeAuditScenario(
        "A_neutral",
        "Neutraler Startfall (alle Kopplungen erlaubt)",
        IntChargeConfig.neutral(),
    ),
    ChargeAuditScenario(
        "B_partial",
        "Teilladung (q_C isoliert, EA und B gekoppelt)",
        IntChargeConfig(1, 1, -2),
    ),
    ChargeAuditScenario(
        "C_full",
        "Vollladung (vollständige gegenseitige Sektorisolierung)",
        IntChargeConfig(1, 2, 3),
    ),
)


@dataclass
class ChargeAuditResult:
    """Ergebnis eines Ladungs-Kommutator-Audits."""

    scenario: str
    description: str
    charge: IntChargeConfig
    max_comm_allowed: float
    max_comm_violating: float | None
    allowed_passed: bool
    violation_passed: bool | None
    thetas: tuple[float, ...] = field(default_factory=lambda: DEFAULT_CHARGE_AUDIT_THETAS)
    seed: int = 0

    def to_dict(self) -> dict[str, Any]:
        return {
            "scenario": self.scenario,
            "description": self.description,
            "charge": self.charge.as_tuple(),
            "max_comm_allowed": self.max_comm_allowed,
            "max_comm_violating": self.max_comm_violating,
            "allowed_passed": self.allowed_passed,
            "violation_passed": self.violation_passed,
            "thetas": list(self.thetas),
            "seed": self.seed,
            "passed": self.allowed_passed and (self.violation_passed is not False),
        }


def _has_charge_mismatch(q: IntChargeConfig) -> bool:
    return q.q_ea != q.q_b or q.q_ea != q.q_c or q.q_b != q.q_c


def audit_charge_commutator(
    q: IntChargeConfig,
    *,
    seed: int = 0,
    thetas: tuple[float, ...] = DEFAULT_CHARGE_AUDIT_THETAS,
    allowed_atol: float = CHARGE_AUDIT_ALLOWED_ATOL,
    violation_rtol: float = CHARGE_AUDIT_VIOLATION_RTOL,
) -> dict[str, float | bool | None]:
    """
    [B] Frobenius-Kommutator-Audit ‖[G_g, D_int]‖_F für ladungserhaltende vs. verletzende Blöcke.

    Entspricht den Lean-Lemmas `offDiagonalCouplingAllowed` und `neutral_internalGaugeMatrix`.
    """
    rng = np.random.default_rng(seed)
    allowed_blocks = random_d_int_blocks(q, rng, include_violations=False)
    d_int_allowed = build_d_int(**allowed_blocks)

    max_comm_allowed = 0.0
    max_comm_violating: float | None = None
    violation_passed: bool | None = None

    for theta in thetas:
        g = build_internal_gauge_matrix(theta, q)
        max_comm_allowed = max(max_comm_allowed, frobenius_commutator_norm(g, d_int_allowed))

    if _has_charge_mismatch(q):
        rng_viol = np.random.default_rng(seed + 1)
        violating_blocks = random_d_int_blocks(q, rng_viol, include_violations=True)
        d_int_violating = build_d_int(**violating_blocks)
        max_comm_violating = 0.0
        for theta in thetas:
            g = build_internal_gauge_matrix(theta, q)
            max_comm_violating = max(
                max_comm_violating,
                frobenius_commutator_norm(g, d_int_violating),
            )
        violation_passed = max_comm_violating > violation_rtol

    return {
        "max_comm_allowed": max_comm_allowed,
        "max_comm_violating": max_comm_violating,
        "allowed_passed": max_comm_allowed <= allowed_atol,
        "violation_passed": violation_passed,
    }


def run_charge_audit(
    scenario: ChargeAuditScenario,
    *,
    seed: int = 0,
    thetas: tuple[float, ...] = DEFAULT_CHARGE_AUDIT_THETAS,
    allowed_atol: float = CHARGE_AUDIT_ALLOWED_ATOL,
    violation_rtol: float = CHARGE_AUDIT_VIOLATION_RTOL,
) -> ChargeAuditResult:
    """Führt ein vollständiges Ladungs-Audit für ein Szenario durch."""
    metrics = audit_charge_commutator(
        scenario.charge,
        seed=seed,
        thetas=thetas,
        allowed_atol=allowed_atol,
        violation_rtol=violation_rtol,
    )
    return ChargeAuditResult(
        scenario=scenario.name,
        description=scenario.description,
        charge=scenario.charge,
        max_comm_allowed=float(metrics["max_comm_allowed"]),
        max_comm_violating=(
            None if metrics["max_comm_violating"] is None else float(metrics["max_comm_violating"])
        ),
        allowed_passed=bool(metrics["allowed_passed"]),
        violation_passed=(
            None if metrics["violation_passed"] is None else bool(metrics["violation_passed"])
        ),
        thetas=thetas,
        seed=seed,
    )


def run_standard_charge_audits(
    *,
    seed: int = 0,
    thetas: tuple[float, ...] = DEFAULT_CHARGE_AUDIT_THETAS,
) -> list[ChargeAuditResult]:
    """Alle drei E-110-Standardszenarien."""
    return [run_charge_audit(scenario, seed=seed, thetas=thetas) for scenario in CHARGE_AUDIT_SCENARIOS]


def format_charge_audit_report(result: ChargeAuditResult) -> str:
    """Textreport für CLI/Notebook."""
    q = result.charge
    lines = [
        "=" * 80,
        f"AUDIT: {result.description}",
        f"Ladungs-Konfiguration: q_EA = {q.q_ea}, q_B = {q.q_b}, q_C = {q.q_c}",
        "-" * 80,
        f"Max. Frobenius-Kommutator (erlaubte Kopplung):  {result.max_comm_allowed:.2e}",
    ]
    if result.allowed_passed:
        lines.append(" -> Symmetriebedingung [G_g, D_int] = 0: BESTANDEN (Kovarianz geschützt)")
    else:
        lines.append(" -> Symmetriebedingung [G_g, D_int] = 0: FEHLGESCHLAGEN!")
    if result.max_comm_violating is None:
        lines.append(" -> Gegen-Audit übersprungen (Neutraler Fall: alle Kopplungen sind legal)")
    else:
        lines.append(
            f"Max. Frobenius-Kommutator (verbotene Kopplung): {result.max_comm_violating:.2e}"
        )
        if result.violation_passed:
            lines.append(" -> Gegen-Audit (Symmetriebrechung detektiert): BESTANDEN")
        else:
            lines.append(" -> Gegen-Audit: FEHLGESCHLAGEN!")
    lines.append("=" * 80)
    return "\n".join(lines)

