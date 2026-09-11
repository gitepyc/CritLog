#!/usr/bin/env bash
# Regenerates CHANGELOG.md in full via git-cliff (see cliff.toml), reading
# real tags directly from git history - not an incremental --prepend,
# which self-duplicates every prior entry once any tag predates git-cliff's
# own adoption commit (root-caused during the CritLog history rebuild,
# 2026-09). Run this AFTER creating the new tag (so git-cliff can read its
# real commit date), then fold the result into the release commit:
#
#   sed -i 's/^## Version:.*/## Version: X.Y.Z/' CritLog.toc
#   git add CritLog.toc && git commit -m "chore: bump version to X.Y.Z for release"
#   git tag -f X.Y.Z
#   scripts/update-changelog.sh
#   git add CHANGELOG.md && git commit --amend --no-edit
#   git tag -f X.Y.Z
#
# Not run in CI - release.yml independently regenerates its own release
# notes from the same commits, it doesn't read this file.
set -euo pipefail

cd "$(dirname "$0")/.."

docker run --rm \
    -v "$PWD":/repo \
    -w /repo \
    orhunp/git-cliff:latest \
    --config cliff.toml -o CHANGELOG.md
