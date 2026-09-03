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

-- Matches a third-party lottery addon's raid-chat announcement (e.g.
-- CrossGambling) - not anything CritLog itself understands or runs, just a
-- fixed phrase to react to, same as raid end/wipe above.
function CritLog:CHAT_MSG_RAID(message)
    if not CritLogDB.GambleSoundFlag then
        return
    end

    if string.find(message, self.Constants.chatTriggers.gamble, 1, true) then
        self:PlaySound(self.Constants.sounds.lotteryFirst)
        self:PlaySound(self.Constants.sounds.lotterySecond)
    end
end

-- /roll results arrive as a system message, not a real chat channel -
-- English and German client locales phrase it differently, so both
-- patterns are tried. Actual classification is CritLog.Filters.classifyRoll
-- (pure, no WoW API) - this just parses the message and hands the numbers
-- off.
function CritLog:CHAT_MSG_SYSTEM(message)
    if not CritLogDB.RollSoundFlag then
        return
    end

    local _, rollResult, rollMin, rollMax = string.match(message, "(.+) rolls (%d+) %((%d+)%-(%d+)%)")
    if not rollResult then
        _, rollResult, rollMin, rollMax = string.match(message, "(.+) würfelt%. Ergebnis: (%d+) %((%d+)%-(%d+)%)")
    end
    if not rollResult then
        return
    end

    local soundKey = CritLog.Filters.classifyRoll(tonumber(rollResult), tonumber(rollMin), tonumber(rollMax))
    if soundKey then
        self:PlaySound(self.Constants.sounds[soundKey])
    end
end
