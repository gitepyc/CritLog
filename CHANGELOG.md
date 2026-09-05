# Changelog

**Next up:** in-game verification is the main open item across the board -
see [docs/ROADMAP.md](docs/ROADMAP.md) for the full prioritized list.

**Entry format:** one line per change, `**type:** short bullet`
(`feature`/`fix`/etc., bolded) - as terse as possible, no prose, no
rationale. Save the "why" for the commit message/PR, not here.

## 0.9.1-dev

- **refactor:** raid-end sound consolidated into one file (`raidend.mp3`, concatenated from `bye.mp3`+`end.mp3`), single `PlaySound` call instead of two - the two previously fired at the same instant with no gap/silence between them at all, so they fully overlapped for `bye.mp3`'s ~4s duration
- **tweak:** Help panel's credit line is now two lines (`CritLog` / `by Epyc, 2026 ...`) instead of one, smaller/greyed-out font (`GameFontDisableSmall`) so it reads as a footer, not a heading
- **chore:** `CritLog.toc`'s `## Interface:` now declares Retail, MoP Classic, TBC Classic, and Classic Era/SoD (matching TitanCritLine), not just Classic Era/SoD
- **refactor:** DPS death-sound detection is now a real 3-role system (Tank/Healer/everyone else) instead of a class-based guess that silently never fired for Hunter/Mage/Warlock/Priest
- **fix:** melee and tank death sounds fired together for a Warrior/Rogue assigned the Tank role
- **fix:** reset confirmation popups ("Reset All" etc.) were hidden behind our own FULLSCREEN panels
- **feature:** Warlock Healthstone ritual sound confirmed working in-game

## 0.9.0.4-dev

- **fix:** roll10 sound trimmed to its first 2.5s (was 9.7s, far longer than every other roll sound)

## 0.9.0.3-dev

- **fix:** Raid Chat Phrases section on Sound Settings was anchored off-panel (labels/Preview buttons ran off the right edge)
- **fix:** main panel master switch label - "Sounds enabled" instead of "Sound enabled"
- **feature:** note explaining exactly which raid-leader chat phrases trigger the raid end/wipe sounds

## 0.9.0.2-dev

- **feature:** all 33 sound files normalized (loudness, sample rate, bitrate) - see `docs/SOUNDS.md` and `scripts/normalize-sounds.sh`

## 0.9.0.1-dev

- **feature:** "Sound enabled" master switch moved off the Sound Settings submenu onto the main panel, right above the Sound Settings button
- **feature:** added missing sound previews - raid-leader chat phrases (raid end, wipe) and lottery's second clip

## 0.9.0.0-dev

Version-number rollback point: everything from here down through
`## 0.9.0-dev` below uses the OLD pre-rollback numbering (deliberately
higher-looking than `0.9.0.0-dev` despite being chronologically older -
those tags were deleted once the numbers were freed up again). Sections
are ordered by actual date, not by comparing version strings - do not
resort this file by parsing version numbers.

- **fix:** white-hit crits (melee and ranged) now always play the highscore sound on a new personal record even with "Sound for white hit crits" off, matching how ability/heal crits already behaved; ranged white-hit records were also being skipped entirely (not even recorded) with that setting off - now recorded unconditionally like melee

## 0.9.8.5-dev

- **feature:** Debug mode moved off the main "Options" group - now a small indented checkbox below the Sound Settings/Help buttons instead of grouped with the level filter, since it's dev/troubleshooting-only

## 0.9.8.4-dev

- **feature:** colored highscore display (spell/target/amount) shared between the TitanPanel tooltip and the main options panel now, via a new `Core/Records.lua` `formatRecordTextColored` instead of a Titan-only copy
- **feature:** color scheme retuned - target dark green (was red), plain text dark gold (was white), amount gradient now green-to-red
- **feature:** Roll Sounds/Aura sound hints no longer state the exact sound count; Roll Sounds hint also says "on the side" instead of "below", matching its new position
- **feature:** Help panel shrunk (920x660 -> 800x600)

## 0.9.8.3-dev

- **fix:** TitanPanel button text never updated after a new crit (stayed on "-/-/-" forever, even though the hover tooltip showed the correct data) - Titan doesn't refresh button text on its own, now explicitly told to via `TitanPanelButton_UpdateButton` whenever a highscore is recorded

## 0.9.8.2-dev

- **feature:** Help panel's About/credits line now anchored to the bottom of the panel itself (centered, just above the Close button) instead of chained below the content above

## 0.9.8.1-dev

- **fix:** Roll Sounds button overflowed past the panel's right edge and sat awkwardly on its own row - now sized/positioned like a Preview button, same row as the RollSoundFlag checkbox
- **feature:** TitanPanel tooltip colors toned down again - spell gold, target muted red, amount scale now starts at green instead of white (in-game screenshotted: the yellow/blue/heat-scale combo "didn't look good")

