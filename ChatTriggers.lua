function CritLog:CHAT_MSG_RAID_LEADER(message)
    local lowerMessage = string.lower(message)

    if tContains(self.Data.chatTriggers.raidEnd, lowerMessage) then
        self:PlaySound(self.Data.sounds.raidEndBye)
        self:PlaySound(self.Data.sounds.raidEndFinal)
    end

    if tContains(self.Data.chatTriggers.wipe, lowerMessage) then
        self:PlaySound(self.Data.sounds.wipe)
    end
end
