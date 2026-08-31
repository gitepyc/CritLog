# WoW Addons

This repository contains private World of Warcraft addons. It currently hosts
one addon: **CritLog**.

> **Project status:** Working legacy addon under active documentation and
> modernization. CritLog `0.1.1` is currently tested with Season of Discovery
> on Classic Era `1.15.9` (Interface `11509`).

## Documentation

- [Wiki home](docs/README.md)
- [Behavior and triggers](docs/BEHAVIOR.md)
- [Complete sound catalog](docs/SOUNDS.md)
- [Refactoring plan](docs/REFACTORING.md)

## Included addons

| Addon | Purpose | Status |
| --- | --- | --- |
| [CritLog](CritLog/) | Records personal critical-hit and critical-heal highscores and plays event-driven sounds. | Working legacy addon; modernization planned |

## Install CritLog

There is no build or release pipeline yet. Copy the `CritLog` directory directly
into the addon directory of the Classic Era client:

```text
World of Warcraft/
└── _classic_era_/
    └── Interface/
        └── AddOns/
            └── CritLog/
                ├── CritLog.toc
                ├── CritLog.lua
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
| `/cl sound` | Toggles the sound for a new highscore. |
| `/cl allcrits` | Toggles sounds for every critical hit. |
| `/cl whitehit` | Toggles critical auto-attack/ranged-attack handling. |
| `/cl level` | Toggles the level filter for damage records. |
| `/cl login` | Toggles the login-sound setting; playback is currently commented out. |
| `/cl ready` | Toggles the ready-check sound. |
| `/cl aura` | Toggles sounds for selected auras and abilities. |
| `/cl dead` | Master switch for death sounds. |
| `/cl player` | Toggles the player's own death sound. |
| `/cl melee` | Toggles death sounds for a hard-coded melee roster. |
| `/cl tank` | Toggles death sounds for a hard-coded tank roster. |
| `/cl priest` | Toggles death sounds for a hard-coded healer-priest roster. |
| `/cl boss` | Toggles death sounds for a hard-coded boss roster. |
| `/cl toni` | Switches between the default and alternate sound directories. The alternate set is still incomplete. |

## Repository layout

```text
wow-addons/
├── README.md
├── LICENSE               # MIT, code only — see License section below
├── CHANGELOG.md
├── docs/                 # Behavior, sounds, and refactoring wiki
├── tests/                # How to verify changes — see tests/README.md
│   └── lint/Dockerfile   # Containerized luacheck (Lua 5.1 + WoW globals)
├── scripts/lint.sh        # Convenience wrapper to build and run the lint container
├── .luacheckrc           # luacheck config; stds.wow lists only the WoW API CritLog calls
├── .pkgmeta              # Draft BigWigsMods/packager config (not yet wired into CI)
├── .github/workflows/    # CI (runs against the GitHub push mirror; Gitea has no runner yet)
└── CritLog/
    ├── CritLog.toc       # WoW metadata and SavedVariables declaration
    ├── CritLog.lua       # Current event, storage, sound, and command logic
    ├── README.txt        # Historical minimal readme
    └── sounds/
        ├── assi/         # Alternate sound set
        └── more sounds/  # Unused candidate sound files
```

## Hard-coded data inventory

The following data is embedded directly in `CritLog.lua` and cannot currently
be managed through an options UI or configuration file:

- installation paths and filenames for every requested sound
- English and German names for selected abilities and auras
- English and German Burning Crusade boss names
- character names grouped into melee, tank, and healer-priest rosters
- special-case behavior for the character `Schnutz`
- raid-leader phrases that trigger sounds
- a nine-level threshold for relevant damage targets
- defaults for all feature toggles
- the addon version, independently duplicated in the TOC file

## Known technical issues and risks

This is a static inventory, not a complete in-game verification:

1. **Legacy implementation:** The addon works in the current Season of
   Discovery test environment, but its combat-log handling has not yet been
   systematically verified for every relevant SoD event.
2. **Fragile target check:** The level filter uses the currently selected
   `target`, which is not guaranteed to be the combat-log destination. Missing
   or invalid target levels are possible. It now correctly applies only to
   damage crits, not to healing crits.
3. **Name-based localization:** Abilities and bosses are matched by displayed
   English/German names instead of stable spell and NPC IDs.
4. **Destructive version upgrades:** Any change to `CRITLOG_VERSION` replaces
   the complete per-character database instead of migrating it.
5. **Unused or disabled assets/code:** Login sound, zone handler, the “over 9k”
   sound, and the complete `more sounds/` directory are inactive.
6. **Packaging and releases not yet automated:** Static linting runs via
   `tests/lint/` and CI (see [Testing](#testing)), but there is no packaged
   release build, versioned release process, or CurseForge/Wago project yet.
   `.pkgmeta` exists as an unverified first draft.
7. **Unclear asset rights:** Audio-file origin and redistribution rights are
   undocumented and must be reviewed before public distribution.

## Next steps

The recommended sequence is documented in the [Refactoring plan](docs/REFACTORING.md):
freeze behavior with reproducible checks, centralize trigger and sound data,
fix verified defects, and only then split the code along stable boundaries.
Mechanically splitting the current file first would distribute the existing
hard-coded data and bugs across several files.

## Development

There are no external dependencies or build steps. Changes are made directly in
`CritLog/CritLog.lua` and must be tested in the target client. Until a release
pipeline exists, the versions in `CritLog.lua` and `CritLog.toc` must be kept
in sync manually.

## Testing

See [tests/README.md](tests/README.md) for how to run static analysis
(`scripts/lint.sh`, a containerized `luacheck`) and the manual in-game
verification checklist. There is no headless way to execute WoW addon code
or render UI outside the real game client, so behavior changes still require
manual in-game testing.

## License

The Lua source code is MIT-licensed — see [LICENSE](LICENSE). The audio
files under `CritLog/sounds/` are **not** covered by that license: their
origin and redistribution rights are undocumented and must be reviewed
before public distribution — see
[docs/SOUNDS.md](docs/SOUNDS.md#required-human-review).
