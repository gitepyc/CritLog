# Sound Catalog

## Overview

The catalog contains **33 files**, all in active use, totaling approximately
**2.9 MB**. See `CHANGELOG.md` for how it got here (dedup, profile
consolidation, random-pick removal, the `feature/legacy-sound-port` batch of
15 files ported from the original single-file addon); [ROADMAP.md](ROADMAP.md)
for what's still outstanding — the asset-rights review below is the big one.

Duration and bitrate values come from Windows audio metadata; `n/a` means
Windows did not expose the value.

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
| Damage Dealer death | `wilhelm.ogg` | Hard-coded Damage Dealer-roster member dies |
| Tank death | `Tank.mp3` | Hard-coded tank-roster member dies |
| Healer-priest death | `Angels.mp3` | Hard-coded healer-priest member dies |
| Boss death | `FFX.mp3` | Hard-coded boss dies |
| Raid end | `bye.mp3`, then `end.mp3` | Matching raid-leader message, both immediately |
| Wipe | `wipe.mp3` | Matching raid-leader message |
| Login | `Login.mp3` | `PLAYER_LOGIN`; off by default (`/cl login`) |
| Lottery | `lottery2.wav`, then `lottery3.mp3` | Matching CrossGambling message in raid chat, both immediately |
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
| `Angels.mp3` | 5 s | 178 kbps | 121,680 B | healer-priest death |
| `at_bam_babam.mp3` | 1 s | 128 kbps | 17,553 B | crit/highscore |
| `Bloodlust.mp3` | 3 s | 128 kbps | 56,134 B | Bloodlust/Heroism |
| `Bubble.mp3` | 1 s | 128 kbps | 27,305 B | Blessing of Protection |
| `bye.mp3` | 4 s | 128 kbps | 66,980 B | raid end, first clip |
| `divineInt.mp3` | 4 s | 128 kbps | 66,486 B | Divine Intervention |
| `dkRapL.mp3` | n/a | n/a | 41,933 B | Drums of Battle |
| `end.mp3` | 9 s | 160 kbps | 183,508 B | raid end, second clip |
| `evo.mp3` | n/a | n/a | 84,018 B | Evocation |
| `FFX.mp3` | 4 s | 128 kbps | 67,495 B | boss death |
| `healthstone.mp3` | n/a | n/a | 85,855 B | Warlock Healthstone ritual |
| `HymnOfHope.mp3` | n/a | n/a | 26,330 B | Hymn of Hope |
| `Innervate.mp3` | 2 s | 128 kbps | 47,754 B | Innervate |
| `Login.mp3` | n/a | n/a | 77,574 B | login (off by default) |
| `lottery2.wav` | n/a | n/a | 706,330 B | lottery, first clip |
| `lottery3.mp3` | n/a | n/a | 29,603 B | lottery, second clip |
| `Manatide.mp3` | 2 s | 320 kbps | 82,684 B | Mana Tide Totem |
| `MarioDeath.mp3` | 2 s | 128 kbps | 37,305 B | player death |
| `Painsup.mp3` | n/a | n/a | 75,996 B | Pain Suppression |
| `Ready.mp3` | 1 s | 128 kbps | 30,336 B | ready check |
| `roll1.mp3` | n/a | n/a | 64,711 B | roll result 1 |
| `roll10.mp3` | n/a | n/a | 116,491 B | roll result 8-10% band |
| `roll100.mp3` | n/a | n/a | 86,241 B | roll result 100 |
| `roll5.mp3` | n/a | n/a | 81,633 B | roll result 2-7% band |
| `roll69.mp3` | n/a | n/a | 81,639 B | roll result 69 |
| `roll95.mp3` | n/a | n/a | 116,466 B | roll result 92-99% band |
| `soulstone.mp3` | 1 s | 128 kbps | 26,487 B | Soulstone |
| `Surprise.mp3` | 5 s | 128 kbps | 83,280 B | Power Infusion |
| `Table.mp3` | n/a | n/a | 59,488 B | Mage Table |
| `Tank.mp3` | 1 s | 128 kbps | 31,763 B | tank death |
| `wilhelm.ogg` | n/a | n/a | 12,524 B | Damage Dealer death |
| `wipe.mp3` | 10 s | 234 kbps | 298,605 B | wipe chat phrase |
| `Xtreme.mp3` | 2 s | 128 kbps | 42,214 B | extreme hit (off by default) |

## Required human review

The technical and code-usage inventory is complete. Before cleanup or public
distribution, every clip still needs a listening and rights review:

- clear content description instead of only a historical filename
- acceptable loudness and duration in game
- language and potentially offensive or unwanted content
- source, author, license, and redistribution permission
- decision to keep, replace, retain for private use only, or remove

Until this review is complete, filenames must not be treated as reliable content
descriptions and existing files must not be treated as approved assets.
