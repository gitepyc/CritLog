# Changelog

## Unreleased

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
