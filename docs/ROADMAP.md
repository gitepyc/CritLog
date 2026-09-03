# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

1. **In-game verification**, ongoing: the options panel (including
   Escape-key behavior) and melee death-sound detection are now confirmed
   working (`0.5.0`); still open are tank/boss/healer death-sound
   detection specifically, and Spirit of Redemption - healer death-sound
   detection changed from a Priest class check to an assigned Healer role
   check (any class), so this needs fresh in-game verification even though
   the general detection-mode mechanism was already partly tested. Not a
   gate blocking
   other work anymore - bugs found during verification (e.g. the
   `0.4.2-dev` NPC-death-sound fix, the `0.4.8-dev` Escape-key fix) land on
   `dev` as they're reported, in parallel with feature work below. Also
   still open, from `feature/legacy-sound-port`: none of the 14 sounds
   ported from the legacy addon (roll, lottery, Drums of Battle,
   Pain Suppression, Hymn of Hope, Evocation, Mage Table, Warlock
   Healthstone ritual) have been in-game confirmed yet - and four of them
   (Drums of Battle, Mage Table, the Healthstone ritual, Hymn of Hope) have
   an open question of whether the underlying spell even exists to cast on
   Classic Era/SoD at all, since the legacy addon itself was never
   confirmed working for those (see `docs/BEHAVIOR.md`).
2. ~~Multi-entry highscores~~ - done: list per category
   (`CritLogDB.records.*`) instead of a single value - 10 tracked
   (`Constants.maxTrackedEntries`), top 5 shown (`Constants.maxDisplayEntries`)
   so deleting a visible entry doesn't need a new crit to refill it. Each
   entry individually deletable via the Highscore List popup's Delete
   button, or a whole category at once via
   `/cl reset damage|whitehit|heal`. Ported from the now-deleted
   `feature/multi-entry-highscores` branch onto the current
   Core/Persistence/UI layout rather than merged as-is (that branch
   predated the `0.4.6-dev` restructure). Not yet in-game verified.
3. ~~SavedVariables-backed player-role configuration~~ - done and in-game
   confirmed for the melee/tank/priest rosters: `CritLogDB.playerGroups`,
   editable via `/cl options` → "Roster Settings..." (Add/Remove, plus
   inline rename with OK/Reset per row, added in `0.5.0`). The boss name
   lists (`CritLog.Constants.bosses`) are still code-only, not scoped for
   this pass - those rosters are still an intentional fallback for the
   live class/role/classification checks, not scheduled for removal.
4. Audio volume/channel control - all sounds play on the fixed `Master`
   channel via `PlaySoundFile`; no volume control beyond `MasterSoundFlag`'s
   on/off mute.
5. Configurable chat-trigger phrases (`CritLog.Constants.chatTriggers` is still
   hardcoded).
6. Boss name-list presets per expansion (SoD/TBC/WotLK/...), selectable or
   combinable, instead of one static list. Parked, not started - needs
   real curated boss-name research (English + German) per expansion
   before it's buildable, not just UI work. Narrower practical value than
   it first looks: `isClassifiedBoss()`'s live `"worldboss"` check already
   covers real raid/world bosses for any expansion automatically: presets
   would mainly matter for 5-man dungeon end-bosses, which aren't
   classified `worldboss` and are the only thing the name-list fallback
   still does real work for.
7. ~~Spirit of Redemption~~ - done: the priest death sound now specifically
   detects a Spirit-of-Redemption-delayed death (buff spell id `27827`
   cached on apply, consumed on the later real `UNIT_DIED`), not just any
   priest dying. Reuses the plain priest-death file for now (no dedicated
   asset), see [BEHAVIOR.md](BEHAVIOR.md). Not yet in-game verified.
8. CurseForge/Wago publishing - no project id configured yet; `.pkgmeta`
   packaging itself is done and verified.
9. **Asset/audio rights review** - none of the shipped sound files have a
   resolved rights/license status. Genuinely blocks public distribution,
   not just a nice-to-have; see
   [SOUNDS.md#required-human-review](SOUNDS.md#required-human-review).
10. TitanPanel integration (exploratory) - a status-bar plugin button for
   TitanPanel users. Researched, design question from before resolved:
   since CritLog has no XML of its own (`CritLog.toc` lists plain `.lua`
   files), a single-addon approach works fine after all - no separate
   companion addon needed. Titan plugins register via a registry table
   (`id`/`menuText`/`buttonTextFunction`/etc.) passed to
   `TitanPanelButton_OnLoad()`, and the button frame is created with
   `CreateFrame("Button", name, parent, "TitanPanelTextTemplate")` - a
   runtime Lua call, not a static XML `inherits`, so it only needs to be
   wrapped in `if IsAddOnLoaded("Titan") then ... end` (checked at
   `PLAYER_LOGIN`, same place `Events.lua` already hooks) to stay
   completely inert - no error, nothing created - when Titan isn't
   installed. `## OptionalDeps: Titan` in `CritLog.toc` for load order
   (so Titan's API exists first if both are present), not
   `## Dependencies:` (that would force Titan as a hard requirement,
   wrong for an addon most users won't have it for). Button content
   decided: top score for damage/white-hit/heal, left-click opens
   `/cl options`, right-click a small context menu (contents TBD).

## Known constraint

No headless WoW client mode exists (see
[tests/README.md](../tests/README.md)), so there's no automated test
harness for combat-log/trigger logic beyond `luacheck` static analysis
(`scripts/lint.sh`). In-game testing is the only way to verify runtime
behavior.
