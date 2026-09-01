# Refactoring Plan

## Recommendation

CritLog should be split into multiple files, but not as the first isolated
change. Establish a small behavioral safety net and a centralized data catalog
first. Otherwise, the same hard-coded data and unnoticed bugs will simply be
distributed across several files.

## Recommended sequence

### 1. Freeze current behavior

- Use the matrix in [BEHAVIOR.md](BEHAVIOR.md) as a manual SoD test checklist.
- Exercise critical-hit records, ready check, every aura group, every death
  group, and raid-leader phrases in game.
- Record Lua errors with script-error reporting enabled.
- Decide which historical special cases should remain, become configurable, or
  be removed.

**Acceptance:** Every desired trigger records whether it works on Classic Era
`1.15.9` and which clip is audible.

### 2. Fix verified defects in small commits

Already completed on `fix/safe-cleanups`:

- reset retains the schema version and active configuration
- highscore output uses the stored target names
- known temporary values are local instead of global
- the alternate tank clip uses the filename requested by the code
- the `divineInt2.mp3` selection was made safe by dropping it; Divine
  Intervention now always plays the one clip that actually exists
- `soulstone2.mp3` was copied into the alternate profile, closing the gap
- the Soulstone random range now covers all three listed clips
- the healing-event branch no longer depends on the enemy target's level

**Acceptance:** No reachable sound selection points to a missing file, reset
retains settings after `/reload`, and record output shows the correct target.
Met on `fix/safe-cleanups`.

### 3. Extract data from control flow

Done. Centralized sounds, spells, bosses, player rosters, and chat-trigger
phrases under the addon namespace in `Data.lua`:

```lua
CritLog.Data = {
  sounds = { ... },
  bosses = { ... },
  playerGroups = { ... },
  spells = { ... },
  chatTriggers = { ... },
}
```

Event handlers now read `CritLog.Data.sounds.*`, `CritLog.Data.spells.*`, etc.
instead of ~30 scattered top-level constants and standalone sound-list
locals. No behavior change: verified with luacheck (still 7 warnings / 0
errors, same set as before) and a script cross-checking every sound
filename in code against every file in `sounds/` (24/24 match both ways).
`SREDEMPTION_NAMES` was deliberately left out of the catalog and untouched,
per the standing decision to leave Spirit of Redemption as-is for now.

Two things from the original version of this step were still open after
this pass; one is now also done:

- ~~Replacing displayed English/German names with stable spell IDs~~ — done
  for the 7 aura triggers (`CritLog.Data.spells`): each entry now has an
  `ids` list matched first, falling back to the `names` list if the ID
  doesn't hit. IDs are Wowhead-Classic-sourced, cross-checked against
  multiple expansion pages where possible (see CHANGELOG.md) but not
  in-game verified — the name fallback exists specifically so a wrong ID
  doesn't silently kill a trigger.
- ~~Boss/NPC matching by NPC ID or classification instead of hardcoded
  names~~ — the classification alternative considered here was implemented,
  not the NPC-ID one: boss/NPC death and killing-blow detection now check
  live `UnitClassification()` for `"worldboss"` first (see `isClassifiedBoss`
  in `CombatLog.lua`), falling back to the English/German boss name lists
  for NPCs that classification doesn't catch (5-man end bosses and similar).
  Matching by NPC ID parsed out of `destGUID` was not pursued — the
  classification check covers the highest-value case (raid/world bosses)
  with much less code. Not yet in-game verified — see CHANGELOG.md.
- ~~Player rosters (`playerGroups`) are still hardcoded names, not
  SavedVariables configuration~~ — partially superseded: melee/tank/priest
  death sounds now check live class (`UnitClass`) and assigned raid role
  (`UnitGroupRolesAssigned`) as the primary match, with `playerGroups` kept
  as a fallback for when no live unit token is available or the live check
  doesn't match. The rosters themselves are still hardcoded, not
  SavedVariables configuration — see step 5's note on this below. Not yet
  in-game verified — see CHANGELOG.md.

**Acceptance:** Event handlers no longer contain long filename or name
lists. Met.

### 4. Split along stable responsibilities

Completed on `refactor/split-modules` with this layout:

```text
CritLog/
├── CritLog.toc
├── Core.lua          # Namespace and version
├── Data.lua          # Names, rosters, triggers, and sound catalog
├── Database.lua      # Defaults, schema, and migrations
├── Sounds.lua        # Resolve and play logical sound IDs
├── CombatLog.lua     # Crits, auras, and deaths
├── ChatTriggers.lua  # Raid-leader phrases
├── Commands.lua      # Slash commands
├── Events.lua        # Frame registration and event dispatch
└── Options.lua       # In-game options panel (/cl options), first draft
```

