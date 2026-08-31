# Cleanup Review Checklist

A condensed, decision-oriented view for deciding what to keep, replace, or
cut. Full technical detail (conditions, payload fields, exact matching
rules) lives in [BEHAVIOR.md](BEHAVIOR.md) and [SOUNDS.md](SOUNDS.md) — this
page exists so you don't have to cross-reference two tables while deciding.

Each trigger below has a number; the sound list references it under "Used
by" so you can see at a glance which sound files become orphaned if you cut
a trigger.

## Triggers

`= default` means the Toni file is byte-identical to the default one (same
audio, no reason to listen twice). Everything else in the Toni column is a
genuinely different clip.

| # | Trigger | Toggle | Default mode | Toni mode |
| ---: | --- | --- | --- | --- |
| 1 | `PLAYER_LOGIN` — always fires, inits/migrates `CritLogDB`, prints stored highscores | none | — (Login sound wired but disabled, see #24) | — (same) |
| 2 | Ready check | `/cl ready` | `Ready.mp3` | `= default` |
| 3 | Player's `SPELL_DAMAGE` crit | `/cl allcrits`, `/cl sound` | `at_bam_babam.mp3` | `= default` |
| 4 | Player's `SWING_DAMAGE` crit (white hit) | `/cl whitehit` | `at_bam_babam.mp3` | `= default` |
| 5 | Player's `RANGE_DAMAGE` crit (counted as white hit) | `/cl whitehit` | `at_bam_babam.mp3` | `= default` |
| 6 | Player's `SPELL_HEAL` crit | `/cl allcrits` | `at_bam_babam.mp3` | `= default` |
| 7 | Party/raid member summons Mana Tide Totem | `/cl aura` | `Manatide.mp3` | different clip |
| 8 | Player receives Bloodlust/Heroism | `/cl aura` | `Bloodlust.mp3` | different clip |
| 9 | Player receives Innervate | `/cl aura` | `Inervate1.mp3` / `Inervate2.mp3` (random) | different clips (both) |
| 10 | Player receives Power Infusion | `/cl aura` | `Surprise.mp3` / `Surprise2.mp3` / `Surprise3.mp3` (random, 3 **distinct** clips) | `Surprise.mp3` / `Surprise2.mp3` / `Surprise3.mp3` (random, but `Surprise2.mp3`/`Surprise3.mp3` were byte-identical copies and have been removed — `ResolveSound()` redirects all three picks to the one remaining `Surprise.mp3`) |
| 11 | Player receives Blessing of Protection | `/cl aura` | `Bubble.mp3` | different clip |
| 12 | Player receives Divine Intervention | `/cl aura` | `divineInt.mp3` | `= default` |
| 13 | Player receives Soulstone Resurrection | `/cl aura` | `soulstone.mp3` / `soulstone2.mp3` / `soulstone3.mp3` (random) | `= default` for all three (we copied `soulstone2.mp3` in to close a prior gap) |
| 14 | Player dies | `/cl player` + `/cl dead` | `MarioDeath.mp3` | different clip |
| 15 | Hardcoded roster member "Schnutz" dies (special case) | `/cl melee` + `/cl dead` | `schnutz.mp3` | different clip |
| 16 | Any other hardcoded `MELEE_NAMES` roster member dies | `/cl melee` + `/cl dead` | `wilhelm.ogg` | `= default` |
| 17 | Hardcoded EN/DE TBC boss list — boss dies | `/cl boss` + `/cl dead` | `FFX.mp3` / `Zelda.mp3` (random) | `= default` for both |
| 18 | Hardcoded `TANK_NAMES` roster member dies | `/cl tank` + `/cl dead` | `Tank.mp3` / `Tank2.mp3` (random, 2 **distinct** clips) | `Tank.mp3` / `Tank2.mp3` (random, but `Tank2.mp3` was a byte-identical copy and has been removed — `ResolveSound()` redirects both picks to the one remaining `Tank.mp3`) |
| 19 | Hardcoded `HEALPRIEST_NAMES` roster member dies | `/cl priest` + `/cl dead` | `Angels1.mp3` / `Angels2.mp3` (random) | `= default` for both |
| 20 | Raid leader says "raid end" / "raid ende" in chat | none — always active | `bye.mp3` then `end.mp3` (may overlap) | different clips (both) |
| 21 | Raid leader says "wipe" / "shit show" in chat | none — always active | `wipe.mp3` | `= default` |
| 22 | Hardcoded boss list — killing blow chat print | none | text only, no sound | text only, no sound |
| 23 | Zone change | inactive — event not registered | — | — |
| 24 | Login sound | inactive — commented out | — (file doesn't exist in this profile) | `Login.mp3` exists but is unreachable |
| 25 | "Over 9k" damage hit | inactive — commented out | — (file doesn't exist in this profile) | `Xtreme.mp3` exists but is unreachable |
| 26 | Spirit of Redemption | inactive — commented out, marked "not working" | — | — |

### Do you need to carry sounds over if Toni becomes the only profile?

**No, not for anything that currently plays.** Every trigger that is active
today (2–21) already has a complete, working sound in the Toni profile —
nothing is missing there that only exists in default. The only
default-only-vs-Toni-only asymmetry is triggers 24–25 (`Login.mp3`,
`Xtreme.mp3`), and those code paths are commented out in both profiles, so
there's nothing to preserve unless you plan to re-enable that code later —
in which case note it's already sitting in `assi/`, just not in the default
folder.

One real behavior change to be aware of before dropping default: in Toni,
the "random" pick for **Power Infusion (#10)** and **Tank death (#18)**
isn't actually random-sounding — all the candidate files are byte-identical
copies of each other, so those triggers always play the same clip today.
Default has 3 distinct Power Infusion clips and 2 distinct Tank clips. If
you want the randomness to feel meaningful after the switch, you'd want to
either pull default's distinct variants into the new single profile for
just those two triggers, or accept that they're effectively single-clip
triggers with dead code around them.

Notes worth weighing while deciding:
- Triggers 15–19 depend on hardcoded character names from one specific raid
  roster — they do nothing for anyone else running the addon.
- Triggers 20–21 have no on/off toggle at all; cutting or gating them is a
  behavior decision, not just asset cleanup.
- Triggers 23–26 are already inert in the shipped code; the only "cost" of
  removing them is the dead code/constants and (for 24–25) the orphaned
  Toni-only sound files.

## Sounds

"Used by" references the trigger numbers above. Files that were
byte-identical to another file already in the catalog have since been
deleted — `CritLog.lua`'s `ResolveSound()` transparently redirects to the
one physical copy that's left, so playback is unaffected. "`→ file`" marks
where that redirect points (see [SOUNDS.md](SOUNDS.md#deduplication) for the
full mechanism).

### Default profile (`CritLog/sounds/`)

| File | Used by | Decision |
| --- | --- | --- |
| `Angels1.mp3` | 19 | |
| `Angels2.mp3` | 19 | |
| `at_bam_babam.mp3` | 3, 4, 5, 6 | |
| `Bloodlust.mp3` | 8 | |
| `Bubble.mp3` | 11 | |
| `bye.mp3` | 20 | |
| `divineInt.mp3` | 12 | |
| `end.mp3` | 20 | |
| `FFX.mp3` | 17 | |
| `Inervate1.mp3` | 9 | |
| `Inervate2.mp3` | 9 | |
| `Manatide.mp3` | 7 | |
| `MarioDeath.mp3` | 14 | |
| `Ready.mp3` | 2 | |
| `schnutz.mp3` | 15 | |
| `soulstone.mp3` | 13 | |
| `soulstone2.mp3` | 13 | |
| `soulstone3.mp3` | 13 | |
| `Surprise.mp3` | 10 | |
| `Surprise2.mp3` | 10 | |
| `Surprise3.mp3` | 10 | |
| `Tank.mp3` | 18 | |
| `Tank2.mp3` | 18 | |
| `wilhelm.ogg` | 16 | |
| `wipe.mp3` | 21 | |
| `Zelda.mp3` | 17 | |

### Toni / "assi" profile (`CritLog/sounds/assi/`, `/cl toni`)

Rows marked "→ default/…" no longer have a physical file in this folder —
they were removed as duplicates. Everything else is a real file here.

| File on disk here? | Used by | Decision |
| --- | --- | --- |
| `Angels1.mp3` — no, → `default/Angels1.mp3` | 19 | |
| `Angels2.mp3` — no, → `default/Angels2.mp3` | 19 | |
| `at_bam_babam.mp3` — no, → `default/at_bam_babam.mp3` | 3, 4, 5, 6 | |
| `Bloodlust.mp3` — yes | 8 | alternate clip |
| `Bubble.mp3` — yes | 11 | alternate clip |
| `bye.mp3` — yes | 20 | alternate clip |
| `divineInt.mp3` — no, → `default/divineInt.mp3` | 12 | |
| `end.mp3` — yes | 20 | alternate clip |
| `FFX.mp3` — no, → `default/FFX.mp3` | 17 | |
| `Inervate1.mp3` — yes | 9 | alternate clip |
| `Inervate2.mp3` — yes | 9 | alternate clip |
| `Login.mp3` — yes | 24 (inactive) | unreachable — the code path that would play it is commented out |
| `Manatide.mp3` — yes | 7 | alternate clip |
| `MarioDeath.mp3` — yes | 14 | alternate clip |
| `Ready.mp3` — no, → `default/Ready.mp3` | 2 | |
| `schnutz.mp3` — yes | 15 | alternate clip |
| `soulstone.mp3` — no, → `default/soulstone.mp3` | 13 | |
| `soulstone2.mp3` — no, → `default/soulstone2.mp3` | 13 | |
| `soulstone3.mp3` — no, → `default/soulstone3.mp3` | 13 | |
| `Surprise.mp3` — yes | 10 | also stands in for `Surprise2.mp3`/`Surprise3.mp3` via `TONI_ALIASES` |
| `Tank.mp3` — yes | 18 | also stands in for `Tank2.mp3` via `TONI_ALIASES` |
| `wilhelm.ogg` — no, → `default/wilhelm.ogg` | 16 | |
| `Xtreme.mp3` — yes | 25 (inactive) | unreachable — the code path that would play it is commented out |
| `Zelda.mp3` — no, → `default/Zelda.mp3` | 17 | |

### Unused candidates (`CritLog/sounds/more sounds/`)

Not referenced by any trigger today — nothing currently plays these.

| File | Decision |
| --- | --- |
| `Bloodlust2.mp3` | |
| `Bloodlust3.mp3` | |
| `Bloodlust4.mp3` | |
| `jok.mp3` | |
| `knock.mp3` | |
| `Login2.mp3` | |
| `Login3.mp3` | |
| `Login4.mp3` | |
| `Login5.mp3` | |
| `Login6.mp3` | |
| `luffy-senpai.mp3` | |
| `m1.mp3` | |
| `m2.mp3` | |
| `Wololooo.mp3` | |

(`wipe.mp3` was also in this folder, byte-identical to `default/wipe.mp3` —
already deleted, nothing referenced it here.)

If nothing here ends up wired to a trigger, this entire folder is a
straightforward first cut — it adds to package size and review burden for
zero runtime benefit.

## Reminder

None of these files have a resolved rights/license status yet (see
[SOUNDS.md#required-human-review](SOUNDS.md#required-human-review)). A file
being "kept" here still needs that review before public distribution.
