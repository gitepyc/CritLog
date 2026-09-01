# Sound Catalog

## Overview

The catalog contains **24 files** totaling approximately **1.71 MB**. As of
the random-pick removal below, **19 are in active use**; the other 5
(`Inervate1.mp3`, `Angels2.mp3`, `Zelda.mp3`, `soulstone2.mp3`,
`soulstone3.mp3`) are the alternates that were dropped and are now unused —
kept on disk, not wired into any code path.

> **History:** CritLog used to ship two profiles (default and an alternate
> "Toni" set), plus a `more sounds/` folder of never-wired-up candidates and
> a couple of sounds tied to disabled features. Byte-identical files were
> deduplicated, the Toni set was promoted to be the only profile, and the
> unused/orphaned material was removed in a follow-up pass. See
> `CHANGELOG.md` for the exact steps and [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md)
> for what (if anything) is still left to review.

Duration and bitrate values come from Windows audio metadata; `n/a` means
Windows did not expose the value.

## Sounds requested by code

| Logical function | Filename | Trigger | Selection |
| --- | --- | --- | --- |
| Crit/highscore | `at_bam_babam.mp3` | Critical hit or new highscore | Fixed |
| Ready check | `Ready.mp3` | `READY_CHECK` | Fixed |
| Extreme hit | `Xtreme.mp3` | Damage above 9,000 | Fixed; off by default (`/cl xtreme`) |
| Mana Tide | `Manatide.mp3` | Party/raid member summons Mana Tide Totem | Fixed |
| Bloodlust | `Bloodlust.mp3` | Player receives Bloodlust/Heroism | Fixed |
| Innervate | `Inervate2.mp3` | Player receives Innervate | Fixed (was random 1/2 with `Inervate1.mp3`, see CHANGELOG.md) |
| Power Infusion | `Surprise.mp3` | Player receives Power Infusion | Fixed |
| Blessing of Protection | `Bubble.mp3` | Player receives Blessing of Protection | Fixed |
| Divine Intervention | `divineInt.mp3` | Player receives Divine Intervention | Fixed |
| Soulstone | `soulstone.mp3` | Player receives Soulstone Resurrection | Fixed (was random 1/3 with `soulstone2.mp3`/`soulstone3.mp3`, see CHANGELOG.md) |
| Player death | `MarioDeath.mp3` | Player dies | Fixed |
| Special melee death | `schnutz.mp3` | `Schnutz` dies | Fixed |
| Other melee death | `wilhelm.ogg` | Hard-coded melee-roster member dies | Fixed |
| Tank death | `Tank.mp3` | Hard-coded tank-roster member dies | Fixed |
| Healer-priest death | `Angels1.mp3` | Hard-coded healer-priest member dies | Fixed (was random 1/2 with `Angels2.mp3`, see CHANGELOG.md) |
| Boss death | `FFX.mp3` | Hard-coded boss dies | Fixed (was random 1/2 with `Zelda.mp3`, see CHANGELOG.md) |
| Raid end | `bye.mp3`, then `end.mp3` | Matching raid-leader message | Both immediately |
| Wipe | `wipe.mp3` | Matching raid-leader message | Fixed |

See [BEHAVIOR.md](BEHAVIOR.md) for the complete conditions.

## Catalog (`sounds/`)

| File | Duration | Bitrate | Size | Used by |
| --- | ---: | ---: | ---: | --- |
| `Angels1.mp3` | 5 s | 178 kbps | 121,680 B | healer-priest death |
| `Angels2.mp3` | 6 s | 192 kbps | 161,568 B | *unused* (former healer-priest death alternate) |
| `at_bam_babam.mp3` | 1 s | 128 kbps | 17,553 B | crit/highscore |
| `Bloodlust.mp3` | 3 s | 128 kbps | 56,134 B | Bloodlust/Heroism |
| `Bubble.mp3` | 1 s | 128 kbps | 27,305 B | Blessing of Protection |
| `bye.mp3` | 4 s | 128 kbps | 66,980 B | raid end, first clip |
| `divineInt.mp3` | 4 s | 128 kbps | 66,486 B | Divine Intervention |
| `end.mp3` | 9 s | 160 kbps | 183,508 B | raid end, second clip |
| `FFX.mp3` | 4 s | 128 kbps | 67,495 B | boss death |
| `Inervate1.mp3` | 2 s | 128 kbps | 37,305 B | *unused* (former Innervate alternate) |
| `Inervate2.mp3` | 2 s | 128 kbps | 47,754 B | Innervate |
| `Manatide.mp3` | 2 s | 320 kbps | 82,684 B | Mana Tide Totem |
| `MarioDeath.mp3` | 2 s | 128 kbps | 37,305 B | player death |
| `Ready.mp3` | 1 s | 128 kbps | 30,336 B | ready check |
| `schnutz.mp3` | 1 s | 128 kbps | 22,676 B | special-case death |
| `soulstone.mp3` | 1 s | 128 kbps | 26,487 B | Soulstone |
| `soulstone2.mp3` | 6 s | 128 kbps | 97,939 B | *unused* (former Soulstone alternate) |
| `soulstone3.mp3` | 2 s | 192 kbps | 52,402 B | *unused* (former Soulstone alternate) |
| `Surprise.mp3` | 5 s | 128 kbps | 83,280 B | Power Infusion |
| `Tank.mp3` | 1 s | 128 kbps | 31,763 B | tank death |
| `wilhelm.ogg` | n/a | n/a | 12,524 B | melee death |
| `wipe.mp3` | 10 s | 234 kbps | 298,605 B | wipe chat phrase |
| `Xtreme.mp3` | 2 s | 128 kbps | 42,214 B | extreme hit (off by default) |
| `Zelda.mp3` | 2 s | 128 kbps | 42,630 B | *unused* (former boss death alternate) |

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
