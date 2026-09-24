-- Pure eligibility/matching rules: given already-resolved values (a class,
-- a role, a classification, ...), decide yes/no. No WoW API calls in this
-- file - resolving those values from a live unit token is Core/CombatLog.lua's
-- job, since that's what actually needs the game client to exist. Splitting
-- it this way is what makes these rules testable outside the game (plain
-- Lua, no client) - see tests/README.md for the standing gap this closes.
CritLog.Filters = {}

-- Matches a spell entry from Core/Constants.lua by ID first, falling back
-- to the display name if the ID doesn't hit.
function CritLog.Filters.matchesSpell(spell, spellId, spellName)
    return tContains(spell.ids, spellId) or tContains(spell.names, spellName)
end

-- DPS is not a class, it's the real in-game 3-role system's third bucket:
-- Tank, Healer, or everyone else - a Mage counts exactly like a Warrior
-- does, as long as neither is currently assigned Tank or Healer.
function CritLog.Filters.isAssignedDps(role)
    return role ~= "TANK" and role ~= "HEALER"
end

-- True only if the unit currently has the Tank role explicitly assigned
-- (raid-frame role icons, or equivalent). Assigned role only reflects a
-- role someone actually set - a real tank who was never manually flagged
-- reports "NONE". Known blind spot, accepted rather than solved: not
-- falling back to a class-based guess, since that would flag every
-- non-tanking Warrior/Paladin/Druid too. The playerGroups.tank
-- name-roster fallback in HandleDeath covers this gap.
function CritLog.Filters.isAssignedTank(role)
    return role == "TANK"
end

-- Same reasoning as isAssignedTank above, for Healer - a raid role, not a
-- class, deliberately not Priest-specific: a Holy Paladin's death counts
-- here exactly like a Priest's. Same known blind spot; the
-- playerGroups.heal name-roster fallback in HandleDeath covers it.
function CritLog.Filters.isAssignedHealer(role)
    return role == "HEALER"
end

-- True if a classification (already read via UnitClassification, or nil if
-- it couldn't be determined) counts as a boss per Core/Constants.lua.
function CritLog.Filters.isBossClassification(classification)
    return classification ~= nil
        and tContains(CritLog.Constants.bosses.classifications, classification)
end

-- Decides whether a dps/tank/heal/boss death sound should play, given
-- the selected detection mode and the two already-computed match results
-- (live role/classification check, and name-roster check). "none"
-- (or any unrecognized value) always returns false - deliberately fails
-- closed rather than falling back to some other mode if CritLogDB ever
-- holds something unexpected.
function CritLog.Filters.matchesDetectionMode(mode, liveMatch, rosterMatch)
    if mode == "experimental" then
        return liveMatch
    end
    if mode == "roster" then
        return rosterMatch
    end
    if mode == "both" then
        return liveMatch or rosterMatch
    end
    return false
end

-- Classifies a /roll result into a Constants.sounds key, or nil for a roll
-- that doesn't hit any of the specific values/bands below. Requires
-- rollMin == 1 (a loot roll like /roll 1 5 starts elsewhere and is
-- ignored); any custom range starting at 1 (e.g. /roll 1-1000) is
-- classified too, not just 1-100.
--
-- roll1/roll100/roll69 are exact-value matches, checked first, so a
-- literal roll of 1 always plays roll1, never one of the percentage bands
-- below. roll5/roll10/roll95 are percentage bands (<8% / 8-10% / >=92% of
-- rollMax) - naturally unreachable for a small custom range, which just
-- falls silent instead of needing an explicit floor.
function CritLog.Filters.classifyRoll(rollResult, rollMin, rollMax)
    if rollMin ~= 1 then
        return nil
    end

    if rollResult == rollMax then
        return "roll100"
    elseif rollResult == 1 then
        return "roll1"
    elseif rollResult == 69 then
        return "roll69"
    elseif rollResult >= 92 * rollMax / 100 then
        return "roll95"
    elseif rollResult < 8 * rollMax / 100 then
        return "roll5"
    elseif rollResult <= 10 * rollMax / 100 then
        return "roll10"
    end

    return nil
end

-- Excludes crits against trivial ("grey") enemies from counting as
-- highscores, so a one-shot on low-level content doesn't overwrite a real
-- record from relevant content. `targetLevel`/`targetClassification` are
-- already-resolved values (nil handling for "no unit token" is the caller's
-- job, since that's a WoW-API concern, not a rule).
--
-- `filterEnabled` is the separate on/off master switch (`LevelFilterFlag`);
-- `levelDiffThreshold` is how many levels below the player a target may be
-- before it's excluded once the filter is on. Deliberately
-- one-directional: a crit against a much *higher*-level target is never
-- filtered out, since that's exactly the impressive case a highscore
-- tracker shouldn't exclude.
function CritLog.Filters.passesLevelFilter(targetLevel, targetClassification, playerLevel, filterEnabled, levelDiffThreshold)
    if not filterEnabled then
        return true
    end

    return targetLevel > playerLevel - levelDiffThreshold or targetClassification == "worldboss"
end
