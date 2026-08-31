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
phrases into one `local CritLogData` table (not a new global) near the top
of `CritLog.lua`:

```lua
local CritLogData = {
  sounds = { ... },
  bosses = { ... },
  playerGroups = { ... },
  spells = { ... },
  chatTriggers = { ... },
}
```

Event handlers now read `CritLogData.sounds.*`, `CritLogData.spells.*`, etc.
instead of ~30 scattered top-level constants and standalone sound-list
locals. No behavior change: verified with luacheck (still 7 warnings / 0
errors, same set as before) and a script cross-checking every sound
filename in code against every file in `sounds/` (24/24 match both ways).
`SREDEMPTION_NAMES` was deliberately left out of the catalog and untouched,
per the standing decision to leave Spirit of Redemption as-is for now.

Two things from the original version of this step are still open, not part
of this pass:

- Replacing displayed English/German names with stable spell and NPC IDs.
  Riskier than the data move above — needs verified IDs and in-game testing
  per trigger, since a wrong ID fails silently. A separate follow-up.
- Player rosters (`playerGroups`) are still hardcoded names, not
  SavedVariables configuration. Tracked under step 5.

**Acceptance:** Event handlers no longer contain long filename or name
lists. Met.

### 4. Split along stable responsibilities

Recommended target layout:

```text
CritLog/
├── CritLog.toc
├── Core.lua          # Namespace, initialization, and event dispatch
├── Data.lua          # Spell/NPC IDs, defaults, and sound catalog
├── Database.lua      # Defaults, schema, and migrations
├── Sounds.lua        # Resolve and play logical sound IDs
├── CombatLog.lua     # Crits, auras, and deaths
├── ChatTriggers.lua  # Raid-leader phrases
├── Commands.lua      # Slash commands
└── Options.lua       # Future options UI
```

Load the files in this order from `CritLog.toc`. Shared state belongs in one
addon namespace, not in new globals.

**Acceptance:** Every file has one clear responsibility and behavior from step
1 remains unchanged.

### 5. Professionalize configuration

- versioned SavedVariables schema
- UI for sound groups, audio channel/volume, and player roles
- clip selection and preview
- configurable chat triggers
- ~~explicit sound profiles instead of switching a raw directory path~~ —
  moot: the addon now ships a single sound profile, see CHANGELOG.md and
  [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md)

### 6. Add quality and release automation

- Lua linting: done. `tests/lint/` containerizes `luacheck` against Lua 5.1
  with a curated WoW API globals list (`.luacheckrc`); `scripts/lint.sh` runs
  it locally, `.github/workflows/lint.yml` runs it in CI against the GitHub
  push mirror (Gitea has no Actions runner registered yet). 79 pre-existing
  warnings remain unaddressed — mostly unused combat-log fields, unused dead
  sound constants, and the global-pollution items already tracked in step 4.
- focused tests for pure functions, migrations, and trigger matching — still
  outstanding; no runtime/unit-test harness exists because the WoW client has
  no supported headless mode (see [tests/README.md](../tests/README.md))
- packaging that contains only used assets — done and verified: `.pkgmeta`
  (`package-as: CritLog`, `manual-changelog: CHANGELOG.md`) run locally via
  `release.sh -d -z` produces a `CritLog/` directory with only
  `CritLog.toc`, `CritLog.lua`, `sounds/`, `README.txt`, and the real
  `CHANGELOG.md` — no `docs/`, `tests/`, `scripts/`, or other repo
  scaffolding. Not yet wired into CI or an actual upload (no CurseForge/Wago
  project id configured)
- one source of truth for the version number — still outstanding
- changelog and versioned releases — `CHANGELOG.md` started; no tagged
  releases yet

## First structural refactoring branch

The first structural branch should be named `refactor/catalog-and-safety`, not
“split files”. It should contain only:

1. centralized sound and trigger tables
2. protection from unavailable sounds
3. the remaining small verified defects
4. no intentional user-visible behavior change

After that, splitting files becomes substantially safer and easier to review.
