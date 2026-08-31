# Changelog

## Unreleased

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
