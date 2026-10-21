#!/usr/bin/env bash
# build.sh 가 만든 생성물 삭제

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

rm -rf build

# 소스 폴더에서 직접 xvlog/xsim 을 돌렸을 때 남는 파일들
rm -rf xsim.dir .Xil
rm -f  *.log *.jou *.pb *.wdb *.vcd *.str webtalk*

echo "cleaned: $SCRIPT_DIR"
