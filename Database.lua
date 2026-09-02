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

-- One-time migration: copies CritLog.Data.playerGroups (melee/tank/priest
-- name rosters, previously code-only) into CritLogDB, so they're editable
-- per character via the options panel. Guarded on CritLogDB.playerGroups
-- itself (not the schema version) so it runs exactly once regardless of
-- which version a character upgrades from - same pattern as the DEFAULTS
-- back-fill above, just for a nested table instead of scalar fields.
-- CombatLog.lua reads only the CritLogDB copy from here on; Data.lua's
-- table is just the seed for a first-time install.
local function migratePlayerGroups()
    if CritLogDB.playerGroups then
        return
    end

    CritLogDB.playerGroups = {}
    for kind, names in pairs(CritLog.Data.playerGroups) do
        local copy = {}
        for _, name in ipairs(names) do
            table.insert(copy, name)
        end
        CritLogDB.playerGroups[kind] = copy
    end
end

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

    migratePlayerGroups()

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

-- Adds a name to a roster category (melee/tank/priest) if it's non-empty
-- and not already present. Returns true on success, false if rejected -
-- the options panel uses that to decide whether to clear the input box.
function CritLog:AddRosterName(kind, name)
    name = name:match("^%s*(.-)%s*$")
    if name == "" or tContains(CritLogDB.playerGroups[kind], name) then
        return false
    end

    table.insert(CritLogDB.playerGroups[kind], name)
    return true
end

-- Removes a single name from a roster category by its position - for
-- retiring one name (e.g. someone left the guild) without touching the
-- rest of that category's list.
function CritLog:RemoveRosterName(kind, index)
    table.remove(CritLogDB.playerGroups[kind], index)
end
