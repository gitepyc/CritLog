-- Luacheck config for CritLog.
--
-- WoW's client runs Lua 5.1 with a sandboxed standard library plus its own
-- large C API. Rather than importing a generic multi-thousand-entry globals
-- list, `stds.wow` below only lists the API surface CritLog actually calls.
-- Extend it when new API calls are added.

stds.wow = {
    read_globals = {
        -- WoW client API used by the addon modules
        "CreateFrame",
        "CombatLogGetCurrentEventInfo",
        "PlaySoundFile",
        "UnitClass", -- class/role-based death-sound matching (feature/class-based-death-sounds)
        "UnitClassification",
        "UnitGUID",
        "UnitGroupRolesAssigned", -- class/role-based death-sound matching (feature/class-based-death-sounds)
        "UnitInParty",
        "UnitInRaid",
        "UnitLevel",
        "tContains",
        "GetAddOnMetadata",
        "C_AddOns",
        "C_NamePlate",
        -- Options.lua: parent frame for the standalone options panel
        "UIParent",
    },
    globals = {
        -- Blizzard slash-command convention: SlashCmdList is a client-owned
        -- global table that addons register new keys into.
        "SlashCmdList",
    },
}

std = "lua51+wow"

-- Long hard-coded name/boss lists are one-liners by nature; wrapping them
-- would hurt readability more than it helps.
max_line_length = false

-- CritLog uses Lua's colon-method OOP idiom throughout (function
-- CritLog:Foo()); most handlers don't need self, and that's expected for
-- event-dispatch-style methods, not a defect to fix line by line.
self = false

globals = {
    "SlashCmdList",
    -- Every module contributes fields/methods to these two shared tables
    -- (the addon namespace and its SavedVariables), so both need to be
    -- mutable everywhere, not just in the one file that first creates them.
    "CritLog",
    "CritLogDB",
}

files["Commands.lua"] = {
    -- Slash-command names are required globals under Blizzard's convention.
    globals = {
        "SLASH_CRITLOG1",
        "SLASH_CRITLOG2",
    },
}

exclude_files = {
    "tests/lint/*",
}
