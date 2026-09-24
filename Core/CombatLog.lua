-- Combat-log event capture and decoding: reads CombatLogGetCurrentEventInfo,
-- resolves live unit state (tokens, class, role, classification), and
-- dispatches into the pure rules in Filters.lua/Records.lua. This file is
-- the "impure shell" - anything that touches the WoW API lives here, not in
-- those two.
local function endsWith(value, ending)
    return ending == "" or value:sub(-#ending) == ending
end

local function isPlayerSource(sourceGUID)
    return sourceGUID == UnitGUID("Player")
end

-- Cooldown gates for the two group-member ritual sounds below (Mage Table,
-- Warlock Healthstone ritual): every party/raid member's SPELL_CAST_SUCCESS
-- fires its own combat-log event, so without this a 5-person group would
-- play the sound 5 times for one ritual cast. Plain module-level locals,
-- not SavedVariables - resets on reload, fine for session-only spam
-- prevention.
local lastMageTableSound = 0
local lastHealthstoneSound = 0
local MAGE_TABLE_COOLDOWN_SECONDS = 100
local HEALTHSTONE_COOLDOWN_SECONDS = 60

-- Finds a live unit token for a combat-log GUID. The combat log only gives
-- us a GUID, but UnitLevel/UnitClassification need an actual unit token
-- (target, mouseover, a nameplate, ...) - there's no UnitLevel(GUID). Checks
-- the current target first (cheap, no allocation), then falls back to
-- scanning visible nameplates. Used for enemy NPC GUIDs (boss
-- classification, the damage-crit level filter) - see findGroupUnitToken
-- below for the separate group-member version.
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

-- Finds a live unit token for a GUID known to belong to a group member
-- (party/raid), independent of findUnitToken above - that one only checks
-- "target" and visible nameplates, unreliable for a raid member out of
-- nameplate range. party1-4/raid1-40 tokens resolve by roster membership
-- regardless of range or visibility.
local function findGroupUnitToken(guid)
    if UnitGUID("player") == guid then
        return "player"
    end

    for i = 1, 4 do
        local token = "party" .. i
        if UnitGUID(token) == guid then
            return token
        end
    end

    for i = 1, 40 do
        local token = "raid" .. i
        if UnitGUID(token) == guid then
            return token
        end
    end

    return nil
end

-- True if the unit currently has Feign Death active - checked live via
-- UnitBuff at the moment of death (see HandleDeath), not a cached
-- combat-log SPELL_AURA_APPLIED match, so a stale/missed cache entry
-- can't cause a false negative.
local function hasFeignDeathBuff(unit)
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
        if not name then
            return false
        end
        if CritLog.Filters.matchesSpell(CritLog.Constants.spells.feignDeath, spellId, name) then
            return true
        end
    end
    return false
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
    return CritLog.Filters.isBossClassification(classificationFor(guid))
end

-- Excludes crits against trivial ("grey") enemies from counting as
-- highscores, so a one-shot on low-level content doesn't overwrite a real
-- record from relevant content. If the hit target's unit token can't be
-- resolved (e.g. no nameplate on screen), the crit is allowed through
-- rather than silently dropped, since that's rare and losing a real record
-- is worse than occasionally counting an unverified one.
local function targetPassesLevelFilter(destGUID)
    if not CritLogDB.LevelFilterFlag then
        return true
    end

    local token = findUnitToken(destGUID)
    if not token then
        CritLog:Debug("Level filter: no unit token found for", destGUID, "- allowing crit through")
        return true
    end

    local passes = CritLog.Filters.passesLevelFilter(
        UnitLevel(token), UnitClassification(token), UnitLevel("player"),
        CritLogDB.LevelFilterFlag, CritLogDB.LevelDiffThreshold
    )
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

    local matchesSpell = CritLog.Filters.matchesSpell

    if (UnitInParty(sourceName) or UnitInRaid(sourceName)) and spellName ~= nil then
        if subevent == "SPELL_SUMMON" then
            self:Debug("SPELL_SUMMON by group member - id:", spellId, "name:", spellName)
            if CritLogDB.ManaTideSoundFlag and matchesSpell(self.Constants.spells.manaTide, spellId, spellName) then
                self:PlaySound(self.Constants.sounds.manaTide)
            end
        elseif subevent == "SPELL_CAST_SUCCESS" then
            if CritLogDB.MageTableSoundFlag
                and matchesSpell(self.Constants.spells.mageTable, spellId, spellName)
                and (GetTime() - lastMageTableSound) > MAGE_TABLE_COOLDOWN_SECONDS
            then
                lastMageTableSound = GetTime()
                self:PlaySound(self.Constants.sounds.mageTable)
            end

            if CritLogDB.HealthstoneSoundFlag
                and matchesSpell(self.Constants.spells.healthstoneRitual, spellId, spellName)
                and (GetTime() - lastHealthstoneSound) > HEALTHSTONE_COOLDOWN_SECONDS
            then
                lastHealthstoneSound = GetTime()
                self:PlaySound(self.Constants.sounds.healthstoneRitual)
            end
        end
    end

    if destGUID ~= UnitGUID("Player") or subevent ~= "SPELL_AURA_APPLIED" then
        return
    end

    self:Debug("SPELL_AURA_APPLIED on player - id:", spellId, "name:", spellName)

    -- AuraSoundFlag (checked above) is the master switch; each of these 7
    -- also has its own flag, individually toggleable in the Sound Settings
    -- panel instead of all-or-nothing.
    if CritLogDB.BloodlustSoundFlag and matchesSpell(self.Constants.spells.bloodlust, spellId, spellName) then
        self:PlaySound(self.Constants.sounds.bloodlust)
    end

    if CritLogDB.InnervateSoundFlag and matchesSpell(self.Constants.spells.innervate, spellId, spellName) then
        self:PlaySound(self.Constants.sounds.innervate)
    end

    if CritLogDB.PowerInfusionSoundFlag and matchesSpell(self.Constants.spells.powerInfusion, spellId, spellName) then
        self:PlaySound(self.Constants.sounds.powerInfusion)
    end

    if CritLogDB.BlessingOfProtectionSoundFlag
        and matchesSpell(self.Constants.spells.blessingOfProtection, spellId, spellName)
    then
        self:PlaySound(self.Constants.sounds.blessingOfProtection)
    end

    if CritLogDB.DivineInterventionSoundFlag
        and matchesSpell(self.Constants.spells.divineIntervention, spellId, spellName)
    then
        self:PlaySound(self.Constants.sounds.divineIntervention)
    end

    if CritLogDB.SoulstoneSoundFlag and matchesSpell(self.Constants.spells.soulstone, spellId, spellName) then
        self:PlaySound(self.Constants.sounds.soulstone)
    end

    if CritLogDB.DrumsSoundFlag and matchesSpell(self.Constants.spells.drums, spellId, spellName) then
        self:PlaySound(self.Constants.sounds.drums)
    end

    if CritLogDB.PainSuppressionSoundFlag
        and matchesSpell(self.Constants.spells.painSuppression, spellId, spellName)
    then
        self:PlaySound(self.Constants.sounds.painSuppression)
    end

    if CritLogDB.HymnOfHopeSoundFlag and matchesSpell(self.Constants.spells.hymnOfHope, spellId, spellName) then
        self:PlaySound(self.Constants.sounds.hymnOfHope)
    end

    if CritLogDB.EvocationSoundFlag and matchesSpell(self.Constants.spells.evocation, spellId, spellName) then
        self:PlaySound(self.Constants.sounds.evocation)
    end
end

function CritLog:HandleXtremeDamage(subevent, sourceGUID, amount)
    if isPlayerSource(sourceGUID)
        and subevent == "SPELL_DAMAGE"
        and CritLogDB.XtremeSoundFlag
        and tonumber(amount) > 9000
    then
        self:PlaySound(self.Constants.sounds.xtremeDamage)
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

        -- Checked against the current #1 before inserting, so AddRecord
        -- (which always tries to insert, even a crit that only makes 3rd
        -- place) doesn't change what counts as "new highscore" for the
        -- sound/print below.
        local damageList = CritLogDB.records.damage
        local isNewHighscore = CritLog.Records.isNewHighscore(amount, damageList[1] and damageList[1].amount or 0)
        self:AddRecord("damage", amount, spellName, destName)

        if isNewHighscore then
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

        -- A new highscore always sounds, same as ability/heal crits below -
        -- WhiteHitFlag only gates the "every crit" spam sound above, not
        -- this one.
        local whiteHitList = CritLogDB.records.whiteHit
        local isNewHighscore = CritLog.Records.isNewHighscore(amount, whiteHitList[1] and whiteHitList[1].amount or 0)
        if isNewHighscore then
            self:AddRecord("whiteHit", amount, nil, destName)
            print("DAMAGE Crit WhiteHit: "..amount.." ("..destName..")")
            if not alreadyPlayed then
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

        -- Matches SWING_DAMAGE above: AddRecord/print always happen on a
        -- new highscore, and the sound is gated only by alreadyPlayed,
        -- not WhiteHitFlag.
        local whiteHitList = CritLogDB.records.whiteHit
        local isNewHighscore = CritLog.Records.isNewHighscore(amount, whiteHitList[1] and whiteHitList[1].amount or 0)
        if isNewHighscore then
            self:AddRecord("whiteHit", amount, nil, destName)
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

    local healList = CritLogDB.records.heal
    local isNewHighscore = CritLog.Records.isNewHighscore(amount, healList[1] and healList[1].amount or 0)
    self:AddRecord("heal", amount, spellName, destName)

    if isNewHighscore then
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
    if not CritLogDB.BossKillFlag
        or not endsWith(subevent, "_DAMAGE")
        or type(overkill) ~= "number"
        or overkill <= 0
    then
        return
    end

    -- Classification-only now - the hardcoded name-list fallback (english/
    -- german) is gone, see Core/Constants.lua's bosses table.
    if isClassifiedBoss(destGUID) then
        print(sourceName.." killed "..destName)
    end
end

function CritLog:HandleDeath(subevent, destGUID, destName)
    if subevent ~= "UNIT_DIED" then
        return
    end

    -- Used both by the Feign Death check right below and the class/role
    -- checks further down. May end up nil (e.g. someone who left the
    -- group before dying) - every check below falls back to the name
    -- roster in that case, same as when the class/role check doesn't
    -- match.
    local token = findGroupUnitToken(destGUID)

    -- Feign Death fires a real UNIT_DIED for the feigning unit - checked
    -- first, before even the player's own death sound below, since a
    -- hunter feigning themselves would otherwise trigger it too.
    if token and hasFeignDeathBuff(token) then
        return
    end

    if destGUID == UnitGUID("Player") then
        if CritLogDB.PlayerSoundFlag then
            self:PlaySound(self.Constants.sounds.playerDeath)
        end
        return
    end

    -- Discard a resolved token unless it's actually a player: UnitClass()/
    -- UnitGroupRolesAssigned() aren't guaranteed nil for NPCs. Nilling it
    -- here makes every check below fall back to the name roster exactly
    -- like an unresolved token already does.
    if token and not UnitIsPlayer(token) then
        token = nil
    end

    -- Resolved once and reused by all three checks below instead of each
    -- one independently calling UnitClass/UnitGroupRolesAssigned again.
    local class, role
    if token then
        local _, unitClass = UnitClass(token)
        class = unitClass
        role = UnitGroupRolesAssigned(token)
    end

    -- The live role checks below (dps/tank/heal) are gated on group
    -- membership - without this, an enemy player in PvP or an unrelated
    -- player on a visible nameplate could trigger these sounds just
    -- because their class/role matched. The name-roster fallback below is
    -- deliberately NOT gated by this - it's an explicit named allowlist,
    -- not a live-detection heuristic that needs a sanity check.
    local isGroupMember = UnitInParty(destName) or UnitInRaid(destName)

    -- Roster-fallback safety net: an NPC (raid trash, an add, a totem,
    -- ...) can share a display name with someone in a roster - the roster
    -- check is pure name-matching with no player/NPC distinction. If
    -- findUnitToken resolves a token for the dying unit and it's
    -- definitely not a player, the roster "match" is wrong. An unresolved
    -- token can't disprove anything, so the name is still trusted.
    local rosterUnitToken = findUnitToken(destGUID)
    local rosterMatchTrustworthy = not rosterUnitToken or UnitIsPlayer(rosterUnitToken)

    -- TEMPORARY debugging aid for an intermittent false-positive DPS death
    -- sound not fully root-caused yet - a plain print(), not self:Debug(),
    -- so it isn't buried by DebugFlag's other noise. Remove (or move
    -- behind self:Debug()) once confirmed there's nothing left to find.
    if isGroupMember then
        print(
            "|cff33ff99CritLog Debug:|r HandleDeath", destName, destGUID,
            "token:", token or "none",
            "class:", class or "n/a", "role:", role or "n/a",
            "isGroupMember:", tostring(isGroupMember)
        )
    end

    -- Each category's sound has a 4-way mode: "experimental" only trusts
    -- the live check, "roster" only the name list, "both" either one,
    -- "none" never plays. See Core/Filters.lua's matchesDetectionMode.
    local matchesMode = CritLog.Filters.matchesDetectionMode

    if matchesMode(
        CritLogDB.DpsDetectionMode,
        token and isGroupMember and CritLog.Filters.isAssignedDps(role),
        rosterMatchTrustworthy and tContains(CritLogDB.playerGroups.dps, destName)
    ) then
        self:PlaySound(self.Constants.sounds.dpsDeath)
    end

    -- Plain flag, not a detection mode: no roster to fall back to, live
    -- classification is the only signal.
    if CritLogDB.BossSoundFlag and isClassifiedBoss(destGUID) then
        self:PlaySound(self.Constants.sounds.bossDeath)
    end

    if matchesMode(
        CritLogDB.TankDetectionMode,
        token and isGroupMember and CritLog.Filters.isAssignedTank(role),
        rosterMatchTrustworthy and tContains(CritLogDB.playerGroups.tank, destName)
    ) then
        self:PlaySound(self.Constants.sounds.tankDeath)
    end

    -- Healer death (CritLogDB.HealDetectionMode, renamed from
    -- PriestDetectionMode - see CHANGELOG.md and
    -- Persistence/Database.lua's migratePriestToHeal): matches the
    -- assigned Healer role (isAssignedHealer, same pattern as
    -- isAssignedTank), not a Priest-specific check - a Holy Paladin/Resto
    -- Druid/Resto Shaman death counts here exactly like a Priest's.
    if matchesMode(
        CritLogDB.HealDetectionMode,
        token and isGroupMember and CritLog.Filters.isAssignedHealer(role),
        rosterMatchTrustworthy and tContains(CritLogDB.playerGroups.heal, destName)
    ) then
        self:PlaySound(self.Constants.sounds.healDeath)
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
