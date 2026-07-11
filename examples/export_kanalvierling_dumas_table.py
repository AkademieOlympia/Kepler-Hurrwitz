"""Export Kanalvierlinge (EABC channel-bucket quadruples) with Dumas table columns."""

from __future__ import annotations

import argparse
import csv
import sys
from math import isqrt
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports" / "kanalvierling_dumas_200.csv"
DEFAULT_PRIME_COUNT = 200
sys.path.insert(0, str(SRC))

from kepler_hurwitz.dumas_natural_fill import (  # noqa: E402
    HOST_CHANNEL_ORDER,
    build_dumas_natural_fill,
    host_component,
    host_for_quadruplet_index,
    host_triple,
    host_triple_gap_pair,
    natural_fill_index_gaps,
    rotor_d_artagnan_offset,
    sorted_gap_pair,
    verify_dumas_lemma,
)
from kepler_hurwitz.eabc_rising_collection import (  # noqa: E402
    EABCRisingQuadruple,
    partition_eabc_quadruples_by_channels,
    prime_eabc_channel,
    summarize_partition,
)
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel  # noqa: E402
from kepler_hurwitz.primvierling import Primvierling, pair_gaps, quat_norm  # noqa: E402


def kanalvierling_to_primvierling(quad: EABCRisingQuadruple) -> Primvierling:
    """Map sorted EABC quadruple to Primvierling ``(A, B, C, E)`` by channel."""
    mapping = {prime_eabc_channel(p): p for p in quad.primes}
    return (
        mapping[EABCChannel.A],
        mapping[EABCChannel.B],
        mapping[EABCChannel.C],
        mapping[EABCChannel.E],
    )


def format_tuple(values: tuple[int, ...]) -> str:
    inner = ", ".join(str(value) for value in values)
    return f"({inner})"


def kanalvierling_dumas_records(
    quadruples: list[EABCRisingQuadruple],
) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for quad in quadruples:
        v = kanalvierling_to_primvierling(quad)
        a, b, c, e = v
        fill = build_dumas_natural_fill(v)
        verify_ok = verify_dumas_lemma(v)
        missing = natural_fill_index_gaps(fill)
        rotor_host = host_for_quadruplet_index(quad.index)
        rotor_triple = host_triple(rotor_host, v)
        rotor_d1, rotor_d2 = sorted_gap_pair(rotor_triple)
        expected_rotor = host_triple_gap_pair(rotor_host)
        d_artagnan = host_component(rotor_host, v)
        canonical_rotor_d = a + rotor_d_artagnan_offset(rotor_host)

        row: dict[str, object] = {
            "index": quad.index,
            "prime_count_scope": "",
            "v_abcE": format_tuple(v),
            "p_anchor": a,
            "A": a,
            "B": b,
            "C": c,
            "E": e,
            "p1_sorted": quad.p1,
            "p2_sorted": quad.p2,
            "p3_sorted": quad.p3,
            "p4_sorted": quad.p4,
            "channels_sorted": ",".join(ch.value for ch in quad.channels),
            "span": quad.span,
            "gaps_sorted": ",".join(str(g) for g in quad.gaps),
            "canonical_primquadruplet": quad.canonical,
            "quat_norm": quat_norm(v),
            "sqrt_norm": isqrt(quat_norm(v)),
            "pair_gaps": pair_gaps(v),
            "host_E": fill.host_components["E"],
            "host_A": fill.host_components["A"],
            "host_B": fill.host_components["B"],
            "host_C": fill.host_components["C"],
            "verify_dumas_lemma": verify_ok,
            "natural_fill_gaps": ",".join(str(i) for i in missing),
            "natural_fill_gap_free": len(missing) == 0,
            "triple_slot_primes": ",".join(str(slot.prime) for slot in fill.triple_slots),
            "rotor_host": rotor_host.value,
            "rotor_d_artagnan": d_artagnan,
            "rotor_d_artagnan_canonical_formula": canonical_rotor_d,
            "rotor_d_artagnan_matches_canonical_formula": d_artagnan == canonical_rotor_d,
            "rotor_musketiere": format_tuple(rotor_triple),
            "rotor_d1": rotor_d1,
            "rotor_d2": rotor_d2,
            "rotor_gap_pair": format_tuple((rotor_d1, rotor_d2)),
            "rotor_gap_matches_canonical": (rotor_d1, rotor_d2) == expected_rotor,
        }

        for host in HOST_CHANNEL_ORDER:
            triple = host_triple(host, v)
            d1, d2 = sorted_gap_pair(triple)
            expected = host_triple_gap_pair(host)
            prefix = host.value
            row[f"host_{prefix}_component"] = host_component(host, v)
            row[f"host_{prefix}_musketiere"] = format_tuple(triple)
            row[f"host_{prefix}_d1"] = d1
            row[f"host_{prefix}_d2"] = d2
            row[f"host_{prefix}_gap_pair"] = format_tuple((d1, d2))
            row[f"host_{prefix}_gap_matches_canonical"] = (d1, d2) == expected

        records.append(row)
    return records


