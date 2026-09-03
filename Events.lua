-- Retail moved IsAddOnLoaded to C_AddOns.IsAddOnLoaded; fall back to the
-- older global for clients that don't have C_AddOns yet. Same pattern
-- CritLog.lua already uses for GetAddOnMetadata - in-game reported: the
-- plain global is nil on this client, "attempt to call a nil value" at
-- PLAYER_LOGIN, which silently skipped TitanPanel button setup entirely
-- (the whole reason it never showed up in Titan's list, not a category
-- issue - registry.category = "Combat" in UI/TitanButton.lua was already
-- correct, it just never ran).
local isAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded

local frame = CreateFrame("Frame")

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_SYSTEM")

frame:SetScript("OnEvent", function(_, event, ...)
    CritLog[event](CritLog, ...)
end)

function CritLog:PLAYER_LOGIN()
    self:SetDefaults()
    self:PrintCritLogs()

    -- Optional TitanPanel status-bar button (UI/TitanButton.lua) - see
    -- docs/ROADMAP.md item 3. Gated here so it's completely inert (no
    -- frame created, no error) when Titan isn't installed.
    if isAddOnLoaded("Titan") then
        self:InitTitanPanelButton()
    end
end

function CritLog:READY_CHECK()
    if CritLogDB.ReadySoundFlag then
        self:PlaySound(self.Constants.sounds.readyCheck)
    end
end
