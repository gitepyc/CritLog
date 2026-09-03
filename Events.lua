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

    if CritLogDB.LoginSoundFlag then
        self:PlaySound(self.Constants.sounds.login)
    end
end

function CritLog:READY_CHECK()
    if CritLogDB.ReadySoundFlag then
        self:PlaySound(self.Constants.sounds.readyCheck)
    end
end
