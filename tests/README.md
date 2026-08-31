# Testing CritLog

This is the single entry point for verifying changes before they ship. It
covers what is automated today and what still requires a human in the game
client.

## Static analysis (automated)

`tests/lint/Dockerfile` builds a small Alpine image with `luacheck` on Lua
5.1, matching the language version the WoW client embeds. It does **not**
have access to the real WoW API, so it validates syntax, unused
variables/arguments, shadowing, and accidental global pollution — not
whether an API call is used correctly or whether a frame renders.

Run it from the repo root:

```bash
scripts/lint.sh
```

The globals whitelist in `.luacheckrc` (`stds.wow`) only lists the WoW API
calls `CritLog.lua` actually uses. Add a new entry there when the code calls
a new API function; do not import a generic multi-thousand-entry globals
list — for a project this size a curated list stays honest about what is
actually verified.

### CI

`.github/workflows/lint.yml` runs the same container against the GitHub push
mirror (`sync_on_commit` triggers it on every Gitea push; the Gitea instance
itself has no Actions runner registered). It only fails the build on real
`luacheck` errors (exit code ≥ 2, e.g. a syntax error) — pre-existing, known
warnings (currently 10, see CHANGELOG.md) don't turn the pipeline red, since
a pipeline that's always red trains people to ignore it. Trigger it manually
from the GitHub UI ("Actions" tab → "Lint" → "Run workflow") or via
`gh workflow run lint.yml --repo gitepyc/critlog`.

## What cannot be automated here

The WoW client is a graphical game client with no supported headless mode.
There is no way to execute combat-log events, `CreateFrame`/UI code, or
`PlaySoundFile` calls outside the real client in this environment. Any
behavior change must still be verified in-game.

## Manual in-game verification

Use [docs/BEHAVIOR.md](../docs/BEHAVIOR.md) as the checklist: it lists every
registered event, its condition, and the expected sound/state change. Before
merging a behavior-affecting change:

1. Load the character in Classic Era / Season of Discovery.
2. `/reload` and confirm `CritLogDB` migrated without wiping unrelated
   settings.
3. Walk the relevant rows of the BEHAVIOR.md matrix (crits, auras, deaths,
   raid-leader chat, ready check) and confirm the expected clip plays from
   both the default and Toni (`/cl toni`) sound profiles.
4. Watch for Lua errors with `/console scriptErrors 1` or an error-display
   addon enabled.

Record what you tested (client version, class/spec, reproduction steps) in
the pull request description — see the maintenance rule in
[docs/README.md](../docs/README.md).
