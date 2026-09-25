#!/usr/bin/env bash
# Regenerates CHANGELOG.md in full via git-cliff (see cliff.toml), reading
# real tags directly from git history - not an incremental --prepend,
# which self-duplicates every prior entry once any tag predates git-cliff's
# own adoption commit. Run this AFTER creating the new tag (so git-cliff
# can read its real commit date), then fold the result into the release
# commit:
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

# Sanity check: a dev tag (X.Y.Z-dev.N) should never get its own heading -
# cliff.toml's [git] ignore_tags is what folds it into the next real
# release's section instead. If this ever fires, that regex broke (or got
# edited away) and CHANGELOG.md just fragmented into a heading per dev
# build - CONTRIBUTING.md's "Releasing" section documents the intended
# behavior this is meant to protect.
if grep -qE '^## \[[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?-dev\.[0-9]+\]' CHANGELOG.md; then
    echo "error: CHANGELOG.md has a heading for a -dev tag - cliff.toml's ignore_tags isn't folding it in anymore" >&2
    exit 1
fi
