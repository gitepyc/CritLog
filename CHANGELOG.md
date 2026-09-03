# Changelog

**Next up:** in-game verification is the main open item across the board -
see [docs/ROADMAP.md](docs/ROADMAP.md) for the full prioritized list.

**Entry format:** one line per change, `type: short description`
(`feature`/`fix`/etc.) - no prose, no rationale. Save the "why" for the
commit message/PR, not here.

## 0.1.6-titanpanel-dev

Test build on `feature/titan-panel-integration`, not merged into `dev` -
standalone, not decided yet whether to keep this.

- feature: naming brought in line with TitanCritLine's own convention - frame renamed `TitanPanelCritLogButton` (was `CritLogTitanPanelButton`), registry id back to plain `"CritLog"` (was `"CritLogTitan"`, no longer needed now that the real "already loaded" bug is fixed)

## 0.1.5-titanpanel-dev

Test build on `feature/titan-panel-integration`, not merged into `dev` -
standalone, not decided yet whether to keep this.

- fix: found the real cause of "already loaded" via Titan Panel 9.3.2's actual source - `TitanPanelTextTemplate` already calls `TitanPanelButton_OnLoad` in its own baked-in XML OnLoad, our explicit second call queued the same button for registration twice; removed the redundant call

## 0.1.4-titanpanel-dev

Test build on `feature/titan-panel-integration`, not merged into `dev` -
standalone, not decided yet whether to keep this.

- fix: "Plugin 'CritLog' already loaded" persisted even with a single guarded registration on a confirmed-fresh 0.1.3 load - likely a stale entry in Titan's own SavedVariables from the earlier double-registration bug; registry id changed from "CritLog" to "CritLogTitan" to sidestep it

## 0.1.3-titanpanel-dev

Test build on `feature/titan-panel-integration`, not merged into `dev` -
standalone, not decided yet whether to keep this.

- fix: Titan rejected registration with "Plugin 'CritLog' already loaded" - guard against InitTitanPanelButton running twice (likely two CritLog addon folders enabled at once, check your AddOns folder for duplicates)

## 0.1.2-titanpanel-dev

Test build on `feature/titan-panel-integration`, not merged into `dev` -
standalone, not decided yet whether to keep this.

- fix: button never appeared in Titan's list at all - `IsAddOnLoaded` is nil on this client (moved to `C_AddOns.IsAddOnLoaded`), threw an error at PLAYER_LOGIN that silently skipped button setup entirely; not a "Combat" category issue, that was already correct

## 0.1.1-titanpanel-dev

Test build on `feature/titan-panel-integration`, not merged into `dev` -
standalone, not decided yet whether to keep this.

- fix: comments pointed at the wrong ROADMAP.md item number (10, not 3)

## 0.1.0-titanpanel-dev

Test build on `feature/titan-panel-integration`, not merged into `dev` -
standalone, not decided yet whether to keep this.

- feature: optional TitanPanel status-bar button, inert unless Titan is installed - icon, live "D:/W:/H:" top-score text next to it, hover tooltip with full per-category detail, left-click opens `/cl options`, right-click shows a small menu (Options, Reset All Highscores)

## 0.7.7-dev

- feature: shortened Help panel/`/cl help` wording throughout, merged the four healer/dps/tank/boss lines into one
- feature: added an "About" line at the end (author, year)

## 0.7.6-dev

- feature: every highscore reset (per-category buttons, and now `/cl reset`/`/cl reset damage|whitehit|heal` too) asks for confirmation, not just "Reset All"

## 0.7.5-dev

- feature: Death Sounds dropdown order now matches Roster Settings (DPS, Tank, Healer, Boss)
- feature: dropdown hints say "Experimental:" instead of "Live check:", matching the mode's actual name

## 0.7.4-dev

