# Changelog

**Next up:** in-game verification of the new multi-entry highscore list
(`0.5.1-dev`) and the remaining unverified death-sound/Spirit of Redemption
detection. See [docs/ROADMAP.md](docs/ROADMAP.md) for the full prioritized
list.

### Unreleased (not yet tagged)

## 0.5.1-dev

- Multi-entry highscores: top-`Constants.maxRecordEntries` (5) list per
  category instead of a single value, each entry individually deletable
  via the Highscore List popup's Delete button (`/cl options` -> "Highscore
  List..."), or a whole category at once via
  `/cl reset damage|whitehit|heal`. Ported from the `feature/multi-entry-
  highscores` branch (built before the `0.4.6-dev` file restructure, so
  merged in by hand onto the current `Core/`/`Persistence/`/`UI/` layout
  rather than as a git merge) - same underlying design, adapted to the new
  file/naming conventions (`CritLog.Constants.recordKinds`/`CritLogDB.records`,
  matching the `rosterKinds`/`playerGroups` split already used for rosters).
  **`CritLogDB` migration**: `migrateToRecordLists()` seeds the new
  `CritLogDB.records.*` lists from the old single-value fields
  (`DamageAbilityCrit`/`DAC_Name`/`DAC_Tar` etc.) on first load after
  upgrading, guarded on `CritLogDB.records` itself so it runs exactly once.
  Those old fields are kept in `DEFAULTS` - never written again - purely so
  a stale SavedVariables file never produces a nil read. Not yet in-game
  verified.

## 0.5.0

Second stable release since `0.4.0`, folding in everything from the
`0.4.1-dev` through `0.4.9-dev` line.

- **Escape key**: fixed for real and in-game confirmed. Panels push/pop
  themselves onto a small stack so only the most-recently-opened one is
  ever registered in `UISpecialFrames`. The first attempt (`0.4.1-dev`)
  broke again on out-of-order closes (closing a non-topmost panel left a
  duplicate registration behind instead of replacing it); fixed by
  tracking the one currently-registered frame explicitly instead of
  inferring it from stack position.
- **Roster Settings** (melee/tank/priest name lists) are now fully
  editable per character, not just Add/Remove: each row is an inline-
  editable field with its own OK (confirm rename), Reset (discard the
  in-progress edit), and Remove button. `CritLogDB.playerGroups` migration
  unchanged from `0.4.4-dev` (copied once from a code-only seed, existing
  names kept).
- Fixed the melee/tank/priest death-sound class checks wrongly firing on
  enemy NPC deaths in instances - in-game reported against a Necromancer
  trash mob at Mount Hyjal. A resolved unit token is now discarded unless
  `UnitIsPlayer()` confirms it's an actual player.
- Fixed the boss killing-blow chat line only checking the English boss
  name list, not German.
- Fixed the highscore panel showing empty parentheses (e.g. "Damage crit
  (): 0 ()") before any crit of that kind was ever recorded.
- Gave Spirit of Redemption a real, working implementation: the buff's
  `SPELL_AURA_APPLIED` (spell id `27827`) is cached by GUID for any priest
  in the raid and read back once that priest's delayed real death
  arrives, instead of firing on every priest death. **Not yet in-game
  verified.**
- Restructured the file layout into `Core/`/`Persistence/`/`UI/` - pure
  code organization, no behavior change. See [README.md](README.md) for
  the layout.

Still not in-game verified: Spirit of Redemption, and the live
class/role/classification detection specifically for tank and boss deaths
(melee's false-positive bug is fixed and confirmed; the others use the
same pattern but haven't had a dedicated in-game test yet).

## 0.4.0

First stable release since `0.2.1`.

- Added a first-draft in-game options panel (`/cl options`): highscores
  with per-record/list reset, toggles split into a main crit-tracking
  panel and a separate Sound Settings panel (button-triggered), per-sound
  preview buttons, a hint line on every toggle, closes on Escape.
- Added a master sound switch (`MasterSoundFlag`/`/cl mute`) and a debug
  mode (`/cl debug`).
- Aura/ability triggers (Bloodlust, Innervate, Power Infusion, Mana Tide,
  Blessing of Protection, Divine Intervention, Soulstone) now match by
  spell ID first, name as fallback.
- **Experimental**: melee/tank/priest death sounds match by live
  class/role first; boss death/kill detection matches live
  `UnitClassification() == "worldboss"` first; both fall back to the old
  hardcoded name rosters when the live check doesn't resolve or match.
- Removed random multi-clip sound selection (every sound is now a single
  fixed file) and the special-cased `Schnutz` death sound; sound catalog
  trimmed to 18 files (from 24).
- Fixed several options-panel bugs found during review: `f.Inset`
  mis-anchoring, checkbox-column drift, preview buttons stuck on the
  hover color, a double-played white/ranged crit sound, and previews
  doing nothing while muted.
