local function endsWith(value, ending)
    return ending == "" or value:sub(-#ending) == ending
end

-- Spirit of Redemption is a disabled test feature (see the commented-out
-- block at the bottom of this file); its name list is kept separate and
-- untouched until that feature gets a real fix.
local SREDEMPTION_NAMES = {"Spirit of Redemption", "Geist der Erlösung"}

local function randomEntry(values)
    return values[math.random(1, #values)]
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
        return true
    end

    return UnitLevel(token) > UnitLevel("player") - 9
        or UnitClassification(token) == "worldboss"
end

function CritLog:HandleAuraSounds(subevent, sourceName, destGUID, spellName)
    if not CritLogDB.AuraSoundFlag then
        return
    end

    if (UnitInParty(sourceName) or UnitInRaid(sourceName))
        and subevent == "SPELL_SUMMON"
        and spellName ~= nil
        and tContains(self.Data.spells.manaTide, spellName)
    then
        self:PlaySound(self.Data.sounds.manaTide)
    end

    if destGUID ~= UnitGUID("Player") or subevent ~= "SPELL_AURA_APPLIED" then
        return
    end

    if tContains(self.Data.spells.bloodlust, spellName) then
        self:PlaySound(self.Data.sounds.bloodlust)
    end

    if tContains(self.Data.spells.innervate, spellName) then
        self:PlaySound(randomEntry(self.Data.sounds.innervate))
    end

    if tContains(self.Data.spells.powerInfusion, spellName) then
        self:PlaySound(self.Data.sounds.powerInfusion)
    end

    if tContains(self.Data.spells.blessingOfProtection, spellName) then
        self:PlaySound(self.Data.sounds.blessingOfProtection)
    end

    if tContains(self.Data.spells.divineIntervention, spellName) then
        self:PlaySound(self.Data.sounds.divineIntervention)
    end

    if tContains(self.Data.spells.soulstone, spellName) then
        self:PlaySound(randomEntry(self.Data.sounds.soulstone))
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

        if CritLogDB.AllCritFlag and CritLogDB.WhiteHitFlag then
            self:PlayCritSound()
        end

        if amount > CritLogDB.WhiteHitCrit then
            CritLogDB.WhiteHitCrit = amount
            CritLogDB.WHC_Tar = destName
            print("DAMAGE Crit WhiteHit: "..amount.." ("..destName..")")
            if CritLogDB.WhiteHitFlag then
                self:PlayCritSound()
            end
        end
        return
    end

    if subevent == "RANGE_DAMAGE" and isCritical then
        if CritLogDB.AllCritFlag then
            self:PlayCritSound()
        end

        if amount > CritLogDB.WhiteHitCrit and CritLogDB.WhiteHitFlag then
            CritLogDB.WhiteHitCrit = amount
            CritLogDB.WHC_Tar = destName
            print("DAMAGE Crit WhiteHit: "..amount.." ("..destName..")")
            self:PlayCritSound()
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
    destName,
    overkill
)
    if tContains(self.Data.bosses.english, destName)
        and endsWith(subevent, "_DAMAGE")
        and overkill
        and overkill > 0
    then
        print(sourceName.." killed "..destName)
    end
end

function CritLog:HandleDeath(subevent, destGUID, destName)
    if subevent ~= "UNIT_DIED" or not CritLogDB.DeadSoundFlag then
        return
    end

    if destGUID == UnitGUID("Player") then
        if CritLogDB.PlayerSoundFlag then
            self:PlaySound(self.Data.sounds.playerDeath)
        end
        return
    end

    if CritLogDB.MeleeSoundFlag
        and tContains(self.Data.playerGroups.melee, destName)
    then
        if destName == "Schnutz" then
            self:PlaySound(self.Data.sounds.meleeDeathSchnutz)
        else
            self:PlaySound(self.Data.sounds.meleeDeath)
        end
    end

    if CritLogDB.BossSoundFlag
        and (
            tContains(self.Data.bosses.english, destName)
            or tContains(self.Data.bosses.german, destName)
        )
    then
        self:PlaySound(randomEntry(self.Data.sounds.bossDeath))
    end

    if CritLogDB.TankSoundFlag
        and tContains(self.Data.playerGroups.tank, destName)
    then
        self:PlaySound(self.Data.sounds.tankDeath)
    end

    if CritLogDB.PriestSoundFlag
        and tContains(self.Data.playerGroups.priest, destName)
    then
        self:PlaySound(randomEntry(self.Data.sounds.priestDeath))
    end
end

function CritLog:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName,
        _, _, sv1, sv2, _, sv4, sv5, _, sv7, _, _, sv10 =
        CombatLogGetCurrentEventInfo()

    self:HandleAuraSounds(subevent, sourceName, destGUID, sv2)
    self:HandleXtremeDamage(subevent, sourceGUID, sv4)

    if isPlayerSource(sourceGUID) then
        if subevent == "SWING_DAMAGE" then
            self:HandleDamageCrit(subevent, destGUID, destName, sv1, nil, sv7)
        else
            self:HandleDamageCrit(subevent, destGUID, destName, sv4, sv2, sv10)
        end
        self:HandleHealCrit(subevent, destName, sv4, sv2, sv7)
    end

    self:PrintBossKillingBlow(subevent, sourceName, destName, sv5)
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
