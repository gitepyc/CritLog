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
  group, raid-leader phrases, and both sound profiles in game.
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

Introduce central tables while the addon still has one working implementation
file:

```lua
CritLogData = {
  sounds = { ... },
  spells = { ... },
  bosses = { ... },
  playerGroups = { ... },
  chatTriggers = { ... },
}
```

Then replace displayed names with stable spell and NPC IDs where possible.
Player rosters should become SavedVariables configuration rather than source
code.

**Acceptance:** Event handlers no longer contain long filename or name lists.

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
- explicit sound profiles instead of switching a raw directory path

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
- packaging that contains only used assets — `.pkgmeta` exists as a first
  draft (`package-as: CritLog`), not yet run end-to-end or wired into CI
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
