local DEFAULTS = {
    DamageAbilityCrit = 0,
    DAC_Name = "",
    DAC_Tar = "",
    WhiteHitCrit = 0,
    WHC_Tar = "",
    HealAbilityCrit = 0,
    HAC_Name = "",
    HAC_Tar = "",
    SoundFlag = true,
    AllLevel = false,
    AllCritFlag = false,
    WhiteHitFlag = true,
    ReadySoundFlag = true,
    AuraSoundFlag = true,
    PriestSoundFlag = true,
    TankSoundFlag = true,
    MeleeSoundFlag = true,
    PlayerSoundFlag = true,
    BossSoundFlag = true,
    DeadSoundFlag = true,
    XtremeSoundFlag = false,
    DebugFlag = false,
    MasterSoundFlag = true,
}

function CritLog:SetDefaults()
    local initialized = not CritLogDB
    local upgraded = not initialized and CritLogDB.Version ~= self.version

    if initialized then
        CritLogDB = {}
    end

    if initialized or upgraded then
        for key, value in pairs(DEFAULTS) do
            if CritLogDB[key] == nil then
                CritLogDB[key] = value
            end
        end
        CritLogDB.Version = self.version
    end

    if initialized then
        print("CritLog Initialized")
        print("/cl help for list of commands")
    elseif upgraded then
        print("CritLog updated to "..self.version.." (existing data kept)")
        print("/cl help for list of commands")
    end
end

-- Clears one highscore record back to its default (0 / no name / no
-- target), leaving the other two untouched - for clearing a single
-- false-positive record instead of wiping everything via ResetRecords().
function CritLog:ResetRecord(kind)
    local fields = self.Data.records[kind]
    CritLogDB[fields.value] = 0
    if fields.name then
        CritLogDB[fields.name] = ""
    end
    CritLogDB[fields.target] = ""
end

function CritLog:ResetRecords()
    for kind in pairs(self.Data.records) do
        self:ResetRecord(kind)
    end
end
