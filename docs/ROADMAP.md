# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

1. **In-game verification**, ongoing: the options panel, the four
   experimental death-sound toggles (melee/tank/priest/boss), debug mode.
   Not a gate blocking other work anymore - bugs found during verification
   (e.g. the `0.4.2-dev` NPC-death-sound fix) land on `dev` as they're
   reported, in parallel with feature work below.
2. **Next up, feature work:** multi-entry highscores - top-5 list per
   category instead of a single value, each entry individually deletable.
   Built on its own branch, `feature/multi-entry-highscores`, deliberately
   kept off `dev` until it's ready to merge (bigger, schema-touching
   change than the bugfix-only work `dev` has been getting otherwise).
   Remaining: review/finish that branch, in-game-verify it, then merge.
3. ~~SavedVariables-backed player-role configuration~~ - done for the
   melee/tank/priest rosters: `CritLogDB.playerGroups`, editable via
   `/cl options` → "Roster Settings..." (Add/Remove per category). Not
   yet in-game verified. The boss name lists (`CritLog.Data.bosses`) are
   still code-only, not scoped for this pass - those rosters are still an
   intentional fallback for the live class/role/classification checks,
   not scheduled for removal.
4. Audio volume/channel control - all sounds play on the fixed `Master`
   channel via `PlaySoundFile`; no volume control beyond `MasterSoundFlag`'s
   on/off mute.
5. Configurable chat-trigger phrases (`CritLog.Data.chatTriggers` is still
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
7. Spirit of Redemption - give it a real, working implementation, or remove
   `SREDEMPTION_NAMES` and the disabled test block entirely. Parked, not
   scheduled either way.
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