## 0.9.8-dev

- **feature:** TitanPanel tooltip restyled - spell yellow, target blue (was blue/red, "didn't look good"), plain text now explicitly white instead of relying on GameTooltip's own default
- **feature:** Roll Sounds button moved under the shared Preview-button column instead of flush-left
- **feature:** Help panel's About/credits line pushed further down and a touch brighter, reads as its own footer now
- **feature:** Aura/spell sound hint no longer states the exact count ("13"), just "spell sounds"

## 0.9.7-dev

- **feature:** TitanPanel tooltip amount colors retuned - orange from 4000, red from 8000 (was 5000/10000)

## 0.9.6-dev

- **feature:** TitanPanel tooltip title changed to "CritLog Summary"
- **feature:** TitanPanel tooltip styled - ability/target names colored, amount colored by a rough size-based heat scale (white/yellow/orange/red)

## 0.9.5-dev

- **fix:** Help panel rows drifted one level further right with every single row (a growing staircase) - a chained x-offset wasn't being cancelled between rows, same class of bug this file has hit before
- **feature:** Sound Settings - Roll Sounds button now sits directly under its own toggle instead of grouped with Aura/Death Sounds at the end; Aura toggle + Aura/Death Sounds button row follow after, unchanged from before

## 0.9.4-dev

- **feature:** Roster Settings explains its own save behavior - Add/Remove take effect immediately, renaming only saves on Enter/OK

## 0.9.3-dev

- **fix:** Death Sounds dropdown rows' Preview buttons were completely unclickable - the dropdown's own expanded tooltip hit rect fully covered them and won every click; same latent risk fixed proactively for every checkbox row's Preview button too, not yet reported there

## 0.9.2-dev

- **feature:** new Roll Sounds panel (opened from Sound Settings, same pattern as Aura/Death Sounds) - Preview button for each of the 6 roll-result sounds; still one shared toggle (`RollSoundFlag`) for all of them, not individually toggleable
- **feature:** Roll Sounds row moved to sit right after Lottery on the Sound Settings panel, renamed from "Roll sound" to "Roll Sounds"

## 0.9.1-dev (pre-rollback, unrelated to the 0.9.1-dev section above)

Old version-number scheme, from before the 0.9.0.0-dev version rollback
(see the `## 0.9.0.0-dev` section above) reused this exact number for an
unrelated later release. This tag no longer exists in git (deleted during
that rollback) - kept here for historical record only, ordered by actual
date rather than by the now-ambiguous version string.

- **feature:** TitanPanel button text - numbers rendered white, matching TitanCritLine's own color scheme (separators stay the default gold)

## 0.9.0-dev

Merges two standalone test branches into `dev`: `feature/level-diff-slider`
(0.8.0-0.8.3-leveldiff-dev) and `feature/titan-panel-integration`
(0.1.0-0.1.7-titanpanel-dev), plus `dev`'s own 0.7.6-0.7.8-dev work. See
git history for the version-by-version path each one took.

- **feature:** level filter is now a separate enable checkbox (`LevelFilterFlag`) plus a 1-20 threshold slider (`LevelDiffThreshold`), replacing the old single `AllLevel` on/off flag - modeled on TitanCritLine's level-adjustment slider
- **feature:** optional TitanPanel status-bar button - icon, live "CL: <dmg>/<white>/<heal>" text, hover tooltip with full per-category detail, left-click opens `/cl options`, right-click menu (Options, Reset All Highscores); entirely inert without Titan installed
- **feature:** every highscore reset (per-category buttons and matching chat commands) now asks for confirmation, not just "Reset All"
- **feature:** Help panel reworked - two columns (General/Sounds), real section headings instead of "------------", command highlighted with its description below instead of one plain line
- **fix:** toggle-row tooltips sometimes rendered much too large until moving the mouse away and re-hovering - GameTooltip now explicitly hidden before every re-show
- **fix:** `/cl reset damage/whitehit/heal` line had gone missing from the Help panel - a literal `|` in the text was being parsed as a WoW color-code escape sequence

## 0.7.5-dev

- **feature:** Death Sounds dropdown order now matches Roster Settings (DPS, Tank, Healer, Boss)
- **feature:** dropdown hints say "Experimental:" instead of "Live check:", matching the mode's actual name

## 0.7.4-dev