- fix: toggle-row tooltips reported still not showing - root cause was our own options panels sitting on TOOLTIP frame strata, competing with GameTooltip itself; panels now use FULLSCREEN (matching TitanCritLine's settings panel), tooltip code back to the plain TitanCritLine pattern

## 0.7.3-dev

- fix: toggle-row tooltips reported still not showing - anchor now matches TitanCritLine's proven pattern, plus explicit EnableMouse

## 0.7.2-dev

- fix: toggle-row tooltips still didn't show (hit-rect expansion used a width that read as 0)

## 0.7.1-dev

- feature: hover tooltips instead of static hint text under each toggle row
- fix: main options panel was missing its Close button
- feature: addon icon (`media/icon.png`), wired up via `## IconTexture`
- fix: toggle-row tooltips didn't show at all (GameTooltip vs. our own TOOLTIP-strata panels)

## 0.7.0

Third stable release since `0.5.0`, folding in everything from the
`0.5.1-dev` through `0.6.16-dev` line.

- **Multi-entry highscores**: each category now tracks up to 10 crits and
  shows the top 5 in a real table (rank/amount/ability/target columns,
  each entry individually deletable) instead of a single value in a
  combined text line. A "Reset All" button clears every category at once,
  gated behind a confirmation dialog since it's the one highscore action
  that can't be undone by waiting for a new crit. The popup's row layout
  is now fixed at 5 rows per category regardless of how many entries
  actually exist yet, so it no longer visibly grows into its final layout
  as crits accumulate.
- **Death-sound detection modes**: melee/tank/heal/boss death sounds are
  now a 4-way `None`/`Experimental`/`Roster`/`Both` dropdown instead of a
  plain on/off flag, replacing the removed `DeadSoundFlag` master switch.
  `Experimental` trusts only the live class/role/classification check;
  `Roster` only the name list; `Both` (the original default) either. The
  live checks are now gated on the dying player actually being in your
  group (`UnitInParty`/`UnitInRaid`), fixing false positives from
  unrelated players (PvP, a visible nameplate) matching by class/role
  alone.
- **Healer death and Spirit of Redemption split apart**: used to share one
  gate, with only the sound file differing (and both pointed at the same
  file anyway, so there was no audible difference). Healer death now
  detects the assigned raid Healer role instead of Priest class - a Holy
  Paladin/Resto Druid/Resto Shaman counts too, not just Priests - and was
  renamed from `PriestDetectionMode`/`playerGroups.priest` to
  `HealDetectionMode`/`playerGroups.heal` (migrated automatically). Spirit
  of Redemption is now an independent plain toggle (`SpiritSoundFlag`),
  still Priest-class-specific since the talent itself is, with its own
  dedicated sound file (`Angels2.mp3`, restored from the legacy addon's
  sound folder) instead of sharing the healer-death file.
- **Aura/spell sounds**: the original 7 (Bloodlust, Innervate, Power
  Infusion, Blessing of Protection, Divine Intervention, Mana Tide,
  Soulstone) are now individually toggleable under the `AuraSoundFlag`
  master switch, instead of all-or-nothing.
- **Ported 14 sounds from the original single-file legacy addon**
  (`feature/legacy-sound-port`, the legacy addon itself archived as the
  `legacy-0.1.4.2` Gitea release for reference): `/roll` result sounds
  (specific values/bands on a 1-100 roll), a lottery-chat-trigger sound,
  and 6 more aura/ritual sounds (Drums of Battle, Pain Suppression, Hymn
  of Hope, Evocation, Mage Table, Warlock Healthstone ritual). Spell IDs
  filled in where confirmable (Pain Suppression, Evocation, and now Drums
  of Battle/Mage Table/Healthstone - though those three are confirmed
  TBC-only spells, so SoD availability stays unverified even with the
  right ID; Hymn of Hope confirmed to not exist under that name before
  WotLK at all, so that one trigger genuinely cannot fire on Classic
  Era/SoD). A login sound was ported too, then removed entirely after
  review.
- **Options panel split into more, smaller panels** as each grew too tall:
  the 13 aura/ritual sounds moved from Sound Settings into a new Aura
  Sounds panel (two-column layout); the player/heal/DPS/tank/boss
  death-sound block moved into a new Death Sounds panel, which also picked
  up the "Roster Settings..." button (moved off the main panel, since the
  rosters are only ever a fallback for the dropdowns there); a new Help
  panel lists every slash command in-game, sharing one source of truth
  with `/cl help` instead of chat-only output. The main panel is back down
  to a compact Sound Settings + Help button row.
- **Wording**: "Melee" renamed to "Damage Dealer" (roster and label -
  ranged DPS belongs there too, the roster was never actually
  melee-restricted); "Soulstone Resurrection" renamed to "Soulstone
  Applied" (the sound fires on buff-apply, not the actual resurrection);
  `/cl melee` renamed to `/cl dps`; `/cl priest` renamed to `/cl healer`
  with a new `/cl spirit`; every highscore "Reset" button now reads
  "Reset all" (wording only, each still clears just its own category).
- Every panel now has a consistent bottom-center "Close" button in
  addition to the corner X and Escape. Fixed two underlying bugs found
  in-game along the way: detection-mode dropdowns not opening at all
  (Blizzard's shared dropdown-list frames were rendering behind our
  higher-strata panels), and the Escape-key stack leaving stale panel
  registrations behind on out-of-order closes.
- Several rounds of in-game-reported layout polish: dropdown-row Preview
  buttons not lining up with checkbox rows' Preview column, hint text
  overflowing past a panel's right edge, and the None/Experimental/
  Roster/Both explanation consolidated into a single shared note instead
  of being repeated on every row.

Still not in-game verified: tank/boss/healer-specific live detection,
Spirit of Redemption, and all 14 legacy-ported sounds (four of which have
an open question of whether the underlying spell can even be cast on
Classic Era/SoD at all - see `docs/ROADMAP.md`).

## 0.5.0

Second stable release since `0.4.0`, folding in everything from the
`0.4.1-dev` through `0.4.9-dev` line.

- **Escape key**: fixed for real and in-game confirmed. Panels push/pop
  themselves onto a small stack so only the most-recently-opened one is
  ever registered in `UISpecialFrames`. The first attempt (`0.4.1-dev`)
  broke again on out-of-order closes (closing a non-topmost panel left a
  duplicate registration behind instead of replacing it); fixed by
  tracking the one currently-registered frame explicitly instead of
  inferring it from stack position.
- **Roster Settings** (melee/tank/priest name lists) are now fully
  editable per character, not just Add/Remove: each row is an inline-
  editable field with its own OK (confirm rename), Reset (discard the
  in-progress edit), and Remove button. `CritLogDB.playerGroups` migration
  unchanged from `0.4.4-dev` (copied once from a code-only seed, existing
  names kept).
- Fixed the melee/tank/priest death-sound class checks wrongly firing on
  enemy NPC deaths in instances - in-game reported against a Necromancer
  trash mob at Mount Hyjal. A resolved unit token is now discarded unless
  `UnitIsPlayer()` confirms it's an actual player.
- Fixed the boss killing-blow chat line only checking the English boss
  name list, not German.
- Fixed the highscore panel showing empty parentheses (e.g. "Damage crit
  (): 0 ()") before any crit of that kind was ever recorded.
- Gave Spirit of Redemption a real, working implementation: the buff's
  `SPELL_AURA_APPLIED` (spell id `27827`) is cached by GUID for any priest
  in the raid and read back once that priest's delayed real death
  arrives, instead of firing on every priest death. **Not yet in-game
  verified.**
- Restructured the file layout into `Core/`/`Persistence/`/`UI/` - pure
  code organization, no behavior change. See [README.md](README.md) for
  the layout.

Still not in-game verified: Spirit of Redemption, and the live
class/role/classification detection specifically for tank and boss deaths
(melee's false-positive bug is fixed and confirmed; the others use the
same pattern but haven't had a dedicated in-game test yet).

## 0.4.0

First stable release since `0.2.1`.

- Added a first-draft in-game options panel (`/cl options`): highscores
  with per-record/list reset, toggles split into a main crit-tracking
  panel and a separate Sound Settings panel (button-triggered), per-sound
  preview buttons, a hint line on every toggle, closes on Escape.
- Added a master sound switch (`MasterSoundFlag`/`/cl mute`) and a debug
  mode (`/cl debug`).
- Aura/ability triggers (Bloodlust, Innervate, Power Infusion, Mana Tide,
  Blessing of Protection, Divine Intervention, Soulstone) now match by
  spell ID first, name as fallback.
- **Experimental**: melee/tank/priest death sounds match by live
  class/role first; boss death/kill detection matches live
  `UnitClassification() == "worldboss"` first; both fall back to the old
  hardcoded name rosters when the live check doesn't resolve or match.
- Removed random multi-clip sound selection (every sound is now a single
  fixed file) and the special-cased `Schnutz` death sound; sound catalog
  trimmed to 18 files (from 24).
- Fixed several options-panel bugs found during review: `f.Inset`
  mis-anchoring, checkbox-column drift, preview buttons stuck on the
  hover color, a double-played white/ranged crit sound, and previews
  doing nothing while muted.
