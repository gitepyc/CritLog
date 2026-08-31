# CritLog Wiki

This documentation describes the current state of CritLog `0.2.1`. It
distinguishes user-confirmed runtime behavior, behavior derived from static code
review, and checks that are still outstanding.

## Target environment

- **Game mode:** Season of Discovery
- **Client family:** WoW Classic Era
- **Client version:** `1.15.9`
- **TOC interface:** `11509`
- **Runtime status:** The current user confirms that the addon works in this
  client.

The interface number primarily prevents the client from marking the addon as
out of date. It does not by itself prove that every API call behaves correctly.

### Interface-version verification

`11509` was cross-checked on August 31, 2026 against multiple actively
maintained Classic Era addons:

- [MoveAny `MoveAny_Vanilla.toc`](https://github.com/d4kir92/MoveAny/blob/main/MoveAny_Vanilla.toc)
- [ApogeePartyHealthBars compatibility statement](https://github.com/notify353/ApogeePartyHealthBars)
- [BetterBags report using Classic Era/SoD 1.15.9](https://github.com/Cidan/BetterBags/issues/1053)

Recheck this value against the installed client or current Classic Era TOCs
after future client patches.

## Pages

| Page | Content |
| --- | --- |
| [Behavior and triggers](BEHAVIOR.md) | Which event and condition cause which state change or sound? |
| [Sound catalog](SOUNDS.md) | All 68 audio files, code usage, variants, gaps, and duplicates. |
| [Refactoring plan](REFACTORING.md) | Recommended order, module boundaries, and acceptance criteria. |
| [Cleanup review checklist](CLEANUP-REVIEW.md) | Condensed trigger and sound lists for deciding what to keep, replace, or cut. |
| [Project README](../README.md) | Installation, commands, layout, and known risks. |

## Documentation status

| Area | Status |
| --- | --- |
| Registered events and handlers | Inventoried from code |
| Slash commands | Inventoried from code |
| Sound files and technical metadata | Fully inventoried |
| Byte-identical duplicates | Verified through SHA-256 comparison |
| In-game playback of every trigger on SoD | Not yet recorded as a test matrix |
| Listening review of every clip | Outstanding |
| Copyright and redistribution rights | Outstanding |

## Maintenance rule

Any behavior change must update the relevant matrix in `BEHAVIOR.md` and the
catalog in `SOUNDS.md` in the same commit. Observed in-game behavior should be
recorded with the client version, character class, and reproduction steps.
