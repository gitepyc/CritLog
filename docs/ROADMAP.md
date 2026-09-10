# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

1. One-click post highscores to chat - **next feature up.** Chosen trigger:
   a dedicated post button directly on the Highscore List popup
   (`UI/MainPanel.lua`'s `layoutHighscoreList`), next to/near the existing
   per-entry Delete buttons - posts the current top record(s) straight to
   a chosen chat channel (Guild, Raid/Party, Whisper, ...) via
   `SendChatMessage`, instead of manually typing or screenshotting. Needs
   a channel picker (Whisper additionally needs a target name/edit box)
   and a decision on posting just the visible entry vs. the whole list.
   Not decided yet: one combined message for all three categories vs. one
   per category/click, and whether to reuse the colored
   `formatRecordTextColored` variant (WoW chat channels do render `|c`
   color codes for other players, unlike a plain `print()`) or stick to
   the plain uncolored text for maximum compatibility/readability.
   Message styling/text layout also still open. The earlier idea of
   repurposing the TitanPanel button's left-click itself (normally opens
   `/cl options`, see `UI/TitanButton.lua`) into a one-click chat-post
   shortcut is parked for now, not the chosen approach - if revisited, it
   would need a two-click confirm or a `CritLog.UI.showConfirmation`
   StaticPopup first, since a single misclick would post to the whole
   raid/guild.
2. CritLogDB migration/versioning cleanup - discussed in-game: there's
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
3. Per-ability crit rate tracking - lowest priority, not committed to yet
   (may not happen at all). In-game requested, modeled on TitanCritLine's
   own equivalent feature (verified against their actual code, not
   guessed): `Core/Records.lua`'s `attack[HitType]["Value"] =
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
4. Watch a custom/user-created chat channel for the lottery trigger, not
   just raid/party - in-game floated: what if someone runs the gambling
   announcement through a dedicated custom channel (e.g. a "World"-style
   channel joined via `/join`) instead of raid/party chat? Technically
   possible: named channels all funnel through one shared event,
   `CHAT_MSG_CHANNEL`, which also passes the channel name
   (`channelName`/`channelBaseName`) - filtering on that name (not the
   channel *number*, which is unstable across clients/join order) would
   catch it. Needs the channel name to be **configurable** (an options
   panel text field and/or a `/cl` command), not hardcoded like the
   raid/party phrases are - different users would name their channel
   differently. Not started, no UI mockup yet.
5. Roll-sound range handling - bring back percentage-based bands for
   custom roll ranges, refined from the original legacy behavior (not a
   straight revert). `Core/Filters.lua`'s `classifyRoll` currently
   requires an exact `1-100` roll; anything else plays no sound. Agreed
   design - drop the size gate entirely (`rollMin == 1` is the only
   requirement, same as the original legacy code, minus its
   `rollMax >= 100` floor):
   - `roll1`/`roll100`/`roll69` are **exact-value** matches (rolled
     literally `1`, literally `rollMax`, or literally `69`) - not
     percentage-based, not even `roll1`. The original legacy code
     checked `roll1` against `1% of rollMax` (rarely a whole number,
     e.g. `0.5` for a `1-50` roll - effectively dead for most ranges);
     tying it to the literal minimum instead mirrors `roll100` and is
     meaningful for every range size. Checked early in the match order
     (before the percentage bands below), so a literal roll of `1`
     always plays `roll1`, never `roll10`.
   - `roll5`/`roll10`/`roll95` are **percentage-based**
     (`<8%`/`8-10%`/`>=92%` of `rollMax`, matching the original bands).
     No explicit minimum-range guard needed: for a small custom range
     (e.g. `/roll 1-10`), the bands are naturally unreachable by the
     math itself (the exact-value checks above already claim the only
     candidate values, or the threshold falls below the smallest
     possible roll) - not a bug, just falls silent for that range, same
     net effect as an explicit floor without needing one.
   A plain `/roll` (1-100) is unaffected either way, since it already
   satisfies every check the same as before. Wording/hints on the Roll
   Sounds panel need updating to describe the new exact-vs-percentage
   split once implemented.

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
