#!/bin/zsh
set -euo pipefail
cd "${0:A:h}/.."
build_tmp=$(mktemp -d)
trap 'rm -rf "$build_tmp"' EXIT
# Some Command Line Tools installs contain two definitions of SwiftBridging.
# A compiler-only VFS overlay avoids changing the installed toolchain.
/usr/bin/python3 - "$build_tmp" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
(p / 'empty.modulemap').write_text('')
(p / 'overlay.json').write_text(json.dumps({'version': 0, 'roots': [{'type': 'file', 'name': '/Library/Developer/CommandLineTools/usr/include/swift/module.modulemap', 'external-contents': str(p / 'empty.modulemap')}]}))
PY
swiftc 源码/main.swift -o Antigravity代理助手.app/Contents/MacOS/AntigravityProxyHelper -framework Cocoa -module-cache-path "$build_tmp/cache" -vfsoverlay "$build_tmp/overlay.json" -Xcc -ivfsoverlay -Xcc "$build_tmp/overlay.json"
codesign --force --sign - Antigravity代理助手.app
Antigravity代理助手.app/Contents/MacOS/AntigravityProxyHelper --self-test
echo '构建完成。'
