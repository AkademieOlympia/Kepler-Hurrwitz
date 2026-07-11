import math

import pytest

from kepler_hurwitz.diagnostics import (
    ATLAS_PRIMARY_FUNCTIONS,
    bad_run_cost,
    bad_run_cost_from_n,
    channel_entropy,
    chirality_norm,
    collatz_net_descent_diagnostics,
    distill_primvierling,
    net_descent_margin,
    norm_signature_defect,
    norm_signature_defect_from_primvierling,
    primvierling_product,
    prime_grid_compression,
    projection_loss,
    shrink_efficiency,
)
from kepler_hurwitz.primvierling import quat_norm
from kepler_hurwitz.signatures import eabc_mass, signature_from_nat


class TestDiagnosticsAtlas:
    def test_atlas_primary_functions_exactly_eight(self):
        assert len(ATLAS_PRIMARY_FUNCTIONS) == 8
        assert ATLAS_PRIMARY_FUNCTIONS == (
            "net_descent_margin",
            "bad_run_cost",
            "shrink_efficiency",
            "channel_entropy",
            "prime_grid_compression",
            "norm_signature_defect",
            "projection_loss",
            "chirality_norm",
        )

    def test_channel_entropy_isotropic(self):
        assert channel_entropy((1, 1, 1, 1)) == math.log(4)

    def test_channel_entropy_degenerate(self):
        assert channel_entropy((4, 0, 0, 0)) == 0

    def test_channel_entropy_zero_mass(self):
        assert channel_entropy((0, 0, 0, 0)) == 0

    def test_channel_entropy_rejects_negative(self):
        with pytest.raises(ValueError):
            channel_entropy((-1, 1, 1, 1))

    def test_channel_entropy_rejects_wrong_length(self):
        with pytest.raises(ValueError):
            channel_entropy((1, 1, 1))

    def test_prime_grid_compression(self):
        assert prime_grid_compression(4, 6) == pytest.approx(2 / 3)

    def test_prime_grid_compression_rejects_zero_omega(self):
        with pytest.raises(ValueError):
            prime_grid_compression(4, 0)

    def test_prime_grid_compression_rejects_negative_mass(self):
        with pytest.raises(ValueError):
            prime_grid_compression(-1, 6)

    def test_norm_signature_defect(self):
        assert norm_signature_defect((1, 1, 1, 1), (1, 0, 1, 0)) == 2

    def test_norm_signature_defect_rejects_negative(self):
        with pytest.raises(ValueError):
            norm_signature_defect((1, -1, 1, 1), (1, 0, 1, 0))

    def test_norm_signature_defect_rejects_wrong_length(self):
        with pytest.raises(ValueError):
            norm_signature_defect((1, 1, 1), (1, 0, 1, 0))

    def test_projection_loss(self):
        assert projection_loss(5, 3) == 2

    def test_projection_loss_rejects_invalid_order(self):
        with pytest.raises(ValueError):
            projection_loss(3, 5)

    def test_projection_loss_rejects_negative(self):
        with pytest.raises(ValueError):
            projection_loss(-1, 0)

    def test_chirality_norm(self):
        assert chirality_norm(3, 4, 12) == pytest.approx(13.0)

    def test_net_descent_margin(self):
        assert net_descent_margin(27, 20) == 7

    def test_net_descent_margin_rejects_negative_n(self):
        with pytest.raises(ValueError):
            net_descent_margin(-1, 5)

    def test_net_descent_margin_rejects_negative_descended_value(self):
        with pytest.raises(ValueError):
            net_descent_margin(27, -1)

    def test_bad_run_cost(self):
        assert bad_run_cost(5) == 5

    def test_bad_run_cost_rejects_negative(self):
        with pytest.raises(ValueError):
            bad_run_cost(-1)

    def test_shrink_efficiency(self):
        assert shrink_efficiency(12, 3) == pytest.approx(3.0)

    def test_shrink_efficiency_rejects_negative_cost(self):
        with pytest.raises(ValueError):
            shrink_efficiency(12, -1)

    def test_primvierling_example(self):
        """v=(5,7,11,13): P=5005, H(P)=(1,1,1,1), N(gamma_v)=364, delta_H=2."""
        v = (5, 7, 11, 13)
        assert primvierling_product(v) == 5005
        assert quat_norm(v) == 364
        assert signature_from_nat(quat_norm(v)).as_tuple() == (1, 0, 1, 0)
        assert norm_signature_defect_from_primvierling(v) == 2
        record = distill_primvierling(v)
        assert record.norm == 364
        assert record.norm_signature_defect == 2
        assert record.product_signature == (1, 1, 1, 1)
        assert record.norm_signature == (1, 0, 1, 0)
        assert record.projection_loss == 2
        assert eabc_mass(primvierling_product(v)) == 4

    def test_collatz_diagnostics_consistent_with_atlas(self):
        n, t_loc = 27, 3
        diag = collatz_net_descent_diagnostics(n, t_loc)
        descended = n - diag.net_descent_margin
        assert net_descent_margin(n, descended) == diag.net_descent_margin
        assert bad_run_cost_from_n(n) == diag.bad_run_cost
        assert bad_run_cost(diag.t_good) == diag.bad_run_cost
        assert shrink_efficiency(diag.net_descent_margin, diag.bad_run_cost) == pytest.approx(
            diag.shrink_efficiency
        )
