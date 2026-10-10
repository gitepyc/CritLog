# CritLog

CritLog is a World of Warcraft addon that keeps your personal critical-hit
and critical-heal highscores and plays sounds for new records, deaths,
ready checks, `/roll` results, auras and more - all of it configurable.

## Install

1. Download `CritLog-<version>.zip` from the
   [latest release](https://github.com/gitepyc/CritLog/releases/latest).
2. Extract it into your AddOns folder
   (`World of Warcraft/<client folder>/Interface/AddOns/`, e.g.
   `_classic_era_`), so that `AddOns/CritLog/CritLog.toc` exists afterwards.
3. Start the game (or `/reload`) and make sure CritLog is enabled in the
   addon list on the character selection screen.

Highscores and settings are stored per character. To update, repeat the
steps above with the newer zip.

## Getting started

CritLog works out of the box: it records your best critical hits and
critical heals and plays its sounds right away. Every sound and feature can
be switched on or off.

- `/cl` prints your current highscores in chat.
- `/cl options` (or `/cl opt`) opens the options panel.
- `/cl help` lists all commands, `/cl mute` is the master switch for all
  sounds.

**Options panel**

- *Enable level filter* / *Max levels below you* - crits against much
  lower-level targets don't count as highscores (bosses always count).
- *Boss killing-blow chat message* - announces who landed the killing blow
  on a boss.
- *Sounds enabled* - turns all CritLog sounds on/off without changing the
  individual settings.
- **Highscore List...** - your top 5 per category (damage crit, white-hit
  crit, heal crit); deleting an entry moves the next-best up. Delete single
  entries, reset everything, or post your current best per category to
  yourself, Guild, Party, Raid or a whisper target.
- **Sound Settings...** - toggle each sound group and preview the sounds.
  Sub-panels cover aura/spell sounds, death sounds (you, bosses, and the
  dps/tank/healer roles with editable rosters) and `/roll` sounds.
- **Help...** - the full command list, in-game.

Something not working? `/cl debug` turns on diagnostic chat output; see
[CONTRIBUTING.md](CONTRIBUTING.md) for how to report a bug.

## Titan Panel integration

If Titan Panel is installed, CritLog registers a plugin for it. Without
Titan Panel none of this is loaded.

To show it, right-click the Titan Panel bar and pick **CritLog** from the
**Combat** category.

- **Button:** `CL: <damage>/<white hit>/<heal>` next to the CritLog icon -
  your current best crit per category, `-` where there is no record yet. It
  updates the moment a new highscore is set.
- **Tooltip:** hovering shows your best entry per category in full (amount,
  ability, target), colored like the options panel.
- **Left-click:** opens the CritLog options panel.
- **Right-click:** Titan's standard plugin menu (show/hide icon and label,
  remove from bar) plus *Options* and *Reset All Highscores* (with the usual
  confirmation).

## Documentation

- [Wiki home](docs/README.md)
- [Behavior and triggers](docs/BEHAVIOR.md)
- [Complete sound catalog](docs/SOUNDS.md)
- [Roadmap](docs/ROADMAP.md)
- [Contributing](CONTRIBUTING.md) - bug report checklist, pull request guidelines, and the release process

## Current behavior at a glance

CritLog reacts to these events:

| WoW event | Reaction |
| --- | --- |
| `PLAYER_LOGIN` | Initializes per-character settings and prints stored records. |
| `COMBAT_LOG_EVENT_UNFILTERED` | Detects critical spell, ranged, and melee damage; critical healing; selected auras; and deaths. |
| `READY_CHECK` | Plays a sound when enabled. |
| `CHAT_MSG_RAID` / `CHAT_MSG_PARTY` / `CHAT_MSG_GUILD` | Reacts to a CrossGambling lottery announcement in raid, party, or guild chat. |
| `CHAT_MSG_SYSTEM` | Reacts to specific `/roll` results/bands. |

Highscores and settings live in `CritLogDB` (`SavedVariablesPerCharacter`).
Most sound groups are enabled by default. Damage
crits are filtered using the current target's level unless `/cl level`
disables that filter.

See [Behavior and triggers](docs/BEHAVIOR.md) for the complete event -> condition
-> setting -> sound matrix.

## Slash commands

`/cl` and `/critlog` are equivalent command prefixes. The same list is
available in-game via `/cl help` or `/cl options` -> "Help...".

| Command | Behavior |
| --- | --- |
| `/cl` | Prints your current best per category. |
| `/cl reset` | Clears all highscore lists after a confirmation; settings are kept. |
| `/cl reset damage/whitehit/heal` | Clears one category's list (with confirmation). |
| `/cl level` | Toggles the level filter (on by default; targets up to 9 levels below you still count - the options panel has a slider, range 1-20). |
| `/cl options` (or `/cl opt`) | Opens/closes the options panel. |
| `/cl config` | Prints the current settings. |
| `/cl help` | Lists all commands. |
| `/cl debug` | Diagnostic chat output for troubleshooting (off by default). |
| `/cl mute` | Master sound switch, overrides every other sound toggle (sounds enabled by default). |
| `/cl sound` | Sound on a new personal highscore (on by default). |
| `/cl allcrits` | Plays that sound on every crit, not just new highscores (off by default). |
| `/cl whitehit` | Includes white-hit (auto-attack/ranged) crits in the sounds above; ability crits count either way (on by default). |
| `/cl xtreme` | Extra sound when a hit deals over 9000 damage (off by default). |
| `/cl ready` | Sound when a ready check starts (on by default). |
| `/cl gamble` | Lottery sound, triggered by a CrossGambling announcement in raid/party/guild chat (on by default). |
| `/cl roll` | Master switch for the 6 `/roll` result sounds (1, 69, max, plus three percentage bands that work for any range starting at 1) - each one individually in the Roll Sounds panel (on by default). |
| `/cl aura` | Master switch for 13 individually toggleable aura/ritual sounds - see the Aura Sounds panel (on by default). |
| `/cl player` | Your own death sound (on by default). |
| `/cl boss` | Boss death sound (off by default). |
| `/cl bosskill` | Chat message naming who landed the killing blow on a boss - also on the main options panel (on by default). |
| `/cl dps` / `tank` / `healer` | Toggles that role's death sound between None and Both (default Both); the Death Sounds panel dropdown also offers Role-only (live assigned role) and Roster-only (saved name list). DPS means any group member who isn't assigned Tank or Healer. |

