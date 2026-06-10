#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_NAME="${ATCODER_ENV_NAME:-atcoder-cpp23}"
MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-"$ROOT_DIR/.micromamba"}"
MAMBA_BIN="${MAMBA_BIN:-"$ROOT_DIR/.tools/micromamba/bin/micromamba"}"
ACL_VERSION="${ACL_VERSION:-v1.6}"

mkdir -p "$(dirname "$MAMBA_BIN")" "$MAMBA_ROOT_PREFIX"

if [[ ! -x "$MAMBA_BIN" ]]; then
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    echo "Downloading micromamba..."
    curl -L "https://micro.mamba.pm/api/micromamba/linux-64/latest" -o "$tmp_dir/micromamba.tar.bz2"
    python3 - "$tmp_dir/micromamba.tar.bz2" "$tmp_dir" <<'PY'
import sys
import tarfile

archive, dest = sys.argv[1], sys.argv[2]
with tarfile.open(archive, "r:bz2") as tar:
    tar.extract("bin/micromamba", dest)
PY
    mv "$tmp_dir/bin/micromamba" "$MAMBA_BIN"
    chmod +x "$MAMBA_BIN"
fi

export MAMBA_ROOT_PREFIX

if [[ -d "$MAMBA_ROOT_PREFIX/envs/$ENV_NAME" ]]; then
    "$MAMBA_BIN" env update -n "$ENV_NAME" -f "$ROOT_DIR/environment.yml" -y
else
    "$MAMBA_BIN" env create -f "$ROOT_DIR/environment.yml" -y
fi

if [[ ! -d "$ROOT_DIR/third_party/ac-library/atcoder" ]]; then
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT
    mkdir -p "$ROOT_DIR/third_party"

    echo "Downloading ac-library $ACL_VERSION..."
    curl -L "https://github.com/atcoder/ac-library/archive/refs/tags/$ACL_VERSION.tar.gz" -o "$tmp_dir/ac-library.tar.gz"
    tar -xzf "$tmp_dir/ac-library.tar.gz" -C "$tmp_dir"
    rm -rf "$ROOT_DIR/third_party/ac-library"
    mv "$tmp_dir/ac-library-${ACL_VERSION#v}" "$ROOT_DIR/third_party/ac-library"
fi

echo "Compiler:"
"$MAMBA_BIN" run -n "$ENV_NAME" bash -lc '"${CXX:-x86_64-conda-linux-gnu-g++}" --version | head -n 1'

echo "Done. Try: ./scripts/run.sh"
