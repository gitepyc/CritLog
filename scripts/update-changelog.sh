#!/usr/bin/env bash
# Regenerates CHANGELOG.md's newest section from commits since the last
# real tag, via git-cliff (see cliff.toml), and prepends it above the
# existing file - existing sections are untouched. Run this locally right
# before creating a new tag (after bumping CritLog.toc's version, before
# `git tag`), not in CI - CI (release.yml) independently regenerates its
# own release notes from the same commits, it doesn't read this file.
#
# Usage: scripts/update-changelog.sh <new-version>
#   e.g. scripts/update-changelog.sh 0.9.1.12-dev
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new-version>" >&2
    exit 1
fi

cd "$(dirname "$0")/.."

docker run --rm \
    -v "$PWD":/repo \
    -w /repo \
    orhunp/git-cliff:latest \
    --config cliff.toml --unreleased --tag "$1" --prepend CHANGELOG.md
