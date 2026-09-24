-- DamageAbilityCrit/DAC_Name/DAC_Tar etc. below are superseded by
-- CritLogDB.records (see migrateToRecordLists), and PriestSoundFlag/
-- TankSoundFlag/MeleeSoundFlag by the CritLogDB.<Kind>DetectionMode
-- strings (see migrateDetectionModes) - kept here only as one-time
-- migration sources, never written again afterward. BossSoundFlag is the
-- odd one out: still actively read (see migrateBossModeToFlag).
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
    RollSoundFlag = true,
    GambleSoundFlag = true,
    AuraSoundFlag = true,
    BloodlustSoundFlag = true,
    InnervateSoundFlag = true,
    PowerInfusionSoundFlag = true,
    BlessingOfProtectionSoundFlag = true,
    DivineInterventionSoundFlag = true,
    ManaTideSoundFlag = true,
    SoulstoneSoundFlag = true,
    DrumsSoundFlag = true,
    PainSuppressionSoundFlag = true,
    HymnOfHopeSoundFlag = true,
    EvocationSoundFlag = true,
    MageTableSoundFlag = true,
    HealthstoneSoundFlag = true,
    PriestSoundFlag = true,
    TankSoundFlag = true,
    MeleeSoundFlag = true,
    PlayerSoundFlag = true,
    BossSoundFlag = true,
    BossKillFlag = true,
    XtremeSoundFlag = false,
    DebugFlag = false,
    MasterSoundFlag = true,
    -- Highscore List popup's "Post" dropdown/target box (see
    -- UI/MainPanel.lua's postHighscores) - remembers the last-picked
    -- channel/whisper target between sessions, same as any other setting.
    -- FOR_ME (a local print, not a real chat channel) as the default
    -- rather than a real channel: a stray click on "Post" should never
    -- spam guild/raid chat by accident.
    PostChannel = "FOR_ME",
    PostWhisperTarget = "",
}

-- Seed for CritLogDB.playerGroups on first install (migratePlayerGroups
-- below copies from this once; from then on only the CritLogDB copy is
-- read or written). Editable per character via the options panel; serves
-- as the name-roster fallback when the live class/role detection in
-- Core/CombatLog.lua can't resolve a unit token or assigned role.
local PLAYER_GROUPS_DEFAULTS = {
    dps = {
        "Schnutz", "Synday", "Kamicaze", "Alcira", "Shocksx",
        "Dripperx", "Enry", "Feniara", "Lemonsoda", "Cindarr",
        "Truffi", "Gradba", "Zoiy",
    },
    tank = { "Truby", "Ketamartin", "Hïnatahÿuuga", "Kîtten" },
    heal = { "Ilenkov", "Epyç" },
}

-- One-time migration: copies PLAYER_GROUPS_DEFAULTS into CritLogDB, so
-- they're editable per character. Guarded on CritLogDB.playerGroups
-- itself, not the schema version, so it runs exactly once regardless of
-- which version a character upgrades from.
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
-- fields, so existing highscores survive the switch to list-based
-- storage. Guarded on CritLogDB.records itself, same reasoning as
-- migratePlayerGroups above.
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

