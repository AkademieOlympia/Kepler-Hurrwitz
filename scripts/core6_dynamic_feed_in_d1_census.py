#!/usr/bin/env python3
"""D1 full dyadic census for Core6 expanding→contracting feed-in [B].

Epistemic:
  - ReachabilityFeedInGoal / OneBlockFeedInGoal remain [C].
  - This script produces finite reproducible [B] evidence only.
  - 100% hits up to stage m_max do NOT prove the universal Lean goals.
  - Censoring at horizon T is NOT a counterexample.

Starts (complete expanding residues at stage m):
  n = Φ_{e0}(k) = b_{e0} + k * 2^{e0+9},  e0 ∈ {1,2,3},  0 ≤ k < 2^{m-e0}.

Usage (repo root)::

    PYTHONPATH=. python scripts/core6_dynamic_feed_in_d1_census.py --m 8 --T 64
    PYTHONPATH=. python scripts/core6_dynamic_feed_in_d1_census.py --m 6 --T 32 --jsonl /tmp/d1.jsonl
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable, Iterator, Optional


COEFF3 = 3**7  # 2187
WORD_C_FIBER = 2347
CORE6 = (1, 1, 1, 1, 2, 2)


def valuation_step(n: int) -> int:
    """ν₂(3n+1)."""
    x = 3 * n + 1
    if x <= 0:
        raise ValueError(f"non-positive 3n+1 for n={n}")
    v = 0
    while x % 2 == 0:
        x //= 2
        v += 1
    return v


def next_odd(n: int) -> int:
    """U(n) = oddCore(3n+1)."""
    x = 3 * n + 1
    while x % 2 == 0:
        x //= 2
    return x


def realizes_word(word: Iterable[int], n: int) -> bool:
    cur = n
    for e in word:
        if cur % 2 == 0:
            return False
        if valuation_step(cur) != e:
            return False
        cur = next_odd(cur)
    return True


def realized_image(word: Iterable[int], n: int) -> int:
    cur = n
    for _ in word:
        cur = next_odd(cur)
    return cur


def modinv(a: int, m: int) -> int:
    return pow(a % m, -1, m)


def canonical_base(e: int) -> int:
    """Unique b < 2^{e+9} with 2187·b + 2347 ≡ 2^{e+8} (mod 2^{e+9})."""
    M = 1 << (e + 9)
    rhs = ((1 << (e + 8)) - WORD_C_FIBER) % M
    return (modinv(COEFF3, M) * rhs) % M


def seed_modulus(e: int) -> int:
    return 1 << (e + 9)


def fiber_index(e: int, k: int) -> int:
    return canonical_base(e) + k * seed_modulus(e)


def in_contracting_mass(n: int) -> tuple[bool, Optional[int]]:
    """n ∈ ⋃_{e≥4} C_e iff RealizesWord(core6,n) and seventh valuation ≥ 4."""
    if n % 2 == 0:
        return False, None
    if not realizes_word(CORE6, n):
        return False, None
    x = realized_image(CORE6, n)
    if x % 2 == 0:
        return False, None
    e = valuation_step(x)
    if e >= 4:
        return True, e
    return False, e


@dataclass(frozen=True)
class CensusRow:
    stage_m: int
    source_e: int
    source_k: int
    start_n: int
    hit: bool
    first_hit_t: Optional[int]
    target_e: Optional[int]
    censored_at: Optional[int]
    valuation_trace: str
    one_block_hit: bool
    one_block_target_e: Optional[int]


def expanding_starts(m: int) -> Iterator[tuple[int, int, int]]:
    """Yield (e0, k, n) for all expanding residues at stage m."""
    if m < 3:
        raise ValueError("stage m must be ≥ 3 to include e0=1,2,3 lifts")
    for e0 in (1, 2, 3):
        count = 1 << (m - e0)
        for k in range(count):
            yield e0, k, fiber_index(e0, k)


def census_one(stage_m: int, e0: int, k: int, n: int, T: int) -> CensusRow:
    # Sanity: start in claimed source fiber
    if not realizes_word(CORE6 + (e0,), n):
        raise SystemExit(f"sanity: start not in C_{e0}: e0={e0} k={k} n={n}")
    if n != fiber_index(e0, k):
        raise SystemExit(f"sanity: n ≠ Φ(e0,k): {n} vs {fiber_index(e0, k)}")

    # One-block image after full fiberE e0
    img = realized_image(CORE6 + (e0,), n)
    one_hit, one_e = in_contracting_mass(img)

    # Odd-iterate search from the original start (t=1..)
    cur = n
    trace: list[int] = []
    hit = False
    first_t: Optional[int] = None
    target_e: Optional[int] = None
    censored: Optional[int] = T

    for t in range(1, T + 1):
        cur = next_odd(cur)
        v = valuation_step(cur) if cur % 2 == 1 else -1
        trace.append(v)
        ok, e_hit = in_contracting_mass(cur)
        if ok:
            hit = True
            first_t = t
            target_e = e_hit
            censored = None
            # minimality: first success breaks
            break

    return CensusRow(
        stage_m=stage_m,
        source_e=e0,
        source_k=k,
        start_n=n,
        hit=hit,
        first_hit_t=first_t,
        target_e=target_e,
        censored_at=censored,
        valuation_trace=",".join(str(v) for v in trace),
        one_block_hit=one_hit,
        one_block_target_e=one_e if one_hit else None,
    )


def verify_row(row: CensusRow, T: int) -> None:
    n = row.start_n
    e0 = row.source_e
    if not realizes_word(CORE6 + (e0,), n):
        raise SystemExit(f"post-check: start not in source fiber: {row}")
    if row.hit:
        assert row.first_hit_t is not None and row.censored_at is None
        cur = n
        for t in range(1, row.first_hit_t + 1):
            cur = next_odd(cur)
        ok, e = in_contracting_mass(cur)
        if not ok or e != row.target_e:
            raise SystemExit(f"post-check: false hit: {row}")
        # minimality
        cur = n
        for t in range(1, row.first_hit_t):
            cur = next_odd(cur)
            ok, _ = in_contracting_mass(cur)
            if ok:
                raise SystemExit(f"post-check: non-minimal hit time: {row}")
    else:
        if row.censored_at != T or row.first_hit_t is not None:
            raise SystemExit(f"post-check: bad censor fields: {row}")


def param_hash(m: int, T: int) -> str:
    payload = json.dumps(
        {"m": m, "T": T, "coeff3": COEFF3, "wordC": WORD_C_FIBER, "core6": list(CORE6)},
        sort_keys=True,
    )
    return hashlib.sha256(payload.encode()).hexdigest()[:16]


def summarize(rows: list[CensusRow]) -> dict:
    by_e: dict[int, dict] = {}
    for e0 in (1, 2, 3):
        sub = [r for r in rows if r.source_e == e0]
        hits = [r for r in sub if r.hit]
        cens = [r for r in sub if not r.hit]
        one = [r for r in sub if r.one_block_hit]
        by_e[e0] = {
            "starts": len(sub),
            "hits": len(hits),
            "censored": len(cens),
            "one_block_hits": len(one),
            "hit_times": sorted(r.first_hit_t for r in hits if r.first_hit_t is not None),
            "target_e_counts": {},
        }
        for r in hits:
            te = r.target_e
            by_e[e0]["target_e_counts"][te] = by_e[e0]["target_e_counts"].get(te, 0) + 1
    return {
        "total_starts": len(rows),
        "total_hits": sum(1 for r in rows if r.hit),
        "total_censored": sum(1 for r in rows if not r.hit),
        "total_one_block_hits": sum(1 for r in rows if r.one_block_hit),
        "by_source_e": by_e,
    }


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--m", type=int, required=True, help="dyadic stage m (≥3)")
    p.add_argument("--T", type=int, required=True, help="odd-iterate horizon")
    p.add_argument("--jsonl", type=Path, help="optional JSONL output path")
    p.add_argument("--csv", type=Path, help="optional CSV output path")
    p.add_argument("--summary", type=Path, help="optional summary JSON path")
    args = p.parse_args(argv)

    if args.m < 3:
        print("error: --m must be ≥ 3", file=sys.stderr)
        return 2
    if args.T < 1:
        print("error: --T must be ≥ 1", file=sys.stderr)
        return 2

    # Uniqueness of starts within stage
    seen: set[int] = set()
    rows: list[CensusRow] = []
    for e0, k, n in expanding_starts(args.m):
        if n in seen:
            raise SystemExit(f"duplicate start within stage: n={n}")
        seen.add(n)
        row = census_one(args.m, e0, k, n, args.T)
        verify_row(row, args.T)
        rows.append(row)

    ph = param_hash(args.m, args.T)
    summary = {
        "epistemic": "[B] finite census — does not discharge [C] goals",
        "stage_m": args.m,
        "horizon_T": args.T,
        "param_hash": ph,
        "Q_m": 1 << (args.m + 9),
        "expected_starts": (1 << (args.m - 1)) + (1 << (args.m - 2)) + (1 << (args.m - 3)),
        **summarize(rows),
    }
    if summary["total_starts"] != summary["expected_starts"]:
        raise SystemExit("start count mismatch vs ∑ 2^{m-e0}")

    if args.jsonl:
        with args.jsonl.open("w", encoding="utf-8") as f:
            for r in rows:
                f.write(json.dumps(asdict(r), sort_keys=True) + "\n")
    if args.csv:
        with args.csv.open("w", encoding="utf-8", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(asdict(rows[0]).keys()))
            w.writeheader()
            for r in rows:
                w.writerow(asdict(r))
    if args.summary:
        args.summary.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")

    print(json.dumps(summary, indent=2, sort_keys=True))
    print(
        f"D1_CENSUS_OK param_hash={ph} starts={summary['total_starts']} "
        f"hits={summary['total_hits']} censored={summary['total_censored']} "
        f"one_block_hits={summary['total_one_block_hits']}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
