# Cleanup Review Checklist

A condensed, decision-oriented view for deciding what to keep, replace, or
cut. Full technical detail (conditions, payload fields, exact matching
rules) lives in [BEHAVIOR.md](BEHAVIOR.md) and [SOUNDS.md](SOUNDS.md) — this
page exists so you don't have to cross-reference two tables while deciding.

Each trigger below has a number; the sound list references it under "Used
by" so you can see at a glance which sound files become orphaned if you cut
a trigger.

## Triggers

| # | Trigger | Toggle | Sound(s) |
| ---: | --- | --- | --- |
| 1 | `PLAYER_LOGIN` — always fires, inits/migrates `CritLogDB`, prints stored highscores | none | — (Login sound wired but disabled, see #24) |
| 2 | Ready check | `/cl ready` | `Ready.mp3` |
| 3 | Player's `SPELL_DAMAGE` crit | `/cl allcrits`, `/cl sound` | `at_bam_babam.mp3` |
| 4 | Player's `SWING_DAMAGE` crit (white hit) | `/cl whitehit` | `at_bam_babam.mp3` |
| 5 | Player's `RANGE_DAMAGE` crit (counted as white hit) | `/cl whitehit` | `at_bam_babam.mp3` |
| 6 | Player's `SPELL_HEAL` crit | `/cl allcrits` | `at_bam_babam.mp3` |
| 7 | Party/raid member summons Mana Tide Totem | `/cl aura` | `Manatide.mp3` |
| 8 | Player receives Bloodlust/Heroism | `/cl aura` | `Bloodlust.mp3` |
| 9 | Player receives Innervate | `/cl aura` | `Inervate1.mp3` / `Inervate2.mp3` (random) |
| 10 | Player receives Power Infusion | `/cl aura` | `Surprise.mp3` / `Surprise2.mp3` / `Surprise3.mp3` (random) |
| 11 | Player receives Blessing of Protection | `/cl aura` | `Bubble.mp3` |
| 12 | Player receives Divine Intervention | `/cl aura` | `divineInt.mp3` |
| 13 | Player receives Soulstone Resurrection | `/cl aura` | `soulstone.mp3` / `soulstone2.mp3` / `soulstone3.mp3` (random) |
| 14 | Player dies | `/cl player` + `/cl dead` | `MarioDeath.mp3` |
| 15 | Hardcoded roster member "Schnutz" dies (special case) | `/cl melee` + `/cl dead` | `schnutz.mp3` |
| 16 | Any other hardcoded `MELEE_NAMES` roster member dies | `/cl melee` + `/cl dead` | `wilhelm.ogg` |
| 17 | Hardcoded EN/DE TBC boss list — boss dies | `/cl boss` + `/cl dead` | `FFX.mp3` / `Zelda.mp3` (random) |
| 18 | Hardcoded `TANK_NAMES` roster member dies | `/cl tank` + `/cl dead` | `Tank.mp3` / `Tank2.mp3` (random) |
| 19 | Hardcoded `HEALPRIEST_NAMES` roster member dies | `/cl priest` + `/cl dead` | `Angels1.mp3` / `Angels2.mp3` (random) |
| 20 | Raid leader says "raid end" / "raid ende" in chat | none — always active | `bye.mp3` then `end.mp3` (may overlap) |
| 21 | Raid leader says "wipe" / "shit show" in chat | none — always active | `wipe.mp3` |
| 22 | Hardcoded boss list — killing blow chat print | none | text only, no sound |
| 23 | Zone change | inactive — event not registered | — |
| 24 | Login sound | inactive — commented out | `Login.mp3` (Toni profile only; absent from default) |
| 25 | "Over 9k" damage hit | inactive — commented out | `Xtreme.mp3` (Toni profile only; absent from default) |
| 26 | Spirit of Redemption | inactive — commented out, marked "not working" | — |

Notes worth weighing while deciding:
- Triggers 15–19 depend on hardcoded character names from one specific raid
  roster — they do nothing for anyone else running the addon.
- Triggers 20–21 have no on/off toggle at all; cutting or gating them is a
  behavior decision, not just asset cleanup.
- Triggers 23–26 are already inert in the shipped code; the only "cost" of
  removing them is the dead code/constants and (for 24–25) the orphaned
  Toni-only sound files.

## Sounds

"Used by" references the trigger numbers above. "`= file`" means
byte-identical to a file already listed — you only need to listen to one of
each identical group (see [SOUNDS.md](SOUNDS.md#byte-identical-files) for
the full duplicate list).

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

| File | Used by | Decision |
| --- | --- | --- |
| `Angels1.mp3` | 19 | `= default/Angels1.mp3` |
| `Angels2.mp3` | 19 | `= default/Angels2.mp3` |
| `at_bam_babam.mp3` | 3, 4, 5, 6 | `= default/at_bam_babam.mp3` |
| `Bloodlust.mp3` | 8 | alternate clip |
| `Bubble.mp3` | 11 | alternate clip |
| `bye.mp3` | 20 | alternate clip |
| `divineInt.mp3` | 12 | `= default/divineInt.mp3` |
| `end.mp3` | 20 | alternate clip |
| `FFX.mp3` | 17 | `= default/FFX.mp3` |
| `Inervate1.mp3` | 9 | alternate clip |
| `Inervate2.mp3` | 9 | alternate clip |
| `Login.mp3` | 24 (inactive) | unreachable — the code path that would play it is commented out |
| `Manatide.mp3` | 7 | alternate clip |
| `MarioDeath.mp3` | 14 | alternate clip |
| `Ready.mp3` | 2 | `= default/Ready.mp3` |
| `schnutz.mp3` | 15 | alternate clip |
| `soulstone.mp3` | 13 | `= default/soulstone.mp3` |
| `soulstone2.mp3` | 13 | `= default/soulstone2.mp3` (we copied this file in to close a gap — see CHANGELOG) |
| `soulstone3.mp3` | 13 | `= default/soulstone3.mp3` |
| `Surprise.mp3` | 10 | `= Surprise2.mp3` / `Surprise3.mp3` (all three identical within this profile) |
| `Surprise2.mp3` | 10 | `= Surprise.mp3` |
| `Surprise3.mp3` | 10 | `= Surprise.mp3` |
| `Tank.mp3` | 18 | `= Tank2.mp3` (identical within this profile) |
| `Tank2.mp3` | 18 | `= Tank.mp3` |
| `wilhelm.ogg` | 16 | `= default/wilhelm.ogg` |
| `wipe.mp3` | 21 | `= default/wipe.mp3` |
| `Xtreme.mp3` | 25 (inactive) | unreachable — the code path that would play it is commented out |
| `Zelda.mp3` | 17 | `= default/Zelda.mp3` |

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
| `wipe.mp3` | `= default/wipe.mp3` |
| `Wololooo.mp3` | |

If nothing here ends up wired to a trigger, this entire folder is a
straightforward first cut — it adds to package size and review burden for
zero runtime benefit.

## Reminder

None of these files have a resolved rights/license status yet (see
[SOUNDS.md#required-human-review](SOUNDS.md#required-human-review)). A file
being "kept" here still needs that review before public distribution.