-- One-time migration: the dps/tank/heal death sounds used to be a plain
-- on/off flag; now each is a 4-way mode ("none"/"experimental"/"roster"/
-- "both", see Core/Constants.lua's detectionModes). Boss is NOT in this
-- list - it has no roster to fall back to (see migrateBossModeToFlag).
-- Guarded per-category on the new field itself; true becomes "both",
-- false becomes "none", so an existing character's prior setting
-- carries forward. Must run after migratePriestToHeal below, so
-- HealDetectionMode already has any pre-existing PriestDetectionMode
-- value by the time this runs.
local function migrateDetectionModes()
    local categories = {
        { mode = "DpsDetectionMode", oldFlag = "MeleeSoundFlag" },
        { mode = "TankDetectionMode", oldFlag = "TankSoundFlag" },
        { mode = "HealDetectionMode", oldFlag = "PriestSoundFlag" },
    }
    for _, category in ipairs(categories) do
        if CritLogDB[category.mode] == nil then
            CritLogDB[category.mode] = CritLogDB[category.oldFlag] and "both" or "none"
        end
    end
end

-- One-time migration, opposite direction from migrateDetectionModes above:
-- Boss death sound went from a detection-mode dropdown back to a plain
-- on/off flag (BossSoundFlag) - it never had a roster to fall back to.
-- Guarded on BossDetectionMode still being present, since BossSoundFlag
-- itself is never nil (it's been in DEFAULTS from the start), so the
-- usual "is the new field nil" guard doesn't apply here. Must run after
-- migrateDetectionModes above.
local function migrateBossModeToFlag()
    if CritLogDB.BossDetectionMode ~= nil then
        CritLogDB.BossSoundFlag = CritLogDB.BossDetectionMode == "both"
            or CritLogDB.BossDetectionMode == "experimental"
        CritLogDB.BossDetectionMode = nil
    end
end

-- One-time migration: PriestDetectionMode/playerGroups.priest renamed to
-- HealDetectionMode/playerGroups.heal, since healer detection became
-- role-based (any class) rather than Priest-class-based. Guarded on the
-- new name being nil, so this runs exactly once. Must run before
-- migrateDetectionModes above, so a character with an existing
-- PriestDetectionMode value carries it forward instead of that
-- migration falling back to the oldest PriestSoundFlag boolean.
local function migratePriestToHeal()
    if CritLogDB.HealDetectionMode == nil and CritLogDB.PriestDetectionMode ~= nil then
        CritLogDB.HealDetectionMode = CritLogDB.PriestDetectionMode
    end
    CritLogDB.PriestDetectionMode = nil

    if CritLogDB.playerGroups.heal == nil and CritLogDB.playerGroups.priest ~= nil then
        CritLogDB.playerGroups.heal = CritLogDB.playerGroups.priest
    end
    CritLogDB.playerGroups.priest = nil
end

-- One-time migration: the level filter used to be a single plain on/off
-- flag (AllLevel, see DEFAULTS above); now it's a separate enable
-- checkbox (LevelFilterFlag) plus a configurable slider
-- (LevelDiffThreshold), see Core/Filters.lua's passesLevelFilter.
-- LevelFilterFlag/LevelDiffThreshold are deliberately not in DEFAULTS
-- itself - that would back-fill them before this migration runs, and the
-- nil guards below would never trigger. Each field guarded independently
-- since they're two independent facts derived from the same old flag.
local function migrateAllLevelToThreshold()
    if CritLogDB.LevelDiffThreshold == nil then
        CritLogDB.LevelDiffThreshold = 9
    end

    if CritLogDB.LevelFilterFlag == nil then
        CritLogDB.LevelFilterFlag = not CritLogDB.AllLevel
    end
end

-- One-time migration: MeleeDetectionMode/playerGroups.melee renamed to
-- DpsDetectionMode/playerGroups.dps - DPS detection became the real
-- 3-role system (Tank/Healer/everyone else, see Core/Filters.lua's
-- isAssignedDps) rather than a melee-capable-class guess. Same pattern
-- and ordering reason as migratePriestToHeal above: must run before
-- migrateDetectionModes below.
local function migrateMeleeToDps()
    if CritLogDB.DpsDetectionMode == nil and CritLogDB.MeleeDetectionMode ~= nil then
        CritLogDB.DpsDetectionMode = CritLogDB.MeleeDetectionMode
    end
    CritLogDB.MeleeDetectionMode = nil

    if CritLogDB.playerGroups.dps == nil and CritLogDB.playerGroups.melee ~= nil then
        CritLogDB.playerGroups.dps = CritLogDB.playerGroups.melee
    end
    CritLogDB.playerGroups.melee = nil
end

-- Migrations, in the order they must actually run - several depend on an
-- earlier one's output (see each function's own comment above).
-- CritLogDB.SchemaVersion (see SetDefaults below) is this table's index
-- after a migration has run. Each function keeps its own internal guard
-- as a one-time bridge for characters upgrading from before
-- SchemaVersion existed at all.
local MIGRATIONS = {
    migratePlayerGroups,
    migrateToRecordLists,
    migratePriestToHeal,
    migrateMeleeToDps,
    migrateDetectionModes,
    migrateBossModeToFlag,
    migrateAllLevelToThreshold,
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

    -- No special case for a brand-new character: DEFAULTS above only
    -- back-fills scalar fields; several migrations below are the ONLY
    -- place that seed a fresh character's playerGroups roster, level
    -- filter, and dps/tank/heal detection mode. A character predating
    -- SchemaVersion entirely also defaults to 0 here, safe since every
    -- migration below still has its own internal guard. This loop runs
    -- each migration at most once per character, ever.
    CritLogDB.SchemaVersion = CritLogDB.SchemaVersion or 0
    for schemaVersion, migrate in ipairs(MIGRATIONS) do
        if CritLogDB.SchemaVersion < schemaVersion then
            migrate()
            CritLogDB.SchemaVersion = schemaVersion
        end
    end

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

    -- See UI/TitanButton.lua's RefreshTitanPanelButton - a no-op unless
    -- the optional Titan button exists, needed because Titan doesn't
    -- refresh its button text on its own.
    self:RefreshTitanPanelButton()
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

-- Adds a name to a roster category (dps/tank/heal) if it's non-empty
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
