# Changelog

**Next up:** the multi-entry highscore list (top-5 per category,
individually deletable), built on its own `feature/multi-entry-highscores`
branch and not yet merged. See [docs/ROADMAP.md](docs/ROADMAP.md) for the
full prioritized list.

### Unreleased (not yet tagged)

## 0.4.4-dev

- Made the melee/tank/priest death-sound name rosters editable per
  character: `/cl options` → "Roster Settings..." now shows each
  category's name list with Add/Remove controls, instead of them being
  fixed in the addon's code.
  **`CritLogDB` migration**: adds a new `CritLogDB.playerGroups` table,
  copied once from `CritLog.Data.playerGroups` (`Database.lua`'s
  `migratePlayerGroups()`, guarded on `CritLogDB.playerGroups` itself so
  it runs exactly once regardless of which version a character upgrades
  from). Existing characters keep every name that was already in the
  hardcoded roster - nothing is dropped or reset. `CombatLog.lua` reads
  only the new `CritLogDB` copy from now on, never the old
  `CritLog.Data.playerGroups` table directly, so removing a name that
  used to be a hard-coded default now works the same as removing one you
  added yourself. Not yet in-game verified.

## 0.4.3-dev

- Fixed the boss killing-blow chat line only checking the English boss
  name list, not German - a pre-existing asymmetry with the death-sound
  check below it, which has always checked both languages.

## 0.4.2-dev

- Fixed the melee/tank/priest death-sound class checks (added in
  `0.3.0-dev`) wrongly firing on enemy NPC deaths in instances - reported
  in-game against a Necromancer trash mob at Mount Hyjal.
  `UnitClass()`/`UnitGroupRolesAssigned()` aren't guaranteed `nil` for
  NPCs (some carry a class internally), so a resolved unit token is now
  discarded unless `UnitIsPlayer()` confirms it's an actual player,
  falling back to the name roster exactly like an unresolved token
  already did.

## 0.4.1-dev

- Fixed Escape closing every open options panel at once instead of just
  the topmost one. `UISpecialFrames` natively hides every registered,
  shown frame in a single keystroke; panels now push/pop themselves on a
  small stack so only the most-recently-opened one is ever actually
  registered, closing them one at a time like a normal window stack.

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
