# Sound Catalog

## Overview

The catalog contains **18 files**, all in active use, totaling approximately
**1.24 MB**. The 6 former multi-variant/special-case alternates
(`Inervate1.mp3`, `Angels2.mp3`, `Zelda.mp3`, `soulstone2.mp3`,
`soulstone3.mp3`, `schnutz.mp3`) were deleted once random selection and the
`Schnutz` special case were removed (see `CHANGELOG.md`); the two survivors
that used to carry a `1`/`2` variant suffix were renamed to drop it
(`Angels1.mp3` → `Angels.mp3`, `Inervate2.mp3` → `Innervate.mp3`, also fixing
the "Inervate" typo along the way).

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
| Soulstone | `soulstone.mp3` | Player receives Soulstone Resurrection |
| Player death | `MarioDeath.mp3` | Player dies |
| Melee death | `wilhelm.ogg` | Hard-coded melee-roster member dies |
| Tank death | `Tank.mp3` | Hard-coded tank-roster member dies |
| Healer-priest death | `Angels.mp3` | Hard-coded healer-priest member dies |
| Boss death | `FFX.mp3` | Hard-coded boss dies |
| Raid end | `bye.mp3`, then `end.mp3` | Matching raid-leader message, both immediately |
| Wipe | `wipe.mp3` | Matching raid-leader message |

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
| `end.mp3` | 9 s | 160 kbps | 183,508 B | raid end, second clip |
| `FFX.mp3` | 4 s | 128 kbps | 67,495 B | boss death |
| `Innervate.mp3` | 2 s | 128 kbps | 47,754 B | Innervate |
| `Manatide.mp3` | 2 s | 320 kbps | 82,684 B | Mana Tide Totem |
| `MarioDeath.mp3` | 2 s | 128 kbps | 37,305 B | player death |
| `Ready.mp3` | 1 s | 128 kbps | 30,336 B | ready check |
| `soulstone.mp3` | 1 s | 128 kbps | 26,487 B | Soulstone |
| `Surprise.mp3` | 5 s | 128 kbps | 83,280 B | Power Infusion |
| `Tank.mp3` | 1 s | 128 kbps | 31,763 B | tank death |
| `wilhelm.ogg` | n/a | n/a | 12,524 B | melee death |
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
