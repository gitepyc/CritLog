# Behavior and Triggers

This page describes when CritLog reacts and which sound file the current
code requests. All sounds live under `sounds/`.

## Event flow

```text
WoW event
  -> registered CritLog handler
  -> configuration flag and hard-coded condition
  -> database change and/or chat output
  -> PlaySoundFile(CritLog/sounds/<filename>, "Master")
```

All sounds use the `Master` audio channel, no independent volume control.
`CritLogDB.MasterSoundFlag` (`/cl mute`, on by default) is checked inside
`CritLog:PlaySound()` (`Sounds.lua`) and mutes every sound in the addon
regardless of the individual toggles below.

## Login and ready check

| Event | Condition | Effect | Sound |
| --- | --- | --- | --- |
| `PLAYER_LOGIN` | Always | Initializes/migrates `CritLogDB` and prints records. | None. |
| `READY_CHECK` | `ReadySoundFlag = true` | No state change. | `Ready.mp3` |

## Critical hits and heals

Detection runs through `COMBAT_LOG_EVENT_UNFILTERED`; damage and heal
events must originate from the player. The level filter resolves a live
unit token for the combat-log destination (current target if it matches,
otherwise a visible nameplate with a matching GUID) rather than assuming
the selected target is the unit that was hit; if no token resolves, the
crit is allowed through. The filter only applies to damage, not healing.

| Combat-log type | Condition | State change | Sound condition | Sound |
| --- | --- | --- | --- | --- |
| `SPELL_DAMAGE` | Player source, critical hit, level filter passes | Inserted into the damage-crit list. | Every crit with `/cl allcrits`; also every new #1. | `at_bam_babam.mp3` |
| `SWING_DAMAGE` | Player source, critical hit, level filter passes | Inserted into the white-hit list only if it beats the current #1. | Every crit when both `/cl allcrits` and `/cl whitehit` are enabled; a new #1 when `/cl whitehit` is enabled. | `at_bam_babam.mp3` |
| `RANGE_DAMAGE` | Player source, critical hit, level filter passes | Inserted into the white-hit list only if it beats the current #1 **and** `/cl whitehit` is enabled. | Every crit with `/cl allcrits`; a new #1 with `/cl whitehit`. | `at_bam_babam.mp3` |
| `SPELL_HEAL` | Player source, critical heal | Inserted into the heal-crit list. | Every crit with `/cl allcrits`; also every new #1. | `at_bam_babam.mp3` |

