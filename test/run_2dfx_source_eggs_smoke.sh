#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/egg-smoke-obj
obj=()
for f in web/src/twodfx/core/{twodfx_emu,twodfx_raster,twodfx_3d}.c \
         web/src/twodfx/assets/logo_2dfx_asset.c \
         web/src/twodfx/firmware_eggs/{firmware_page,egg_*}.c \
         test/2dfx_source_eggs_smoke.c; do
  out="build/egg-smoke-obj/$(basename "${f%.c}").o"
  cc -std=c99 -O0 -w \
     -Iweb/src/twodfx/include -Iweb/src/twodfx/core \
     -Iweb/src/twodfx/assets -Iweb/src/twodfx/firmware_eggs \
     -Iweb/src/twodfx/firmware_eggs/portable -c "$f" -o "$out"
  obj+=("$out")
done
cc "${obj[@]}" -lm -o build/2dfx-source-eggs-smoke
build/2dfx-source-eggs-smoke
