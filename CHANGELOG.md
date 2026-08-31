# Changelog

## Unreleased

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
