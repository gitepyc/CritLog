# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

1. **In-game verification** of everything built recently: the options panel
   (layout, master mute, hint text, per-record reset buttons), the four
   experimental death-sound toggles (melee/tank/priest/boss - live
   class/role/classification detection with name-list fallback), debug
   mode, and the double-played white/ranged crit sound fix. Nothing further
   should build on top of this until it's confirmed working.
2. Expand the highscore display - a popup or a short list of the top 5-10
   entries instead of a single record per category.
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
