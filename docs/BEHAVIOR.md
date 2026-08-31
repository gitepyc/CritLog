# Behavior and Triggers

This page describes when CritLog reacts and which sound file the current
code requests. All sounds live under `sounds/`.

> **History:** CritLog used to ship two interchangeable sound profiles
> (default and an alternate "Toni" set, switchable with `/cl toni`). The
> Toni set was promoted to be the only profile and the command was removed;
> see [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md) for what that changed and what
> is still worth stripping as dead weight.

## Event flow

```text
WoW event
  -> registered CritLog handler
  -> configuration flag and hard-coded condition
  -> database change and/or chat output
  -> PlaySoundFile(CritLog/sounds/<filename>, "Master")
```

All sounds use the `Master` audio channel. CritLog has no independent volume
control.

## Login and ready check

| Event | Condition | Effect | Sound |
| --- | --- | --- | --- |
| `PLAYER_LOGIN` | Always | Initializes/migrates `CritLogDB` and prints records. | None. The login-sound feature was removed entirely, along with `Login.mp3`; see `CHANGELOG.md`. |
| `READY_CHECK` | `ReadySoundFlag = true` | No state change. | `Ready.mp3` |

## Critical hits and heals

Detection runs through `COMBAT_LOG_EVENT_UNFILTERED`. Damage and heal events
must originate from the player. The level filter currently checks the
selected target rather than reliably checking the combat-log destination,
and only applies to damage events; healing crits are always recorded
regardless of the current target's level.

| Combat-log type | Condition | State change | Sound condition | Sound |
| --- | --- | --- | --- | --- |
| `SPELL_DAMAGE` | Player source, critical hit, level filter passes | Updates highest ability crit, ability, and target. | Every crit when `/cl allcrits` is enabled; also every new record. | `at_bam_babam.mp3` |
| `SWING_DAMAGE` | Player source, critical hit, level filter passes | Updates highest white-hit crit and target. | Every crit when both `/cl allcrits` and `/cl whitehit` are enabled; new records when `/cl whitehit` is enabled. | `at_bam_babam.mp3` |
| `RANGE_DAMAGE` | Player source, critical hit, level filter passes | Stores the result in the white-hit record. | Every crit with `/cl allcrits`; new records with `/cl whitehit`. | `at_bam_babam.mp3` |
| `SPELL_HEAL` | Player source, critical heal | Updates highest heal crit, ability, and target. | Every crit with `/cl allcrits`; also every new record. | `at_bam_babam.mp3` |

`/cl sound` is the master switch for `at_bam_babam.mp3` and suppresses the
clip even when the individual conditions above are met.

## Extreme hits

| Combat-log type | Condition | Sound |
| --- | --- | --- |
| `SPELL_DAMAGE` | Player source, `sv4 > 9000` | `Xtreme.mp3`, only if `/cl xtreme` is enabled |

Off by default (`XtremeSoundFlag = false`). Unlike the crit tracking above,
this has no level filter and no state change — it's a standalone "hit hard
enough" alert. Toggle with `/cl xtreme`.

## Auras and abilities

This group requires `/cl aura` to be enabled. The current implementation
matches displayed English or German spell names rather than spell IDs.

| Trigger | Source/destination condition | Matched names | Sound |
| --- | --- | --- | --- |
| Mana Tide Totem summoned (`SPELL_SUMMON`) | Source is recognized as a party or raid member. | `Mana Tide Totem`, `Totem der Manaflut` | `Manatide.mp3` |
| Bloodlust/Heroism received (`SPELL_AURA_APPLIED`) | Destination is the player. | `Bloodlust`, `Heroism`, `Blutrausch`, `Heldentum` | `Bloodlust.mp3` |
| Innervate received | Destination is the player. | `Innervate`, `Anregen` | Randomly `Inervate1.mp3` or `Inervate2.mp3` |
| Power Infusion received | Destination is the player. | `Power Infusion`, `Seele der Macht` | `Surprise.mp3` (fixed — see [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md) for why this is no longer a random pick) |
| Blessing of Protection received | Destination is the player. | `Blessing of Protection`, `Segen des Schutzes` | `Bubble.mp3` |
| Divine Intervention received | Destination is the player. | `Divine Intervention`, `Göttliches Eingreifen` | `divineInt.mp3` |
| Soulstone Resurrection received | Destination is the player. | `Soulstone Resurrection`, `Seelenstein Auferstehung` | Randomly `soulstone.mp3`, `soulstone2.mp3`, or `soulstone3.mp3` |

## Deaths

All reactions below require `DeadSoundFlag = true` (`/cl dead`). Each group
also has its own feature flag.

| Dead unit | Additional condition | Sound |
| --- | --- | --- |
| Player | `/cl player` enabled | `MarioDeath.mp3` |
| Character `Schnutz` | `/cl melee` enabled | `schnutz.mp3` |
| Another name in `MELEE_NAMES` | `/cl melee` enabled | `wilhelm.ogg` |
| English/German name in the TBC boss list | `/cl boss` enabled | Randomly `FFX.mp3` or `Zelda.mp3` |
| Name in `TANK_NAMES` | `/cl tank` enabled | `Tank.mp3` (fixed — see [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md) for why this is no longer a random pick) |
| Name in `HEALPRIEST_NAMES` | `/cl priest` enabled | Randomly `Angels1.mp3` or `Angels2.mp3` |

The player lists are hard-coded to one specific historical raid roster. Roles
are not derived from the current party or raid — see
[CLEANUP-REVIEW.md](CLEANUP-REVIEW.md).

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
| Spirit of Redemption | Test code is commented out and labeled as not working. Deliberately left as-is for now — see [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md). |

## Stored data

`CritLogDB` is stored per character:

- highest ability-damage crit, including ability and target
- highest white-hit/ranged crit, including target
- highest healing crit, including ability and target
- all command toggles

Known storage and event-handling issues are listed in the
[project README](../README.md#known-technical-issues-and-risks).