- **fix:** toggle-row tooltips reported still not showing - root cause was our own options panels sitting on TOOLTIP frame strata, competing with GameTooltip itself; panels now use FULLSCREEN (matching TitanCritLine's settings panel), tooltip code back to the plain TitanCritLine pattern

## 0.7.3-dev

- **fix:** toggle-row tooltips reported still not showing - anchor now matches TitanCritLine's proven pattern, plus explicit EnableMouse

## 0.7.2-dev

- **fix:** toggle-row tooltips still didn't show (hit-rect expansion used a width that read as 0)

## 0.7.1-dev

- **feature:** hover tooltips instead of static hint text under each toggle row
- **fix:** main options panel was missing its Close button
- **feature:** addon icon (`media/icon.png`), wired up via `## IconTexture`
- **fix:** toggle-row tooltips didn't show at all (GameTooltip vs. our own TOOLTIP-strata panels)

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

## 0.2.1

Small follow-up to `0.2.0`, fixing one real gameplay bug found right
after that tag.

- **Fixed the damage-crit level filter**: it always checked the level of
  the player's currently UI-selected target, not the actual enemy that
  was hit (the combat log only gives a GUID) - a crit against one enemy
  could be wrongly filtered using a completely different enemy's level.
  Now resolves the correct unit (checking the current target first, then
  falling back to a nameplate scan), and lets the crit through unfiltered
  if no unit token can be found at all rather than silently dropping it.
  Heal crits were already unaffected by this filter.
- Removed `README.txt` (superseded by `README.md`/`docs/`); the addon
  version is now read once from `CritLog.toc` instead of being
  duplicated in code. Two roadmap items documented but not yet acted on:
  replacing the hardcoded player-name rosters with class-based matching,
  and giving Spirit of Redemption a real fix or removing it.

## 0.2.0

First tagged release after the addon's initial import - covers repo
setup, a first pass of bugfixes, and an early round of sound/dead-code
cleanup.

- **Toni becomes the only sound profile**: the alternate "default" sound
  set is dropped along with `/cl toni` and the profile-switching
  mechanism. Sound files shrank from the original 68 down to 24 as
  duplicates and orphaned files were removed along the way; Power
  Infusion and Tank-death "random" sound picks turned out to be
  non-random within Toni since their candidate files were byte-identical
  copies of each other - they now honestly play a single fixed clip.
- **Fixed destructive version upgrades**: `SetDefaults()` used to fully
  wipe every character's saved highscores and toggles whenever the addon
  version changed; it now only back-fills missing fields, preserving
  existing data.
- **Fixed several real bugs**: Divine Intervention referenced a missing
  sound file and always failed to play; Soulstone's random-sound range
  didn't cover all three of its clips, and one clip was missing from the
  Toni profile entirely; the heal-crit path was wrongly subject to the
  enemy-level filter meant only for damage crits; `/cl reset` was
  silently resetting the sound-profile and custom sound-path fields
  instead of preserving them; damage/heal highscore output printed the
  ability name in place of the target's name (twice, effectively hiding
  the actual target).
- **Revived the "over 9000 damage" extreme-hit sound** as a real working
  feature (`XtremeSoundFlag`/`/cl xtreme`, off by default) instead of
  leaving it as dead, commented-out code.
- **Removed the login-sound feature entirely** (toggle, command, and
  playback code) since it had a working toggle but no code path ever
  read it; also removed other dead code (`ZONE_CHANGED`, `Split()`) and
  orphaned assets (`Login.mp3`, an unreferenced 14-file "more sounds"
  folder).
- Centralized previously scattered hardcoded sound/spell/boss/roster
  constants into a single `CritLogData` table - no behavior change.
- Split the single-file addon into focused modules, with a follow-up
  pass fixing review issues (content dropped during the split restored,
  `.luacheckrc` globals corrected).
- Flattened the repository layout - CritLog moved out of a subdirectory
  of the former shared `wow-addons` monorepo to its own repo root.
- Added repository scaffolding: license, `.gitignore`/`.editorconfig`, a
  containerized luacheck setup plus a CI lint workflow (only failing on
  real errors, not warnings), and `.pkgmeta` packaging verified
  end-to-end - including fixing the packager shipping its own
  auto-generated changelog instead of ours.
- Added `README.md`/`docs/` (behavior, sound inventory, a cleanup
  checklist, refactoring notes), translated from the original German
  documentation to English.
- Added `release.yml` to build and publish a GitHub Release with the
  packaged zip on every tag push.
- Addon now credits Epyc as current author and Chabo as original
  creator.

## legacy-0.1.4.2

Not a release of this repository's own CritLog rewrite - listed here for
completeness, between `0.1.1` and `0.2.0` by version number rather than by
when the git tag was actually created (which was much later, once the
rewrite below was already largely done).

This tag archives a newer version of the *original, standalone*
single-file legacy addon (version `0.1.4.2`, its own independent
numbering), obtained directly from the original creator (Kîtten aka
Chabo) after this repo's `0.1.1` import already existed. Kept as a Gitea/
GitHub release for reference, and later used as the source for
`feature/legacy-sound-port`'s 14 backported sounds (see `0.7.0` above).

## 0.1.1

Initial import of the addon into this repository.

- Adds `CritLog.lua`, `CritLog.toc`, `README.txt`, and the original
  `sounds/` folder as a single self-contained addon, carried over
  unchanged from its pre-existing legacy form.
