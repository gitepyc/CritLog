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
| `PLAYER_LOGIN` | Always | Initializes/migrates `CritLogDB` and prints records. | None. A login sound was briefly ported from the legacy addon in `feature/legacy-sound-port`, then removed - see `CHANGELOG.md`. |
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

This group requires `/cl aura` (`AuraSoundFlag`) to be enabled - a master
switch over all 13 triggers below, each of which also has its own flag
(e.g. `BloodlustSoundFlag`), individually toggleable in the Sound Settings
panel instead of all-or-nothing. Each trigger matches by spell ID first;
if the ID doesn't hit, it falls back to matching the displayed
English/German spell name. The name fallback exists because the IDs are
Wowhead-Classic-sourced but not yet in-game verified — see
[ROADMAP.md](ROADMAP.md). Of the six ported in `feature/legacy-sound-port`,
five now have a confirmed Wowhead spell ID: Pain Suppression (`402004`,
the Season of Discovery Priest rune), Evocation (`12051`, a genuine
vanilla/Classic Era spell), and Drums of Battle (`35476`)/Mage Table
(`43987`)/the Healthstone ritual (`29893`) - but those last three are
confirmed **TBC-introduced** spells (none existed in vanilla WoW at all),
so having the right ID doesn't by itself confirm they're castable on
Classic Era/SoD; that's still unverified, mirroring the legacy addon's
own uncertainty (see `CHANGELOG.md`). Hymn of Hope is the one exception
with no ID at all: confirmed to not exist under that name before WotLK
patch 3.0.2 (it replaced the TBC-only, Draenei-only "Symbol of Hope",
spell id `32548` - a different spell, not used here), so this trigger
cannot fire on Classic Era/SoD under any circumstances unless SoD
introduces an equivalent rune.