## Installing from source

For unreleased changes, copy this repository's contents into a folder named
`CritLog` inside your client's addon directory
(`World of Warcraft/<client folder>/Interface/AddOns/CritLog/`) and enable
it in the character selection addon list. See [Repository layout](#repository-layout)
for what belongs in there.

## Repository layout

```text
critlog/
├── README.md
├── CONTRIBUTING.md       # Bug report checklist, PR guidelines, release process
├── LICENSE               # MIT, code only — see License section below
├── CHANGELOG.md
├── docs/                 # Behavior, sounds, and roadmap docs
├── tests/                # How to verify changes — see tests/README.md
│   └── lint/Dockerfile   # Containerized luacheck (Lua 5.1 + WoW globals)
├── scripts/              # lint.sh (containerized luacheck), normalize-sounds.sh (sound loudness, see docs/SOUNDS.md),
│                         # update-changelog.sh and cleanup-tags.sh (release tooling, see CONTRIBUTING.md)
├── cliff.toml            # git-cliff config - CHANGELOG.md and release notes are generated from commit messages
├── .luacheckrc           # luacheck config; stds.wow lists only the WoW API CritLog calls
├── .pkgmeta              # BigWigsMods/packager config, used by release.yml on tag push
├── .github/workflows/    # lint.yml (luacheck) and release.yml (packaging + release notes); run on the GitHub push mirror
├── CritLog.toc           # WoW metadata and SavedVariables declaration
├── CritLog.lua           # Addon namespace and version
├── Core/                 # Domain logic - matching rules and event decoding
│   ├── Constants.lua     # Sound, trigger, boss, spell, and roster-label catalog
│   ├── Filters.lua       # Pure eligibility rules (no WoW API calls) - see below
│   ├── Records.lua       # Pure highscore-record rules (no WoW API calls)
│   └── CombatLog.lua     # Combat-log capture/decoding; the "impure shell" around Filters/Records
├── Persistence/          # CritLogDB reads/writes
│   └── Database.lua      # Defaults, migrations, record reset, roster CRUD
├── UI/                   # In-game options panels (/cl options)
│   ├── Shared.lua        # Frame/checkbox-row helpers, Escape-key stack
│   ├── MainPanel.lua     # Crit-tracking panel + Highscore List popup
│   ├── SoundPanel.lua    # Sound Settings panel
│   ├── AuraSoundPanel.lua # Aura Sounds panel (13 aura/ritual sounds, opened from Sound Settings)
│   ├── DeathSoundPanel.lua # Death Sounds panel (player + heal/DPS/tank/boss, opened from Sound Settings)
│   ├── RollSoundPanel.lua # Roll Sounds panel (6 roll-result sounds, opened from Sound Settings)
│   ├── RosterPanel.lua   # Roster Settings panel
│   ├── HelpPanel.lua     # Help panel - lists every slash command
│   └── TitanButton.lua   # Optional Titan Panel plugin, inert without Titan
├── Sounds.lua            # Sound playback helpers
├── ChatTriggers.lua       # Chat trigger handling (lottery, roll results)
├── Commands.lua           # Slash commands and chat output
├── Events.lua             # Frame registration and event dispatch
├── media/                # Addon icon
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
on every tag push, matching what the manual installation above does by hand.

## Hard-coded data inventory

The following data is centralized in `Core/Constants.lua`. The options panel
(`/cl options`) can toggle whether each feature fires at all, and the
dps/tank/heal name rosters are editable too (see below) - everything else in
this list is code-only, not editable through the panel or a configuration
file:

- installation paths and filenames for every requested sound
- spell IDs for selected abilities and auras, with English/German display
  names kept as a fallback if an ID doesn't match
- chat trigger phrases
- defaults for all feature toggles (including the default level-filter
  threshold of nine levels, which is adjustable through the options panel)

The dps/tank/heal death-sound rosters are seeded from
`Persistence/Database.lua` once, then live in `CritLogDB.playerGroups` per
character - editable via
`/cl options` -> "Death Sounds..." -> "Roster Settings..." (Add/Remove per
category).

## Known technical issues and risks

Behavior can only be verified in-game (see [Testing](#testing)). Spell-ID aura matching falls back to
the older name-based matching when the live ID check doesn't resolve. Full
prioritized list: [Roadmap](docs/ROADMAP.md).

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

The Lua source code is MIT-licensed — see [LICENSE](LICENSE).
