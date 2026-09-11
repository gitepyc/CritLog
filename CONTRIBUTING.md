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

- Branch off `main` (there's no separate `dev` branch - trunk-based,
  short-lived feature branches only) and open the PR against `main`.
- Run `scripts/lint.sh` before opening the PR if you changed any `.lua` file.
- Write commit messages as `type: short description` (`feature`/`fix`/
  `tweak`/`docs`/`debug`/`refactor`/`chore`) - `CHANGELOG.md` is generated
  from these automatically via [git-cliff](https://git-cliff.org), not
  hand-edited.
- Keep the PR focused on one change - a bug fix doesn't need unrelated
  cleanup bundled in.

## Releasing

- Tags follow [SemVer 2.0.0](https://semver.org): `X.Y.Z` for a real
  release, `X.Y.Z-dev.N` for a prerelease pending in-game verification
  (dotted number, so version-precedence sorts correctly - not a bare
  `-dev` suffix). Both live on `main`; there's no separate branch for
  "not yet verified" state.
- Bump `CritLog.toc`'s `## Version:`, commit, tag, then run
  `scripts/update-changelog.sh` and fold the result into the same commit
  (see that script's header comment for the exact sequence) - this way the
  generated CHANGELOG.md section reads the tag's real commit date.
- `.github/workflows/release.yml` marks the GitHub Release as a prerelease
  automatically whenever the tag contains a `-`.
- Keep incrementing `-dev.N` for the same target version across iterations -
  only bump the version itself when starting toward a genuinely new target,
  not on every change. Once a `-dev.N` build is confirmed working in-game,
  tag the same commit again without the suffix (the real release) and
  delete the now-superseded `-dev.N` tag(s) for that target.
