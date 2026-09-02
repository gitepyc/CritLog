-- DamageAbilityCrit/DAC_Name/DAC_Tar etc. below are the old single-value
-- highscore fields, superseded by the CritLogDB.records lists (see
-- migrateToRecordLists below) but kept in DEFAULTS - and never actively
-- written again after migration - purely so an old SavedVariables file
-- never produces a nil field if something still reads them.
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

-- Seed for CritLogDB.playerGroups on first install (migratePlayerGroups
-- below copies from this once; from then on only the CritLogDB copy is
-- read or written - see Core/CombatLog.lua). Originally a fixed, code-only
-- roster tied to one specific historical raid group; now editable per
-- character via the options panel. As of the class/role-based matching in
-- Core/CombatLog.lua (see Core/Constants.lua's deathClasses), these are no
-- longer the primary check — they're kept as a fallback, same
-- ID-first-then-name-fallback pattern used for spells in Core/Constants.lua:
-- class/role detection needs a live unit token and (for tank) an explicitly
-- assigned raid role, neither of which is guaranteed available, so a name
-- still in this list keeps firing even when the live check can't.
local PLAYER_GROUPS_DEFAULTS = {
    melee = {
        "Schnutz", "Synday", "Kamicaze", "Alcira", "Shocksx",
        "Dripperx", "Enry", "Feniara", "Lemonsoda", "Cindarr",
        "Truffi", "Gradba", "Zoiy",
    },
    tank = { "Truby", "Ketamartin", "Hïnatahÿuuga", "Kîtten" },
    priest = { "Ilenkov", "Epyç" },
}

-- One-time migration: copies PLAYER_GROUPS_DEFAULTS (melee/tank/priest name
-- rosters, previously code-only) into CritLogDB, so they're editable per
-- character via the options panel. Guarded on CritLogDB.playerGroups itself
-- (not the schema version) so it runs exactly once regardless of which
-- version a character upgrades from - same pattern as the DEFAULTS
-- back-fill above, just for a nested table instead of scalar fields.
local function migratePlayerGroups()
    if CritLogDB.playerGroups then
        return
    end

    CritLogDB.playerGroups = {}
    for kind, names in pairs(PLAYER_GROUPS_DEFAULTS) do
        local copy = {}
        for _, name in ipairs(names) do
            table.insert(copy, name)
        end
        CritLogDB.playerGroups[kind] = copy
    end
end

-- One-time migration: seeds CritLogDB.records from the old single-value
-- fields, so existing highscores survive the switch to list-based storage.
-- Guarded on CritLogDB.records itself (not the schema version) so it runs
-- exactly once per character regardless of how many versions they skip -
-- same pattern as migratePlayerGroups above.
local function migrateToRecordLists()
    if CritLogDB.records then
        return
    end

    CritLogDB.records = { damage = {}, whiteHit = {}, heal = {} }

    if CritLogDB.DamageAbilityCrit and CritLogDB.DamageAbilityCrit > 0 then
        table.insert(CritLogDB.records.damage, {
            amount = CritLogDB.DamageAbilityCrit,
            name = CritLogDB.DAC_Name,
            target = CritLogDB.DAC_Tar,
        })
    end
    if CritLogDB.WhiteHitCrit and CritLogDB.WhiteHitCrit > 0 then
        table.insert(CritLogDB.records.whiteHit, {
            amount = CritLogDB.WhiteHitCrit,
            target = CritLogDB.WHC_Tar,
        })
    end
    if CritLogDB.HealAbilityCrit and CritLogDB.HealAbilityCrit > 0 then
        table.insert(CritLogDB.records.heal, {
            amount = CritLogDB.HealAbilityCrit,
            name = CritLogDB.HAC_Name,
            target = CritLogDB.HAC_Tar,
        })
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
    migrateToRecordLists()

    if initialized then
        print("CritLog Initialized")
        print("/cl help for list of commands")
    elseif upgraded then
        print("CritLog updated to "..self.version.." (existing data kept)")
        print("/cl help for list of commands")
    end
end

-- Inserts a new crit into a category's list, sorted highest-first, capped
-- at Constants.maxTrackedEntries (more than what's actually displayed -
-- see UI/MainPanel.lua's Constants.maxDisplayEntries). Always attempted
-- (not just for a new #1), so a crit that only beats the 3rd-best still
-- earns its spot - the caller checks list[1] before/after to detect an
-- actual new highscore itself (see Core.CombatLog's
-- HandleDamageCrit/HandleHealCrit).
function CritLog:AddRecord(kind, amount, name, target)
    local list = CritLogDB.records[kind]
    table.insert(list, { amount = amount, name = name, target = target })
    table.sort(list, function(a, b) return a.amount > b.amount end)
    while #list > self.Constants.maxTrackedEntries do
        table.remove(list)
    end
end

-- Removes a single entry from a category's list by its position (1 =
-- highest) - for discarding one false positive without touching the rest.
function CritLog:RemoveRecordEntry(kind, index)
    table.remove(CritLogDB.records[kind], index)
end

-- Clears an entire category's list - for `/cl reset damage|whitehit|heal`
-- and the main panel's per-category Reset button. Individual-entry
-- removal is RemoveRecordEntry above.
function CritLog:ResetRecord(kind)
    CritLogDB.records[kind] = {}
end

function CritLog:ResetRecords()
    for kind in pairs(CritLogDB.records) do
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

-- Renames the name at a given position in place, e.g. fixing a typo or a
-- character rename, without a remove-then-re-add round trip. Same
-- trim/empty/duplicate rules as AddRosterName, except a name matching
-- itself at its own position isn't treated as a duplicate. Returns true on
-- success, false if rejected - the options panel uses that to snap the
-- edit box back to the stored value instead of keeping the rejected text.
function CritLog:RenameRosterName(kind, index, name)
    name = name:match("^%s*(.-)%s*$")
    if name == "" then
        return false
    end

    local list = CritLogDB.playerGroups[kind]
    for i, existing in ipairs(list) do
        if i ~= index and existing == name then
            return false
        end
    end

    list[index] = name
    return true
end
