#!/usr/bin/env bash
# Deletes -dev git tags that are already covered by a newer real release (a
# plain X.Y.Z tag, no -dev suffix) - CHANGELOG.md folds their content into
# that release's own entry (see the consolidation pattern there), so the
# tag itself is pure clutter afterward. Real release tags and the
# `legacy-*` archival tag are never touched; any -dev tag at or after the
# latest real release (ongoing, not-yet-released work) is left alone too.
#
# Dry-run by default - prints what would be deleted. Pass --yes to
# actually delete. Deletes via `git push --delete`, which the Gitea ->
# GitHub push-mirror propagates automatically - no separate GitHub step
# needed. Also deletes the matching Gitea Release object, if one exists,
# for each tag removed.
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

latest_release=$(echo "$tags" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)

if [[ -z "$latest_release" ]]; then
    echo "No real release tag found (X.Y.Z, no -dev suffix) - aborting." >&2
    exit 1
fi

echo "Latest real release: $latest_release"

to_delete=()
while IFS= read -r tag; do
    [[ "$tag" =~ ^[0-9]+\.[0-9]+\.[0-9]+-dev$ ]] || continue
    version="${tag%-dev}"
    older=$(printf '%s\n%s\n' "$version" "$latest_release" | sort -V | head -1)
    if [[ "$version" != "$latest_release" && "$older" == "$version" ]]; then
        to_delete+=("$tag")
    fi
done <<< "$tags"

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
