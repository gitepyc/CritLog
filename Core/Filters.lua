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

-- Per Core/Constants.lua's deathClasses.meleeCapable/alwaysMelee. Warrior
-- and Rogue have no ranged/caster spec at all, so class alone identifies
-- them. The remaining hybrid classes (Paladin, Shaman, Druid) are narrowed
-- by assigned raid role: a Healer-flagged member of one of those classes is
-- excluded, since a Holy Paladin/Restoration Shaman/Restoration Druid is
-- never in melee.
--
-- Known blind spot, accepted rather than solved: this does NOT exclude
-- ranged-caster DPS specs of those same hybrid classes (Elemental Shaman,
-- Balance Druid, ...), which will still be flagged as "melee" here. There
-- is no reliable API to tell a melee spec from a caster spec of the same
-- class for another player without inspecting talents, which isn't always
-- possible. See CHANGELOG.md.
function CritLog.Filters.isMeleeClass(class, role)
    if not class then
        return false
    end

    if tContains(CritLog.Constants.deathClasses.alwaysMelee, class) then
        return true
    end

    if not tContains(CritLog.Constants.deathClasses.meleeCapable, class) then
        return false
    end

    return role ~= "HEALER"
end

-- True only if the unit currently has the Tank role explicitly assigned
-- (raid-frame role icons, or equivalent). Tank is a raid role, not a class
-- — a Warrior/Paladin/Druid can each be a tank or something else — and
-- assigned role only reflects a role someone actually set, which is not
-- guaranteed. It commonly reports "NONE" for a real tank who was never
-- manually flagged, especially outside a raid.
--
-- Known blind spot, accepted rather than solved: an unassigned real tank
-- is not detected here. Deliberately not falling back to a class-based
-- guess (e.g. "Warrior with no Healer role") — that would also flag every
-- non-tanking Warrior/Paladin/Druid, trading one gap for a worse one. The
-- playerGroups.tank name-roster fallback in HandleDeath covers this gap
-- for the same handful of characters it always has. See CHANGELOG.md.
function CritLog.Filters.isAssignedTank(role)
    return role == "TANK"
end

-- Same reasoning as isAssignedTank above, for Healer - a raid role, not a
-- class: a Priest/Paladin/Druid/Shaman can each be a healer or something
-- else. Used for the "Healer death" category (CritLogDB.PriestDetectionMode
-- - field name unchanged, only the UI label/roster meaning moved from
-- "Priest" to "assigned Healer role"), which is deliberately NOT
-- priest-specific anymore - a Holy Paladin's death counts here exactly
-- like a Priest's. Spirit of Redemption is the one case that still needs
-- an actual Priest (see isPriestClass below and Core/CombatLog.lua's
-- HandleDeath) - it's a Priest-only talent, unlike the Healer role itself.
--
-- Known blind spot, same as isAssignedTank: an unassigned real healer is
-- not detected here; the playerGroups.priest name-roster fallback in
-- HandleDeath covers this gap.
function CritLog.Filters.isAssignedHealer(role)
    return role == "HEALER"
end

-- Straightforward class check, used only for Spirit of Redemption now
-- (see Core/CombatLog.lua's HandleDeath) - the talent itself is
-- Priest-only, unlike the "Healer death" category above which matches any
-- class's assigned Healer role.
function CritLog.Filters.isPriestClass(class)
    return class ~= nil and tContains(CritLog.Constants.deathClasses.priest, class)
end

-- True if a classification (already read via UnitClassification, or nil if
-- it couldn't be determined) counts as a boss per Core/Constants.lua.
function CritLog.Filters.isBossClassification(classification)
    return classification ~= nil
        and tContains(CritLog.Constants.bosses.classifications, classification)
end

-- Decides whether a melee/tank/priest/boss death sound should play, given
-- the selected detection mode and the two already-computed match results
-- (live class/role/classification check, and name-roster check). "none"
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
-- that doesn't hit any of the specific values/bands below. Ported near
-- verbatim from the legacy single-file addon (see CHANGELOG.md); only
-- applies to a plain 1-100 roll (rollMin == 1, rollMax >= 100) - any other
-- range (e.g. a /roll 1 5 for loot) is deliberately ignored. Checked in
-- this order because the bands overlap at their edges (e.g. 100 would
-- also satisfy ">= 92%"), so the more specific exact-value checks must run
-- first.
function CritLog.Filters.classifyRoll(rollResult, rollMin, rollMax)
    if rollMin ~= 1 or rollMax < 100 then
        return nil
    end

    if rollResult == rollMax then
        return "roll100"
    elseif rollResult == 1 * rollMax / 100 then
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
function CritLog.Filters.passesLevelFilter(targetLevel, targetClassification, playerLevel, allLevel)
    if allLevel then
        return true
    end

    return targetLevel > playerLevel - 9 or targetClassification == "worldboss"
end
