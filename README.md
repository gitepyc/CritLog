# CritLog

CritLog is a World of Warcraft addon that records personal critical-hit and
critical-heal highscores and plays event-driven sounds for crits, deaths,
auras, and raid-leader chat triggers.

> **Project status:** Working legacy addon under active documentation and
> modernization. CritLog `0.5.0` targets Season of Discovery on Classic Era
> `1.15.9` (Interface `11509`). The options panel, the Escape-key behavior,
> and editable melee/tank/heal rosters are now in-game confirmed; the
> class/role-based death-sound detection for tank/boss specifically and
> Spirit of Redemption are not yet — see [CHANGELOG.md](CHANGELOG.md) for
> the versioned list.

## Documentation

- [Wiki home](docs/README.md)
- [Behavior and triggers](docs/BEHAVIOR.md)
- [Complete sound catalog](docs/SOUNDS.md)
- [Roadmap](docs/ROADMAP.md)

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
                ├── CritLog.lua
                ├── Core/
                │   ├── Constants.lua
                │   ├── Filters.lua
                │   ├── Records.lua
                │   └── CombatLog.lua
                ├── Persistence/
                │   └── Database.lua
                ├── UI/
                │   ├── Shared.lua
                │   ├── MainPanel.lua
                │   ├── SoundPanel.lua
                │   ├── AuraSoundPanel.lua
                │   ├── DeathSoundPanel.lua
                │   ├── RollSoundPanel.lua
                │   ├── RosterPanel.lua
                │   ├── HelpPanel.lua
                │   └── TitanButton.lua
                ├── Sounds.lua
                ├── ChatTriggers.lua
                ├── Commands.lua
                ├── Events.lua
                └── sounds/
```

Enable CritLog in the character selection addon list. The currently confirmed
target is Season of Discovery on Classic Era `1.15.9`.

## Current behavior at a glance

CritLog listens for six events:

| WoW event | Reaction |
| --- | --- |
| `PLAYER_LOGIN` | Initializes per-character settings and prints stored records. |
| `COMBAT_LOG_EVENT_UNFILTERED` | Detects critical spell, ranged, and melee damage; critical healing; selected auras; and deaths. |
| `READY_CHECK` | Plays a sound when enabled. |
| `CHAT_MSG_RAID_LEADER` | Reacts to hard-coded raid-leader phrases such as `raid end`, `raid ende`, `wipe`, and `shit show`. |
| `CHAT_MSG_RAID` | Reacts to a CrossGambling lottery announcement in raid chat. |
| `CHAT_MSG_SYSTEM` | Reacts to specific `/roll` results/bands on a 1-100 roll. |

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
| `/cl help` | Lists all commands in chat; the same list is also available in-game via `/cl options` -> "Help..." (a panel, not chat spam). |
| `/cl config` | Prints the current toggles. |
| `/cl reset` | Resets highscores while retaining the current configuration. |
| `/cl mute` | Master switch: turns all sounds on/off, overriding every other sound toggle. On by default. |
| `/cl sound` | Toggles the sound for a new highscore. |
| `/cl allcrits` | Toggles sounds for every critical hit. |
| `/cl whitehit` | Toggles critical auto-attack/ranged-attack handling. |
| `/cl level` | Toggles the level filter for damage records on/off; `/cl options` has a slider for how many levels below you still counts (default 9, range 1-20). |
| `/cl xtreme` | Toggles the sound for hits over 9000 damage. Off by default. |
| `/cl debug` | Toggles diagnostic chat output (spell ID/name seen by aura triggers, level-filter decisions). Off by default. |
| `/cl options` (or `/cl opt`) | Opens/closes the in-game options panel (checkboxes for every toggle above, plus preview buttons for triggerable sounds). First draft, not yet in-game verified — see [CHANGELOG.md](CHANGELOG.md). |
| `/cl ready` | Toggles the ready-check sound. |
| `/cl roll` | Toggles sounds for specific `/roll` results on a 1-100 roll (1, 69, 95+, 100, lowest range). |
| `/cl gamble` | Toggles the lottery sound (CrossGambling raid-chat announcement). |
| `/cl aura` | Toggles sounds for selected auras and abilities. |
| `/cl player` | Toggles the player's own death sound. |
| `/cl dps` | Toggles the Damage Dealer death sound between `none`/`both`; `/cl options` -> Death Sounds has a dropdown for `experimental`-only or `roster`-only. Experimental: melee-capable class, not flagged Healer - the roster/name-list side isn't melee-only, ranged DPS names belong there too. |
| `/cl tank` | Same toggle, for the tank death sound. Experimental: assigned raid Tank role. |
| `/cl healer` | Same toggle, for the healer death sound. Experimental: assigned raid Healer role, any class (Priest, Holy Paladin, Resto Druid, Resto Shaman, ...). Excludes a death delayed by Spirit of Redemption - see `/cl spirit`. |
| `/cl spirit` | Toggles the Spirit of Redemption sound (a Priest's death delayed ~15s by the talent - Priest-only, unlike `/cl healer` above; own sound file, not shared with the plain healer death sound). Independent of `/cl healer` - plain on/off, not a detection mode; there's no roster equivalent for "this death was Spirit-delayed". |
| `/cl boss` | Same toggle, for the boss death sound. Experimental: `UnitClassification` (`worldboss`). |

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
├── CritLog.lua           # Addon namespace and version
├── Core/                 # Domain logic - matching rules and event decoding
│   ├── Constants.lua     # Sound, trigger, boss, spell, and roster-label catalog
│   ├── Filters.lua       # Pure eligibility rules (no WoW API calls) - see below
│   ├── Records.lua       # Pure highscore-record rules (no WoW API calls)
│   └── CombatLog.lua     # Combat-log capture/decoding; the "impure shell" around Filters/Records
├── Persistence/          # CritLogDB reads/writes
│   └── Database.lua      # Defaults, migrations, record reset, roster CRUD
├── UI/                   # In-game options panels (/cl options), first draft
│   ├── Shared.lua        # Frame/checkbox-row helpers, Escape-key stack
│   ├── MainPanel.lua     # Crit-tracking panel + Highscore List popup
│   ├── SoundPanel.lua    # Sound Settings panel
│   ├── AuraSoundPanel.lua # Aura Sounds panel (13 aura/ritual sounds, opened from Sound Settings)
│   ├── DeathSoundPanel.lua # Death Sounds panel (player + heal/DPS/tank/boss, opened from Sound Settings)
│   ├── RollSoundPanel.lua # Roll Sounds panel (6 roll-result sounds, opened from Sound Settings)
│   ├── RosterPanel.lua   # Roster Settings panel
│   ├── HelpPanel.lua     # Help panel - lists every slash command
│   └── TitanButton.lua   # Optional TitanPanel status-bar button, inert without Titan
├── Sounds.lua            # Sound playback helpers
├── ChatTriggers.lua       # Raid-leader/raid/roll chat trigger handling
├── Commands.lua           # Slash commands and chat output
├── Events.lua             # Frame registration and event dispatch
└── sounds/
```

