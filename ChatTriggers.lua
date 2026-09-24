function CritLog:CHAT_MSG_RAID_LEADER(message)
    local lowerMessage = string.lower(message)

    if tContains(self.Constants.chatTriggers.raidEnd, lowerMessage) then
        self:PlaySound(self.Constants.sounds.raidEnd)
    end

    if tContains(self.Constants.chatTriggers.wipe, lowerMessage) then
        self:PlaySound(self.Constants.sounds.wipe)
    end
end

-- Matches a third-party lottery addon's chat announcement (e.g.
-- CrossGambling), not anything CritLog itself understands or runs.
local function handleGambleMessage(message)
    if not CritLogDB.GambleSoundFlag then
        return
    end

    if string.find(message, CritLog.Constants.chatTriggers.gamble, 1, true) then
        CritLog:PlaySound(CritLog.Constants.sounds.lottery)
    end
end

function CritLog:CHAT_MSG_RAID(message)
    handleGambleMessage(message)
end

function CritLog:CHAT_MSG_PARTY(message)
    handleGambleMessage(message)
end

function CritLog:CHAT_MSG_GUILD(message)
    handleGambleMessage(message)
end

-- /roll results arrive as a system message. Matching only requires a
-- "roll"/"ürfel" substring (case-insensitive, covers every self/other and
-- English/German phrasing) plus the trailing "N (min-max)" numbers, since
-- the exact wording differs by who rolled and by locale.
function CritLog:CHAT_MSG_SYSTEM(message)
    if not CritLogDB.RollSoundFlag then
        return
    end

    local lowerMessage = string.lower(message)
    if not string.find(lowerMessage, "roll") and not string.find(lowerMessage, "ürfel") then
        return
    end

    local rollResult, rollMin, rollMax = string.match(message, "(%d+) %((%d+)%-(%d+)%)$")
    if not rollResult then
        return
    end

    local soundKey = CritLog.Filters.classifyRoll(tonumber(rollResult), tonumber(rollMin), tonumber(rollMax))
    if soundKey then
        self:PlaySound(self.Constants.sounds[soundKey])
    end
end
