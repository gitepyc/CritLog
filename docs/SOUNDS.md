# Sound Catalog

## Overview

The catalog contains **30 files**, all in active use, totaling approximately
**1.6 MB**. See [ROADMAP.md](ROADMAP.md) for what's still outstanding.

Sounds are normalized with `scripts/normalize-sounds.sh`: two-pass EBU R128
loudnorm to -16 LUFS integrated / -1.5 dBTP true peak, resampled to 44.1kHz,
re-encoded per format (mp3 128k CBR, ogg libvorbis q5, wav PCM). The ogg
setting is quality-based (VBR), so a short file can land well below the
nominal ~160 kbps. Duration and bitrate values below come from `ffprobe`.

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
| Player death | `Toni.mp3` | Player dies |
| Damage Dealer death | `wilhelm.ogg` | Live: not currently assigned Tank or Healer (any class); and/or Damage Dealer roster, per detection mode - see `docs/BEHAVIOR.md` |
| Tank death | `Tank.mp3` | Live assigned Tank role and/or tank roster, per detection mode |
| Healer death | `Angels.mp3` | Live assigned Healer role (any class) and/or Healer roster, per detection mode |
| Boss death | `FFX.mp3` | Live boss-level-mob classification (`worldboss`) |
| Raid end | `raidend.mp3` | Matching raid-leader message |
| Wipe | `wipe.mp3` | Matching raid-leader message |
| Lottery | `lottery.mp3` | Matching CrossGambling message in raid/party/guild chat |
| Roll (exact 1) | `roll1.mp3` | `/roll` result is 1 (the roll's minimum must be 1) |
| Roll (low band) | `roll5.mp3` | `/roll` result below 8% of the max (on 1-100: 2-7) |
| Roll (10 band) | `roll10.mp3` | `/roll` result from 8% to 12% of the max (on 1-100: 8-12) |
| Roll (69) | `roll69.mp3` | `/roll` result is exactly 69 |
| Roll (95 band) | `roll95.mp3` | `/roll` result at or above 92% of the max, below the max (on 1-100: 92-99) |
| Roll (100) | `roll100.mp3` | `/roll` result equals the max (any roll starting at 1) |
| Drums of Battle | `dkRapL.mp3` | Player receives Drums of Battle |
| Pain Suppression | `Painsup.mp3` | Player receives Pain Suppression (SoD Priest rune) |
| Hymn of Hope | `HymnOfHope.mp3` | Player receives Hymn of Hope |
| Evocation | `evo.mp3` | Player receives Evocation |
| Mage Table | `Table.mp3` | Party/raid member casts Ritual of Refreshment (max once per 100s) |
| Warlock Healthstone ritual | `healthstone.mp3` | Party/raid member casts Ritual of Souls (max once per 60s) |

Each trigger plays one fixed file. See [BEHAVIOR.md](BEHAVIOR.md) for the
complete trigger conditions.

## Catalog (`sounds/`)

| File | Duration | Bitrate | Size | Used by |
| --- | ---: | ---: | ---: | --- |
| `Angels.mp3` | 5 s | 129 kbps | 86,995 B | healer death |
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
| `lottery.mp3` | 4 s | 130 kbps | 62,736 B | lottery |
| `Manatide.mp3` | 2 s | 132 kbps | 33,154 B | Mana Tide Totem |
| `Painsup.mp3` | 3 s | 131 kbps | 50,709 B | Pain Suppression |
| `Ready.mp3` | 2 s | 132 kbps | 29,718 B | ready check |
| `raidend.mp3` | 9 s | 129 kbps | 146,746 B | raid end |
| `roll1.mp3` | 3 s | 131 kbps | 43,185 B | roll result 1 |
| `roll10.mp3` | 3 s | 100 kbps | 31,344 B | roll result 8-12% of max |
| `roll100.mp3` | 5 s | 129 kbps | 86,657 B | roll result 100 |
| `roll5.mp3` | 2 s | 132 kbps | 31,503 B | roll result below 8% of max |
| `roll69.mp3` | 3 s | 131 kbps | 53,634 B | roll result 69 |
| `roll95.mp3` | 4 s | 130 kbps | 62,840 B | roll result at or above 92% of max |
| `soulstone.mp3` | 2 s | 132 kbps | 26,885 B | Soulstone |
| `Surprise.mp3` | 5 s | 129 kbps | 83,309 B | Power Infusion |
| `Table.mp3` | 4 s | 130 kbps | 59,904 B | Mage Table |
| `Tank.mp3` | 2 s | 131 kbps | 31,807 B | tank death |
| `Toni.mp3` | 2 s | 131 kbps | 37,334 B | player death |
| `wilhelm.ogg` | 1 s | 72 kbps | 10,861 B | Damage Dealer death |
| `wipe.mp3` | 10 s | 128 kbps | 163,883 B | wipe chat phrase |
| `Xtreme.mp3` | 3 s | 130 kbps | 43,092 B | extreme hit (off by default) |