`Core/Filters.lua` and `Core/Records.lua` take already-resolved values (a
class, a role, an amount) and return a decision - no `Unit*`/`PlaySoundFile`
calls anywhere in either file. `Core/CombatLog.lua` is what resolves live
unit state from a combat-log GUID and calls into them. This split exists so
the actual matching/highscore rules can eventually get real Lua unit tests
outside the game client, closing the gap described in
[tests/README.md](tests/README.md) - not done yet, just made possible.

This repository's root doubles as the addon's own folder content: the
`package-as: CritLog` rule in `.pkgmeta` packages it into a `CritLog/` folder
for distribution — `.github/workflows/release.yml` does this automatically
on every tag push, matching what manual installation above does by hand.

## Hard-coded data inventory

The following data is centralized in `Core/Constants.lua`. The options panel
(`/cl options`) can toggle whether each feature fires at all, and the
melee/tank/heal name rosters are now editable too (see below) — everything
else in this list is still code-only, not editable through the panel or a
configuration file:

- installation paths and filenames for every requested sound
- spell IDs for selected abilities and auras, with English/German display
  names kept as a fallback if an ID doesn't match
- English and German Burning Crusade boss names, used as a fallback for NPCs
  that live `UnitClassification` doesn't identify as `worldboss` — this list
  is still code-only, not editable through the panel
- raid-leader phrases that trigger sounds
- a nine-level threshold for relevant damage targets
- defaults for all feature toggles

The melee/tank/heal death-sound rosters are seeded from
`Persistence/Database.lua` once, then live in `CritLogDB.playerGroups` per
character — editable via
`/cl options` → "Death Sounds..." → "Roster Settings..." (Add/Remove per
category), not just a fallback for the live class/role check anymore.

## Known technical issues and risks

The options panel (including Escape-key behavior) and roster editing are
now in-game confirmed. Still not in-game verified: class/role/
classification-based death-sound detection for tank and boss specifically
(melee's false-positive bug is fixed and confirmed), spell-ID aura matching
(all fall back to the old name-based matching when the live check doesn't
resolve), and Spirit of Redemption detection. No CurseForge/Wago project
configured yet - releases only reach GitHub for now. Audio-file rights are
undocumented and must be reviewed before public distribution.
Full prioritized list: [Roadmap](docs/ROADMAP.md).

## Development

There are no runtime dependencies or build steps. Changes are made in the
focused Lua modules listed above and must be tested in the target client.
`CritLog.toc`'s `## Version:` is the single source of truth for the version
number — `CritLog.lua` reads it via `GetAddOnMetadata`/`C_AddOns.GetAddOnMetadata`
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
