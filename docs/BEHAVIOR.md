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

All sounds use the `Master` audio channel. CritLog has no independent volume
control. `CritLogDB.MasterSoundFlag` (`/cl mute`, on by default) is checked
inside `CritLog:PlaySound()` in `Sounds.lua` — every sound in the addon
(crits, auras, deaths, ready check, chat triggers) routes through that one
function, so this one flag mutes everything regardless of the individual
toggles below.

## Login and ready check

| Event | Condition | Effect | Sound |
| --- | --- | --- | --- |
| `PLAYER_LOGIN` | Always | Initializes/migrates `CritLogDB` and prints records. | None. The login-sound feature was removed entirely, along with `Login.mp3`; see `CHANGELOG.md`. |
| `READY_CHECK` | `ReadySoundFlag = true` | No state change. | `Ready.mp3` |

## Critical hits and heals

Detection runs through `COMBAT_LOG_EVENT_UNFILTERED`. Damage and heal events
must originate from the player. The level filter resolves a live unit token
for the actual combat-log destination — the current target if it matches,
otherwise a visible nameplate with a matching GUID — rather than assuming
the currently selected target is the unit that was hit. If no token can be
resolved (e.g. no nameplate on screen), the crit is allowed through rather
than silently dropped. The filter only applies to damage events; healing
crits are always recorded regardless of the target's level.

| Combat-log type | Condition | State change | Sound condition | Sound |
| --- | --- | --- | --- | --- |
| `SPELL_DAMAGE` | Player source, critical hit, level filter passes | Inserted into the damage-crit list (see below). | Every crit when `/cl allcrits` is enabled; also every new #1. | `at_bam_babam.mp3` |
| `SWING_DAMAGE` | Player source, critical hit, level filter passes | Inserted into the white-hit list only if it beats the current #1. | Every crit when both `/cl allcrits` and `/cl whitehit` are enabled; a new #1 when `/cl whitehit` is enabled. | `at_bam_babam.mp3` |
| `RANGE_DAMAGE` | Player source, critical hit, level filter passes | Inserted into the white-hit list only if it beats the current #1 **and** `/cl whitehit` is enabled (pre-existing asymmetry vs. `SWING_DAMAGE`, not fixed). | Every crit with `/cl allcrits`; a new #1 with `/cl whitehit`. | `at_bam_babam.mp3` |
| `SPELL_HEAL` | Player source, critical heal | Inserted into the heal-crit list. | Every crit with `/cl allcrits`; also every new #1. | `at_bam_babam.mp3` |

`/cl sound` is the master switch for `at_bam_babam.mp3` and suppresses the
clip even when the individual conditions above are met. "Inserted into the
list" means `CritLog:AddRecord()` (`Persistence/Database.lua`) attempts to
add the crit regardless of whether it's a new #1 - a crit that only beats
the 3rd-best still earns a spot in the top `Constants.maxTrackedEntries`
(10, more than the `Constants.maxDisplayEntries` (5) actually shown - see
below). The sound/print trigger is a separate check against the list's
current #1 before the insert, so "new highscore" behavior is unchanged
from the old single-value tracking.

## Extreme hits

| Combat-log type | Condition | Sound |
| --- | --- | --- |
| `SPELL_DAMAGE` | Player source, `sv4 > 9000` | `Xtreme.mp3`, only if `/cl xtreme` is enabled |

Off by default (`XtremeSoundFlag = false`). Unlike the crit tracking above,
this has no level filter and no state change — it's a standalone "hit hard
enough" alert. Toggle with `/cl xtreme`.

## Auras and abilities

This group requires `/cl aura` to be enabled. Each trigger matches by spell
ID first; if the ID doesn't hit, it falls back to matching the displayed
English/German spell name. The name fallback exists because the IDs are
Wowhead-Classic-sourced but not yet in-game verified — see
[ROADMAP.md](ROADMAP.md).

| Trigger | Source/destination condition | Spell ID(s) | Name fallback | Sound |
| --- | --- | --- | --- | --- |
| Mana Tide Totem summoned (`SPELL_SUMMON`) | Source is recognized as a party or raid member. | `16190` | `Mana Tide Totem`, `Totem der Manaflut` | `Manatide.mp3` |
| Bloodlust/Heroism received (`SPELL_AURA_APPLIED`) | Destination is the player. | `27689` (Horde), `23682` (Alliance) | `Bloodlust`, `Heroism`, `Blutrausch`, `Heldentum` | `Bloodlust.mp3` |
| Innervate received | Destination is the player. | `29166` | `Innervate`, `Anregen` | `Innervate.mp3` |
| Power Infusion received | Destination is the player. | `10060` | `Power Infusion`, `Seele der Macht` | `Surprise.mp3` |
| Blessing of Protection received | Destination is the player. | `1022` | `Blessing of Protection`, `Segen des Schutzes` | `Bubble.mp3` |
| Divine Intervention received | Destination is the player. | `19752` | `Divine Intervention`, `Göttliches Eingreifen` | `divineInt.mp3` |
| Soulstone Resurrection received | Destination is the player. | `20707` | `Soulstone Resurrection`, `Seelenstein Auferstehung` | `soulstone.mp3` |

## Deaths

