# CritLog

CritLog is a World of Warcraft addon that records personal critical-hit and
critical-heal highscores and plays event-driven sounds for crits, deaths,
auras, and raid-leader chat triggers.

> **Project status:** Working legacy addon under active documentation and
> modernization. CritLog `0.2.1` is currently tested with Season of Discovery
> on Classic Era `1.15.9` (Interface `11509`).

## Documentation

- [Wiki home](docs/README.md)
- [Behavior and triggers](docs/BEHAVIOR.md)
- [Complete sound catalog](docs/SOUNDS.md)
- [Refactoring plan](docs/REFACTORING.md)
- [Cleanup review checklist](docs/CLEANUP-REVIEW.md)

## Install

There is no build or release pipeline yet. Copy this repository's contents
into a folder named `CritLog` inside the addon directory of the Classic Era
client:

```text
World of Warcraft/
└── _classic_era_/
    └── Interface/
        └── AddOns/
            └── CritLog/
                ├── CritLog.toc
                ├── Core.lua
                ├── Data.lua
                ├── Database.lua
                ├── Sounds.lua
                ├── ChatTriggers.lua
                ├── CombatLog.lua
                ├── Commands.lua
                ├── Events.lua
                └── sounds/
```

Enable CritLog in the character selection addon list. The currently confirmed
target is Season of Discovery on Classic Era `1.15.9`.

## Current behavior at a glance

CritLog listens for four events:

| WoW event | Reaction |
| --- | --- |
| `PLAYER_LOGIN` | Initializes per-character settings and prints stored records. |
| `COMBAT_LOG_EVENT_UNFILTERED` | Detects critical spell, ranged, and melee damage; critical healing; selected auras; and deaths. |
| `READY_CHECK` | Plays a sound when enabled. |
| `CHAT_MSG_RAID_LEADER` | Reacts to hard-coded raid-leader phrases such as `raid end`, `raid ende`, `wipe`, and `shit show`. |

Highscores and settings are stored per character in `CritLogDB` through
`SavedVariablesPerCharacter`. Most sound groups are enabled by default. Damage
crits are filtered using the current target's level unless `/cl level` disables
that filter.

See [Behavior and triggers](docs/BEHAVIOR.md) for the complete event → condition
→ setting → sound matrix.

## Slash commands

`/cl` and `/critlog` are equivalent command prefixes.

| Command | Current behavior |
| --- | --- |
| `/cl` | Prints stored highscores. |
| `/cl help` | Lists all commands in chat. |
| `/cl config` | Prints the current toggles. |
| `/cl reset` | Resets highscores while retaining the current configuration. |
| `/cl mute` | Master switch: turns all sounds on/off, overriding every other sound toggle. On by default. |
| `/cl sound` | Toggles the sound for a new highscore. |
| `/cl allcrits` | Toggles sounds for every critical hit. |
| `/cl whitehit` | Toggles critical auto-attack/ranged-attack handling. |
| `/cl level` | Toggles the level filter for damage records. |
| `/cl xtreme` | Toggles the sound for hits over 9000 damage. Off by default. |
| `/cl debug` | Toggles diagnostic chat output (spell ID/name seen by aura triggers, level-filter decisions). Off by default. |
| `/cl ready` | Toggles the ready-check sound. |
| `/cl aura` | Toggles sounds for selected auras and abilities. |
| `/cl dead` | Master switch for death sounds. |
| `/cl player` | Toggles the player's own death sound. |
| `/cl melee` | Toggles death sounds for a hard-coded melee roster. |
| `/cl tank` | Toggles death sounds for a hard-coded tank roster. |
| `/cl priest` | Toggles death sounds for a hard-coded healer-priest roster. |
| `/cl boss` | Toggles death sounds for a hard-coded boss roster. |

## Repository layout

