local function endsWith(value, ending)
    return ending == "" or value:sub(-#ending) == ending
end

-- Spirit of Redemption is a disabled test feature (see the commented-out
-- block at the bottom of this file); its name list is kept separate and
-- untouched until that feature gets a real fix.
local SREDEMPTION_NAMES = {"Spirit of Redemption", "Geist der Erlösung"}

-- Matches a spell entry from Data.lua (see the comment there) by ID first,
-- falling back to the display name if the ID doesn't hit.
local function matchesSpell(spell, spellId, spellName)
    return tContains(spell.ids, spellId) or tContains(spell.names, spellName)
end

local function isPlayerSource(sourceGUID)
    return sourceGUID == UnitGUID("Player")
end

-- Finds a live unit token for a combat-log GUID. The combat log only gives
-- us a GUID, but UnitLevel/UnitClassification need an actual unit token
-- (target, mouseover, a nameplate, ...) - there's no UnitLevel(GUID). Checks
-- the current target first (cheap, no allocation), then falls back to
-- scanning visible nameplates.
local function findUnitToken(guid)
    if UnitGUID("target") == guid then
        return "target"
    end

    if C_NamePlate and C_NamePlate.GetNamePlates then
        for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
            local token = plate.namePlateUnitToken
            if token and UnitGUID(token) == guid then
                return token
            end
        end
    end

    return nil
end

-- Returns true if the unit's class is melee-capable, per the rules in
-- Data.lua's deathClasses.meleeCapable/alwaysMelee. Warrior and Rogue have
-- no ranged/caster spec at all, so class alone identifies them. The
-- remaining hybrid classes (Paladin, Shaman, Druid) are narrowed by
-- assigned raid role: a Healer-flagged member of one of those classes is
-- excluded, since a Holy Paladin/Restoration Shaman/Restoration Druid is
-- never in melee.
--
-- Known blind spot, accepted rather than solved: this does NOT exclude
-- ranged-caster DPS specs of those same hybrid classes (Elemental Shaman,
-- Balance Druid, ...), which will still be flagged as "melee" here. There
-- is no reliable API to tell a melee spec from a caster spec of the same
-- class for another player without inspecting talents, which isn't always
-- possible. See CHANGELOG.md.
local function isMeleeClass(token)
    local _, class = UnitClass(token)
    if not class then
        return false
    end

    if tContains(CritLog.Data.deathClasses.alwaysMelee, class) then
        return true
    end

    if not tContains(CritLog.Data.deathClasses.meleeCapable, class) then
        return false
    end

    return UnitGroupRolesAssigned(token) ~= "HEALER"
end

-- Returns true only if the unit currently has the Tank role explicitly
-- assigned (raid-frame role icons, or equivalent). Tank is a raid role,
-- not a class — a Warrior/Paladin/Druid can each be a tank or something
-- else — and UnitGroupRolesAssigned only reflects a role someone actually
-- set, which is not guaranteed. It commonly reports "NONE" for a real tank
-- who was never manually flagged, especially outside a raid.
--
-- Known blind spot, accepted rather than solved: an unassigned real tank
-- is not detected here. Deliberately not falling back to a class-based
-- guess (e.g. "Warrior with no Healer role") — that would also flag every
-- non-tanking Warrior/Paladin/Druid, trading one gap for a worse one. The
-- playerGroups.tank name-roster fallback in HandleDeath covers this gap
-- for the same handful of characters it always has. See CHANGELOG.md.
local function isAssignedTank(token)
    return UnitGroupRolesAssigned(token) == "TANK"
end

-- Straightforward class check — Priest has no role ambiguity like
-- melee/tank above.
local function isPriestClass(token)
    local _, class = UnitClass(token)
    return class ~= nil and tContains(CritLog.Data.deathClasses.priest, class)
end

-- Boss detection, part 1: remembering what a unit is while it still exists.
--
-- UnitClassification() needs a live unit token, and by the time UNIT_DIED
-- fires the unit is dead: its nameplate is gone or going, and it is only
-- still your target if you happened to be targeting it. Looking the
-- classification up at the moment of death would therefore fail most of the
-- time. Instead every NPC seen in the combat log is classified once while it
-- is still alive and fighting, keyed by GUID, and the death handler reads
-- that cache.
--
-- The cache is a plain runtime table, not SavedVariables: it describes the
-- current fight and is worthless across a reload.
local MAX_CLASSIFICATION_ATTEMPTS = 3
local CLASSIFICATION_CACHE_LIMIT = 200

local classifications = {}
local resolveAttempts = {}
local trackedGuids = 0

local function isNpcGUID(guid)
    if type(guid) ~= "string" then
        return false
    end

    return guid:sub(1, 8) == "Creature" or guid:sub(1, 7) == "Vehicle"
end

local function resetClassificationCache()
    classifications = {}
    resolveAttempts = {}
    trackedGuids = 0
end

local function forgetClassification(guid)
    if classifications[guid] ~= nil or resolveAttempts[guid] ~= nil then
        classifications[guid] = nil
        resolveAttempts[guid] = nil
        trackedGuids = trackedGuids - 1
    end
end

-- Classifies an NPC GUID once and caches the result. A GUID whose token
-- can't be resolved yet (no nameplate on screen, not targeted) is retried on
-- later combat-log events, but only a few times - otherwise every event from
-- an off-screen mob would rescan all nameplates for the rest of the fight.
local function rememberClassification(guid)
    if not isNpcGUID(guid) or classifications[guid] then
        return
    end

    local attempts = resolveAttempts[guid] or 0
    if attempts >= MAX_CLASSIFICATION_ATTEMPTS then
        return
    end

    if trackedGuids >= CLASSIFICATION_CACHE_LIMIT then
        CritLog:Debug("Classification cache full - wiping", trackedGuids, "entries")
        resetClassificationCache()
        attempts = 0
    end

    if attempts == 0 then
        trackedGuids = trackedGuids + 1
    end

    local token = findUnitToken(guid)
    if not token then
        resolveAttempts[guid] = attempts + 1
        return
    end

    resolveAttempts[guid] = nil
    classifications[guid] = UnitClassification(token)
    CritLog:Debug("Classified", guid, "as", classifications[guid], "via token", token)
end

-- Cached classification first, live lookup as a last chance (the unit may
-- still be targeted, and for a killing blow it is by definition still
-- around). nil means "couldn't tell" - never treated as a boss.
local function classificationFor(guid)
    local cached = classifications[guid]
    if cached then
        return cached
    end

    local token = findUnitToken(guid)
    return token and UnitClassification(token) or nil
end

local function isClassifiedBoss(guid)
    local classification = classificationFor(guid)

    return classification ~= nil
        and tContains(CritLog.Data.bosses.classifications, classification)
end

-- Excludes crits against trivial ("grey") enemies from counting as
-- highscores, so a one-shot on low-level content doesn't overwrite a real
-- record from relevant content. If the hit target's unit token can't be
-- resolved (e.g. no nameplate on screen), the crit is allowed through
-- rather than silently dropped, since that's rare and losing a real record
-- is worse than occasionally counting an unverified one.
local function targetPassesLevelFilter(destGUID)
    if CritLogDB.AllLevel then
        return true
    end

    local token = findUnitToken(destGUID)
    if not token then
        CritLog:Debug("Level filter: no unit token found for", destGUID, "- allowing crit through")
        return true
    end

    local passes = UnitLevel(token) > UnitLevel("player") - 9
        or UnitClassification(token) == "worldboss"
    CritLog:Debug(
        "Level filter: token", token,
        "level", UnitLevel(token),
        "classification", UnitClassification(token),
        "passes:", passes
    )
    return passes
end

function CritLog:HandleAuraSounds(
    subevent,
    sourceName,
    destGUID,
    spellId,
    spellName
)
    if not CritLogDB.AuraSoundFlag then
        return
    end

    if (UnitInParty(sourceName) or UnitInRaid(sourceName))
        and subevent == "SPELL_SUMMON"
        and spellName ~= nil
    then
        self:Debug("SPELL_SUMMON by group member - id:", spellId, "name:", spellName)
        if matchesSpell(self.Data.spells.manaTide, spellId, spellName) then
            self:PlaySound(self.Data.sounds.manaTide)
        end
    end

    if destGUID ~= UnitGUID("Player") or subevent ~= "SPELL_AURA_APPLIED" then
        return
    end

    self:Debug("SPELL_AURA_APPLIED on player - id:", spellId, "name:", spellName)

    if matchesSpell(self.Data.spells.bloodlust, spellId, spellName) then
        self:PlaySound(self.Data.sounds.bloodlust)
    end

    if matchesSpell(self.Data.spells.innervate, spellId, spellName) then
        self:PlaySound(self.Data.sounds.innervate)
    end

    if matchesSpell(self.Data.spells.powerInfusion, spellId, spellName) then
        self:PlaySound(self.Data.sounds.powerInfusion)
    end

    if matchesSpell(self.Data.spells.blessingOfProtection, spellId, spellName) then
        self:PlaySound(self.Data.sounds.blessingOfProtection)
    end

    if matchesSpell(self.Data.spells.divineIntervention, spellId, spellName) then
        self:PlaySound(self.Data.sounds.divineIntervention)
    end

    if matchesSpell(self.Data.spells.soulstone, spellId, spellName) then
        self:PlaySound(self.Data.sounds.soulstone)
    end
end

function CritLog:HandleXtremeDamage(subevent, sourceGUID, amount)
    if isPlayerSource(sourceGUID)
        and subevent == "SPELL_DAMAGE"
        and CritLogDB.XtremeSoundFlag
        and tonumber(amount) > 9000
    then
        self:PlaySound(self.Data.sounds.xtremeDamage)
    end
end

function CritLog:HandleDamageCrit(
    subevent,
    destGUID,
    destName,
    amount,
    spellName,
    isCritical
)
    if not targetPassesLevelFilter(destGUID) then
        return
    end

    if subevent == "SPELL_DAMAGE" then
        if not isCritical then
            return
        end

        if CritLogDB.AllCritFlag then
            self:PlayCritSound()
        end

        if amount > CritLogDB.DamageAbilityCrit then
            CritLogDB.DamageAbilityCrit = amount
            CritLogDB.DAC_Name = spellName
            CritLogDB.DAC_Tar = destName
            print("DAMAGE Crit "..spellName..": "..amount.." ("..destName..")")
            self:PlayCritSound()
        end
        return
    end

    if subevent == "SWING_DAMAGE" then
        if not isCritical then
            return
        end

        -- Played at most once per event: without this flag, a white hit
        -- that both passes the "every crit" check below and turns out to
        -- be a new highscore played the same sound twice in a row.
        local alreadyPlayed = false
        if CritLogDB.AllCritFlag and CritLogDB.WhiteHitFlag then
            self:PlayCritSound()
            alreadyPlayed = true
        end

        if amount > CritLogDB.WhiteHitCrit then
            CritLogDB.WhiteHitCrit = amount
            CritLogDB.WHC_Tar = destName
            print("DAMAGE Crit WhiteHit: "..amount.." ("..destName..")")
            if CritLogDB.WhiteHitFlag and not alreadyPlayed then
                self:PlayCritSound()
            end
        end
        return
    end

    if subevent == "RANGE_DAMAGE" and isCritical then
        -- Same double-play fix as SWING_DAMAGE above.
        local alreadyPlayed = false
        if CritLogDB.AllCritFlag then
            self:PlayCritSound()
            alreadyPlayed = true
        end

        if amount > CritLogDB.WhiteHitCrit and CritLogDB.WhiteHitFlag then
            CritLogDB.WhiteHitCrit = amount
            CritLogDB.WHC_Tar = destName
            print("DAMAGE Crit WhiteHit: "..amount.." ("..destName..")")
            if not alreadyPlayed then
                self:PlayCritSound()
            end
        end
    end
end

function CritLog:HandleHealCrit(
    subevent,
    destName,
    amount,
    spellName,
    isCritical
)
    if subevent ~= "SPELL_HEAL" or not isCritical then
        return
    end

    if CritLogDB.AllCritFlag then
        self:PlayCritSound()
    end

    if amount > CritLogDB.HealAbilityCrit then
        CritLogDB.HealAbilityCrit = amount
        CritLogDB.HAC_Name = spellName
        CritLogDB.HAC_Tar = destName
        print("HEAL Crit "..spellName..": "..amount.." ("..destName..")")
        self:PlayCritSound()
    end
end

function CritLog:PrintBossKillingBlow(
    subevent,
    sourceName,
    destGUID,
    destName,
    overkill
)
    -- Cheap checks first: this runs on every combat-log event, and the boss
    -- check below can scan nameplates. The type() guard is new - `overkill`
    -- is read positionally and isn't guaranteed to be a number for every
    -- subevent ending in "_DAMAGE" (see docs/BEHAVIOR.md), and comparing a
    -- non-number to 0 is a Lua error.
    if not endsWith(subevent, "_DAMAGE")
        or type(overkill) ~= "number"
        or overkill <= 0
    then
        return
    end

    -- Name fallback now checks both languages, same as the death-sound
    -- check below - was English-only, a pre-existing asymmetry with no
    -- reason behind it (both lists have always existed side by side).
    if isClassifiedBoss(destGUID)
        or tContains(self.Data.bosses.english, destName)
        or tContains(self.Data.bosses.german, destName)
    then
        print(sourceName.." killed "..destName)
    end
end

function CritLog:HandleDeath(subevent, destGUID, destName)
    if subevent ~= "UNIT_DIED" then
        return
    end

    if not CritLogDB.DeadSoundFlag then
        -- Sounds are off, but the GUID is still done for classification
        -- purposes: drop it now instead of leaving it in the cache.
        forgetClassification(destGUID)
        return
    end

    if destGUID == UnitGUID("Player") then
        if CritLogDB.PlayerSoundFlag then
            self:PlaySound(self.Data.sounds.playerDeath)
        end
        return
    end

    -- Live unit token for the dying player, used by the class/role checks
    -- below. May be nil (e.g. no nameplate on screen and not the current
    -- target) — every check below falls back to the legacy name roster
    -- when that happens, same as when the token resolves but the
    -- class/role check itself doesn't match.
    local token = findUnitToken(destGUID)

    -- Discard a resolved token unless it's actually a player: UnitClass()/
    -- UnitGroupRolesAssigned() aren't guaranteed nil for NPCs (some enemy
    -- units carry a class internally for combat/AI purposes), which let
    -- enemy deaths in instances - a Necromancer trash mob at Mount Hyjal,
    -- reported in-game - wrongly trigger the melee/tank/priest death
    -- sounds. Nilling it here makes every check below fall back to the
    -- name roster exactly like an unresolved token already does.
    if token and not UnitIsPlayer(token) then
        token = nil
    end

    if CritLogDB.MeleeSoundFlag
        and (
            (token and isMeleeClass(token))
            or tContains(CritLogDB.playerGroups.melee, destName)
        )
    then
        self:PlaySound(self.Data.sounds.meleeDeath)
    end

    if CritLogDB.BossSoundFlag
        and (
            isClassifiedBoss(destGUID)
            or tContains(self.Data.bosses.english, destName)
            or tContains(self.Data.bosses.german, destName)
        )
    then
        self:PlaySound(self.Data.sounds.bossDeath)
    end

    if CritLogDB.TankSoundFlag
        and (
            (token and isAssignedTank(token))
            or tContains(CritLogDB.playerGroups.tank, destName)
        )
    then
        self:PlaySound(self.Data.sounds.tankDeath)
    end

    if CritLogDB.PriestSoundFlag
        and (
            (token and isPriestClass(token))
            or tContains(CritLogDB.playerGroups.priest, destName)
        )
    then
        self:PlaySound(self.Data.sounds.priestDeath)
    end

    -- The classification (if any) has now been read for the boss check
    -- above; the GUID belongs to a dead unit and won't be looked up again.
    forgetClassification(destGUID)
