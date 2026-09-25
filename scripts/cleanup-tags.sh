#!/usr/bin/env bash
# Deletes -dev.N git tags that are no longer needed, in two cases:
#
# 1. Their target version already has (or is older than) a real release (a
#    plain X.Y.Z or X.Y.Z.W tag, no -dev suffix) - CHANGELOG.md folds their
#    content into that release's own entry, so the tag itself is pure
#    clutter afterward.
# 2. They're a superseded dev build of a version that hasn't been released
#    yet - only the highest -dev.N per not-yet-released version is kept, so
#    there's always at most one active dev build in flight per version, not
#    a pile of every intermediate one.
#
# Real release tags and the `legacy-*` archival tag are never touched.
#
# Dry-run by default - prints what would be deleted. Pass --yes to
# actually delete. Deletes via `git push --delete`, which the Gitea ->
# GitHub push-mirror propagates automatically. Also deletes the matching
# Gitea Release object, if one exists, for each tag removed.
set -euo pipefail

cd "$(dirname "$0")/.."

set -a
source ~/.claude/gil-tools.env
set +a

REPO=$(git remote get-url origin | sed -E 's#.*/([^/]+/[^/]+)\.git#\1#')
API="https://gitea.gil.gmbh/api/v1/repos/$REPO"

DRY_RUN=true
if [[ "${1:-}" == "--yes" ]]; then
    DRY_RUN=false
fi

tags=$(curl -s -H "Authorization: token $GITEA_ACCESS_TOKEN" "$API/tags?limit=100" \
    | python3 -c "import json,sys; print('\n'.join(t['name'] for t in json.load(sys.stdin)))")

latest_release=$(echo "$tags" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$' | sort -V | tail -1)

if [[ -z "$latest_release" ]]; then
    echo "No real release tag found (X.Y.Z, no -dev suffix) - aborting." >&2
    exit 1
fi

echo "Latest real release: $latest_release"

to_delete=()
released_dev_tags=()
declare -A highest_dev_num
declare -A highest_dev_tag
unreleased_dev_tags=()
unreleased_dev_versions=()

while IFS= read -r tag; do
    [[ "$tag" =~ ^([0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?)-dev\.([0-9]+)$ ]] || continue
    version="${BASH_REMATCH[1]}"
    devNum="${BASH_REMATCH[3]}"

    newer=$(printf '%s\n%s\n' "$version" "$latest_release" | sort -V | tail -1)
    if [[ "$newer" == "$latest_release" ]]; then
        # Case 1: version <= latest_release - already folded into a real
        # release, every dev tag for it goes.
        released_dev_tags+=("$tag")
        continue
    fi

    # Case 2: not yet released - remember it and track the highest -dev.N
    # seen per version, so only that one survives below.
    unreleased_dev_tags+=("$tag")
    unreleased_dev_versions+=("$version")
    if [[ -z "${highest_dev_num[$version]:-}" || "$devNum" -gt "${highest_dev_num[$version]}" ]]; then
        highest_dev_num[$version]="$devNum"
        highest_dev_tag[$version]="$tag"
    fi
done <<< "$tags"

to_delete=("${released_dev_tags[@]}")
for i in "${!unreleased_dev_tags[@]}"; do
    tag="${unreleased_dev_tags[$i]}"
    version="${unreleased_dev_versions[$i]}"
    if [[ "$tag" != "${highest_dev_tag[$version]}" ]]; then
        to_delete+=("$tag")
    fi
done

if [[ ${#to_delete[@]} -eq 0 ]]; then
    echo "Nothing to clean up."
    exit 0
fi

echo "Tags to delete (${#to_delete[@]}):"
printf '  %s\n' "${to_delete[@]}"

if $DRY_RUN; then
    echo
    echo "Dry run - nothing deleted. Re-run with --yes to actually delete."
    exit 0
fi

for tag in "${to_delete[@]}"; do
    release_id=$(curl -s -H "Authorization: token $GITEA_ACCESS_TOKEN" "$API/releases/tags/$tag" \
        | python3 -c "
import json, sys
try:
    print(json.load(sys.stdin).get('id', ''))
except Exception:
    print('')
")
    if [[ -n "$release_id" ]]; then
        echo "Deleting release for $tag (id $release_id)..."
        curl -s -X DELETE -H "Authorization: token $GITEA_ACCESS_TOKEN" "$API/releases/$release_id" >/dev/null
    fi
    echo "Deleting tag $tag..."
    git push origin --delete "$tag"
done

echo "Done - ${#to_delete[@]} tags removed. GitHub mirror will sync the deletions automatically."
