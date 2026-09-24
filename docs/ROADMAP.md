# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

### 1. Per-ability crit rate tracking (low priority, not committed to)

Track normal-vs-crit hit counts per ability, not just the single
highest-value crit per category like today, to show which ability crits
most often - modeled on TitanCritLine's own equivalent feature.

Needs new persisted state (a `{ normal = N, crit = M }` counter per
ability, updated on every relevant hit, not just new highscores) and a
place to display the result (options panel, Titan tooltip, or a `/cl`
command - undecided). May not happen at all.

## Parked

Not active priorities, revisit only if the situation changes.

### Pruning old `Persistence/Database.lua` migrations

`CritLogDB.SchemaVersion` now records exactly which migrations a
character still needs (see `CHANGELOG.md`). Once a minimum supported
schema version is declared, the migration functions below it - and the
`DEFAULTS` fields that exist purely as their source data - can be deleted.
Not yet: needs real time/version-spread first, declaring one now would be
a guess.

Checked against the actual known user base (only `0.1.1`/`legacy-0.1.4.2`
plus the current dev line - nobody else has tested the versions between):
both predate every one of the 7 migrations (no `playerGroups`, no
dps/tank/heal roles, no `BossSoundFlag`, raw `AllLevel` instead of
`LevelFilterFlag`/`LevelDiffThreshold`, a single `DamageAbilityCrit` value
instead of record lists), so all 7 are still load-bearing for that upgrade
path today - none are safe to prune until a minimum supported version is
actually declared.

## Known constraint

No headless WoW client mode exists (see
[tests/README.md](../tests/README.md)), so there's no automated test
harness for combat-log/trigger logic beyond `luacheck` static analysis
(`scripts/lint.sh`). In-game testing is the only way to verify runtime
behavior.
