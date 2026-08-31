# Sound Catalog

## Overview

The catalog contains **68 files** totaling approximately **5.58 MB**:

| Directory | Purpose in the current code |
| --- | --- |
| `CritLog/sounds/` | Default sound profile |
| `CritLog/sounds/assi/` | Alternate “Toni” profile selected with `/cl toni` |
| `CritLog/sounds/more sounds/` | Candidate files; currently not referenced |

There are 66 MP3 and 2 OGG files. Duration and bitrate values come from Windows
audio metadata; `n/a` means Windows did not expose the value. “Used” only
describes reachability from the current source code, not a completed listening
test.

## Sounds requested by code

| Logical function | Filename | Trigger | Selection |
| --- | --- | --- | --- |
| Crit/highscore | `at_bam_babam.mp3` | Critical hit or new highscore | Fixed |
| Ready check | `Ready.mp3` | `READY_CHECK` | Fixed |
| Mana Tide | `Manatide.mp3` | Party/raid member summons Mana Tide Totem | Fixed |
| Bloodlust | `Bloodlust.mp3` | Player receives Bloodlust/Heroism | Fixed |
| Innervate | `Inervate1.mp3`, `Inervate2.mp3` | Player receives Innervate | Random 1/2 |
| Power Infusion | `Surprise.mp3` through `Surprise3.mp3` | Player receives Power Infusion | Random 1/3 |
| Blessing of Protection | `Bubble.mp3` | Player receives Blessing of Protection | Fixed |
| Divine Intervention | `divineInt.mp3`, `divineInt2.mp3` | Player receives Divine Intervention | Random 1/2; second file is missing |
| Soulstone | `soulstone.mp3`, `soulstone2.mp3` | Player receives Soulstone Resurrection | Random 1/2; `soulstone3.mp3` is never selected |
| Player death | `MarioDeath.mp3` | Player dies | Fixed |
| Special melee death | `schnutz.mp3` | `Schnutz` dies | Fixed |
| Other melee death | `wilhelm.ogg` | Hard-coded melee-roster member dies | Fixed |
| Tank death | `Tank.mp3`, `Tank2.mp3` | Hard-coded tank-roster member dies | Random 1/2 |
| Healer-priest death | `Angels1.mp3`, `Angels2.mp3` | Hard-coded healer-priest member dies | Random 1/2 |
| Boss death | `FFX.mp3`, `Zelda.mp3` | Hard-coded boss dies | Random 1/2 |
| Raid end | `bye.mp3`, then `end.mp3` | Matching raid-leader message | Both immediately |
| Wipe | `wipe.mp3` | Matching raid-leader message | Fixed |
| Login | `Login.mp3` | Login | Disabled code |
| Extreme hit | `Xtreme.mp3` | Damage above 9,000 | Disabled code |

See [BEHAVIOR.md](BEHAVIOR.md) for the complete conditions.

## Default profile

| File | Duration | Bitrate | Size | Status |
| --- | ---: | ---: | ---: | --- |
| `Angels1.mp3` | 5 s | 178 kbps | 121,680 B | Used: healer-priest death |
| `Angels2.mp3` | 6 s | 192 kbps | 161,568 B | Used: healer-priest death |
| `at_bam_babam.mp3` | 1 s | 128 kbps | 17,553 B | Used: crit/highscore |
| `Bloodlust.mp3` | 2 s | 128 kbps | 38,496 B | Used: Bloodlust/Heroism |
| `Bubble.mp3` | 3 s | 128 kbps | 60,247 B | Used: Blessing of Protection |
| `bye.mp3` | 1 s | 128 kbps | 20,925 B | Used: raid end, first clip |
| `divineInt.mp3` | 4 s | 128 kbps | 66,486 B | Used: Divine Intervention |
| `end.mp3` | 15 s | 128 kbps | 247,766 B | Used: raid end, second clip |
| `FFX.mp3` | 4 s | 128 kbps | 67,495 B | Used: boss death |
| `Inervate1.mp3` | 1 s | 64 kbps | 17,052 B | Used: Innervate |
| `Inervate2.mp3` | <1 s | 320 kbps | 36,745 B | Used: Innervate |
| `Manatide.mp3` | 4 s | 128 kbps | 77,321 B | Used: Mana Tide Totem |
| `MarioDeath.mp3` | 9 s | 192 kbps | 250,524 B | Used: player death |
| `Ready.mp3` | 1 s | 128 kbps | 30,336 B | Used: ready check |
| `schnutz.mp3` | 1 s | 128 kbps | 120,496 B | Used: special-case death |
| `soulstone.mp3` | 1 s | 128 kbps | 26,487 B | Used: Soulstone |
| `soulstone2.mp3` | 6 s | 128 kbps | 97,939 B | Used: Soulstone |
| `soulstone3.mp3` | 2 s | 192 kbps | 52,402 B | Listed but unreachable due to random range |
| `Surprise.mp3` | 3 s | 128 kbps | 58,180 B | Used: Power Infusion |
| `Surprise2.mp3` | 2 s | 128 kbps | 32,181 B | Used: Power Infusion |
| `Surprise3.mp3` | 2 s | 128 kbps | 37,632 B | Used: Power Infusion |
| `Tank.mp3` | 1 s | 184 kbps | 28,267 B | Used: tank death |
| `Tank2.mp3` | 3 s | 74 kbps | 29,950 B | Used: tank death |
| `wilhelm.ogg` | n/a | n/a | 12,524 B | Used: melee death |
| `wipe.mp3` | 10 s | 234 kbps | 298,605 B | Used: wipe chat phrase |
| `Zelda.mp3` | 2 s | 128 kbps | 42,630 B | Used: boss death |