```text
critlog/
├── README.md
├── LICENSE               # MIT, code only — see License section below
├── CHANGELOG.md
├── docs/                 # Behavior, sounds, and refactoring wiki
├── tests/                # How to verify changes — see tests/README.md
│   └── lint/Dockerfile   # Containerized luacheck (Lua 5.1 + WoW globals)
├── scripts/lint.sh        # Convenience wrapper to build and run the lint container
├── .luacheckrc           # luacheck config; stds.wow lists only the WoW API CritLog calls
├── .pkgmeta              # BigWigsMods/packager config, used by release.yml on tag push
├── .github/workflows/    # CI (runs against the GitHub push mirror; Gitea has no runner yet)
├── CritLog.toc           # WoW metadata and SavedVariables declaration
├── Core.lua              # Addon namespace and version
├── Data.lua              # Sound, trigger, boss, spell, and roster catalog
├── Database.lua          # SavedVariables defaults and record reset
├── Sounds.lua            # Sound playback helpers
├── ChatTriggers.lua       # Raid-leader phrase handling
├── CombatLog.lua          # Crit, aura, death, and boss-kill handling
├── Commands.lua           # Slash commands and chat output
├── Events.lua             # Frame registration and event dispatch
└── sounds/
```

This repository's root doubles as the addon's own folder content: the
`package-as: CritLog` rule in `.pkgmeta` packages it into a `CritLog/` folder
for distribution — `.github/workflows/release.yml` does this automatically
on every tag push, matching what manual installation above does by hand.

## Hard-coded data inventory

The following data is centralized in `Data.lua` and cannot currently
be managed through an options UI or configuration file:

- installation paths and filenames for every requested sound
- English and German names for selected abilities and auras
- English and German Burning Crusade boss names
- character names grouped into melee, tank, and healer-priest rosters
- special-case behavior for the character `Schnutz`
- raid-leader phrases that trigger sounds
- a nine-level threshold for relevant damage targets
- defaults for all feature toggles

## Known technical issues and risks

This is a static inventory, not a complete in-game verification:

1. **Legacy implementation:** The addon works in the current Season of
   Discovery test environment, but its combat-log handling has not yet been
   systematically verified for every relevant SoD event.
2. **Name-based boss matching:** Bosses are still matched by displayed
   English/German names instead of stable NPC IDs. (Aura/ability triggers
   now match by spell ID first, with the name kept as a fallback — see
   docs/REFACTORING.md.)
3. **Spirit of Redemption:** Test code is commented out and marked "not
   working" by the original author. Deliberately left as-is for now — see
   [docs/CLEANUP-REVIEW.md](docs/CLEANUP-REVIEW.md).
4. **No CurseForge/Wago project yet:** Static linting runs via `tests/lint/`
   and CI (see [Testing](#testing)), and `.github/workflows/release.yml`
   builds and publishes a GitHub Release with a packaged zip on every tag
   push. There is no CurseForge/WoWInterface/Wago project id or upload
   automation configured yet, so releases only reach GitHub for now.
5. **Unclear asset rights:** Audio-file origin and redistribution rights are
   undocumented and must be reviewed before public distribution.

## Next steps

The behavioral inventory, safe cleanup, data catalog, and module split are now
complete. The recommended next steps are documented in the
[Refactoring plan](docs/REFACTORING.md): replace localized name matching with
verified IDs, professionalize configuration and migrations, and add focused
tests for pure matching and migration logic.

## Development

There are no runtime dependencies or build steps. Changes are made in the
focused Lua modules listed above and must be tested in the target client.
`CritLog.toc`'s `## Version:` is the single source of truth for the version
number — `Core.lua` reads it via `GetAddOnMetadata`/`C_AddOns.GetAddOnMetadata`
at load time instead of duplicating it.

## Testing

See [tests/README.md](tests/README.md) for how to run static analysis
(`scripts/lint.sh`, a containerized `luacheck`) and the manual in-game
verification checklist. There is no headless way to execute WoW addon code
or render UI outside the real game client, so behavior changes still require
manual in-game testing.

## License

The Lua source code is MIT-licensed — see [LICENSE](LICENSE). The audio
files under `sounds/` are **not** covered by that license: their
origin and redistribution rights are undocumented and must be reviewed
before public distribution — see
[docs/SOUNDS.md](docs/SOUNDS.md#required-human-review).
