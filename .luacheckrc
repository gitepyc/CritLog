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
        "GetTime", -- cooldown gate for the Mage Table/Healthstone ritual sounds (feature/legacy-sound-port)
        "UnitClass", -- class/role-based death-sound matching (feature/class-based-death-sounds)
        "UnitClassification",
        "UnitGUID",
        "UnitGroupRolesAssigned", -- class/role-based death-sound matching (feature/class-based-death-sounds)
        "UnitInParty",
        "UnitInRaid",
        "UnitIsPlayer", -- excludes NPCs from the melee/tank/priest death-sound class checks
        "UnitLevel",
        "tContains",
        "GetAddOnMetadata",
        "C_AddOns",
        "C_NamePlate",
        -- UI/Shared.lua: parent frame for the standalone options panels
        "UIParent",
        -- UI/Shared.lua: registers panels so Escape closes them
        "UISpecialFrames",
        "tinsert",
        -- UI/Shared.lua: the melee/tank/priest/boss detection-mode dropdowns
        "UIDropDownMenu_SetWidth",
        "UIDropDownMenu_Initialize",
        "UIDropDownMenu_CreateInfo",
        "UIDropDownMenu_AddButton",
        "UIDropDownMenu_SetText",
        "CloseDropDownMenus",
        "DropDownList1",
        "DropDownList2",
        -- UI/MainPanel.lua: confirmation dialog before Reset All
        "StaticPopup_Show",
        -- UI/Shared.lua: hover tooltip for each toggle row, replacing the
        -- static hint line underneath (feature/toggle-row-tooltips)
        "GameTooltip",
        -- Events.lua/UI/TitanButton.lua: gate + build the optional
        -- TitanPanel status-bar button (feature/titan-panel-integration)
        "IsAddOnLoaded",
        "TitanPanelButton_OnClick",
        "TitanPanelButton_UpdateButton",
        "Titan_Menu",
    },
    globals = {
        -- Blizzard slash-command convention: SlashCmdList is a client-owned
        -- global table that addons register new keys into.
        "SlashCmdList",
        -- Same convention: StaticPopupDialogs is a client-owned global
        -- table that addons register new dialog definitions into.
        "StaticPopupDialogs",
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
    -- UI/TitanButton.lua: registry.buttonTextFunction/tooltipTextFunction
    -- must be global function name strings (Titan calls _G[name]()), not
    -- local functions or CritLog.* table fields - see the reference
    -- implementation this is modeled on (TitanCritLine.lua's tcl_* globals).
    "CritLogTitan_GetButtonText",
    "CritLogTitan_GetTooltipText",
    "CritLogTitan_MenuGenerator",
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
    -- Nested agent worktrees can end up inside the repo directory during
    -- development; never part of the project itself.
    ".claude/*",
}