The default profile is missing `divineInt2.mp3`. It also lacks the disabled
`Login.mp3` and `Xtreme.mp3` files.

## Alternate “Toni” profile (`assi/`)

| File | Duration | Bitrate | Size | Status |
| --- | ---: | ---: | ---: | --- |
| `Angels1.mp3` | 5 s | 178 kbps | 121,680 B | Used; identical to default |
| `Angels2.mp3` | 6 s | 192 kbps | 161,568 B | Used; identical to default |
| `at_bam_babam.mp3` | 1 s | 128 kbps | 17,553 B | Used; identical to default |
| `Bloodlust.mp3` | 3 s | 128 kbps | 56,134 B | Used; alternate file |
| `Bubble.mp3` | 1 s | 128 kbps | 27,305 B | Used; alternate file |
| `bye.mp3` | 4 s | 128 kbps | 66,980 B | Used; alternate file |
| `divineInt.mp3` | 4 s | 128 kbps | 66,486 B | Used; identical to default |
| `end.mp3` | 9 s | 160 kbps | 183,508 B | Used; alternate file |
| `FFX.mp3` | 4 s | 128 kbps | 67,495 B | Used; identical to default |
| `Inervate1.mp3` | 2 s | 128 kbps | 37,305 B | Used; alternate file |
| `Inervate2.mp3` | 2 s | 128 kbps | 47,754 B | Used; alternate file |
| `Login.mp3` | 3 s | 192 kbps | 77,574 B | Present; playback commented out |
| `Manatide.mp3` | 2 s | 320 kbps | 82,684 B | Used; alternate file |
| `MarioDeath.mp3` | 2 s | 128 kbps | 37,305 B | Used; alternate file |
| `Ready.mp3` | 1 s | 128 kbps | 30,336 B | Used; identical to default |
| `schnutz.mp3` | 1 s | 128 kbps | 22,676 B | Used; alternate file |
| `soulstone.mp3` | 1 s | 128 kbps | 26,487 B | Used; identical to default |
| `soulstone3.mp3` | 2 s | 192 kbps | 52,402 B | Present but unreachable due to random range |
| `Surprise.mp3` | 5 s | 128 kbps | 83,280 B | Used; identical to next two files |
| `Surprise2.mp3` | 5 s | 128 kbps | 83,280 B | Used; duplicate |
| `Surprise3.mp3` | 5 s | 128 kbps | 83,280 B | Used; duplicate |
| `Tank.mp3` | 1 s | 128 kbps | 31,763 B | Used; renamed from `Tank1.mp3` to match code |
| `Tank2.mp3` | 1 s | 128 kbps | 31,763 B | Used; identical to `Tank.mp3` |
| `wilhelm.ogg` | n/a | n/a | 12,524 B | Used; identical to default |
| `wipe.mp3` | 10 s | 234 kbps | 298,605 B | Used; identical to default and candidate copy |
| `Xtreme.mp3` | 2 s | 128 kbps | 42,214 B | Present; code path commented out |
| `Zelda.mp3` | 2 s | 128 kbps | 42,630 B | Used; identical to default |

The Toni profile still lacks the reachable `divineInt2.mp3` and
`soulstone2.mp3` files.

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
| `wipe.mp3` | 10 s | 234 kbps | 298,605 B |
| `Wololooo.mp3` | 1 s | 128 kbps | 26,330 B |

## Byte-identical files

SHA-256 comparison found the following exact duplicates:

- Default and Toni: `Angels1.mp3`, `Angels2.mp3`,
  `at_bam_babam.mp3`, `divineInt.mp3`, `FFX.mp3`, `Ready.mp3`,
  `soulstone.mp3`, `soulstone3.mp3`, `wilhelm.ogg`, and `Zelda.mp3`
- `wipe.mp3` is identical in the default, Toni, and candidate directories.
- Toni `Surprise.mp3`, `Surprise2.mp3`, and `Surprise3.mp3` are identical.
- Toni `Tank.mp3` and `Tank2.mp3` are identical.

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
