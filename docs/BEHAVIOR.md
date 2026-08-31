# Behavior and Triggers

This page describes when CritLog reacts and which sound files the current code
requests. “Default” refers to `CritLog/sounds/`; “Toni” refers to the alternate
`CritLog/sounds/assi/` directory selected by `/cl toni`.

## Event flow

```text
WoW event
  -> registered CritLog handler
  -> configuration flag and hard-coded condition
  -> database change and/or chat output
  -> PlaySoundFile(<active sound directory>/<filename>, "Master")
```

All sounds use the `Master` audio channel. CritLog has no independent volume
control.

## Login and ready check

| Event | Condition | Effect | Default sound | Toni sound |
| --- | --- | --- | --- | --- |
| `PLAYER_LOGIN` | Always | Initializes/migrates `CritLogDB` and prints records. | None. The `Login.mp3` call is commented out and the default file is absent. | None. `Login.mp3` exists, but the call is commented out. |
| `READY_CHECK` | `ReadySoundFlag = true` | No state change. | `Ready.mp3` | `Ready.mp3` (byte-identical) |

## Critical hits and heals

Detection runs through `COMBAT_LOG_EVENT_UNFILTERED`. Damage and heal events must
originate from the player. The level filter currently checks the selected target
rather than reliably checking the combat-log destination, and only applies to
damage events; healing crits are always recorded regardless of the current
target's level.

| Combat-log type | Condition | State change | Sound condition | Sound |
| --- | --- | --- | --- | --- |
| `SPELL_DAMAGE` | Player source, critical hit, level filter passes | Updates highest ability crit, ability, and target. | Every crit when `/cl allcrits` is enabled; also every new record. | `at_bam_babam.mp3` |
| `SWING_DAMAGE` | Player source, critical hit, level filter passes | Updates highest white-hit crit and target. | Every crit when both `/cl allcrits` and `/cl whitehit` are enabled; new records when `/cl whitehit` is enabled. | `at_bam_babam.mp3` |
| `RANGE_DAMAGE` | Player source, critical hit, level filter passes | Stores the result in the white-hit record. | Every crit with `/cl allcrits`; new records with `/cl whitehit`. | `at_bam_babam.mp3` |
| `SPELL_HEAL` | Player source, critical heal | Updates highest heal crit, ability, and target. | Every crit with `/cl allcrits`; also every new record. | `at_bam_babam.mp3` |

`/cl sound` is the master switch for `at_bam_babam.mp3` and suppresses the
clip even when the individual conditions above are met.

## Auras and abilities

This group requires `/cl aura` to be enabled. The current implementation
matches displayed English or German spell names rather than spell IDs.

| Trigger | Source/destination condition | Matched names | Selected sound |
| --- | --- | --- | --- |
| Mana Tide Totem summoned (`SPELL_SUMMON`) | Source is recognized as a party or raid member. | `Mana Tide Totem`, `Totem der Manaflut` | `Manatide.mp3` |
| Bloodlust/Heroism received (`SPELL_AURA_APPLIED`) | Destination is the player. | `Bloodlust`, `Heroism`, `Blutrausch`, `Heldentum` | `Bloodlust.mp3` |
| Innervate received | Destination is the player. | `Innervate`, `Anregen` | Randomly `Inervate1.mp3` or `Inervate2.mp3` |
| Power Infusion received | Destination is the player. | `Power Infusion`, `Seele der Macht` | Randomly `Surprise.mp3`, `Surprise2.mp3`, or `Surprise3.mp3` |
| Blessing of Protection received | Destination is the player. | `Blessing of Protection`, `Segen des Schutzes` | `Bubble.mp3` |
| Divine Intervention received | Destination is the player. | `Divine Intervention`, `Göttliches Eingreifen` | `divineInt.mp3` (fixed; the missing second clip was removed from the selection) |
| Soulstone Resurrection received | Destination is the player. | `Soulstone Resurrection`, `Seelenstein Auferstehung` | Randomly `soulstone.mp3`, `soulstone2.mp3`, or `soulstone3.mp3` |

## Deaths

All reactions below require `DeadSoundFlag = true` (`/cl dead`). Each group
also has its own feature flag.

| Dead unit | Additional condition | Default sound | Toni sound |
| --- | --- | --- | --- |
| Player | `/cl player` enabled | `MarioDeath.mp3` | `MarioDeath.mp3` |
| Character `Schnutz` | `/cl melee` enabled | `schnutz.mp3` | `schnutz.mp3` |
| Another name in `MELEE_NAMES` | `/cl melee` enabled | `wilhelm.ogg` | `wilhelm.ogg` |
| English/German name in the TBC boss list | `/cl boss` enabled | Randomly `FFX.mp3` or `Zelda.mp3` | Same files |
| Name in `TANK_NAMES` | `/cl tank` enabled | Randomly `Tank.mp3` or `Tank2.mp3` | `Tank.mp3` or `Tank2.mp3`; both currently contain the same audio |
| Name in `HEALPRIEST_NAMES` | `/cl priest` enabled | Randomly `Angels1.mp3` or `Angels2.mp3` | Same files |

The player lists are hard-coded. Roles are not derived from the current party or
raid.

## Raid-leader chat

The message only needs to arrive through `CHAT_MSG_RAID_LEADER`. An earlier
check for a specific sender is commented out.

| Case-insensitive message | Reaction |
| --- | --- |
| `raid ende` or `raid end` | Starts `bye.mp3` and immediately starts `end.mp3`. The clips may overlap. |
| `shit show` or `wipe` | Plays `wipe.mp3`. |

These chat sounds have no feature flag. Neither `/cl sound` nor `/cl dead`
disables them.

## Other code paths

| Function | Status |
| --- | --- |
| Boss killing-blow output | Prints a chat line for a matching boss name and a `_DAMAGE` event with a positive fifth payload value. The positional payload check is fragile across event types. |
| Divine Intervention second clip | `divineInt2.mp3` was removed from the sound selection because it was never shipped in either profile. Re-add it if a second clip becomes available. |
| Login sound | Commented out. |
| “Over 9k” sound `Xtreme.mp3` | Fully commented out; the file is absent from the default profile. |
| Zone logging | Handler exists, but the event is not registered. |
| Spirit of Redemption | Test code is commented out and labeled as not working. |

## Stored data

`CritLogDB` is stored per character:

- highest ability-damage crit, including ability and target
- highest white-hit/ranged crit, including target
- highest healing crit, including ability and target
- all command toggles
- active sound directory
- internal addon version

Known storage and event-handling issues are listed in the
[project README](../README.md#known-technical-issues-and-risks).
