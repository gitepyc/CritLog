# Changelog

## Unreleased

- Deleted the 6 sound files that became unused once random multi-clip
  selection and the `Schnutz` special case were removed: `Inervate1.mp3`,
  `Angels2.mp3`, `Zelda.mp3`, `soulstone2.mp3`, `soulstone3.mp3`,
  `schnutz.mp3`. Renamed the two survivors that still carried a stale
  variant-number suffix now that they're the only file for their sound:
  `Angels1.mp3` → `Angels.mp3`, `Inervate2.mp3` → `Innervate.mp3` (also
  fixing the long-standing "Inervate" typo). `Data.lua` and
  `docs/SOUNDS.md`/`docs/BEHAVIOR.md` updated to match; the sound catalog
  is now 18 files instead of 24.
- Removed the special-cased `"Schnutz"` death sound (`meleeDeathSchnutz` /
  `schnutz.mp3`): that character is already in the standard
  `playerGroups.melee` roster, so they now get the regular melee death
  sound (`wilhelm.ogg`) like everyone else instead of a personal clip.
  `schnutz.mp3` stays on disk, unused, pending the deferred asset-rights
  review.
- Removed random multi-clip selection: every logical sound now plays exactly
  one fixed file instead of picking randomly between two or three each time.
  Affected `CritLog.Data.sounds` entries and the file now kept (the others
  stay on disk, unused, pending the deferred asset-rights review):
  `bossDeath` → `FFX.mp3` (was random with `Zelda.mp3`), `priestDeath` →
  `Angels1.mp3` (was random with `Angels2.mp3`), `innervate` → `Inervate2.mp3`
  (was random with `Inervate1.mp3`), `soulstone` → `soulstone.mp3` (was
  random with `soulstone2.mp3`/`soulstone3.mp3`). Which file to keep for
  each was the user's call, not derivable from the code. Removed the now-dead
  `randomEntry()` helper in `CombatLog.lua` and the matching
  `type(sound) == "table"` branch in `Options.lua`'s preview handler, since
  no `CritLog.Data.sounds` entry is a table anymore.
- Added TOOLTIP frame strata + `SetToplevel(true)` to the options panel so it
  renders above other addon UI (was getting covered by a WeakAuras display).
- Options panel: added a short hover tooltip to every toggle explaining what
  it does, and marked the four toggles that rely on the new class/role/
  classification detection (Priest/Melee/Tank/Boss death sounds) as
  "(Experimental)" in their labels, since only crit and aura sounds have
  been in-game verified so far.
