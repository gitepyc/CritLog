# Cleanup Review Checklist

## Resolved: default vs. Toni

CritLog used to ship two interchangeable sound profiles (default and an
alternate "Toni" set, switchable with `/cl toni`). That decision is made:
the Toni set was promoted to be the only profile, the old default-only
clips were dropped, and the whole profile-switching mechanism
(`ASSISOUND`, `ToniFlag`, `/cl toni`, the `ResolveSound()`/dedup-alias
machinery from the interim step) was removed as no longer needed. See
`CHANGELOG.md` for the exact steps. `CritLogDB` migration was checked at
each step: `CRITLOG_VERSION` never changed, so existing characters' saved
data is left untouched on login and any now-unused fields (`ToniFlag`,
`SoundFile`) simply stop being read — no reset, no error, no data loss for
fields still in use.

One real behavior change from that merge, not just an asset swap: **Power
Infusion** and **Tank death** used to pick "randomly" among 2–3 sound
files, but in the Toni set those files were byte-identical copies of each
other, so the randomness was always fake. Rather than duplicate a file back
in just to keep pretending, the code now plays a single fixed clip for both
(`POWERINFUSION_SOUND`, `TANK_DEAD`) — same audible result as before, less
code.

## Dead weight

Concrete candidates for the next cleanup pass, each with what removing it
actually costs and touches. None of these are removed yet — this is the
list to check off, not a change already made.

### Code with zero live surface (safe to delete outright)

| # | What | Where | Why it's dead |
| ---: | --- | --- | --- |
| 1 | "Over 9k damage" sound feature | `XTREME_DMG` constant + ~6-line commented block in `COMBAT_LOG_EVENT_UNFILTERED` | Fully commented out, no `/cl` toggle ever existed for it |
| 2 | Spirit of Redemption test code | `SREDEMPTION_NAMES` constant + ~6-line commented block | Commented out, author's own note says "not working" |
| 3 | `ZONE_CHANGED` handler | Whole function (~12 lines) | Its `RegisterEvent` call is commented out — the handler can never fire |
| 4 | `Split()` function | Whole function (~7 lines) | Only referenced inside a commented-out debug condition; never called at runtime |

None of these have a `CritLogDB` field, so deleting them doesn't touch the
saved-variables schema at all — no migration concern.

### Code with live-but-pointless config surface

| # | What | Where | Why it's dead |
| ---: | --- | --- | --- |
| 5 | Login sound | `LOGIN_SOUND` constant, commented-out playback in `PLAYER_LOGIN`, **and** the live `LoginSoundFlag` field + `/cl login` toggle + its `help`/`config` lines | `/cl login` genuinely flips a saved flag, but no code path ever reads it to play anything — toggling it is a no-op that looks like it does something |

Removing #5 means dropping `LoginSoundFlag` from the `CritLogDB` table
constructors (both in `SetDefaults()` and the `/cl reset` path). Same safe
pattern already used for `ToniFlag`/`SoundFile`: existing characters keep
whatever value they have sitting unused in their saved data; it's simply
never read or rewritten going forward.

### Orphaned assets

| # | What | Size | Tied to |
| ---: | --- | ---: | --- |
| 6 | `Login.mp3` | 77,574 B | Item 5 above |
| 7 | `Xtreme.mp3` | 42,214 B | Item 1 above |
| 8 | `CritLog/sounds/more sounds/` (14 files, none referenced by any trigger, ever) | ~1.5 MB | Nothing — pure leftover candidates, see [SOUNDS.md](SOUNDS.md#candidate-files-more-sounds) |

Deleting 6–7 only makes sense together with removing their matching dead
code (1 and 5) — otherwise the constants/comments reference files that no
longer exist. Item 8 has no code dependency at all and can be deleted
independently of everything else.

### Needs a decision, not just deletion

These aren't unreachable code — they run every time, they just encode
choices specific to one historical raid group. Worth a conscious call
before a public release, not a mechanical cleanup:

| # | What | Where |
| ---: | --- | --- |
| 9 | Hardcoded melee/tank/healer-priest death rosters (`MELEE_NAMES`, `TANK_NAMES`, `HEALPRIEST_NAMES`) plus the special-cased `"Schnutz"` death sound | Death-sound triggers — see [BEHAVIOR.md](BEHAVIOR.md#deaths) |
| 10 | `CritLog/README.txt` — 3-line legacy readme, fully superseded by the root `README.md` and `docs/` | `CritLog/README.txt` |

Item 9 is the bigger one: for anyone who isn't in that original roster, the
melee/tank/priest death sounds simply never fire — dead weight in practice,
but removing it changes what the addon does for you today, so it's a
product decision (keep as-is for nostalgia, make it configurable, or cut
it), not a pure cleanup.

## Reminder

None of the kept files have a resolved rights/license status yet (see
[SOUNDS.md#required-human-review](SOUNDS.md#required-human-review)). A file
surviving this cleanup pass still needs that review before public
distribution.