All reactions below require `DeadSoundFlag = true` (`/cl dead`). Each group
also has its own feature flag. The player's own death sound
(`PlayerSoundFlag`) is unchanged, long-standing behavior. The other four
groups (Melee/Tank/Priest/Boss) are marked **"(Experimental)"** in the
options panel: their primary detection is live class/role/classification
matching, added this session and not yet in-game verified, with the
original hard-coded name rosters kept as a fallback for whenever no live
unit token is available or the live check doesn't match — same
ID-first-then-name-fallback pattern used for spells above.

| Dead unit | Additional condition | Sound |
| --- | --- | --- |
| Player | `/cl player` enabled | `MarioDeath.mp3` |
| Melee-capable class not flagged Healer (`isMeleeClass`), or a name in `CritLogDB.playerGroups.melee` | `/cl melee` enabled | `wilhelm.ogg` |
| Live classification `worldboss` (`isClassifiedBoss`), or an English/German name in `CritLog.Constants.bosses` | `/cl boss` enabled | `FFX.mp3` |
| Assigned raid role Tank (`isAssignedTank`), or a name in `CritLogDB.playerGroups.tank` | `/cl tank` enabled | `Tank.mp3` |
| Class `PRIEST` (`isPriestClass`), or a name in `CritLogDB.playerGroups.priest` | `/cl priest` enabled | `Angels.mp3` |
| Priest death preceded by the Spirit of Redemption buff (spell id `27827`) | `/cl priest` enabled | `Angels.mp3` (same file as the plain priest death sound for now, see `CHANGELOG.md`) |

The live checks (melee/tank/priest, not boss) need a resolved unit token
for the dying player (the current target, or a matching visible nameplate)
— see `findUnitToken()` in `Core/CombatLog.lua` — and that token must pass
`UnitIsPlayer()`, discarded otherwise: some enemy NPCs carry a class
internally, so `UnitClass()`/`UnitGroupRolesAssigned()` aren't reliably
`nil` for them, which let enemy deaths in instances wrongly trigger these
sounds (fixed after an in-game report - a Necromancer trash mob at Mount
Hyjal). They also require `UnitInParty(destName) or UnitInRaid(destName)`
— without that, any player death that happens to resolve a token (an enemy
player in PvP, or an unrelated player on a visible nameplate) could match
by class/role alone even though they're nobody in your group; in-game
reported. This also gates the Spirit of Redemption branch below, checked
against the same `destName`. When no token resolves, the token isn't a
player, isn't a group member, or resolves but the class/role check doesn't
match, the legacy name-roster check still applies - that fallback is an
explicit named allowlist, not a live-detection heuristic, so it's
deliberately NOT gated by group membership. The `"Schnutz"` character no longer has a separate special
case (removed — see `CHANGELOG.md`); they are simply one more name in
`playerGroups.melee` like everyone else, and get the regular melee death
sound. Boss detection accepts only the `"worldboss"` classification
(40-man raid bosses, outdoor world bosses, SoD's level-60 raids); the name
lists remain the only way 5-man end bosses and similarly-ranked NPCs are
detected (that boss list is still code-only, not editable). The three
death-sound name rosters (melee/tank/priest) are editable per character:
`/cl options` → "Roster Settings..." shows each one with Add/Remove
controls. `CritLogDB.playerGroups` is a per-character copy, migrated once
from a code-only seed on first load after upgrading (see
`Persistence/Database.lua`'s `migratePlayerGroups()`) - from then on only the
`CritLogDB` copy is read or written, so removing a name that used to be a
hard-coded default works the same as removing one you added yourself.
Spirit of Redemption (the Priest talent that turns the killing blow into a
15s delayed death) is now handled specifically: the real `UNIT_DIED` only
fires once the buff expires, with nothing on that event itself to tie it
back to the talent, so the buff's `SPELL_AURA_APPLIED` (spell id `27827`,
matched the same ID-first-then-name pattern as the spells table above) is
cached by GUID (`Core/CombatLog.lua`'s `rememberSpiritOfRedemption` /
`spiritOfRedemptionGuids`, any priest in the raid, not just the player) and
consumed once the matching death arrives. This branch is exclusive with the
plain priest-class check right above it, not additive - both currently play
the same file, so without the exclusivity a Spirit of Redemption death would
double-play it.

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
| Boss killing-blow output | Prints a chat line for a `_DAMAGE` event with a positive numeric fifth payload value (`overkill`), where the destination is either live-classified `worldboss` or its name is in the English or German boss list - same three-way check as the death sound below. |

## Stored data

`CritLogDB` is stored per character:

- `records.damage`/`records.whiteHit`/`records.heal`: up to
  `Constants.maxTrackedEntries` (10) entries each, sorted highest-first,
  each with an amount, target, and (except white-hit) the ability name.
  Only the top `Constants.maxDisplayEntries` (5) are shown in the options
  panel's Highscore List popup - the rest exist so deleting a bad entry
  from the visible list doesn't need a new crit to refill it. Individually
  deletable there, or clearable a whole category at a time via
  `/cl reset damage|whitehit|heal`.
- the legacy single-value fields (`DamageAbilityCrit`, `DAC_Name`, ...) -
  no longer read or written, kept only so an old SavedVariables file never
  produces a nil field if something still reads them
- all command toggles

Known storage and event-handling issues are listed in the
[project README](../README.md#known-technical-issues-and-risks).
