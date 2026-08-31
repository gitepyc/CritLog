# Cleanup Review Checklist

## Resolved: default vs. Toni

CritLog used to ship two interchangeable sound profiles (default and an
alternate "Toni" set, switchable with `/cl toni`). That decision is made:
the Toni set was promoted to be the only profile, the old default-only
clips were dropped, and the whole profile-switching mechanism
(`ASSISOUND`, `ToniFlag`, `/cl toni`, the `ResolveSound()`/dedup-alias
machinery from the interim step) was removed as no longer needed. See
`CHANGELOG.md` for the exact steps.

One real behavior change from that merge, not just an asset swap: **Power
Infusion** and **Tank death** used to pick "randomly" among 2–3 sound
files, but in the Toni set those files were byte-identical copies of each
other, so the randomness was always fake. The code now plays a single fixed
clip for both — same audible result as before, less code.

## Resolved: dead weight

The first dead-weight pass is done:

| What | Outcome |
| --- | --- |
| "Over 9k damage" sound | **Revived, not deleted.** Now a real feature gated by `XtremeSoundFlag`/`/cl xtreme`, off by default. Uses the same `sourceGUID == UnitGUID("Player")` check already established elsewhere in the file instead of the original's fragile `Split()`-based string parsing. |
| Spirit of Redemption test code | **Left as-is, deliberately.** Still fully commented out (`SREDEMPTION_NAMES`, the marked-"not working" block). May get its own fix later. |
| `ZONE_CHANGED` handler | Removed — its `RegisterEvent` call was already commented out, so it could never fire. |
| `Split()` function | Removed — was only referenced inside a commented-out debug condition, never called at runtime. |
| Login sound | Removed entirely: `LOGIN_SOUND` constant, the commented-out playback in `PLAYER_LOGIN`, the live-but-pointless `LoginSoundFlag` field, the `/cl login` command, and its `help`/`config` lines. It had a real toggle but no code path ever read it. |
| `Login.mp3` | Deleted — its last reference is gone. |
| `CritLog/sounds/more sounds/` (14 files) | Deleted — none of it was ever referenced by any trigger. |

`CritLogDB` migration was checked for every field change here, same as the
Toni merge: `CRITLOG_VERSION` is unchanged. Removed fields (`LoginSoundFlag`)
simply stop being read/written for existing characters — no error, no data
loss for fields still in use. The new field (`XtremeSoundFlag`) needs no
migration either: a saved character without it just reads as `nil`, which
is falsy in the `if CritLogDB.XtremeSoundFlag` check — so it's "off by
default" automatically, for old and new characters alike, without any
explicit default-writing step.

The sound catalog is now 24 files, all in active use — see
[SOUNDS.md](SOUNDS.md).

## Still open: needs a decision, not just deletion

These aren't unreachable code — they run every time, they just encode
choices specific to one historical raid group. Deliberately left in for
now; a later refactor, not a cleanup pass:

| # | What | Where |
| ---: | --- | --- |
| 1 | Hardcoded melee/tank/healer-priest death rosters (`MELEE_NAMES`, `TANK_NAMES`, `HEALPRIEST_NAMES`) plus the special-cased `"Schnutz"` death sound | Death-sound triggers — see [BEHAVIOR.md](BEHAVIOR.md#deaths) |
| 2 | `CritLog/README.txt` — 3-line legacy readme, fully superseded by the root `README.md` and `docs/` | `CritLog/README.txt` |

For anyone who isn't in that original roster, the melee/tank/priest death
sounds simply never fire today — dead weight in practice, but removing it
changes what the addon does for you specifically, so it's a product
decision (keep as-is for nostalgia, make it configurable, or cut it), not a
pure cleanup.

## Reminder

None of the kept files have a resolved rights/license status yet (see
[SOUNDS.md#required-human-review](SOUNDS.md#required-human-review)). A file
surviving this cleanup pass still needs that review before public
distribution.
