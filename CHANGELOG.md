# Changelog

## Unreleased

- Revived the "over 9000 damage" sound as a real feature: added
  `XtremeSoundFlag`/`/cl xtreme`, off by default, using the same
  `sourceGUID == UnitGUID("Player")` check already used elsewhere instead of
  the original's fragile `Split()`-based string parsing.
- Removed the login-sound feature entirely (it had a live `/cl login`
  toggle, but no code path ever played anything): `LOGIN_SOUND`,
  `LoginSoundFlag`, the `/cl login` command, its `help`/`config` lines, and
  `Login.mp3`.
- Removed dead code with no live surface: the unreachable `ZONE_CHANGED`
  handler (its `RegisterEvent` call was already commented out) and
  `Split()` (only ever referenced inside a commented-out debug condition).
- Removed `CritLog/sounds/more sounds/` (14 files) — never referenced by
  any trigger.
- Left Spirit of Redemption's commented-out test code untouched,
  deliberately — may get a real fix later.
- `CritLogDB` migration verified again for all of the above:
  `CRITLOG_VERSION` unchanged, so `LoginSoundFlag` simply stops being
  read/written for existing characters, and the new `XtremeSoundFlag` reads
  as `nil` (falsy) for anyone who doesn't have it yet — off by default with
  no explicit migration step needed.
- Sound catalog is now 24 files, all in active use (down from 39; the very
  first count in this cleanup was 69). See docs/SOUNDS.md and
  docs/CLEANUP-REVIEW.md.
- Made the Toni sound set the addon's only profile and removed the old
  default-only clips (25 active files now, down from 53, ~4.18 MB →
  ~3.13 MB). `/cl toni`, `ToniFlag`, `SoundFile`, and the whole
  `ResolveSound()`/dedup-alias mechanism from the previous step are gone —
  there's only one profile now, so nothing to resolve between. Power
  Infusion and Tank death now play a single fixed clip instead of
  "randomly" picking between files that were already identical in the Toni
  set. `CritLogDB` migration verified: `CRITLOG_VERSION` is unchanged, so
  existing characters' saved data is untouched on login; the now-unused
  `ToniFlag`/`SoundFile` fields simply stop being read. See
  docs/CLEANUP-REVIEW.md for what's still worth cutting as dead weight
  (disabled-feature constants/assets, hardcoded raid rosters, the unused
  `more sounds/` candidates folder).
- Deduplicated the sound catalog: 16 files that were byte-identical to
  another file already in the catalog were removed (69 → 53 files,
  ~5.68 MB → ~4.18 MB). `CritLog.lua` now resolves sound paths through a new
  `ResolveSound()` helper (`SHARED_WITH_DEFAULT`, `TONI_ALIASES`) instead of
  raw string concatenation, so removed filenames transparently redirect to
  the one physical copy that's left. No change to what plays in game, with
  one caveat already true before this change: the Toni-profile "random"
  picks for Power Infusion and Tank death always played the same clip
  because the candidate files were identical — that's now explicit in code
  instead of coincidental. See docs/SOUNDS.md and docs/CLEANUP-REVIEW.md.
- Fixed `divineInt2.mp3` selection pointing at a file that was never shipped;
  Divine Intervention now plays the one clip that exists.
- Fixed the Toni sound profile missing `soulstone2.mp3`.
- Fixed the Soulstone random range so `soulstone3.mp3` is reachable.
- Fixed critical heals being gated by the enemy target-level filter, which
  only makes sense for damage crits.
- Fixed several accidental global variable leaks (missing `local`).
- Fixed `/cl reset` dropping the schema version and active configuration.
- Fixed the highscore printout showing the wrong target name.
- Added `.luacheckrc` and a containerized `luacheck` setup (`tests/`,
  `scripts/lint.sh`) for static analysis.
- Added repository scaffolding: `LICENSE` (MIT, code only — audio rights
  remain unresolved, see docs/SOUNDS.md), `.gitignore`, `.editorconfig`,
  `.pkgmeta` draft, GitHub Actions lint workflow.

## 0.1.1

Baseline version inherited from the original addon. See
[docs/BEHAVIOR.md](docs/BEHAVIOR.md) and [docs/SOUNDS.md](docs/SOUNDS.md) for
a full inventory of behavior and known issues at this version.
