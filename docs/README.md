# CritLog Wiki

This documentation describes the current behavior of CritLog; see
[`../CHANGELOG.md`](../CHANGELOG.md) for the versioned list of what changed
when.

## Client compatibility

`CritLog.toc` declares the interface versions `120100, 50504, 20506, 11509, 16001`
(Retail, Mists Classic, TBC Anniversary, Classic Era, WoW Forever). Development happens
on Classic Era / Season of Discovery `1.15.9` (interface `11509`).

Retail (since 12.0) and WoW Forever block the combat log for addons. On
these clients CritLog does not register `COMBAT_LOG_EVENT_UNFILTERED` and
prints a notice at login: crit highscores, death, aura and killing-blow
features are unavailable there. Ready check, `/roll`, lottery and chat
trigger sounds still work. Detection: the global `issecretvalue` exists.
The options panel shows a "Limited mode" line there; combat-log-only options
are greyed out with a tooltip explaining why, the Aura Sounds and Death
Sounds buttons are disabled, and the matching `/cl` toggles only print a
notice.

The interface number only prevents the client from marking the addon as out
of date; it does not prove that every API call behaves correctly. Recheck
the values against the installed client or current TOCs after client
patches.

## Pages

| Page | Content |
| --- | --- |
| [Behavior and triggers](BEHAVIOR.md) | Which event and condition cause which state change or sound? |
| [Sound catalog](SOUNDS.md) | Every audio file and its code usage. |
| [Roadmap](ROADMAP.md) | Prioritized list of what's still outstanding. |
| [Project README](../README.md) | Installation, commands, layout, and known risks. |

## Documentation status

| Area | Status |
| --- | --- |
| Registered events and handlers | Inventoried from code |
| Slash commands | Inventoried from code |
| Sound files and technical metadata | Fully inventoried |
| In-game playback of every trigger on SoD | Not yet recorded as a test matrix |

## Maintenance rule

Any behavior change must update the relevant matrix in `BEHAVIOR.md` and the
catalog in `SOUNDS.md` in the same commit. Observed in-game behavior should be
recorded with the client version, character class, and reproduction steps.
