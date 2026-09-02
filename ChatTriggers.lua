function CritLog:CHAT_MSG_RAID_LEADER(message)
    local lowerMessage = string.lower(message)

    if tContains(self.Constants.chatTriggers.raidEnd, lowerMessage) then
        self:PlaySound(self.Constants.sounds.raidEndBye)
        self:PlaySound(self.Constants.sounds.raidEndFinal)
    end

    if tContains(self.Constants.chatTriggers.wipe, lowerMessage) then
        self:PlaySound(self.Constants.sounds.wipe)
    end
end
