#!/usr/bin/env bash
# Vivado RTL schematic (Elaborated Design) 보기 스크립트
#
# 사용법:
#   ./schematic.sh          RTL elaborate 후 Vivado GUI 에서 schematic 표시
#   ./schematic.sh -nogui   elaborate 만 수행 (문법/연결 오류 확인용)
#
# 생성물은 모두 build/ 아래에 만들어지며 ./clean.sh 로 지운다.

set -eo pipefail

# ---------------------------------------------------------------------------
# 설정
# ---------------------------------------------------------------------------
VIVADO_DIR="${VIVADO_DIR:-/home/eunwoo/tools/Xilinx/Vivado/2023.2}"
TOP="ripple_adder"
SRCS=(ripple_adder.v)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

GUI=1
case "$1" in
    "")              ;;
    -nogui|--nogui)  GUI=0 ;;
    *) echo "usage: $0 [-nogui]" >&2; exit 1 ;;
esac

# ---------------------------------------------------------------------------
# Vivado 환경
# ---------------------------------------------------------------------------
if ! command -v vivado >/dev/null 2>&1; then
    if [ ! -f "$VIVADO_DIR/settings64.sh" ]; then
        echo "ERROR: $VIVADO_DIR/settings64.sh 가 없습니다. VIVADO_DIR 을 확인하세요." >&2
        exit 1
    fi
    source "$VIVADO_DIR/settings64.sh"
fi

mkdir -p "$BUILD_DIR"

# Ubuntu 24.04 에는 libtinfo.so.5 / libncurses.so.5 가 없다.
# 시스템에 없으면 build/lib 에 .so.6 을 가리키는 호환 링크를 만들어 사용한다.
COMPAT_DIR="$BUILD_DIR/lib"
for lib in libtinfo libncurses; do
    if ! ldconfig -p 2>/dev/null | grep -q "$lib\.so\.5 "; then
        so6="$(ldconfig -p | awk -v l="$lib.so.6" '$1 == l && /x86-64/ {print $NF; exit}')"
        if [ -n "$so6" ]; then
            mkdir -p "$COMPAT_DIR"
            ln -sf "$so6" "$COMPAT_DIR/$lib.so.5"
        fi
    fi
done
if [ -d "$COMPAT_DIR" ]; then
    export LD_LIBRARY_PATH="$COMPAT_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# ---------------------------------------------------------------------------
# RTL elaborate → schematic
# ---------------------------------------------------------------------------
cd "$BUILD_DIR"

{
    for src in "${SRCS[@]}"; do
        echo "read_verilog {$SCRIPT_DIR/$src}"
    done
    echo "synth_design -rtl -top $TOP -name rtl_1"
    if [ "$GUI" -eq 1 ]; then
        echo 'show_schematic [concat [get_cells] [get_ports]]'
    fi
} > schematic.tcl

if [ "$GUI" -eq 1 ]; then
    echo "==> vivado (GUI, RTL schematic)"
    vivado -mode gui -source schematic.tcl
else
    echo "==> vivado (batch, RTL elaborate)"
    vivado -mode batch -source schematic.tcl
fi