`/cl sound` is the master switch for `at_bam_babam.mp3` and suppresses it
even when the conditions above are met. "Inserted into the list" means
`CritLog:AddRecord()` (`Persistence/Database.lua`) adds the crit
regardless of whether it's a new #1, keeping the top
`Constants.maxTrackedEntries` (10, more than the `Constants.maxDisplayEntries`
(5) actually shown - see [Stored data](#stored-data)). The sound/print
trigger checks against the list's current #1 before the insert.

## Extreme hits

| Combat-log type | Condition | Sound |
| --- | --- | --- |
| `SPELL_DAMAGE` | Player source, `sv4 > 9000` | `Xtreme.mp3`, only if `/cl xtreme` is enabled |

Off by default (`XtremeSoundFlag = false`). No level filter, no state
change - a standalone "hit hard enough" alert.

## Auras and abilities

Requires `/cl aura` (`AuraSoundFlag`) as a master switch over all 13
triggers below, each individually toggleable in the Sound Settings panel.
Each trigger matches by spell ID first, falling back to the displayed
English/German spell name if the ID doesn't hit.

Verification status of the less common spells: Mage Table and the
Healthstone ritual sounds are in-game verified working, though not
specifically confirmed castable on Classic Era/SoD (vs. some other
client version). Hymn of Hope has no spell ID (it replaced the
TBC-only "Symbol of Hope" in WotLK patch 3.0.2) and is expected
uncastable on Classic Era/SoD, but that's still unverified in-game.

| Trigger | Own flag | Source/destination condition | Spell ID(s) | Name fallback | Sound |
| --- | --- | --- | --- | --- | --- |
| Mana Tide Totem summoned (`SPELL_SUMMON`) | `ManaTideSoundFlag` | Source is a party or raid member. | `16190` | `Mana Tide Totem`, `Totem der Manaflut` | `Manatide.mp3` |
| Bloodlust/Heroism received (`SPELL_AURA_APPLIED`) | `BloodlustSoundFlag` | Destination is the player. | `27689` (Horde), `23682` (Alliance) | `Bloodlust`, `Heroism`, `Blutrausch`, `Heldentum` | `Bloodlust.mp3` |
| Innervate received | `InnervateSoundFlag` | Destination is the player. | `29166` | `Innervate`, `Anregen` | `Innervate.mp3` |
| Power Infusion received | `PowerInfusionSoundFlag` | Destination is the player. | `10060` | `Power Infusion`, `Seele der Macht` | `Surprise.mp3` |
| Blessing of Protection received | `BlessingOfProtectionSoundFlag` | Destination is the player. | `1022` | `Blessing of Protection`, `Segen des Schutzes` | `Bubble.mp3` |
| Divine Intervention received | `DivineInterventionSoundFlag` | Destination is the player. | `19752` | `Divine Intervention`, `Göttliches Eingreifen` | `divineInt.mp3` |
| Soulstone buff received (not the resurrection itself - real in-game name is "Soulstone Resurrection") | `SoulstoneSoundFlag` | Destination is the player. | `20707` | `Soulstone Resurrection`, `Seelenstein Auferstehung` | `soulstone.mp3` |
| Drums of Battle received | `DrumsSoundFlag` | Destination is the player. | `35476` | `Drums of Battle`, `Greater Drums of Battle`, `Trommeln der Schlacht`, `Große Trommeln der Schlacht` | `dkRapL.mp3` |
| Pain Suppression received | `PainSuppressionSoundFlag` | Destination is the player. | `402004` | `Pain Suppression`, `Schmerzunterdrückung` | `Painsup.mp3` |
| Hymn of Hope received | `HymnOfHopeSoundFlag` | Destination is the player. | none | `Hymn of Hope`, `Hymne der Hoffnung` | `HymnOfHope.mp3` |
| Evocation received | `EvocationSoundFlag` | Destination is the player. | `12051` | `Evocation`, `Hervorrufung` | `evo.mp3` |
| Mage Table cast (`SPELL_CAST_SUCCESS`) | `MageTableSoundFlag` | Source is a party/raid member; at most once per 100s (shared cooldown gate). | `43987` | `Ritual of Refreshment`, `Tischlein deck dich` | `Table.mp3` |
| Warlock Healthstone ritual cast (`SPELL_CAST_SUCCESS`) | `HealthstoneSoundFlag` | Source is a party/raid member; at most once per 60s (shared cooldown gate). | `29893` | `Ritual of Souls`, `Ritual der Seelen` | `healthstone.mp3` |

## Deaths

`PlayerSoundFlag` (`/cl player`) and `BossSoundFlag` (`/cl boss`) are
plain on/off flags. The Damage Dealer/Tank/Healer groups each use a
**detection mode** instead (`CritLogDB.<Kind>DetectionMode`, a dropdown
in the Death Sounds panel, one of `CritLog.Constants.detectionModes`);
setting all three to `none` is the equivalent of a master switch.

| Mode | Meaning |
| --- | --- |
| `none` | Sound never plays for this category. |
| `experimental` (shown as "Role" in the options panel) | Only the live assigned-role check counts; the name roster is ignored. |
| `roster` | Only a name in `CritLogDB.playerGroups.<kind>` counts; the live check is ignored. |
| `both` | Either one counts - the default. |

`/cl healer`/`dps`/`tank` toggle between `none` and `both` only;
`experimental`/`roster` need the options panel dropdown. `/cl boss` is a
plain toggle, not a mode.

| Dead unit | Live check | Sound |
| --- | --- | --- |
| Player | `/cl player` enabled | `Toni.mp3` |
| Not currently assigned Tank or Healer (`isAssignedDps`), any class | `DpsDetectionMode` matches | `wilhelm.ogg` |
| Live classification `worldboss` (`isClassifiedBoss`) | `BossSoundFlag` enabled | `FFX.mp3` |
| Assigned raid role Tank (`isAssignedTank`) | `TankDetectionMode` matches | `Tank.mp3` |
| Assigned raid role Healer (`isAssignedHealer`, any class) | `HealDetectionMode` matches | `Angels.mp3` |

Hunter's Feign Death fires a real `UNIT_DIED`. Checked first in
`HandleDeath` via a live `UnitBuff` scan on the resolved group token
(`hasFeignDeathBuff`, spell id `5384`, ID-first-then-name-fallback).

The live dps/tank/healer checks resolve the dying player's unit token via
`findGroupUnitToken()` (`Core/CombatLog.lua`), which checks
`party1-4`/`raid1-40`/`player` directly by GUID (not target/nameplates,
unlike `findUnitToken()` used for enemy NPCs - see the boss/level-filter
rows above). That token must pass `UnitIsPlayer()` and
`UnitInParty()`/`UnitInRaid()`. When the detection mode is `experimental`,
failing any of these means no sound at all - the name roster is only
consulted in `roster`/`both` mode.

The name roster matches purely on `destName`, independent of group
membership. `findUnitToken()` is still tried for the dying GUID regardless
of mode; if it resolves to something confirmed not a player, the roster
match is suppressed (guards against an NPC coincidentally sharing a
display name with a rostered player). An unresolved token doesn't
suppress the roster match. Boss detection only accepts the `"worldboss"`
classification, no name-list fallback.

The three death-sound rosters (dps/tank/heal - `playerGroups.melee` and
`playerGroups.priest` were renamed to `playerGroups.dps`/`playerGroups.heal`,
see `Persistence/Database.lua`'s `migrateMeleeToDps()`/
`migratePriestToHeal()`) are editable per character: `/cl options` →
"Death Sounds..." → "Roster Settings..." shows each with Add/Remove
controls. `CritLogDB.playerGroups` is a per-character copy, seeded once
from code defaults on first load (`migratePlayerGroups()`); only the
`CritLogDB` copy is read or written afterward.

## Raid-leader chat

`CHAT_MSG_RAID_LEADER`, no feature flag (`/cl sound` doesn't disable
these).

| Case-insensitive message | Reaction |
| --- | --- |
| `raid ende` or `raid end` | Plays `raidend.mp3`. |
| `shit show` or `wipe` | Plays `wipe.mp3`. |

## Raid/party/guild chat (lottery)

`CHAT_MSG_RAID`, `CHAT_MSG_PARTY`, and `CHAT_MSG_GUILD`, gated by
`GambleSoundFlag` (`/cl gamble`). Reacts to a fixed announcement phrase
from a third-party lottery addon (e.g. CrossGambling) - a chat-string
match only, CritLog does not run or understand any lottery itself.
CrossGambling's own chat-destination options are `PARTY`/`RAID`/`GUILD`
only (no custom channel support), matching the three events listened to
here.

| Raid/party/guild chat message contains | Reaction |
| --- | --- |
| `CrossGambling: A new game has been started! Type 1 to join!` | Plays `lottery.mp3`. |

## Rolls

`CHAT_MSG_SYSTEM`, gated by `RollSoundFlag` (`/cl roll`). Reacts to any
`/roll` starting at 1 - a plain 1-100 roll or a custom range (e.g.
`/roll 1-1000`); a loot roll with a different minimum (e.g. `/roll 1 5`)
is ignored. Matching requires a `"roll"`/`"ürfel"` substring anywhere in
the message (case-insensitive, covers self/other and English/German
phrasing) plus the trailing `"N (min-max)"` numbers.
`CritLog.Filters.classifyRoll` (pure, no WoW API) then classifies the
parsed numbers into a sound.

| Roll result | Sound |
| --- | --- |
| Exactly the maximum | `roll100.mp3` |
| Exactly 1 | `roll1.mp3` |
| Exactly 69 | `roll69.mp3` |
| >= 92% of max | `roll95.mp3` |
| < 8% of max | `roll5.mp3` |
| 8-12% of max | `roll10.mp3` |
| Anything else | No sound. |

The percentage bands (`roll5`/`roll10`/`roll95`) are unreachable for a
small custom range - the exact-value checks already claim the only
candidate values, or the threshold falls below the smallest possible roll.

## Other code paths

| Function | Status |
| --- | --- |
| Boss killing-blow output | `BossKillFlag` (main panel checkbox or `/cl bosskill`, on by default). Prints a chat line for a `_DAMAGE` event with a positive numeric fifth payload value (`overkill`), where the destination is a live-classified boss-level mob (`worldboss`). |

## Stored data

`CritLogDB` is stored per character:

- `records.damage`/`records.whiteHit`/`records.heal`: up to
  `Constants.maxTrackedEntries` (10) entries each, sorted highest-first,
  each with an amount, target, and (except white-hit) the ability name.
  Only the top `Constants.maxDisplayEntries` (5) are shown in the options
  panel's Highscore List popup. Individually deletable there, or
  clearable a whole category at a time via `/cl reset damage|whitehit|heal`.
  The popup's "Reset All" button clears every category and is the only
  highscore action that asks for confirmation first (`StaticPopupDialogs`).
- the legacy single-value fields (`DamageAbilityCrit`, `DAC_Name`, ...) -
  no longer read or written, kept only so an old SavedVariables file never
  produces a nil field if something still reads them
- all command toggles

Known storage and event-handling issues are listed in the
[project README](../README.md#known-technical-issues-and-risks).
