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

-- Spirit of Redemption negates the killing blow: the priest's death is
-- delayed 15s (spirit form), so the eventual UNIT_DIED has no signal of its
-- own tying it back to the talent - the buff application is the only
-- moment the game tells us this death is coming. Cached by GUID here (not
-- restricted to the player - any priest in the raid can proc it) and read
-- back once in HandleDeath, then cleared.
local spiritOfRedemptionGuids = {}

local function rememberSpiritOfRedemption(subevent, destGUID, spellId, spellName)
    if subevent == "SPELL_AURA_APPLIED"
        and CritLog.Filters.matchesSpell(CritLog.Constants.spells.spiritOfRedemption, spellId, spellName)
    then
        spiritOfRedemptionGuids[destGUID] = true
    end
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
    if CritLogDB.AllLevel then
        return true
    end

    local token = findUnitToken(destGUID)
    if not token then
        CritLog:Debug("Level filter: no unit token found for", destGUID, "- allowing crit through")
        return true
    end

    local passes = CritLog.Filters.passesLevelFilter(
        UnitLevel(token), UnitClassification(token), UnitLevel("player"), CritLogDB.AllLevel
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

    if (UnitInParty(sourceName) or UnitInRaid(sourceName))
        and subevent == "SPELL_SUMMON"
        and spellName ~= nil
    then
        self:Debug("SPELL_SUMMON by group member - id:", spellId, "name:", spellName)
        if CritLogDB.ManaTideSoundFlag and matchesSpell(self.Constants.spells.manaTide, spellId, spellName) then
            self:PlaySound(self.Constants.sounds.manaTide)
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

        local whiteHitList = CritLogDB.records.whiteHit
        local isNewHighscore = CritLog.Records.isNewHighscore(amount, whiteHitList[1] and whiteHitList[1].amount or 0)
        if isNewHighscore then
            self:AddRecord("whiteHit", amount, nil, destName)
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

        local whiteHitList = CritLogDB.records.whiteHit
        local isNewHighscore = CritLog.Records.isNewHighscore(amount, whiteHitList[1] and whiteHitList[1].amount or 0)
        if isNewHighscore and CritLogDB.WhiteHitFlag then
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
        or tContains(self.Constants.bosses.english, destName)
        or tContains(self.Constants.bosses.german, destName)
    then
        print(sourceName.." killed "..destName)
    end
end

function CritLog:HandleDeath(subevent, destGUID, destName)
    if subevent ~= "UNIT_DIED" then
        return
    end

    if destGUID == UnitGUID("Player") then
        if CritLogDB.PlayerSoundFlag then
            self:PlaySound(self.Constants.sounds.playerDeath)
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

    -- Resolved once and reused by all three checks below instead of each
    -- one independently calling UnitClass/UnitGroupRolesAssigned again.
    local class, role
    if token then
        local _, unitClass = UnitClass(token)
        class = unitClass
        role = UnitGroupRolesAssigned(token)
    end

    -- The live class/role checks below (melee/tank/priest, and Spirit of
    -- Redemption) are gated on group membership - without this, any player
    -- death that happens to resolve a unit token (e.g. an enemy player in
    -- PvP, or an unrelated player on a visible nameplate) could trigger
    -- these sounds just because their class/role matched, even though
    -- they're nobody in your group. Checked by name (works whether or not
    -- a token resolved), same as the Mana Tide Totem check in
    -- HandleAuraSounds. The name-roster fallback below is deliberately NOT
    -- gated by this - it's an explicit named allowlist of real people, not
    -- a live-detection heuristic that needs a sanity check.
    local isGroupMember = UnitInParty(destName) or UnitInRaid(destName)

    -- Each category's sound now has a 4-way mode instead of a plain
    -- on/off flag: "experimental" only trusts the live check, "roster"
    -- only the name list, "both" either one (the original default
    -- behavior), "none" (or anything else) never plays. See
    -- Core/Filters.lua's matchesDetectionMode.
    local matchesMode = CritLog.Filters.matchesDetectionMode

    if matchesMode(
        CritLogDB.MeleeDetectionMode,
        token and isGroupMember and CritLog.Filters.isMeleeClass(class, role),
        tContains(CritLogDB.playerGroups.melee, destName)
    ) then
        self:PlaySound(self.Constants.sounds.meleeDeath)
    end

    if matchesMode(
        CritLogDB.BossDetectionMode,
        isClassifiedBoss(destGUID),
        tContains(self.Constants.bosses.english, destName) or tContains(self.Constants.bosses.german, destName)
    ) then
        self:PlaySound(self.Constants.sounds.bossDeath)
    end

    if matchesMode(
        CritLogDB.TankDetectionMode,
        token and isGroupMember and CritLog.Filters.isAssignedTank(role),
        tContains(CritLogDB.playerGroups.tank, destName)
    ) then
        self:PlaySound(self.Constants.sounds.tankDeath)
    end

    -- Spirit of Redemption and the plain priest-death sound share the same
    -- mode gate - whether the priest sound plays at all is still decided
    -- by CritLogDB.PriestDetectionMode, same as the other three categories.
    -- Which of the two files plays is a separate, exclusive choice once
    -- that's already true (both currently point at the same file anyway,
    -- see Core/Constants.lua, so playing both would just double it).
    -- isGroupMember gates Spirit of Redemption too - the buff-apply
    -- tracking in rememberSpiritOfRedemption has no way to know who's in
    -- your group at that earlier point, so the check happens here instead.
    if matchesMode(
        CritLogDB.PriestDetectionMode,
        token and isGroupMember and CritLog.Filters.isPriestClass(class),
        tContains(CritLogDB.playerGroups.priest, destName)
    ) then
        if spiritOfRedemptionGuids[destGUID] and isGroupMember then
            self:PlaySound(self.Constants.sounds.spiritOfRedemption)
        else
            self:PlaySound(self.Constants.sounds.priestDeath)
        end
    end
    spiritOfRedemptionGuids[destGUID] = nil

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
    rememberSpiritOfRedemption(subevent, destGUID, sv1, sv2)

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
