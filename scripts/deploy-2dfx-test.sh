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

# The ep128emu submodule is patched locally by build.sh; ignore its
# intentional working-tree changes, but do not overwrite edits in this repo.
if [[ -n "$(git status --porcelain --ignore-submodules=all)" ]]; then
  echo 'Uncommitted changes in the Web Emulator checkout; refusing to pull.' >&2
  git status --short --ignore-submodules=all >&2
  exit 1
fi

echo '========== FETCHING DEVELOPMENT BRANCH =========='
git fetch origin "$BRANCH"
git merge --ff-only FETCH_HEAD

if [[ ! -f ep128emu/src/ep128vm.cpp ]]; then
  git submodule update --init --recursive
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
