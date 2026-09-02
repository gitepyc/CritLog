# Changelog

**Next up:** in-game verification of the new multi-entry highscore list
and the remaining unverified death-sound/Spirit of Redemption detection.
See [docs/ROADMAP.md](docs/ROADMAP.md) for the full prioritized list.

### Unreleased (not yet tagged)

## 0.5.13-dev

- Added a Help panel (`/cl options` -> "Help...", new `UI/HelpPanel.lua`)
  listing every slash command in-game, instead of only via `/cl help`
  printing to chat. Both now read from one shared list
  (`CritLog.Constants.helpLines`) so they can't drift apart.
- Renamed the `/cl melee` command to `/cl dps`, matching the earlier
  Damage Dealer wording rename - the underlying field
  (`CritLogDB.MeleeDetectionMode`) is unchanged, only the typed command
  word changed.

## 0.5.12-dev

- Wording: "Soulstone Resurrection" renamed to "Soulstone Applied" - the
  sound plays when the buff lands on you (`SPELL_AURA_APPLIED`), not when
  you're actually resurrected by it. The real in-game buff name happens to
  be "Soulstone Resurrection" (kept as the name-match fallback, unchanged),
  which made the old label read as if it triggered on the resurrection.
  Also fixed the stale "Melee death"/"melee-roster" wording in
  `docs/SOUNDS.md`, missed in the earlier Damage Dealer rename.

## 0.5.11-dev

- Wording: "Melee death sound" / roster category renamed to "Damage
  Dealer" - the roster (name-list) side was never actually restricted to
  melee, just labeled that way, and ranged DPS names belong there too.
  The live "Experimental" check (`isMeleeClass`) is unchanged, still
  melee-specific. `/cl melee` command name unchanged.

## 0.5.10-dev

- Removed the `DeadSoundFlag` master switch - it only ever gated the four
  detection-mode categories (Melee/Tank/Priest/Boss), which already have
  their own off state (`none`) each, making the shared master redundant.
  `/cl dead` is gone; `/cl player`/`PlayerSoundFlag` (unaffected, always
  had its own toggle) still controls the player's own death sound.
- Fixed the detection-mode dropdowns not opening at all in-game (in-game
  reported: no menu appeared, value stayed on "Both" everywhere). The
  options panels use `TOOLTIP` strata to stay above other addons' windows,
  but Blizzard's shared dropdown-list frames render at a lower fixed
  strata by default - the menu was almost certainly opening behind our
  own panel. Now bumps `DropDownList1`/`DropDownList2` to `TOOLTIP` when a
  dropdown button is clicked.
- The None/Experimental/Roster/Both explanation is now spelled out once
  (on the Priest row, first of the four) instead of repeated on all four
  dropdown rows; the other three just note their own live-check condition.

## 0.5.9-dev

- Added `/cl opt` as a short alias for `/cl options`.

## 0.5.8-dev

- Added a "Reset All" button to the Highscore List popup that clears every
  category's list at once, gated behind a confirmation dialog
  (`StaticPopupDialogs`) since it's the only highscore action that can't
  be undone by just waiting for a new crit. Established as the general
  rule going forward: any future "reset/delete everything at once" action
  needs a confirmation; single-entry/single-category actions (already
  easy to recover from) don't.

## 0.5.7-dev

- Main panel's topmost highscore Reset button now reads "Reset all"
  (wording only - still just clears the Damage crit category, same as
  before).
- The 7 individual aura/spell checkboxes under "Aura/spell sound" are now
  visibly a sub-category: smaller checkboxes, smaller label font, and
  indented, instead of looking like 7 more peers of the master toggle.
  `CritLog.UI.buildToggleRows` gained an `indent = true` per-entry option
  for this (`UI/Shared.lua`).

## 0.5.6-dev

- Melee/Tank/Priest/Boss death-sound detection is now a 4-way mode
  (`None`/`Experimental`/`Roster`/`Both`) via a dropdown in the Sound
  Settings panel, instead of a plain on/off flag that always used live
  detection with roster fallback. `Experimental` uses only the live
  class/role/classification check (no roster fallback); `Roster` uses only
  the name list (live check ignored even if it matches); `Both` is the
  original default behavior. Requested. `/cl priest`/`melee`/`tank`/`boss`
  still work as a quick `None`/`Both` toggle; the dropdown is needed for
  `Experimental`/`Roster` only.
  **`CritLogDB` migration**: `migrateDetectionModes()` seeds the new
  `CritLogDB.<Kind>DetectionMode` fields from the old
  `<Kind>SoundFlag` booleans (`true` -> `"both"`, `false` -> `"none"`) on
  first load after upgrading, guarded per-category on the new field
  itself. The old flags are kept in `DEFAULTS` - never written again -
  purely so a stale SavedVariables file never produces a nil read.

## 0.5.5-dev

- The 7 aura/spell sounds (Bloodlust, Innervate, Power Infusion, Blessing
  of Protection, Divine Intervention, Mana Tide Totem, Soulstone) are now
  individually toggleable in the Sound Settings panel, each with its own
  checkbox and preview button, instead of being all-or-nothing under
  `AuraSoundFlag` (still the master switch, gating all 7). Requested.
  Replaces the compact preview-only button grid that previously sat under
  the master toggle.

## 0.5.4-dev

- Highscore List popup redesigned as an actual table: a category heading
  (Damage/White Hit/Heal Crit) and a column header row (#/Amount/Ability/
  Target) per category, with each entry's values aligned into columns
  instead of one combined "label (ability): amount (target)" line.
  Requested after testing the multi-entry list. Widened the popup
  (420 -> 460) and gave it more height (460 -> 520) for the extra header
  rows.

## 0.5.3-dev

- Fixed the melee/tank/priest death-sound class/role checks (and Spirit of
  Redemption) firing on any player death that happened to resolve a live
  unit token, regardless of whether that player was actually in your
  group - in-game reported. Now also requires
  `UnitInParty(destName) or UnitInRaid(destName)`, same check already used
  for the Mana Tide Totem aura trigger. The name-roster fallback is
  unaffected - it's an explicit named allowlist, not a live-detection
  heuristic that needs this sanity check.

## 0.5.2-dev

- Highscore lists now track more entries than they display: up to
  `Constants.maxTrackedEntries` (10) per category, but the Highscore List
  popup only ever shows the top `Constants.maxDisplayEntries` (5) -
  requested so deleting a couple of bad entries from the visible list
  (e.g. two false positives) doesn't need brand new crits to refill it;
  the next-best already-tracked entries shift into view immediately
  instead. Previously tracking and display shared one cap
  (`Constants.maxRecordEntries`, now split into the two above).

## 0.5.1-dev

- Multi-entry highscores: list per category instead of a single value,
  each entry individually deletable
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
