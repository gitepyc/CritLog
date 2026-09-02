# Changelog

## Unreleased

- Both options panels now close on Escape (registered via `UISpecialFrames`,
  the standard WoW convention - previously only closable by clicking the
  title bar's close button or re-running the slash command).
- Fixed options panel checkboxes drifting 4px further right on every row
  (a growing staircase down the list) - each row's hint line sits +4px
  from its own checkbox, and the next checkbox anchored to that hint
  without canceling the offset back out.
- Added per-record highscore reset (`/cl reset damage|whitehit|heal`, or a
  Reset button per line in the options panel) to clear a single false
  positive without wiping all three records.
- Split the options panel: `/cl options` now shows only the 2 crit-tracking
  toggles (`AllLevel`, `DebugFlag`) plus a "Sound Settings..." button; the
  other 13 sound toggles moved to their own panel.
- Fixed preview buttons doing nothing while `MasterSoundFlag` (mute) was on.
- Fixed a double-played sound for white-hit/ranged crits that were also a
  new highscore while both `AllCritFlag` and `WhiteHitFlag` were on.
- Clarified the "Sound for white hit crits" hint text: white-hit highscores
  need this flag, ability-crit highscores don't.
- Fixed the options panel's checkbox list rendering at the screen's
  top-left instead of inside the panel (was anchored to `f.Inset`, which
  doesn't exist on this client) and the frame being too short for its own
  content.
- Options panel now uses `TOOLTIP` frame strata so it renders above other
  addon UI (was getting covered by a WeakAuras display).
- Replaced options-panel hover tooltips with a static hint line under every
  toggle (tooltips didn't reliably trigger in-game); marked the four
  class/role/classification-based death-sound toggles "(Experimental)";
  moved `PlayerSoundFlag` out of that group since it isn't experimental;
  fixed preview button text getting stuck on the yellow hover color.
- Removed random multi-clip sound selection - every sound is now exactly
  one fixed file. Removed the special-cased `Schnutz` death sound (now uses
  the standard melee sound). Deleted 6 now-unused sound files and renamed
  `Angels1.mp3`→`Angels.mp3`, `Inervate2.mp3`→`Innervate.mp3` (also fixes
  the "Inervate" typo). Sound catalog is 18 files (was 24).
- Added a master sound switch (`MasterSoundFlag`/`/cl mute`), on by default.
- Added a first-draft in-game options panel (`/cl options`) with
  highscores, all toggles, and per-sound preview buttons.
- **Experimental, not yet in-game verified**: melee/tank/priest death
  sounds now match by live class/role first, falling back to the old
  hardcoded name rosters. Boss death/kill detection now matches live
  `UnitClassification() == "worldboss"` first, same fallback pattern. Also
  fixed a latent crash risk in `PrintBossKillingBlow` (unguarded `overkill`
  type check).
- Added debug mode (`/cl debug`) with diagnostic chat output for aura
  matching and the level filter.
- Aura/ability triggers (Bloodlust, Innervate, Power Infusion, Mana Tide,
  Blessing of Protection, Divine Intervention, Soulstone) now match by
  spell ID first, name as fallback. IDs not yet in-game verified.

## 0.2.1

- Fixed the damage-crit level filter using the wrong unit's level (the
  selected UI target instead of the actual combat-log destination).
- Removed `README.txt` (superseded by `README.md`/`docs/`).
- `CritLog.toc`'s `## Version:` is now the single source of truth
  (`Core.lua` reads it via `GetAddOnMetadata`).
- Documented (not yet implemented): class-based death-sound matching,
  Spirit of Redemption fix/removal decision.

## 0.2.0

- Added `.github/workflows/release.yml`: tags now auto-build and publish a
  GitHub Release via the BigWigsMods packager.
- Split the former monolithic `CritLog.lua` into focused modules
  (Core/Data/Database/Sounds/ChatTriggers/CombatLog/Commands/Events).
- Centralized sounds, spells, bosses, player rosters, and chat-trigger
  phrases in `CritLog.Data`.
- `CritLogDB` version upgrades no longer reset existing data - only
  back-fill missing fields.
- Split CritLog out of the former `wow-addons` monorepo into its own
  repository, full history preserved.
- Revived the "over 9000 damage" sound as a real feature
  (`XtremeSoundFlag`/`/cl xtreme`, off by default).
- Removed the login-sound feature entirely (toggle existed but no code
  path ever played anything).
- Removed dead code: unreachable `ZONE_CHANGED` handler, unused `Split()`.
- Removed `CritLog/sounds/more sounds/` (14 files, never referenced).
- Sound catalog deduplicated and reduced to 24 files (from 69 originally);
  made the "Toni" sound set the addon's only profile.
- Fixed several sound-selection bugs: `divineInt2.mp3` pointing at a
  missing file, `soulstone2.mp3` missing from the Toni profile, an
  unreachable Soulstone random-range slot, critical heals wrongly gated by
  the enemy-level filter, `/cl reset` dropping schema version/config, the
  highscore printout showing the wrong target name, and several accidental
  global variable leaks.
- Added `.luacheckrc` + containerized `luacheck` setup, repo scaffolding
  (`LICENSE`, `.gitignore`, `.editorconfig`, `.pkgmeta`, lint CI workflow).

## 0.1.1

Baseline version inherited from the original addon. See
[docs/BEHAVIOR.md](docs/BEHAVIOR.md) and [docs/SOUNDS.md](docs/SOUNDS.md) for
a full inventory of behavior and known issues at this version.
