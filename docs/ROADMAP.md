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
3. SavedVariables-backed player-role configuration - the options panel can
   only toggle whether melee/tank/priest/boss death sounds fire, not edit
   the underlying hardcoded name rosters (`CritLog.Data.playerGroups`/
   `bosses`). Those rosters are an intentional fallback for the live
   class/role/classification checks, not scheduled for removal.
4. Audio volume/channel control - all sounds play on the fixed `Master`
   channel via `PlaySoundFile`; no volume control beyond `MasterSoundFlag`'s
   on/off mute.
5. Configurable chat-trigger phrases (`CritLog.Data.chatTriggers` is still
   hardcoded).
6. Spirit of Redemption - give it a real, working implementation, or remove
   `SREDEMPTION_NAMES` and the disabled test block entirely. Parked, not
   scheduled either way.
7. CurseForge/Wago publishing - no project id configured yet; `.pkgmeta`
   packaging itself is done and verified.
8. **Asset/audio rights review** - none of the shipped sound files have a
   resolved rights/license status. Genuinely blocks public distribution,
   not just a nice-to-have; see
   [SOUNDS.md#required-human-review](SOUNDS.md#required-human-review).
9. TitanPanel integration (exploratory) - a status-bar plugin button for
   TitanPanel users. Harder than the items above since Titan is an optional
   third-party dependency most users won't have installed; two possible
   approaches (guard Titan API calls inline, or ship a separate companion
   addon with `## RequiredDeps: Titan`), no design decision made.

## Known constraint

No headless WoW client mode exists (see
[tests/README.md](../tests/README.md)), so there's no automated test
harness for combat-log/trigger logic beyond `luacheck` static analysis
(`scripts/lint.sh`). In-game testing is the only way to verify runtime
behavior.