CSV_FIELDS = [
    "index",
    "prime_count_scope",
    "v_abcE",
    "p_anchor",
    "A",
    "B",
    "C",
    "E",
    "p1_sorted",
    "p2_sorted",
    "p3_sorted",
    "p4_sorted",
    "channels_sorted",
    "span",
    "gaps_sorted",
    "canonical_primquadruplet",
    "quat_norm",
    "sqrt_norm",
    "pair_gaps",
    "host_E",
    "host_A",
    "host_B",
    "host_C",
    "verify_dumas_lemma",
    "natural_fill_gaps",
    "natural_fill_gap_free",
    "triple_slot_primes",
    "rotor_host",
    "rotor_d_artagnan",
    "rotor_d_artagnan_canonical_formula",
    "rotor_d_artagnan_matches_canonical_formula",
    "rotor_musketiere",
    "rotor_d1",
    "rotor_d2",
    "rotor_gap_pair",
    "rotor_gap_matches_canonical",
    "host_E_component",
    "host_E_musketiere",
    "host_E_d1",
    "host_E_d2",
    "host_E_gap_pair",
    "host_E_gap_matches_canonical",
    "host_A_component",
    "host_A_musketiere",
    "host_A_d1",
    "host_A_d2",
    "host_A_gap_pair",
    "host_A_gap_matches_canonical",
    "host_B_component",
    "host_B_musketiere",
    "host_B_d1",
    "host_B_d2",
    "host_B_gap_pair",
    "host_B_gap_matches_canonical",
    "host_C_component",
    "host_C_musketiere",
    "host_C_d1",
    "host_C_d2",
    "host_C_gap_pair",
    "host_C_gap_matches_canonical",
]


def export_kanalvierling_dumas_csv(
    output_path: str | Path,
    prime_count: int = DEFAULT_PRIME_COUNT,
) -> tuple[Path, dict[str, object], list[dict[str, object]]]:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    quadruples, eabc_stream, remainder = partition_eabc_quadruples_by_channels(prime_count)
    records = kanalvierling_dumas_records(quadruples)
    for record in records:
        record["prime_count_scope"] = prime_count

    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS)
        writer.writeheader()
        writer.writerows(records)

    stats = summarize_partition(quadruples, eabc_stream, remainder)
    stats["kanalvierling_count"] = len(quadruples)
    stats["verify_dumas_all"] = all(record["verify_dumas_lemma"] for record in records)
    stats["natural_fill_gap_free_all"] = all(record["natural_fill_gap_free"] for record in records)
    stats["canonical_count"] = sum(1 for record in records if record["canonical_primquadruplet"])
    stats["rotor_gap_canonical_count"] = sum(
        1 for record in records if record["rotor_gap_matches_canonical"]
    )
    return destination, stats, records


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--n-primes",
        type=int,
        default=DEFAULT_PRIME_COUNT,
        help=f"number of primes in scan scope (default: {DEFAULT_PRIME_COUNT})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUT,
        help="CSV output path",
    )
    args = parser.parse_args()

    path, stats, records = export_kanalvierling_dumas_csv(args.output, args.n_primes)
    print(f"Wrote {path} ({len(records)} data rows + header)")
    print(f"Scope: first n={args.n_primes} primes")
    print(f"EABC stream |S_n|: {stats['eabc_stream_count']}")
    print(f"Kanalvierlinge K_bucket: {stats['K_bucket']}")
    print(f"Coverage: {stats['coverage_ratio']:.4%}")
    print(f"Canonical Primquadruplets: {stats['canonical_count']}/{len(records)}")
    print(f"verify_dumas_lemma all True: {stats['verify_dumas_all']}")
    print(f"Natural-fill gap-free all: {stats['natural_fill_gap_free_all']}")
    print(f"Rotor gap matches canonical: {stats['rotor_gap_canonical_count']}/{len(records)}")
    if records:
        print(f"First row: index={records[0]['index']}, v={records[0]['v_abcE']}")
        print(f"Last row: index={records[-1]['index']}, v={records[-1]['v_abcE']}")


if __name__ == "__main__":
    main()
