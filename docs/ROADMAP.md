# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

1. **In-game verification**, ongoing: still open are tank/boss/healer
   death-sound detection specifically (healer changed from a Priest class
   check to an assigned Healer role check, any class - needs fresh
   verification even though the general detection-mode mechanism is
   already partly tested), Spirit of Redemption, the `0.7.0` multi-entry
   highscores and fixed-row Highscore List layout, and the `0.7.1-dev`
   tooltip refactor. Also still open, from `feature/legacy-sound-port`:
   none of the 14 sounds ported from the legacy addon (roll, lottery,
   Drums of Battle, Pain Suppression, Evocation, Mage Table, Warlock
   Healthstone ritual) have been in-game confirmed yet. Three of them
   (Drums of Battle, Mage Table, the Healthstone ritual) have a confirmed
   Wowhead spell ID but are confirmed TBC-introduced spells (didn't exist
   in vanilla WoW) - having the right ID doesn't confirm SoD availability.
   Hymn of Hope is excluded entirely: confirmed to not exist under that
   name before WotLK, cannot fire on Classic Era/SoD. Not a gate blocking
   other work - bugs found during verification land on `dev` as they're
   reported, in parallel with feature work below.
2. Configurable boss name list - `CritLog.Constants.bosses`' name-list
   fallback (used when live `UnitClassification` doesn't return
   `"worldboss"`, e.g. 5-man dungeon end bosses) is currently code-only and
   still the original Burning Crusade roster, matching nothing in Classic
   Era/SoD. Make it editable per character, the same Add/Remove pattern
   already used for the melee/tank/heal death-sound rosters
   (`CritLogDB.playerGroups`, see `UI/RosterPanel.lua`) - players add the
   names they actually need instead of waiting on curated research. Folds
   in the old "presets per expansion" idea as an optional extra on top of
   this, not a separate research-heavy project: once the list is editable,
   shipping a couple of quick-add preset buttons (SoD/TBC/...) is a small
   follow-up, not its own effort.
3. TitanPanel integration - a status-bar plugin button. Researched, design
   settled: single-addon approach works (`CritLog.toc` has no XML to
   conflict with), wrapped in `if IsAddOnLoaded("Titan") then ... end` at
   `PLAYER_LOGIN` so it's inert without Titan installed. `## OptionalDeps:
   Titan` in `CritLog.toc` for load order. Button shows top score for
   damage/white-hit/heal, left-click opens `/cl options`, right-click a
   small context menu (contents TBD).
4. Addon icon - a first draft SVG exists (comic "BÄM"-burst style, tying
   into the highscore sound's own naming) but isn't in the repo yet, needs
   a look and sign-off first. Useful for the Titan button texture above
   and any future CurseForge/Wago page, even while publishing itself stays
   parked.

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