| Trigger | Own flag | Source/destination condition | Spell ID(s) | Name fallback | Sound |
| --- | --- | --- | --- | --- | --- |
| Mana Tide Totem summoned (`SPELL_SUMMON`) | `ManaTideSoundFlag` | Source is recognized as a party or raid member. | `16190` | `Mana Tide Totem`, `Totem der Manaflut` | `Manatide.mp3` |
| Bloodlust/Heroism received (`SPELL_AURA_APPLIED`) | `BloodlustSoundFlag` | Destination is the player. | `27689` (Horde), `23682` (Alliance) | `Bloodlust`, `Heroism`, `Blutrausch`, `Heldentum` | `Bloodlust.mp3` |
| Innervate received | `InnervateSoundFlag` | Destination is the player. | `29166` | `Innervate`, `Anregen` | `Innervate.mp3` |
| Power Infusion received | `PowerInfusionSoundFlag` | Destination is the player. | `10060` | `Power Infusion`, `Seele der Macht` | `Surprise.mp3` |
| Blessing of Protection received | `BlessingOfProtectionSoundFlag` | Destination is the player. | `1022` | `Blessing of Protection`, `Segen des Schutzes` | `Bubble.mp3` |
| Divine Intervention received | `DivineInterventionSoundFlag` | Destination is the player. | `19752` | `Divine Intervention`, `Göttliches Eingreifen` | `divineInt.mp3` |
| Soulstone buff received (not the resurrection itself - the buff's real in-game name happens to be "Soulstone Resurrection", the name fallback below) | `SoulstoneSoundFlag` | Destination is the player. | `20707` | `Soulstone Resurrection`, `Seelenstein Auferstehung` | `soulstone.mp3` |
| Drums of Battle received | `DrumsSoundFlag` | Destination is the player. | `35476` (TBC-introduced, SoD availability unverified) | `Drums of Battle`, `Greater Drums of Battle`, `Trommeln der Schlacht`, `Große Trommeln der Schlacht` | `dkRapL.mp3` |
| Pain Suppression received | `PainSuppressionSoundFlag` | Destination is the player. | `402004` | `Pain Suppression`, `Schmerzunterdrückung` | `Painsup.mp3` |
| Hymn of Hope received | `HymnOfHopeSoundFlag` | Destination is the player. | none - confirmed to not exist before WotLK | `Hymn of Hope`, `Hymne der Hoffnung` | `HymnOfHope.mp3` |
| Evocation received | `EvocationSoundFlag` | Destination is the player. | `12051` | `Evocation`, `Hervorrufung` | `evo.mp3` |
| Mage Table cast (`SPELL_CAST_SUCCESS`) | `MageTableSoundFlag` | Source is a party/raid member; at most once per 100s (cooldown gate, shared across the whole group so 5 simultaneous casts don't play it 5 times). | `43987` (TBC-introduced, SoD availability unverified) | `Ritual of Refreshment`, `Tischlein deck dich` | `Table.mp3` |
| Warlock Healthstone ritual cast (`SPELL_CAST_SUCCESS`) | `HealthstoneSoundFlag` | Source is a party/raid member; at most once per 60s (same cooldown-gate reasoning as Mage Table). | `29893` (TBC-introduced, SoD availability unverified) | `Ritual of Souls`, `Ritual der Seelen` | `healthstone.mp3` |

## Deaths

The player's own death sound (`PlayerSoundFlag`, `/cl player`) is a plain
on/off flag, unchanged, long-standing behavior. Boss (`BossSoundFlag`,
`/cl boss`) is also a plain on/off flag - it went through a detection-mode
phase and back (see `CHANGELOG.md`) since it never had a name-roster
fallback to justify one. The remaining three groups (Damage Dealer/Tank/
Healer) each have a **detection mode** instead - there is no separate
master switch over just these three anymore (there used to be one,
`DeadSoundFlag`); setting all three modes to `none` is equivalent
(`CritLogDB.<Kind>DetectionMode`, a dropdown in the Death Sounds panel,
one of `CritLog.Constants.detectionModes`). Spirit of Redemption
(`SpiritSoundFlag`, `/cl spirit`) is another independent plain on/off flag
next to these, not a detection mode - see further below for why.

| Mode | Meaning |
| --- | --- |
| `none` | Sound never plays for this category. |
| `experimental` (shown as "Role" in the options panel) | Only the live assigned-role check counts (see below); the name roster is ignored even if it matches. |
| `roster` | Only a name in `CritLogDB.playerGroups.<kind>` counts; the live check is ignored even if it matches. |
| `both` | Either one counts - the original, still-default behavior. |

`/cl healer`/`dps`/`tank` only toggle between `none` and `both`;
`experimental`/`roster` need the options panel dropdown. `/cl boss` is a
plain on/off toggle, not a mode - see above. The live checks are not yet
in-game verified for tank/boss/healer specifically (an earlier
class-based DPS guess's false-positive bug is fixed and confirmed) - see
[ROADMAP.md](ROADMAP.md).

| Dead unit | Live check | Sound |
| --- | --- | --- |
| Player | `/cl player` enabled | `MarioDeath.mp3` |
| Not currently assigned Tank or Healer (`isAssignedDps`) - the real 3-role system's third bucket, any class | `DpsDetectionMode` matches | `wilhelm.ogg` |
| Live classification `worldboss` (`isClassifiedBoss`) | `BossSoundFlag` enabled | `FFX.mp3` |
| Assigned raid role Tank (`isAssignedTank`) | `TankDetectionMode` matches | `Tank.mp3` |
| Assigned raid role Healer (`isAssignedHealer`, any class), death NOT preceded by the Spirit of Redemption buff | `HealDetectionMode` matches | `Angels.mp3` |
| Class `PRIEST` specifically (`isPriestClass`) AND preceded by the Spirit of Redemption buff (spell id `27827`) | `SpiritSoundFlag` enabled - independent of `HealDetectionMode`, see below | `Angels2.mp3` (own asset, restored from the legacy addon - see `CHANGELOG.md`) |

Hunter's Feign Death fires a real `UNIT_DIED` for the feigning hunter - a
well-known WoW quirk, not a bug in listening to `UNIT_DIED` itself
(in-game reported: the DPS death sound triggered on a Feign Death, still
happened even after an initial fix, most visibly during a raid-wide
mass-feign). Checked first in `HandleDeath`, before even the player's own
death sound - live `UnitBuff` scan on the resolved group token
(`hasFeignDeathBuff`, spell id `5384` matched ID-first-then-name-fallback
like every other spell check), not a cached combat-log
`SPELL_AURA_APPLIED` match - the earlier cache-based version still missed
real Feign Deaths, most likely an exact spell-ID/name mismatch that the
live scan's fallback matching doesn't depend on getting right.

The live checks (dps/tank/healer, not boss) need a resolved unit token for
the dying player - `findGroupUnitToken()` in `Core/CombatLog.lua`, which
checks `party1-4`/`raid1-40` (and `player`) tokens directly by GUID, not
`target`/nameplates (that's `findUnitToken()`, used elsewhere for enemy
NPCs - see below and the boss/level-filter rows above). Group-roster
tokens resolve regardless of range or visibility, unlike target/nameplate
scanning, which is why this exists as its own function (in-game reported:
the live checks barely ever fired for raid members specifically, since
they're rarely your current target or on-screen, unlike party members).
That token must also pass `UnitIsPlayer()`, discarded otherwise: some
enemy NPCs carry a class internally, so `UnitClass()`/
`UnitGroupRolesAssigned()` aren't reliably `nil` for them, which let enemy
deaths in instances wrongly trigger these sounds (fixed after an in-game
report - a Necromancer trash mob at Mount Hyjal). They also require
`UnitInParty(destName) or UnitInRaid(destName)` — without that, any player
death that happens to resolve a token (an enemy player in PvP) could match
by class/role alone even though they're nobody in your group; in-game
reported. This also gates the Spirit of Redemption branch below, checked
against the same `destName`. When the detection mode is `experimental`,
losing any of these (no token, not a player, not a group member, or a
class/role mismatch) means no sound at all - the name roster is only
consulted in `roster`/`both` mode.

The name roster is a separate, independent fallback - matched purely on
`destName`, no group-membership requirement of its own (it's an explicit
named allowlist, not a live-detection heuristic). It does share one
safety check with the live path though: `findUnitToken()` (target/
nameplate, works for non-group-members unlike `findGroupUnitToken()`
above) is tried for the dying GUID regardless of detection mode, and if
that resolves to something confirmed *not* a player, the roster match is
suppressed - in-game reported: an NPC (raid trash, an add, a totem, ...)
can coincidentally share a display name with someone already in a
roster, triggering a false-positive death sound in a raid for something
that was neither a player nor the current target. An unresolved token
(off-screen, not targeted) can't disprove anything, so the roster match
is still trusted as before in that case. The `"Schnutz"` character no
longer has a separate special case (removed — see `CHANGELOG.md`); they
are simply one more name in `playerGroups.dps` like everyone else, and
get the regular DPS death sound. Boss detection accepts only the
`"worldboss"` classification
(raid bosses, outdoor world bosses, and other level-60 raid
encounters) - there
is no name-list fallback anymore (removed, see `CHANGELOG.md`), so 5-man
end bosses and similarly-ranked NPCs don't play a boss death sound at
all. The three death-sound name rosters (dps/tank/heal, `playerGroups.melee` renamed to
`playerGroups.dps` and `playerGroups.priest` renamed to
`playerGroups.heal` - see `Persistence/Database.lua`'s
`migrateMeleeToDps()`/`migratePriestToHeal()`) are editable per character:
`/cl options` → "Death Sounds..." → "Roster Settings..." shows each one
with Add/Remove
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
consumed once the matching death arrives. Originally this only decided
which of two files played under a single shared `HealDetectionMode`
(then still named `PriestDetectionMode`) gate (you couldn't hear one
without the other, and in practice couldn't tell them apart either, since
both pointed at the same file) - now the two are independent: a death
delayed by the buff is excluded from the plain healer-death check above
(`HealDetectionMode` never sees it) and instead gated purely by
`SpiritSoundFlag`, a plain on/off flag rather than a detection mode, and
plays its own dedicated file (`Angels2.mp3`, restored from the legacy
addon rather than sharing `Angels.mp3` with the plain healer-death sound).
There's no meaningful roster/name-list equivalent for
"this priest's death was Spirit-delayed" - the buff-apply cache is the
only signal that exists at all, so a 4-way mode would just have three of
its four options behave identically.

## Raid-leader chat

The message only needs to arrive through `CHAT_MSG_RAID_LEADER`. An earlier
check for a specific sender is commented out.

| Case-insensitive message | Reaction |
| --- | --- |
| `raid ende` or `raid end` | Plays `raidend.mp3`. |
| `shit show` or `wipe` | Plays `wipe.mp3`. |

These chat sounds have no feature flag - `/cl sound` doesn't disable them.

## Raid/party chat (lottery)

`CHAT_MSG_RAID` and `CHAT_MSG_PARTY`, gated by `GambleSoundFlag`
(`/cl gamble`). Reacts to a fixed announcement phrase from a third-party
lottery addon (e.g. CrossGambling) - CritLog does not run or understand
any lottery itself, this is purely a chat-string match, same mechanism as
raid end/wipe above. Both events needed since the third-party addon
announces to whichever group chat is actually active - raid chat in a
raid, party chat otherwise (in-game reported: party announcements weren't
triggering the sound at all).

| Raid chat message contains | Reaction |
| --- | --- |
| `CrossGambling: A new game has been started! Type 1 to join!` | Plays `lottery.mp3`. |

## Rolls

`CHAT_MSG_SYSTEM`, gated by `RollSoundFlag` (`/cl roll`). Reacts to any
`/roll` starting at 1 - a plain 1-100 roll or a custom range (e.g.
`/roll 1-1000`); a loot roll with a different minimum (e.g. `/roll 1 5`) is
ignored. Doesn't parse an exact wording (the client phrases your own roll
differently from someone else's - "You roll N (min-max)" vs "PlayerName
rolls N (min-max)", on top of the English/German split - in-game reported:
the sound only ever fired off someone else's roll, never the player's own,
which only became obvious once solo). Instead just requires a "roll"/"ürfel"
substring anywhere in the message (case-insensitive - covers every
tense/person/locale conjugation) and reads the trailing "N (min-max)"
numbers, which every phrasing shares; classification of the parsed numbers
into a sound (or no sound) is `CritLog.Filters.classifyRoll` - pure, no WoW
API.

| Roll result | Sound |
| --- | --- |
| Exactly the maximum | `roll100.mp3` |
| Exactly 1 | `roll1.mp3` |
| Exactly 69 | `roll69.mp3` |
| >= 92% of max | `roll95.mp3` |
| < 8% of max | `roll5.mp3` |
| 8-10% of max | `roll10.mp3` |
| Anything else | No sound. |

The percentage bands (`roll5`/`roll10`/`roll95`) are naturally unreachable
for a small custom range - not a bug, the exact-value checks above already
claim the only candidate values, or the threshold falls below the smallest
possible roll.

## Other code paths

| Function | Status |
| --- | --- |
| Boss killing-blow output | Prints a chat line for a `_DAMAGE` event with a positive numeric fifth payload value (`overkill`), where the destination is live-classified `worldboss` - same check as the death sound below, minus the death-only token/group-membership gating. |

## Stored data

`CritLogDB` is stored per character:

- `records.damage`/`records.whiteHit`/`records.heal`: up to
  `Constants.maxTrackedEntries` (10) entries each, sorted highest-first,
  each with an amount, target, and (except white-hit) the ability name.
  Only the top `Constants.maxDisplayEntries` (5) are shown in the options
  panel's Highscore List popup - the rest exist so deleting a bad entry
  from the visible list doesn't need a new crit to refill it. Individually
  deletable there (no confirmation - one entry is easy to lose and easy to
  re-earn), or clearable a whole category at a time via
  `/cl reset damage|whitehit|heal`. The popup's "Reset All" button clears
  every category at once and is the one highscore action that asks for
  confirmation first (`StaticPopupDialogs`) - it's the only one that can't
  be undone by just waiting for a new crit.
- the legacy single-value fields (`DamageAbilityCrit`, `DAC_Name`, ...) -
  no longer read or written, kept only so an old SavedVariables file never
  produces a nil field if something still reads them
- all command toggles

Known storage and event-handling issues are listed in the
[project README](../README.md#known-technical-issues-and-risks).