Load the files in this order from `CritLog.toc`. Shared state belongs in one
addon namespace, not in new globals.

**Acceptance:** Every file has one clear responsibility, the TOC load order is
explicit, and shared state is namespaced. Static checks are complete; the
manual in-game behavior checklist remains required before merge.

### 5. Professionalize configuration

- versioned SavedVariables schema
- ~~UI for sound groups~~ — done, first draft: `Options.lua` (`/cl options`)
  has a checkbox for every one of the 15 `CritLogDB` toggle fields plus a
  "Preview" button for every toggle with a sound of its own. Not yet
  in-game verified — see CHANGELOG.md.
- audio channel/volume — still outstanding. All sounds play on the fixed
  `Master` channel via `PlaySoundFile`; there is no per-sound or overall
  volume control beyond `MasterSoundFlag`'s on/off mute.
- UI for player roles — still outstanding: the options panel can only
  toggle whether the melee/tank/priest/boss death sounds fire, not edit the
  underlying `playerGroups`/`bosses` name rosters. See the roster item
  below.
- ~~clip selection~~ — moot: every `CritLog.Data.sounds` entry is a single
  fixed file now (see CHANGELOG.md's random-multi-clip removal), so there's
  nothing left to select between. Preview is done (see above).
- configurable chat triggers — still outstanding
- ~~explicit sound profiles instead of switching a raw directory path~~ —
  moot: the addon now ships a single sound profile, see CHANGELOG.md and
  [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md)
- ~~replace the hardcoded melee/tank/priest death rosters with class-based
  matching~~ — implemented as a first draft: `CombatLog.lua`'s `HandleDeath`
  now checks live class (`UnitClass`)/assigned role (`UnitGroupRolesAssigned`)
  for melee/tank/priest and live `UnitClassification` (`"worldboss"`) for
  bosses as the primary match, falling back to the original hardcoded
  `playerGroups`/`bosses` name lists when no live unit token is available or
  the live check doesn't match. The name rosters themselves are unchanged
  and not yet SavedVariables-configurable. **Not yet in-game verified** —
  see CHANGELOG.md for the known blind spots accepted in this first draft
  (e.g. an unassigned real tank, or a ranged-spec hybrid class flagged as
  melee).
- give Spirit of Redemption a real, working implementation, or remove
  `SREDEMPTION_NAMES` and the disabled test block entirely — currently
  parked, not scheduled

### 6. Add quality and release automation

- Lua linting: done. `tests/lint/` containerizes `luacheck` against Lua 5.1
  with a curated WoW API globals list (`.luacheckrc`); `scripts/lint.sh` runs
  it locally, `.github/workflows/lint.yml` runs it in CI against the GitHub
  push mirror (Gitea has no Actions runner registered yet). Splitting the
  addon into per-responsibility modules (this step) dropped the accepted
  warning count from 7 to 1 — turning the former `PrintCritLogs`/`ends_with`
  global-pollution warnings into ordinary module functions removed them
  outright. The one remaining warning is the intentionally-unused
  `SREDEMPTION_NAMES`, kept for the disabled Spirit of Redemption feature.
- focused tests for pure functions, migrations, and trigger matching — still
  outstanding; no runtime/unit-test harness exists because the WoW client has
  no supported headless mode (see [tests/README.md](../tests/README.md))
- packaging that contains only used assets — done and verified: `.pkgmeta`
  (`package-as: CritLog`, `manual-changelog: CHANGELOG.md`) run locally via
  `release.sh -d -z` produces a `CritLog/` directory with only the TOC, the
  addon's Lua modules, `sounds/`, and the real `CHANGELOG.md` — no `docs/`,
  `tests/`, `scripts/`, or other repo scaffolding. Not yet wired into CI or
  an actual upload (no CurseForge/Wago project id configured)
- one source of truth for the version number — done: `Core.lua` reads
  `CritLog.toc`'s `## Version:` via `GetAddOnMetadata` instead of
  duplicating the string
- changelog and versioned releases — `CHANGELOG.md` started; no tagged
  releases yet

## Current refactoring status

The catalog-and-safety work, the responsibility-based file split, spell-ID
matching (with name fallback), classification-based boss detection, and a
first-draft options panel are all complete. None of the class/role/
classification detection or the options panel has been in-game verified
yet — that verification, not further refactoring, is the immediate next
step. Once verified, the next refactoring branch should focus on one
independently testable concern — audio volume control, SavedVariables-backed
player-roster configuration, or NPC-ID-based matching for bosses that aren't
classified `worldboss` — rather than combining configuration UI, schema
changes, and combat-log behavior in one review.
