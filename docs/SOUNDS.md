# Sound Catalog

## Overview

The catalog contains **25 files in active use** plus a **14-file unused
candidates folder**, totaling approximately **3.13 MB**.

> **History:** CritLog used to ship two profiles (default and an alternate
> "Toni" set). Byte-identical files were deduplicated first, then the Toni
> set was promoted to be the only profile — the old default-only clips were
> dropped. See `CHANGELOG.md` for the exact steps and
> [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md) for what's still worth stripping.

| Directory | Purpose in the current code |
| --- | --- |
| `CritLog/sounds/` | The (only) sound profile. |
| `CritLog/sounds/more sounds/` | Candidate files; not referenced by any code path — see [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md). |

Duration and bitrate values come from Windows audio metadata; `n/a` means
Windows did not expose the value. "Used" only describes reachability from
the current source code, not a completed listening test.

## Sounds requested by code

| Logical function | Filename | Trigger | Selection |
| --- | --- | --- | --- |
| Crit/highscore | `at_bam_babam.mp3` | Critical hit or new highscore | Fixed |
| Ready check | `Ready.mp3` | `READY_CHECK` | Fixed |
| Mana Tide | `Manatide.mp3` | Party/raid member summons Mana Tide Totem | Fixed |
| Bloodlust | `Bloodlust.mp3` | Player receives Bloodlust/Heroism | Fixed |
| Innervate | `Inervate1.mp3`, `Inervate2.mp3` | Player receives Innervate | Random 1/2 |
| Power Infusion | `Surprise.mp3` | Player receives Power Infusion | Fixed |
| Blessing of Protection | `Bubble.mp3` | Player receives Blessing of Protection | Fixed |
| Divine Intervention | `divineInt.mp3` | Player receives Divine Intervention | Fixed |
| Soulstone | `soulstone.mp3`, `soulstone2.mp3`, `soulstone3.mp3` | Player receives Soulstone Resurrection | Random 1/3 |
| Player death | `MarioDeath.mp3` | Player dies | Fixed |
| Special melee death | `schnutz.mp3` | `Schnutz` dies | Fixed |
| Other melee death | `wilhelm.ogg` | Hard-coded melee-roster member dies | Fixed |
| Tank death | `Tank.mp3` | Hard-coded tank-roster member dies | Fixed |
| Healer-priest death | `Angels1.mp3`, `Angels2.mp3` | Hard-coded healer-priest member dies | Random 1/2 |
| Boss death | `FFX.mp3`, `Zelda.mp3` | Hard-coded boss dies | Random 1/2 |
| Raid end | `bye.mp3`, then `end.mp3` | Matching raid-leader message | Both immediately |
| Wipe | `wipe.mp3` | Matching raid-leader message | Fixed |
| Login | `Login.mp3` | Login | Disabled code — file is dead weight, see [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md) |
| Extreme hit | `Xtreme.mp3` | Damage above 9,000 | Disabled code — file is dead weight, see [CLEANUP-REVIEW.md](CLEANUP-REVIEW.md) |

See [BEHAVIOR.md](BEHAVIOR.md) for the complete conditions.

## Active profile (`CritLog/sounds/`)

| File | Duration | Bitrate | Size | Status |
| --- | ---: | ---: | ---: | --- |
| `Angels1.mp3` | 5 s | 178 kbps | 121,680 B | Used: healer-priest death |
| `Angels2.mp3` | 6 s | 192 kbps | 161,568 B | Used: healer-priest death |
| `at_bam_babam.mp3` | 1 s | 128 kbps | 17,553 B | Used: crit/highscore |
| `Bloodlust.mp3` | 3 s | 128 kbps | 56,134 B | Used: Bloodlust/Heroism |
| `Bubble.mp3` | 1 s | 128 kbps | 27,305 B | Used: Blessing of Protection |
| `bye.mp3` | 4 s | 128 kbps | 66,980 B | Used: raid end, first clip |
| `divineInt.mp3` | 4 s | 128 kbps | 66,486 B | Used: Divine Intervention |
| `end.mp3` | 9 s | 160 kbps | 183,508 B | Used: raid end, second clip |
| `FFX.mp3` | 4 s | 128 kbps | 67,495 B | Used: boss death |
| `Inervate1.mp3` | 2 s | 128 kbps | 37,305 B | Used: Innervate |
| `Inervate2.mp3` | 2 s | 128 kbps | 47,754 B | Used: Innervate |
| `Login.mp3` | 3 s | 192 kbps | 77,574 B | **Dead weight** — playback commented out |
| `Manatide.mp3` | 2 s | 320 kbps | 82,684 B | Used: Mana Tide Totem |
| `MarioDeath.mp3` | 2 s | 128 kbps | 37,305 B | Used: player death |
| `Ready.mp3` | 1 s | 128 kbps | 30,336 B | Used: ready check |
| `schnutz.mp3` | 1 s | 128 kbps | 22,676 B | Used: special-case death |
| `soulstone.mp3` | 1 s | 128 kbps | 26,487 B | Used: Soulstone |
| `soulstone2.mp3` | 6 s | 128 kbps | 97,939 B | Used: Soulstone |
| `soulstone3.mp3` | 2 s | 192 kbps | 52,402 B | Used: Soulstone |
| `Surprise.mp3` | 5 s | 128 kbps | 83,280 B | Used: Power Infusion |
| `Tank.mp3` | 1 s | 128 kbps | 31,763 B | Used: tank death |
| `wilhelm.ogg` | n/a | n/a | 12,524 B | Used: melee death |
| `wipe.mp3` | 10 s | 234 kbps | 298,605 B | Used: wipe chat phrase |
| `Xtreme.mp3` | 2 s | 128 kbps | 42,214 B | **Dead weight** — code path commented out |
| `Zelda.mp3` | 2 s | 128 kbps | 42,630 B | Used: boss death |

## Candidate files (`more sounds/`)

None of these files is referenced by the current Lua code.

| File | Duration | Bitrate | Size |
| --- | ---: | ---: | ---: |
| `Bloodlust2.mp3` | 2 s | 102 kbps | 35,564 B |
| `Bloodlust3.mp3` | 3 s | 192 kbps | 84,774 B |
| `Bloodlust4.mp3` | 14 s | 128 kbps | 233,358 B |
| `jok.mp3` | n/a | n/a | 88,770 B |
| `knock.mp3` | 5 s | 128 kbps | 92,984 B |
| `Login2.mp3` | 9 s | 192 kbps | 237,653 B |
| `Login3.mp3` | 1 s | 128 kbps | 19,296 B |
| `Login4.mp3` | 8 s | 163 kbps | 164,928 B |
| `Login5.mp3` | 7 s | 128 kbps | 115,806 B |
| `Login6.mp3` | 3 s | 192 kbps | 75,996 B |
| `luffy-senpai.mp3` | 3 s | 320 kbps | 129,611 B |
| `m1.mp3` | <1 s | 128 kbps | 9,957 B |
| `m2.mp3` | 1 s | 132 kbps | 20,863 B |
| `Wololooo.mp3` | 1 s | 128 kbps | 26,330 B |

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