- Added a master sound switch: `CritLogDB.MasterSoundFlag` (`/cl mute`, on
  by default - migration-safe, back-fills to `true` so existing characters
  keep hearing sounds exactly as before until they explicitly mute).
  Checked inside `CritLog:PlaySound()` in `Sounds.lua`, the single function
  every sound in the addon already routes through (crits, auras, deaths,
  ready check, chat triggers, and the options panel's preview buttons) -
  so one flag mutes everything, without needing to touch each trigger or
  split sound logic into a separate module. Considered and rejected a
  larger split of the addon into a "crit tracking core" and a fully
  separate "sound module": `Sounds.lua` already is that boundary
  file-wise, and `CritLogDB` state updates already happen independently
  of whether a sound plays, so the only thing actually missing was this
  one global toggle - a full architectural split would have added an
  event-dispatch layer for no real benefit at this addon's size. Added a
  checkbox for it (no preview button - muting has no sound of its own) at
  the top of the options panel's toggle list, and `/cl mute` to
  `printHelp()`/`printConfig()`.
- Added a standalone in-game options panel (`Options.lua`, loaded last per
  `docs/REFACTORING.md`'s step-4 layout), opened/closed with `/cl options`.
  Shows the current highscores (damage/white-hit/heal crit records, same
  data `/cl` already prints via `printHighscores()`), `CritLog.version`, and
  a checkbox for every one of the 14 `CritLogDB` toggle fields, labeled with
  wording lifted from `Commands.lua`'s `printHelp()`/`printConfig()` so no
  new terminology is introduced. Checkboxes read their state on every
  `OnShow` (highscores and toggles can change from chat commands while the
  panel is closed) and write straight back to `CritLogDB` on click - no new
  `CritLogDB` fields, no changes to trigger/combat-log/sound logic.
  Deliberately built with only stock Blizzard templates
  (`BasicFrameTemplateWithInset`, `UICheckButtonTemplate`,
  `UIPanelButtonTemplate`) and default styling - "erstmal Default Styling,
  dann schauen wir mal": this is a first draft for visual review, not a
  finished panel. No minimap button, no Interface Options/Settings
  integration - out of scope for this pass. Added `UIParent` to
  `.luacheckrc`'s curated globals list for the new frame parent. Not tested
  in a real WoW client - there's no headless mode to verify
  `CreateFrame`/frame layout with here (see `tests/README.md`); needs an
  in-game check of both visuals and each checkbox's read/write round-trip
  before merge.
  Every toggle with a sound of its own (highscore/xtreme/ready/priest/
  melee/tank/player/boss) also got a "Preview" button that plays the
  clip directly through the existing `CritLog:PlaySound()`
  (`Sounds.lua`), bypassing both the `CritLogDB` flag and the real
  combat-log/event trigger entirely, so you can hear a sound while
  deciding whether to enable it. `AuraSoundFlag` alone gates seven
  distinct spell sounds (Bloodlust, Innervate, Power Infusion, Blessing
  of Protection, Divine Intervention, Mana Tide, Soulstone), too many
  for one row, so it gets a small button grid instead of a single
  preview button. Multi-variant sounds (priest/boss death, Innervate,
  Soulstone) preview a random pick each click via the same
  `math.random`-based selection `CombatLog.lua`'s local `randomEntry()`
  already uses for the real trigger, rather than cycling through
  variants, so a preview sounds like what actually plays in game.
  Flags with no sound of their own - `AllCritFlag`/`WhiteHitFlag` (they
  only change *when* the shared highscore sound plays, already
  previewable from the `SoundFlag` row), `AllLevel`/`DebugFlag` (no
  sound at all), `DeadSoundFlag` (a master switch already covered by
  the five death-sound rows it gates) - don't get a button, to keep a
  first-draft panel from getting more cluttered than the 14 checkboxes
  already make it. No new `CritLogDB` fields - preview buttons only play
  sounds, nothing is persisted. Verified all sound keys referenced from
  `Options.lua` exist in `CritLog.Data.sounds` and re-ran the
  filename-vs-`sounds/`-directory cross-check from `docs/REFACTORING.md`
  step 3 (still 24/24 both ways).
- **First draft, needs in-game verification and a product decision before
  merge** — replaced the hardcoded melee/tank/priest death-sound rosters
  with class/role-based matching as the primary check, per the roadmap item
  in docs/REFACTORING.md (step 5) and docs/CLEANUP-REVIEW.md ("Direction
  decided, not yet scheduled"). `CombatLog.lua`'s `HandleDeath` now resolves
  a live unit token for the dying player via the existing `findUnitToken()`
  helper and checks:
  - **Priest**: `UnitClass(token)` englishClass `== "PRIEST"`. Clean 1:1
    mapping, no judgment call needed.
  - **Tank**: `UnitGroupRolesAssigned(token) == "TANK"`. This is the
    correct API for an actually-assigned role, but it only reflects a role
    someone explicitly set (e.g. raid-frame role icons) — it commonly
    reports `"NONE"` for a real tank who was never manually flagged,
    especially outside a raid group. Deliberately **not** falling back to
    a class-based guess (e.g. "Warrior with no Healer role") when the role
    is unassigned — that would flag every non-tanking Warrior/Paladin/Druid
    too, trading one gap for a worse one. Judgment call; open for
    reconsideration.
  - **Melee**: the fuzziest of the three, flagged as a known, accepted
    blind spot rather than presented as solved. `Data.lua`'s new
    `deathClasses.meleeCapable` (`WARRIOR`, `ROGUE`, `PALADIN`, `SHAMAN`,
    `DRUID`) and `alwaysMelee` (`WARRIOR`, `ROGUE`, which have no
    ranged/caster spec at all) narrow the hybrids by excluding anyone with
    `UnitGroupRolesAssigned(token) == "HEALER"`. This does **not** exclude
    ranged-caster DPS specs of those same hybrid classes (Elemental
    Shaman, Balance Druid, ...) — there is no reliable API to distinguish
    a melee spec from a caster spec of the same class for another player
    without inspecting talents, which isn't always possible. Hunter is
    excluded entirely (functionally ranged despite being able to equip
    melee weapons); Mage/Warlock are excluded entirely (never melee).
    Judgment call; open for reconsideration.
  - **`"Schnutz"` special case**: kept, unchanged, as a standalone
    exact-name check independent of the class/role logic above — it's a
    personal in-joke tied to one specific character, not a generalizable
    class or role rule, so it doesn't fit "no more names" cleanly either
    way. Not silently dropped and not silently kept as if it were
    resolved: flagged explicitly in the PR for the user to decide (keep
    for nostalgia / make configurable / drop). Currently keeping it is the
    recommendation, since dropping it silently would be a behavior change
    the user didn't ask for.

  The old `Data.lua` `playerGroups` name rosters (melee/tank/priest) are
  **kept as a fallback**, not deleted, using the same
  ID-first-then-name-fallback pattern already established for spell
  matching: class/role detection needs a live unit token (not guaranteed —
  the dying player might not be targeted or on a visible nameplate) and,
  for tank, an explicitly assigned role (also not guaranteed) — a name
  match in the legacy roster still fires the sound when the live check
  can't. This was a judgment call, not a mandate: full replacement was
  considered and rejected because role detection is inherently less
  reliable than the spell-ID lookups this pattern was originally built
  for, so the failure mode (a death sound silently not firing) is more
  likely here, not less.

  No new `CritLogDB` field was added — `MeleeSoundFlag`/`TankSoundFlag`/
  `PriestSoundFlag` still gate the same three sounds as before, just with
  a different match underneath. `CRITLOG_VERSION` is unchanged and
  `SetDefaults()` needed no changes; migration safety isn't affected by
  this change at all.

  **Cannot be verified without a WoW client** (see tests/README.md — no
  headless mode exists in this environment): whether `UnitClass`/
  `UnitGroupRolesAssigned` behave as expected against real group members,
  whether `findUnitToken()` reliably resolves a token for a dying player in
  practice, and whether the melee/tank heuristics above produce acceptable
  results for an actual roster. This needs in-game testing before merge.
- Boss/NPC death and killing-blow detection is now classification-first,
  with the hardcoded name lists kept as a fallback (previously name-only,
  see the `docs/REFACTORING.md` note added in the previous release about
  considering `UnitClassification()`). Only the `"worldboss"` classification
  is accepted - the "Level ?? (Boss)" rank that covers 40-man raid bosses,
  outdoor world bosses, and SoD's new level-60 raid encounters. Deliberately
  narrow: `"elite"`/`"rareelite"` match ordinary dungeon trash and 5-man end
  bosses, `"rare"` matches leveling rare spawns, and accepting those would
  fire the boss sound/kill message on most pulls. The name lists remain the
  mechanism for boss NPCs that aren't classified `"worldboss"` (5-man end
  bosses, SoD's Blackfathom Deeps/Gnomeregan raid bosses) - they're not
  being retired, just demoted to fallback.

  Implementation note: `UnitClassification()` needs a live unit token, and
  by the time `UNIT_DIED` fires the unit's nameplate is usually already
  gone. So classification isn't looked up at death - it's captured and
  cached by GUID while the NPC is still alive and in combat (from both
  the attacker and target side of every combat-log event), and the death
  handler and killing-blow print just read the cache. The cache is a
  plain runtime table (not `CritLogDB`/SavedVariables) since it only
  describes the current fight; capped at 200 tracked GUIDs with a retry
  limit per unresolved GUID, and cache entries are dropped once their
  unit dies so a long raid doesn't accumulate dead GUIDs.

  Also fixes a latent bug found along the way: `PrintBossKillingBlow`
  compared `overkill` (read positionally off the combat log) directly
  against `0` without checking it was actually a number first - not every
  `_DAMAGE`-suffixed subevent guarantees a numeric `overkill` argument, so
  this could throw a Lua error. Now guarded with `type(overkill) ~=
  "number"`.

  **Needs in-game verification before this is trusted**: neither the
  classify-while-alive caching timing nor the `"worldboss"`-only allowlist
  have been tested against a real client. Please verify against at least
  one real dungeon/raid boss (kill message + death sound both fire) and a
  random non-boss elite or rare mob (neither fires - false positive check)
  before merging.
- Added a debug mode: `/cl debug` toggles `DebugFlag` (off by default,
  standard migration-safe new field - existing characters just get it
  backfilled as `false`). `CritLog:Debug(...)` in Core.lua prints only
  when enabled, prefixed so it's easy to spot in chat. Wired into the two
  areas most likely to need diagnosing right now: every `SPELL_AURA_APPLIED`
  on the player and every `SPELL_SUMMON` by a group member logs the raw
  spell ID/name seen (directly useful for verifying the not-yet-verified
  spell IDs from the previous change), and the level filter logs which
  unit token it resolved and the resulting level/classification check.
- Aura/ability triggers (Bloodlust/Heroism, Innervate, Power Infusion,
  Mana Tide Totem, Blessing of Protection, Divine Intervention, Soulstone
  Resurrection) now match by spell ID first, falling back to the
  English/German display name if the ID doesn't hit. IDs sourced from
  Wowhead's current Classic database, cross-checked against multiple
  expansion pages where available:
  - Bloodlust (Horde) `27689`, Heroism (Alliance) `23682`
  - Innervate `29166`
  - Power Infusion `10060`
  - Mana Tide Totem `16190`
  - Blessing of Protection `1022`
  - Divine Intervention `19752`
  - Soulstone Resurrection `20707`

  Not in-game verified — that's exactly why the name fallback exists,
  since a wrong ID fails silently while a wrong name costs nothing extra
  to keep around. Boss/NPC matching is untouched, still name-only.

## 0.2.1

- Fixed the damage-crit level filter checking the currently selected UI
  target instead of the actual combat-log destination — a crit against one
  enemy could be filtered using a different enemy's level if your target
  didn't match. Added `findUnitToken()`, which resolves the hit unit's own
  token (target, or a matching visible nameplate) before checking its
  level/classification; if no token can be resolved, the crit is allowed
  through rather than silently dropped. Only affects damage crits (heal
  crits were already exempt from this filter); crit detection itself was
  never affected, since that comes straight from the combat log's own
  critical-hit flag. Needs in-game verification — not something lint can
  confirm.
- Removed `README.txt`, the 3-line legacy readme fully superseded by
  `README.md`/`docs/`. One readme instead of two.
- `Core.lua` now reads the version from `CritLog.toc` via
  `GetAddOnMetadata("CritLog", "Version")` (falling back to
  `C_AddOns.GetAddOnMetadata` if the plain global isn't available on a
  given client) instead of duplicating the version string. `CritLog.toc`'s
  `## Version:` is now the single source of truth. No `CritLogDB` migration
  impact beyond the version bump itself: `SetDefaults()` only back-fills
  missing fields on a version change, nothing is reset.
- Documented two roadmap decisions without implementing them yet:
  replacing the hardcoded player-name death rosters with class-based
  matching, and giving Spirit of Redemption a real fix or removing it
  outright. See docs/REFACTORING.md and docs/CLEANUP-REVIEW.md.

## 0.2.0

- Added `.github/workflows/release.yml`: on a tag push, runs the
  BigWigsMods packager and creates a GitHub Release with the built zip
  attached. No CurseForge/WoWInterface/Wago project id or API keys are
  configured yet, so only the GitHub Release step runs; the workflow uses
  the automatically-provided `GITHUB_TOKEN`. Requires this GitHub mirror
  repo's Settings → Actions → General → Workflow permissions to be set to
  "Read and write", or the release step fails with "Resource not
  accessible by integration".
- Verified `.pkgmeta` end-to-end by running the BigWigsMods `release.sh`
  packager locally (skip upload, skip zip creation). It produces a clean
  `CritLog/` package directory containing only the TOC, addon Lua modules,
  `sounds/`, `README.txt`, and this changelog — no repo scaffolding. Added
  `manual-changelog: CHANGELOG.md` so the packager ships this hand-maintained
  changelog instead of auto-generating one from raw git log messages, and
  added `.gitattributes` to the ignore list (it isn't an addon file).
- Split the former monolithic `CritLog.lua` into focused modules for core
  state, data, SavedVariables, sounds, chat triggers, combat-log handling,
  commands, and event dispatch. The TOC defines their dependency order and
  shared state lives under the `CritLog` namespace.
- Added `.gitattributes` to keep source and documentation files on LF across
  development platforms. WoW can load LF files on Windows.
- Centralized sounds, spells, bosses, player rosters, and chat-trigger
  phrases in `CritLog.Data` instead of scattered constants and sound lists.
  No intentional user-visible behavior change; see docs/REFACTORING.md.
- `CritLogDB` version upgrades no longer reset existing data. Previously,
  any `CRITLOG_VERSION` change rebuilt the whole per-character database from
  scratch (documented as a known risk). `SetDefaults()` now only back-fills
  fields that don't exist yet on a version change; existing highscores and
  toggles are kept. A brand-new character still gets the full default table
  as before.
- Split CritLog out of the former `wow-addons` monorepo into its own
  repository (`critlog`), with full commit history preserved. The addon's
  files (`CritLog.toc`, `CritLog.lua`, `README.txt`, `sounds/`) moved from
  the `CritLog/` subdirectory up to the repository root; everything else
  (`docs/`, `tests/`, `scripts/`, `.luacheckrc`, `.pkgmeta`, CI workflow)
  already lived at root and is unchanged in content beyond path references.
  No addon behavior changed. This also fixes a latent mismatch: `.pkgmeta`
  already assumed `CritLog.toc` lived at the repository root (standard for
  a single-addon repo), which only became true with this move.
- Revived the "over 9000 damage" sound as a real feature: added
  `XtremeSoundFlag`/`/cl xtreme`, off by default, using the same
  `sourceGUID == UnitGUID("Player")` check already used elsewhere instead of
  the original's fragile `Split()`-based string parsing.
- Removed the login-sound feature entirely (it had a live `/cl login`
  toggle, but no code path ever played anything): `LOGIN_SOUND`,
  `LoginSoundFlag`, the `/cl login` command, its `help`/`config` lines, and
  `Login.mp3`.
- Removed dead code with no live surface: the unreachable `ZONE_CHANGED`
  handler (its `RegisterEvent` call was already commented out) and
  `Split()` (only ever referenced inside a commented-out debug condition).
- Removed `CritLog/sounds/more sounds/` (14 files) — never referenced by
  any trigger.
- Left Spirit of Redemption's commented-out test code untouched,
  deliberately — may get a real fix later.
- `CritLogDB` migration verified again for all of the above:
  `CRITLOG_VERSION` unchanged, so `LoginSoundFlag` simply stops being
  read/written for existing characters, and the new `XtremeSoundFlag` reads
  as `nil` (falsy) for anyone who doesn't have it yet — off by default with
  no explicit migration step needed.
- Sound catalog is now 24 files, all in active use (down from 39; the very
  first count in this cleanup was 69). See docs/SOUNDS.md and
  docs/CLEANUP-REVIEW.md.
- Made the Toni sound set the addon's only profile and removed the old
  default-only clips (25 active files now, down from 53, ~4.18 MB →
  ~3.13 MB). `/cl toni`, `ToniFlag`, `SoundFile`, and the whole
  `ResolveSound()`/dedup-alias mechanism from the previous step are gone —
  there's only one profile now, so nothing to resolve between. Power
  Infusion and Tank death now play a single fixed clip instead of
  "randomly" picking between files that were already identical in the Toni
  set. `CritLogDB` migration verified: `CRITLOG_VERSION` is unchanged, so
  existing characters' saved data is untouched on login; the now-unused
  `ToniFlag`/`SoundFile` fields simply stop being read. See
  docs/CLEANUP-REVIEW.md for what's still worth cutting as dead weight
  (disabled-feature constants/assets, hardcoded raid rosters, the unused
  `more sounds/` candidates folder).
- Deduplicated the sound catalog: 16 files that were byte-identical to
  another file already in the catalog were removed (69 → 53 files,
  ~5.68 MB → ~4.18 MB). `CritLog.lua` now resolves sound paths through a new
  `ResolveSound()` helper (`SHARED_WITH_DEFAULT`, `TONI_ALIASES`) instead of
  raw string concatenation, so removed filenames transparently redirect to
  the one physical copy that's left. No change to what plays in game, with
  one caveat already true before this change: the Toni-profile "random"
  picks for Power Infusion and Tank death always played the same clip
  because the candidate files were identical — that's now explicit in code
  instead of coincidental. See docs/SOUNDS.md and docs/CLEANUP-REVIEW.md.
- Fixed `divineInt2.mp3` selection pointing at a file that was never shipped;
  Divine Intervention now plays the one clip that exists.
- Fixed the Toni sound profile missing `soulstone2.mp3`.
- Fixed the Soulstone random range so `soulstone3.mp3` is reachable.
- Fixed critical heals being gated by the enemy target-level filter, which
  only makes sense for damage crits.
- Fixed several accidental global variable leaks (missing `local`).
- Fixed `/cl reset` dropping the schema version and active configuration.
- Fixed the highscore printout showing the wrong target name.
- Added `.luacheckrc` and a containerized `luacheck` setup (`tests/`,
  `scripts/lint.sh`) for static analysis.
- Added repository scaffolding: `LICENSE` (MIT, code only — audio rights
  remain unresolved, see docs/SOUNDS.md), `.gitignore`, `.editorconfig`,
  `.pkgmeta` draft, GitHub Actions lint workflow.

## 0.1.1

Baseline version inherited from the original addon. See
[docs/BEHAVIOR.md](docs/BEHAVIOR.md) and [docs/SOUNDS.md](docs/SOUNDS.md) for
a full inventory of behavior and known issues at this version.
