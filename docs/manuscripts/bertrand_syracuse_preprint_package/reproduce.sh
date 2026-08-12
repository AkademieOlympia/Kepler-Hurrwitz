#!/usr/bin/env bash
# Reproducible checks for the Bertrand–Syracuse preprint package.
# Run from repository root:
#   ./docs/manuscripts/bertrand_syracuse_preprint_package/reproduce.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT"

MODULE="KeplerHurwitz/Collatz/BertrandSyracuseTrichotomy.lean"
TARGET="KeplerHurwitz.Collatz.BertrandSyracuseTrichotomy"
TEX="docs/manuscripts/bertrand_syracuse_prime_trichotomy.tex"
MANIFEST="docs/manuscripts/bertrand_syracuse_preprint_package/MANIFEST.json"

echo "== Package inventory =="
for f in "$MODULE" "$TEX" "$MANIFEST" lean-toolchain lakefile.toml; do
  if [[ -f "$f" ]]; then
    echo "  OK  $f"
  else
    echo "  MISS $f" >&2
    exit 1
  fi
done

echo "== Version pins =="
echo -n "  lean-toolchain: "; cat lean-toolchain
echo -n "  mathlib rev:    "; grep -E '^\s*rev\s*=' lakefile.toml | head -1

echo "== Sorry / admit audit (module only) =="
if command -v rg >/dev/null 2>&1; then
  if rg -n -P '(^|[^A-Za-z0-9_/`])(sorry|admit)([^A-Za-z0-9_]|$)' "$MODULE"; then
    echo "FAIL: sorry/admit found in module" >&2
    exit 1
  fi
else
  if grep -nE '(^|[^A-Za-z0-9_/`])(sorry|admit)([^A-Za-z0-9_]|$)' "$MODULE"; then
    echo "FAIL: sorry/admit found in module" >&2
    exit 1
  fi
fi
echo "  0 sorry / 0 admit"

echo "== Lean build =="
if command -v lake >/dev/null 2>&1; then
  lake build "$TARGET"
else
  echo "  SKIP: lake not on PATH" >&2
  exit 1
fi

echo "== Optional PDF =="
if command -v pdflatex >/dev/null 2>&1; then
  OUT="$(mktemp -d)"
  pdflatex -interaction=nonstopmode -output-directory="$OUT" "$TEX" >/dev/null
  echo "  PDF OK: $OUT/$(basename "${TEX%.tex}.pdf")"
else
  echo "  SKIP: pdflatex not on PATH"
fi

echo "== PASS: preprint package reproducible checks =="