end

function CritLog:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName,
        _, _, sv1, sv2, _, sv4, sv5, _, sv7, _, _, sv10 =
        CombatLogGetCurrentEventInfo()

    -- Boss detection, part 2: feed the cache from both sides of every
    -- combat-log event, not just NPCs the player is hitting. A boss that is
    -- only ever attacking (not being attacked by the player, e.g. it's
    -- fighting another party member) still needs to end up classified
    -- before it dies. rememberClassification() is cheap once a GUID is
    -- cached or has exhausted its retry attempts, so calling it twice per
    -- event here doesn't add meaningful overhead to this hot path.
    rememberClassification(sourceGUID)
    rememberClassification(destGUID)

    self:HandleAuraSounds(subevent, sourceName, destGUID, sv1, sv2)
    self:HandleXtremeDamage(subevent, sourceGUID, sv4)

    if isPlayerSource(sourceGUID) then
        if subevent == "SWING_DAMAGE" then
            self:HandleDamageCrit(subevent, destGUID, destName, sv1, nil, sv7)
        else
            self:HandleDamageCrit(subevent, destGUID, destName, sv4, sv2, sv10)
        end
        self:HandleHealCrit(subevent, destName, sv4, sv2, sv7)
    end

    self:PrintBossKillingBlow(subevent, sourceName, destGUID, destName, sv5)
    self:HandleDeath(subevent, destGUID, destName)
end

--
-- Spirit of Redemtption TEST ------not working
--
--if Split(sourceGUID, "-")[1] == "Player" then
--    if subevent == "SPELL_AURA_APPLIED" then
--        if tContains( SREDEMPTION_NAMES, sv2 ) then
--            tmpRNDM = math.random(1, 2)
--            print("SPIRIT OF REDEMPTION SCRIPT WORKING----- TELL ME IF IT DOES Cause i thinks it's not")
--        end
--    end
--end
