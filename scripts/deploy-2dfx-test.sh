#!/usr/bin/env bash
# Deploy the dedicated Ep128web 2dfx-fidelity development build on Debian.
# Execute as root: bash scripts/deploy-2dfx-test.sh
set -Eeuo pipefail

REPO=/root/Ep128web_test
BRANCH=2dfx-fidelity
SITE=/var/www/ep128web-test

if [[ "$(id -u)" -ne 0 ]]; then
  echo 'Run as root (required to publish the nginx site).' >&2
  exit 1
fi

cd "$REPO"

if [[ "$(git branch --show-current)" != "$BRANCH" ]]; then
  echo "Expected branch '$BRANCH'; refusing to deploy another branch." >&2
  exit 1
fi

# This Debian VM is a disposable mirror, NOT a place to preserve local
# commits or edits. GitHub's 2dfx-fidelity branch is authoritative.
# Reset only this checkout: never clean /var/www or any other repository.
echo '========== REPLACING LOCAL BRANCH FROM GITHUB =========='
git fetch origin "$BRANCH"
git reset --hard "refs/remotes/origin/$BRANCH"

# build.sh intentionally patches the pinned ep128emu submodule. Keep those
# already-applied patches unless the submodule commit itself has changed.
PINNED_SUBMODULE=$(git rev-parse HEAD:ep128emu)
CURRENT_SUBMODULE=$(git -C ep128emu rev-parse HEAD 2>/dev/null || true)
if [[ ! -f ep128emu/src/ep128vm.cpp || "$CURRENT_SUBMODULE" != "$PINNED_SUBMODULE" ]]; then
  git submodule update --init --recursive --force
fi

# Request a reproducible full recompile (e.g. after changing toolchains):
# CLEAN_BUILD=1 bash scripts/deploy-2dfx-test.sh
if [[ "${CLEAN_BUILD:-0}" == "1" ]]; then
  echo '========== DISCARDING COMPILED OBJECT CACHE =========='
  rm -rf -- build/obj
fi

export EMSDK_QUIET=1
# shellcheck disable=SC1091
source /root/emsdk/emsdk_env.sh

echo '========== EMSCRIPTEN =========='
emcc --version | sed -n '1p'

echo '========== BUILDING =========='
./build.sh

for file in index.html ep128emu.js ep128emu.wasm; do
  if [[ ! -s "dist/$file" ]]; then
    echo "Missing or empty build artifact: dist/$file" >&2
    exit 1
  fi
done

echo '========== DEPLOYING =========='
install -d -m 0755 "$SITE"
cp -a dist/. "$SITE/"
chmod -R a+rX "$SITE"

echo "Published commit $(git rev-parse --short HEAD) to $SITE"
echo 'Open: http://192.168.188.143:8000/'
