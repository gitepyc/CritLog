-- Luacheck config for CritLog.
--
-- WoW's client runs Lua 5.1 with a sandboxed standard library plus its own
-- large C API. Rather than importing a generic multi-thousand-entry globals
-- list, `stds.wow` below only lists the API surface CritLog actually calls,
-- cross-checked against CritLog.lua. Extend it when new API calls are added.

stds.wow = {
    read_globals = {
        -- WoW client API used by CritLog.lua
        "CreateFrame",
        "CombatLogGetCurrentEventInfo",
        "PlaySoundFile",
        "GetRealZoneText",
        "GetSubZoneText",
        "UnitClassification",
        "UnitGUID",
        "UnitInParty",
        "UnitInRaid",
        "UnitLevel",
        "tContains",
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

files["CritLog/CritLog.lua"] = {
    -- SavedVariables and the slash-command hook are required by Blizzard's
    -- addon conventions and must be real globals, not locals.
    globals = {
        "CritLog",
        "CritLogDB",
        "SLASH_CRITLOG1",
        "SLASH_CRITLOG2",
    },
}

exclude_files = {
    "tests/lint/*",
}
