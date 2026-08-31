#!/usr/bin/env bash
# Runs luacheck against the repo inside the tools/lint container image.
# Builds the image on first use or after Dockerfile changes.
set -euo pipefail

cd "$(dirname "$0")/.."

docker build -q -t critlog-luacheck:5.1 -f tests/lint/Dockerfile tests/lint >/dev/null

docker run --rm -v "$PWD":/addon:ro critlog-luacheck:5.1 .
