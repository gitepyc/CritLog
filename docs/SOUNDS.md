# Sound Catalog

## Overview

The catalog contains **31 files**, all in active use, totaling approximately
**1.9 MB**. See `CHANGELOG.md` for how it got here (dedup, profile
consolidation, random-pick removal, the `feature/legacy-sound-port` batch of
14 files ported from the original single-file addon, the lottery and
raid-end two-clip-to-one-file consolidations); [ROADMAP.md](ROADMAP.md) for
what's still outstanding — the asset-rights review below is the big one.

Every file has been loudness-, sample-rate-, and bitrate-normalized (see
`feature/sound-normalization` in `CHANGELOG.md` and
`scripts/normalize-sounds.sh`): two-pass EBU R128 loudnorm to -16 LUFS
integrated / -1.5 dBTP true peak, resampled to 44.1kHz, re-encoded at a
consistent bitrate per format (mp3 128k CBR, ogg libvorbis q5, wav PCM).
Filenames/extensions/codec families are unchanged. Duration and bitrate
values below come from `ffprobe` against the normalized files, not Windows
metadata as before - no more `n/a` entries.

## Sounds requested by code

| Logical function | Filename | Trigger |
| --- | --- | --- |
| Crit/highscore | `at_bam_babam.mp3` | Critical hit or new highscore |
| Ready check | `Ready.mp3` | `READY_CHECK` |
| Extreme hit | `Xtreme.mp3` | Damage above 9,000; off by default (`/cl xtreme`) |
| Mana Tide | `Manatide.mp3` | Party/raid member summons Mana Tide Totem |
| Bloodlust | `Bloodlust.mp3` | Player receives Bloodlust/Heroism |
| Innervate | `Innervate.mp3` | Player receives Innervate |
| Power Infusion | `Surprise.mp3` | Player receives Power Infusion |
| Blessing of Protection | `Bubble.mp3` | Player receives Blessing of Protection |
| Divine Intervention | `divineInt.mp3` | Player receives Divine Intervention |
| Soulstone | `soulstone.mp3` | Player receives the Soulstone buff (not the resurrection itself) |
| Player death | `MarioDeath.mp3` | Player dies |
| Damage Dealer death | `wilhelm.ogg` | Live: not currently assigned Tank or Healer (any class); and/or Damage Dealer roster, per detection mode - see `docs/BEHAVIOR.md` |
| Tank death | `Tank.mp3` | Live assigned Tank role and/or tank roster, per detection mode |
| Healer death | `Angels.mp3` | Live assigned Healer role (any class) and/or Healer roster, per detection mode; excludes a Spirit-of-Redemption-delayed death |
| Spirit of Redemption | `Angels2.mp3` (own asset, restored from the legacy addon - see `CHANGELOG.md`) | A Priest's death (class-specific, not role-based) delayed by the talent; independent on/off toggle, not a detection mode |
| Boss death | `FFX.mp3` | Live `worldboss` classification |
| Raid end | `raidend.mp3` | Matching raid-leader message |
| Wipe | `wipe.mp3` | Matching raid-leader message |
| Lottery | `lottery.mp3` | Matching CrossGambling message in raid chat |
| Roll (exact 1) | `roll1.mp3` | `/roll` result is the lowest possible value on a 1-100 roll |
| Roll (low band) | `roll5.mp3` | `/roll` result in the roughly-2-7% band on a 1-100 roll |
| Roll (10 band) | `roll10.mp3` | `/roll` result in the roughly-8-10% band on a 1-100 roll |
| Roll (69) | `roll69.mp3` | `/roll` result is exactly 69 |
| Roll (95 band) | `roll95.mp3` | `/roll` result in the roughly-92-99% band on a 1-100 roll |
| Roll (100) | `roll100.mp3` | `/roll` result is the maximum on a 1-100 roll |
| Drums of Battle | `dkRapL.mp3` | Player receives Drums of Battle |
| Pain Suppression | `Painsup.mp3` | Player receives Pain Suppression (SoD Priest rune) |
| Hymn of Hope | `HymnOfHope.mp3` | Player receives Hymn of Hope |
| Evocation | `evo.mp3` | Player receives Evocation |
| Mage Table | `Table.mp3` | Party/raid member casts Ritual of Refreshment (max once per 100s) |
| Warlock Healthstone ritual | `healthstone.mp3` | Party/raid member casts Ritual of Souls (max once per 60s) |

