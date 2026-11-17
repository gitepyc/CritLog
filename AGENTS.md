# AGENTS.md

CritLog: WoW Classic Era / SoD crit and heal highscore tracker with
event-driven sounds. User docs: `README.md` (incl. repository layout),
`docs/`; contribution and release rules: `CONTRIBUTING.md` (source of truth,
read it before releasing).

## Repos

- Mainline and PRs: GitHub `gitepyc/CritLog` (tag pushes build the release
  via `.github/workflows/release.yml`; Forgejo pull-mirrors GitHub).
- Gitea `claude-bot-mh/CritLog` push-mirrors to GitHub with ref pruning:
  push branches to Gitea (they appear on GitHub within seconds), then open
  the PR on GitHub. A branch pushed only to GitHub, or deleted on Gitea, is
  removed from GitHub on the next sync and its PR closes.

## Commands

- `scripts/lint.sh` - luacheck (Lua 5.1) in a Docker image built from
  `tests/lint/Dockerfile`. Keep it at 0 warnings. No unit tests; behavior is
  verified in-game against `docs/BEHAVIOR.md` (see `tests/README.md`).
- `scripts/update-changelog.sh` - full git-cliff regen of `CHANGELOG.md`
  (Docker). Only at release time, sequence in the script header.
- `scripts/cleanup-tags.sh` - removes superseded `-dev.N` tags (dry run by
  default, `--yes` to apply).
- New WoW API globals go into the curated `stds.wow` list in `.luacheckrc`.

## Workflow rules

- Explain a proposed change and wait for agreement before committing - also
  for docs-only changes.
- Short-lived branch off `main` + PR; never commit directly to `main`.
- Large or behavior-changing reworks: PR stays open until the user confirms
  an in-game test. A test build can be tagged `-dev.N` on the branch commit.
- Merge locally (`git merge --no-ff`, push `main` to Gitea) so the merge
  commit keeps the `gitepyc` identity. Don't merge in the GitHub UI: the
  next mirror sync overwrites GitHub `main` with Gitea's.
- Commit author and committer: `gitepyc <git@brauteam.de>` (repo-local
  `git config`, set right after cloning).
- Commit subject `type: description` (`feature`/`fix`/`tweak`/`docs`/
  `debug`/`refactor`/`chore`, `ci:` = `chore`). The subject line becomes the
  changelog bullet verbatim: one short line, rationale goes into the body.
- No version bump, tag or release unless the user asks for it. Bump
  `CritLog.toc` `## Version` only right before tagging; keep incrementing
  `-dev.N` for the same target.

## Code conventions

- `CritLogDB` schema changes must keep existing saved data: add a one-time
  migration function to `MIGRATIONS` in `Persistence/Database.lua` (index =
  `SchemaVersion`, order matters), never reset data. Call the migration out
  in the commit subject so it shows in the changelog.
- `Core/Filters.lua` and `Core/Records.lua` are pure logic without WoW API
  calls; keep them that way.
- Confirmation dialogs go through `CritLog.UI.showConfirmation()`
  (`UI/Shared.lua`), never `StaticPopup_Show` directly: panels use
  FULLSCREEN strata and would hide a default-strata popup.
- On clients that block the combat log (`issecretvalue` exists) the addon
  runs in limited mode; combat-log-only options must stay greyed out there.
- Keep `LICENSE` byte-close to the SPDX MIT template (license detection);
  sound-rights notes belong in `README.md` / `docs/SOUNDS.md`.
- New files that must not ship in the addon zip go into `.pkgmeta` `ignore`.
