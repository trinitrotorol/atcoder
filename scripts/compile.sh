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
OUT="${2:-"$ROOT_DIR/a.out"}"

if [[ ! -f "$SRC" ]]; then
    echo "source file not found: $SRC" >&2
    exit 1
fi

SRC="$(realpath "$SRC")"

pick_cxx() {
    if [[ -n "${CXX:-}" ]] && command -v "$CXX" >/dev/null 2>&1; then
        command -v "$CXX"
        return
    fi
    if command -v x86_64-conda-linux-gnu-g++ >/dev/null 2>&1; then
        command -v x86_64-conda-linux-gnu-g++
        return
    fi
    if command -v g++ >/dev/null 2>&1; then
        command -v g++
        return
    fi
    echo "g++ was not found. Run ./scripts/setup-linux.sh first." >&2
    exit 1
}

CXX_BIN="$(pick_cxx)"

build_standard_module() {
    local module_name="$1"
    local source_path="$2"
    local cache_path="$ROOT_DIR/gcm.cache/$module_name.gcm"
    local object_path="$ROOT_DIR/.cache/$module_name.o"

    if [[ ! -f "$source_path" ]]; then
        return
    fi

    if [[ -f "$cache_path" && "$cache_path" -nt "$source_path" ]]; then
        return
    fi

    mkdir -p "$ROOT_DIR/.cache"
    (
        cd "$ROOT_DIR"
        "$CXX_BIN" -std=gnu++23 -fmodules -c "$source_path" -o "$object_path"
    )
}

ensure_standard_modules() {
    if ! grep -Eq '^[[:space:]]*(export[[:space:]]+)?import[[:space:]]+std(\.compat)?[[:space:]]*;' "$SRC"; then
        return
    fi

    local std_source
    local compat_source

    std_source="$("$CXX_BIN" -print-file-name=include/c++/bits/std.cc)"
    compat_source="$("$CXX_BIN" -print-file-name=include/c++/bits/std.compat.cc)"

    build_standard_module "std" "$std_source"
    if grep -Eq '^[[:space:]]*(export[[:space:]]+)?import[[:space:]]+std\.compat[[:space:]]*;' "$SRC"; then
        build_standard_module "std.compat" "$compat_source"
    fi
}

FLAGS=(
    -std=gnu++23
    -O2
    -Wall
    -Wextra
    -DONLINE_JUDGE
    -DATCODER
    -fconstexpr-depth=1024
    -fconstexpr-loop-limit=524288
    -fconstexpr-ops-limit=2097152
    -fmodules
    -ftrivial-auto-var-init=zero
)

if [[ "${ATCODER_NATIVE:-1}" == "1" ]]; then
    FLAGS+=(-march=native)
fi

INCLUDES=(
    -I"$ROOT_DIR/include"
    -I"$ROOT_DIR/third_party/ac-library"
)

LDFLAGS=(-pthread)

if [[ -n "${CONDA_PREFIX:-}" ]]; then
    INCLUDES+=(-I"$CONDA_PREFIX/include")
    LDFLAGS+=(-L"$CONDA_PREFIX/lib" -Wl,-rpath,"$CONDA_PREFIX/lib")
fi

EXTRA_FLAGS=()
if [[ -n "${ATCODER_EXTRA_FLAGS:-}" ]]; then
    EXTRA_FLAGS=(${ATCODER_EXTRA_FLAGS})
fi

ensure_standard_modules

(
    cd "$ROOT_DIR"
    "$CXX_BIN" "${FLAGS[@]}" "${INCLUDES[@]}" "$SRC" -o "$OUT" "${LDFLAGS[@]}" "${EXTRA_FLAGS[@]}"
)
