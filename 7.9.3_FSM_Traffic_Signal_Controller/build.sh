#!/usr/bin/env bash
# Vivado xsim 빌드 + 시뮬레이션 스크립트
#
# 사용법:
#   ./build.sh          컴파일 → elaborate → 시뮬레이션 후 waveform GUI 실행
#   ./build.sh -nogui   콘솔에서만 시뮬레이션 ($monitor 출력 확인용)
#
# 생성물은 모두 build/ 아래에 만들어지며 ./clean.sh 로 지운다.

set -eo pipefail

# ---------------------------------------------------------------------------
# 설정
# ---------------------------------------------------------------------------
VIVADO_DIR="${VIVADO_DIR:-/home/eunwoo/tools/Xilinx/Vivado/2023.2}"
TOP="tb_sig_control"
SRCS=(sig_control.v tb_sig_control.v)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
SNAPSHOT="${TOP}_behav"

GUI=1
case "$1" in
    "")              ;;
    -nogui|--nogui)  GUI=0 ;;
    *) echo "usage: $0 [-nogui]" >&2; exit 1 ;;
esac

# ---------------------------------------------------------------------------
# Vivado 환경
# ---------------------------------------------------------------------------
if ! command -v xvlog >/dev/null 2>&1; then
    if [ ! -f "$VIVADO_DIR/settings64.sh" ]; then
        echo "ERROR: $VIVADO_DIR/settings64.sh 가 없습니다. VIVADO_DIR 을 확인하세요." >&2
        exit 1
    fi
    source "$VIVADO_DIR/settings64.sh"
fi

mkdir -p "$BUILD_DIR"

# Ubuntu 24.04 에는 libtinfo.so.5 / libncurses.so.5 가 없어 xvlog 가 실행되지 않는다.
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
# 컴파일 → elaborate → 시뮬레이션
# ---------------------------------------------------------------------------
cd "$BUILD_DIR"

echo "==> xvlog (compile)"
xvlog "${SRCS[@]/#/$SCRIPT_DIR/}"

echo "==> xelab (elaborate)"
xelab "$TOP" -debug typical -s "$SNAPSHOT"

if [ "$GUI" -eq 1 ]; then
    cat > sim_gui.tcl <<'EOF'
log_wave -recursive *
add_wave /
run all
EOF
    echo "==> xsim (GUI)"
    xsim "$SNAPSHOT" -gui -tclbatch sim_gui.tcl
else
    cat > sim_batch.tcl <<'EOF'
log_wave -recursive *
run all
quit
EOF
    echo "==> xsim (batch)"
    xsim "$SNAPSHOT" -tclbatch sim_batch.tcl -wdb "$SNAPSHOT.wdb"
    echo "waveform DB: $BUILD_DIR/$SNAPSHOT.wdb"
fi
