#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_NAME="${ATCODER_ENV_NAME:-atcoder-cpp23}"
MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-"$ROOT_DIR/.micromamba"}"
MAMBA_BIN="${MAMBA_BIN:-"$ROOT_DIR/.tools/micromamba/bin/micromamba"}"

if [[ -z "${CONDA_PREFIX:-}" && -x "$MAMBA_BIN" ]]; then
    export MAMBA_ROOT_PREFIX
    exec "$MAMBA_BIN" run -n "$ENV_NAME" bash "$0" "$@"
fi

SRC="${1:-"$ROOT_DIR/Main.cpp"}"
INPUT="${2:-}"
OUT="$ROOT_DIR/a.out"

"$ROOT_DIR/scripts/compile.sh" "$SRC" "$OUT"

if [[ -n "$INPUT" ]]; then
    "$OUT" < "$INPUT"
else
    "$OUT"
fi