Every entry above is a single fixed file — no more random multi-clip
selection anywhere in the addon. See [BEHAVIOR.md](BEHAVIOR.md) for the
complete trigger conditions.

## Catalog (`sounds/`)

| File | Duration | Bitrate | Size | Used by |
| --- | ---: | ---: | ---: | --- |
| `Angels.mp3` | 5 s | 129 kbps | 86,995 B | healer death |
| `Angels2.mp3` | 7 s | 129 kbps | 108,712 B | Spirit of Redemption |
| `at_bam_babam.mp3` | 1 s | 134 kbps | 17,597 B | crit/highscore |
| `Bloodlust.mp3` | 3 s | 130 kbps | 56,133 B | Bloodlust/Heroism |
| `Bubble.mp3` | 2 s | 134 kbps | 26,467 B | Blessing of Protection |
| `divineInt.mp3` | 4 s | 129 kbps | 67,357 B | Divine Intervention |
| `dkRapL.mp3` | 3 s | 131 kbps | 55,828 B | Drums of Battle |
| `evo.mp3` | 4 s | 129 kbps | 67,334 B | Evocation |
| `FFX.mp3` | 4 s | 130 kbps | 67,922 B | boss death |
| `healthstone.mp3` | 2 s | 131 kbps | 35,151 B | Warlock Healthstone ritual |
| `HymnOfHope.mp3` | 2 s | 132 kbps | 25,120 B | Hymn of Hope |
| `Innervate.mp3` | 3 s | 131 kbps | 47,783 B | Innervate |
| `lottery.mp3` | 4 s | 130 kbps | 62,781 B | lottery (consolidated, see `CHANGELOG.md`) |
| `Manatide.mp3` | 2 s | 132 kbps | 33,154 B | Mana Tide Totem |
| `MarioDeath.mp3` | 2 s | 131 kbps | 37,334 B | player death |
| `Painsup.mp3` | 3 s | 131 kbps | 50,709 B | Pain Suppression |
| `Ready.mp3` | 2 s | 132 kbps | 29,718 B | ready check |
| `raidend.mp3` | 9 s | 129 kbps | 146,746 B | raid end (overlap variant for comparison, see `CHANGELOG.md`) |
| `roll1.mp3` | 3 s | 131 kbps | 43,185 B | roll result 1 |
| `roll10.mp3` | 10 s | 129 kbps | 155,523 B | roll result 8-10% band |
| `roll100.mp3` | 5 s | 129 kbps | 86,657 B | roll result 100 |
| `roll5.mp3` | 2 s | 132 kbps | 31,503 B | roll result 2-7% band |
| `roll69.mp3` | 3 s | 131 kbps | 53,634 B | roll result 69 |
| `roll95.mp3` | 4 s | 130 kbps | 62,840 B | roll result 92-99% band |
| `soulstone.mp3` | 2 s | 132 kbps | 26,885 B | Soulstone |
| `Surprise.mp3` | 5 s | 129 kbps | 83,309 B | Power Infusion |
| `Table.mp3` | 4 s | 130 kbps | 59,904 B | Mage Table |
| `Tank.mp3` | 2 s | 131 kbps | 31,807 B | tank death |
| `wilhelm.ogg` | 1 s | 72 kbps | 10,861 B | Damage Dealer death |
| `wipe.mp3` | 10 s | 128 kbps | 163,883 B | wipe chat phrase |
| `Xtreme.mp3` | 3 s | 130 kbps | 43,092 B | extreme hit (off by default) |

## Required human review

The technical and code-usage inventory is complete. Before cleanup or public
distribution, every clip still needs a listening and rights review:

- clear content description instead of only a historical filename
- acceptable loudness and duration in game - the normalization pass above
  gives every file the same *technical* loudness target, but that's not a
  substitute for actually listening to each one in game
- language and potentially offensive or unwanted content
- source, author, license, and redistribution permission
- decision to keep, replace, retain for private use only, or remove

Until this review is complete, filenames must not be treated as reliable content
descriptions and existing files must not be treated as approved assets.
