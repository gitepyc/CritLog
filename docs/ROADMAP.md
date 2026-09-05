# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

1. **In-game verification**, ongoing: still open are tank/boss/healer
   death-sound detection specifically (healer changed from a Priest class
   check to an assigned Healer role check, any class - needs fresh
   verification even though the general detection-mode mechanism is
   already partly tested), Spirit of Redemption, the `0.7.0` multi-entry
   highscores and fixed-row Highscore List layout, and the `0.7.1-dev`
   `## IconTexture` (unclear whether Classic Era's AddOns list actually
   renders it). Also still open from `0.9.0-dev`: the TitanPanel button's
   icon legibility scaled down to 16px, and the level-diff slider's actual
   in-game look after its latest anchor fix. Also still open, from
   `feature/legacy-sound-port`: 13 of the 14 sounds ported from the legacy
   addon (roll, lottery, Drums of Battle, Pain Suppression, Evocation,
   Mage Table) remain in-game unconfirmed - Warlock Healthstone ritual is
   now confirmed working in-game. Two of the still-unconfirmed ones
   (Drums of Battle, Mage Table) have a confirmed Wowhead spell ID but are
   confirmed TBC-introduced spells (didn't exist in vanilla WoW) - having
   the right ID doesn't confirm SoD availability. Hymn of Hope is excluded entirely:
   confirmed to not exist under that name before WotLK, cannot fire on
   Classic Era/SoD. Not a gate blocking other work - bugs found during
   verification land on `dev` as they're reported, in parallel with
   feature work below.
2. Per-ability crit rate tracking - in-game requested, modeled on
   TitanCritLine's own equivalent feature (verified against their actual
   code, not guessed): `Core/Records.lua`'s `attack[HitType]["Value"] =
   (attack[HitType]["Value"] or 0) + 1` counts every hit, split into a
   `NORMAL` and a `CRIT` bucket per ability name, persisted across
   sessions; `UI/Summary.lua`'s `tcl_GetHighestCritPercentage` computes
   `critHits / (critHits + normalHits) * 100` per ability and finds the
   one with the best rate. CritLog currently only tracks the single
   highest-*value* crit per category (`CritLogDB.records`), not hit
   counts, so this needs new state entirely: a per-ability
   `{ normal = N, crit = M }` counter table, incremented on *every*
   relevant hit (not just new highscores - the combat-log handlers
   currently mostly only care about crits at all, non-crit hits would
   need to start being counted too), plus somewhere to show the result
   (options panel section, Titan tooltip, and/or a `/cl` command are all
   plausible, not decided yet).
3. One-click post highscores to chat - in-game requested: a button (main
   panel and/or Highscore List popup) or `/cl` command to post the
   current top record(s) straight to a chosen chat channel (Guild, Raid/
   Party, Whisper, ...) via `SendChatMessage`, instead of manually typing
   or screenshotting. Needs a channel picker (Whisper additionally needs
   a target name/edit box) and a decision on which record(s) to post -
   just the current #1 per category (matching `/cl`'s plain-text chat
   output, `Core/Records.lua`'s `formatRecordText`) is the obvious first
   cut; posting a specific Highscore List entry is a possible follow-up.
   Not decided yet: one combined message for all three categories vs. one
   per category/click, and whether to reuse the colored
   `formatRecordTextColored` variant (WoW chat channels do render `|c`
   color codes for other players, unlike a plain `print()`) or stick to
   the plain uncolored text for maximum compatibility/readability. Also
   floated: an optional toggle that repurposes the TitanPanel button's
   left-click itself (normally opens `/cl options`, see
   `UI/TitanButton.lua`) into a one-click chat-post shortcut instead -
   spam risk (a single misclick posts to the whole raid/guild) probably
   means this wants a two-click confirm (first click arms it, second
   within some short window actually posts, or a StaticPopup
   confirmation like the highscore Reset buttons already use via
   `CritLog.UI.showConfirmation`) rather than firing unconditionally on
   one click. Also floated as a second, additive trigger option (not
   instead of the TitanPanel idea, alongside it): a dedicated post button
   shown directly on the Highscore List popup (`UI/MainPanel.lua`'s
   `layoutHighscoreList`), next to/near the existing per-entry delete
   buttons - would need its own decision on posting just the visible
   entry vs. the whole list. Message styling/text layout also still open
   regardless of which trigger UI(s) win.
4. CritLogDB migration/versioning cleanup - discussed in-game: there's
   currently no schema-version counter at all, only `CritLogDB.Version`
   (the addon version string, compared against `CritLog.toc` on login to
   decide whether to back-fill `DEFAULTS` and print the "updated to..."
   message). The actual migrations (`Persistence/Database.lua`'s
   `migratePlayerGroups`/`migrateToRecordLists`/`migratePriestToHeal`/
   `migrateMeleeToDps`/`migrateDetectionModes`/`migrateBossModeToFlag`/
   `migrateAllLevelToThreshold`) each run unconditionally on every login,
   guarded only by their own field's presence/absence - cheap today (7
   functions, each a nil-check), but an ever-growing list with no way to
   ever prune an old migration, since nothing records which schema
   version a character's saved data is actually on. A real incrementing
   `CritLogDB.SchemaVersion` (separate from the addon version) that each
   migration bumps past once applied would let old migrations eventually
   be deleted once a minimum supported schema version is declared -
   not designed yet, just flagged as worth doing before this list gets
   much longer.

## Parked

Not active priorities, revisit only if the situation changes:

- **Publishing (CurseForge/Wago) and the audio/asset rights review** - the
  review found the sound files' origin/license undocumented (see
  [SOUNDS.md#required-human-review](SOUNDS.md#required-human-review)),
  which likely rules out public distribution as-is. A sounds-stripped
  build was floated as one possible way around that, but it's an early
  idea, not a plan - low priority either way since staying internal/
  guild-only is a perfectly fine outcome.

## Known constraint

No headless WoW client mode exists (see
[tests/README.md](../tests/README.md)), so there's no automated test
harness for combat-log/trigger logic beyond `luacheck` static analysis
(`scripts/lint.sh`). In-game testing is the only way to verify runtime
behavior.
