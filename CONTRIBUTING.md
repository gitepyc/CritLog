# Contributing

CritLog is a small, actively maintained addon. This project has no formal
review board or coding-standard document - the guidelines below are just
what makes a bug report or pull request actionable.

## Reporting a bug

Only the game client can validate WoW APIs, so a good report needs the same
information [`tests/README.md`](tests/README.md#manual-in-game-verification)
asks for:

1. Exact reproduction steps.
2. The first Lua error in full, including its stack trace (`/console
   scriptErrors 1` or an error-display addon).
3. Which event/trigger was involved (crit, death, aura, roll, chat trigger, ...).
4. `/dump GetBuildInfo()` and `/dump C_AddOns.GetAddOnMetadata("CritLog", "Version")`.
5. Whether you tested with clean saved variables or an existing character's
   `CritLogDB`.

## Pull requests

- Trunk-based: `main` is the only long-lived branch. Branch off `main`
  with a short-lived feature branch and open the PR against `main`.
- Run `scripts/lint.sh` before opening the PR if you changed any `.lua` file.
- Write commit messages as `type: short description` (`feature`/`fix`/
  `tweak`/`docs`/`debug`/`refactor`/`chore`; `ci:` is accepted as an alias
  for `chore:`) - `CHANGELOG.md` is generated from these automatically via
  [git-cliff](https://git-cliff.org), not hand-edited. A commit without a
  recognized type lands in an `other` group, so the prefix is required.
  Merge commits and `chore: bump version`/`chore: release` commits are left
  out of the changelog.
- Keep the PR focused on one change - a bug fix doesn't need unrelated
  cleanup bundled in.

## Releasing

- Tags: `X.Y.Z` or `X.Y.Z.W` for a real release, `X.Y.Z(.W)-dev.N` for a
  prerelease pending in-game verification (dotted number, so version
  precedence sorts correctly - not a bare `-dev` suffix). Both live on
  `main`. `legacy-*` tags are archival.
- To release: bump `CritLog.toc`'s `## Version:` and commit it as
  `chore: bump version to X.Y.Z for release`, tag it, run
  `scripts/update-changelog.sh`, amend the result into the same commit,
  move the tag onto the amended commit, then push `main` and the tag (see
  the script's header comment for the exact sequence). This way the
  generated `CHANGELOG.md` section reads the tag's real commit date.
- `.github/workflows/release.yml` packages the addon and marks the GitHub
  Release as a prerelease automatically whenever the tag contains a `-`.
- Keep incrementing `-dev.N` for the same target version across iterations -
  only bump the version itself when starting toward a genuinely new target,
  not on every change. Only one `-dev.N` tag exists per unreleased version:
  when tagging `-dev.N+1`, remove `-dev.N`. Once a build is confirmed working
  in-game, tag the real release and remove all of that version's `-dev.N`
  tags. `scripts/cleanup-tags.sh` does this (dry run by default, `--yes` to
  apply); deleting a tag leaves its GitHub release behind as a draft, which
  has to be deleted separately.
- `cliff.toml`'s `ignore_tags` folds every `-dev.N` tag's commits into the
  next real release's section automatically - `CHANGELOG.md` never shows
  `X.Y.Z-dev.1`/`.2`/... as separate permanent entries, only the final
  `X.Y.Z` heading with everything since the previous real release. The
  in-progress, not-yet-tagged-clean work shows as `## Unreleased` until
  then. `scripts/update-changelog.sh` fails if a `-dev.N` heading ever shows
  up anyway.
- `release.yml` builds the release notes from the explicit range
  `<last real tag>..<tag>` for prereleases and real releases alike, so a
  real release's notes include every folded-in `-dev.N` commit. It does not
  use git-cliff's `--current`, which returns empty notes while any `-dev.N`
  tag still sits inside the range.
