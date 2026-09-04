-- DamageAbilityCrit/DAC_Name/DAC_Tar etc. below are the old single-value
-- highscore fields, superseded by the CritLogDB.records lists (see
-- migrateToRecordLists below) but kept in DEFAULTS - and never actively
-- written again after migration - purely so an old SavedVariables file
-- never produces a nil field if something still reads them. Same reasoning
-- for PriestSoundFlag/TankSoundFlag/MeleeSoundFlag, now superseded by the
-- CritLogDB.<Kind>DetectionMode strings (see migrateDetectionModes below).
-- BossSoundFlag is the odd one out: still actively read (see
-- migrateBossModeToFlag below) - Boss went to a detection mode and back.
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
    -- Independent of PriestDetectionMode now - see Core/CombatLog.lua's
    -- HandleDeath. Plain flag, not a detection mode: there is no roster/
    -- name-list equivalent for "this priest's death was Spirit-of-
    -- Redemption-delayed", the buff-apply cache is the only signal.
    SpiritSoundFlag = true,
    BossSoundFlag = true,
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
    -- Key is `dps`, not `melee` (see migrateMeleeToDps below for the
    -- rename of an already-existing character's data) - this seed only
    -- ever runs for a brand-new install, which always gets the current
    -- key name directly.
    dps = {
        "Schnutz", "Synday", "Kamicaze", "Alcira", "Shocksx",
        "Dripperx", "Enry", "Feniara", "Lemonsoda", "Cindarr",
        "Truffi", "Gradba", "Zoiy",
    },
    tank = { "Truby", "Ketamartin", "Hïnatahÿuuga", "Kîtten" },
    -- Key is `heal`, not `priest` (see migratePriestToHeal below for the
    -- rename of an already-existing character's data) - this seed only
    -- ever runs for a brand-new install, which always gets the current
    -- key name directly.
    heal = { "Ilenkov", "Epyç" },
}

-- One-time migration: copies PLAYER_GROUPS_DEFAULTS (dps/tank/heal name
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

-- One-time migration: the dps/tank/heal death sounds used to be a plain
-- on/off flag; now each is a 4-way mode ("none"/"experimental"/"roster"/
-- "both", see Core/Constants.lua's detectionModes and Core/Filters.lua's
-- matchesDetectionMode). Boss is deliberately NOT in this list - it never
-- had a roster to fall back to (see migrateBossModeToFlag below for its
-- own, opposite-direction migration) - Guarded per-category on the new
-- field itself, same pattern as the other migrations above - true becomes
-- "both" (live check with roster fallback, the original default
-- behavior), false becomes "none". Reads the old flag rather than a
-- hardcoded default so an existing character who had e.g. tank sounds
-- turned off keeps them off after upgrading. Run after migratePriestToHeal
-- below, so HealDetectionMode already has any pre-existing
-- PriestDetectionMode value by the time this runs - PriestSoundFlag here
-- is only the oldest generation's fallback (a character that never even
-- reached the PriestDetectionMode era).
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
-- on/off flag (BossSoundFlag) - it never had a roster to fall back to (see
-- Core/Constants.lua's bosses table and UI/DeathSoundPanel.lua), so
-- "Roster"/"Both" on that row were dead options. Guarded on
-- BossDetectionMode still being present (unlike every other migration
-- here, BossSoundFlag itself is never nil - it's been in DEFAULTS from
-- the start - so the usual "is the new field nil" guard doesn't work; the
-- old field's presence is the only signal that this hasn't run yet).
-- Must run after migrateDetectionModes above so a character upgrading
-- from the oldest BossSoundFlag-only era already has a BossDetectionMode
-- value to read here, same as every other era.
local function migrateBossModeToFlag()
    if CritLogDB.BossDetectionMode ~= nil then
        CritLogDB.BossSoundFlag = CritLogDB.BossDetectionMode == "both"
            or CritLogDB.BossDetectionMode == "experimental"
        CritLogDB.BossDetectionMode = nil
    end
end

-- One-time migration: PriestDetectionMode/playerGroups.priest renamed to
-- HealDetectionMode/playerGroups.heal for naming consistency - healer
-- detection became role-based (any class) rather than Priest-class-based,
-- so keeping "Priest" in the field/key name was misleading (see
-- CHANGELOG.md). Guarded on the new name being nil, not the old one's
-- absence, so this runs exactly once regardless of what an upgrading
-- character already has. Must run before migrateDetectionModes above, so
-- a character that already has a real PriestDetectionMode value (not just
-- the oldest PriestSoundFlag boolean) carries it forward instead of that
-- migration falling back to the boolean. The old names are cleared here
-- rather than left as orphaned clutter, unlike some other superseded
-- fields in DEFAULTS above - those are still read as a migration source by
-- name elsewhere, these two are not (nothing reads
-- PriestDetectionMode/playerGroups.priest ever again after this point).
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
-- flag (AllLevel, see DEFAULTS above); now it's a separate enable checkbox
-- (LevelFilterFlag) plus a configurable slider (LevelDiffThreshold)
-- replacing the hardcoded "9" a trivial/grey target used to be compared
-- against - see Core/Filters.lua's passesLevelFilter and CHANGELOG.md.
-- Deliberately not in DEFAULTS itself (same reason HealDetectionMode
-- isn't, see migratePriestToHeal above): being in DEFAULTS would
-- back-fill these before this migration runs, and the nil guards below
-- would never trigger. AllLevel stays in DEFAULTS purely as a migration
-- source, same pattern as the MeleeSoundFlag/TankSoundFlag/etc. flags
-- above - never read again after this. Each field guarded independently
-- (not a single combined guard) since they're two independent facts
-- derived from the same old flag, not one field being renamed.
local function migrateAllLevelToThreshold()
    if CritLogDB.LevelDiffThreshold == nil then
        CritLogDB.LevelDiffThreshold = 9
    end

    if CritLogDB.LevelFilterFlag == nil then
        CritLogDB.LevelFilterFlag = not CritLogDB.AllLevel
    end
end

-- One-time migration: MeleeDetectionMode/playerGroups.melee renamed to
-- DpsDetectionMode/playerGroups.dps - DPS detection stopped being a
-- melee-capable-class guess (which silently never fired for Hunter/Mage/
-- Warlock/Priest at all) and became the real 3-role system instead
-- (Tank/Healer/everyone else, see Core/Filters.lua's isAssignedDps), so
-- keeping "Melee" in the field/key name was actively misleading. Same
-- pattern as migratePriestToHeal above, and must run before
-- migrateDetectionModes below for the same reason: a character already on
-- a real MeleeDetectionMode value (not just the oldest MeleeSoundFlag
-- boolean) needs to carry it forward before that generic migration's
-- nil-check would otherwise fall back to the boolean.
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
    migratePriestToHeal()
    migrateMeleeToDps()
    migrateDetectionModes()
    migrateBossModeToFlag()
    migrateAllLevelToThreshold()

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
