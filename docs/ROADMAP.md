# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

### 1. One-click post highscores to chat (next up)

Add a post button on the Highscore List popup (`UI/MainPanel.lua`, next to
the per-entry Delete buttons) that sends the current top record(s) to a
chosen chat channel via `SendChatMessage`, instead of manually typing or
screenshotting.

Still open: a channel picker (Whisper needs a target name field), one
combined message for all three categories vs. one per category/click, and
plain vs. colored text (`formatRecordTextColored` - WoW chat channels do
render `|c` color codes for other players). Repurposing the TitanPanel
button's left-click into a post shortcut was considered and parked - too
easy to misclick into the whole raid/guild without a confirm step first.

### 2. Per-ability crit rate tracking (low priority, not committed to)

Track normal-vs-crit hit counts per ability, not just the single
highest-value crit per category like today, to show which ability crits
most often - modeled on TitanCritLine's own equivalent feature.

Needs new persisted state (a `{ normal = N, crit = M }` counter per
ability, updated on every relevant hit, not just new highscores) and a
place to display the result (options panel, Titan tooltip, or a `/cl`
command - undecided). May not happen at all.

### 3. Watch a custom chat channel for the lottery trigger

Let the CrossGambling-style lottery trigger react in a user-joined custom
channel too, not just raid/party chat.

Technically simple - named channels funnel through `CHAT_MSG_CHANNEL`,
which passes the channel name - just needs a configurable channel-name
setting (options panel field and/or `/cl` command) instead of the
hardcoded raid/party phrases. Not started, no UI mockup yet.

## Parked

Not active priorities, revisit only if the situation changes.

### Pruning old `Persistence/Database.lua` migrations

`CritLogDB.SchemaVersion` now records exactly which migrations a
character still needs (see `CHANGELOG.md`). Once a minimum supported
schema version is declared, the migration functions below it - and the
`DEFAULTS` fields that exist purely as their source data - can be deleted.
Not yet: needs real time/version-spread first, declaring one now would be
a guess.

## Known constraint

No headless WoW client mode exists (see
[tests/README.md](../tests/README.md)), so there's no automated test
harness for combat-log/trigger logic beyond `luacheck` static analysis
(`scripts/lint.sh`). In-game testing is the only way to verify runtime
behavior.
